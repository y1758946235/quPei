//
//  AppDelegate.m
//  LvYue
//
//  Created by apple on 15/9/28.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import "AppDelegate.h"
//#import "NewLoginViewController.h"
//#import "LoginViewController.h"
#import "LYUserService.h"
#import "LYHttpPoster.h"
#import "AppDelegate+EaseMob.h"
#import "AppDelegate+UMeng.h"
#import "MBProgressHUD+NJ.h"
#import "RootNavigationController.h"
#import <AlipaySDK/AlipaySDK.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    NSString *sdk = [EaseMob sharedInstance].sdkVersion;
    NSLog(@"版本号---------------%@", sdk);
    _rootTabC               = [[RootTabBarController alloc] init];
    _window                 = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _window.backgroundColor = [UIColor whiteColor];
    [self checkAutoLogin];
    [_window makeKeyAndVisible];

    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;

    // 是否显示充值
    [self p_getShowGetCoinButton];
    
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
    [WXApi registerApp:@"wx9f84f81dac87502a"]; //豆客appid
#endif
    return YES;
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    application.applicationIconBadgeNumber = 0;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LY_ReloadSystemMessage" object:nil];
    //更新系统消息后的点
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LY_ReloadSystemMessagePoint" object:nil];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    application.applicationIconBadgeNumber = 0;
}


#pragma mark - 验证自动登录
- (void)checkAutoLogin {
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    self.deviceToken     = [user objectForKey:@"deviceToken"];

    //如果本地有用户缓存信息
    if (((![[user objectForKey:@"mobile"] isEqualToString:@""] && [user objectForKey:@"mobile"]) && (![[user objectForKey:@"password"] isEqualToString:@""] && [user objectForKey:@"password"]) && (![[user objectForKey:@"userID"] isEqualToString:@""] && [user objectForKey:@"userID"])) || (([user objectForKey:@"umengID"] && ![[user objectForKey:@"umengID"] isEqualToString:@""]) && (![[user objectForKey:@"userID"] isEqualToString:@""] && [user objectForKey:@"userID"]))) {
        _window.rootViewController = _rootTabC;
        //重新加载单例数据
        [[LYUserService sharedInstance] reloadUserInfo];
        //发送消息给首页,进行自动登录校验
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"autoLogin" object:nil];
        });
    } else { //无缓存

        //        if (ISIPHONE4 || ISIPHONE5) {
        //            _window.rootViewController = [[RootNavigationController alloc] initWithRootViewController:[[NewLoginViewController alloc] init]];
        //        }else {
        //            _window.rootViewController = [[RootNavigationController alloc] initWithRootViewController:[[LoginViewController alloc] init]];
        //        }
        _window.rootViewController = _rootTabC;
    }
}

- (void)p_getShowGetCoinButton {
    
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/pay_Set", REQUESTHEADER]
                           andParameter:@{}
                                success:^(id successResponse) {
                                    MLOG(@"结果:%@", successResponse);
                                    if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
                                        [[NSUserDefaults standardUserDefaults] setValue:@([successResponse[@"data"][@"set"][@"sign"] integerValue] == 1 ? YES : NO) forKey:@"ShowGetCoinKey"];
                                    } else {
//                                        [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"msg"]]];
                                    }
                                }
                             andFailure:^(id failureResponse){
                             }];
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
            NSString *tableName2      = @"Group";
            NSString *createTableSql2 = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@'('%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT)", tableName2, @"groupID", @"easemob_id", @"name", @"desc", @"icon"];
            [self.dataBase executeUpdate:createTableSql2];
            //建立视频表
            NSString *tableName3      = @"VideoPreviewImage";
            NSString *createTableSql3 = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@'('%@' TEXT, '%@' TEXT)", tableName3, @"video_url", @"imageData"];
            [self.dataBase executeUpdate:createTableSql3];
            //关闭
            [self.dataBase close];
        } else {
            MLOG(@"创建表失败!");
        }
    }];
}

@end
