//
//  AppDelegate+UMeng.m
//  LvYue
//
//  Created by apple on 15/10/26.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import "AppDelegate+UMeng.h"
#import "LYUserService.h"
#import "MBProgressHUD+NJ.h"
#import "UMSocial.h"
#import "UMSocialQQHandler.h"
#import "UMSocialWechatHandler.h"
#import "UMessage.h"
#import <AlipaySDK/AlipaySDK.h>

@implementation AppDelegate (UMeng)

- (void)addUMengApplication:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    /****————————————————友盟分享————————————————****/
    //注册友盟
    [UMSocialData setAppKey:@"55f3983c67e58e502a00167d"];
    //由于苹果审核政策需求，建议大家对未安装客户端平台进行隐藏，在设置QQ、微信AppID之后调用下面的方法
    [UMSocialConfig hiddenNotInstallPlatforms:@[UMShareToQQ, UMShareToQzone, UMShareToWechatSession, UMShareToWechatTimeline]];
    //设置微信AppId、appSecret，分享url
    [UMSocialWechatHandler setWXAppId:@"wx9f84f81dac87502a" appSecret:@"5ef44653195a0bab9f2b0a337016ddb7" url:@"http://www.lantin.me/app/shopInfomationDetailShare.html"];
    //设置QQAppId、appKey，分享url
    [UMSocialQQHandler setQQWithAppId:@"1104779541" appKey:@"WlnLOutWeGWDLZjO" url:@"http://www.lantin.me/app/shopInfomationDetailShare.html"];


    /****————————————————友盟推送————————————————****/
    //set AppKey and AppSecret
    [UMessage startWithAppkey:@"55f3983c67e58e502a00167d" launchOptions:launchOptions];

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= _IPHONE80_
    if (kSystemVersion >= 8.0) {
        //register remoteNotification types （iOS 8.0及其以上版本）
        UIMutableUserNotificationAction *action1 = [[UIMutableUserNotificationAction alloc] init];
        action1.identifier                       = @"action1_identifier";
        action1.title                            = @"Accept";
        action1.activationMode                   = UIUserNotificationActivationModeForeground; //当点击的时候启动程序

        UIMutableUserNotificationAction *action2 = [[UIMutableUserNotificationAction alloc] init]; //第二按钮
        action2.identifier                       = @"action2_identifier";
        action2.title                            = @"Reject";
        action2.activationMode                   = UIUserNotificationActivationModeBackground; //当点击的时候不启动程序，在后台处理
        action2.authenticationRequired           = YES;                                        //需要解锁才能处理，如果action.activationMode = UIUserNotificationActivationModeForeground;则这个属性被忽略；
        action2.destructive                      = YES;

        UIMutableUserNotificationCategory *categorys = [[UIMutableUserNotificationCategory alloc] init];
        categorys.identifier                         = @"category1"; //这组动作的唯一标示
        [categorys setActions:@[action1, action2] forContext:(UIUserNotificationActionContextDefault)];

        UIUserNotificationSettings *userSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert
                                                                                     categories:[NSSet setWithObject:categorys]];
        [UMessage registerRemoteNotificationAndUserNotificationSettings:userSettings];

    } else {
        //register remoteNotification types (iOS 8.0以下)
        [UMessage registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert];
    }
#else

    //register remoteNotification types (iOS 8.0以下)
    [UMessage registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert];

#endif
    //for log
    [UMessage setLogEnabled:YES];
}


//分享回调方法
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    NSString *urlString = [url absoluteString];
    if ([urlString rangeOfString:@"pay"].location != NSNotFound) {
        return [WXApi handleOpenURL:url delegate:self]; //微信支付回调
    } else {
        return [UMSocialSnsService handleOpenURL:url]; //友盟回调
    }
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    //跳转支付宝钱包进行支付，处理支付结果
    [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
        NSLog(@"result = %@", resultDic);
    }];
    NSString *urlString = [url absoluteString];
    if ([urlString rangeOfString:@"pay"].location != NSNotFound) {
        return [WXApi handleOpenURL:url delegate:self]; //微信支付回调
    } else {
        return [UMSocialSnsService handleOpenURL:url]; //友盟回调
    }
}

- (void)onResp:(BaseResp *)resp {
    //启动微信支付的response
    if ([resp isKindOfClass:[PayResp class]]) {
        PayResp *response = (PayResp *) resp;
        if (response.errCode == 0) {
            NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
            [user setObject:@"1" forKey:@"isVip"];
            [user synchronize];
            [LYUserService sharedInstance].userDetail.isVip = [user objectForKey:@"isVip"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"WeXinPayResponse" object:@YES];
            [MBProgressHUD showSuccess:@"购买成功"];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"WeXinPayResponse" object:@NO];
            [MBProgressHUD showError:@"购买失败"];
        }
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [UMSocialSnsService applicationDidBecomeActive];
}


@end
