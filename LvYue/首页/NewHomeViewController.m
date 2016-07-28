//
//  NewHomeViewController.m
//  LvYue
//
//  Created by 広有射怪鸟事 on 16/1/5.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "NewHomeViewController.h"
#import "NSString+DeleteLastWord.h"
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

@interface NewHomeViewController ()<CLLocationManagerDelegate,BMKGeoCodeSearchDelegate,UITableViewDataSource,UITableViewDelegate,KDCycleBannerViewDelegate,KDCycleBannerViewDataSource>
{
    UITableView *tableV;//主tableview
    UIView *headView;//headerView
    UILabel *locLabel;//显示当前城市名的label
    UIView *backView;//菜单背景蒙版
    UIButton *modalBtn;//蒙版上的按钮
    
    NSString *longitude;//经纬度
    NSString *latitude;
    NSString *currentCity;//当前城市名
    NSString *refreshType;//find为按条件搜索,near为附近的人
    NSMutableArray *guideArray;//主页用户数组
    NSMutableArray *scrollImageArray;//轮播图图片数组
    NSInteger currentPage;//当前页数
    BOOL isCloseHeaderView;//是否关闭headerView
    BOOL moreFunctionIsShow;//是否显示菜单
    
    HomeModel *homeModel;//用户模型
    KDCycleBannerView *cycleBannerViewBottom;//轮播图
}

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

@implementation NewHomeViewController

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
    
    refreshType = @"near";
    currentPage = 1;
}


- (BOOL)prefersStatusBarHidden {
    return NO;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    guideArray = [[NSMutableArray alloc] init];
    
    isCloseHeaderView = NO;
    moreFunctionIsShow = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(autoLogin:) name:@"autoLogin" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(findGuide:) name:@"findGuide" object:nil];
    
    [self createTableView];
    [self createNavigationView];
    [self createScrollView];//创建轮播图
    [self moreFunctionCreated];//创建菜单
    
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
    
}

#pragma mark - 通知中心

- (void)autoLogin:(NSNotification *)aNotification {
    if (!kAppDelegate.deviceToken) {
        kAppDelegate.deviceToken = @"bb63b19106f3108798b7a271447e40df8a75c0b7cec8d99f54b43728713edc37";
    }
    [[LYUserService sharedInstance] autoLoginWithController:self mobile:[[LYUserService sharedInstance] mobile] password:[[LYUserService sharedInstance] password] deviceType:@"1" deviceToken:kAppDelegate.deviceToken umengID:[LYUserService sharedInstance].userDetail.umengID longitude:longitude latitude:latitude];
}

- (void)findGuide:(NSNotification *)aNotification{
    
    tableV.mj_header = [MJRefreshStateHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefreshing)];
    tableV.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRefreshing)];
    MJRefreshStateHeader *header = (MJRefreshStateHeader *)tableV.mj_header;
    [header setTitle:@"下拉回到附近的人" forState:MJRefreshStateIdle];
    [header setTitle:@"松开马上刷新" forState:MJRefreshStatePulling];
    [header setTitle:@"刷新中" forState:MJRefreshStateRefreshing];
    
    NSString *cityName = [NSString stringWithFormat:@"%@",aNotification.userInfo[@"cityName"]];
    NSString *proName = [NSString stringWithFormat:@"%@",aNotification.userInfo[@"provinceName"]];
    NSString *countryName = [NSString stringWithFormat:@"%@",aNotification.userInfo[@"countryName"]];
    guideArray = aNotification.userInfo[@"guide"];
    refreshType = aNotification.userInfo[@"type"];
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
        locLabel.text = cityName;
    }
    else if (![self isBlankString:proName]){
        locLabel.text = proName;
    }
    else if (![self isBlankString:countryName]){
        locLabel.text = countryName;
    }
    else if (![self isBlankString:self.guideName]){
        locLabel.text = @"关键字";
    }
    else{
        locLabel.text = @"全部";
    }
    [tableV reloadData];
    [tableV.mj_footer endRefreshing];
}

#pragma mark 创建界面

- (void)createTableView{
    tableV = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight) style:UITableViewStyleGrouped];
    tableV.delegate = self;
    tableV.dataSource = self;
    tableV.separatorStyle = UITableViewCellSeparatorStyleNone;
        
    tableV.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefreshing)];
    tableV.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRefreshing)];
    
    [self.view addSubview:tableV];
}

- (void)createNavigationView{
    
    //创建左边的view
    
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(-100, 0, 50, 17)];
    
    //添加地图定位的图片
    UIImageView *locImage = [[UIImageView alloc] initWithFrame:CGRectMake(-15, 0,30, leftView.frame.size.height)];
    locImage.image = [UIImage imageNamed:@"map-maker"];
    locImage.contentMode = UIViewContentModeScaleAspectFit;
    [leftView addSubview:locImage];
    
    //添加当前城市名
    locLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(locImage.frame) - 5, 0,leftView.frame.size.width, locImage.frame.size.height)];
    locLabel.font = [UIFont systemFontOfSize:14];
    locLabel.textAlignment = NSTextAlignmentCenter;
    locLabel.text = @"定位中";
    [leftView addSubview:locLabel];
    
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithCustomView:leftView];
    [self.navigationItem setLeftBarButtonItem:left];
    
    
    //创建中间的view
    
    UIView *centerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 25)];
    
    UIButton *centerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [centerBtn setFrame:CGRectMake(0, 0, 200, 25)];
    centerBtn.layer.cornerRadius = 12;
    centerBtn.layer.borderWidth = 0.5;
    centerBtn.layer.borderColor = RGBACOLOR(204, 204, 204, 1).CGColor;
    [centerBtn addTarget:self action:@selector(turnToSearch) forControlEvents:UIControlEventTouchUpInside];
    [centerView addSubview:centerBtn];
    
    //添加左边的搜索图片
    UIImageView *searchImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 5, 30, centerBtn.frame.size.height - 10)];
    // searchImg.backgroundColor = [UIColor redColor];
    searchImg.contentMode = UIViewContentModeScaleAspectFit;
    searchImg.image = [UIImage imageNamed:@"search"];
    [centerBtn addSubview:searchImg];
    
    //添加搜索文字
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(searchImg.frame), 0, 120, centerBtn.frame.size.height)];
    titleLabel.textColor = RGBACOLOR(204, 204, 204, 1);
    titleLabel.font = [UIFont boldSystemFontOfSize:14];
    titleLabel.text = @"该地方搜索城市";
    [centerBtn addSubview:titleLabel];
    
    [self.navigationItem setTitleView:centerView];

    
    //---------------添加右边的item------------
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [rightBtn setFrame:CGRectMake(0, 0, 30, 17)];
    
    //添加扩展功能的图片
    UIImageView *andMoreImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,30, rightBtn.frame.size.height)];
    andMoreImg.image = [UIImage imageNamed:@"more"];
    andMoreImg.contentMode = UIViewContentModeScaleAspectFit;
    [rightBtn addSubview:andMoreImg];
    [rightBtn addTarget:self action:@selector(moreFunctionShow) forControlEvents: UIControlEventTouchUpInside];
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    [self.navigationItem setRightBarButtonItem:right];
    
}

- (void)createScrollView{
    
    headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenWidth / 2)];
    
    cycleBannerViewBottom = [KDCycleBannerView new];
    cycleBannerViewBottom.frame = CGRectMake(0, 0, kMainScreenWidth, kMainScreenWidth / 2); //位置及宽高
    cycleBannerViewBottom.datasource = self;
    cycleBannerViewBottom.delegate = self;
    cycleBannerViewBottom.continuous = YES; //是否连续显示
    cycleBannerViewBottom.autoPlayTimeInterval = 4; //时间间隔
    [headView addSubview:cycleBannerViewBottom];
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setFrame:CGRectMake(10, 10, 20, 20)];
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeTableHeadView) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:closeBtn];
    
    scrollImageArray = [[NSMutableArray alloc] init];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/assets/homeImg",REQUESTHEADER] andParameter:@{} success:^(id successResponse) {
        MLOG(@"轮播图结果:%@",successResponse);
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            
            NSArray *array = successResponse[@"data"][@"imgs"];
            for (NSDictionary *dict in array) {
                NSString *imgStr = dict[@"img"];
                NSString *imgName = [NSString stringWithFormat:@"%@%@",IMAGEHEADER,imgStr];
                [scrollImageArray addObject:imgName];
            }
            [cycleBannerViewBottom reloadDataWithCompleteBlock:nil];
        } else {
            
        }
    } andFailure:^(id failureResponse) {
        
    }];
}

- (void) turnToSearch{
    
    SearchNearbyViewController *nextV = [[SearchNearbyViewController alloc]init];
    nextV.latitude = latitude;
    nextV.longitude = longitude;
    [self.navigationController pushViewController:nextV animated:YES];

}

- (void) moreFunctionCreated{
    
    //创建点击附加功能按钮显示的button
    modalBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [modalBtn setFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight)];
    [modalBtn setBackgroundColor:RGBACOLOR(0, 0, 0, 0.2)];
    [modalBtn addTarget:self action:@selector(moreFunctionHidden) forControlEvents:UIControlEventTouchUpInside];
    
    //更多功能视图一开始是隐藏状态
    moreFunctionIsShow = false;
    //设置背景图
    backView = [[UIView alloc] initWithFrame:CGRectMake(kMainScreenWidth - 10, 60,1,1)];
    backView.autoresizesSubviews = YES;
    float width = backView.frame.size.width;
    float height = backView.frame.size.height;
    [backView.layer setCornerRadius:10];
    [backView.layer setBorderWidth:1];
    [backView.layer setBorderColor:UIColorWithRGBA(230, 230, 230, 1).CGColor];
    backView.backgroundColor = [UIColor whiteColor];
    
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
    [backView addSubview:firstBtn];
    
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
    [backView addSubview:secondBtn];
    
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
    [backView addSubview:thirdBtn];
    
    [modalBtn addSubview:backView];
}

- (void) moreFunctionShow{
    [UIView animateWithDuration:0.2 animations:^{
        if (moreFunctionIsShow == false) {
            [backView setFrame:CGRectMake(kMainScreenWidth - 120 - 10, 60, 120, 120)];
            [self.view addSubview:modalBtn];
            moreFunctionIsShow = YES;
        }
        else{
            [backView setFrame:CGRectMake(kMainScreenWidth - 10, 60, 1, 1)];
            [modalBtn removeFromSuperview];
            moreFunctionIsShow = NO;
        }
    }];
    
}

- (void) moreFunctionHidden{
    [UIView animateWithDuration:0.2 animations:^{
        [modalBtn removeFromSuperview];
        moreFunctionIsShow = NO;
    }];
}

- (void) dealloc{
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

//关闭tableHeadView
- (void) closeTableHeadView{
    isCloseHeaderView = YES;
    [tableV reloadData];
}

#pragma mark 上拉下拉刷新

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
    
    MJRefreshStateHeader *header = (MJRefreshStateHeader *)tableV.mj_header;
    [header setTitle:@"下拉可以刷新" forState:MJRefreshStateIdle];
    [header setTitle:@"松开马上刷新" forState:MJRefreshStatePulling];
    [header setTitle:@"刷新中" forState:MJRefreshStateRefreshing];
    
}

- (void)footerRefreshing{
    
    if ([refreshType isEqualToString:@"find"]) {
        currentPage ++;
        
        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/GuideByCondition",REQUESTHEADER] andParameter:@{@"user_id":[LYUserService sharedInstance].userID,@"sex":self.guideSex,@"city":self.guideCity,@"province":self.guideProvince,@"country":self.guideCountry,@"age":self.guideAge,@"service_content":self.guideServiceContent,@"name":self.guideName,@"longitude":self.guideLongitude,@"latitude":self.guideLatitude,@"pageNum":[NSString stringWithFormat:@"%ld",(long)currentPage]} success:^(id successResponse) {
            MLOG(@"结果:%@",successResponse);
            if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                for (NSDictionary *dict in successResponse[@"data"][@"userList"]) {
                    homeModel = [[HomeModel alloc] initWithDict:dict];
                    [guideArray addObject:homeModel];
                }
                NSArray *array = successResponse[@"data"][@"userList"];
                if (!array.count) {
                    currentPage --;
                    [MBProgressHUD showError:@"已经到底咯~"];
                }else{
                    [tableV reloadData];
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
        [tableV.mj_footer endRefreshing];
    }
    else if ([refreshType isEqualToString:@"near"]){
        
        [[LYUserService sharedInstance] fetchLoginStateWithCompeletionBlock:^(UserLoginStateType type) {
            if (type == UserLoginStateTypeWaitToLogin) {
                currentPage ++;
                
                [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/guide",REQUESTHEADER] andParameter:@{@"isToristEnter":@"1",@"longitude":longitude,@"latitude":latitude,@"pageNum":[NSString stringWithFormat:@"%ld",(long)currentPage]} success:^(id successResponse) {
                    MLOG(@"结果:%@",successResponse);
                    if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
                        for (NSDictionary *dict in successResponse[@"data"][@"list"]) {
                            homeModel = [[HomeModel alloc] initWithDict:dict];
                            [guideArray addObject:homeModel];
                        }
                        
                        NSArray *array = successResponse[@"data"][@"list"];
                        if (!array.count) {
                            currentPage --;
                            [MBProgressHUD showError:@"已经到底咯~"];
                        }
                        else{
                            [tableV reloadData];
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
                [tableV.mj_footer endRefreshing];
            }
            else if (type == UserLoginStateTypeAlreadyLogin)
            {
                currentPage ++;
                
                [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/guide",REQUESTHEADER] andParameter:@{@"user_id":[LYUserService sharedInstance].userID,@"longitude":longitude,@"latitude":latitude,@"pageNum":[NSString stringWithFormat:@"%ld",(long)currentPage]} success:^(id successResponse) {
                    MLOG(@"结果:%@",successResponse);
                    if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
                        for (NSDictionary *dict in successResponse[@"data"][@"list"]) {
                            homeModel = [[HomeModel alloc] initWithDict:dict];
                            [guideArray addObject:homeModel];
                        }
                        
                        NSArray *array = successResponse[@"data"][@"list"];
                        if (!array.count) {
                            currentPage --;
                            [MBProgressHUD showError:@"已经到底咯~"];
                        }
                        else{
                            [tableV reloadData];
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
                [tableV.mj_footer endRefreshing];
            }
        }];
    }
}

#pragma mark 网络请求

- (void)getDataFromWeb{
    
    [[LYUserService sharedInstance] fetchLoginStateWithCompeletionBlock:^(UserLoginStateType type) {
        if (type == 1) {
            [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/guide",REQUESTHEADER] andParameter:@{@"user_id":[LYUserService sharedInstance].userID,@"longitude":longitude,@"latitude":latitude} success:^(id successResponse) {
                MLOG(@"结果:%@",successResponse);
                if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
                    [guideArray removeAllObjects];
                    for (NSDictionary *dict in successResponse[@"data"][@"list"]) {
                        homeModel = [[HomeModel alloc] initWithDict:dict];
                        [guideArray addObject:homeModel];
                    }
                    [tableV reloadData];
                } else {
                    [MBProgressHUD hideHUD];
                    [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
                }
            } andFailure:^(id failureResponse) {
                [MBProgressHUD hideHUD];
                [MBProgressHUD showError:@"服务器繁忙,请重试"];
            }];
            
            [tableV.mj_header endRefreshing];
        }
        else if (type == 0){
            [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/guide",REQUESTHEADER] andParameter:@{@"longitude":longitude,@"latitude":latitude,@"isToristEnter":@"1"} success:^(id successResponse) {
                MLOG(@"结果:%@",successResponse);
                if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
                    [guideArray removeAllObjects];
                    for (NSDictionary *dict in successResponse[@"data"][@"list"]) {
                        homeModel = [[HomeModel alloc] initWithDict:dict];
                        [guideArray addObject:homeModel];
                    }
                    [tableV reloadData];
                } else {
                    [MBProgressHUD hideHUD];
                    [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
                }
            } andFailure:^(id failureResponse) {
                [MBProgressHUD hideHUD];
                [MBProgressHUD showError:@"服务器繁忙,请重试"];
            }];
            
            [tableV.mj_header endRefreshing];
        }
    }];
}

#pragma mark - 获取城市位置

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations{
    [_clManager stopUpdatingLocation];
    CLLocation *currentLocation = [locations lastObject];
    
    latitude = [NSString stringWithFormat:@"%f",currentLocation.coordinate.latitude];
    longitude = [NSString stringWithFormat:@"%f",currentLocation.coordinate.longitude];
    
    [self getDataFromWeb];
    
    //停止定位
    [_clManager stopUpdatingLocation];
    
    //初始化检索对象
    self.searcher =[[BMKGeoCodeSearch alloc] init];
    self.searcher.delegate = self;
    
    //发起反向地理编码检索
    CLLocationCoordinate2D pt = (CLLocationCoordinate2D){[latitude floatValue], [longitude floatValue]};
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
//        [MBProgressHUD showError:@"用户拒绝授权,请在设置中开启"];
    }
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
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
    locLabel.text = currentCity;
}

#pragma mark tableview代理

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return guideArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

//设置cell的高度
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (guideArray.count) {
        homeModel = guideArray[indexPath.section];
        if (homeModel.photos.count) {
            NSDictionary *photoDict = homeModel.photos[0];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NewHomeTableViewCell *cell = [NewHomeTableViewCell cellWithTableView:tableView andIndexPath:indexPath];
    homeModel = guideArray[indexPath.section];
    [cell fillData:homeModel];
    cell.navi = self.navigationController;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    HomeModel *model = guideArray[indexPath.section];
    DetailDataViewController *deta = [[DetailDataViewController alloc] init];
    deta.friendId = [model.id integerValue];
    [self.navigationController pushViewController:deta animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        if (isCloseHeaderView) {
            return 1;
        }
        return kMainScreenWidth / 2;
    }
    else{
        return 6;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        if (isCloseHeaderView) {
            return nil;
        }
        return headView;
    }
    else{
        return nil;
    }
}

#pragma mark 轮播图代理委托

- (NSArray *)numberOfKDCycleBannerView:(KDCycleBannerView *)bannerView{
    if (scrollImageArray.count) {
        return scrollImageArray;
    }
    else{
        return nil;
    }
}

- (UIViewContentMode)contentModeForImageIndex:(NSUInteger)index{
    return UIViewContentModeScaleToFill;
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

@end
