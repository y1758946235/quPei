//
//  selectProvinceVC.m
//  LvYue
//
//  Created by X@Han on 17/1/6.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "selectProvinceVC.h"
#import "selectCityVC.h"
#import "MBProgressHUD+NJ.h"
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "LocationModel.h"
#import <CoreLocation/CoreLocation.h>
#import "BMapKit.h"


//省份
@interface selectProvinceVC ()<UITableViewDataSource,UITableViewDelegate,CLLocationManagerDelegate,BMKGeoCodeSearchDelegate>
{
    //保存当前选择的省份
    NSString *currentProvince;
    //保存当前选择的城市
    
    NSString *currentCity;
    //保存当前选择的区县
    NSString *currentDistrict;
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

@implementation selectProvinceVC

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
    [self setNav];
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
    [self getDataFromWeb];
}
#pragma mark   -------配置导航栏
- (void)setNav{
    self.title = @"选择省份";
    //导航栏title的颜色
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithHexString:@"#424242"],UITextAttributeTextColor, [UIFont fontWithName:@"PingFangSC-Medium" size:18],UITextAttributeFont, nil]];
    
    //导航栏返回按钮
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(16, 38, 28, 14)];
    [button setTitleColor:[UIColor colorWithHexString:@"#424242"] forState:UIControlStateNormal];
    [button setTitle:@"返回" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [button addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = back;
    
    //导航栏保存按钮
    UIButton *edit = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-16-60, 38, 60, 14)];
    [edit setTitleColor:[UIColor colorWithHexString:@"#ff5252"] forState:UIControlStateNormal];
    [edit setTitle:@"当前位置" forState:UIControlStateNormal];
    edit.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [edit addTarget:self action:@selector(currentlocat) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *edited = [[UIBarButtonItem alloc]initWithCustomView:edit];
    self.navigationItem.rightBarButtonItem = edited;

    
}


- (void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)currentlocat{
    if (self.currnentLocationBlock != nil) {
        if ([CommonTool dx_isNullOrNilWithObject:currentProvince] ||[CommonTool dx_isNullOrNilWithObject:currentCity]) {
            [MBProgressHUD showError:@"定位失败,请手动选择地址"];
        }else{
            self.currnentLocationBlock(currentProvince,currentCity,currentDistrict);
            [self.navigationController popViewControllerAnimated:YES];

        }
      
    }
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
//    [MBProgressHUD showError:@"定位失败,请重试"];
}

#pragma mark 代理方法返回反地理编码结果
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error{
    if (result) {
        currentCity = [NSString stringWithFormat:@"%@", result.addressDetail.city];
        currentProvince = [NSString stringWithFormat:@"%@", result.addressDetail.province];
         currentDistrict = [NSString stringWithFormat:@"%@", result.addressDetail.district];
      
    }else{
        currentCity = @"定位失败";
    }
    [self.tableV reloadData];
}

- (void)getDataFromWeb{
    [MBProgressHUD showMessage:nil toView:self.view];
    
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/cache/getProvince",REQUESTHEADER] andParameter:@{} success:^(id successResponse) {
        // MLOG(@"省份结果:%@",successResponse);
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            [self.locationArray removeAllObjects];
            for (NSDictionary *dict in successResponse[@"data"]) {
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
    self.tableV = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight-48)];
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
    
    if (indexPath.row>2) {
        self.model = self.locationArray[indexPath.row-3];
        selectCityVC *next = [[selectCityVC alloc]init];
        next.preLoc = self.model.name; //选中城市的名字
        next.countryId = self.model.level;//选中城市的id
        
        [self.navigationController pushViewController:next animated:YES];
    }
    
}


//创建每个cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cellIdentifier";
    //分割用的cell
    if (indexPath.row == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        [cell setBackgroundColor:UIColorWithRGBA(234, 234, 234, 1)];
        cell.textLabel.text = @"当前定位";
        cell.textLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        
        cell.textLabel.textColor = [UIColor colorWithHexString:@"#424242"];
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
        countryLabel.textColor = [UIColor colorWithHexString:@"#757575"];
        countryLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
        countryLabel.text = @"中国";
        [cell addSubview:countryLabel];
        
        return cell;
    }
    else if(indexPath.row == 2) {
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        [cell setBackgroundColor:UIColorWithRGBA(234, 234, 234, 1)];
        cell.textLabel.text = @"全部地区";
        cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
        cell.textLabel.textColor = [UIColor colorWithHexString:@"#424242"];
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
            cell.textLabel.textColor = [UIColor colorWithHexString:@"#757575"];
            cell.textLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
        }
        return cell;
    }
}


- (void)currnentLocationBlock:(CurrnentLocationBlock)block{
    self.currnentLocationBlock = block;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
