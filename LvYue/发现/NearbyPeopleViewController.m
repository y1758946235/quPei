//
//  NearbyPeopleViewController.m
//  澜庭
//
//  Created by 广有射怪鸟事 on 15/9/24.
//  Copyright (c) 2015年 刘瀚韬. All rights reserved.
//

#import "NearbyPeopleViewController.h"
#import "NearbyPeopleTableViewCell.h"
#import "LYHttpPoster.h"
#import "MBProgressHUD+NJ.h"
#import "NearByPeopleModel.h"
#import "DetailDataViewController.h"
#import "DetailDataViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "LYUserService.h"

@interface NearbyPeopleViewController ()<UITableViewDataSource,UITableViewDelegate,CLLocationManagerDelegate>

@property (nonatomic,strong) NSString *latitude;
@property (nonatomic,strong) NSString *longitude;

//定位信息管理者
@property (nonatomic, strong) CLLocationManager *clManager;

//地理编码对象
@property (nonatomic, strong) CLGeocoder *geocoder;

@property (nonatomic,assign) float longitudeF;
@property (nonatomic,assign) float latitudeF;
@property (nonatomic,strong) NearByPeopleModel *model;//模型
@property (nonatomic,strong) NSMutableArray *modelArray;//模型数组
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *imgViewArray;//图标数组
@property (nonatomic,assign) NSInteger imgCount;//图标count

@end

@implementation NearbyPeopleViewController

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
    // Do any additional setup after loading the view.
    
    self.title = @"附近的人";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.modelArray = [[NSMutableArray alloc] init];
    [self createTableView];
    
    self.latitude = @"";
    self.longitude = @"";
    
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


//创建tableview
- (void)createTableView{
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation *currentLocation = [locations lastObject];
    self.latitude = [NSString stringWithFormat:@"%f",currentLocation.coordinate.latitude];
    self.longitude = [NSString stringWithFormat:@"%f",currentLocation.coordinate.longitude];
    
    //停止定位
    [_clManager stopUpdatingLocation];
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

#pragma mark 网络请求

- (void)getDataFromWeb{
    
    self.longitudeF = [self.longitude floatValue];
    self.latitudeF = [self.latitude floatValue];
    float absLong = fabsf(self.longitudeF);
    float absLati = fabsf(self.latitudeF);
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/nearby",REQUESTHEADER] andParameter:@{@"user_id":[LYUserService sharedInstance].userID,@"longitude":[NSString stringWithFormat:@"%f",absLong],@"latitude":[NSString stringWithFormat:@"%f",absLati]} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [self.modelArray removeAllObjects];
            NSArray *array = successResponse[@"data"][@"list"];
            for (NSDictionary *dict in array) {
                self.model = [[NearByPeopleModel alloc] initWithDict:dict];
                [self.modelArray addObject:self.model];
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

#pragma mark tableview代理事件

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.modelArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NearbyPeopleTableViewCell *cell = [NearbyPeopleTableViewCell myCellWithTableView:tableView indexPath:indexPath];
    if (self.modelArray.count) {
        [cell fillDataWithModel:self.modelArray[indexPath.row]];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 20)];
    view.backgroundColor =  [UIColor colorWithRed:238.0 green:238.0 blue:238.0 alpha:0];
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DetailDataViewController *detail = [[DetailDataViewController alloc] init];
    self.model = self.modelArray[indexPath.row];
    detail.friendId = self.model.id;
    [self.navigationController pushViewController:detail animated:YES];
}

@end
