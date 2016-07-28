/************************************************************
 *  * EaseMob CONFIDENTIAL
 * __________________
 * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of EaseMob Technologies.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from EaseMob Technologies.
 */

#import "AppDelegate+EaseMob.h"
#import "LYUserService.h"
#import "ChatViewController.h"
#import "UMessage.h"
#import "NSString+DeviceToken.h"
#import "ChatSendHelper.h"
#import "LYHttpPoster.h"
#import "DialogueViewController.h"
#import <AudioToolbox/AudioToolbox.h>

@interface AppDelegate ()<EMChatManagerDelegate,UIAlertViewDelegate,IChatManagerDelegate,EMChatManagerDelegate>

@end

/**
 *  本类中做了EaseMob初始化和推送等操作
 */

@implementation AppDelegate (EaseMob)

- (NSString *)applyUserName {
    return objc_getAssociatedObject(self, @selector(applyUserName));
}

- (void)setApplyUserName:(NSString *)applyUserName {
    objc_setAssociatedObject(self, @selector(applyUserName), applyUserName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)easemobApplication:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //点击离线apns栏唤醒app 拿到apns推送信息
    if (launchOptions) {
        NSDictionary*userInfo = [launchOptions objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"];
        if(userInfo)
        {
            [self didReceiveRemoteNotification:userInfo];
        }
    }
    
    //标记连接状态为已连接
    _connectionState = eEMConnectionConnected;
    
    //注册APNS推送
    [self registerRemoteNotification];
    

    //SDK注册 APNS文件的名字, 需要与后台上传证书时的名字一一对应
//    NSString *apnsCertName = @"LvYuePushDebug";
    NSString *apnsCertName = @"ReleasePushBook";

    EMError * error = [[EaseMob sharedInstance] registerSDKWithAppKey:@"rw2015#lvyuedemo"
                                       apnsCertName:apnsCertName
                                        otherConfig:@{kSDKConfigEnableConsoleLogger:@YES}];
    MLOG(@"错误:%@",error);
    
    // 登录成功后，自动去取好友列表
    // SDK获取结束后，会回调
    // - (void)didFetchedBuddyList:(NSArray *)buddyList error:(EMError *)error方法。
    [[EaseMob sharedInstance].chatManager setIsAutoFetchBuddyList:NO];
    
    // 注册环信监听
    [self registerEaseMobNotification];
    [[EaseMob sharedInstance] application:application
            didFinishLaunchingWithOptions:launchOptions];
    
    [self setupNotifiers];
    
}


// 监听系统生命周期回调，以便将需要的事件传给SDK
- (void)setupNotifiers{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidEnterBackgroundNotif:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidFinishLaunching:)
                                                 name:UIApplicationDidFinishLaunchingNotification
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidBecomeActiveNotif:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillResignActiveNotif:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidReceiveMemoryWarning:)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillTerminateNotif:)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appProtectedDataWillBecomeUnavailableNotif:)
                                                 name:UIApplicationProtectedDataWillBecomeUnavailable
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appProtectedDataDidBecomeAvailableNotif:)
                                                 name:UIApplicationProtectedDataDidBecomeAvailable
                                               object:nil];
}

#pragma mark - notifiers
- (void)appDidEnterBackgroundNotif:(NSNotification*)notif{
    [[EaseMob sharedInstance] applicationDidEnterBackground:notif.object];
}

- (void)appWillEnterForeground:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationWillEnterForeground:notif.object];
}

- (void)appDidFinishLaunching:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationDidFinishLaunching:notif.object];
}

- (void)appDidBecomeActiveNotif:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationDidBecomeActive:notif.object];
}

- (void)appWillResignActiveNotif:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationWillResignActive:notif.object];
}

- (void)appDidReceiveMemoryWarning:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationDidReceiveMemoryWarning:notif.object];
}

- (void)appWillTerminateNotif:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationWillTerminate:notif.object];
}

- (void)appProtectedDataWillBecomeUnavailableNotif:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationProtectedDataWillBecomeUnavailable:notif.object];
}

- (void)appProtectedDataDidBecomeAvailableNotif:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationProtectedDataDidBecomeAvailable:notif.object];
}

// 将得到的deviceToken传给SDK
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    //环信获取deviceToken
    [[EaseMob sharedInstance] application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
    //友盟获取deviceToken
    [UMessage registerDeviceToken:deviceToken];
    NSString *deviceTokenString = [NSString deviceTokenStringWithDeviceTokenData:deviceToken];
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setObject:deviceTokenString forKey:@"deviceToken"];
    kAppDelegate.deviceToken = deviceTokenString;
    if (!kAppDelegate.deviceToken) {
        kAppDelegate.deviceToken = @"bb63b19106f3108798b7a271447e40df8a75c0b7cec8d99f54b43728713edc37";
    }
    MLOG(@"\n成功拿到设备Token:%@\n",deviceTokenString);
    
}

// 注册deviceToken失败，此处失败，与环信SDK无关，一般是您的环境配置或者证书配置有误(注册推送失败)
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    [[EaseMob sharedInstance] application:application didFailToRegisterForRemoteNotificationsWithError:error];
    MLOG(@"推送注册失败");
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"apns.failToRegisterApns", Fail to register apns)
//                                                    message:error.description
//                                                   delegate:nil
//                                          cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
//                                          otherButtonTitles:nil];
//    [alert show];
}

// 注册推送
- (void)registerRemoteNotification{
    UIApplication *application = [UIApplication sharedApplication];
    application.applicationIconBadgeNumber = 0;
    
    //IOS8注册APNS
    if([application respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
    }

#if !TARGET_IPHONE_SIMULATOR
    //IOS8 手动开启推送申请授权
    if ([application respondsToSelector:@selector(registerForRemoteNotifications)]) {
        [application registerForRemoteNotifications];
    }else{ //IOS7 注册APNS
        UIRemoteNotificationType notificationTypes = UIRemoteNotificationTypeBadge |
        UIRemoteNotificationTypeSound |
        UIRemoteNotificationTypeAlert;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:notificationTypes];
    }
#endif
}

#pragma mark - registerEaseMobNotification
- (void)registerEaseMobNotification{
    [self unRegisterEaseMobNotification];
    // 将self 添加到SDK回调中，以便本类可以收到SDK回调
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
}

- (void)unRegisterEaseMobNotification{
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}



// 绑定deviceToken回调(绑定失败)
- (void)didBindDeviceWithError:(EMError *)error
{
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"绑定失败\n%@\n",error] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        
        [alert show];

    }
}

// 监听网络状态变化回调
- (void)didConnectionStateChanged:(EMConnectionState)connectionState
{
    _connectionState = connectionState;
    NSDictionary *stateDict = @{@"connectionState":[NSString stringWithFormat:@"%lu",(unsigned long)connectionState]};
    //发送网络状态变化的通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LY_NetworkConnectionStateDidChange" object:nil userInfo:stateDict];
}

// 程序离线时点击推送栏调用(因为didFinishLaunchingWithOptions方法里调用到) 接收相应的apns信息
-(void)didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    MLOG(@"收到的推送信息:%@",userInfo);
    [UIApplication sharedApplication].applicationIconBadgeNumber = 1;
    //判断是什么推送
    if (userInfo[@"umengPush"]) { //如果是友盟推送
        
        NSString *string = userInfo[@"aps"][@"alert"];
        if ([[string substringFromIndex:string.length - 4] isEqualToString:@"好友申请"]) { //如果不是订单类推送
            //记录在本地
            NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
            [user setObject:@"1" forKey:kHavePrompt];
            [user synchronize];
            //显示一级提醒器
            [[NSNotificationCenter defaultCenter] postNotificationName:@"closeOrShowMyBuddyListVcPushPrompt" object:nil];
            //通知显示二级显示器
            [[NSNotificationCenter defaultCenter] postNotificationName:@"closeOrShowCheckMessageListVcPushPrompt" object:nil];
        }else if ([userInfo[@"aps"][@"alert"] isEqualToString:@"有人应邀了您的需求"]) {
            //记录在本地
            NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
            [user setObject:@"1" forKey:kHaveInvite];
            [user synchronize];
            //显示一级提醒器
            [[NSNotificationCenter defaultCenter] postNotificationName:@"closeOrShowCheckRequireListVcPushPrompt" object:nil];
        }else if ([userInfo[@"aps"][@"alert"] isEqualToString:@"有新需求与您的技能匹配"]) {
            //记录在本地
            NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
            [user setObject:@"1" forKey:kHaveRequire];
            [user synchronize];
            //显示一级提醒器
            [[NSNotificationCenter defaultCenter] postNotificationName:@"closeOrShowCheckSkillListVcPushPrompt" object:nil];
        }

        UINavigationController *dialogueNav = kAppDelegate.rootTabC.viewControllers[1];
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        NSString *str = [user objectForKey:kHavePrompt];
        NSString *skillStr = [user objectForKey:kHaveInvite];
        NSString *requireStr  = [user objectForKey:kHaveRequire];
        if ([[EaseMob sharedInstance].chatManager loadTotalUnreadMessagesCountFromDatabase] == 0 && kAppDelegate.unReadSystemMessageNum == 0 && [str integerValue] == 0 && [skillStr integerValue] == 0 && [requireStr integerValue] == 0) {
            dialogueNav.tabBarItem.badgeValue = nil;
        }
        else if ([[EaseMob sharedInstance].chatManager loadTotalUnreadMessagesCountFromDatabase] == 0 && kAppDelegate.unReadSystemMessageNum != 0 && [str integerValue] == 0 && [skillStr integerValue] == 0 && [requireStr integerValue] == 0) {
            dialogueNav.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld",(long)kAppDelegate.unReadSystemMessageNum];
        }
        else if ([[EaseMob sharedInstance].chatManager loadTotalUnreadMessagesCountFromDatabase] == 0 && kAppDelegate.unReadSystemMessageNum == 0 && [str integerValue] != 0 && [skillStr integerValue] == 0 && [requireStr integerValue] == 0) {
            dialogueNav.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld",(long)[str integerValue]];
        }
        else if ([[EaseMob sharedInstance].chatManager loadTotalUnreadMessagesCountFromDatabase] == 0 && kAppDelegate.unReadSystemMessageNum == 0 && [skillStr integerValue] != 0 && [str integerValue] == 0 && [requireStr integerValue] == 0) {
            dialogueNav.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld",(long)[skillStr integerValue]];
        }
        else if ([[EaseMob sharedInstance].chatManager loadTotalUnreadMessagesCountFromDatabase] == 0 && kAppDelegate.unReadSystemMessageNum == 0 && [requireStr integerValue] != 0 && [str integerValue] == 0 && [skillStr integerValue] == 0) {
            dialogueNav.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld",(long)[requireStr integerValue]];
        }
        else {
            if (([[EaseMob sharedInstance].chatManager loadTotalUnreadMessagesCountFromDatabase] + kAppDelegate.unReadSystemMessageNum) > 99) {
                dialogueNav.tabBarItem.badgeValue = @"99";
            } else {
                dialogueNav.tabBarItem.badgeValue = [NSString stringWithFormat:@"%lu",((unsigned long)[[EaseMob sharedInstance].chatManager loadTotalUnreadMessagesCountFromDatabase] + kAppDelegate.unReadSystemMessageNum) + [str integerValue] + [skillStr integerValue] + [requireStr integerValue]];
            }
        }

        [UMessage didReceiveRemoteNotification:userInfo];
        kAppDelegate.rootTabC.selectedIndex = 1;
        //更新系统消息
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LY_ReloadSystemMessage" object:nil];
        //更新系统消息后的点
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LY_ReloadSystemMessagePoint" object:nil];
    } else { //如果是环信推送 通过收到的apns信息直接进入会话
        BOOL isGroupChat;
        NSString *chatter = @"";
        if (userInfo[@"g"]) { //如果是群聊
            isGroupChat = YES;
            chatter = [NSString stringWithFormat:@"%@",userInfo[@"g"]];
            //查询群组名称
            [kAppDelegate.dataBaseQueue inDatabase:^(FMDatabase *db) {
                if ([kAppDelegate.dataBase open]) {
                    BOOL isExist = NO;
                    NSString *groupName = @"";
                    NSString *findSql = [NSString stringWithFormat:@"SELECT * FROM '%@' WHERE easemob_id = '%@'",@"Group",chatter];
                    FMResultSet *result = [kAppDelegate.dataBase executeQuery:findSql];
                    while([result next]) {
                        isExist = YES;
                        groupName = [result stringForColumn:@"name"];
                    }
                    if (isExist) { //如果表中有数据
                                [[[UIAlertView alloc] initWithTitle:@"xxxx" message:[NSString stringWithFormat:@"%@",userInfo] delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil] show];
                        ChatViewController *chatVc = [[ChatViewController alloc] initWithChatter:chatter isGroup:isGroupChat];
                        chatVc.title = groupName;
                        kAppDelegate.rootTabC.selectedIndex = 1;
                        [kAppDelegate.rootTabC.viewControllers[1] popToRootViewControllerAnimated:NO];
                        [kAppDelegate.rootTabC.viewControllers[1] pushViewController:chatVc animated:YES];
                        [kAppDelegate.dataBase close];
                    } else { //没有去请求群组名称并插入表中
                        [kAppDelegate.dataBase close];
                        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/group/getInfoByEasemobId",REQUESTHEADER] andParameter:@{@"easemob_id":chatter} success:^(id successResponse) {
                            if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
                                NSDictionary *group = successResponse[@"data"][@"group"];
                                NSString *groupID = [NSString stringWithFormat:@"%@",group[@"groupID"]];
                                NSString *name = [NSString stringWithFormat:@"%@",group[@"name"]];
                                NSString *desc = [NSString stringWithFormat:@"%@",group[@"desc"]];
                                NSString *icon = [NSString stringWithFormat:@"%@%@",IMAGEHEADER,group[@"icon"]];
                                ChatViewController *chatVc = [[ChatViewController alloc] initWithChatter:chatter isGroup:isGroupChat];
                                chatVc.title = name;
                                kAppDelegate.rootTabC.selectedIndex = 1;
                                [kAppDelegate.rootTabC.viewControllers[1] popToRootViewControllerAnimated:NO];
                                [kAppDelegate.rootTabC.viewControllers[1] pushViewController:chatVc animated:YES];
                                //存入数据库
                                [kAppDelegate.dataBaseQueue inDatabase:^(FMDatabase *db) {
                                    if ([kAppDelegate.dataBase open]) {
                                        NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO '%@'('%@','%@','%@','%@','%@') VALUES('%@','%@','%@','%@','%@')",@"Group",@"groupID",@"easemob_id",@"name",@"desc",@"icon",groupID,chatter,name,desc,icon];
                                        BOOL isSuccess = [kAppDelegate.dataBase executeUpdate:insertSql];
                                        if (isSuccess) {
                                            MLOG(@"插入数据成功!");
                                        } else {
                                            MLOG(@"插入数据失败!");
                                        }
                                        [kAppDelegate.dataBase close];
                                    }
                                }];
                            }
                        } andFailure:^(id failureResponse) {
                        }];
                    }
                } else {
                    ChatViewController *chatVc = [[ChatViewController alloc] initWithChatter:chatter isGroup:isGroupChat];
                    chatVc.title = chatter;
                    kAppDelegate.rootTabC.selectedIndex = 1;
                    [kAppDelegate.rootTabC.viewControllers[1] popToRootViewControllerAnimated:NO];
                    [kAppDelegate.rootTabC.viewControllers[1] pushViewController:chatVc animated:YES];
                }
            }];
        } else { //如果是单聊
            isGroupChat = NO;
            chatter = [NSString stringWithFormat:@"%@",userInfo[@"f"]];
            [kAppDelegate.dataBaseQueue inDatabase:^(FMDatabase *db) {
                __block NSDictionary *resultDict;
                __block NSString *userName = @"";
                //打开数据库
                if ([kAppDelegate.dataBase open]) {
                    //条件查询
                    NSString *searchSql = [NSString stringWithFormat:@"SELECT * FROM '%@' WHERE userID = '%@'",@"User",chatter];
                    FMResultSet *result = [kAppDelegate.dataBase executeQuery:searchSql];
                    BOOL isExist = NO;
                    while ([result next]) {
                        isExist = YES;
                        NSString *userID = [result stringForColumn:@"userID"];
                        NSString *name = [result stringForColumn:@"name"];
                        NSString *remark = [result stringForColumn:@"remark"];
                        NSString *icon = [result stringForColumn:@"icon"];
                        resultDict = @{@"userID":userID,@"name":name,@"remark":remark,@"icon":icon};
                    }
                    if (isExist) { //如果表中有数据
                        [kAppDelegate.dataBase close];
                        if (resultDict[@"remark"] && !([[NSString stringWithFormat:@"%@",resultDict[@"remark"]] isEqualToString:@""]) && !([[NSString stringWithFormat:@"%@",resultDict[@"remark"]] isEqualToString:@"(null)"])) {
                            userName = resultDict[@"remark"];
                        } else {
                            userName = resultDict[@"name"];
                        }
                        ChatViewController *chatVc = [[ChatViewController alloc] initWithChatter:chatter isGroup:isGroupChat];
                        chatVc.title = userName;
                        kAppDelegate.rootTabC.selectedIndex = 1;
                        [kAppDelegate.rootTabC.viewControllers[1] popToRootViewControllerAnimated:NO];
                        [kAppDelegate.rootTabC.viewControllers[1] pushViewController:chatVc animated:YES];
                        [kAppDelegate.dataBase close];
                    } else { //没有数据就去请求用户昵称并插入表中
                        [kAppDelegate.dataBase close];
                        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/userFriend/getInfo",REQUESTHEADER] andParameter:@{@"user_id":[LYUserService sharedInstance].userID,@"friend_user_id":chatter} success:^(id successResponse) {
                            if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
                                NSDictionary *user = successResponse[@"data"][@"user"];
                                NSString *userID = [NSString stringWithFormat:@"%@",user[@"id"]];
                                NSString *name = [NSString stringWithFormat:@"%@",user[@"name"]];
                                NSString *remark = [NSString stringWithFormat:@"%@",user[@"remark"]];
                                NSString *icon = [NSString stringWithFormat:@"%@%@",IMAGEHEADER,user[@"icon"]];
                                resultDict = @{@"userID":userID,@"name":name,@"remark":remark,@"icon":icon};
                                if (resultDict[@"remark"] && !([[NSString stringWithFormat:@"%@",resultDict[@"remark"]] isEqualToString:@""]) && !([[NSString stringWithFormat:@"%@",resultDict[@"remark"]] isEqualToString:@"(null)"])) {
                                    userName = remark;
                                } else {
                                    userName = name;
                                }
                                ChatViewController *chatVc = [[ChatViewController alloc] initWithChatter:chatter isGroup:isGroupChat];
                                chatVc.title = userName;
                                kAppDelegate.rootTabC.selectedIndex = 1;
                                [kAppDelegate.rootTabC.viewControllers[1] popToRootViewControllerAnimated:NO];
                                [kAppDelegate.rootTabC.viewControllers[1] pushViewController:chatVc animated:YES];
                                //存入数据库
                                [kAppDelegate.dataBaseQueue inDatabase:^(FMDatabase *db) {
                                    if ([kAppDelegate.dataBase open]) {
                                        NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO '%@'('%@','%@','%@','%@') VALUES('%@','%@','%@','%@')",@"User",@"userID",@"name",@"remark",@"icon",userID,name,remark,icon];
                                        BOOL isSuccess = [kAppDelegate.dataBase executeUpdate:insertSql];
                                        if (isSuccess) {
                                            MLOG(@"插入数据成功!");
                                        } else {
                                            MLOG(@"插入数据失败!");
                                        }
                                        [kAppDelegate.dataBase close];
                                    }
                                }];
                            }
                        } andFailure:^(id failureResponse) {
                        }];
                    }
                } else {
                    ChatViewController *chatVc = [[ChatViewController alloc] initWithChatter:chatter isGroup:isGroupChat];
                    chatVc.title = chatter;
                    kAppDelegate.rootTabC.selectedIndex = 1;
                    [kAppDelegate.rootTabC.viewControllers[1] popToRootViewControllerAnimated:NO];
                    [kAppDelegate.rootTabC.viewControllers[1] pushViewController:chatVc animated:YES];
                }
            }];
        }
    }
}



//成功收到推送(在前台收到远程推送或者在后台点击推送栏调用，非离线)
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    MLOG(@"\nuserInfo == \n%@",userInfo);
    if (userInfo[@"aps"][@"umengPush"]) { //如果是友盟推送
        //如果原本程序处于后台状态
        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateInactive) {
            kAppDelegate.rootTabC.selectedIndex = 1;
        }
        //更新系统消息
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LY_ReloadSystemMessage" object:nil];
        //更新系统消息后的点
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LY_ReloadSystemMessagePoint" object:nil];
        //根据推送过来的内容判断是否显示提醒器
        NSString *string = userInfo[@"aps"][@"alert"];
        if ([[string substringFromIndex:string.length - 4] isEqualToString:@"好友申请"]) { //如果不是订单类推送
            //记录在本地
            NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
            [user setObject:@"1" forKey:kHavePrompt];
            [user synchronize];
            //显示一级提醒器
            [[NSNotificationCenter defaultCenter] postNotificationName:@"closeOrShowMyBuddyListVcPushPrompt" object:nil];
            //通知显示二级显示器
            [[NSNotificationCenter defaultCenter] postNotificationName:@"closeOrShowCheckMessageListVcPushPrompt" object:nil];
        }else if ([userInfo[@"aps"][@"alert"] isEqualToString:@"有人应邀了您的需求"]) {
            //记录在本地
            NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
            [user setObject:@"1" forKey:kHaveInvite];
            [user synchronize];
            //显示一级提醒器
            [[NSNotificationCenter defaultCenter] postNotificationName:@"closeOrShowCheckRequireListVcPushPrompt" object:nil];
        }else if ([userInfo[@"aps"][@"alert"] isEqualToString:@"有新需求与您的技能匹配"]) {
            //记录在本地
            NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
            [user setObject:@"1" forKey:kHaveRequire];
            [user synchronize];
            //显示一级提醒器
            [[NSNotificationCenter defaultCenter] postNotificationName:@"closeOrShowCheckSkillListVcPushPrompt" object:nil];
        }
        
        UINavigationController *dialogueNav = kAppDelegate.rootTabC.viewControllers[1];
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        NSString *str = [user objectForKey:kHavePrompt];
        NSString *skillStr = [user objectForKey:kHaveInvite];
        NSString *requireStr  = [user objectForKey:kHaveRequire];
        if ([[EaseMob sharedInstance].chatManager loadTotalUnreadMessagesCountFromDatabase] == 0 && kAppDelegate.unReadSystemMessageNum == 0 && [str integerValue] == 0 && [skillStr integerValue] == 0 && [requireStr integerValue] == 0) {
            dialogueNav.tabBarItem.badgeValue = nil;
        }
        else if ([[EaseMob sharedInstance].chatManager loadTotalUnreadMessagesCountFromDatabase] == 0 && kAppDelegate.unReadSystemMessageNum != 0 && [str integerValue] == 0 && [skillStr integerValue] == 0 && [requireStr integerValue] == 0) {
            dialogueNav.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld",(long)kAppDelegate.unReadSystemMessageNum];
        }
        else if ([[EaseMob sharedInstance].chatManager loadTotalUnreadMessagesCountFromDatabase] == 0 && kAppDelegate.unReadSystemMessageNum == 0 && [str integerValue] != 0 && [skillStr integerValue] == 0 && [requireStr integerValue] == 0) {
            dialogueNav.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld",(long)[str integerValue]];
        }
        else if ([[EaseMob sharedInstance].chatManager loadTotalUnreadMessagesCountFromDatabase] == 0 && kAppDelegate.unReadSystemMessageNum == 0 && [skillStr integerValue] != 0 && [str integerValue] == 0 && [requireStr integerValue] == 0) {
            dialogueNav.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld",(long)[skillStr integerValue]];
        }
        else if ([[EaseMob sharedInstance].chatManager loadTotalUnreadMessagesCountFromDatabase] == 0 && kAppDelegate.unReadSystemMessageNum == 0 && [requireStr integerValue] != 0 && [str integerValue] == 0 && [skillStr integerValue] == 0) {
            dialogueNav.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld",(long)[requireStr integerValue]];
        }
        else {
            if (([[EaseMob sharedInstance].chatManager loadTotalUnreadMessagesCountFromDatabase] + kAppDelegate.unReadSystemMessageNum) > 99) {
                dialogueNav.tabBarItem.badgeValue = @"99";
            } else {
                dialogueNav.tabBarItem.badgeValue = [NSString stringWithFormat:@"%lu",((unsigned long)[[EaseMob sharedInstance].chatManager loadTotalUnreadMessagesCountFromDatabase] + kAppDelegate.unReadSystemMessageNum) + [str integerValue] + [skillStr integerValue] + [requireStr integerValue]];
            }
        }

    }
}


//处理本地推送通知
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    MLOG(@"收到本地通知");
    if (application.applicationState == UIApplicationStateInactive) {
        NSDictionary *userInfo = [notification userInfo];
        NSString *chatTitle = @""; //聊天标题
        //直接进入会话
        BOOL isGroup;
        if ([userInfo[@"messageType"] isEqualToString:[NSString stringWithFormat:@"%ld",(long)eMessageTypeGroupChat]]) {
            isGroup = YES;
            EMGroup *group = [[EaseMob sharedInstance].chatManager fetchGroupInfo:userInfo[@"chatter"] error:nil];
            chatTitle = group.groupSubject;
            //查询本地后台的groupID
            [kAppDelegate.dataBaseQueue inDatabase:^(FMDatabase *db) {
                if ([kAppDelegate.dataBase open]) {
                    BOOL isExist = NO;
                    NSString *groupID = @"";
                    NSString *findSql = [NSString stringWithFormat:@"SELECT * FROM '%@' WHERE easemob_id = '%@'",@"Group",userInfo[@"chatter"]];
                    FMResultSet *result = [kAppDelegate.dataBase executeQuery:findSql];
                    while([result next]) {
                        isExist = YES;
                        groupID = [result stringForColumn:@"groupID"];
                    }
                    if (isExist) { //如果表中有数据
                        ChatViewController *chatVc = [[ChatViewController alloc] initWithChatter:userInfo[@"chatter"] isGroup:isGroup];
                        chatVc.title = chatTitle;
                        chatVc.groupID = groupID;
                        kAppDelegate.rootTabC.selectedIndex = 1;
                        [kAppDelegate.rootTabC.viewControllers[1] popToRootViewControllerAnimated:NO];
                        [kAppDelegate.rootTabC.viewControllers[1] pushViewController:chatVc animated:YES];
                        [kAppDelegate.dataBase close];
                    } else { //没有去请求群组名称并插入表中
                        [kAppDelegate.dataBase close];
                        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/group/getInfoByEasemobId",REQUESTHEADER] andParameter:@{@"easemob_id":userInfo[@"chatter"]} success:^(id successResponse) {
                            if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
                                NSDictionary *group = successResponse[@"data"][@"group"];
                                NSString *groupID = [NSString stringWithFormat:@"%@",group[@"groupID"]];
                                NSString *name = [NSString stringWithFormat:@"%@",group[@"name"]];
                                NSString *desc = [NSString stringWithFormat:@"%@",group[@"desc"]];
                                NSString *icon = [NSString stringWithFormat:@"%@%@",IMAGEHEADER,group[@"icon"]];
                                ChatViewController *chatVc = [[ChatViewController alloc] initWithChatter:userInfo[@"chatter"] isGroup:isGroup];
                                chatVc.title = chatTitle;
                                chatVc.groupID = groupID;
                                kAppDelegate.rootTabC.selectedIndex = 1;
                                [kAppDelegate.rootTabC.viewControllers[1] popToRootViewControllerAnimated:NO];
                                [kAppDelegate.rootTabC.viewControllers[1] pushViewController:chatVc animated:YES];
                                //存入数据库
                                [kAppDelegate.dataBaseQueue inDatabase:^(FMDatabase *db) {
                                    if ([kAppDelegate.dataBase open]) {
                                        NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO '%@'('%@','%@','%@','%@','%@') VALUES('%@','%@','%@','%@','%@')",@"Group",@"groupID",@"easemob_id",@"name",@"desc",@"icon",groupID,userInfo[@"chatter"],name,desc,icon];
                                        BOOL isSuccess = [kAppDelegate.dataBase executeUpdate:insertSql];
                                        if (isSuccess) {
                                            MLOG(@"插入数据成功!");
                                        } else {
                                            MLOG(@"插入数据失败!");
                                        }
                                        [kAppDelegate.dataBase close];
                                    }
                                }];
                            }
                        } andFailure:^(id failureResponse) {
                        }];
                    }
                }
            }];
        } else {
            isGroup = NO;
            chatTitle = userInfo[@"senderName"];
            ChatViewController *chatVc = [[ChatViewController alloc] initWithChatter:userInfo[@"chatter"] isGroup:isGroup];
            chatVc.title = chatTitle;
            kAppDelegate.rootTabC.selectedIndex = 1;
            [kAppDelegate.rootTabC.viewControllers[1] popToRootViewControllerAnimated:NO];
            [kAppDelegate.rootTabC.viewControllers[1] pushViewController:chatVc animated:YES];
        }
    }
}



//环信回调
#pragma mark - IChatManagerDelegate
//监听未读消息数变化的回调
- (void)didUnreadMessagesCountChanged {
    UINavigationController *dialogueNav = kAppDelegate.rootTabC.viewControllers[1];
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *str = [user objectForKey:kHavePrompt];
    NSString *skillStr = [user objectForKey:kHaveInvite];
    NSString *requireStr  = [user objectForKey:kHaveRequire];
    if ([[EaseMob sharedInstance].chatManager loadTotalUnreadMessagesCountFromDatabase] == 0 && kAppDelegate.unReadSystemMessageNum == 0 && [str integerValue] == 0 && [skillStr integerValue] == 0 && [requireStr integerValue] == 0) {
        dialogueNav.tabBarItem.badgeValue = nil;
    }
    else if ([[EaseMob sharedInstance].chatManager loadTotalUnreadMessagesCountFromDatabase] == 0 && kAppDelegate.unReadSystemMessageNum != 0 && [str integerValue] == 0 && [skillStr integerValue] == 0 && [requireStr integerValue] == 0) {
        dialogueNav.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld",(long)kAppDelegate.unReadSystemMessageNum];
    }
    else if ([[EaseMob sharedInstance].chatManager loadTotalUnreadMessagesCountFromDatabase] == 0 && kAppDelegate.unReadSystemMessageNum == 0 && [str integerValue] != 0 && [skillStr integerValue] == 0 && [requireStr integerValue] == 0) {
        dialogueNav.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld",(long)[str integerValue]];
    }
    else if ([[EaseMob sharedInstance].chatManager loadTotalUnreadMessagesCountFromDatabase] == 0 && kAppDelegate.unReadSystemMessageNum == 0 && [skillStr integerValue] != 0 && [str integerValue] == 0 && [requireStr integerValue] == 0) {
        dialogueNav.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld",(long)[skillStr integerValue]];
    }
    else if ([[EaseMob sharedInstance].chatManager loadTotalUnreadMessagesCountFromDatabase] == 0 && kAppDelegate.unReadSystemMessageNum == 0 && [requireStr integerValue] != 0 && [str integerValue] == 0 && [skillStr integerValue] == 0) {
        dialogueNav.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld",(long)[requireStr integerValue]];
    }
    else {
        if (([[EaseMob sharedInstance].chatManager loadTotalUnreadMessagesCountFromDatabase] + kAppDelegate.unReadSystemMessageNum) > 99) {
            dialogueNav.tabBarItem.badgeValue = @"99";
        } else {
            dialogueNav.tabBarItem.badgeValue = [NSString stringWithFormat:@"%lu",((unsigned long)[[EaseMob sharedInstance].chatManager loadTotalUnreadMessagesCountFromDatabase] + kAppDelegate.unReadSystemMessageNum) + [str integerValue] + [skillStr integerValue] + [requireStr integerValue]];
        }
    }
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground) {
        //提醒角标+1
//        [UIApplication sharedApplication].applicationIconBadgeNumber ++;3
    }
}


//监听发送消息的回调
- (void)didSendMessage:(EMMessage *)message error:(EMError *)error {
    //发送更新会话列表的通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LY_ReloadConversationList" object:nil];
}

//监听收到消息的回调
- (void)didReceiveMessage:(EMMessage *)message {
    //发送更新会话列表的通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LY_ReloadConversationList" object:nil];
    
    //如果程序在前台,手机产生震动
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
    
    //发送本地通知(如果程序在后台)
    BOOL isGroupChat;
    __block NSString *senderName = @"";
    NSString *chatter = @"";
    if (message.messageType == eMessageTypeGroupChat) { //如果是群聊
        isGroupChat = YES;
        chatter = message.groupSenderName;
    } else { //否则为单聊
        isGroupChat = NO;
        chatter = message.from;
    }
    [kAppDelegate.dataBaseQueue inDatabase:^(FMDatabase *db) {
        __block NSDictionary *resultDict;
        //打开数据库
        if ([kAppDelegate.dataBase open]) {
            //条件查询
            NSString *searchSql = [NSString stringWithFormat:@"SELECT * FROM '%@' WHERE userID = '%@'",@"User",chatter];
            FMResultSet *result = [kAppDelegate.dataBase executeQuery:searchSql];
            BOOL isExist = NO;
            while ([result next]) {
                isExist = YES;
                NSString *userID = [result stringForColumn:@"userID"];
                NSString *name = [result stringForColumn:@"name"];
                NSString *remark = [result stringForColumn:@"remark"];
                NSString *icon = [result stringForColumn:@"icon"];
                resultDict = @{@"userID":userID,@"name":name,@"remark":remark,@"icon":icon};
            }
            if (isExist) { //如果表中有数据
                [kAppDelegate.dataBase close];
                if (resultDict[@"remark"] && !([[NSString stringWithFormat:@"%@",resultDict[@"remark"]] isEqualToString:@""]) && !([[NSString stringWithFormat:@"%@",resultDict[@"remark"]] isEqualToString:@"(null)"])) {
                    senderName = resultDict[@"remark"];
                } else {
                    senderName = resultDict[@"name"];
                }
                //创建本地通知
                [self addLocalNotificationWithMessage:message andSenderName:senderName];
                [kAppDelegate.dataBase close];
            } else { //没有数据就去请求用户昵称并插入表中
                [kAppDelegate.dataBase close];
                [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/userFriend/getInfo",REQUESTHEADER] andParameter:@{@"user_id":[LYUserService sharedInstance].userID,@"friend_user_id":chatter} success:^(id successResponse) {
                    if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
                        NSDictionary *user = successResponse[@"data"][@"user"];
                        NSString *userID = [NSString stringWithFormat:@"%@",user[@"id"]];
                        NSString *name = [NSString stringWithFormat:@"%@",user[@"name"]];
                        NSString *remark = [NSString stringWithFormat:@"%@",user[@"remark"]];
                        NSString *icon = [NSString stringWithFormat:@"%@%@",IMAGEHEADER,user[@"icon"]];
                        resultDict = @{@"userID":userID,@"name":name,@"remark":remark,@"icon":icon};
                        if (resultDict[@"remark"] && !([[NSString stringWithFormat:@"%@",resultDict[@"remark"]] isEqualToString:@""]) && !([[NSString stringWithFormat:@"%@",resultDict[@"remark"]] isEqualToString:@"(null)"])) {
                            senderName = remark;
                        } else {
                            senderName = name;
                        }
                        //创建本地通知
                        [self addLocalNotificationWithMessage:message andSenderName:senderName];
                        //存入数据库
                        [kAppDelegate.dataBaseQueue inDatabase:^(FMDatabase *db) {
                            if ([kAppDelegate.dataBase open]) {
                                NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO '%@'('%@','%@','%@','%@') VALUES('%@','%@','%@','%@')",@"User",@"userID",@"name",@"remark",@"icon",userID,name,remark,icon];
                                BOOL isSuccess = [kAppDelegate.dataBase executeUpdate:insertSql];
                                if (isSuccess) {
                                    MLOG(@"插入数据成功!");
                                } else {
                                    MLOG(@"插入数据失败!");
                                }
                                [kAppDelegate.dataBase close];
                            }
                        }];
                    }
                } andFailure:^(id failureResponse) {
                }];
            }
        } else {
            //创建本地通知(如果打开数据库失败,则只能显示对方id,而非昵称/备注)
            [self addLocalNotificationWithMessage:message andSenderName:chatter];
        }
    }];
}


//创建本地通知
- (void)addLocalNotificationWithMessage:(EMMessage *)message andSenderName:(NSString *)senderName {
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    //设置触发时间
    NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
    notification.fireDate = fireDate;
    //设置时区
    notification.timeZone = [NSTimeZone systemTimeZone];
    //设置重复间隔(0代表不重复)
    notification.repeatInterval = 0;
    //通知内容
    id<IEMMessageBody> msgBody = [message.messageBodies firstObject];

    //聊天内容隐私判断
#ifdef kChatContentPrivacy
    notification.alertBody = @"您有一条新消息";
#else
    switch (msgBody.messageBodyType) {
        case eMessageBodyType_Text:
        {
            NSString *text = ((EMTextMessageBody *)msgBody).text;
            notification.alertBody = [NSString stringWithFormat:@"%@: %@",senderName,text];
            break;
        }
        case eMessageBodyType_Image:
        {
            notification.alertBody = [NSString stringWithFormat:@"%@ 发送了一张图片",senderName];
            break;
        }
        case eMessageBodyType_Voice:
        {
            notification.alertBody = [NSString stringWithFormat:@"%@ 发送了一段语音",senderName];
            break;
        }
        case eMessageBodyType_Location:
        {
            notification.alertBody = [NSString stringWithFormat:@"%@ 分享了一个位置",senderName];
            break;
        }
        case eMessageBodyType_Video:
        {
            notification.alertBody = [NSString stringWithFormat:@"%@ 发送了一段视频",senderName];
            break;
        }
        default:
        {
            notification.alertBody = @"您有一条新消息";
            break;
        }
    }
#endif
    notification.soundName = UILocalNotificationDefaultSoundName;
    //设置参数
    notification.userInfo = @{@"messageType":[NSString stringWithFormat:@"%ld",(long)message.messageType],@"chatter":message.conversationChatter,@"senderName":senderName};
    //执行通知
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground) {
        //提醒角标+1
        [UIApplication sharedApplication].applicationIconBadgeNumber ++;
    }
}


//监听异地登录
- (void)didLoginFromOtherDevice {
    //退出登录
    [[LYUserService sharedInstance] loginOutWithController:nil compeletionBlock:^{
        [[[UIAlertView alloc] initWithTitle:@"警告" message:@"您的账号正在异地登录,您被迫下线" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil] show];
    }];
}


//监听账号被服务器移除
- (void)didRemovedFromServer {
    //退出登录
    [[LYUserService sharedInstance] loginOutWithController:nil compeletionBlock:^{
        [[[UIAlertView alloc] initWithTitle:@"警告" message:@"您的账号已被注销,请联系客服" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil] show];
    }];
}


/**
    当自己的好友列表发生变化时回调
    1.自己通过了别人的验证时
    2.自己的验证信息被别人通过之后
    PS:自己被好友删除时不会回调此方法
 */
- (void)didUpdateBuddyList:(NSArray *)buddyList
            changedBuddies:(NSArray *)changedBuddies
                     isAdd:(BOOL)isAdd {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //更新好友列表
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMyBuddyList" object:nil];
    });
}


#pragma mark - EMChatManagerDeleagte
//当自己被好友删除后的回调
- (void)didRemovedByBuddy:(NSString *)username {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //更新好友列表
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMyBuddyList" object:nil];
    });
}


@end
