//
//  LocalCountryViewController.m
//  豆客项目
//
//  Created by Xia Wei on 15/10/9.
//  Copyright © 2015年 Xia Wei. All rights reserved.
//

#import "LocalCountryViewController.h"
#import "XWLocationViewController.h"
#import "MBProgressHUD+NJ.h"
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "LocationModel.h"
#import <CoreLocation/CoreLocation.h>
#import "BMapKit.h"

@interface LocalCountryViewController ()<UITableViewDataSource,UITableViewDelegate,CLLocationManagerDelegate,BMKGeoCodeSearchDelegate>
{
    //保存当前选择的城市
    NSString *currentCity;
}

@property(nonatomic,strong)NSMutableArray *dataArr;
@property (nonatomic,strong) LocationModel *model;
@property (nonatomic,strong) NSMutableArray *locationArray;
@property (nonatomic,strong) UITableView *tableV;

@property (nonatomic,strong) NSString *latitude;
@property (nonatomic,strong) NSString *longitude;

@property (nonatomic,strong) BMKGeoCodeSearch *searcher;

//定位信息管理者
@property (nonatomic, strong) CLLocationManager *clManager;

//地理编码对象
@property (nonatomic, strong) CLGeocoder *geocoder;

@end

@implementation LocalCountryViewController

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
    [self tableViewCreated];
    
    currentCity = @"定位中";
    
    self.clManager.delegate = self;
    
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 8.0) {
        //前台和后台都允许请求用户是否允许开启定位 IOS8.0以上版本需要设置环境参数
        [_clManager requestAlwaysAuthorization];
        [_clManager startUpdatingLocation];
    }
    else {
        //如果是IOS8.0以下的版本，则可直接开启定位
        [_clManager startUpdatingLocation];
    }
    
    self.locationArray = [[NSMutableArray alloc] init];
    _dataArr = [[NSMutableArray alloc]init];
    //添加测试数据
    for (int i = 0; i < 100; i ++) {
        NSString *str = [NSString stringWithFormat:@"%d国",i];
        [_dataArr addObject:str];
    }
    self.title = @"定位";
    
    [self getDataFromWeb];
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation *currentLocation = [locations lastObject];
    
    self.latitude = [NSString stringWithFormat:@"%f",currentLocation.coordinate.latitude];
    self.longitude = [NSString stringWithFormat:@"%f",currentLocation.coordinate.longitude];

    //停止定位
    [_clManager stopUpdatingLocation];
    
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
        currentCity = [NSString stringWithFormat:@"%@", result.addressDetail.city];
        NSLog(@"%@ - %@", result.address, result.addressDetail.streetNumber);
    }else{
        currentCity = @"定位失败";
    }
    [self.tableV reloadData];
}

- (void)getDataFromWeb{
    [MBProgressHUD showMessage:nil toView:self.view];
    
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/area/list",REQUESTHEADER] andParameter:@{} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            [self.locationArray removeAllObjects];
            for (NSDictionary *dict in successResponse[@"data"][@"list"]) {
                self.model = [[LocationModel alloc] initWithDict:dict];
                [self.locationArray addObject:self.model];
            }
            [self.tableV reloadData];
        } else {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
}

//创建tableView
- (void) tableViewCreated{
    self.tableV = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight)];
    self.tableV.delegate = self;
    self.tableV.dataSource = self;
    self.tableV.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableV];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return 30;
    }
    else if (indexPath.row == 2){
        return 20;
    }
    return 48;
}

//设置cell的数目
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.locationArray.count;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //点击选择下一层地区并把当前选择的地区传送过去
    if (indexPath.row > 2) {
        self.model = self.locationArray[indexPath.row - 3];
        if ([self.model.status integerValue]) {
            XWLocationViewController *next = [[XWLocationViewController alloc]init];
            next.preLoc = self.model.name;
            next.isProvince = YES;
            next.countryId = self.model.id;
            next.preView = self.preView;
            next.countryName = self.model.name;
            [self.navigationController pushViewController:next animated:YES];
        }
        else{
            if ([self.preView isEqualToString:@"search"]) {
                NSDictionary *dict = @{@"searchCountry":self.model.id,@"countryName":self.model.name};
                [[NSNotificationCenter defaultCenter] postNotificationName:@"searchCountry" object:nil userInfo:dict];
                [self.navigationController popViewControllerAnimated:YES];
            }
            else if ([self.preView isEqualToString:@"live"]){
                NSDictionary *dict = @{@"searchCountry":self.model.id,@"countryName":self.model.name};
                [[NSNotificationCenter defaultCenter] postNotificationName:@"liveSelect" object:nil userInfo:dict];
                [self.navigationController popViewControllerAnimated:YES];
            }
            else if ([self.preView isEqualToString:@"addLive"]){
                NSDictionary *dict = @{@"searchCountry":self.model.id,@"countryName":self.model.name};
                [[NSNotificationCenter defaultCenter] postNotificationName:@"addLive" object:nil userInfo:dict];
                [self.navigationController popViewControllerAnimated:YES];
            }
            else{
                [MBProgressHUD showMessage:nil toView:self.view];
                [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/update",REQUESTHEADER] andParameter:@{@"id":[NSString stringWithFormat:@"%@",[LYUserService sharedInstance].userID],@"country":self.model.id,@"province":self.model.id,@"city":self.model.id} success:^(id successResponse) {
                    MLOG(@"结果:%@",successResponse);
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
                        NSDictionary *dict = @{@"countryName":self.model.name};
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"changeLocation" object:nil userInfo:dict];
                        [self.navigationController popViewControllerAnimated:YES];
                        
                    } else {
                        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                        [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
                    }
                } andFailure:^(id failureResponse) {
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    [MBProgressHUD showError:@"服务器繁忙,请重试"];
                }];
            }
        }
    }
}

//创建每个cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cellIdentifier";
    //分割用的cell
    if (indexPath.row == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        [cell setBackgroundColor:UIColorWithRGBA(234, 234, 234, 1)];
        cell.textLabel.text = @"当前位置";
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
        int temp = 158;
        cell.textLabel.textColor = UIColorWithRGBA(temp, temp, temp, 1);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.userInteractionEnabled = NO;
        return cell;
    }
    //已选中的地区
    else if(indexPath.row == 1) {
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        cell.userInteractionEnabled = NO;
        //设置定位的图片
        UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(13, 14, 20, 20)];
        imageV.contentMode = UIViewContentModeScaleAspectFit;
        imageV.image = [UIImage imageNamed:@"map-maker"];
        [cell addSubview:imageV];
        
        //设置国家label
        UILabel *countryLabel = [[UILabel alloc] initWithFrame:CGRectMake(imageV.frame.origin.x + imageV.frame.size.width + 10, imageV.frame.origin.y - 5, 200, 30)];
        countryLabel.text = currentCity;
        [cell addSubview:countryLabel];
        
//        //设置地区label
//        UILabel *placeLabel = [[UILabel alloc] init];
//        //使每个label自适应宽度
//        CGSize labelSizePlace = [_locPlace boundingRectWithSize:size options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
//        [placeLabel setFrame:CGRectMake(CGRectGetMaxX(countryLabel.frame) + 10, 0, labelSizePlace.width, 48)];
//        placeLabel.text = _locPlace;
//        [cell addSubview:placeLabel];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
    else if(indexPath.row == 2) {
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        [cell setBackgroundColor:UIColorWithRGBA(234, 234, 234, 1)];
        cell.textLabel.text = @"全部地区";
        cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
        int temp = 158;
        cell.textLabel.textColor = UIColorWithRGBA(temp, temp, temp, 1);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        self.model = self.locationArray[indexPath.row - 3];
        //所有地区
        if (self.locationArray) {
            [cell setBackgroundColor:[UIColor redColor]];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] init];
            }
            UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 47, kMainScreenWidth,1)];
            lineView.backgroundColor = UIColorWithRGBA(234, 234, 234, 1);
            [cell addSubview:lineView];
            cell.textLabel.text = self.model.name;
        }
        return cell;
    }
}

@end
