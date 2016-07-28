//
//  LoginViewController.m
//  LvYue
//
//  Created by apple on 15/9/28.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import "LoginViewController.h"
#import "NewRigisterViewController.h"
#import "ForgetPasswordController.h"
#import "FinishRigisterViewController.h"
#import "RootTabBarController.h"
#import "LYHttpPoster.h"
#import "MBProgressHUD+NJ.h"
#import "LYUserService.h"
#import "UMSocial.h"
#import "NewFinishRigisterViewController.h"
#import "MyBuddyModel.h"
#import "GroupModel.h"
#import "ThirdRegisterViewController.h"

@interface LoginViewController ()<CLLocationManagerDelegate>{
    NSString *longitude;//经纬度
    NSString *latitude;
}

@property (nonatomic, strong) NSMutableArray *buddyArray; //与本地数据库映射的用户数组
@property (nonatomic, strong) NSMutableArray *groupArray; //与本地数据库映射的群组数组

//定位信息管理者
@property (nonatomic, strong) CLLocationManager *clManager;


@property (nonatomic, copy) NSString *gender;  //性别  1
@property (nonatomic, copy) NSString* profile_image_url;//头像

@end

@implementation LoginViewController

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

#pragma mark - 获取城市位置

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations{
    [_clManager stopUpdatingLocation];
    CLLocation *currentLocation = [locations lastObject];
    
    latitude = [NSString stringWithFormat:@"%f",currentLocation.coordinate.latitude];
    longitude = [NSString stringWithFormat:@"%f",currentLocation.coordinate.longitude];
    
    //停止定位
    [_clManager stopUpdatingLocation];
    
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        //用户允许授权,开启定位
        [_clManager startUpdatingLocation];
    } else {
        //        [MBProgressHUD showError:@"用户拒绝授权,请在设置中开启"];
        longitude = @"120.027860";
        latitude = @"30.245586";
    }
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [MBProgressHUD showError:@"定位失败,请重试"];
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
    _buddyArray = [NSMutableArray array];
    _groupArray = [NSMutableArray array];
    
    UIImageView *numberIcon = [[UIImageView alloc] initWithFrame:CGRectMake(15, 7.5, 14, 25)];
    numberIcon.image = [UIImage imageNamed:@"手机"];
    
    UIImageView *passWordIcon = [[UIImageView alloc] initWithFrame:CGRectMake(15, 7.5, 13, 25)];
    passWordIcon.image = [UIImage imageNamed:@"密码"];
    
    UIView *number = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
    [number addSubview:numberIcon];
    UIView *password = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
    [password addSubview:passWordIcon];
    
    _phoneField.leftView = number;
    _phoneField.leftViewMode = UITextFieldViewModeAlways;
    _passwordField.leftView = password;
    _passwordField.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(30, 294, SCREEN_WIDTH - 60, 1)];
    line1.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
    [self.view addSubview:line1];
    
    UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(30, 344, SCREEN_WIDTH - 60, 1)];
    line2.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
    [self.view addSubview:line2];
    
    self.clManager.delegate = self;
    self.clManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 8.0) {
        //前台和后台都允许请求用户是否允许开启定位 IOS8.0以上版本需要设置环境参数
        [_clManager requestWhenInUseAuthorization];
        [_clManager startUpdatingLocation];
    }
    else {
        //如果是IOS8.0以下的版本，则可直接开启定位
        [_clManager startUpdatingLocation];
    }

}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self.view endEditing:YES];
}

- (IBAction)rigister:(UIButton *)sender {
    if (!longitude) {
        longitude = @"";
    }
    if (!latitude) {
        latitude = @"";
    }
//    [self presentViewController:[[NewRigisterViewController alloc] init] animated:YES completion:nil];
    NewRigisterViewController *vc = [[NewRigisterViewController alloc] init];
    vc.isForgetPassword = NO;
    vc.latitude = latitude;
    vc.longitude = longitude;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)forgetPassword:(UIButton *)sender {
    
    NewRigisterViewController *vc = [[NewRigisterViewController alloc] init];
    vc.isForgetPassword = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)login:(UIButton *)sender {
    if (!longitude) {
        longitude = @"";
    }
    if (!latitude) {
        latitude = @"";
    }
    if (_phoneField.text.length == 0) {
        [MBProgressHUD showError:@"手机号不能为空!"];
        return;
    }
    if (_passwordField.text.length == 0) {
        [MBProgressHUD showError:@"密码不能为空!"];
        return;
    }
    if ([_passwordField.text isEqualToString:@"00000000000"]) {
        [MBProgressHUD showError:@"手机号不符合规范!"];
        return;
    }
    [MBProgressHUD showMessage:@"登录中..."];
    MLOG(@"DEVICETOKEN : %@",kAppDelegate.deviceToken);
    if (!kAppDelegate.deviceToken) {
        kAppDelegate.deviceToken = @"bb63b19106f3108798b7a271447e40df8a75c0b7cec8d99f54b43728713edc37";
    }
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/login",REQUESTHEADER] andParameter:@{@"mobile":_phoneField.text,@"password":_passwordField.text,@"device_type":@"1",@"device_token":kAppDelegate.deviceToken,@"longitude":longitude,@"latitude":latitude} success:^(id successResponse) {
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            MLOG(@"登录结果:%@",successResponse);
            [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:[NSString stringWithFormat:@"%@",successResponse[@"data"][@"user"][@"id"]] password:@"111111" completion:^(NSDictionary *loginInfo, EMError *error) {
                if (!error && loginInfo) {
                    [MBProgressHUD hideHUD];
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
                    [[EaseMob sharedInstance].chatManager setApnsNickname:[NSString stringWithFormat:@"%@",successResponse[@"data"][@"user"][@"name"]]];
#ifdef kChatContentPrivacy
                    //设置推送风格(自己定制)
                    options.displayStyle = ePushNotificationDisplayStyle_simpleBanner;
#else
                    options.displayStyle = ePushNotificationDisplayStyle_messageSummary;
#endif
                    //设置推送免打扰时段
//                    options.noDisturbStatus = ePushNotificationNoDisturbStatusCustom;
//                    options.noDisturbingStartH = 23;
//                    options.noDisturbingEndH = 7;
                    //异步上传保存推送配置
                    [[EaseMob sharedInstance].chatManager asyncUpdatePushOptions:options completion:nil onQueue:nil];
                    
                    //异步更新本地数据库(好友体系中的用户和群组植入)
                    [self buddyDataBaseOperation];
                    [self groupDataBaseOperation];
                    
                    //实时更新自己的未读系统消息数
                    [[LYUserService sharedInstance] getCurrentUnReadSystemMessageNumber];
                }else{
                    [MBProgressHUD hideHUD];
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"登录失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    [alertView show];
                }
            } onQueue:nil];
        } else {
            [MBProgressHUD hideHUD];
            //创建抖动效果
            CAKeyframeAnimation *keyFrame = [CAKeyframeAnimation animationWithKeyPath:@"position"];
            CGPoint startPosition = self.passwordField.layer.position;
            //设置各个关键帧位置
            keyFrame.values = @[[NSValue valueWithCGPoint:CGPointMake(startPosition.x, startPosition.y)],
                                [NSValue valueWithCGPoint:CGPointMake(startPosition.x - 10, startPosition.y)],
                                [NSValue valueWithCGPoint:CGPointMake(startPosition.x + 10, startPosition.y)],
                                [NSValue valueWithCGPoint:CGPointMake(startPosition.x - 10, startPosition.y)],
                                [NSValue valueWithCGPoint:CGPointMake(startPosition.x + 10, startPosition.y)],
                                [NSValue valueWithCGPoint:CGPointMake(startPosition.x - 10, startPosition.y)],
                                [NSValue valueWithCGPoint:CGPointMake(startPosition.x + 10, startPosition.y)],
                                [NSValue valueWithCGPoint:CGPointMake(startPosition.x - 10, startPosition.y)],
                                [NSValue valueWithCGPoint:CGPointMake(startPosition.x + 10, startPosition.y)],
                                [NSValue valueWithCGPoint:CGPointMake(startPosition.x - 10, startPosition.y)],
                                [NSValue valueWithCGPoint:CGPointMake(startPosition.x + 10, startPosition.y)],
                                [NSValue valueWithCGPoint:CGPointMake(startPosition.x, startPosition.y)]];
            //淡入淡出效果
            keyFrame.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            //动画持续时间
            keyFrame.duration = 0.8;
            //恢复到最初位置
            self.passwordField.layer.position = startPosition;
            //加入动画
            [self.passwordField.layer addAnimation:keyFrame forKey:@"keyFrame"];
            
            //创建抖动效果2
            CAKeyframeAnimation *keyFrame2 = [CAKeyframeAnimation animationWithKeyPath:@"position"];
            CGPoint startPosition2 = self.phoneField.layer.position;
            //设置各个关键帧位置
            keyFrame2.values = @[[NSValue valueWithCGPoint:CGPointMake(startPosition2.x, startPosition2.y)],
                                [NSValue valueWithCGPoint:CGPointMake(startPosition2.x - 10, startPosition2.y)],
                                [NSValue valueWithCGPoint:CGPointMake(startPosition2.x + 10, startPosition2.y)],
                                [NSValue valueWithCGPoint:CGPointMake(startPosition2.x - 10, startPosition2.y)],
                                [NSValue valueWithCGPoint:CGPointMake(startPosition2.x + 10, startPosition2.y)],
                                [NSValue valueWithCGPoint:CGPointMake(startPosition2.x - 10, startPosition2.y)],
                                [NSValue valueWithCGPoint:CGPointMake(startPosition2.x + 10, startPosition2.y)],
                                [NSValue valueWithCGPoint:CGPointMake(startPosition2.x - 10, startPosition2.y)],
                                [NSValue valueWithCGPoint:CGPointMake(startPosition2.x + 10, startPosition2.y)],
                                [NSValue valueWithCGPoint:CGPointMake(startPosition2.x - 10, startPosition2.y)],
                                [NSValue valueWithCGPoint:CGPointMake(startPosition2.x + 10, startPosition2.y)],
                                [NSValue valueWithCGPoint:CGPointMake(startPosition2.x, startPosition2.y)]];
            //淡入淡出效果
            keyFrame2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            //动画持续时间
            keyFrame2.duration = 0.8;
            //恢复到最初位置
            self.phoneField.layer.position = startPosition2;
            //加入动画
            [self.phoneField.layer addAnimation:keyFrame2 forKey:@"keyFrame2"];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUD];
        });
    
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
}

- (IBAction)ThirdLogin:(UIButton *)sender {
    if (!longitude) {
        longitude = @"";
    }
    if (!latitude) {
        latitude = @"";
    }
    if (!kAppDelegate.deviceToken) {
        kAppDelegate.deviceToken = @"bb63b19106f3108798b7a271447e40df8a75c0b7cec8d99f54b43728713edc37";
    }
    if (sender.tag == 100) {
        //微博登录
        
        UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToSina];
        snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
            //获取微博用户名、uid、token等
            if (response.responseCode == UMSResponseCodeSuccess) {
                UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary] valueForKey:UMShareToSina];
                NSLog(@"~~~~~~~~~~~~~~微博用户信息:username is %@, uid is %@, token is %@ url is %@",snsAccount.userName,snsAccount.usid,snsAccount.accessToken,snsAccount.iconURL);
                [MBProgressHUD showMessage:@"登录中.." toView:self.view];
                //进行第三方登录
                [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/loginUmeng",REQUESTHEADER] andParameter:@{@"umeng_id":snsAccount.usid,@"device_type":@"1",@"device_token":kAppDelegate.deviceToken,@"longitude":longitude,@"latitude":latitude} success:^(id successResponse) {
                    MLOG(@"微博 的 登录结果:%@",successResponse);
                    MLOG(@"信息 : %@",successResponse[@"msg"]);
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
                                [[EaseMob sharedInstance].chatManager setApnsNickname:[NSString stringWithFormat:@"%@",successResponse[@"data"][@"user"][@"name"]]];
#ifdef kChatContentPrivacy
                                //设置推送风格(自己定制)
                                options.displayStyle = ePushNotificationDisplayStyle_simpleBanner;
#else
                                options.displayStyle = ePushNotificationDisplayStyle_messageSummary;
#endif
                                //设置推送免打扰时段
//                                options.noDisturbStatus = ePushNotificationNoDisturbStatusCustom;
//                                options.noDisturbingStartH = 23;
//                                options.noDisturbingEndH = 7;
                                //异步上传保存推送配置
                                [[EaseMob sharedInstance].chatManager asyncUpdatePushOptions:options completion:nil onQueue:nil];
                                
                                //异步更新本地数据库(好友体系中的用户和群组植入)
                                [self buddyDataBaseOperation];
                                [self groupDataBaseOperation];
                                
                                //实时更新自己的未读系统消息数
                                [[LYUserService sharedInstance] getCurrentUnReadSystemMessageNumber];
                            }else{
                                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"登录失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                                [alertView show];
                            }
                        } onQueue:nil];
                    } else {
                        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                        NewFinishRigisterViewController *dest = [[NewFinishRigisterViewController alloc] init];
                        dest.umeng_id = snsAccount.usid;
                        dest.userName = snsAccount.userName;
                        dest.longitude = longitude;
                        dest.latitude = latitude;
                        [self.navigationController pushViewController:dest animated:YES];
                    }
                } andFailure:^(id failureResponse) {
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    [MBProgressHUD showError:@"服务器繁忙,请重试"];
                }];
            }});
        //获取accestoken以及新浪用户信息，得到的数据在回调Block对象形参respone的data属性
        [[UMSocialDataService defaultDataService] requestSnsInformation:UMShareToSina  completion:^(UMSocialResponseEntity *response){
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            NSLog(@"SnsInformation is %@",response.data);
        }];
    } else if (sender.tag == 101) {
        //QQ登录
        UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToQQ];
        snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
            //获取QQ用户名、uid、token等
            if (response.responseCode == UMSResponseCodeSuccess) {
                UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary] valueForKey:UMShareToQQ];
                NSLog(@"~~~~~~~~~~~~~~QQ用户信息:username is %@, uid is %@, token is %@ url is %@",snsAccount.userName,snsAccount.usid,snsAccount.accessToken,snsAccount.iconURL);
                [MBProgressHUD showMessage:@"登录中.." toView:self.view];
                //进行第三方登录
                [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/loginUmeng",REQUESTHEADER] andParameter:@{@"umeng_id":snsAccount.usid,@"device_type":@"1",@"device_token":kAppDelegate.deviceToken,@"longitude":longitude,@"latitude":latitude} success:^(id successResponse) {
                    MLOG(@"QQ 的 登录结果:%@",successResponse);
                    MLOG(@"信息 : %@",successResponse[@"msg"]);
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
                                [[EaseMob sharedInstance].chatManager setApnsNickname:[NSString stringWithFormat:@"%@",successResponse[@"data"][@"user"][@"name"]]];
#ifdef kChatContentPrivacy
                                //设置推送风格(自己定制)
                                options.displayStyle = ePushNotificationDisplayStyle_simpleBanner;
#else
                                options.displayStyle = ePushNotificationDisplayStyle_messageSummary;
#endif
                                //设置推送免打扰时段
//                                options.noDisturbStatus = ePushNotificationNoDisturbStatusCustom;
//                                options.noDisturbingStartH = 23;
//                                options.noDisturbingEndH = 7;
                                //异步上传保存推送配置
                                [[EaseMob sharedInstance].chatManager asyncUpdatePushOptions:options completion:nil onQueue:nil];
                                
                                //异步更新本地数据库(好友体系中的用户和群组植入)
                                [self buddyDataBaseOperation];
                                [self groupDataBaseOperation];
                                
                                //实时更新自己的未读系统消息数
                                [[LYUserService sharedInstance] getCurrentUnReadSystemMessageNumber];
                            }else{
                                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示"
                                                                                   message:@"登录失败"
                                                                                  delegate:self
                                                                         cancelButtonTitle:@"确定"
                                                                         otherButtonTitles:nil];
                                [alertView show];
                            }
                        } onQueue:nil];
                    } else {
                        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                        //NewFinishRigisterViewController *dest = [[NewFinishRigisterViewController alloc] init];
                        ThirdRegisterViewController *dest = [[ThirdRegisterViewController alloc] init];
                        dest.umeng_id = snsAccount.usid;
                        dest.nickName = [NSString stringWithFormat:@"%@", snsAccount.userName];
                        dest.longitude = [NSString stringWithFormat:@"%@", longitude];
                        dest.latitude = [NSString stringWithFormat:@"%@", latitude];
                        //dest.accessToken = snsAccount.accessToken;
                        dest.sex = [NSString stringWithFormat:@"%@",self.gender];
                        dest.icon = [NSString stringWithFormat:@"%@", self.profile_image_url];
                        [self.navigationController pushViewController:dest animated:YES];
                        //[self presentViewController:dest animated:YES completion:nil];
                    }
                } andFailure:^(id failureResponse) {
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    [MBProgressHUD showError:@"服务器繁忙,请重试"];
                }];
            }});
        //获取accestoken以及QQ用户信息，得到的数据在回调Block对象形参respone的data属性
        [[UMSocialDataService defaultDataService] requestSnsInformation:UMShareToWechatSession  completion:^(UMSocialResponseEntity *response){
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            NSLog(@"SnsInformation is %@",response.data);
            self.gender = response.data[@"gender"];
            //NSString* location = response.data[@"location"];
            self.profile_image_url = response.data[@"profile_image_url"];
            MLOG(@"当前执行线程 : %@",[NSThread currentThread]);
        }];
    } else {
        //微信登录
        UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToWechatSession];
        snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
            if (response.responseCode == UMSResponseCodeSuccess) {
                UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary]valueForKey:UMShareToWechatSession];
                NSLog(@"~~~~~~~~~~~~~~微信用户信息:username is %@, uid is %@, token is %@ url is %@",snsAccount.userName,snsAccount.usid,snsAccount.accessToken,snsAccount.iconURL);
                [MBProgressHUD showMessage:@"登录中.." toView:self.view];
                //进行第三方登录
                [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/loginUmeng",REQUESTHEADER] andParameter:@{@"umeng_id":snsAccount.usid,@"device_type":@"1",@"device_token":kAppDelegate.deviceToken,@"longitude":longitude,@"latitude":latitude} success:^(id successResponse) {
                    MLOG(@"微信 的 登录结果:%@",successResponse);
                    MLOG(@"信息 : %@",successResponse[@"msg"]);
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
                                [[EaseMob sharedInstance].chatManager setApnsNickname:[NSString stringWithFormat:@"%@",successResponse[@"data"][@"user"][@"name"]]];
#ifdef kChatContentPrivacy
                                //设置推送风格(自己定制)
                                options.displayStyle = ePushNotificationDisplayStyle_simpleBanner;
#else
                                options.displayStyle = ePushNotificationDisplayStyle_messageSummary;
#endif
                                //设置推送免打扰时段
//                                options.noDisturbStatus = ePushNotificationNoDisturbStatusCustom;
//                                options.noDisturbingStartH = 23;
//                                options.noDisturbingEndH = 7;
                                //异步上传保存推送配置
                                [[EaseMob sharedInstance].chatManager asyncUpdatePushOptions:options completion:nil onQueue:nil];
                                
                                //异步更新本地数据库(好友体系中的用户和群组植入)
                                [self buddyDataBaseOperation];
                                [self groupDataBaseOperation];
                                
                                //实时更新自己的未读系统消息数
                                [[LYUserService sharedInstance] getCurrentUnReadSystemMessageNumber];
                            }else{
                                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"登录失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                                [alertView show];
                            }
                        } onQueue:nil];
                    } else {
                        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                        ThirdRegisterViewController *dest = [[ThirdRegisterViewController alloc] init];
                        dest.umeng_id = snsAccount.usid;
                        dest.nickName = [NSString stringWithFormat:@"%@", snsAccount.userName];
                        dest.longitude = [NSString stringWithFormat:@"%@", longitude];
                        dest.latitude = [NSString stringWithFormat:@"%@", latitude];
                        //dest.accessToken = snsAccount.accessToken;
                        dest.sex = [NSString stringWithFormat:@"%@", self.gender];
                        dest.icon = [NSString stringWithFormat:@"%@", self.profile_image_url];
                        [self.navigationController pushViewController:dest animated:YES];

                    }
                } andFailure:^(id failureResponse) {
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    [MBProgressHUD showError:@"服务器繁忙,请重试"];
                }];
            }});
        //得到的数据在回调Block对象形参respone的data属性
        [[UMSocialDataService defaultDataService] requestSnsInformation:UMShareToWechatSession  completion:^(UMSocialResponseEntity *response){
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            NSLog(@"SnsInformation is %@",response.data);
            self.gender = response.data[@"gender"];
            //NSString* location = response.data[@"location"];
            self.profile_image_url = response.data[@"profile_image_url"];
        }];
    }
}


//游客进入
- (IBAction)visitorEnter:(UIButton *)sender {
    //直接进入主页
    RootTabBarController *rootVc = [[RootTabBarController alloc] init];
    kAppDelegate.rootTabC = rootVc;
    KEYWINDOW.rootViewController = rootVc;
    rootVc.selectedIndex = 0;
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
        //非VIP用户的朋友圈发布权限
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
        [userDefaults setObject:_passwordField.text forKey:@"password"];
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
                    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO '%@'('%@','%@','%@','%@') VALUES('%@','%@','%@','%@')",@"User",@"userID",@"name",@"remark",@"icon",[LYUserService sharedInstance].userID,user[@"name"],@"",[NSString stringWithFormat:@"%@%@",IMAGEHEADER,user[@"icon"]]];
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
