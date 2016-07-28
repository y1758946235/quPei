//
//  PeopleLiveViewController.m
//  LvYue
//
//  Created by LHT on 15/11/12.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import "PeopleLiveViewController.h"
#import "PeopleLiveTableViewCell.h"
#import "AddLiveViewController.h"
#import "MBProgressHUD+NJ.h"
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "LiveModel.h"
#import <CoreLocation/CoreLocation.h>
#import "DetailDataViewController.h"
#import "AllWordViewController.h"
#import "SelectCityTableViewCell.h"
#import "LocalCountryViewController.h"
#import "BMapKit.h"

@interface PeopleLiveViewController ()<UITableViewDataSource,UITableViewDelegate,CLLocationManagerDelegate,BMKGeoCodeSearchDelegate>
{
    //保存当前选择的城市
    NSString *currentCity;
}

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) LiveModel *liveModel;
@property (nonatomic,strong) NSMutableArray *liveArray;
@property (nonatomic,strong) NSString *cityId;

@property (nonatomic,strong) NSString *latitude;
@property (nonatomic,strong) NSString *longitude;

//定位信息管理者
@property (nonatomic, strong) CLLocationManager *clManager;

//地理编码对象
@property (nonatomic, strong) CLGeocoder *geocoder;

@property (nonatomic,strong) BMKGeoCodeSearch *searcher;//百度定位反编译

@end

@implementation PeopleLiveViewController

#pragma mark - 定位管理者
- (CLLocationManager *)clManager {
    
    if (!_clManager) {
        _clManager = [[CLLocationManager alloc] init];
        //设置定位硬件的精准度
        _clManager.desiredAccuracy = kCLLocationAccuracyBest;
        //设置定位硬件的刷新频率
        _clManager.distanceFilter = kCLLocationAccuracyKilometer;
    }
    return _clManager;
}

#pragma mark - 地理编码对象
- (CLGeocoder *)geocoder {
    
    if (_geocoder == nil) {
        _geocoder = [[CLGeocoder alloc] init];
    }
    return _geocoder;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"民宿";
    
    self.liveArray = [[NSMutableArray alloc] init];
    
    [self setRightButton:[UIImage imageNamed:@"faqi"] title:nil target:self action:@selector(addPeopleLive)];
    
    [self createTableView];
    
    self.latitude = @"";
    self.longitude = @"";
    self.cityId = @"";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCity:) name:@"liveSelect" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(okAdd:) name:@"okAdd" object:nil];
    
    self.clManager.delegate = self;
    [MBProgressHUD showMessage:nil toView:self.view];
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 8.0) {
        //前台和后台都允许请求用户是否允许开启定位 IOS8.0以上版本需要设置环境参数
        [_clManager requestAlwaysAuthorization];
        [_clManager startUpdatingLocation];
    }
    else {
        //如果是IOS8.0以下的版本，则可直接开启定位
        [_clManager startUpdatingLocation];
    }
}

- (void)okAdd:(NSNotification *)aNotification{
    [self getDataFromWeb];
}

- (void)changeCity:(NSNotification *)aNotification{
    if (aNotification.userInfo[@"searchCity"]) {
        currentCity = aNotification.userInfo[@"cityName"];
        self.cityId = aNotification.userInfo[@"searchCity"];
    }
    else if (aNotification.userInfo[@"searchPro"]){
        currentCity = aNotification.userInfo[@"proName"];
        self.cityId = aNotification.userInfo[@"searchPro"];
    }
    else{
        currentCity = aNotification.userInfo[@"countryName"];
        self.cityId = aNotification.userInfo[@"searchCountry"];
    }
    [self getDataFromWeb];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)createTableView{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight) style:UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation *currentLocation = [locations lastObject];
    self.latitude = [NSString stringWithFormat:@"%f",currentLocation.coordinate.latitude];
    self.longitude = [NSString stringWithFormat:@"%f",currentLocation.coordinate.longitude];
    
    //初始化检索对象
    self.searcher =[[BMKGeoCodeSearch alloc] init];
    self.searcher.delegate = self;
    
    //停止定位
    [_clManager stopUpdatingLocation];
    [self getDataFromWeb];
    
    //发起反向地理编码检索
    CLLocationCoordinate2D pt = (CLLocationCoordinate2D){[self.latitude floatValue], [self.longitude floatValue]};
    BMKReverseGeoCodeOption *reverseGeoCodeSearchOption = [[BMKReverseGeoCodeOption alloc] init];
    reverseGeoCodeSearchOption.reverseGeoPoint = pt;
    [self.searcher reverseGeoCode:reverseGeoCodeSearchOption];
    BOOL flag = [self.searcher reverseGeoCode:reverseGeoCodeSearchOption];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        //用户允许授权,开启定位
        [_clManager startUpdatingLocation];
    } else {
        [MBProgressHUD showError:@"用户拒绝授权,请在设置中开启"];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [MBProgressHUD showError:@"定位失败,请重试"];
}

#pragma mark 代理方法返回反地理编码结果
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error{
    if (result) {
        if (!result.addressDetail.city) {
            currentCity = @"定位失败";
        } else {
            //保存定位到的城市
            currentCity = result.addressDetail.city;
        }
    }else{
        currentCity = @"定位失败";
    }
    [self.tableView reloadData];
}

#pragma mark 网络请求

- (void)getDataFromWeb{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [MBProgressHUD showMessage:nil toView:self.view];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/hostel/list",REQUESTHEADER] andParameter:@{@"longitude":self.longitude,@"latitude":self.latitude,@"city":self.cityId} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            [self.liveArray removeAllObjects];
            for (NSDictionary *dict in successResponse[@"data"][@"list"]) {
                self.liveModel = [[LiveModel alloc] initWithDict:dict];
                [self.liveArray addObject:self.liveModel];
            }
            [self.tableView reloadData];
        } else {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
}

#pragma mark 添加民宿事件

- (void)addPeopleLive{
    AddLiveViewController *add = [[AddLiveViewController alloc] init];
    [self.navigationController pushViewController:add animated:YES];
}

#pragma mark tableview 代理

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.liveArray.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section >= 1) {
        self.liveModel = self.liveArray[indexPath.section - 1];
    }
    NSArray *csarray = [self.liveModel.photos componentsSeparatedByString:@";"];
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:csarray];
    
    if ([self isBlankString:array.lastObject]) {
        [array removeLastObject];
    }
    if ([self.liveModel.photos isEqualToString:@"<null>"]) {
        [array removeAllObjects];
    }
    
    if (indexPath.section == 0) {
        return 44;
    }
    
    if (array.count <= 3 && array.count > 0) {
        return 230;
    }
    else if (array.count >= 3 && array.count <= 6){
        return 299;
    }
    else if (array.count > 6){
        return 392;
    }
    else{
        return 150;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        SelectCityTableViewCell *selectCell = [SelectCityTableViewCell myCellWithTableView:tableView andIndexPath:indexPath];
        [selectCell fillDataWithCity:currentCity];
        return selectCell;
    }
    
    PeopleLiveTableViewCell *cell = [PeopleLiveTableViewCell myCellWithTableView:tableView indexPath:indexPath];
    self.liveModel = self.liveArray[indexPath.section - 1];
    [cell fillDataWithModel:self.liveModel];
    cell.navi = self.navigationController;
    cell.cityLabel.hidden = YES;
    cell.mapIcon.hidden = YES;
    [cell.checkBtn addTarget:self action:@selector(checkAction:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        LocalCountryViewController *local = [[LocalCountryViewController alloc] init];
        local.preView = @"live";
        [self.navigationController pushViewController:local animated:YES];
    }
    else{
        AllWordViewController *all = [[AllWordViewController alloc] init];
        self.liveModel = self.liveArray[indexPath.section - 1];
        all.detail = self.liveModel.content;
        [self.navigationController pushViewController:all animated:YES];
    }
}

#pragma mark 查看详细资料事件

- (void)checkAction:(UIButton *)sender{
    
    UITableViewCell *cell = (UITableViewCell *)[[sender superview] superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSInteger section = indexPath.section;
    
    self.liveModel = self.liveArray[section - 1];
    DetailDataViewController *deta = [[DetailDataViewController alloc] init];
    deta.friendId = [self.liveModel.userId integerValue];
    [self.navigationController pushViewController:deta animated:YES];
}

#pragma mark 判断是否为空或只有空格

- (BOOL)isBlankString:(NSString *)string{
    
    if (string == nil) {
        return YES;
    }
    
    if (string == NULL) {
        return YES;
    }
    
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}

@end
