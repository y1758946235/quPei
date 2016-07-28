//
//  LYUserService.m
//  LvYue
//
//  Created by apple on 15/10/7.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import "LYUserService.h"
#import "LoginViewController.h"
#import "NewLoginViewController.h"
#import "RootTabBarController.h"
#import "MBProgressHUD+NJ.h"
#import "LYHttpPoster.h"
#import "MyBuddyModel.h"
#import "GroupModel.h"
#import "RootNavigationController.h"

@interface LYUserService ()

@property (nonatomic, strong) NSMutableArray *buddyArray; //好友体系的映射数组
@property (nonatomic, strong) NSMutableArray *groupArray; //群组体系的映射数组

@end

@implementation LYUserService

static LYUserService *userService;

#pragma mark - 单例创建
+ (instancetype)sharedInstance {
    
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        userService = [[self alloc] init];
        userService.userDetail = [[UserDetail alloc] init];
        userService.systemVipSwitch = [[VIPAuthoritySwitch alloc] init];
        userService.buddyArray = [NSMutableArray array];
        userService.groupArray = [NSMutableArray array];
    }) ;
    
    return userService;
}


#pragma mark - 重载用户信息
- (void)reloadUserInfo {
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    self.userID = [user objectForKey:@"userID"];
    self.mobile = [user objectForKey:@"mobile"];
    self.password = [user objectForKey:@"password"];
    //加载用户详细信息
    [self.userDetail reloadUserDetail];
}



#pragma mark - 获取登录状态执行用户回调
- (void)fetchLoginStateWithCompeletionBlock:(CHECKLOGINSTATEBLOCK)compeletionBlock {
    if ([LYUserService sharedInstance].userID && (![[LYUserService sharedInstance].userID isEqualToString:@""])) { //已经登录
        if (compeletionBlock) {
            compeletionBlock(UserLoginStateTypeAlreadyLogin);
        }
    } else { //未登录
        if (compeletionBlock) {
            compeletionBlock(UserLoginStateTypeWaitToLogin);
        }
    }
}


#pragma mark - 跳转到登录界面
- (void)jumpToLoginWithController:(UIViewController *)vc {
    if (!ISIPHONE4 && !ISIPHONE5) {
        LoginViewController *dest = [[LoginViewController alloc] init];
//        [vc presentViewController:dest animated:YES completion:nil];
        KEYWINDOW.rootViewController = [[RootNavigationController alloc] initWithRootViewController:dest];
    }else {
        NewLoginViewController *dest = [[NewLoginViewController alloc] init];
//        [vc presentViewController:dest animated:YES completion:nil];
        KEYWINDOW.rootViewController = [[RootNavigationController alloc] initWithRootViewController:dest];
    }
}


#pragma mark - 退出登录
- (void)loginOutWithController:(UIViewController *)viewController compeletionBlock:(void (^)())compeletionBlock {
    
    [MBProgressHUD showMessage:@"退出中.."];
    [[EaseMob sharedInstance].chatManager asyncLogoffWithUnbindDeviceToken:YES completion:^(NSDictionary *info, EMError *error) {
        [MBProgressHUD hideHUD];
        if (!error) {
            //抹除本地缓存
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:@"" forKey:@"auth_car"];
            [userDefaults setObject:@"" forKey:@"auth_edu"];
            [userDefaults setObject:@"" forKey:@"auth_identity"];
            [userDefaults setObject:@"" forKey:@"auth_video"];
            [userDefaults setObject:@"" forKey:@"userID"];
            [userDefaults setObject:@"" forKey:@"umengID"];
            [userDefaults setObject:@"" forKey:@"mobile"];
            [userDefaults setObject:@"" forKey:@"userName"];
            [userDefaults setObject:@"" forKey:@"sex"];
            [userDefaults setObject:@"" forKey:@"userType"];
            [userDefaults setObject:@"" forKey:@"isVip"];
            [userDefaults setObject:@"" forKey:@"password"];
            [userDefaults setObject:@"" forKey:@"alipay_Id"];
            [userDefaults setObject:@"" forKey:@"weixin_Id"];
            [userDefaults synchronize];
            
            //清除单例数据
            LYUserService *service = [LYUserService sharedInstance];
            service.userID = @"";
            service.mobile = @"";
            service.password = @"";
            service.userDetail.umengID = @"";
            service.userDetail.auth_car = @"";
            service.userDetail.auth_edu = @"";
            service.userDetail.auth_identity = @"";
            service.userDetail.auth_video = @"";
            service.userDetail.sex = @"";
            service.userDetail.userType = @"";
            service.userDetail.isVip = @"";
            
            //将登录界面设置为RootController
            
            if (!ISIPHONE4 && !ISIPHONE5) {
                LoginViewController *loginVC = [[LoginViewController alloc] init];
                KEYWINDOW.rootViewController = [[RootNavigationController alloc] initWithRootViewController:loginVC];
            }else {
                NewLoginViewController *loginVC = [[NewLoginViewController alloc] init];
                KEYWINDOW.rootViewController = [[RootNavigationController alloc] initWithRootViewController:loginVC];
            }
            
            //执行回调块
            if (compeletionBlock) {
                compeletionBlock();
            }
        } else {
            MLOG(@"EMERROR: %@",error);
            MLOG(@"INFO :%@",info);
        }
    } onQueue:nil];
}

#pragma mark - 自动登录
- (void)autoLoginWithController:(UIViewController *)viewController mobile:(NSString *)mobile password:(NSString *)password deviceType:(NSString *)deviceType deviceToken:(NSString *)deviceToken umengID:(NSString *)umengID longitude:(NSString *)longitude latitude:(NSString *)latitude{

    if (!kAppDelegate.deviceToken) {
        kAppDelegate.deviceToken = @"bb63b19106f3108798b7a271447e40df8a75c0b7cec8d99f54b43728713edc37";
    }
    if (umengID && ![umengID isEqualToString:@""]) {
        //进行第三方登录
        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/loginUmeng",REQUESTHEADER] andParameter:@{@"umeng_id":umengID,@"device_type":@"1",@"device_token":kAppDelegate.deviceToken,@"longitude":longitude,@"latitude":latitude} success:^(id successResponse) {
            MLOG(@"登录结果:%@",successResponse);
            if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
                [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:[NSString stringWithFormat:@"%@",successResponse[@"data"][@"user"][@"id"]] password:@"111111" completion:^(NSDictionary *loginInfo, EMError *error) {
                    if (!error && loginInfo) {
                        [MBProgressHUD hideHUD];
                        //设置是否自动登录
                        [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:NO];
                        NSDictionary *userDict = successResponse[@"data"];
                        //将用户信息保存在手机缓存中
                        [self saveToUserDefault:userDict password:[NSString stringWithFormat:@"%@",successResponse[@"data"][@"user"][@"password"]]];
                        
                        /*---------------- 配置apns ---------------*/
                        EMPushNotificationOptions *options = [[EaseMob sharedInstance].chatManager pushNotificationOptions];
                        //设置推送用户昵称
                        [[EaseMob sharedInstance].chatManager setApnsNickname:[NSString stringWithFormat:@"%@",successResponse[@"data"][@"user"][@"name"]]];
#ifdef kChatContentPrivacy
                        //设置推送风格(自己定制)
                        options.displayStyle = ePushNotificationDisplayStyle_simpleBanner;
#else
                        options.displayStyle = ePushNotificationDisplayStyle_messageSummary;
#endif
                        //设置推送免打扰时段
//                        options.noDisturbStatus = ePushNotificationNoDisturbStatusCustom;
//                        options.noDisturbingStartH = 23;
//                        options.noDisturbingEndH = 7;
                        //异步上传保存推送配置
                        [[EaseMob sharedInstance].chatManager asyncUpdatePushOptions:options completion:nil onQueue:nil];
                        
                        //异步更新本地数据库中的好友体系
                        [self buddyDataBaseOperation];
                        [self groupDataBaseOperation];
                        
                        //实时更新自己的未读系统消息数
                        [self getCurrentUnReadSystemMessageNumber];
                    }else{
                        [MBProgressHUD hideHUD];
                        //抹除数据,并弹回登录界面
                        [self loginOutWithController:viewController compeletionBlock:^{
                            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"自动登录失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                            [alertView show];
                        }];
                    }
                } onQueue:nil];
            } else {
                [MBProgressHUD hideHUD];
                [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
                //抹除数据,并弹回登录界面
                [self loginOutWithController:viewController compeletionBlock:^{
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"自动登录失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    [alertView show];
                }];
            }
        } andFailure:^(id failureResponse) {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"服务器繁忙,请重试"];
            //抹除数据,并弹回登录界面
            [self loginOutWithController:viewController compeletionBlock:^{
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"自动登录失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alertView show];
            }];
        }];
    } else { //手机号自动登录
        [MBProgressHUD showMessage:@"自动登录中.."];
        if (!deviceToken) {
            deviceToken = @"bb63b19106f3108798b7a271447e40df8a75c0b7cec8d99f54b43728713edc37";
        }
        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/login",REQUESTHEADER] andParameter:@{@"mobile":mobile,@"password":password,@"device_type":deviceType,@"device_token":deviceToken,@"longitude":longitude,@"latitude":latitude} success:^(id successResponse) {
            if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
                MLOG(@"登录结果:%@",successResponse);
                [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:[NSString stringWithFormat:@"%@",successResponse[@"data"][@"user"][@"id"]] password:@"111111" completion:^(NSDictionary *loginInfo, EMError *error) {
                    if (!error && loginInfo) {
                        [MBProgressHUD hideHUD];
                        //设置是否自动登录
                        [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:NO];
                        NSDictionary *userDict = successResponse[@"data"];
                        //将用户信息保存在手机缓存中
                        [self saveToUserDefault:userDict password:password];
                        
                        /*---------------- 配置apns ---------------*/
                        EMPushNotificationOptions *options = [[EaseMob sharedInstance].chatManager pushNotificationOptions];
                        //设置推送用户昵称
                        [[EaseMob sharedInstance].chatManager setApnsNickname:[NSString stringWithFormat:@"%@",successResponse[@"data"][@"user"][@"name"]]];
#ifdef kChatContentPrivacy
                        //设置推送风格(自己定制)
                        options.displayStyle = ePushNotificationDisplayStyle_simpleBanner;
#else
                        options.displayStyle = ePushNotificationDisplayStyle_messageSummary;
#endif
                        //设置推送免打扰时段
//                        options.noDisturbStatus = ePushNotificationNoDisturbStatusCustom;
//                        options.noDisturbingStartH = 23;
//                        options.noDisturbingEndH = 7;
                        //异步上传保存推送配置
                        [[EaseMob sharedInstance].chatManager asyncUpdatePushOptions:options completion:nil onQueue:nil];
                        
                        //异步更新本地数据库中的好友体系
                        [self buddyDataBaseOperation];
                        [self groupDataBaseOperation];
                        
                        //实时更新自己的未读系统消息数
                        [self getCurrentUnReadSystemMessageNumber];
                    }else{
                        [MBProgressHUD hideHUD];
                        //抹除数据,并弹回登录界面
                        [self loginOutWithController:viewController compeletionBlock:^{
                            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"自动登录失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                            [alertView show];
                        }];
                    }
                } onQueue:nil];
            } else {
                [MBProgressHUD hideHUD];
                [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
                //抹除数据,并弹回登录界面
                [self loginOutWithController:viewController compeletionBlock:^{
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"自动登录失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    [alertView show];
                }];
            }
        } andFailure:^(id failureResponse) {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"服务器繁忙,请重新登录"];
            //抹除数据,并弹回登录界面
            [self loginOutWithController:viewController compeletionBlock:^{
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"自动登录失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alertView show];
            }];
        }];
    }
}


#pragma mark - private
- (void)saveToUserDefault:(NSDictionary *)userDict password:(NSString *)password {
    @synchronized(self) {
        //将数据保存在本地
        NSDictionary *user = userDict[@"user"];
        NSDictionary *userDetail = userDict[@"userDetail"];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        //非VIP用户的聊天权限开关
        [userDefaults setObject:[NSString stringWithFormat:@"%@",userDict[@"send_switch"]] forKey:@"chatSwitch"];
        //非VIP用户的查看联系方式权限
        [userDefaults setObject:[NSString stringWithFormat:@"%@",userDict[@"check_switch"]] forKey:@"phoneSwitch"];
        //非VIP用户朋友圈的发布权限
        [userDefaults setObject:[NSString stringWithFormat:@"%@",userDict[@"notice_switch"]] forKey:@"noticeSwitch"];
        //非VIP用户播放视频的权限
        [userDefaults setObject:[NSString stringWithFormat:@"%@",userDict[@"playVideo_switch"]] forKey:@"playVideoSwitch"];
        //非VIP用户发布视频的权限
        [userDefaults setObject:[NSString stringWithFormat:@"%@",userDict[@"publishVideo_switch"]] forKey:@"publishVideoSwitch"];
        [userDefaults setObject:[NSString stringWithFormat:@"%@",user[@"auth_car"]] forKey:@"auth_car"];
        [userDefaults setObject:[NSString stringWithFormat:@"%@",user[@"auth_edu"]] forKey:@"auth_edu"];
        [userDefaults setObject:[NSString stringWithFormat:@"%@",user[@"auth_identity"]] forKey:@"auth_identity"];
        [userDefaults setObject:[NSString stringWithFormat:@"%@",user[@"auth_video"]] forKey:@"auth_video"];
        [userDefaults setObject:[NSString stringWithFormat:@"%@",user[@"id"]] forKey:@"userID"];
        [userDefaults setObject:[NSString stringWithFormat:@"%@",userDetail[@"umeng_id"]] forKey:@"umengID"];
        [userDefaults setObject:[NSString stringWithFormat:@"%@",user[@"mobile"]] forKey:@"mobile"];
        [userDefaults setObject:[NSString stringWithFormat:@"%@",user[@"name"]] forKey:@"userName"];
        [userDefaults setObject:[NSString stringWithFormat:@"%@",user[@"sex"]] forKey:@"sex"];
        [userDefaults setObject:[NSString stringWithFormat:@"%@",user[@"type"]] forKey:@"userType"];
        [userDefaults setObject:[NSString stringWithFormat:@"%@",user[@"vip"]] forKey:@"isVip"];
        [userDefaults setObject:password forKey:@"password"];
        NSString *alipayid = userDetail[@"alipay_id"];
        NSString *weixinid = userDetail[@"weixin_id"];
        if (alipayid.length > 0) {
            [userDefaults setObject:alipayid forKey:@"alipay_Id"];
        }else {
            [userDefaults setObject:@"" forKey:@"alipay_Id"];
        }
        if (weixinid.length > 0) {
            [userDefaults setObject:weixinid forKey:@"weixin_Id"];
        }else {
            [userDefaults setObject:@"" forKey:@"weixin_Id"];
        }
        [userDefaults synchronize];
        //加载单例数据
        [[LYUserService sharedInstance] reloadUserInfo];
        //加载系统开关
        [LYUserService sharedInstance].systemVipSwitch.chatSwitch = [userDefaults objectForKey:@"chatSwitch"];
        [LYUserService sharedInstance].systemVipSwitch.phoneSwitch = [userDefaults objectForKey:@"phoneSwitch"];
        [LYUserService sharedInstance].systemVipSwitch.publishSwith = [userDefaults objectForKey:@"noticeSwitch"];
        [LYUserService sharedInstance].systemVipSwitch.playVideoSwitch = [userDefaults objectForKey:@"playVideoSwitch"];
        [LYUserService sharedInstance].systemVipSwitch.publishVideoSwitch = [userDefaults objectForKey:@"publishVideoSwitch"];
        
        //插入/更新本地数据库(自己的信息)
        [kAppDelegate.dataBaseQueue inDatabase:^(FMDatabase *db) {
            if ([kAppDelegate.dataBase open]) {
                //如果在本地数据库表中没有，则插入，否则更新
                NSString *findSql = [NSString stringWithFormat:@"SELECT * FROM '%@' WHERE userID = '%@'",@"User",[LYUserService sharedInstance].userID];
                FMResultSet *result = [kAppDelegate.dataBase executeQuery:findSql];
                if ([result resultCount]) { //如果查询结果有数据
                    //更新对应数据
                    NSString *updateSql = [NSString stringWithFormat:@"UPDATE '%@' SET name = '%@',remark = '%@',icon = '%@' WHERE userID = '%@'",@"User",user[@"name"],@"",[NSString stringWithFormat:@"%@%@",IMAGEHEADER,user[@"icon"]],[LYUserService sharedInstance].userID];
                    BOOL isSuccess = [kAppDelegate.dataBase executeUpdate:updateSql];
                    if (isSuccess) {
                        MLOG(@"更新数据成功!");
                    } else {
                        MLOG(@"更新数据失败!");
                    }
                } else { //如果查询结果没有数据
                    //插入相应数据
                    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO '%@'('%@','%@','%@','%@') VALUES('%@','%@','%@','%@')",@"User",@"userID",@"name",@"remark",@"icon",[LYUserService sharedInstance].userID,user[@"name"],@"",user[@"icon"]];
                    BOOL isSuccess = [kAppDelegate.dataBase executeUpdate:insertSql];
                    if (isSuccess) {
                        MLOG(@"插入数据成功!");
                    } else {
                        MLOG(@"插入数据失败!");
                    }
                }
            } else {
                MLOG(@"更新自己的信息到本地数据库失败!");
            }
        }];
    }
}




//获取最新的未读系统消息数(自动更新tabbar的提醒数字)
- (void)getCurrentUnReadSystemMessageNumber {
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/messageSystem/numLast",REQUESTHEADER] andParameter:@{@"user_id":[LYUserService sharedInstance].userID} success:^(id successResponse) {
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            NSInteger num = [[NSString stringWithFormat:@"%@",successResponse[@"data"][@"length"]] integerValue];
            //更新对话tabbar的提示数字
            UINavigationController *nav = kAppDelegate.rootTabC.viewControllers[1];
            //得到纯未读聊天消息数
            NSInteger chatunReadMessageNum = [[EaseMob sharedInstance].chatManager loadTotalUnreadMessagesCountFromDatabase];
            kAppDelegate.unReadSystemMessageNum = num;
            NSInteger totalNum = chatunReadMessageNum + kAppDelegate.unReadSystemMessageNum;
            if (totalNum) {
                if (totalNum > 99) {
                    nav.tabBarItem.badgeValue = @"99";
                } else {
                    nav.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld",totalNum];
                }
            } else {
                nav.tabBarItem.badgeValue = nil;
            }
        }
    } andFailure:^(id failureResponse) {
    }];
}


#pragma mark - VIP权限开关
- (BOOL)canSendMessage {
    return [[LYUserService sharedInstance].systemVipSwitch.chatSwitch isEqualToString:@"1"]?NO:YES;
}

- (BOOL)canCheckPhone {
    return [[LYUserService sharedInstance].systemVipSwitch.phoneSwitch isEqualToString:@"1"]?NO:YES;
}

- (BOOL)canPublishFriend {
    return [[LYUserService sharedInstance].systemVipSwitch.publishSwith isEqualToString:@"1"]?NO:YES;
}

- (BOOL)canPlayVideo {
    return [[LYUserService sharedInstance].systemVipSwitch.playVideoSwitch isEqualToString:@"1"]?NO:YES;
}

- (BOOL)canPublishVideo {
    return [[LYUserService sharedInstance].systemVipSwitch.publishVideoSwitch isEqualToString:@"1"]?NO:YES;
}


#pragma mark - 数据库操作
//建立本地数据库的好友体系
- (void)buddyDataBaseOperation {
    //异步更新本地数据库(好友体系中的用户植入)
    [_buddyArray removeAllObjects];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/userFriend/list",REQUESTHEADER] andParameter:@{@"user_id":[LYUserService sharedInstance].userID} success:^(id successResponse) {
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            NSArray *list = successResponse[@"data"][@"list"];
            for (NSDictionary *dict in list) {
                MyBuddyModel *model = [[MyBuddyModel alloc] initWithDict:dict];
                [_buddyArray addObject:model];
            }
            [kAppDelegate.dataBaseQueue inDatabase:^(FMDatabase *db) {
                //如果数据库打开成功
                if ([kAppDelegate.dataBase open]) {
                    for (MyBuddyModel *model in _buddyArray) {
                        //如果用户模型在本地数据库表中没有，则插入，否则更新
                        NSString *findSql = [NSString stringWithFormat:@"SELECT * FROM '%@' WHERE userID = '%@'",@"User",model.buddyID];
                        FMResultSet *result = [kAppDelegate.dataBase executeQuery:findSql];
                        if ([result resultCount]) { //如果查询结果有数据
                            //更新对应数据
                            NSString *updateSql = [NSString stringWithFormat:@"UPDATE '%@' SET name = '%@',remark = '%@',icon = '%@' WHERE userID = '%@'",@"User",model.name,model.remark,model.icon,model.buddyID];
                            BOOL isSuccess = [kAppDelegate.dataBase executeUpdate:updateSql];
                            if (isSuccess) {
                                MLOG(@"更新数据成功!");
                            } else {
                                MLOG(@"更新数据失败!");
                            }
                        } else { //如果查询结果没有数据
                            //插入相应数据
                            NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO '%@'('%@','%@','%@','%@') VALUES('%@','%@','%@','%@')",@"User",@"userID",@"name",@"remark",@"icon",model.buddyID,model.name,model.remark,model.icon];
                            BOOL isSuccess = [kAppDelegate.dataBase executeUpdate:insertSql];
                            if (isSuccess) {
                                MLOG(@"插入数据成功!");
                            } else {
                                MLOG(@"插入数据失败!");
                            }
                        }
                    }
                    [kAppDelegate.dataBase close];
                } else {
                    MLOG(@"\n本地数据库更新失败\n");
                }
            }];
        } else {
            MLOG(@"\n本地数据库更新失败\n");
        }
    } andFailure:^(id failureResponse) {
        MLOG(@"\n本地数据库更新失败\n");
    }];
}


//建立本地数据库的群组体系
- (void)groupDataBaseOperation {
    //异步更新本地数据库(群组体系中的群组植入)
    [_groupArray removeAllObjects];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/group/list",REQUESTHEADER] andParameter:@{@"user_id":[LYUserService sharedInstance].userID} success:^(id successResponse) {
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            NSArray *list = successResponse[@"data"][@"list"];
            for (NSDictionary *dict in list) {
                GroupModel *model = [[GroupModel alloc] initWithDict:dict];
                [_groupArray addObject:model];
            }
            [kAppDelegate.dataBaseQueue inDatabase:^(FMDatabase *db) {
                //如果数据库打开成功
                if ([kAppDelegate.dataBase open]) {
                    for (GroupModel *model in _groupArray) {
                        //如果群组模型在本地数据库表中没有，则插入，否则更新
                        NSString *findSql = [NSString stringWithFormat:@"SELECT * FROM '%@' WHERE easemob_id = '%@'",@"Group",model.easeMob_id];
                        FMResultSet *result = [kAppDelegate.dataBase executeQuery:findSql];
                        if ([result resultCount]) { //如果查询结果有数据
                            //更新对应数据
                            NSString *updateSql = [NSString stringWithFormat:@"UPDATE '%@' SET groupID = '%@',name = '%@',desc = '%@',icon = '%@' WHERE easemob_id = '%@'",@"Group",model.groupID,model.name,model.desc,model.icon,model.easeMob_id];
                            BOOL isSuccess = [kAppDelegate.dataBase executeUpdate:updateSql];
                            if (isSuccess) {
                                MLOG(@"更新数据成功!");
                            } else {
                                MLOG(@"更新数据失败!");
                            }
                        } else { //如果查询结果没有数据
                            //插入相应数据
                            NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO '%@'('%@','%@','%@','%@','%@') VALUES('%@','%@','%@','%@','%@')",@"Group",@"groupID",@"easemob_id",@"name",@"desc",@"icon",model.groupID,model.easeMob_id,model.name,model.desc,model.icon];
                            BOOL isSuccess = [kAppDelegate.dataBase executeUpdate:insertSql];
                            if (isSuccess) {
                                MLOG(@"插入数据成功!");
                            } else {
                                MLOG(@"插入数据失败!");
                            }
                        }
                    }
                    [kAppDelegate.dataBase close];
                } else {
                    MLOG(@"\n本地数据库更新失败\n");
                }
            }];
        } else {
            MLOG(@"\n本地数据库更新失败\n");
        }
    } andFailure:^(id failureResponse) {
        MLOG(@"\n本地数据库更新失败\n");
    }];
}


@end
