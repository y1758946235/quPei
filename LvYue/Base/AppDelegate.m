//
//  AppDelegate.m
//  LvYue
//
//  Created by apple on 15/9/28.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import "AppDelegate.h"
#import "AppDelegate+EaseMob.h"
#import "AppDelegate+UMeng.h"
#import "RootNavigationController.h"

#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "MBProgressHUD+NJ.h"
#import "NewLoginViewController.h"
#import "pchFile.pch"
#import "perfactInfoVC.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
  
    NSString *sdk = [EaseMob sharedInstance].sdkVersion;
    NSLog(@"版本号---------------%@", sdk);
//    _rootTabC               = [[RootTabBarController alloc] init];
 
//    _window.backgroundColor = [UIColor whiteColor];
//    _window.rootViewController = _rootTabC;
    

    

//    NewLoginViewController * main = [[NewLoginViewController alloc]init];
//    UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:main];
//    self.window.rootViewController = nav;
    
//    [CommonTool gotoLogin];
//    [CommonTool gotoMain];
  

//    //检验是否自动登录
    [self checkAutoLogin];
    
    //_window.rootViewController = _rootTabC;
    
   
    
    if (launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]) {
        [self application:application didReceiveRemoteNotification:launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]];
    }
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;

    
    //初始化环信SDK，详细内容在AppDelegate+EaseMob.m 文件中
    [self easemobApplication:application didFinishLaunchingWithOptions:launchOptions];
    //初始化友盟SDK
    [self addUMengApplication:application didFinishLaunchingWithOptions:launchOptions];

   //数据库操作
    [self updateLocalDataBase];

    //百度MapKit
    _mapManager = [[BMKMapManager alloc] init];
    BOOL ret    = [_mapManager start:@"0A4eGEoGUvPQVcIp47GPXKFO" generalDelegate:nil];
    if (!ret) {
        NSLog(@"manager start failed!");
    }

#ifdef kEasyVersion
    [WXApi registerApp:@"wxaf9375cc55fedb78"]; //滴滴向导appid
#else
    [WXApi registerApp:@"wx75e81a6ae929b24a"]; //豆客appid
#endif
    
    
    return YES;
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.window endEditing:YES];
}
- (void)applicationWillEnterForeground:(UIApplication *)application {
//    application.applicationIconBadgeNumber = 0;
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"LY_ReloadSystemMessage" object:nil];
//    //更新系统消息后的点
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"LY_ReloadSystemMessagePoint" object:nil];
//    
//    //    //增加关注，送礼的红点通知中心
//    //    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowGiftRedBadgeNotification" object:@(YES)];
//    //    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowFansRedBadgeNotification" object:@(YES)];
//    
}

#pragma mark - 连接本地数据库
- (void)updateLocalDataBase {
    
    MLOG(@"\n本地数据库路径 : \n%@\n", kDataBasePath);
    
    FMDatabase *dataBase   = [FMDatabase databaseWithPath:kDataBasePath];
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:kDataBasePath];
    self.dataBase          = dataBase;
    self.dataBaseQueue     = queue;
    
    [self.dataBaseQueue inDatabase:^(FMDatabase *db) {
        //打开数据库并建表(如果表不存在)
        if ([self.dataBase open]) {
            //建用户表
            NSString *tableName      = @"User";
            NSString *createTableSql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@'('%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT)", tableName, @"userID", @"name", @"remark", @"icon"];
            [self.dataBase executeUpdate:createTableSql];
            //建群组表
//            NSString *tableName2      = @"Group";
//            NSString *createTableSql2 = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@'('%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT)", tableName2, @"groupID", @"easemob_id", @"name", @"desc", @"icon"];
//            [self.dataBase executeUpdate:createTableSql2];
//            //建立视频表
//            NSString *tableName3      = @"VideoPreviewImage";
//            NSString *createTableSql3 = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@'('%@' TEXT, '%@' TEXT)", tableName3, @"video_url", @"imageData"];
//            [self.dataBase executeUpdate:createTableSql3];
            //创建好友列表
            NSString *tableName2      = @"Firends";
            NSString *createTableSql2 = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@'('%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT)", tableName2, @"userID", @"name", @"remark", @"icon"];
            [self.dataBase executeUpdate:createTableSql2];
            //创建关注列表
            NSString *tableName3      = @"Focus";
            NSString *createTableSql3 = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@'('%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT)", tableName3, @"userID", @"name", @"remark", @"icon"];
            [self.dataBase executeUpdate:createTableSql3];
            //创建粉丝列表
            NSString *tableName4      = @"Fans";
            NSString *createTableSql4 = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@'('%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT)", tableName4, @"userID", @"name", @"remark", @"icon"];
            [self.dataBase executeUpdate:createTableSql4];
            //创建黑名单列表
            NSString *tableName5      = @"Blacklist";
            NSString *createTableSql5 = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@'('%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT)", tableName5, @"userID", @"name", @"remark", @"icon"];
            [self.dataBase executeUpdate:createTableSql5];
            //关闭
            [self.dataBase close];
        } else {
            MLOG(@"创建表失败!");
        }
    }];
}


#pragma mark  ---验证自动登录
- (void)checkAutoLogin {
    
        
    
        
        
        
        
        
  
    //如果本地有用户缓存信息  ((![[user objectForKey:@"mobile"] isEqualToString:@""] && [user objectForKey:@"mobile"]) && (![[user objectForKey:@"password"] isEqualToString:@""] && [user objectForKey:@"password"]) && (![[user objectForKey:@"userID"] isEqualToString:@""] && [user objectForKey:@"userID"])) || (([user objectForKey:@"umengID"] && ![[user objectForKey:@"umengID"] isEqualToString:@""]) && (![[user objectForKey:@"userID"] isEqualToString:@""] && [user objectForKey:@"userID"]))
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    
    self.deviceToken = [user objectForKey:@"deviceToken"];
 
    if (![CommonTool dx_isNullOrNilWithObject:[CommonTool getUserID]]  && ![CommonTool dx_isNullOrNilWithObject:[CommonTool getUserCaptcha]]&& ![CommonTool dx_isNullOrNilWithObject:[CommonTool getUserNickname]] && ![CommonTool dx_isNullOrNilWithObject:[CommonTool getUserIcon]]  && ![CommonTool dx_isNullOrNilWithObject:[CommonTool getUserSex]] ) {
        _rootTabC               = [[RootTabBarController alloc] init];
      

        _window.rootViewController = _rootTabC;
        
      
            
       

        
//        //重新加载单例数据
//        [[LYUserService sharedInstance] reloadUserInfo];
//        //发送消息给首页,进行自动登录校验
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"autoLogin" object:nil];
//        });
    } else { //无缓存
        
//        if (ISIPHONE4 || ISIPHONE5) {
//            _window.rootViewController = [[RootNavigationController alloc] initWithRootViewController:[[NewLoginViewController alloc] init]];
//        }else {
//            _window.rootViewController = [[RootNavigationController alloc] initWithRootViewController:[[LoginViewController alloc] init]];
//        }
//        _window.rootViewController = _rootTabC;
        
        
        if (![CommonTool dx_isNullOrNilWithObject:[CommonTool getUserID]]  && ![CommonTool dx_isNullOrNilWithObject:[CommonTool getUserCaptcha]]) {
            if ( [CommonTool dx_isNullOrNilWithObject:[CommonTool getUserNickname]] || [CommonTool dx_isNullOrNilWithObject:[CommonTool getUserIcon]]  || [CommonTool dx_isNullOrNilWithObject:[CommonTool getUserSex]] ) {
                perfactInfoVC * main = [[perfactInfoVC alloc]init];
                UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:main];
                self.window.rootViewController = nav;
            }else{
                NewLoginViewController * main = [[NewLoginViewController alloc]init];
                UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:main];
                self.window.rootViewController = nav;
 
            }
         
        
        }else{
            
            NewLoginViewController * main = [[NewLoginViewController alloc]init];
            UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:main];
            self.window.rootViewController = nav;
        
        }
        
            
    }
    
}
















- (void)applicationWillTerminate:(UIApplication *)application {
 
    
    
    
}

@end
