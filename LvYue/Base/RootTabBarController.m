//
//  RootTabBarController.m
//  LvYue
//
//  Created by apple on 15/9/28.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import "DialogueViewController.h"
#import "FriendsCirleViewController.h"
#import "LYHomeViewController.h"
#import "LYMeViewController.h"
#import "LYUserService.h"
#import "MeController.h"
#import "NewHomeViewController.h"
#import "RootNavigationController.h"
#import "RootTabBarController.h"
#import "SearchViewController.h"
#import "SendAppointViewController.h"

#import "DynamicViewController.h"
#import "MyUITabBar.h"
#import "CallViewController.h"
#import "CallViewController.h"
#import "EMCDDeviceManager.h"
#import "AlterGivingView.h"
@interface RootTabBarController () <UITabBarControllerDelegate, UITabBarDelegate,RoundButtonDelegate
,EMChatManagerDelegate,EMCallManagerDelegate, EMCDDeviceManagerDelegate> {
    //记录上一次点击的索引
    NSInteger selectedIndex;
    
    UIViewController *currentVC;
    NSString *alterViewtypeUser;
    
      int _time;
}
@property (nonatomic, strong) AlterGivingView *alterView ;
@end

@implementation RootTabBarController
-(AlterGivingView *)alterView {
    if (!_alterView) {
        _alterView  = [[AlterGivingView alloc]init];
        _alterView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        _alterView.backgroundColor = RGBA(1, 1, 1, 0.1);
    }
    return _alterView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
//    MyUITabBar *tabbar = [[MyUITabBar alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
//    tabbar.myDelegate = self;
//    //修改系统的Tabbar，使用我们自定义的Tabbar
//    [self setValue:tabbar forKeyPath:@"tabBar"];
//    self.delegate = self;

     _time = 0;//定时器执行次数
    [self initWithNavs];
    
    [self registerEaseMobNotification];
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callControllerClose:) name:@"callControllerClose" object:nil];
      [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"isNoShowCallViewAgain"];//默认打开实时语音界面
    
     [self cacheLogin];
    [self checkVersion];
}

//push通知
- (void)cacheLogin {
    NSLog(@"userId--%@--",[CommonTool getUserID]);
    NSLog(@"getUserCaptcha--%@--",[CommonTool getUserCaptcha]);
    NSLog(@"kAppDelegate.deviceToken--%@--",kAppDelegate.deviceToken);
    WS(weakSelf)
    NSDictionary *dic = @{@"userId":[CommonTool getUserID],@"userCaptcha":[CommonTool getUserCaptcha],@"deviceType":@"1",@"deviceToken":[CommonTool getDeviceToken]};
    
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/login/cacheLogin",REQUESTHEADER] andParameter:dic success:^(id successResponse) {
#pragma mark  ---获取个人信息
        [weakSelf getPersonalInfo];
    } andFailure:^(id failureResponse) {
#pragma mark  ---获取个人信息
        [weakSelf getPersonalInfo];
    }];
    
}


#pragma mark  ---获取个人信息
- (void)getPersonalInfo{
    
    // NSString *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userId"];
    
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/getPersonalInfo",REQUESTHEADER] andParameter:@{@"userId":[CommonTool getUserID]} success:^(id successResponse) {
        
        NSLog(@"0000000000000我的资料:%@",successResponse);
        
        
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            
            NSDictionary *dataDic = successResponse[@"data"];
            [self saveToUserDefault:dataDic];
            [self  isGetFuli:[NSString stringWithFormat:@"%@",successResponse[@"data"][@"userSex"]]];
        }else{
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
        }
        
    } andFailure:^(id failureResponse) {
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
        NSLog(@"失败:%@",failureResponse);
    }];
    
}
//获取数据
-(void)isGetFuli:(NSString *)userSex{
    WS(weakSelf)
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/login/loginReward",REQUESTHEADER] andParameter:@{@"userId":[CommonTool getUserID]} success:^(id successResponse) {
        
        
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            
            if ([[NSString stringWithFormat:@"%@",successResponse[@"data"]] isEqualToString:@"0"]) {
                alterViewtypeUser = @"0";
                [weakSelf creatAlterView];
                
#pragma mark 新用户标志符存入本地
                NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
                [user setObject:alterViewtypeUser forKey:@"alterViewtypeUser"];
#pragma mark 如果是新用户
                NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:300 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
                [[NSRunLoop  currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
            }else if ([[NSString stringWithFormat:@"%@",successResponse[@"data"]] isEqualToString:@"1"]) {
                alterViewtypeUser = @"1";
                [weakSelf creatAlterView];
                NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
                [user setObject:alterViewtypeUser forKey:@"alterViewtypeUser"];
                
                
            }else{
                NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
                [user setObject:@"" forKey:@"alterViewtypeUser"];
            }
            
        }else{
            [MBProgressHUD showSuccess:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
            NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
            [user setObject:@"" forKey:@"alterViewtypeUser"];
        }
        
    } andFailure:^(id failureResponse) {
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
        NSLog(@"失败:%@",failureResponse);
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        [user setObject:@"" forKey:@"alterViewtypeUser"];
    }];
    
}


-(void)timerAction:(NSTimer *)timer{
    _time++;
    [self addWhoSeeMe];
    if (_time >=3) {
        [timer invalidate];
        timer = nil;
        
    }
    NSLog(@"_time--%d",_time);
}
-(void)creatAlterView{
    
    
    [self.alterView removeFromSuperview];
    
    [[UIApplication sharedApplication].keyWindow addSubview:self.alterView];
    
    [self.alterView creatTypeUser:alterViewtypeUser] ;
    
}


-(void)addWhoSeeMe{
    [LYHttpPoster requestAddSeeMeDataWithParameters:@{@"userId":[CommonTool getUserID],@"userSex":[CommonTool getUserSex]} Block:^(NSArray *arr) {
        
    }];
}

//#pragma mark   ---保存用户信息到本地
- (void)saveToUserDefault:(NSDictionary *)userDict {
    @synchronized (self) {
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        [user setObject:[NSString stringWithFormat:@"%@",userDict[@"userId"]] forKey:@"userId"];
        [user setObject:[NSString stringWithFormat:@"%@",userDict[@"userNickname"]] forKey:@"userNickname"];
        [user setObject:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,userDict[@"userIcon"]] forKey:@"userIcon"];
        [user setObject:[NSString stringWithFormat:@"%@",userDict[@"userSex"]] forKey:@"userSex"];
        [user setObject:[NSString stringWithFormat:@"%@",userDict[@"vipLevel"]] forKey:@"vipLevel"];
        
    }
    
    
    
}

-(void)checkVersion
{
    //获取本地软件的版本号
    NSString *localVersion = [[[NSBundle mainBundle]infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/cache/getIosVersion",REQUESTHEADER] andParameter:@{@"iosVersion":localVersion} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            if ([[NSString stringWithFormat:@"%@",successResponse[@"data"]] isEqualToString:@"1"]) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"升级提示"message:@"发现新版本" preferredStyle:UIAlertControllerStyleAlert];
                
                [self presentViewController:alert animated:YES completion:nil];
                
                
                
                
                [alert addAction:[UIAlertAction actionWithTitle:@"现在升级" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/us/app/id1064840775"]];//http://114.215.184.120:8088/mobile/shareApp.html 下载地址
                    // http://itunes.apple.com/us/app/id1064840775           NSLog(@"点击现在升级按钮");
                }]];
                
            }else if ([[NSString stringWithFormat:@"%@",successResponse[@"data"]] isEqualToString:@"2"]) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"升级提示" message:@"发现新版本" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"升级", nil];
                alertView.tag = 1002;
                [alertView show];
            
            }
            
        } else {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
    
    
    
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1002) {
        if (1 == buttonIndex) {
         
             [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/us/app/id1064840775"]];
        }
    }

}
- (void)callControllerClose:(NSNotification *)notification
{
    //    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    //    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    //    [audioSession setActive:YES error:nil];
    [[EaseMob sharedInstance].callManager removeDelegate:self];
    [[EaseMob sharedInstance].callManager addDelegate:self delegateQueue:nil];
}
#pragma mark - registerEaseMobNotification
- (void)registerEaseMobNotification{
 
#warning 以下三行代码必须写，注册为SDK的ChatManager的delegate
    [EMCDDeviceManager sharedInstance].delegate = self;
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
    //注册为SDK的ChatManager的delegate
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];//这是会话管理者,获取该对象后, 可以做登录、聊天、加好友等操作
    
    // 当离开这个页面的时候,要讲代理取消掉,不然会造成别的页面接收不了消息.
    [[EaseMob sharedInstance].callManager removeDelegate:self];
    [[EaseMob sharedInstance].callManager addDelegate:self delegateQueue:nil];//最后一个为即时通讯的代理,(即时视频,即时语音)
}


#pragma mark - ICallManagerDelegate
#pragma mark - ICallManagerDelegate
#pragma mark  接收到视频请求的时候,视频这里开始
/*!
 @method
 @brief 实时通话状态发生变化时的回调
 @param callSession 实时通话的实例
 @param reason   变化原因
 @param error    错误信息
 */
- (void)callSessionStatusChanged:(EMCallSession *)callSession changeReason:(EMCallStatusChangedReason)reason error:(EMError *)error
{
    
   
    if (callSession.status == eCallSessionStatusConnected)
    {
        EMError *error = nil;
        do {
            BOOL isShowPicker = [[[NSUserDefaults standardUserDefaults] objectForKey:@"isShowPicker"] boolValue];
            if (isShowPicker) {
                error = [EMError errorWithCode:EMErrorInitFailure andDescription:NSLocalizedString(@"call.initFailed", @"Establish call failure")];
                break;
            }
            
            if (![self canRecord]) {
                error = [EMError errorWithCode:EMErrorInitFailure andDescription:NSLocalizedString(@"call.initFailed", @"Establish call failure")];
                break;
            }
            
#warning 在后台不能进行视频通话
            if(callSession.type == eCallSessionTypeVideo && ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive || ![CallViewController canVideo])){
                error = [EMError errorWithCode:EMErrorInitFailure andDescription:NSLocalizedString(@"call.initFailed", @"Establish call failure")];
                
                
           //    [self addLocalNotificationWithMessage:callSession andSenderName:callSession.sessionChatter];
                break;
            }
            
            
            
            BOOL isNoShowCallViewAgain = [[[NSUserDefaults standardUserDefaults] objectForKey:@"isNoShowCallViewAgain"] boolValue];
            
            if (!isShowPicker &&  isNoShowCallViewAgain == NO){
                [[EaseMob sharedInstance].callManager removeDelegate:self];
                
                
                CallViewController *callController = [[CallViewController alloc] initWithSession:callSession isIncoming:YES];
                callController.modalPresentationStyle = UIModalPresentationOverFullScreen;
                
                 callController.receivId = [CommonTool getUserID];
                   NSString *NewId = [callSession.sessionChatter substringFromIndex:2];// 由于是环信的id 所以改成用户ID
                   callController.senderId = NewId;
                [self presentViewController:callController animated:NO completion:nil];
             

            }
        } while (0);
        
        if (error) {
            [[EaseMob sharedInstance].callManager asyncEndCall:callSession.sessionId reason:eCallReasonHangup];
            return;
        }
    }
}

////创建本地通知
//- (void)addLocalNotificationWithMessage:(EMCallSession *)callSession andSenderName:(NSString *)senderName {
//    UILocalNotification *notification = [[UILocalNotification alloc] init];
//    //设置触发时间
//    NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
//    notification.fireDate = fireDate;
//    //设置时区
//    notification.timeZone = [NSTimeZone systemTimeZone];
//    //设置重复间隔(0代表不重复)
//    notification.repeatInterval = 0;
// 
// 
//    //聊天内容隐私判断
//#ifdef kChatContentPrivacy
//    notification.alertBody = @"您收到一个视频聊";
//#endif
//    notification.soundName = UILocalNotificationDefaultSoundName;
//    //设置参数
//    
//    notification.userInfo = @{@"chatter":callSession.sessionChatter,@"isIncomingCallController":@"isIncomingCallController"};
//       //执行通知
//    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
//    
////    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground) {
////        //提醒角标+1
////        [UIApplication sharedApplication].applicationIconBadgeNumber ++;
////    }
//}

#pragma mark - private

- (BOOL)canRecord {
    __block BOOL bCanRecord = YES;
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending) {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
            [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                bCanRecord = granted;
            }];
        }
    }
    
    return bCanRecord;
}

//#pragma mark  ---获取视频功能开关
//- (void)getVideoOption{
//    
//    // NSString *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userId"];
//    
//    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/video/getVideoOption1",REQUESTHEADER] andParameter:nil success:^(id successResponse) {
//        
//        NSLog(@"0000000000000:%@",successResponse);
//        
//        
//       
//            if ([[NSString stringWithFormat:@"%@",successResponse[@"data"]] isEqualToString:@"1"]) {
//                //开启
//                [self initWithNavs];
//            }else{
//                [self initCloseWithNavs];
//            }
//        
//    } andFailure:^(id failureResponse) {
//        [MBProgressHUD showError:@"服务器繁忙,请重试"];
//        NSLog(@"失败:%@",failureResponse);
//    }];
//    
//}

- (void)initWithNavs {

    NSString *path    = [[NSBundle mainBundle] pathForResource:@"RootTabBarC_Init" ofType:@"plist"];
    NSArray *navInfos = [NSArray arrayWithContentsOfFile:path];

    _homeNav     = [[RootNavigationController alloc] initWithRootViewController:[[LYHomeViewController alloc] init]];
    _dialogueNav = [[RootNavigationController alloc] initWithRootViewController:[[DialogueViewController alloc] init]];
   
    _searchNav = [[RootNavigationController alloc]initWithRootViewController:[[FriendsCirleViewController alloc]init]];
    
    _sendNav = [[RootNavigationController alloc]initWithRootViewController:[[DynamicViewController alloc]init]];

    _meNav = [[RootNavigationController alloc] initWithRootViewController:[[LYMeViewController alloc] init]];

    NSArray *navs = @[_sendNav, _searchNav,_homeNav, _dialogueNav, _meNav];
    
       self.tabBar.selectedImageTintColor = [UIColor colorWithHexString:@"#ff5252"];

    for (int i = 0; i < navs.count; i++) {
        RootNavigationController *nav = navs[i];
        nav.title                     = navInfos[i][@"title"];
        nav.tabBarItem.selectedImage  = [UIImage imageNamed:navInfos[i][@"selectedImage"]];
        nav.tabBarItem.image          = [UIImage imageNamed:navInfos[i][@"image"]];
        
        if (i==0)
        {
            nav.title  = @"视频";
            nav.tabBarItem.image = [[UIImage imageNamed:@"灰色-视频聊icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            nav.tabBarItem.selectedImage = [[UIImage imageNamed:@"红色-视频聊icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            //nav.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
             self.parentViewController.tabBarController.tabBar.hidden = NO;
            
        }
        [self addChildViewController:nav];
    }
 
    

    
}

- (void)initCloseWithNavs {
    
    NSString *path    = [[NSBundle mainBundle] pathForResource:@"RootTabBarC_Init" ofType:@"plist"];
    NSArray *navInfos = [NSArray arrayWithContentsOfFile:path];
    
    _homeNav     = [[RootNavigationController alloc] initWithRootViewController:[[LYHomeViewController alloc] init]];
    _dialogueNav = [[RootNavigationController alloc] initWithRootViewController:[[DialogueViewController alloc] init]];
    
    _searchNav = [[RootNavigationController alloc]initWithRootViewController:[[FriendsCirleViewController alloc]init]];
    
    
    _meNav = [[RootNavigationController alloc] initWithRootViewController:[[LYMeViewController alloc] init]];
    
    NSArray *navs = @[ _searchNav,_homeNav, _dialogueNav, _meNav];
    
    self.tabBar.selectedImageTintColor = [UIColor colorWithHexString:@"#ff5252"];
    
    for (int i = 0; i < navs.count; i++) {
        RootNavigationController *nav = navs[i];
        nav.title                     = navInfos[i+1][@"title"];
        nav.tabBarItem.selectedImage  = [UIImage imageNamed:navInfos[i+1][@"selectedImage"]];
        nav.tabBarItem.image          = [UIImage imageNamed:navInfos[i+1][@"image"]];
        
//        if (i==0)
//        {
//            
//            nav.tabBarItem.image = [[UIImage imageNamed:@"灰色动态"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//            nav.tabBarItem.selectedImage = [[UIImage imageNamed:@"红色动态"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//            //nav.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
//            self.parentViewController.tabBarController.tabBar.hidden = NO;
//            
//        }
        [self addChildViewController:nav];
    }
    
    
    
    
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    
 
//    
//    if (viewController == tabBarController.viewControllers[2]){
//    
//       
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"roundBtnClicked" object:nil userInfo:nil];}
//    else{
//        
//       
//    }
  
    return YES;
//    if ([LYUserService sharedInstance].userID && (![[LYUserService sharedInstance].userID isEqualToString:@""])) { //已登录
//        if (viewController == tabBarController.viewControllers[4]) { //我的页面
//            
//        }
//        return YES;
//    } else { //未登录
        //如果以游客身份点击了'我'和'对话',直接弹出登陆界面
//        if (viewController == tabBarController.viewControllers[3]) {
//            [[LYUserService sharedInstance] fetchLoginStateWithCompeletionBlock:^(UserLoginStateType type) {
//                if (type == UserLoginStateTypeWaitToLogin) {
//                    [[LYUserService sharedInstance] jumpToLoginWithController:tabBarController];
//                }
//            }];
//            return NO;
//        } else { //如果以游客身份点击了‘首页’和‘发现’,则不进行操作
//            return YES;
//        }
   // }
}


@end
