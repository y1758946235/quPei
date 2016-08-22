//
//  FinishRigisterViewController.m
//  LvYue
//
//  Created by apple on 15/9/30.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import "FinishRigisterViewController.h"
#import "RootTabBarController.h"
#import "MBProgressHUD+NJ.h"
#import "LYHttpPoster.h"
#import "LYUserService.h"

@interface FinishRigisterViewController ()
{
    NSString *inviteCode;
}

/**
 *  可选参数
 */
@property (nonatomic, copy) NSString *sex; //男0 女1

@end

@implementation FinishRigisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _finishRigister.layer.cornerRadius = 5.0;
    _finishRigister.clipsToBounds = YES;
    _boyBtn.layer.cornerRadius = 11;
    _boyBtn.clipsToBounds = YES;
    _girlBtn.layer.cornerRadius = 11;
    _girlBtn.clipsToBounds = YES;
    _boyBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _boyBtn.layer.borderWidth = 0.5;
    _girlBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _girlBtn.layer.borderWidth = 0.5;
    
    //如果有传递过来的用户昵称,则显示默认的用户昵称
    if (_userName) {
        self.userNameField.text = _userName;
    }
    
    //设置默认性别 - 女
    _sex = @"1";
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}


- (IBAction)selectBoy:(UIButton *)sender {
    [_girlBtn setBackgroundImage:nil forState:UIControlStateNormal];
    [_boyBtn setBackgroundImage:[UIImage imageNamed:@"Selected"] forState:UIControlStateNormal];
    _sex = @"0";
}

- (IBAction)selectGirl:(UIButton *)sender {
    [_boyBtn setBackgroundImage:nil forState:UIControlStateNormal];
    [_girlBtn setBackgroundImage:[UIImage imageNamed:@"Selected"] forState:UIControlStateNormal];
    _sex = @"1";
}

- (IBAction)finishRigister:(UIButton *)sender {

    if (_userNameField.text.length == 0) {
        [MBProgressHUD showError:@"昵称不能为空!"];
        return;
    }
    if (_userNameField.text.length > 15 || ([_userNameField.text rangeOfString:@" "].location != NSNotFound)) {
        [MBProgressHUD showError:@"昵称不能含有空格且不能超过15个字符!"];
        return;
    }
    if (!_sex) {
        [MBProgressHUD showError:@"性别不能为空!"];
        return;
    }
    //判断是否是友盟第三方注册
    if (_umeng_id) {
        [MBProgressHUD showMessage:@"正在登录.." toView:self.view];
        if (!kAppDelegate.deviceToken) {
            kAppDelegate.deviceToken = @"bb63b19106f3108798b7a271447e40df8a75c0b7cec8d99f54b43728713edc37";
        }
        //友盟注册
        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/umengRegister",REQUESTHEADER] andParameter:@{@"umeng_id":_umeng_id,@"name":_userNameField.text,@"sex":_sex,@"device_type":@"1",@"device_token":kAppDelegate.deviceToken,@"inviteCode":self.inviteCodeTextField.text} success:^(id successResponse) {
            MLOG(@"注册结果:%@",successResponse);
            if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
                //自动进行登录
                [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/loginUmeng",REQUESTHEADER] andParameter:@{@"umeng_id":_umeng_id,@"device_type":@"1",@"device_token":kAppDelegate.deviceToken} success:^(id successResponse) {
                    if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
                        [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:[NSString stringWithFormat:@"%@",successResponse[@"data"][@"user"][@"id"]] password:@"111111" completion:^(NSDictionary *loginInfo, EMError *error) {
                            if (!error && loginInfo) {
                                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                //设置是否自动登录
                                [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:NO];
                                NSDictionary *userDict = successResponse[@"data"];
                                //将用户信息保存在手机缓存中
                                [self saveToUserDefault:userDict];
                                RootTabBarController *rootVc = [[RootTabBarController alloc] init];
                                kAppDelegate.rootTabC = rootVc;
                                KEYWINDOW.rootViewController = rootVc;
                                rootVc.selectedIndex = 0;
                                
                                /*---------------- 配置apns ---------------*/
                                EMPushNotificationOptions *options = [[EaseMob sharedInstance].chatManager pushNotificationOptions];
                                //设置推送用户昵称
                                [[EaseMob sharedInstance].chatManager setApnsNickname:[NSString stringWithFormat:@"%@",successResponse[@"data"][@"user"][@"n ame"]]];
                                //设置推送风格(自己定制)
                                options.displayStyle = ePushNotificationDisplayStyle_messageSummary;
                                //设置推送免打扰时段
//                                options.noDisturbStatus = ePushNotificationNoDisturbStatusCustom;
//                                options.noDisturbingStartH = 23;
//                                options.noDisturbingEndH = 7;
                                //异步上传保存推送配置
                                [[EaseMob sharedInstance].chatManager asyncUpdatePushOptions:options completion:nil onQueue:nil];
                            }else{
                                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"登录失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                                [alertView show];
                            }
                        } onQueue:nil];
                    } else {
                        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    }
                } andFailure:^(id failureResponse) {
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    [MBProgressHUD showError:@"服务器繁忙,请重试"];
                }];
            } else {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
            }
        } andFailure:^(id failureResponse) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [MBProgressHUD showError:@"服务器繁忙,请重试"];
        }];
    } else {
        [MBProgressHUD showMessage:@"注册中.."];
        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/register",REQUESTHEADER] andParameter:@{@"mobile":_mobile,@"password":_password,@"captcha":_checkNum,@"name":_userNameField.text,@"sex":_sex} success:^(id successResponse) {
            MLOG(@"注册结果:%@",successResponse);
            if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
                [MBProgressHUD hideHUD];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"dismissRigisterView" object:nil];
                [MBProgressHUD showSuccess:@"注册成功"];
            } else {
                [MBProgressHUD hideHUD];
                [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        } andFailure:^(id failureResponse) {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"服务器繁忙,请重试"];
        }];
    }
}

- (IBAction)back:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        [MBProgressHUD hideHUD];
    }];
}


#pragma mark - private
- (void)saveToUserDefault:(NSDictionary *)userDict {
    @synchronized(self) {
        //将数据保存在本地
        NSDictionary *user = userDict[@"user"];
        NSDictionary *userDetail = userDict[@"userDetail"];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        //非VIP用户的聊天权限开关
        [userDefaults setObject:[NSString stringWithFormat:@"%@",userDict[@"send_switch"]] forKey:@"chatSwitch"];
        //非VIP用户的查看联系方式权限
        [userDefaults setObject:[NSString stringWithFormat:@"%@",userDict[@"check_switch"]] forKey:@"phoneSwitch"];
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
        [userDefaults setObject:[NSString stringWithFormat:@"%@",user[@"password"]] forKey:@"password"];
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
    }
}


@end
