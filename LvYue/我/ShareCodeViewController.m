//
//  ShareCodeViewController.m
//  LvYue
//
//  Created by 広有射怪鸟事 on 15/12/15.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import "ShareCodeViewController.h"
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "MBProgressHUD+NJ.h"
#import "UMSocial.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import "WXApi.h"

@interface ShareCodeViewController ()
{
    NSString *code;
    NSString *getUrl;
}

@end

@implementation ShareCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"分享邀请码";
    
    getUrl = [NSString stringWithFormat:@"%@/assets/invite_code?user_id=%@",REQUESTHEADER,[LYUserService sharedInstance].userID];
    
    [self getData];
    
}

- (void)getData{
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/getInvite",REQUESTHEADER] andParameter:@{@"user_id":[NSString stringWithFormat:@"%@",[LYUserService sharedInstance].userID]} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            code = successResponse[@"msg"];
            self.codeLabel.text = code;
        } else {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
}

- (IBAction)shareFriend:(UIButton *)sender {
    
    [UMSocialData defaultData].extConfig.wechatTimelineData.url = getUrl;
    
    //使用UMShareToWechatSession,UMShareToWechatTimeline,UMShareToWechatFavorite分别代表微信好友、微信朋友圈、微信收藏
    [UMSocialData defaultData].extConfig.wechatTimelineData.title = @"我分享了一个邀请码";
    [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToWechatTimeline] content:@"我分享了一个豆客邀请码，快来注册吧" image:[UIImage imageNamed:@"logo108"] location:nil urlResource:nil presentedController:self completion:^(UMSocialResponseEntity *response){
        if (response.responseCode == UMSResponseCodeSuccess) {
            NSLog(@"分享成功！");
            [MBProgressHUD showSuccess:@"分享成功"];
        }
    }];
}

- (IBAction)shareWeixin:(UIButton *)sender {
    
    if ([WXApi isWXAppInstalled]) {
        [UMSocialData defaultData].extConfig.wechatSessionData.url = getUrl;
        
        //使用UMShareToWechatSession,UMShareToWechatTimeline,UMShareToWechatFavorite分别代表微信好友、微信朋友圈、微信收藏
        [UMSocialData defaultData].extConfig.wechatSessionData.title = @"我分享了一个邀请码";
        [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToWechatSession] content:@"我分享了一个豆客邀请码，快来注册吧" image:[UIImage imageNamed:@"logo108"] location:nil urlResource:nil presentedController:self completion:^(UMSocialResponseEntity *response){
            if (response.responseCode == UMSResponseCodeSuccess) {
                NSLog(@"分享成功！");
                [MBProgressHUD showSuccess:@"分享成功"];
            }
        }];
    } else {
        [MBProgressHUD showError:@"分享失败-您并未安装手机微信客户端"];
    }
}

- (IBAction)shareQQ:(UIButton *)sender {
    
    if ([QQApiInterface isQQInstalled]) {
        [UMSocialData defaultData].extConfig.qqData.url = getUrl;
        
        [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToQQ] content:@"我分享了一个豆客邀请码，快来注册吧" image:[UIImage imageNamed:@"logo108"] location:nil urlResource:nil presentedController:self completion:^(UMSocialResponseEntity *response){
            if (response.responseCode == UMSResponseCodeSuccess) {
                NSLog(@"分享成功！");
                [MBProgressHUD showSuccess:@"分享成功"];
            }
        }];
    } else {
        [MBProgressHUD showError:@"分享失败-您并未安装手机QQ客户端"];
    }
}

- (IBAction)shareWeibo:(UIButton *)sender {
    
    [MBProgressHUD showMessage:nil];
    UMSocialUrlResource *urlResource = [[UMSocialUrlResource alloc] initWithSnsResourceType:UMSocialUrlResourceTypeImage url:
                                        getUrl];
    [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToSina] content:@"我分享了一个豆客邀请码，快来注册吧" image:[UIImage imageNamed:@"logo108"] location:nil urlResource:urlResource presentedController:self completion:^(UMSocialResponseEntity *shareResponse){
        if (shareResponse.responseCode == UMSResponseCodeSuccess) {
            [MBProgressHUD hideHUD];
            NSLog(@"分享成功！");
            [MBProgressHUD showSuccess:@"分享成功"];
        }
    }];
    
}
@end
