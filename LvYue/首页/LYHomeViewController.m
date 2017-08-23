  //
//  LYHomeViewController.m
//  LvYue
//
//  Created by 郑洲 on 16/3/14.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "LYHomeViewController.h"
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "MBProgressHUD+NJ.h"
#import "MJRefresh.h"
#import "SearchNearbyViewController.h"
#import "UIImageView+WebCache.h"
#import "UIView+KFFrame.h"

#import <CoreLocation/CoreLocation.h>

#import "appointModel.h"      //约会吧 下方model
#import "AppointTableCell.h"   //约会吧 下方cell
#import "AFNetworking.h"
#import "bigImageController.h"
#import "otherZhuYeVC.h"  //别人的主页
#import "NewLoginViewController.h"  //登录
#import "travalTableView.h"
#import "eatTableView.h"
#import "movieTableView.h"
#import "ktvTableView.h"
#import "exerciseTableView.h"
#import "marryTableView.h"
#import "shopTableView.h"
#import "otherTableView.h"
#import "newTableView.h"
#import "pchFile.pch"
#import "ZHCellHeightCalculator.h"
#import "newMyInfoModel.h"
#import "MyBuddyModel.h"
#import "EMChatViewBaseCell.h"
#import "AlterGivingView.h"

#import "CallViewController.h"
#import "LGJAutoRunLabel.h"

#define kNavigationHiddenAnimationDuration 0.25f

@interface LYHomeViewController () <CLLocationManagerDelegate, BMKGeoCodeSearchDelegate,UITableViewDataSource,UITableViewDelegate,LGJAutoRunLabelDelegate> {
    UIButton *localeBtn;
   UILabel *locLabel; //显示当前城市名的label
    UIView *currentView;
    NSString *longitude; //经纬度
    NSString *latitude;
    NSString *currentCity; //当前城市名
    NSString *currentProvince; //当前省名
    NSString *currentDistrict; //当前地区名

    UIScrollView *topScroll;   //最上方的scroll
 
    
    UIButton *_lastBtn;
    UILabel *_lastLabel;
    UIButton *button; //scroll上的按钮
    //UITableView *appointTable;  //下方的约内容
    
    NSString *typeId;//约会类型
    
    
    NSInteger currentPage2;                    //当前页数
    NSString *currentTime;//当前时间
    
    ZHCellHeightCalculator *heightCalculator;
    
    NSString *provinceId ;
    NSString *cityId;
    NSString *distriId;
    
//    NSString *alterViewtypeUser;
//   int _time;
}


@property(nonatomic,strong)travalTableView *travel;
@property(nonatomic,strong)eatTableView *eat;
@property(nonatomic,strong)movieTableView *movie;
@property(nonatomic,strong)ktvTableView *ktv;
@property(nonatomic,strong)exerciseTableView *exercise;
@property(nonatomic,strong)marryTableView *marry;
@property(nonatomic,strong)shopTableView *shop;
@property(nonatomic,strong)otherTableView *other;
@property(nonatomic,strong)newTableView *bestNewTable;


@property(nonatomic,retain)NSMutableArray *selelcImageArr; //按钮选中图片数组
@property(nonatomic,retain)NSMutableArray *labelNameArr ;  //sroll上的label的名字
@property(nonatomic,retain)NSMutableArray *scrollImageArr; //scroll上图片的名字
@property(nonatomic,retain)NSMutableArray *labelIdArr;  //scroll上label的id名字

@property (nonatomic, strong) BMKGeoCodeSearch *searcher;

//地理编码对象
@property (nonatomic, strong) CLGeocoder *geocoder;

//定位信息管理者
@property (nonatomic, strong) CLLocationManager *clManager;
//我
@property(nonatomic,copy)NSString *createTime;  //发布约会的时间
@property(nonatomic,copy)NSString *ctivityTime; //约会的时间
@property(nonatomic,copy)NSString *dateCity; //约会的城市
@property(nonatomic,copy)NSString *dateDistict; //约会的区域

@property(nonatomic,strong)NSString *dateProvince;  //约会的省

@property (nonatomic, strong) UITableView *myTableView;
@property (nonatomic,retain) NSMutableArray  *dateTypeArr;

@property (nonatomic,strong) NSString  *yuehuibaTypeId;


@property (nonatomic, strong) AppointTableCell *appointTableCell ;

//@property (nonatomic, strong) AlterGivingView *alterView ;


@end

@implementation LYHomeViewController
static int countInt = 0;

-(UITableView *)myTableView {
    if (!_myTableView) {
        _myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 56*AutoSizeScaleX, SCREEN_WIDTH, SCREEN_HEIGHT-56*AutoSizeScaleX-64-49) style:UITableViewStyleGrouped];
       // [_myTableView registerNib:[UINib nibWithNibName:@"AppointTableCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"AppointTableCell"];
        [_myTableView registerClass:[AppointTableCell class] forCellReuseIdentifier:@"AppointTableCell"];
        _myTableView.delegate = self;
        _myTableView.dataSource = self;
        _myTableView.backgroundColor = RGBA(246, 246, 247, 1);
//        _myTableView.decelerationRate = 0.1f;
//        self.appointTableCell = [_myTableView dequeueReusableCellWithIdentifier:@"AppointTableCell"];
        
    }
//    _myTableView.rowHeight = 607;
   // _myTableView.estimatedRowHeight = 500;
   
    // _myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
   // [_myTableView   setSeparatorColor:[sezhiClass colorWithHexString:@"#d9d9d9"]];  //设置分割线
  
    return _myTableView;
}
//-(AlterGivingView *)alterView {
//    if (!_alterView) {
//        _alterView  = [[AlterGivingView alloc]init];
//        _alterView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
//        _alterView.backgroundColor = RGBA(1, 1, 1, 0.1);
//    }
//   return _alterView;
//}

- (NSMutableArray *)dateTypeArr {
    if (!_dateTypeArr) {
        _dateTypeArr = [[NSMutableArray alloc] init];
    }
    return _dateTypeArr;
}

- (NSMutableArray *)selelcImageArr{
    if (!_selelcImageArr) {
        _selelcImageArr = [[NSMutableArray alloc]init];
    }
    return _selelcImageArr;
}


- (NSMutableArray *)labelIdArr{
    if (!_labelIdArr) {
        _labelIdArr = [[NSMutableArray alloc]init];
    }
    
    return _labelIdArr;
}


//scroll上方label
- (NSMutableArray *)labelNameArr{
    if (!_labelNameArr) {
        _labelNameArr = [[NSMutableArray alloc]init];
    }
    return _labelNameArr;
}

//scroll上方图片
- (NSMutableArray *)scrollImageArr{
    if (!_scrollImageArr) {
        _scrollImageArr = [[NSMutableArray alloc]init];
    }
    return _scrollImageArr;
}



#pragma mark - 定位管理者
- (CLLocationManager *)clManager {
    
    if (!_clManager) {
        _clManager = [[CLLocationManager alloc] init];
        //设置定位硬件的精准度
        _clManager.desiredAccuracy = kCLLocationAccuracyBest;
        //设置定位硬件的刷新频率
        _clManager.distanceFilter = kCLLocationAccuracyKilometer;
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9) {
            _clManager.allowsBackgroundLocationUpdates = NO;
        }
    }
    return _clManager;
}

//#pragma mark - 获取城市位置
//
//- (void)locationManager:(CLLocationManager *)manager
//     didUpdateLocations:(NSArray *)locations{
//    
//}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        //用户允许授权,开启定位
        [_clManager startUpdatingLocation];
    } else {
        //        [MBProgressHUD showError:@"您拒绝了定位授权,若需要请在设置中开启"];
        longitude = @"120.027860";
        latitude = @"30.245586";
    }
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [MBProgressHUD showError:@"定位失败,请重试"];
}

//在视图即将出现的时候把状态栏字体设为黑色
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear: animated];
   //设置状态栏的颜色
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    if (self.scrollImageArr.count == 0) {
        [self getData];
    }
     currentPage2 = 1;
    
    
    
  
}





#pragma mark - 地理编码对象
- (CLGeocoder *)geocoder {

    if (_geocoder == nil) {
        
        _geocoder = [[CLGeocoder alloc] init];
    }
    return _geocoder;
}


- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [MBProgressHUD hideHUD];
    latitude= [[NSString alloc]init];
    longitude = [[NSString alloc]init];
     currentPage2 = 1;
    typeId = @"";
    self.userSex = @"";
    self.arrayType = @"";
    distriId= @"";
    cityId= @"";
    distriId= @"";
    currentCity = @"";
    currentProvince = @"";
    currentDistrict = @"";
//    _time = 0;//定时器执行次数
    NSLog(@"width---%2f,hheight%2f",[[UIScreen mainScreen] bounds].size.width-320,[[UIScreen mainScreen] bounds].size.height);

  
  
    

    
    //上方导航栏
    [self createNavigationView];
    
    [self registNotification];
    [self creatUI];
    
    
    
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
    
    
//    [self cacheLogin];
     [self addRefresh];
    //获取上方约会数据
    [self getData];
    [self  getAppointDataIsupdData];
   
    
   
    
   
    
   
}
-(void)creatUI{
    
    [self.view addSubview:self.myTableView];
    
    UIButton * plusButton = [[UIButton alloc]init];
    plusButton.frame = CGRectMake(SCREEN_WIDTH-80, SCREEN_HEIGHT-64-49-100, 70, 70);
    plusButton.layer.cornerRadius = 35;
    plusButton.clipsToBounds = YES;
    [plusButton setImage:[UIImage imageNamed:@"home_+"] forState:UIControlStateNormal];
    [plusButton  addTarget:self action:@selector(gotoSendApointVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:plusButton];
    [self.view bringSubviewToFront:plusButton];
    
}

-(void)gotoSendApointVC{
    SendAppointViewController *VC = [[SendAppointViewController alloc]init];
    [self.navigationController pushViewController:VC animated:YES];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1002) {
        if (1 == buttonIndex) {
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://114.215.184.120:8088/mobile/shareApp.html"]];
        }
    }
    
}
-(void)registNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadUIData) name:@"reloadUIData" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotoCallViewController:) name:@"gotoCallViewController" object:nil];
}

-(void)reloadUIData{
    [self getAppointDataIsupdData];
}
-(void)gotoCallViewController:(NSNotification *)noti{
                    CallViewController *callController = [[CallViewController alloc] initWithSession:noti.object isIncoming:YES];
                    callController.modalPresentationStyle = UIModalPresentationOverFullScreen;
//    callController.receivId = [CommonTool getUserID];
//    EMCallSession * session =noti.object;
//    NSString *NewId = [session.sessionChatter substringFromIndex:2];// 由于是环信的id 所以改成用户ID
//    callController.senderId = NewId;
   [self presentViewController:callController animated:YES completion:nil];
}
//


//
//-(void)timerAction:(NSTimer *)timer{
//    _time++;
//   [self addWhoSeeMe];
//    if (_time >=3) {
//        [timer invalidate];
//        timer = nil;
//
//    }
//    NSLog(@"_time--%d",_time);
//}
////push通知
//- (void)cacheLogin {
//    NSLog(@"userId--%@--",[CommonTool getUserID]);
//    NSLog(@"getUserCaptcha--%@--",[CommonTool getUserCaptcha]);
//    NSLog(@"kAppDelegate.deviceToken--%@--",kAppDelegate.deviceToken);
// WS(weakSelf)
//    NSDictionary *dic = @{@"userId":[CommonTool getUserID],@"userCaptcha":[CommonTool getUserCaptcha],@"deviceType":@"1",@"deviceToken":[CommonTool getDeviceToken]};
//
//    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/login/cacheLogin",REQUESTHEADER] andParameter:dic success:^(id successResponse) {
//#pragma mark  ---获取个人信息
//        [weakSelf getPersonalInfo];
//        } andFailure:^(id failureResponse) {
//#pragma mark  ---获取个人信息
//            [weakSelf getPersonalInfo];
//    }];
//
//}
//-(void)addWhoSeeMe{
//    [LYHttpPoster requestAddSeeMeDataWithParameters:@{@"userId":[CommonTool getUserID],@"userSex":[CommonTool getUserSex]} Block:^(NSArray *arr) {
//        
//    }];
//}
//-(void)creatAlterView{
//    
//    
//    [self.alterView removeFromSuperview];
//
//   [[UIApplication sharedApplication].keyWindow addSubview:self.alterView];
//
//    [self.alterView creatTypeUser:alterViewtypeUser] ;
//   
//}
////获取数据
//-(void)isGetFuli:(NSString *)userSex{
//    WS(weakSelf)
//    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/login/loginReward",REQUESTHEADER] andParameter:@{@"userId":[CommonTool getUserID]} success:^(id successResponse) {
//    
//       
//        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
//            
//            if ([[NSString stringWithFormat:@"%@",successResponse[@"data"]] isEqualToString:@"0"]) {
//                  alterViewtypeUser = @"0";
//                [weakSelf creatAlterView];
//              
//                #pragma mark 新用户标志符存入本地
//                NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
//                [user setObject:alterViewtypeUser forKey:@"alterViewtypeUser"];
//#pragma mark 如果是新用户
//                NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:300 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
//                [[NSRunLoop  currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
//            }else if ([[NSString stringWithFormat:@"%@",successResponse[@"data"]] isEqualToString:@"1"]) {
//                alterViewtypeUser = @"1";
//                [weakSelf creatAlterView];
//                NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
//                [user setObject:alterViewtypeUser forKey:@"alterViewtypeUser"];
//
//               
//            }else{
//                NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
//                [user setObject:@"" forKey:@"alterViewtypeUser"];
//            }
//           
//        }else{
//            [MBProgressHUD showSuccess:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
//            NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
//            [user setObject:@"" forKey:@"alterViewtypeUser"];
//        }
//        
//    } andFailure:^(id failureResponse) {
//        [MBProgressHUD showError:@"服务器繁忙,请重试"];
//        NSLog(@"失败:%@",failureResponse);
//        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
//        [user setObject:@"" forKey:@"alterViewtypeUser"];
//    }];
//    
//}
//

- (void)addRefresh{
    currentPage2 = 1;
    // 1.下拉刷新(进入刷新状态就会调用self的headerRereshing)
    _myTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefreshing)];
    
    // 2.上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    _myTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRefreshing)];
    
}

#pragma mark   --下拉刷新
- (void)headerRefreshing{
    
    
    currentPage2 = 1;
    MJRefreshStateHeader *header = (MJRefreshStateHeader *) _myTableView.mj_header;
    [header setTitle:@"下拉可以刷新" forState:MJRefreshStateIdle];
    [header setTitle:@"松开马上刷新" forState:MJRefreshStatePulling];
    [header setTitle:@"刷新中" forState:MJRefreshStateRefreshing];
    if (self.scrollImageArr.count == 0) {
        [self getData];
    }
    [self  getAppointDataIsupdData];
   [_myTableView.mj_header endRefreshing];
}
#pragma mark  -----下方约的数据
- (void)getAppointDataIsupdData{
    
    
    NSDictionary *dic = @{@"userId":[CommonTool getUserID],@"pageNum":[NSString stringWithFormat:@"%ld",(long)currentPage2],@"dateTypeId":typeId,@"arrayType":self.arrayType,@"userSex":self.userSex,@"provinceId":distriId,@"cityId":cityId,@"districtId":distriId,@"dateLongitude":longitude,@"dateLatitude":latitude};
//        NSDictionary *dic = @{@"userId":[CommonTool getUserID],@"pageNum":[NSString stringWithFormat:@"%ld",(long)currentPage2],@"dateTypeId":typeId};


      [ LYHttpPoster requestAppointContentDataWithParameters:dic Block:^(NSArray *arr) {
          if (arr == nil) {
             
              return ;
          }else{
        [self.dateTypeArr removeAllObjects];
        [self.dateTypeArr addObjectsFromArray:arr];
        //        [self appointContent];
          NSLog(@"arr---%@",arr);
      
        [_myTableView reloadData];
   
          }
    }];
   
    
}




#pragma mark   ---上拉刷新
- (void)footerRefreshing{
    
    //[MBProgressHUD showMessage:@"加载中" toView:self];
    
    //    NSInteger page = 1;
    currentPage2++;
    //    page = currentPage2;
    
    //    NSInteger page=currentPage2++;
    //DLK 内存泄漏修改
//    NSString *time;
    if (self.dateTypeArr.count != 0) {
        appointModel *model = self.dateTypeArr[0];
        if (model) {
            currentTime = model.createTimestamp;
            
        }
    }
    
  
//    NSDictionary *dic = @{@"userId":[CommonTool getUserID],@"pageNum":[NSString stringWithFormat:@"%ld",(long)currentPage2],@"dateTypeId":typeId,@"arrayType":self.arrayType,@"userSex":self.userSex,@"provinceId":distriId,@"cityId":cityId,@"districtId":distriId};
    NSDictionary *dic = @{@"userId":[CommonTool getUserID],@"pageNum":[NSString stringWithFormat:@"%ld",(long)currentPage2],@"dateTypeId":typeId,@"createTime": currentTime,@"arrayType":self.arrayType,@"userSex":self.userSex,@"provinceId":distriId,@"cityId":cityId,@"districtId":distriId,@"dateLongitude":longitude,@"dateLatitude":latitude};
    [ LYHttpPoster requestAppointContentDataWithParameters:dic Block:^(NSArray *arr) {
        if (arr == nil) {
            currentPage2 --;
            return ;
        }else{
        [self.dateTypeArr addObjectsFromArray:arr];
        
        [_myTableView reloadData];
        
       
        
        if (arr.count == 0) {
               currentPage2 --;
             [MBProgressHUD showSuccess:@"已经到底啦"];
        }
        
                    
        }
               
    }];

//    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/date/getDate",REQUESTHEADER] andParameter:@{@"userId":[CommonTool getUserID],@"pageNum":[NSString stringWithFormat:@"%d",(int)currentPage2],@"createTime":time} success:^(id successResponse) {
//        NSLog(@"上拉刷新%@",successResponse);
//        NSLog(@"上拉刷新%@",successResponse[@"errorMsg"]);
//        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
//            
//            
//            
//            [MBProgressHUD hideHUD];
//            [_myTableView reloadData];
//            [MBProgressHUD showSuccess:@"已经到底啦"];
//            
//            
//        }
//        
//    } andFailure:^(id failureResponse) {
//        
//        [MBProgressHUD hideHUD];
//        [MBProgressHUD showError:@"请检查您的网络"];
//    }];
    
     [_myTableView.mj_footer endRefreshing];
}

#pragma mark   ----push通知
- (void)pushNotification:(NSNotification *)noti{
    
    if ([[noti.userInfo objectForKey:@"push"] isEqualToString:@"otherZhuYeVC"]) {
        otherZhuYeVC *other = [[otherZhuYeVC alloc]init];
        other.userNickName = [noti.userInfo objectForKey:@"nickName"];
        other.userId = [noti.userInfo objectForKey:@"otherId"];    //别人ID
        [self.navigationController pushViewController:other animated:YES];
    }
    

    
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"push" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"reloadUIData" object:nil];
}


#pragma mark   -----------获取上方约会类型的图片  文字
- (void)getData
{
  
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/cache/getDateType",REQUESTHEADER] andParameter:nil success:^(id successResponse) {
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            [self.scrollImageArr removeAllObjects];
            [self.labelNameArr removeAllObjects];
            [self.labelIdArr removeAllObjects];
            [self.selelcImageArr removeAllObjects];
       //  NSLog(@"约会类型00000000000000000000%@",successResponse);
            NSArray *dataArr = successResponse[@"data"];
            for (NSDictionary *dic in dataArr) {
                NSString *imageStr = dic[@"dateTypeIcon"];
                //用七牛请求头把图片名字转换成图片的url
                NSURL *imageUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,imageStr]];
                //图片Url数组
                [self.scrollImageArr addObject:imageUrl];
                NSString *nameStr = dic[@"dateTypeName"];
               NSString *tyId = dic[@"dateTypeId"];
              
                [self.labelNameArr addObject:nameStr];
                [self.labelIdArr addObject:tyId];
                
                
                //选中后的图片
               NSString *str = @"_unselected";
                
                NSString *afterStr = [imageStr stringByReplacingOccurrencesOfString:str withString:@""];
                NSURL *seleUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,afterStr]];
               
                [self.selelcImageArr addObject:seleUrl];
            }
            
            [self createScroll];
            
        }
    } andFailure:^(id failureResponse) {
        }];
}


#pragma mark  ---------最上方的轮播图 ------
- (void)removeAllSubViews
{
    for (UIScrollView *subView in self.view.subviews)
    {
        [subView removeFromSuperview];
    }
}
- (void)createScroll{
    [topScroll removeFromSuperview];
    topScroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 56*AutoSizeScaleX)];
    topScroll.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:topScroll];
    
    UILabel *lineLabel = [[UILabel alloc]init];
    lineLabel.frame = CGRectMake(0, 56*AutoSizeScaleX-1, SCREEN_WIDTH, 1);
    lineLabel.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];
    [topScroll addSubview:lineLabel];
    
    topScroll.contentSize = CGSizeMake(64*AutoSizeScaleX*(self.scrollImageArr.count+1), 0);
    
    for (NSInteger i =0 ; i<self.scrollImageArr.count; i++)
    {
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(28*AutoSizeScaleX+(68*AutoSizeScaleX)*i,10*AutoSizeScaleX, 30*AutoSizeScaleX, 56*AutoSizeScaleX)];
//        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(10+64*i,10, 64, 56)];
//       [btn setBackgroundImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:self.scrollImageArr[i]]] forState:UIControlStateNormal];
//       [btn setBackgroundImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:self.selelcImageArr[i]]]  forState:UIControlStateSelected];
        btn.tag = 1000+i;
        [btn addTarget:self action:@selector(changeType:) forControlEvents:UIControlEventTouchUpInside];
        [topScroll addSubview:btn];
        
        UIImageView *ImageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 30*AutoSizeScaleX, 30*AutoSizeScaleX)];
        ImageView.image=[[UIImage alloc]initWithData:[NSData dataWithContentsOfURL:self.scrollImageArr[i]]];
        ImageView.tag=5000+i;
        
        [btn addSubview:ImageView];
        
        
        
        if (i==0)
        {
             ImageView.image=[[UIImage alloc]initWithData:[NSData dataWithContentsOfURL:self.selelcImageArr[i]]];
            btn.selected = YES;
            _lastBtn = btn;
//           _bestNewTable  = [[newTableView alloc]initWithFrame:CGRectMake(0, 56, SCREEN_WIDTH, SCREEN_HEIGHT-56)];
//            [self.view addSubview:_bestNewTable];
//            _bestNewTable.yueHuiID = self.labelIdArr[0];
//            currentView = _bestNewTable;
            typeId = self.labelIdArr[0];
            
            if ([CommonTool dx_isNullOrNilWithObject:self.placeId] ) {
                self.placeId = @",,";
            }
            
            NSArray *plaIdArr = [self.placeId componentsSeparatedByString:@","];
            if (plaIdArr.count==3) {
                provinceId = plaIdArr[0];
                cityId = plaIdArr[1];
                distriId = plaIdArr[2];
            }else{
                provinceId = plaIdArr[0];
                cityId = plaIdArr[1];
                distriId = @"0";
            }
            
//            [self getAppointDataIsupdData];
        }
        
        
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 33*AutoSizeScaleX, 30*AutoSizeScaleX, 10*AutoSizeScaleX)];
       
        label.text = [NSString stringWithFormat:@"%@",self.labelNameArr[i]];
        label.textColor = [UIColor colorWithHexString:@"#757575"];
        label.font =[UIFont fontWithName:@"PingFangSC-Light" size:12*AutoSizeScaleX];
        label.tag = 2000+i;
        [topScroll addSubview:label];
        if (label.tag == 2000)
        {
            label.textColor = [UIColor colorWithHexString:@"#ff5252"];
            _lastLabel = label;
        }
        
//        label.center = CGPointMake(btn.frame.origin.x+btn.frame.size.width/2.0,50);
//        label.bounds = CGRectMake(0, 0, btn.frame.size.width, 10);
        label.textAlignment = NSTextAlignmentCenter;
        [btn addSubview:label];
       
    }
}



- (void)changeType:(UIButton *)sender{
    
    if (sender == _lastBtn)
    {
        return;
    }
    
    UIImageView *LastImageView=[self.view viewWithTag:_lastBtn.tag+4000];
    LastImageView.image=[[UIImage alloc]initWithData:[NSData dataWithContentsOfURL:self.scrollImageArr[_lastBtn.tag-1000]]];
    
    
    sender.selected = YES;
    _lastBtn.selected = NO;
    _lastBtn = sender;
    
    UILabel *label = [topScroll viewWithTag:sender.tag+1000];
    label.textColor = [UIColor colorWithHexString:@"#ff5252"];
    _lastLabel.textColor = [UIColor colorWithHexString:@"#757575"];
    _lastLabel = label;
    
    UIImageView *ImageView=[self.view viewWithTag:sender.tag+4000];
    ImageView.image=[[UIImage alloc]initWithData:[NSData dataWithContentsOfURL:self.selelcImageArr[sender.tag-1000]]];
    
    typeId = [NSString  stringWithFormat:@"%@",self.labelIdArr[sender.tag - 1000]];
    currentPage2 = 1;
    [self  getAppointDataIsupdData];
////    if (sender.tag ==1000) {
////        if (!_bestNewTable) {
//   [currentView removeFromSuperview];
//            _bestNewTable =[[newTableView alloc]initWithFrame:CGRectMake(0, 56, SCREEN_WIDTH, SCREEN_HEIGHT-56)];
////        }
//     _bestNewTable.yueHuiID = [NSString  stringWithFormat:@"%@",self.labelIdArr[sender.tag - 1000]];
//    
//        [self.view addSubview:_bestNewTable];
//        currentView = _bestNewTable;
//    }
    
//    if (sender.tag ==1000) {
//        if (!_bestNewTable) {
//          _bestNewTable =[[newTableView alloc]initWithFrame:CGRectMake(0, 56, SCREEN_WIDTH, SCREEN_HEIGHT-56)];
//        }
//        [currentView removeFromSuperview];
//        [self.view addSubview:_bestNewTable];
//         currentView = _bestNewTable;
//    }
//    
//    if (sender.tag == 1001) {
//        if (!_travel) {
//        _travel =[[travalTableView alloc]initWithFrame:CGRectMake(0, 56, SCREEN_WIDTH, SCREEN_HEIGHT-56)];
//                    }
//          [currentView removeFromSuperview];
//            [self.view addSubview:_travel];
//            currentView = _travel;
//        
//        }
//    
//    if (sender.tag == 1002) {
//        if (!_eat) {
//            _eat =[[eatTableView alloc]initWithFrame:CGRectMake(0, 56, SCREEN_WIDTH, SCREEN_HEIGHT-56)];
//                    }
//             [currentView removeFromSuperview];
//            [self.view addSubview:_eat];
//            currentView = _eat;
//    }
//    
//    
//    if (sender.tag == 1003) {
//        if (!_movie) {
//            _movie =[[movieTableView alloc]initWithFrame:CGRectMake(0, 56, SCREEN_WIDTH, SCREEN_HEIGHT-56)];
//        }
//        [currentView removeFromSuperview];
//        [self.view addSubview:_movie];
//        currentView = _movie;
//    }
//    
//    if (sender.tag == 1004) {
//        if (!_ktv) {
//            _ktv =[[ktvTableView alloc]initWithFrame:CGRectMake(0, 56, SCREEN_WIDTH, SCREEN_HEIGHT-56)];
//        }
//        [currentView removeFromSuperview];
//        [self.view addSubview:_ktv];
//         currentView = _ktv;
//    }
//    if (sender.tag == 1005) {
//        if (!_exercise) {
//            _exercise =[[exerciseTableView alloc]initWithFrame:CGRectMake(0, 56, SCREEN_WIDTH, SCREEN_HEIGHT-56)];
//        }
//        [currentView removeFromSuperview];
//        [self.view addSubview:_exercise];
//        currentView = _exercise;
//    }
//    
//    if (sender.tag == 1006) {
//        if (!_marry) {
//            _marry =[[marryTableView alloc]initWithFrame:CGRectMake(0, 56, SCREEN_WIDTH, SCREEN_HEIGHT-56)];
//        }
//        [currentView removeFromSuperview];
//        [self.view addSubview:_marry];
//        currentView = _marry;
//    }
//    
//    
//    if (sender.tag == 1007) {
//        if (!_shop) {
//           _shop =[[shopTableView alloc]initWithFrame:CGRectMake(0, 56, SCREEN_WIDTH, SCREEN_HEIGHT-56)];
//        }
//        [currentView removeFromSuperview];
//        [self.view addSubview:_shop];
//        currentView = _shop;
//    }
//    
//    if (sender.tag == 1008) {
//        if (!_other) {
//            _other =[[otherTableView alloc]initWithFrame:CGRectMake(0, 56, SCREEN_WIDTH, SCREEN_HEIGHT-56)];
//        }
//        [currentView removeFromSuperview];
//        [self.view addSubview:_other];
//        currentView = _other;
//    }
//    
}


//#pragma mark  ---时间转化时间戳
//- (void)transformTimeChuo:(NSString *)time{
//    
//    NSDateFormatter *fom = [[NSDateFormatter alloc]init];
//    [fom setDateStyle:NSDateFormatterMediumStyle];
//    [fom setTimeStyle:NSDateFormatterShortStyle];
//    [fom setDateFormat:@"YYYY-MM-dd"];
//    NSTimeZone *zone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
//    [fom setTimeZone:zone];
//    
//    NSDate *date = [fom dateFromString:time];
//    NSInteger timeSp = [[NSNumber numberWithDouble:[date timeIntervalSince1970]] integerValue]*1000;
//   // NSLog(@"33333333333333333333333333333333333333时间戳:%ld",(long)timeSp);
//}


#pragma mark   ---------- 计算时间间隔---------
- (NSString *)dateTimeDifferenceWithStartTime:(NSString *)startTime endTime:(NSString *)endTime{
    
    NSDateFormatter *date = [[NSDateFormatter alloc]init];
    [date setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *startD = [date dateFromString:startTime];
    NSDate *endD = [date dateFromString:endTime];
    
    NSTimeInterval start = [startD timeIntervalSince1970]*1;
    NSTimeInterval end = [endD timeIntervalSince1970]*1;
    NSTimeInterval value = end - start;
    
    
    int second = (int)value %60;//秒
    int minute = (int)value /60%60;
    int house = (int)value / (24 * 3600)%3600;
    int day = (int)value / (24 * 3600);
    NSString *str;
    if (day != 0) {
        str = [NSString stringWithFormat:@"耗时%d天%d小时%d分%d秒",day,house,minute,second];
    }else if (day==0 && house != 0) {
        str = [NSString stringWithFormat:@"耗时%d小时%d分%d秒",house,minute,second];
    }else if (day== 0 && house== 0 && minute!=0) {
        str = [NSString stringWithFormat:@"耗时%d分%d秒",minute,second];
    }else{
        str = [NSString stringWithFormat:@"耗时%d秒",second];
    }
    return str;
    
    
    
    
}




- (void)createNavigationView {
    
    //导航栏背景颜色
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:@"#ffffff"];
    
    //导航栏字体颜色
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#ff5252"],NSFontAttributeName:[UIFont systemFontOfSize:18]};
    
    //定位按钮
    localeBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    localeBtn.frame = CGRectMake(16, 38, 60,40);
    [localeBtn setTitle:@"杭州" forState:UIControlStateNormal];
    localeBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [localeBtn setTitleColor:[UIColor colorWithHexString:@"#424242"] forState:UIControlStateNormal];
    [localeBtn addTarget:self action:@selector(locale:) forControlEvents:UIControlEventTouchUpInside];
    
     UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:localeBtn];
    
    self.navigationItem.leftBarButtonItem = leftItem;
    
    //中间约会吧
    UIView *titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0,91, 30)];
    UIImageView *heartImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 4, 20, 18)];
    heartImage.image = [UIImage imageNamed:@"m_liked"];
    [titleView addSubview:heartImage];
    UILabel *yueLabel = [[UILabel alloc]initWithFrame:CGRectMake(21, 0, 70, 25)];
    yueLabel.text = @"约会吧";
    yueLabel.font = [UIFont systemFontOfSize:18];
    yueLabel.textColor = [UIColor colorWithHexString:@"#ff5252"];
    [titleView addSubview:yueLabel];
    self.navigationItem.titleView = titleView;
    

    
    //右上角筛选按钮
    UIButton *selectBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 25)];
    [selectBtn setImage:[UIImage imageNamed:@"filter"] forState:UIControlStateNormal];
    [selectBtn addTarget:self action:@selector(select:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:selectBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    
   
}

//筛选
- (void)select:(UIButton *)sender{
    
       SearchNearbyViewController *nextV = [[SearchNearbyViewController alloc] init];
   
    
    __weak __typeof(self)weakSelf = self;
    [nextV shaiXuanText:^(NSString *placeId, NSString *arrayType, NSString *userSex) {
        weakSelf.placeId = placeId;
        weakSelf.arrayType = arrayType;
        weakSelf.userSex = userSex;
        if (self.placeId.length == 0) {
            self.placeId = @",,";
        }
      
       NSArray *plaIdArr = [self.placeId componentsSeparatedByString:@","];
        if (plaIdArr.count==3) {
            provinceId = plaIdArr[0];
            cityId = plaIdArr[1];
            distriId = plaIdArr[2];
        }else{
            provinceId = plaIdArr[0];
            cityId = plaIdArr[1];
            distriId = @"0";
        }
//
        [self getAppointDataIsupdData];
        //
        
        
    }];
        
     
        nextV.latitude                    = latitude;
        nextV.longitude                   = longitude;
        [self.navigationController pushViewController:nextV animated:YES];
  

    
}

// 点击定位
- (void)locale:(UIButton *)sender{
    
    

    [self.clManager startUpdatingLocation];
}

#pragma mark - CoreLocation Delegate

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    


    //此处locations存储了持续更新的位置坐标值，取最后一个值为最新位置，如果不想让其持续更新位置，则在此方法中获取到一个值之后让locationManager stopUpdatingLocation
    CLLocation *currentLocation = [locations lastObject];
    latitude = [NSString stringWithFormat:@"%f",currentLocation.coordinate.latitude];
    longitude = [NSString stringWithFormat:@"%f",currentLocation.coordinate.longitude];
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


#pragma mark 代理方法返回反地理编码结果
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error{
    
    if (result) {
        currentCity = [NSString stringWithFormat:@"%@", result.addressDetail.city];
        currentProvince = [NSString stringWithFormat:@"%@", result.addressDetail.province];
        if ([[NSString stringWithFormat:@"%@", currentCity] isEqualToString:@"天津市"]) {
            currentCity = @"";
        }
        if ([[NSString stringWithFormat:@"%@", currentCity] isEqualToString:@"上海市"]) {
            currentCity = @"";
        }
        if ([[NSString stringWithFormat:@"%@", currentCity] isEqualToString:@"北京市"]) {
            currentCity = @"";
        }
        if ([[NSString stringWithFormat:@"%@", currentCity] isEqualToString:@"重庆市"]) {
            currentCity = @"";
        }
       
        currentDistrict = [NSString stringWithFormat:@"%@", result.addressDetail.district];

        [localeBtn setTitle:currentCity forState:UIControlStateNormal];
        
    }else{
        currentCity = @"定位失败";
    }
}
//设置cell的高度
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
   appointModel *model = [self.dateTypeArr objectAtIndex:indexPath.row];
    
//    CGFloat height = [heightCalculator heightForCalculateheightModel:model];
//    if (height>0) {
//        NSLog(@"cache height");
//        return height;
//    }else{
//        NSLog(@"calculate height");
//    }
//    AppointTableCell *cell = self.appointTableCell;
//    cell.contentView.translatesAutoresizingMaskIntoConstraints = NO;
//    [self configureCell:cell atIndexPath:indexPath];//必须先对Cell中的数据进行配置使动态计算时能够知道根据Cell内容计算出合适的高度
//    
//    /*------------------------------重点这里必须加上contentView的宽度约束不然计算出来的高度不准确-------------------------------------*/
//    CGFloat contentViewWidth = CGRectGetWidth(self.myTableView.bounds);
//    NSLayoutConstraint *widthFenceConstraint = [NSLayoutConstraint constraintWithItem:cell.contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:contentViewWidth];
//    [cell.contentView addConstraint:widthFenceConstraint];
//    // Auto layout engine does its math
//    CGFloat fittingHeight = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
//    [cell.contentView removeConstraint:widthFenceConstraint];
//    /*-------------------------------End------------------------------------*/
//    
//    return fittingHeight+2*1/[UIScreen mainScreen].scale;//必须加上上下分割线的高度
    return model.cellHeight;
   // return 567;
}
//#pragma mark Configure Cell Data
//- (void)configureCell:(AppointTableCell *)cell atIndexPath:(NSIndexPath *)indexPath {
//    
//    cell.model = [self.dateTypeArr objectAtIndex:indexPath.row];
//}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
   
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.dateTypeArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AppointTableCell* cell = [tableView dequeueReusableCellWithIdentifier:@"AppointTableCell" forIndexPath:indexPath];
  
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    [self configureCell:cell atIndexPath:indexPath];
//    cell.preservesSuperviewLayoutMargins = NO;
//    cell.separatorInset = UIEdgeInsetsZero;
//    cell.layoutMargins = UIEdgeInsetsZero;
    appointModel *aModel = self.dateTypeArr[indexPath.row];
    if (aModel) {
        
        
        for (UIView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
            
        }
        
        [cell createCell:aModel placeName:[NSString stringWithFormat:@"%@%@%@",currentProvince,currentCity,currentDistrict]];
       
       
     
        //聊天
        cell.chatBtn.tag = 1000+indexPath.row;
        [cell.chatBtn addTarget:self action:@selector(chat:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    

    //self.height = cell.height;
    return  cell;
}
#pragma mark  ---对约会感兴趣
//- (void)instred:(UIButton *)sender{
//    
//    //  NSString *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userId"];
//    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/date/addInterestDate",REQUESTHEADER] andParameter:@{@"userId":@"1000006",@"dateActivityId":@"1",@"otherUserId":@"1000001"} success:^(id successResponse) {
//        
//        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
//            [MBProgressHUD showSuccess:@"感兴趣成功"];
//        }
//        
//    } andFailure:^(id failureResponse) {
//        
//    }];
//    
//    
//    
//}

#pragma mark  --聊天
- (void)chat:(UIButton *)sender{
    
     appointModel *aModel = self.dateTypeArr[sender.tag-1000];
    if ([[NSString stringWithFormat:@"%@",aModel.otherId]  isEqualToString:[CommonTool getUserID]]) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode =MBProgressHUDModeText;//显示的模式
        hud.labelText = @"不能跟自己聊天哦～";
        [hud hide:YES afterDelay:1];
        //设置隐藏的时候是否从父视图中移除，默认是NO
        hud.removeFromSuperViewOnHide = YES;
       
        return;
    }else{
    ChatViewController *chatController = [[ChatViewController alloc] initWithChatter:[NSString stringWithFormat:@"qp%@",aModel.otherId]  isGroup:NO] ;
    chatController.isContactsList2Chat = NO;
    chatController.title = aModel.nickName;
//        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
//        [user setObject:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,aModel.headImage] forKey:@"otherUserIcon"];
//         [user setObject:[NSString stringWithFormat:@"%@",aModel.nickName] forKey:@"otherUserNickname"];
    [self.navigationController pushViewController:chatController animated:YES];
       
        [self buyyFmdb:sender.tag-1000];
    }
}


//#pragma mark  ---获取个人信息
//- (void)getPersonalInfo{
//    
//    // NSString *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userId"];
//    
//    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/getPersonalInfo",REQUESTHEADER] andParameter:@{@"userId":[CommonTool getUserID]} success:^(id successResponse) {
//        
//         NSLog(@"0000000000000我的资料:%@",successResponse);
//        
//        
//        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
//            
//            NSDictionary *dataDic = successResponse[@"data"];
//            [self saveToUserDefault:dataDic];
//             [self  isGetFuli:[NSString stringWithFormat:@"%@",successResponse[@"data"][@"userSex"]]];
//        }else{
//            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
//        }
//        
//    } andFailure:^(id failureResponse) {
//        [MBProgressHUD showError:@"服务器繁忙,请重试"];
//        NSLog(@"失败:%@",failureResponse);
//    }];
//    
//}

////#pragma mark   ---保存用户信息到本地
//- (void)saveToUserDefault:(NSDictionary *)userDict {
//    @synchronized (self) {
//        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
//        [user setObject:[NSString stringWithFormat:@"%@",userDict[@"userId"]] forKey:@"userId"];
//        [user setObject:[NSString stringWithFormat:@"%@",userDict[@"userNickname"]] forKey:@"userNickname"];
//        [user setObject:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,userDict[@"userIcon"]] forKey:@"userIcon"];
//       [user setObject:[NSString stringWithFormat:@"%@",userDict[@"userSex"]] forKey:@"userSex"];
//        [user setObject:[NSString stringWithFormat:@"%@",userDict[@"vipLevel"]] forKey:@"vipLevel"];
//      
//    }
//    
//    
//    
//}

-(void)buyyFmdb:(NSInteger )tag{
    [kAppDelegate.dataBaseQueue inDatabase:^(FMDatabase *db) {
        //如果数据库打开成功
        if ([kAppDelegate.dataBase open]) {
            appointModel *model = self.dateTypeArr[tag];
            NSString *huanxinUserId = [NSString stringWithFormat:@"qp%@",model.otherId];
//            for (MyBuddyModel *model in self.dateTypeArr) {
                //如果用户模型在本地数据库表中没有，则插入，否则更新
                NSString *findSql = [NSString stringWithFormat:@"SELECT * FROM '%@' WHERE userID = '%@'",@"User",huanxinUserId];
                FMResultSet *result = [kAppDelegate.dataBase executeQuery:findSql];
                if ([result resultCount]) { //如果查询结果有数据
                    //更新对应数据
                    NSString *updateSql = [NSString stringWithFormat:@"UPDATE '%@' SET name = '%@',remark = '%@',icon = '%@' WHERE userID = '%@'",@"User",model.nickName,model.remark,[NSString stringWithFormat:@"%@%@",IMAGEHEADER,model.headImage],huanxinUserId];
                    BOOL isSuccess = [kAppDelegate.dataBase executeUpdate:updateSql];
                    if (isSuccess) {
                        MLOG(@"更新数据成功!");
                    } else {
                        MLOG(@"更新数据失败!");
                    }
                } else { //如果查询结果没有数据
                    //插入相应数据
                    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO '%@'('%@','%@','%@','%@') VALUES('%@','%@','%@','%@')",@"User",@"userID",@"name",@"remark",@"icon",huanxinUserId,model.nickName,model.remark,[NSString stringWithFormat:@"%@%@",IMAGEHEADER,model.headImage]];
                    BOOL isSuccess = [kAppDelegate.dataBase executeUpdate:insertSql];
                    if (isSuccess) {
                        MLOG(@"插入数据成功!");
                    } else {
                        MLOG(@"插入数据失败!");
                    }
                }
//            }
            [kAppDelegate.dataBase close];
        } else {
            MLOG(@"\n本地数据库更新失败\n");
        }
    }];

}
//#pragma mark   ----------时间戳转换成时间
//- (NSString *)transformTime:(NSString *)time{
//
//    NSInteger num = [time integerValue]/1000;
//
//    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
//    [formatter setDateStyle:NSDateFormatterMediumStyle];
//    [formatter setTimeStyle:NSDateFormatterShortStyle];
//    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
//    
//    NSDate *contime = [NSDate dateWithTimeIntervalSince1970:num];
//    NSString *conTimeStr = [formatter stringFromDate:contime];
//    
//    return conTimeStr;    //2016-11-21-55
//    
//}

@end
