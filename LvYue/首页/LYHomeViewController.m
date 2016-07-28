//
//  LYHomeViewController.m
//  LvYue
//
//  Created by 郑洲 on 16/3/14.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "CollectWebViewController.h"
#import "DetailDataViewController.h"
#import "HomeCollectionViewCell.h"
#import "HomeModel.h"
#import "HotMessageCollectionViewCell.h"
#import "HotModel.h"
#import "JumpAnimationView.h"
#import "KDCycleBannerView.h"
#import "LYDetailDataViewController.h"
#import "LYHomeViewController.h"
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "LYWaterFlowLayout.h"
#import "MBProgressHUD+NJ.h"
#import "MJRefresh.h"
#import "MyDispositionViewController.h"
#import "PublishRequirementViewController.h"
#import "RequirementDetailViewController.h"
#import "ScrollView.h"
#import "SearchNearbyViewController.h"
#import "SkillDetailViewController.h"
#import "UIImageView+WebCache.h"
#import "UIView+KFFrame.h"
#import "VideoListViewController.h"
#import <CoreLocation/CoreLocation.h>

#define kNavigationHiddenAnimationDuration 0.25f

@interface LYHomeViewController () <CLLocationManagerDelegate, BMKGeoCodeSearchDelegate, KDCycleBannerViewDelegate, KDCycleBannerViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate, HomeCollectionViewCellDelegate> {
    UICollectionView *_collectionView;
    UICollectionView *_hotCollectionView;
    UIView *lineView;
    UIView *headView;
    UIView *headView2;
    UILabel *locLabel; //显示当前城市名的label

    ScrollView *_scrollView;
    NSMutableArray *rssArray;
    NSMutableArray *needIdArr;
    BOOL isNew;
    BOOL isFirst;

    NSString *longitude; //经纬度
    NSString *latitude;
    NSString *currentCity; //当前城市名
    //    NSString *refreshType;//find为按条件搜索,near为附近的人
    NSMutableArray *scrollImageArray;          //轮播图图片数组
    NSMutableArray *scrollImageActionURLArray; //轮播图点击响应的URL
    NSInteger currentPage;                     //当前页数
    NSInteger currentPage2;

    HomeModel *homeModel; //用户模型
    HotModel *hotModel;
    KDCycleBannerView *cycleBannerViewBottom;  //轮播图
    KDCycleBannerView *cycleBannerViewBottom2; //轮播图

    UIButton *topBtn;
    CGFloat _startY; //记录本次拖拽开始滑动的焦点的Y值
    CGFloat _endY;   //记录本次拖拽结束滑动的焦点的Y值
    UIView *_shadowView;
    NSTimer *_timer;
    BOOL isAutoLogin;
}
//上拉刷新用的搜索条件属性
@property (nonatomic, strong) NSString *guideSex;            //性别
@property (nonatomic, strong) NSString *guideCity;           //城市
@property (nonatomic, strong) NSString *guideProvince;       //省
@property (nonatomic, strong) NSString *guideCountry;        //国家
@property (nonatomic, strong) NSString *guideAge;            //年龄
@property (nonatomic, strong) NSString *guideServiceContent; //服务项目
@property (nonatomic, strong) NSString *guideName;           //关键词
@property (nonatomic, strong) NSString *guideLongitude;      //经纬度
@property (nonatomic, strong) NSString *guideLatitude;

@property (nonatomic, strong) BMKGeoCodeSearch *searcher;

@property (nonatomic, strong) JumpAnimationView *animationView; //动画容器View
@property (nonatomic, strong) UIButton *publishBtn;             //发布按钮

//地理编码对象
@property (nonatomic, strong) CLGeocoder *geocoder;

//定位信息管理者
@property (nonatomic, strong) CLLocationManager *clManager;

@property (strong, nonatomic) NSMutableArray *heightArr;
@property (strong, nonatomic) NSMutableArray *heightHotArr;

@property (strong, nonatomic) NSMutableArray *guideArray; //主页用户数组
@property (strong, nonatomic) NSMutableArray *hotArray;

@property (strong, nonatomic) LYWaterFlowLayout *waterFlowLayout;
@end

@implementation LYHomeViewController

static int countInt = 0;
static NSString *notice_index;

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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    //    refreshType = @"near";
    currentPage  = 1;
    currentPage2 = 1;
    if (!topBtn) {
        topBtn                 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH / 4, 49)];
        topBtn.backgroundColor = [UIColor clearColor];
        [topBtn addTarget:self action:@selector(bringToTop) forControlEvents:UIControlEventTouchUpInside];
        [self.tabBarController.tabBar addSubview:topBtn];
    }
    topBtn.hidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    topBtn.hidden = YES;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];


    _guideArray   = [[NSMutableArray alloc] init];
    _hotArray     = [[NSMutableArray alloc] init];
    _heightArr    = [[NSMutableArray alloc] init];
    _heightHotArr = [[NSMutableArray alloc] init];

    isNew       = YES;
    isFirst     = YES;
    isAutoLogin = NO;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(autoLogin:) name:@"autoLogin" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushDetail:) name:@"pushDetail" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showNote) name:@"showNote" object:nil];

    [self createCollectionView];
    [self createNavigationView];
    [self createScrollView]; //创建轮播图
    [self createScrollView2];

    self.clManager.delegate        = self;
    self.clManager.desiredAccuracy = kCLLocationAccuracyBest;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9) {
        _clManager.allowsBackgroundLocationUpdates = NO;
        [_clManager requestWhenInUseAuthorization];
        [_clManager startUpdatingLocation];
    } else if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 8.0) {
        //前台和后台都允许请求用户是否允许开启定位 IOS8.0以上版本需要设置环境参数
        [_clManager requestWhenInUseAuthorization];
        [_clManager startUpdatingLocation];
    } else {
        //如果是IOS8.0以下的版本，则可直接开启定位
        [_clManager startUpdatingLocation];
    }

    [self.view addSubview:self.animationView];
}

#pragma mark - 通知中心

- (void)autoLogin:(NSNotification *)aNotification {

    isAutoLogin = YES;
    if (!kAppDelegate.deviceToken) {
        kAppDelegate.deviceToken = @"bb63b19106f3108798b7a271447e40df8a75c0b7cec8d99f54b43728713edc37";
    }
    if (longitude) {
        [[LYUserService sharedInstance] autoLoginWithController:self mobile:[[LYUserService sharedInstance] mobile] password:[[LYUserService sharedInstance] password] deviceType:@"1" deviceToken:kAppDelegate.deviceToken umengID:[LYUserService sharedInstance].userDetail.umengID longitude:longitude latitude:latitude];
        isAutoLogin = NO;
    }
}

- (void)pushDetail:(NSNotification *)aNotification {
    LYDetailDataViewController *detail = [[LYDetailDataViewController alloc] init];
    //    detail.friendId                    = [aNotification.userInfo[@"userId"] integerValue];
    [self.navigationController pushViewController:detail animated:YES];
}

- (void)showNote {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"请注意防范酒托、饭托等。虽然是开放的时代，但大家一起旅行、唱歌、健身等线下活动时不要强迫对方做不愿意做的事情。尊重第一！" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [alertView show];
    });
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark 创建界面

- (JumpAnimationView *)animationView {
    if (!_animationView) {
        _animationView = [[JumpAnimationView alloc] init];
        [_animationView setCenter:CGPointMake(kMainScreenWidth / 2, kMainScreenHeight - 50 - 44)];
        [_animationView setBounds:CGRectMake(0, 0, 70, 70)];
        _animationView.layer.masksToBounds = YES;
        _animationView.backgroundColor     = [UIColor clearColor];
#warning 隐藏发布按钮
        //[_animationView addSubview:self.publishBtn];
    }
    return _animationView;
}


- (UIButton *)publishBtn {
    if (!_publishBtn) {
        _publishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_publishBtn setBackgroundImage:[UIImage imageNamed:@"拍"] forState:UIControlStateNormal];
        _publishBtn.frame                         = CGRectMake(0, 0, _animationView.bounds.size.width, _animationView.bounds.size.height);
        _publishBtn.imageView.contentMode         = UIViewContentModeScaleAspectFit;
        _publishBtn.imageView.layer.masksToBounds = YES;
        _publishBtn.alpha                         = 0.90;
        [_publishBtn addTarget:self action:@selector(showChooseView) forControlEvents:UIControlEventTouchUpInside];
    }
    return _publishBtn;
}

- (void)showChooseView {
    _shadowView                 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT + 64 + 49)];
    _shadowView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    [[UIApplication sharedApplication].keyWindow addSubview:_shadowView];
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidden)];
    [_shadowView addGestureRecognizer:tapGR];

    UIButton *pubRequirementBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 110, SCREEN_HEIGHT, 80, 80)];
    [pubRequirementBtn setImage:[UIImage imageNamed:@"需求"] forState:UIControlStateNormal];
    [pubRequirementBtn setImageEdgeInsets:UIEdgeInsetsMake(-30, 4, 0, 0)];
    [pubRequirementBtn setTitle:@"发布需求" forState:UIControlStateNormal];
    [pubRequirementBtn setTitleEdgeInsets:UIEdgeInsetsMake(60, -65, 0, 0)];
    pubRequirementBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [pubRequirementBtn addTarget:self action:@selector(publishRequirement) forControlEvents:UIControlEventTouchUpInside];
    [_shadowView addSubview:pubRequirementBtn];

    UIButton *pubSkillBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 + 45, SCREEN_HEIGHT, 80, 80)];
    [pubSkillBtn setImage:[UIImage imageNamed:@"技能"] forState:UIControlStateNormal];
    [pubSkillBtn setImageEdgeInsets:UIEdgeInsetsMake(-30, 4, 0, 0)];
    [pubSkillBtn setTitle:@"发布技能" forState:UIControlStateNormal];
    [pubSkillBtn setTitleEdgeInsets:UIEdgeInsetsMake(60, -70, 0, 0)];
    pubSkillBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [pubSkillBtn addTarget:self action:@selector(publishSkill) forControlEvents:UIControlEventTouchUpInside];
    [_shadowView addSubview:pubSkillBtn];

    [UIView animateWithDuration:kNavigationHiddenAnimationDuration * 3 delay:0.0 usingSpringWithDamping:0.4 initialSpringVelocity:30 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        //BOTTOM
        self.publishBtn.alpha    = 0.35;
        self.animationView.frame = CGRectMake(kMainScreenWidth / 2 - 18, kMainScreenHeight - 20 - 47, 36, 36);
        self.publishBtn.frame    = CGRectMake(0, 0, 36, 36);
        pubRequirementBtn.frame  = CGRectMake(SCREEN_WIDTH / 2 - 110, SCREEN_HEIGHT - 180, 80, 80);
        pubSkillBtn.frame        = CGRectMake(SCREEN_WIDTH / 2 + 45, SCREEN_HEIGHT - 180, 80, 80);
    }
                     completion:nil];
}

- (void)publishRequirement {
    [_shadowView removeFromSuperview];

    PublishRequirementViewController *vc = [[PublishRequirementViewController alloc] init];
    vc.isPushSkill                       = NO;
    vc.isFromDetail                      = NO;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)publishSkill {
    [_shadowView removeFromSuperview];

    PublishRequirementViewController *vc = [[PublishRequirementViewController alloc] init];
    vc.isPushSkill                       = YES;
    vc.isFromDetail                      = NO;
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)hidden {
    [_shadowView removeFromSuperview];

    [UIView animateWithDuration:kNavigationHiddenAnimationDuration * 3 delay:0.0 usingSpringWithDamping:0.35 initialSpringVelocity:50 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        //BOTTOM
        self.publishBtn.alpha    = 0.90;
        self.animationView.frame = CGRectMake(kMainScreenWidth / 2 - 36, kMainScreenHeight - 88 - 44, 70, 70);
        self.publishBtn.frame    = CGRectMake(0, 0, 70, 70);
    }
                     completion:nil];
}

- (void)createCollectionView {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.sectionInset                = UIEdgeInsetsMake(10, 0, 10, 0);
    flowLayout.minimumInteritemSpacing     = 10;
    flowLayout.minimumLineSpacing          = 10;
    flowLayout.headerReferenceSize         = CGSizeMake(SCREEN_WIDTH, SCREEN_WIDTH / 2 + 35);

    _waterFlowLayout = [[LYWaterFlowLayout alloc] init];

    //计算每个item高度方法
    [_waterFlowLayout computeIndexCellHeightWithWidthBlock:^CGFloat(NSIndexPath *indexPath, CGFloat width) {
        if (indexPath.row > 1 && indexPath.row < _heightArr.count + 2) {
            //            NSLog(@"%d",indexPath.row);
            return [_heightArr[indexPath.row - 2] floatValue];
        }
        return SCREEN_WIDTH / 2 + 35;
    }];

    _collectionView                      = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH + 5, SCREEN_HEIGHT) collectionViewLayout:_waterFlowLayout];
    _collectionView.delegate             = self;
    _collectionView.dataSource           = self;
    _collectionView.backgroundColor      = [UIColor whiteColor];
    _collectionView.alwaysBounceVertical = YES;

    _hotCollectionView                      = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH + 5, SCREEN_HEIGHT - 64 - 49) collectionViewLayout:flowLayout];
    _hotCollectionView.delegate             = self;
    _hotCollectionView.dataSource           = self;
    _hotCollectionView.backgroundColor      = [UIColor whiteColor];
    _hotCollectionView.hidden               = YES;
    _hotCollectionView.alwaysBounceVertical = YES;

    [_collectionView registerClass:[HomeCollectionViewCell class] forCellWithReuseIdentifier:@"newCell"];
    [_hotCollectionView registerClass:[HotMessageCollectionViewCell class] forCellWithReuseIdentifier:@"hotCell"];
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    [_hotCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headCell"];

    [self addRefresh];

    [self.view addSubview:_collectionView];
    //    [self.view addSubview:_hotCollectionView];
}

- (void)createNavigationView {

    //创建左边的view
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(-100, 0, 50, 17)];

    //添加地图定位的图片
    UIImageView *locImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10.5, leftView.frame.size.height)];
    locImage.image        = [UIImage imageNamed:@"定位"];
    locImage.contentMode  = UIViewContentModeScaleAspectFit;
    [leftView addSubview:locImage];

    //添加当前城市名
    locLabel               = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(locImage.frame) + 2, 0, leftView.frame.size.width, locImage.frame.size.height)];
    locLabel.font          = [UIFont systemFontOfSize:16];
    locLabel.textAlignment = NSTextAlignmentCenter;
    locLabel.textColor     = [UIColor whiteColor];
    locLabel.text          = @"定位中";
    [leftView addSubview:locLabel];

    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithCustomView:leftView];
    [self.navigationItem setLeftBarButtonItem:left];


    //创建中间的view
    UIView *centerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 25)];

    //最新
    UIButton *newBtn = [[UIButton alloc] initWithFrame:CGRectMake(centerView.frame.size.width / 2 - 50, 0, 40, 25)];
    [newBtn setTitle:@"最新" forState:UIControlStateNormal];
    [newBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    newBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    newBtn.tag             = 101;
    [newBtn addTarget:self action:@selector(changeState:) forControlEvents:UIControlEventTouchUpInside];
    [centerView addSubview:newBtn];

    //热门
    UIButton *hotBtn = [[UIButton alloc] initWithFrame:CGRectMake(centerView.frame.size.width / 2 + 20, 0, 40, 25)];
    [hotBtn setTitle:@"热门" forState:UIControlStateNormal];
    [hotBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    hotBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    hotBtn.tag             = 102;
    [hotBtn addTarget:self action:@selector(changeState:) forControlEvents:UIControlEventTouchUpInside];
    //[centerView addSubview:hotBtn];

    //视频圈
    UIButton *videoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    videoBtn.x         = CGRectGetMaxX(newBtn.frame) + 10;
    videoBtn.y         = 0;
    videoBtn.width     = 80;
    videoBtn.height    = 25;
    //[videoBtn setBackgroundColor:[UIColor redColor]];
    videoBtn.tag = 103;
    [videoBtn setTitle:@"视频圈" forState:UIControlStateNormal];
    videoBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [videoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [videoBtn addTarget:self action:@selector(changeState:) forControlEvents:UIControlEventTouchUpInside];
    [centerView addSubview:videoBtn];


    lineView                 = [[UIView alloc] initWithFrame:CGRectMake(centerView.frame.size.width / 2 - 50, 32, 52, 3)];
    lineView.backgroundColor = [UIColor whiteColor];
    [centerView addSubview:lineView];

    [self.navigationItem setTitleView:centerView];

    //---------------添加右边的item------------
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [rightBtn setFrame:CGRectMake(0, 0, 30, 17)];

    //添加扩展功能的图片
    UIImageView *searchImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, rightBtn.frame.size.height)];
    searchImg.image        = [UIImage imageNamed:@"搜索"];
    searchImg.contentMode  = UIViewContentModeScaleAspectFit;
    [rightBtn addSubview:searchImg];
    [rightBtn addTarget:self action:@selector(turnToSearch) forControlEvents:UIControlEventTouchUpInside];

    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    [self.navigationItem setRightBarButtonItem:right];
}

- (void)createScrollView {

    headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenWidth / 2 - 35)];
    [_collectionView addSubview:headView];

    UIImageView *stateImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, kMainScreenWidth / 2 + 10, 20, 20)];
    stateImg.image        = [UIImage imageNamed:@"动态"];
    [headView addSubview:stateImg];

    UILabel *stateLabel      = [[UILabel alloc] initWithFrame:CGRectMake(37, kMainScreenWidth / 2 + 5, 100, 30)];
    stateLabel.text          = @"最新动态";
    stateLabel.textColor     = [UIColor colorWithRed:29 / 255.0 green:189 / 255.0 blue:159 / 255.0 alpha:1];
    stateLabel.font          = [UIFont systemFontOfSize:16];
    stateLabel.textAlignment = NSTextAlignmentLeft;
    [headView addSubview:stateLabel];

    cycleBannerViewBottom                      = [KDCycleBannerView new];
    cycleBannerViewBottom.frame                = CGRectMake(0, 0, kMainScreenWidth, kMainScreenWidth / 2); //位置及宽高
    cycleBannerViewBottom.datasource           = self;
    cycleBannerViewBottom.delegate             = self;
    cycleBannerViewBottom.continuous           = YES; //是否连续显示
    cycleBannerViewBottom.autoPlayTimeInterval = 4;   //时间间隔
    [headView addSubview:cycleBannerViewBottom];

    cycleBannerViewBottom2                      = [KDCycleBannerView new];
    cycleBannerViewBottom2.frame                = CGRectMake(0, 0, kMainScreenWidth, kMainScreenWidth / 2); //位置及宽高
    cycleBannerViewBottom2.datasource           = self;
    cycleBannerViewBottom2.delegate             = self;
    cycleBannerViewBottom2.continuous           = YES; //是否连续显示
    cycleBannerViewBottom2.autoPlayTimeInterval = 4;   //时间间隔

    scrollImageArray          = [[NSMutableArray alloc] init];
    scrollImageActionURLArray = [[NSMutableArray alloc] init];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/assets/homeImg", REQUESTHEADER] andParameter:@{} success:^(id successResponse) {
        MLOG(@"轮播图结果:%@", successResponse);
        if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {

            NSArray *array = successResponse[@"data"][@"imgs"];
            for (NSDictionary *dict in array) {
                NSString *imgStr  = dict[@"img"];
                NSString *imgName = [NSString stringWithFormat:@"%@%@", IMAGEHEADER, imgStr];
                [scrollImageArray addObject:imgName];
                [scrollImageActionURLArray addObject:dict[@"actionUrl"]];
            }
            [cycleBannerViewBottom reloadDataWithCompleteBlock:nil];
            // cycleBannerViewBottom2 应该已经无效
            //            [cycleBannerViewBottom2 reloadDataWithCompleteBlock:nil];
        } else {
        }
    }
        andFailure:^(id failureResponse){

        }];

    UIView *noteView         = [[UIView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, 30)];
    noteView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
#warning 隐藏发布按钮
    //[self.view addSubview:noteView];

    _scrollView = [[ScrollView alloc] initWithFrame:CGRectMake(40, 5, SCREEN_WIDTH - 50, 20)];
    [noteView addSubview:_scrollView];

    rssArray  = [NSMutableArray arrayWithObjects:@"", nil];
    needIdArr = [NSMutableArray arrayWithObjects:@"", nil];
    [_scrollView.newsButton addTarget:self action:@selector(topInfoClicked:) forControlEvents:UIControlEventTouchUpInside];
    [UIView animateWithDuration:0.7 delay:0 options:0 animations:^() {
        _scrollView.alpha = 0.2;
        [_scrollView exchangeSubviewAtIndex:1 withSubviewAtIndex:0];
        _scrollView.alpha = 1;
    }
        completion:^(BOOL finished){
//设置定时器
#warning 不在请求小喇叭数据
            //[NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(displayNews) userInfo:nil repeats:YES];
            //[NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(getScrollData) userInfo:nil repeats:YES];
        }];

    UIImageView *noteImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 20, 20)];
    noteImg.image        = [UIImage imageNamed:@"小喇叭"];

    [noteView addSubview:noteImg];
}


- (void)topInfoClicked:(UIButton *)btn {

    if (countInt <= rssArray.count) {
        NSString *str  = rssArray[countInt];
        NSArray *array = [str componentsSeparatedByString:@" "];

        if (array.count > 1) {
            if ([needIdArr[countInt][@"horn"][@"type"] integerValue] == 0) {
                RequirementDetailViewController *rlVC = [[RequirementDetailViewController alloc] init];
                rlVC.needId                           = needIdArr[countInt][@"horn"][@"need_id"];
                rlVC.isMyself                         = NO;
                rlVC.needName                         = array[2];
                [self.navigationController pushViewController:rlVC animated:YES];
            } else if ([needIdArr[countInt][@"horn"][@"type"] integerValue] == 1) {
                SkillDetailViewController *rlVC = [[SkillDetailViewController alloc] init];
                rlVC.skillId                    = needIdArr[countInt][@"horn"][@"skill_id"];
                rlVC.skillUserId                = needIdArr[countInt][@"horn"][@"user_id"];
                [self.navigationController pushViewController:rlVC animated:YES];
            }
        }
    }
}

- (void)getScrollData {
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/need/horns", REQUESTHEADER] andParameter:@{} success:^(id successResponse) {
        MLOG(@"结果:%@", successResponse);
        if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
            [rssArray removeAllObjects];
            [needIdArr removeAllObjects];
            for (int i = 0; i < 10; i++) {
                NSDictionary *dic = [successResponse[@"data"][@"data"] objectForKey:[NSString stringWithFormat:@"horns_%d", i]];
                NSString *str     = @"";
                if ([dic[@"horn"][@"type"] integerValue] == 0) {
                    str = [NSString stringWithFormat:@"%@ 发布了 %@ 的需求", dic[@"userName"], dic[@"smallName"]];
                } else if ([dic[@"horn"][@"type"] integerValue] == 1) {
                    str = [NSString stringWithFormat:@"%@ 发布了 %@ 的技能", dic[@"userName"], dic[@"smallName"]];
                } else {
                    str = [NSString stringWithFormat:@"%@ 给 %@ 付款 %@ 元", dic[@"fName"], dic[@"userName"], dic[@"horn"][@"amount"]];
                }
                if (dic) {
                    [rssArray addObject:str];
                    [needIdArr addObject:dic];
                }
            }
        } else {
        }
    }
        andFailure:^(id failureResponse){

        }];
}

- (void)displayNews {
    countInt++;
    //    long num = [rssArray count] >= 3 ? 3:[rssArray count];
    if (countInt >= [rssArray count])
        countInt                  = 0;
    CATransition *animation       = [CATransition animation];
    animation.delegate            = self;
    animation.duration            = 0.5f;
    animation.timingFunction      = UIViewAnimationCurveEaseInOut;
    animation.fillMode            = kCAFillModeForwards;
    animation.removedOnCompletion = YES;
    animation.type                = @"cube";

    [_scrollView.layer addAnimation:animation forKey:@"animationID"];
    if (rssArray.count != 0) {
        [_scrollView setViewWithTitle:rssArray[countInt]];
    }
}

- (void)createScrollView2 {
    headView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenWidth / 2 + 35)];

    UIImageView *stateImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, kMainScreenWidth / 2 + 10, 20, 20)];
    stateImg.image        = [UIImage imageNamed:@"内容"];
    [headView2 addSubview:stateImg];

    UILabel *stateLabel      = [[UILabel alloc] initWithFrame:CGRectMake(37, kMainScreenWidth / 2 + 5, 100, 30)];
    stateLabel.text          = @"热门内容";
    stateLabel.textColor     = [UIColor colorWithRed:29 / 255.0 green:189 / 255.0 blue:159 / 255.0 alpha:1];
    stateLabel.font          = [UIFont systemFontOfSize:16];
    stateLabel.textAlignment = NSTextAlignmentLeft;
    [headView2 addSubview:stateLabel];

    [headView2 addSubview:cycleBannerViewBottom2];
}

- (void)turnToSearch {

    SearchNearbyViewController *nextV = [[SearchNearbyViewController alloc] init];
    nextV.latitude                    = latitude;
    nextV.longitude                   = longitude;
    [self.navigationController pushViewController:nextV animated:YES];
}

- (void)changeState:(UIButton *)btn {
    if (btn.tag == 101) { //最新
        [UIView animateWithDuration:0.3 animations:^{
            lineView.frame = CGRectMake(self.navigationItem.titleView.frame.size.width / 2 - 60, 32, 52, 3);
        }];
        _hotCollectionView.hidden = YES;
        _collectionView.hidden    = NO;
        isNew                     = YES;
    } else if (btn.tag == 102) { //热门
        [UIView animateWithDuration:0.3 animations:^{
            lineView.frame = CGRectMake(self.navigationItem.titleView.frame.size.width / 2 + 8, 32, 52, 3);
        }];
        _hotCollectionView.hidden = NO;
        _collectionView.hidden    = YES;
        isNew                     = NO;
        if (isFirst) {
            [self headerRefreshing];
            isFirst = NO;
        }
    } else if (btn.tag == 103) { //视频圈
                                 //        [UIView animateWithDuration:0.3 animations:^{
                                 //            lineView.frame = CGRectMake(self.navigationItem.titleView.frame.size.width / 2 + 8, 32, 52, 3);
                                 //        }];
        [[LYUserService sharedInstance] fetchLoginStateWithCompeletionBlock:^(UserLoginStateType type) {
            if (type == UserLoginStateTypeWaitToLogin) {
                [[LYUserService sharedInstance] jumpToLoginWithController:self.tabBarController];
            } else {
                VideoListViewController *video = [[VideoListViewController alloc] init];
                [self.navigationController pushViewController:video animated:YES];
            }
        }];

    } else {
    }
}

#pragma mark - 下拉刷新/网络请求
//添加刷新
- (void)addRefresh {
    // 1.下拉刷新(进入刷新状态就会调用self的headerRereshing)
    _collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefreshing)];

    // 2.上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    _collectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRefreshing)];

    // 1.下拉刷新(进入刷新状态就会调用self的headerRereshing)
    _hotCollectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefreshing)];

    // 2.上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    _hotCollectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRefreshing)];
}

#pragma mark 上拉下拉刷新

- (void)headerRefreshing {

    //    refreshType = @"near";
    if (isNew) {
        currentPage = 1;
    } else {
        currentPage2 = 1;
    }

    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 8.0) {
        //前台和后台都允许请求用户是否允许开启定位 IOS8.0以上版本需要设置环境参数
        [_clManager requestAlwaysAuthorization];
        [_clManager startUpdatingLocation];
    } else {
        //如果是IOS8.0以下的版本，则可直接开启定位
        [_clManager startUpdatingLocation];
    }

    MJRefreshStateHeader *header = (MJRefreshStateHeader *) _collectionView.mj_header;
    [header setTitle:@"下拉可以刷新" forState:MJRefreshStateIdle];
    [header setTitle:@"松开马上刷新" forState:MJRefreshStatePulling];
    [header setTitle:@"刷新中" forState:MJRefreshStateRefreshing];
}

- (void)footerRefreshing {
    [MBProgressHUD showMessage:@"加载中" toView:self.view];
    [[LYUserService sharedInstance] fetchLoginStateWithCompeletionBlock:^(UserLoginStateType type) {
        if (type == UserLoginStateTypeWaitToLogin) {
            NSInteger page = 1;
            if (isNew) {
                currentPage++;
                page = currentPage;
            } else {
                currentPage2++;
                page = currentPage2;
            }

            [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/guide2", REQUESTHEADER] andParameter:@{ @"isToristEnter": @"1",
                                                                                                                                    @"longitude": longitude,
                                                                                                                                    @"latitude": latitude,
                                                                                                                                    @"pageNum": [NSString stringWithFormat:@"%ld", (long) page] }
                success:^(id successResponse) {
                    MLOG(@"结果:%@", successResponse);
                    if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {

                        if (isNew) {
                            NSArray *array = successResponse[@"data"][@"list"];
                            if (!array.count) {
                                currentPage--;
                                [MBProgressHUD showError:@"已经到底咯~"];
                                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                            } else {
                                NSMutableArray *arr = [[NSMutableArray alloc] init];
                                for (NSDictionary *dict in successResponse[@"data"][@"list"]) {
                                    homeModel              = [[HomeModel alloc] initWithDict:dict];
                                    homeModel.isShowAction = YES;
                                    [_guideArray addObject:homeModel];
                                    [arr addObject:homeModel];
                                }
                                for (HomeModel *model in arr) {
                                    CGRect rect = CGRectZero;
                                    //                                if (model.skillDetail.length != 0) {
                                    //                                    rect = [model.skillDetail boundingRectWithSize:CGSizeMake((SCREEN_WIDTH - 5)/ 2 - 20, 55) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]} context:nil];
                                    //                                }else if (model.signature.length != 0 && model.skillDetail.length == 0) {
                                    //                                    rect = [model.signature boundingRectWithSize:CGSizeMake((SCREEN_WIDTH - 5)/ 2 - 20, 55) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]} context:nil];
                                    //                                }else {
                                    //                                    rect = CGRectZero;
                                    //                                }
                                    //                                model.textHeight = rect.size.height;

                                    if (model.signature.length != 0) {
                                        rect = [model.signature boundingRectWithSize:CGSizeMake((SCREEN_WIDTH - 5) / 2 - 20, 1000) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:@{ NSFontAttributeName: [UIFont systemFontOfSize:12] } context:nil];
                                    } else {
                                        rect = CGRectZero;
                                    }

                                    model.textHeight = rect.size.height;


                                    CGFloat height = 0;
                                    if (model.imageHeight != 25.0) {
                                        height = model.imageHeight + 55 + rect.size.height;
                                    } else {
                                        height = model.imageHeight + 42 + rect.size.height;
                                    }
                                    model.cellHeight = height;

                                    [_heightArr addObject:[NSString stringWithFormat:@"%f", height]];
                                }

                                [_collectionView reloadData];
                            }
                        } else {
                            NSArray *array = successResponse[@"data"][@"imgs"];
                            if (!array.count) {
                                currentPage2--;
                                [MBProgressHUD showError:@"已经到底咯~"];
                                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                            } else {
                                NSMutableArray *arr = [[NSMutableArray alloc] init];
                                for (NSDictionary *dict in successResponse[@"data"][@"imgs"]) {
                                    hotModel = [[HotModel alloc] initWithDict:dict];
                                    [_hotArray addObject:hotModel];
                                    [arr addObject:hotModel];
                                }
                                for (HotModel *model in arr) {
                                    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", IMAGEHEADER, model.imgName]]];

                                    UIImage *image = [UIImage imageWithData:data];
                                    CGSize size    = CGSizeFromString(NSStringFromCGSize(image.size));
                                    model.image    = image;

                                    model.imageHeight = (SCREEN_WIDTH - 20) / size.width * size.height;

                                    CGRect rect      = [model.intro boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 20, 70) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:@{ NSFontAttributeName: [UIFont systemFontOfSize:16] } context:nil];
                                    model.textHeight = rect.size.height;

                                    CGFloat height   = ((SCREEN_WIDTH - 20) / size.width * size.height + 35 + rect.size.height);
                                    model.cellHeight = height;

                                    [_heightHotArr addObject:[NSString stringWithFormat:@"%f", height]];
                                }
                                [_hotCollectionView reloadData];
                            }
                        }
                    } else {
                        if (isNew) {
                            currentPage--;
                        } else {
                            currentPage2--;
                        }
                        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                        [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"msg"]]];
                    }
                }
                andFailure:^(id failureResponse) {
                    if (isNew) {
                        currentPage--;
                    } else {
                        currentPage2--;
                    }
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    [MBProgressHUD showError:@"服务器繁忙,请重试"];
                }];
            [_collectionView.mj_footer endRefreshing];
            [_hotCollectionView.mj_footer endRefreshing];
        } else if (type == UserLoginStateTypeAlreadyLogin) {
            NSInteger page = 1;
            if (isNew) {
                currentPage++;
                page = currentPage;
            } else {
                currentPage2++;
                page = currentPage2;
            }

            [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/guide2", REQUESTHEADER] andParameter:@{ @"user_id": [LYUserService sharedInstance].userID,
                                                                                                                                    @"longitude": longitude,
                                                                                                                                    @"latitude": latitude,
                                                                                                                                    @"pageNum": [NSString stringWithFormat:@"%ld", (long) page] }
                success:^(id successResponse) {
                    MLOG(@"结果:%@", successResponse);
                    if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {

                        if (isNew) {
                            NSArray *array = successResponse[@"data"][@"list"];
                            if (!array.count) {
                                currentPage--;
                                [MBProgressHUD showError:@"已经到底咯~"];
                                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                            } else {
                                NSMutableArray *arr = [[NSMutableArray alloc] init];
                                for (NSDictionary *dict in successResponse[@"data"][@"list"]) {
                                    homeModel              = [[HomeModel alloc] initWithDict:dict];
                                    homeModel.isShowAction = YES;
                                    [_guideArray addObject:homeModel];
                                    [arr addObject:homeModel];
                                }
                                for (HomeModel *model in arr) {

                                    //                                CGRect rect = CGRectZero;
                                    //                                if (model.skillDetail.length != 0) {
                                    //                                    rect = [model.skillDetail boundingRectWithSize:CGSizeMake((SCREEN_WIDTH - 5)/ 2 - 20, 55) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]} context:nil];
                                    //                                }else if (model.signature.length != 0 && model.skillDetail.length == 0) {
                                    //                                    rect = [model.signature boundingRectWithSize:CGSizeMake((SCREEN_WIDTH - 5)/ 2 - 20, 55) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]} context:nil];
                                    //                                }else {
                                    //                                    rect = CGRectZero;
                                    //                                }
                                    //                                model.textHeight = rect.size.height;
                                    CGRect rect = CGRectZero;
                                    if (model.signature.length != 0) {
                                        rect = [model.signature boundingRectWithSize:CGSizeMake((SCREEN_WIDTH - 5) / 2 - 20, 1000) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:@{ NSFontAttributeName: [UIFont systemFontOfSize:12] } context:nil];
                                    } else {
                                        rect = CGRectZero;
                                    }

                                    model.textHeight = rect.size.height;


                                    CGFloat height = 0;
                                    if (model.imageHeight != 25.0) {
                                        height = model.imageHeight + 55 + rect.size.height;
                                    } else {
                                        height = model.imageHeight + 42 + rect.size.height;
                                    }
                                    model.cellHeight = height;

                                    [_heightArr addObject:[NSString stringWithFormat:@"%f", height]];
                                }

                                [_collectionView reloadData];
                            }
                        } else {
                            NSArray *array = successResponse[@"data"][@"imgs"];
                            if (!array.count) {
                                currentPage--;
                                [MBProgressHUD showError:@"已经到底咯~"];
                                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                            } else {
                                NSMutableArray *arr = [[NSMutableArray alloc] init];
                                for (NSDictionary *dict in successResponse[@"data"][@"imgs"]) {
                                    hotModel = [[HotModel alloc] initWithDict:dict];
                                    [_hotArray addObject:hotModel];
                                    [arr addObject:hotModel];
                                }
                                for (HotModel *model in arr) {
                                    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", IMAGEHEADER, model.imgName]]];

                                    UIImage *image = [UIImage imageWithData:data];
                                    CGSize size    = CGSizeFromString(NSStringFromCGSize(image.size));
                                    model.image    = image;

                                    model.imageHeight = (SCREEN_WIDTH - 20) / size.width * size.height;

                                    CGRect rect      = [model.intro boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 20, 70) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:@{ NSFontAttributeName: [UIFont systemFontOfSize:16] } context:nil];
                                    model.textHeight = rect.size.height;

                                    CGFloat height   = ((SCREEN_WIDTH - 20) / size.width * size.height + 35 + rect.size.height);
                                    model.cellHeight = height;

                                    [_heightHotArr addObject:[NSString stringWithFormat:@"%f", height]];
                                }
                                [_hotCollectionView reloadData];
                            }
                        }
                    } else {
                        if (isNew) {
                            currentPage--;
                        } else {
                            currentPage2--;
                        }
                        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                        [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"msg"]]];
                    }
                }
                andFailure:^(id failureResponse) {
                    if (isNew) {
                        currentPage--;
                    } else {
                        currentPage2--;
                    }
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    [MBProgressHUD showError:@"服务器繁忙,请重试"];
                }];
            [_collectionView.mj_footer endRefreshing];
            [_hotCollectionView.mj_footer endRefreshing];
        }
    }];
}

#pragma mark 网络请求

- (void)getDataFromWeb {
    [MBProgressHUD showMessage:@"加载中" toView:self.view];
    [[LYUserService sharedInstance] fetchLoginStateWithCompeletionBlock:^(UserLoginStateType type) {
        if (type == 1) {
#warning 经纬度
            [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/guide2", REQUESTHEADER] andParameter:@{ @"user_id": [LYUserService sharedInstance].userID,
                                                                                                                                    @"longitude": longitude,
                                                                                                                                    @"latitude": latitude }
                success:^(id successResponse) {
                    MLOG(@"结果:%@", successResponse);
                    if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {

                        if (isNew) {
                            [_guideArray removeAllObjects];
                            [_heightArr removeAllObjects];
                            for (NSDictionary *dict in successResponse[@"data"][@"list"]) {
                                homeModel              = [[HomeModel alloc] initWithDict:dict];
                                homeModel.isShowAction = YES;
                                [_guideArray addObject:homeModel];
                            }
                            for (HomeModel *model in _guideArray) {

                                CGRect rect = CGRectZero;
                                /**
                             *  @author KF, 16-07-14 18:07:13
                             *
                             *  @brief 去掉签名
                             */
                                //                            if (model.skillDetail.length != 0) {
                                //                                rect = [model.skillDetail boundingRectWithSize:CGSizeMake((SCREEN_WIDTH - 5)/ 2 - 20, 55) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]} context:nil];
                                //                            }else if (model.signature.length != 0 && model.skillDetail.length == 0) {
                                //                                rect = [model.signature boundingRectWithSize:CGSizeMake((SCREEN_WIDTH - 5)/ 2 - 20, 55) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]} context:nil];
                                //                            }else {
                                //                                rect = CGRectZero;
                                //                            }
                                if (model.signature.length != 0) {
                                    rect = [model.signature boundingRectWithSize:CGSizeMake((SCREEN_WIDTH - 5) / 2 - 20, 1000) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:@{ NSFontAttributeName: [UIFont systemFontOfSize:12] } context:nil];
                                } else {
                                    rect = CGRectZero;
                                }

                                model.textHeight = rect.size.height;

                                CGFloat height = 0;
                                if (model.imageHeight != 25.0) {
                                    height = model.imageHeight + 55 + rect.size.height;
                                } else {
                                    height = model.imageHeight + 42 + rect.size.height;
                                }
                                model.cellHeight = height;

                                [_heightArr addObject:[NSString stringWithFormat:@"%f", height]];
                            }

                            [_collectionView reloadData];
                        } else {
                            [_hotArray removeAllObjects];
                            [_heightHotArr removeAllObjects];
                            for (NSDictionary *dict in successResponse[@"data"][@"imgs"]) {
                                hotModel = [[HotModel alloc] initWithDict:dict];
                                [_hotArray addObject:hotModel];
                            }
                            for (HotModel *model in _hotArray) {
                                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", IMAGEHEADER, model.imgName]]];

                                UIImage *image = [UIImage imageWithData:data];
                                CGSize size    = CGSizeFromString(NSStringFromCGSize(image.size));
                                model.image    = image;

                                model.imageHeight = (SCREEN_WIDTH - 20) / size.width * size.height;
                                if (!image) {
                                    model.imageHeight = 0;
                                }

                                CGRect rect      = [model.intro boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 20, 60) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:@{ NSFontAttributeName: [UIFont systemFontOfSize:16] } context:nil];
                                model.textHeight = rect.size.height;

                                CGFloat height   = (model.imageHeight + 35 + rect.size.height);
                                model.cellHeight = height;

                                [_heightHotArr addObject:[NSString stringWithFormat:@"%f", height]];
                            }
                            [_hotCollectionView reloadData];
                            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                        }
                    } else {
                        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                        [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"msg"]]];
                    }
                }
                andFailure:^(id failureResponse) {
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    [MBProgressHUD showError:@"服务器繁忙,请重试"];
                }];

            [_collectionView.mj_header endRefreshing];
            [_hotCollectionView.mj_header endRefreshing];
        } else if (type == 0) {
#warning 经纬度
            [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/guide2", REQUESTHEADER] andParameter:@{ @"longitude": longitude,
                                                                                                                                    @"latitude": latitude,
                                                                                                                                    @"isToristEnter": @"1" }
                success:^(id successResponse) {
                    MLOG(@"结果:%@", successResponse);
                    if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {

                        if (isNew) {
                            [_guideArray removeAllObjects];
                            [_heightArr removeAllObjects];
                            for (NSDictionary *dict in successResponse[@"data"][@"list"]) {
                                homeModel              = [[HomeModel alloc] initWithDict:dict];
                                homeModel.isShowAction = YES;
                                [_guideArray addObject:homeModel];
                            }
                            for (HomeModel *model in _guideArray) {

                                CGRect rect = CGRectZero;
                                //                            if (model.skillDetail.length != 0) {
                                //                                rect = [model.skillDetail boundingRectWithSize:CGSizeMake((SCREEN_WIDTH - 5)/ 2 - 20, 55) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]} context:nil];
                                //                            }else if (model.signature.length != 0 && model.skillDetail.length == 0) {
                                //                                rect = [model.signature boundingRectWithSize:CGSizeMake((SCREEN_WIDTH - 5)/ 2 - 20, 55) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]} context:nil];
                                //                            }else {
                                //                                rect = CGRectZero;
                                //                            }
                                //                            model.textHeight = rect.size.height;

                                if (model.signature.length != 0) {
                                    rect = [model.signature boundingRectWithSize:CGSizeMake((SCREEN_WIDTH - 5) / 2 - 20, 1000) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:@{ NSFontAttributeName: [UIFont systemFontOfSize:12] } context:nil];
                                } else {
                                    rect = CGRectZero;
                                }

                                model.textHeight = rect.size.height;


                                CGFloat height = 0;
                                if (model.imageHeight != 25.0) {
                                    height = model.imageHeight + 55 + rect.size.height;
                                } else {
                                    height = model.imageHeight + 42 + rect.size.height;
                                }
                                model.cellHeight = height;

                                [_heightArr addObject:[NSString stringWithFormat:@"%f", height]];
                            }

                            [_collectionView reloadData];
                        } else {
                            [_hotArray removeAllObjects];
                            [_heightHotArr removeAllObjects];
                            for (NSDictionary *dict in successResponse[@"data"][@"imgs"]) {
                                hotModel = [[HotModel alloc] initWithDict:dict];
                                [_hotArray addObject:hotModel];
                            }
                            for (HotModel *model in _hotArray) {
                                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", IMAGEHEADER, model.imgName]]];

                                UIImage *image = [UIImage imageWithData:data];
                                CGSize size    = CGSizeFromString(NSStringFromCGSize(image.size));
                                model.image    = image;

                                model.imageHeight = (SCREEN_WIDTH - 20) / size.width * size.height;
                                if (!image) {
                                    model.imageHeight = 0;
                                }

                                CGRect rect      = [model.intro boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 20, 70) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:@{ NSFontAttributeName: [UIFont systemFontOfSize:16] } context:nil];
                                model.textHeight = rect.size.height;

                                CGFloat height   = (model.imageHeight + 35 + rect.size.height);
                                model.cellHeight = height;

                                [_heightHotArr addObject:[NSString stringWithFormat:@"%f", height]];
                            }
                            [_hotCollectionView reloadData];
                            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                        }
                    } else {
                        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                        [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"msg"]]];
                    }
                }
                andFailure:^(id failureResponse) {
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    [MBProgressHUD showError:@"服务器繁忙,请重试"];
                }];

            [_collectionView.mj_header endRefreshing];
            [_hotCollectionView.mj_header endRefreshing];
        }
    }];
}

#pragma mark - UICollectionDelegate,UICollevtiondataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == _collectionView) {
        return _guideArray.count + 2;
    } else {
        return _hotArray.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == _collectionView) {
        if (indexPath.row > 1) {
            HomeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"newCell" forIndexPath:indexPath];
            cell.delegate                = self;
            homeModel                    = _guideArray[indexPath.row - 2];

            [cell fillData:homeModel];
            return cell;
        } else {
            UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
            cell.backgroundColor       = [UIColor clearColor];
            return cell;
        }
    } else {
        HotMessageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"hotCell" forIndexPath:indexPath];
        cell.backgroundColor               = [UIColor clearColor];
        hotModel                           = _hotArray[indexPath.row];
        [cell fillData:hotModel];
        return cell;
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headCell" forIndexPath:indexPath];
    [headerView addSubview:headView2];
    return headerView;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [[LYUserService sharedInstance] fetchLoginStateWithCompeletionBlock:^(UserLoginStateType type) {
        if (type == UserLoginStateTypeWaitToLogin) {
            [[LYUserService sharedInstance] jumpToLoginWithController:self.tabBarController];
        } else {

            if (collectionView == _collectionView) {
                HomeModel *model                 = _guideArray[indexPath.item - 2];
                LYDetailDataViewController *deta = [[LYDetailDataViewController alloc] init];
                deta.userId                      = model.id;
                [self.navigationController pushViewController:deta animated:YES];
            } else {
                HotModel *model = _hotArray[indexPath.item];
                //        MyDispositionViewController *mdVC = [[MyDispositionViewController alloc] init];
                //        mdVC.userId = model.userId;
                //        [self.navigationController pushViewController:mdVC animated:YES];
                LYDetailDataViewController *deta = [[LYDetailDataViewController alloc] init];
                //                deta.friendId                  = [model.userId integerValue];
                [self.navigationController pushViewController:deta animated:YES];
            }
        }
    }];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item > 1 && collectionView == _collectionView) {

        homeModel = _guideArray[indexPath.item - 2];
        if (homeModel.isShowAction) {
            homeModel.isShowAction = NO;

            CGRect rect     = cell.frame;
            rect.size.width = cell.frame.size.width + 3;

            UIView *hideView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width / 2, rect.size.height / 2)];
            [cell addSubview:hideView1];
            hideView1.backgroundColor = [UIColor colorWithRed:244 / 255.0 green:245 / 255.0 blue:246 / 255.0 alpha:1];

            UIView *hideView2 = [[UIView alloc] initWithFrame:CGRectMake(rect.size.width / 2, 0, rect.size.width / 2, rect.size.height / 2)];
            [cell addSubview:hideView2];
            hideView2.backgroundColor = [UIColor colorWithRed:244 / 255.0 green:245 / 255.0 blue:246 / 255.0 alpha:1];

            UIView *hideView3 = [[UIView alloc] initWithFrame:CGRectMake(0, rect.size.height / 2, rect.size.width / 2, rect.size.height / 2)];
            [cell addSubview:hideView3];
            hideView3.backgroundColor = [UIColor colorWithRed:244 / 255.0 green:245 / 255.0 blue:246 / 255.0 alpha:1];

            UIView *hideView4 = [[UIView alloc] initWithFrame:CGRectMake(rect.size.width / 2, rect.size.height / 2, rect.size.width / 2, rect.size.height / 2)];
            [cell addSubview:hideView4];
            hideView4.backgroundColor = [UIColor colorWithRed:244 / 255.0 green:245 / 255.0 blue:246 / 255.0 alpha:1];


            UIView *hideView5 = [[UIView alloc] initWithFrame:CGRectMake(rect.size.width / 2, 0, 0, rect.size.height / 2)];
            [cell addSubview:hideView5];
            hideView5.backgroundColor = [UIColor colorWithRed:244 / 255.0 green:245 / 255.0 blue:246 / 255.0 alpha:1];

            UIView *hideView6 = [[UIView alloc] initWithFrame:CGRectMake(0, rect.size.height / 2, rect.size.width / 2, 0)];
            [cell addSubview:hideView6];
            hideView6.backgroundColor = [UIColor colorWithRed:244 / 255.0 green:245 / 255.0 blue:246 / 255.0 alpha:1];

            UIView *hideView7 = [[UIView alloc] initWithFrame:CGRectMake(rect.size.width / 2, rect.size.height / 2, 0, rect.size.height / 2)];
            [cell addSubview:hideView7];
            hideView7.backgroundColor = [UIColor colorWithRed:244 / 255.0 green:245 / 255.0 blue:246 / 255.0 alpha:1];

            UIView *hideView8 = [[UIView alloc] initWithFrame:CGRectMake(rect.size.width / 2, rect.size.height / 2, rect.size.width / 2, 0)];
            [cell addSubview:hideView8];
            hideView8.backgroundColor = [UIColor colorWithRed:244 / 255.0 green:245 / 255.0 blue:246 / 255.0 alpha:1];

            [UIView animateWithDuration:0.6 delay:.0 options:UIViewAnimationOptionCurveEaseOut animations:^{

                hideView1.frame = CGRectMake(0, 0, 0, 0);
                hideView2.frame = CGRectMake(rect.size.width, 0, 0, 0);
                hideView3.frame = CGRectMake(0, rect.size.height, 0, 0);
                hideView4.frame = CGRectMake(rect.size.width, rect.size.height, 0, 0);

                hideView5.frame = CGRectMake(0, 0, rect.size.width, 0);
                hideView6.frame = CGRectMake(0, 0, 0, rect.size.height);
                hideView7.frame = CGRectMake(0, rect.size.height, rect.size.width, 0);
                hideView8.frame = CGRectMake(rect.size.width, 0, 0, rect.size.height);
            }
                completion:^(BOOL finished) {
                    [hideView1 removeFromSuperview];
                    [hideView2 removeFromSuperview];
                    [hideView3 removeFromSuperview];
                    [hideView4 removeFromSuperview];
                    [hideView5 removeFromSuperview];
                    [hideView6 removeFromSuperview];
                    [hideView7 removeFromSuperview];
                    [hideView8 removeFromSuperview];
                }];
        }
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == _hotCollectionView) {

        return CGSizeMake(SCREEN_WIDTH, [_heightHotArr[indexPath.item] floatValue]);
    }

    return CGSizeMake(SCREEN_WIDTH, SCREEN_WIDTH);
}

#pragma mark - HomeCollectionViewCellDelegate
- (void)homeCollectionViewCell:(HomeCollectionViewCell *)cell didClickPlayButton:(UIButton *)sender {
    MLOG(@"homeCollectionViewCell");
}

#pragma mark - 获取城市位置

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    [_clManager stopUpdatingLocation];
    CLLocation *currentLocation = [locations lastObject];

    latitude  = [NSString stringWithFormat:@"%f", currentLocation.coordinate.latitude];
    longitude = [NSString stringWithFormat:@"%f", currentLocation.coordinate.longitude];

    if (!kAppDelegate.deviceToken) {
        kAppDelegate.deviceToken = @"bb63b19106f3108798b7a271447e40df8a75c0b7cec8d99f54b43728713edc37";
    }

    if (isAutoLogin) {
        [[LYUserService sharedInstance] autoLoginWithController:self mobile:[[LYUserService sharedInstance] mobile] password:[[LYUserService sharedInstance] password] deviceType:@"1" deviceToken:kAppDelegate.deviceToken umengID:[LYUserService sharedInstance].userDetail.umengID longitude:longitude latitude:latitude];
        isAutoLogin = NO;
    }

    [self getDataFromWeb];

    //停止定位
    [_clManager stopUpdatingLocation];

    //初始化检索对象
    self.searcher          = [[BMKGeoCodeSearch alloc] init];
    self.searcher.delegate = self;

    //发起反向地理编码检索
    CLLocationCoordinate2D pt                           = (CLLocationCoordinate2D){[latitude floatValue], [longitude floatValue]};
    BMKReverseGeoCodeOption *reverseGeoCodeSearchOption = [[BMKReverseGeoCodeOption alloc] init];
    reverseGeoCodeSearchOption.reverseGeoPoint          = pt;
    [self.searcher reverseGeoCode:reverseGeoCodeSearchOption];
    BOOL flag = [self.searcher reverseGeoCode:reverseGeoCodeSearchOption];
    if (flag) {
        NSLog(@"反geo检索发送成功");
    } else {
        NSLog(@"反geo检索发送失败");
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {

    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        //用户允许授权,开启定位
        [_clManager startUpdatingLocation];
    } else {
        //        [MBProgressHUD showError:@"用户拒绝授权,请在设置中开启"];
        longitude = @"120.027860";
        latitude  = @"30.245586";
        if (!kAppDelegate.deviceToken) {
            kAppDelegate.deviceToken = @"bb63b19106f3108798b7a271447e40df8a75c0b7cec8d99f54b43728713edc37";
        }
        if (isAutoLogin) {
            [[LYUserService sharedInstance] autoLoginWithController:self mobile:[[LYUserService sharedInstance] mobile] password:[[LYUserService sharedInstance] password] deviceType:@"1" deviceToken:kAppDelegate.deviceToken umengID:[LYUserService sharedInstance].userDetail.umengID longitude:longitude latitude:latitude];
            isAutoLogin = NO;
        }
        [self getDataFromWeb];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [MBProgressHUD showError:@"定位失败,请重试"];

    [self getDataFromWeb];
}

#pragma mark 代理方法返回反地理编码结果
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    if (result) {
        currentCity = [NSString stringWithFormat:@"%@", result.addressDetail.city];
        NSLog(@"%@ - %@", result.address, result.addressDetail.streetNumber);
    } else {
        currentCity = @"定位失败";
    }
    locLabel.text = currentCity;
}

#pragma mark 轮播图代理委托

- (NSArray *)numberOfKDCycleBannerView:(KDCycleBannerView *)bannerView {
    if (scrollImageArray.count) {
        return scrollImageArray;
    } else {
        return nil;
    }
}

- (UIViewContentMode)contentModeForImageIndex:(NSUInteger)index {
    return UIViewContentModeScaleToFill;
}

- (void)cycleBannerView:(KDCycleBannerView *)bannerView didSelectedAtIndex:(NSUInteger)index {
    CollectWebViewController *vc = [CollectWebViewController new];
    vc.url                       = scrollImageActionURLArray[index];
    [self.navigationController pushViewController:vc animated:YES];
}

//返回顶部
- (void)bringToTop {

    if (isNew) {
        [_collectionView setContentOffset:CGPointMake(0, -64) animated:YES];
    } else {
        [_hotCollectionView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
}

#pragma mark 判断是否为空

- (BOOL)isBlankString:(NSString *)string {
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0) {
        return YES;
    }
    return NO;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat y = scrollView.contentOffset.y;
    if (y >= scrollView.contentSize.height - kMainScreenHeight) {
        return;
    }
    CGFloat offSet_Y = y - _startY;
    if (offSet_Y > 0) {
        [UIView animateWithDuration:kNavigationHiddenAnimationDuration * 3 delay:0.0 usingSpringWithDamping:0.35 initialSpringVelocity:50 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
            //BOTTOM
            self.publishBtn.alpha    = 0.35;
            self.animationView.frame = CGRectMake(kMainScreenWidth / 2 - 18, kMainScreenHeight - 20 - 47, 36, 36);
            self.publishBtn.frame    = CGRectMake(0, 0, 36, 36);
        }
                         completion:nil];
    } else {
        [UIView animateWithDuration:kNavigationHiddenAnimationDuration * 3 delay:0.0 usingSpringWithDamping:0.35 initialSpringVelocity:50 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
            //BOTTOM
            self.publishBtn.alpha    = 0.90;
            self.animationView.frame = CGRectMake(kMainScreenWidth / 2 - 36, kMainScreenHeight - 88 - 44, 70, 70);
            self.publishBtn.frame    = CGRectMake(0, 0, 70, 70);
        }
                         completion:nil];
    }
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _startY = scrollView.contentOffset.y;
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    _endY = scrollView.contentOffset.y;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
