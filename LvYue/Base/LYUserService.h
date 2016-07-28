//
//  LYUserService.h
//  LvYue
//
//  Created by apple on 15/10/7.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserDetail.h"
#import "LoginViewController.h"
#import "VIPAuthoritySwitch.h"

#define COMPELETIONBLOCK void(^)()
#define CHECKLOGINSTATEBLOCK void(^)(UserLoginStateType type)

typedef NS_ENUM(NSInteger, UserLoginStateType) {
    UserLoginStateTypeAlreadyLogin = 1,     //已经登录
    UserLoginStateTypeWaitToLogin = 0       //未登录
};

/**
 *  豆客用户单例
 */

@interface LYUserService : NSObject

@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *mobile; //手机号==登录名
@property (nonatomic, copy) NSString *password;
@property (nonatomic, strong) UserDetail *userDetail; //用户详情
@property (nonatomic, strong) VIPAuthoritySwitch *systemVipSwitch; //默认的非VIP权限控制

//获取单例
+ (instancetype)sharedInstance;

//重载用户缓存的信息
- (void)reloadUserInfo;

//因为Token过期、异地登录或账号被修改/用户手动退出登录 调用
- (void)loginOutWithController:(UIViewController *)viewController compeletionBlock:(COMPELETIONBLOCK)compeletionBlock;

//自动登录(首页进入)
- (void)autoLoginWithController:(UIViewController *)viewController mobile:(NSString *)mobile password:(NSString *)password deviceType:(NSString *)deviceType deviceToken:(NSString *)deviceToken umengID:(NSString *)umengID longitude:(NSString *)longitude latitude:(NSString *)latitude;

//获取自己的未读系统消息数量(自动更新tabbar的提醒数字)
- (void)getCurrentUnReadSystemMessageNumber;

//验证是否处于登录状态
- (void)fetchLoginStateWithCompeletionBlock:(CHECKLOGINSTATEBLOCK)compeletionBlock;

//present登录界面
- (void)jumpToLoginWithController:(UIViewController *)vc;

/***********  权限相关 ************/
//查看当前的非VIP发送消息权限
- (BOOL)canSendMessage;

//查看当前的非VIP查看别人联系方式的权限
- (BOOL)canCheckPhone;

//查看当前的朋友圈发布权限
- (BOOL)canPublishFriend;

//播放视频圈视频的权限
- (BOOL)canPlayVideo;

//发布视频圈视频的权限
- (BOOL)canPublishVideo;

@end
