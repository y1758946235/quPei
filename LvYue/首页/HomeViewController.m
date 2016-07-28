//
//  HomePageViewController.m
//  旅约项目
//
//  Created by Xia Wei on 15/9/23.
//  Copyright © 2015年 Xia Wei. All rights reserved.
//

#import "HomeViewController.h"
#import "HomePageTableCell.h"
#import "HomeTableView.h"
#import "CycleScrollView.h"
#import "NSString+DeleteLastWord.h"
#import "LocalCountryViewController.h"
#import "SearchNearbyViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "LYUserService.h"
#import "StrategyViewController.h"
#import "HelpCenterViewController.h"
#import "MBProgressHUD+NJ.h"
#import "LYHttpPoster.h"
#import "HomeModel.h"
#import "MJRefresh.h"
#import "SubscriptionViewController.h"
#import "BMapKit.h"
#import "NewHomeTableViewCell.h"
#import "DetailDataViewController.h"
#import "KDCycleBannerView.h"

@interface HomeViewController()<UIScrollViewDelegate,CLLocationManagerDelegate,BMKGeoCodeSearchDelegate,UITableViewDataSource,UITableViewDelegate,KDCycleBannerViewDelegate,KDCycleBannerViewDataSource>{
    UINib *nib;
    int _currentPage;
    BOOL moreFunctionIsShow;
    NSString *_currentCountry;
    float rigthDistance;//更多功能的View到右边框的位置
    
    NSInteger currentPage;
    NSString *refreshType;//find为按条件搜索,near为附近的人
    
    //保存当前选择的城市
    NSString *currentCity;
    UIView *tableHeadView;
    KDCycleBannerView *cycleBannerViewBottom;//轮播图
}

@property(nonatomic,strong)NSMutableArray *scrollImageArray;
@property(nonatomic,strong)NSTimer *timer;
@property(nonatomic,strong)CycleScrollView *cycleView;
@property(nonatomic,strong)UILabel *locCity;
@property(nonatomic,strong)UIView *backView;
@property(nonatomic,strong)UIButton *modalBtn;
@property(nonatomic,strong)CLLocationManager *locManager;
@property (nonatomic,strong) UITableView *tableV;

@property (nonatomic,strong) NSMutableArray *guideArray;
@property (nonatomic,strong) HomeModel *homeModel;

@property (nonatomic,strong) NSString *latitude;
@property (nonatomic,strong) NSString *longitude;


//上拉刷新用的搜索条件属性
@property (nonatomic,strong) NSString *guideSex;//性别
@property (nonatomic,strong) NSString *guideCity;//城市
@property (nonatomic,strong) NSString *guideProvince;//省
@property (nonatomic,strong) NSString *guideCountry;//国家
@property (nonatomic,strong) NSString *guideAge;//年龄
@property (nonatomic,strong) NSString *guideServiceContent;//服务项目
@property (nonatomic,strong) NSString *guideName;//关键词
@property (nonatomic,strong) NSString *guideLongitude;//经纬度
@property (nonatomic,strong) NSString *guideLatitude;

@property (nonatomic,strong) BMKGeoCodeSearch *searcher;

//地理编码对象
@property (nonatomic, strong) CLGeocoder *geocoder;

//定位信息管理者
@property (nonatomic, strong) CLLocationManager *clManager;

@end

@implementation HomeViewController

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
    
    if ([refreshType isEqualToString:@"near"]) {
        self.tableV.headerPullToRefreshText = @"下拉可以刷新";
        self.tableV.headerReleaseToRefreshText = @"松开马上刷新";
        self.tableV.headerRefreshingText = @"刷新中";
    }
    else if ([refreshType isEqualToString:@"find"]){
        self.tableV.headerPullToRefreshText = @"下拉回到附近的人";
        self.tableV.headerReleaseToRefreshText = @"松开马上刷新";
        self.tableV.headerRefreshingText = @"刷新中";
    }
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.guideArray = [[NSMutableArray alloc] init];
    
    //如果未获取到当前国家信息，国家就为未知
    _currentCountry = @"未知";
    
    self.latitude = @"";
    self.longitude = @"";
    
    refreshType = @"near";
    
    currentPage = 1;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(autoLogin:) name:@"autoLogin" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCity:) name:@"reloadLocation_XW" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(findGuide:) name:@"findGuide" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeFrame:) name:@"changeHomeFrame" object:nil];
    
    [self loadImage];

    self.clManager.delegate = self;
    self.clManager.desiredAccuracy = kCLLocationAccuracyBest;

    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 8.0) {
        //前台和后台都允许请求用户是否允许开启定位 IOS8.0以上版本需要设置环境参数
        [_clManager requestAlwaysAuthorization];
        [_clManager startUpdatingLocation];
    }
    else {
        //如果是IOS8.0以下的版本，则可直接开启定位
        [_clManager startUpdatingLocation];
    }
    
    //设置navigationBar
    [self setSelfNavigationBar];
    
    [self moreFunctionCreated];
}

- (void)changeFrame:(NSNotification *)aNotification{
    self.tableV.frame = CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight);
}

#pragma mark 轮播图网络请求

//加载scrollView的图片
- (void)loadImage{
    self.scrollImageArray = [[NSMutableArray alloc] init];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/assets/homeImg",REQUESTHEADER] andParameter:@{} success:^(id successResponse) {
        MLOG(@"轮播图结果:%@",successResponse);
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            
            NSArray *array = successResponse[@"data"][@"imgs"];
            for (NSDictionary *dict in array) {
                NSString *imgStr = dict[@"img"];
                NSString *imgName = [NSString stringWithFormat:@"%@%@",IMAGEHEADER,imgStr];
                [self.scrollImageArray addObject:imgName];
            }
            
            [self scrollViewCreated];
            
        } else {
            
        }
    } andFailure:^(id failureResponse) {
        
    }];
}


- (void)findGuide:(NSNotification *)aNotification{
    NSString *cityName = [NSString stringWithFormat:@"%@",aNotification.userInfo[@"cityName"]];
    NSString *proName = [NSString stringWithFormat:@"%@",aNotification.userInfo[@"provinceName"]];
    NSString *countryName = [NSString stringWithFormat:@"%@",aNotification.userInfo[@"countryName"]];
    self.guideArray = aNotification.userInfo[@"guide"];
    refreshType = aNotification.userInfo[@"type"];
//    self.tableV.guideArray = self.guideArray;
    self.guideSex = aNotification.userInfo[@"sex"];
    self.guideProvince = [NSString stringWithFormat:@"%@",aNotification.userInfo[@"province"]];
    self.guideCountry = [NSString stringWithFormat:@"%@",aNotification.userInfo[@"country"]];
    self.guideCity = [NSString stringWithFormat:@"%@",aNotification.userInfo[@"city"]];
    self.guideAge = aNotification.userInfo[@"age"];
    self.guideServiceContent = aNotification.userInfo[@"service_content"];
    self.guideName = aNotification.userInfo[@"name"];
    self.guideLongitude = aNotification.userInfo[@"longitude"];
    self.guideLatitude = aNotification.userInfo[@"latitude"];
    if (![self isBlankString:cityName]) {
        _locCity.text = cityName;
    }
    else if (![self isBlankString:proName]){
        _locCity.text = proName;
    }
    else if (![self isBlankString:countryName]){
        _locCity.text = countryName;
    }
    else if (![self isBlankString:self.guideName]){
        _locCity.text = @"关键字";
    }
    else{
        _locCity.text = @"全部";
    }
    [self.tableV reloadData];
    [self.tableV footerEndRefreshing];
}

//创建scrollView和上面的关闭按钮
-(void)scrollViewCreated{
    
    //设置tableHeadView里面ScrollView的高度
    CGFloat tableHeadViewHeight = kMainScreenWidth / 2;
    
    //创建整个view的容器
    tableHeadView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ViewWidth, tableHeadViewHeight)];
    [tableHeadView setBackgroundColor:[UIColor whiteColor]];
    
    cycleBannerViewBottom = [KDCycleBannerView new];
    cycleBannerViewBottom.frame = CGRectMake(0, 0, kMainScreenWidth, kMainScreenWidth / 2); //位置及宽高
    cycleBannerViewBottom.datasource = self;
    cycleBannerViewBottom.delegate = self;
    cycleBannerViewBottom.continuous = YES; //是否连续显示
    cycleBannerViewBottom.autoPlayTimeInterval = 4; //时间间隔
    [tableHeadView addSubview:cycleBannerViewBottom];
    
    //创建点击关闭开头的按钮
    UIButton *closeBtn = [[UIButton alloc]initWithFrame:CGRectMake(7, 7, 20, 20)];
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    closeBtn.contentMode = UIViewContentModeScaleAspectFit;
    [closeBtn addTarget:self action:@selector(closeTableHeadView) forControlEvents:UIControlEventTouchUpInside];
    [tableHeadView addSubview:closeBtn];
    
    //创建tableView
    [self tableViewCreated:tableHeadView];
    
}

//创建下方的tableView
- (void) tableViewCreated:(UIView *)tableHeadV{
    
    self.tableV = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, kMainScreenWidth, kMainScreenHeight - 110) style:UITableViewStyleGrouped];
    self.tableV.delegate = self;
    self.tableV.dataSource = self;
    self.tableV.tableHeaderView = tableHeadView;
    self.tableV.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableV addHeaderWithTarget:self action:@selector(headerRefreshing)];
    [self.tableV addFooterWithTarget:self action:@selector(footerRefreshing)];
    [self.view addSubview:self.tableV];
}

- (void)headerRefreshing{
    
    refreshType = @"near";
    currentPage = 1;
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 8.0) {
        //前台和后台都允许请求用户是否允许开启定位 IOS8.0以上版本需要设置环境参数
        [_clManager requestAlwaysAuthorization];
        [_clManager startUpdatingLocation];
    }
    else {
        //如果是IOS8.0以下的版本，则可直接开启定位
        [_clManager startUpdatingLocation];
    }
    
    self.tableV.headerPullToRefreshText = @"下拉可以刷新";
    self.tableV.headerReleaseToRefreshText = @"松开马上刷新";
    self.tableV.headerRefreshingText = @"刷新中";
    
}

- (void)footerRefreshing{
    
    if ([refreshType isEqualToString:@"find"]) {
        currentPage ++;
        
        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/GuideByCondition",REQUESTHEADER] andParameter:@{@"user_id":[LYUserService sharedInstance].userID,@"sex":self.guideSex,@"city":self.guideCity,@"province":self.guideProvince,@"country":self.guideCountry,@"age":self.guideAge,@"service_content":self.guideServiceContent,@"name":self.guideName,@"longitude":self.guideLongitude,@"latitude":self.guideLatitude,@"pageNum":[NSString stringWithFormat:@"%ld",(long)currentPage]} success:^(id successResponse) {
            MLOG(@"结果:%@",successResponse);
            if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                for (NSDictionary *dict in successResponse[@"data"][@"userList"]) {
                    self.homeModel = [[HomeModel alloc] initWithDict:dict];
                    [self.guideArray addObject:self.homeModel];
                }
                NSArray *array = successResponse[@"data"][@"userList"];
                if (!array.count) {
                    currentPage --;
                    [MBProgressHUD showError:@"已经到底咯~"];
                }else{
                    [self.tableV reloadData];
                }
            } else {
                currentPage --;
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
            }
        } andFailure:^(id failureResponse) {
            currentPage --;
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [MBProgressHUD showError:@"服务器繁忙,请重试"];
        }];
        [self.tableV footerEndRefreshing];
    }
    else if ([refreshType isEqualToString:@"near"]){
        currentPage ++;
        
        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/guide",REQUESTHEADER] andParameter:@{@"user_id":[LYUserService sharedInstance].userID,@"longitude":self.longitude,@"latitude":self.latitude,@"pageNum":[NSString stringWithFormat:@"%ld",(long)currentPage]} success:^(id successResponse) {
            MLOG(@"结果:%@",successResponse);
            if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
                for (NSDictionary *dict in successResponse[@"data"][@"list"]) {
                    self.homeModel = [[HomeModel alloc] initWithDict:dict];
                    [self.guideArray addObject:self.homeModel];
                }
//                self.tableV.guideArray = self.guideArray;
//                self.tableV.navi = self.navigationController;
                NSArray *array = successResponse[@"data"][@"list"];
                if (!array.count) {
                    currentPage --;
                    [MBProgressHUD showError:@"已经到底咯~"];
                }
                else{
                    [self.tableV reloadData];
                }
            } else {
                currentPage --;
                [MBProgressHUD hideHUD];
                [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
            }
        } andFailure:^(id failureResponse) {
            currentPage --;
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"服务器繁忙,请重试"];
        }];
        [self.tableV footerEndRefreshing];
    }
}

//关闭tableHeadView
- (void) closeTableHeadView{
    NSArray *subviews = [self.view subviews];
    for (UIView *subview in subviews) {
        if ([subview isKindOfClass:[UITableView class]]) {
            HomeTableView *tempTableView = (HomeTableView *)subview;
            [UIView animateWithDuration:0.2 animations:^{
                tempTableView.tableHeaderView = nil;
                self.tableV.tableHeaderView = nil;
            }];
        }
    }
}

//响应手指滑动广告的事件
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    int current = scrollView.contentOffset.x / kMainScreenWidth;
    if(current > 1){
        [_cycleView changeImages:++ _cycleView.currentPage];
    }
    else if(current < 1){
        [_cycleView changeImages:-- _cycleView.currentPage];
    }
}

//响应自动滚动的事件
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    [_cycleView changeImages:++ _cycleView.currentPage];
}

#pragma mark - 获取城市位置

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations{
    [_locManager stopUpdatingLocation];
    CLLocation *currentLocation = [locations lastObject];
    
    self.latitude = [NSString stringWithFormat:@"%f",currentLocation.coordinate.latitude];
    self.longitude = [NSString stringWithFormat:@"%f",currentLocation.coordinate.longitude];
    
    [self getDataFromWeb];
    
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

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [MBProgressHUD showError:@"定位失败,请重试"];
}

#pragma mark 代理方法返回反地理编码结果
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error{
    if (result) {
        self.locCity.text = [NSString stringWithFormat:@"%@", result.addressDetail.city];
        NSLog(@"%@ - %@", result.address, result.addressDetail.streetNumber);
    }else{
        self.locCity.text = @"定位失败";
    }
}

#pragma mark - 自设置navigationBar
- (void) setSelfNavigationBar{
    //创建navigation左边的Bar
    [self leftNavigationBarCreated];
    //---------------创建中间的搜索按钮-------------
    UIView *selfTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 25)];
    UIButton *titleBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [titleBtn addTarget:self action:@selector(turnToSearch) forControlEvents:UIControlEventTouchUpInside];
    [titleBtn setFrame:CGRectMake( 0, 0, kMainScreenWidth / 1.75, 25)];
    [titleBtn.layer setBorderWidth:1];
    [titleBtn.layer setCornerRadius:12];
    UIColor *borderColor = [UIColor colorWithRed:204 / 255.0 green:204 / 255.0 blue:204 /255.0 alpha:1];
    CGColorRef color = borderColor.CGColor;
    [titleBtn.layer setBorderColor:color];
    [selfTitleView addSubview:titleBtn];
    
    // selfTitleView.backgroundColor = [UIColor redColor];
    
    //添加左边的搜索图片
    UIImageView *searchImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 5, 30, titleBtn.frame.size.height - 10)];
    // searchImg.backgroundColor = [UIColor redColor];
    searchImg.contentMode = UIViewContentModeScaleAspectFit;
    searchImg.image = [UIImage imageNamed:@"search"];
    [titleBtn addSubview:searchImg];
    
    //添加搜索文字
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(searchImg.frame), 0, 120, titleBtn.frame.size.height)];
    titleLabel.textColor = borderColor;
    titleLabel.font = [UIFont boldSystemFontOfSize:14];
    titleLabel.text = @"该地方搜索城市";
    [titleBtn addSubview:titleLabel];
    self.navigationItem.titleView = selfTitleView;
    
    //---------------添加右边的item------------
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [rightBtn setFrame:CGRectMake(0, 0, 30, 17)];
    
    //添加扩展功能的图片
    UIImageView *andMoreImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,30, rightBtn.frame.size.height)];
    andMoreImg.image = [UIImage imageNamed:@"more"];
    andMoreImg.contentMode = UIViewContentModeScaleAspectFit;
    [rightBtn addSubview:andMoreImg];
    [rightBtn addTarget:self action:@selector(moreFunctionShow) forControlEvents: UIControlEventTouchUpInside];
    
    //添加一个button调节rightBtn的位置
    UIBarButtonItem *fixBar = [[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixBar.width = -3;
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    NSLog(@"width:%f",fixBar.width);
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:fixBar, right, nil];
}

- (void) turnToSearch{
    
    [[LYUserService sharedInstance] fetchLoginStateWithCompeletionBlock:^(UserLoginStateType type) {
        if (type == UserLoginStateTypeWaitToLogin) {
            [[LYUserService sharedInstance] jumpToLoginWithController:self];
        }
        else if (type == UserLoginStateTypeAlreadyLogin){
            SearchNearbyViewController *nextV = [[SearchNearbyViewController alloc]init];
            nextV.latitude = self.latitude;
            nextV.longitude = self.longitude;
            [self.navigationController pushViewController:nextV animated:YES];
        }
    }];
}

- (void) leftNavigationBarCreated{
    //创建navigationBra左边的城市定位
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [leftBtn setFrame:CGRectMake(-100, 0, 50, 17)];
    
    //添加地图定位的图片
    UIImageView *locImage = [[UIImageView alloc] initWithFrame:CGRectMake(-15, 0,30, leftBtn.frame.size.height)];
    locImage.image = [UIImage imageNamed:@"map-maker"];
    locImage.contentMode = UIViewContentModeScaleAspectFit;
    [leftBtn addSubview:locImage];
    
    //添加当前城市名
    _locCity = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(locImage.frame) - 5, 0,leftBtn.frame.size.width, locImage.frame.size.height)];
    _locCity.font = [UIFont systemFontOfSize:14];
    _locCity.textAlignment = NSTextAlignmentCenter;
    _locCity.text = @"定位中";
    // locCity.backgroundColor = [UIColor redColor];
    [leftBtn addSubview:_locCity];
    
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    [self.navigationItem setLeftBarButtonItem:left];
}

- (void) moreFunctionCreated{
    
    //创建点击附加功能按钮显示的button
    _modalBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_modalBtn setFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight)];
    [_modalBtn setBackgroundColor:RGBACOLOR(0, 0, 0, 0.2)];
//    _modalBtn.alpha = 0.2;
    [_modalBtn addTarget:self action:@selector(moreFunctionHidden) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_modalBtn];
    
    //更多功能视图一开始是隐藏状态
    moreFunctionIsShow = false;
    //设置更多功能视图到右边框的距离
    rigthDistance = 10;
    //设置背景图
    _backView = [[UIView alloc] initWithFrame:CGRectMake(kMainScreenWidth - rigthDistance, 60,1,1)];
    _backView.autoresizesSubviews = YES;
    float width = _backView.frame.size.width;
    float height = _backView.frame.size.height;
    [_backView.layer setCornerRadius:10];
    [_backView.layer setBorderWidth:1];
    [_backView.layer setBorderColor:UIColorWithRGBA(230, 230, 230, 1).CGColor];
    _backView.backgroundColor = [UIColor whiteColor];
    
    //创建第一个button
    UIButton *firstBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0,width, height / 3)];
    //使子视图随着父视图变化
    firstBtn.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    [firstBtn addTarget:self action:@selector(subscriptionAction) forControlEvents:UIControlEventTouchUpInside];
    UIImageView *firstImageV = [[UIImageView alloc] initWithFrame:CGRectMake(width / 12.0,height * 2 / 21.0, width / 7.0, height / 7.0)];
    firstImageV.image = [UIImage imageNamed:@"four"];
    //使子视图随着父视图变化
    firstImageV.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth |  UIViewAutoresizingFlexibleLeftMargin |UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [firstBtn addSubview:firstImageV];
    
    //创建右边的文字
    UILabel *firstLabel = [[UILabel alloc] initWithFrame:CGRectMake(width / 3.5, 0, width * 0.8, height / 3.0)];
    firstLabel.textAlignment = NSTextAlignmentLeft;
    firstLabel.text = @"订阅";
    firstLabel.font = [UIFont systemFontOfSize:15];
    firstLabel.textColor = UIColorWithRGBA(89, 89, 89, 1);
    //使子视图随着父视图变化
    firstLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth |  UIViewAutoresizingFlexibleLeftMargin |UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    [firstBtn addSubview:firstLabel];
    [_backView addSubview:firstBtn];
    
    //创建第二个button
    UIButton *secondBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, height / 3.0,width, height / 3)];
    //使子视图随着父视图变化
    secondBtn.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    [secondBtn addTarget:self action:@selector(strategyAction:) forControlEvents:UIControlEventTouchUpInside];
    //创建左边的图片
    UIImageView *secondImageV = [[UIImageView alloc] initWithFrame:CGRectMake(width / 12.0,height * 2 / 21.0, width / 7.0, height / 7.0)];
    secondImageV.image = [UIImage imageNamed:@"map"];
    //使子视图随着父视图变化
    secondImageV.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    [secondBtn addSubview:secondImageV];
    
    //创建右边的文字
    UILabel *secondLabel = [[UILabel alloc] initWithFrame:CGRectMake(width / 3.5, 0, width * 0.8, height / 3.0)];
    secondLabel.textAlignment = NSTextAlignmentLeft;
    secondLabel.text = @"旅游攻略";
    secondLabel.font = [UIFont systemFontOfSize:15];
    secondLabel.textColor = UIColorWithRGBA(89, 89, 89, 1);
    //使子视图随着父视图变化
    secondLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    [secondBtn addSubview:secondLabel];
    [_backView addSubview:secondBtn];
    
    //创建第三个button
    UIButton *thirdBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, height * 2 / 3.0,width, height / 3)];
    //使子视图随着父视图变化
    thirdBtn.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    [thirdBtn addTarget:self action:@selector(helpAction) forControlEvents:UIControlEventTouchUpInside];
    //创建左边的图片
    UIImageView *thirdImageV = [[UIImageView alloc] initWithFrame:CGRectMake(width / 12.0,height * 2 / 21.0, width / 7.0, height / 7.0)];
    thirdImageV.image = [UIImage imageNamed:@"hand"];
    //使子视图随着父视图变化
    thirdImageV.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    [thirdBtn addSubview:thirdImageV];
    
    //创建右边的文字
    UILabel *thirdLabel = [[UILabel alloc] initWithFrame:CGRectMake(width / 3.5, 0, width * 0.8, height / 3.0)];
    thirdLabel.textAlignment = NSTextAlignmentLeft;
    thirdLabel.text = @"帮助中心";
    thirdLabel.font = [UIFont systemFontOfSize:15];
    thirdLabel.textColor = UIColorWithRGBA(89, 89, 89, 1);
    //使子视图随着父视图变化
    thirdLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    [thirdBtn addSubview:thirdLabel];
    [_backView addSubview:thirdBtn];
    
    [_modalBtn addSubview:_backView];
}

- (void) moreFunctionShow{
    [UIView animateWithDuration:0.2 animations:^{
        if (moreFunctionIsShow == false) {
            [_backView setFrame:CGRectMake(kMainScreenWidth - 120 - rigthDistance, 60, 120, 120)];
            [self.view addSubview:_modalBtn];
            moreFunctionIsShow = YES;
        }
        else{
            [_backView setFrame:CGRectMake(kMainScreenWidth - rigthDistance, 60, 1, 1)];
            [_modalBtn removeFromSuperview];
            moreFunctionIsShow = NO;
        }
    }];
    
}

- (void) moreFunctionHidden{
    [UIView animateWithDuration:0.2 animations:^{
        [_modalBtn removeFromSuperview];
        moreFunctionIsShow = NO;
    }];
}

- (void) dealloc{
    self.cycleView.scrollView.delegate = nil;
    [_locManager stopUpdatingLocation];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)subscriptionAction{
    SubscriptionViewController *sub = [[SubscriptionViewController alloc] init];
    [self.navigationController pushViewController:sub animated:YES];
    [self moreFunctionHidden];
}

- (void)strategyAction:(UIButton *)btn{
    StrategyViewController *str = [[StrategyViewController alloc] init];
    [self.navigationController pushViewController:str animated:YES];
    [self moreFunctionHidden];
}

- (void)helpAction{
    HelpCenterViewController *help = [[HelpCenterViewController alloc] init];
    [self.navigationController pushViewController:help animated:YES];
    [self moreFunctionHidden];
}

#pragma mark - 通知中心
- (void)autoLogin:(NSNotification *)aNotification {
    
    [[LYUserService sharedInstance] autoLoginWithController:self mobile:[[LYUserService sharedInstance] mobile] password:[[LYUserService sharedInstance] password] deviceType:@"1" deviceToken:kAppDelegate.deviceToken umengID:[LYUserService sharedInstance].userDetail.umengID];
}

- (void)reloadCity:(NSNotification *)aNotification {
    
    NSDictionary *userDict = [aNotification userInfo];
    NSString *city = userDict[@"city"];
    _locCity.text = city;
}

#pragma mark 网络请求

- (void)getDataFromWeb{

    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/guide",REQUESTHEADER] andParameter:@{@"user_id":[LYUserService sharedInstance].userID,@"longitude":self.longitude,@"latitude":self.latitude} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            [self.guideArray removeAllObjects];
            for (NSDictionary *dict in successResponse[@"data"][@"list"]) {
                self.homeModel = [[HomeModel alloc] initWithDict:dict];
                [self.guideArray addObject:self.homeModel];
            }
            [self.tableV reloadData];
        } else {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
    [self.tableV headerEndRefreshing];
}

#pragma mark 判断是否为空

- (BOOL) isBlankString:(NSString *)string {
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}

#pragma mark tableview

//设置cell的高度
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.guideArray.count) {
        self.homeModel = self.guideArray[indexPath.section];
        if (self.homeModel.photos.count) {
            NSDictionary *photoDict = self.homeModel.photos[0];
            NSString *photoStr = photoDict[@"photos"];
            
            NSArray *csarray = [photoStr componentsSeparatedByString:@";"];
            NSMutableArray *array = [[NSMutableArray alloc] initWithArray:csarray];
            
            if ([self isBlankString:array.lastObject]) {
                [array removeLastObject];
            }
            
            if (array.count) {
                return 184;
            }
            else{
                return 100;
            }
        }
        else{
            return 100;
        }
    }
    else{
        return 100;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.guideArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NewHomeTableViewCell *cell = [NewHomeTableViewCell cellWithTableView:tableView andIndexPath:indexPath];
    self.homeModel = self.guideArray[indexPath.section];
    [cell fillData:self.homeModel];
    cell.navi = self.navigationController;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    HomeModel *model = self.guideArray[indexPath.section];
    DetailDataViewController *deta = [[DetailDataViewController alloc] init];
    deta.friendId = [model.id integerValue];
    [self.navigationController pushViewController:deta animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 6;
}

#pragma mark 轮播图代理委托

- (NSArray *)numberOfKDCycleBannerView:(KDCycleBannerView *)bannerView{
    if (self.scrollImageArray.count) {
        return self.scrollImageArray;
    }
    else{
        return nil;
    }
}

- (UIViewContentMode)contentModeForImageIndex:(NSUInteger)index{
    return UIViewContentModeScaleToFill;
}

@end
