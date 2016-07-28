//
//  ThemeDateViewController.m
//  澜庭
//
//  Created by 广有射怪鸟事 on 15/9/24.
//  Copyright (c) 2015年 刘瀚韬. All rights reserved.
//

#import "ThemeDateViewController.h"
#import "ThemeDateTableViewCell.h"
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "MBProgressHUD+NJ.h"
#import <CoreLocation/CoreLocation.h>
#import "ThemeDateModel.h"
#import "AllWordViewController.h"
#import "BMapKit.h"

@interface ThemeDateViewController ()<UITableViewDataSource,UITableViewDelegate,CLLocationManagerDelegate,BMKGeoCodeSearchDelegate>
{
    //保存当前选择的城市
    NSString *currentCity;
}

//定位信息管理者
@property (nonatomic, strong) CLLocationManager *clManager;

//地理编码对象
@property (nonatomic,strong) BMKGeoCodeSearch *searcher;

@property (nonatomic,strong) NSMutableArray *modelArray;
@property (nonatomic,strong) ThemeDateModel *model;
@property (nonatomic,strong) UITableView *table;

@property (nonatomic,strong) NSString *latitude;
@property (nonatomic,strong) NSString *longitude;

@end

@implementation ThemeDateViewController

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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"主题豆客";
    
    self.modelArray = [[NSMutableArray alloc] init];
    
    self.view.backgroundColor = RGBACOLOR(238, 238, 238, 1.0);
    [self createTableView];
    
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

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation *currentLocation = [locations lastObject];
    
    self.latitude = [NSString stringWithFormat:@"%f",currentLocation.coordinate.latitude];
    self.longitude = [NSString stringWithFormat:@"%f",currentLocation.coordinate.longitude];
    
    //停止定位
    [_clManager stopUpdatingLocation];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    //初始化检索对象
    self.searcher =[[BMKGeoCodeSearch alloc] init];
    self.searcher.delegate = self;
    
    //发起反向地理编码检索
    CLLocationCoordinate2D pt = (CLLocationCoordinate2D){[self.latitude floatValue], [self.longitude floatValue]};
    BMKReverseGeoCodeOption *reverseGeoCodeSearchOption = [[BMKReverseGeoCodeOption alloc] init];
    reverseGeoCodeSearchOption.reverseGeoPoint = pt;
    [self.searcher reverseGeoCode:reverseGeoCodeSearchOption];
    BOOL flag = [self.searcher reverseGeoCode:reverseGeoCodeSearchOption];
    if(flag)
    {
        NSLog(@"反geo检索发送成功");
    }
    else
    {
        NSLog(@"反geo检索发送失败");
    }
}

#pragma mark 代理方法返回反地理编码结果
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error{
    if (result) {
        currentCity = [NSString stringWithFormat:@"%@", result.addressDetail.city];
        NSLog(@"%@ - %@", result.address, result.addressDetail.streetNumber);
    }else{
        currentCity = @"定位失败";
    }
    [self getDataFromWeb];
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

//创建tableview
- (void)createTableView{
    self.table = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    self.table.dataSource = self;
    self.table.delegate = self;
    [self.view addSubview:self.table];
}

#pragma mark 获取网路数据

- (void)getDataFromWeb{
    NSString * newString;
    if (currentCity.length > 0) {
        newString = [currentCity substringWithRange:NSMakeRange(0, [currentCity length] - 1)];
    }
    else{
        newString = @"";
    }
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/group/publicList",REQUESTHEADER] andParameter:@{@"user_id":[LYUserService sharedInstance].userID,@"city":newString} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            NSArray *array = successResponse[@"data"][@"list"];
            [self.modelArray removeAllObjects];
            for (NSDictionary *dict in array) {
                self.model = [[ThemeDateModel alloc] initWithDict:dict];
                [self.modelArray addObject:self.model];
            }
            [self.table reloadData];
            
        } else {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
}

#pragma mark tableview代理方法

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.modelArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 220;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 20;
    }
    else{
        return 0.1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ThemeDateTableViewCell *cell = [ThemeDateTableViewCell myCellWithTableView:tableView andIndexPath:indexPath];
    if (self.modelArray.count) {
        [cell fillDataWithModel:self.modelArray[indexPath.section]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.model = self.modelArray[indexPath.section];
    AllWordViewController *all = [[AllWordViewController alloc] init];
    all.title = @"群简介";
    all.detail = self.model.desc;
    [self.navigationController pushViewController:all animated:YES];
}

@end
