//
//  NewLoginViewController.m
//  LvYue
//
//  Created by 郑洲 on 16/3/15.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "NewLoginViewController.h"
#import "LYFactory.h"
#import "MBProgressHUD+NJ.h"

#import "UMSocial.h"
#import "DialogueViewController.h"
#import "RootNavigationController.h"
#import "perfactInfoVC.h"

#import "pchFile.pch"
#import "IChatManagerBase.h"
#import "MyBuddyModel.h"
#import "UserAgreeViewController.h"
@interface NewLoginViewController ()<CLLocationManagerDelegate,UITextFieldDelegate>{
    UITextField *phonetf;
    UITextField *checktf;
    
    UIButton  *getCheckBtn;
    
    NSString *longitude;
    NSString *latitude;
    
    UIButton *loginBtn;
    BOOL isClickYanzhengmaBtn;
    
    NSString *userName;
    NSString *icon;
}


@property(nonatomic,strong)CLLocationManager *clManager;  //定位信息管理者
@property(nonatomic,strong)NSTimer *timer;
@property(nonatomic,assign)int time;
@property (nonatomic, strong) NSMutableArray *buddyArray; //与本地数据库映射的用户数组

@end

@implementation NewLoginViewController


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
//        [MBProgressHUD showError:@"您拒绝了定位授权,若需要请在设置中开启"];
        longitude = @"120.027860";
        latitude = @"30.245586";
    }
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//    [MBProgressHUD showError:@"定位失败,请重试"];
}





-(void)viewWillAppear:(BOOL)animated{
    userName = @"";
    icon= @"";
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [MBProgressHUD hideHUD];
    NSMutableArray *vcs = [self.navigationController.viewControllers mutableCopy];
    [vcs removeAllObjects];
    
    NSMutableArray *tcs = [self.navigationController.tabBarController mutableCopy];
     [tcs removeAllObjects];
}
-(void)viewWillDisappear:(BOOL)animated{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [MBProgressHUD hideHUD];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    latitude = @"0";
    longitude = @"0";
    
      _buddyArray = [NSMutableArray array];
 
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
    
    _time = 60;
    [self setUI];
    [self setNav];
    
}

- (void)setNav{
    
    self.title = @"登录";
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:@"#ffffff"];
    //导航栏title的颜色
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithHexString:@"#424242"],UITextAttributeTextColor, [UIFont systemFontOfSize:18],UITextAttributeFont, nil]];
    
//    //导航栏返回按钮
//    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(16, 38, 28, 14)];
//    [button setTitleColor:[UIColor colorWithHexString:@"#424242"] forState:UIControlStateNormal];
//    [button setTitle:@"关闭" forState:UIControlStateNormal];
//    button.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
//    [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithCustomView:button];
//    self.navigationItem.leftBarButtonItem = back;
//    [self.view addSubview:button];
    
}

#pragma mark   ---关闭
- (void)back{
    
     [self.navigationController popViewControllerAnimated:YES];

    
}

- (void)setUI{
    
    //手机号码左边的图片
    UIImageView *phoneImage = [[UIImageView alloc]initWithFrame:CGRectMake(34, 96, 18, 18)];
    phoneImage.image = [UIImage imageNamed:@"loging_user"];
    [self.view addSubview:phoneImage];
    
    phonetf = [[UITextField alloc]init];
    phonetf.translatesAutoresizingMaskIntoConstraints = NO;
    phonetf.placeholder = @"请输入手机号码";
    phonetf.returnKeyType = UIReturnKeyDone;
//    phonetf.text = @"15212856249";
    phonetf.keyboardType = UIKeyboardTypeNumberPad;
    phonetf.textColor = [UIColor colorWithHexString:@"#bdbdbd"];
    phonetf.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
    [self.view addSubview:phonetf];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[phoneImage]-18-[phonetf]-30-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(phoneImage,phonetf)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-88-[phonetf(==34)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(phonetf)]];
    
    
    //验证码左边的图片
    UIImageView *checkImage = [[UIImageView alloc]initWithFrame:CGRectMake(34, 158, 18, 22)];
    checkImage.image = [UIImage imageNamed:@"loging_code"];
    [self.view addSubview:checkImage];
    
    checktf = [[UITextField alloc]init];
    checktf.translatesAutoresizingMaskIntoConstraints = NO;
    checktf.placeholder = @"验证码";
    checktf.keyboardType = UIKeyboardTypeNumberPad;
    checktf.returnKeyType = UIReturnKeyDone;
//    checktf.text = @"111111";
    checktf.textColor = [UIColor colorWithHexString:@"#bdbdbd"];
    checktf.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
    [self.view addSubview:checktf];
    
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[checkImage]-18-[checktf]-150-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(checkImage,checktf)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-152-[checktf(==34)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(checktf)]];
    
    
    getCheckBtn = [[UIButton alloc]initWithFrame:CGRectMake(190, 152, 150, 32)];
    getCheckBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [getCheckBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    [getCheckBtn addTarget:self action:@selector(getCheckClick:) forControlEvents:UIControlEventTouchUpInside];
    [getCheckBtn setTitleColor:[UIColor colorWithHexString:@"#ff5252"] forState:UIControlStateNormal];
    getCheckBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    [self.view addSubview:getCheckBtn];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[checktf]-0-[getCheckBtn]-30-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(checktf,getCheckBtn)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-152-[getCheckBtn(==32)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(getCheckBtn)]];
    
    
    
    

    
    
    // 富文本
    NSString *allText = @"点击'登录'即同意<<用户协议>>";
    
    NSRange rangeBlack = [allText rangeOfString:@"点击'登录'即同意"];
    NSRange rangeBlue = [allText rangeOfString:@"<<用户协议>>"];
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:allText];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:rangeBlack];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#ff5252"] range:rangeBlue];//颜色
    
    
    
    UILabel *noteLabel = [[UILabel alloc]init];
    noteLabel.translatesAutoresizingMaskIntoConstraints = NO;
    noteLabel.attributedText = str;
    noteLabel.textAlignment = NSTextAlignmentCenter;
    noteLabel.userInteractionEnabled = YES;
    noteLabel.font = [UIFont systemFontOfSize:13];
    [self.view addSubview:noteLabel];
    
    NSArray *noteH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-40-[noteLabel]-40-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(noteLabel)];
    NSArray *noteV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[checktf]-10-[noteLabel(==20)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(noteLabel,checktf)];
    [self.view addConstraints:noteH];
    [self.view addConstraints:noteV];
    
    UIButton *protoBtn = [[UIButton alloc]init];
    protoBtn.backgroundColor = [UIColor clearColor];
    protoBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [protoBtn addTarget:self action:@selector(showProto) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:protoBtn];
    
    NSArray *pBtnH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-60-[protoBtn]-40-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(protoBtn)];
    NSArray *pBtnV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[checktf]-10-[protoBtn(==20)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(protoBtn,checktf)];
    [self.view addConstraints:pBtnH];
    [self.view addConstraints:pBtnV];
//
    //登录
    loginBtn = [[UIButton alloc]init];
    loginBtn.translatesAutoresizingMaskIntoConstraints = NO;
    loginBtn.userInteractionEnabled = YES;
    loginBtn.backgroundColor = [UIColor colorWithHexString:@"#ff5252"];
    loginBtn.layer.cornerRadius = 18;
    loginBtn.clipsToBounds = YES;
    loginBtn.layer.shadowOffset = CGSizeMake(2, 4);
    loginBtn.layer.shadowColor = [UIColor colorWithRed:32 green:32 blue:32 alpha:0.12].CGColor;
    [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
   [loginBtn setTitleColor:[UIColor colorWithHexString:@"#ffffff"] forState:UIControlStateNormal];
    loginBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [loginBtn addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginBtn];

    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-100-[loginBtn]-100-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(loginBtn)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-240-[loginBtn(==36)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(loginBtn)]];
    
    
    //第三方登录
    
    UILabel *SanLabel = [[UILabel alloc]init];
    SanLabel.translatesAutoresizingMaskIntoConstraints = NO;
    SanLabel.text = @"--第三方账户登录--";
    SanLabel.textAlignment = NSTextAlignmentCenter;
    SanLabel.textColor = [UIColor colorWithHexString:@"#ff5252"];
    SanLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
    [self.view addSubview:SanLabel];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-80-[SanLabel]-80-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(SanLabel)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[SanLabel(==24)]-160-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(SanLabel)]];
    
    UIButton *QQImage = [[UIButton alloc]init];
    QQImage.translatesAutoresizingMaskIntoConstraints = NO;
    [QQImage setBackgroundImage:[UIImage imageNamed:@"QQ-2"] forState:UIControlStateNormal];
     QQImage.clipsToBounds = YES;
    QQImage.layer.cornerRadius = 25;
    [self.view addSubview:QQImage];
    [QQImage addTarget:self action:@selector(QQLogin) forControlEvents:UIControlEventTouchUpInside];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-70-[QQImage(==50)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(QQImage)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[QQImage(==50)]-80-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(QQImage)]];
    
    UIButton *WXImage = [[UIButton alloc]init];
    WXImage.translatesAutoresizingMaskIntoConstraints = NO;
    [WXImage setBackgroundImage:[UIImage imageNamed:@"pay_wechat"] forState:UIControlStateNormal];
    [WXImage addTarget:self action:@selector(WXLogin) forControlEvents:UIControlEventTouchUpInside];
    WXImage.clipsToBounds = YES;
    WXImage.layer.cornerRadius = 25;
    [self.view addSubview:WXImage];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[WXImage(==50)]-70-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(WXImage)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[WXImage(==50)]-80-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(WXImage)]];
    
   
        UILabel *qqLabel = [[UILabel alloc]init];
        qqLabel.translatesAutoresizingMaskIntoConstraints = NO;
        qqLabel.textAlignment = NSTextAlignmentCenter;
        qqLabel.text = @"QQ";
       qqLabel.textColor = [UIColor colorWithHexString:@"#424242"];
        qqLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        [self.view addSubview:qqLabel];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-70-[qqLabel(==50)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(qqLabel)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[QQImage]-14-[qqLabel(==12)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(QQImage,qqLabel)]];
    
    
    UILabel *wxLabel = [[UILabel alloc]init];
    wxLabel.translatesAutoresizingMaskIntoConstraints = NO;
    wxLabel.textAlignment = NSTextAlignmentCenter;
    wxLabel.text = @"微信";
    wxLabel.textColor = [UIColor colorWithHexString:@"#424242"];
    wxLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [self.view addSubview:wxLabel];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[wxLabel(==50)]-70-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(wxLabel)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[WXImage]-14-[wxLabel(==12)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(WXImage,wxLabel)]];
    
    
    
}
-(void)showProto{
    UserAgreeViewController*vc = [[UserAgreeViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark  --QQ登录
- (void)QQLogin{
    

    
    [MBProgressHUD  showMessage:nil];
    if (!kAppDelegate.deviceToken) {
        kAppDelegate.deviceToken = @"bb63b19106f3108798b7a271447e40df8a75c0b7cec8d99f54b43728713edc37";
    }
    
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToQQ];
    snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [MBProgressHUD hideHUD];
        //获取QQ用户名、uid、token等
        if (response.responseCode == UMSResponseCodeSuccess) {
            UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary] valueForKey:UMShareToQQ];
            NSLog(@"~~~~~~~~~~~~~~QQ用户信息:username is %@, uid is %@, token is %@ url is %@",snsAccount.userName,snsAccount.usid,snsAccount.accessToken,snsAccount.iconURL);
            userName = snsAccount.userName;
            icon = snsAccount.iconURL;
           // [MBProgressHUD showMessage:@"登录中.." toView:self.view];
            [MBProgressHUD showSuccess:@"QQ登录中.."];
            //进行第三方登录
            [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/login/loginUM",REQUESTHEADER] andParameter:@{@"userAccount":snsAccount.usid,@"deviceType":@"1",@"deviceToken":kAppDelegate.deviceToken,@"userLongitude":longitude,@"userLatitude":latitude} success:^(id successResponse) {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [MBProgressHUD hideHUD];
                MLOG(@"QQ 的 信息 %@",successResponse);
                MLOG(@"信息 : %@",successResponse[@"errorMsg"]);
                if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
                    
                    [self saveToUserDefault:successResponse[@"data"]];
                    [self loginHuanXin:successResponse[@"data"]];
                    [self performSelector:@selector(checkUserInfo) withObject:self afterDelay:2];
                
                }else{
                   [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
                }
                     } andFailure:^(id failureResponse) {
              
                         [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                         [MBProgressHUD hideHUD];
                [MBProgressHUD showError:@"服务器繁忙,请重试"];
            }];
        }else{
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
             [MBProgressHUD hideHUD];
        }});
    //获取accestoken以及QQ用户信息，得到的数据在回调Block对象形参respone的data属性
//    [[UMSocialDataService defaultDataService] requestSnsInformation:UMShareToWechatSession  completion:^(UMSocialResponseEntity *response){
//        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//        NSLog(@"SnsInformation is %@",response.data);
//        self.gender = response.data[@"gender"];
//        //NSString* location = response.data[@"location"];
//        self.profile_image_url = response.data[@"profile_image_url"];
//        MLOG(@"当前执行线程 : %@",[NSThread currentThread]);
//    }];
//
    
    
}


#pragma mark  --微信登录
- (void)WXLogin{
    [MBProgressHUD  showMessage:nil];
    //微信登录
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToWechatSession];
    snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [MBProgressHUD hideHUD];
        if (response.responseCode == UMSResponseCodeSuccess) {
            UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary]valueForKey:UMShareToWechatSession];
            NSLog(@"~~~~~~~~~~~~~~微信用户信息:username is %@, uid is %@, token is %@ url is %@",snsAccount.userName,snsAccount.usid,snsAccount.accessToken,snsAccount.iconURL);
            userName = snsAccount.userName;
            icon = snsAccount.iconURL;
            [MBProgressHUD showMessage:@"登录中.." toView:self.view];
            //进行第三方登录
            [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/login/loginUM",REQUESTHEADER] andParameter:@{@"userAccount":snsAccount.usid,@"deviceType":@"1",@"deviceToken":kAppDelegate.deviceToken,@"userLongitude":longitude,@"userLatitude":latitude} success:^(id successResponse) {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [MBProgressHUD hideHUD];
                MLOG(@"微信 的 登录结果:%@",successResponse);
                MLOG(@"信息 : %@",successResponse[@"errorMsg"]);
                if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
                  [self saveToUserDefault:successResponse[@"data"]];
                    [self loginHuanXin:successResponse[@"data"]];
                    [self performSelector:@selector(checkUserInfo) withObject:self afterDelay:2];
                  
                    
                }else{
                    [MBProgressHUD showError:successResponse[@"errorMsg"]];
                }

            } andFailure:^(id failureResponse) {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [MBProgressHUD hideHUD];
                [MBProgressHUD showError:@"服务器繁忙,请重试"];
            }];
        }else{
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [MBProgressHUD hideHUD];
        }
    
    }
                                  
                                  );

    
}

-(void)getCheckClick:(UIButton *)sender{

if ([CommonTool isMobile:phonetf.text] == YES) {
        
        getCheckBtn.enabled = NO;
        [self  getCheckNum];
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeAction:) userInfo:nil repeats:YES];
        [[NSRunLoop  currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
        
        
    }else {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText= @"手机号格式不正确";
        
        [hud hide:YES afterDelay:1];
        //设置隐藏的时候是否从父视图中移除，默认是NO
        hud.removeFromSuperViewOnHide = YES;
    }

}
#pragma mark   ---------获得验证码
- (void)getCheckNum{
 
    
        if ([LYFactory isPhone:phonetf.text]) {
        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/getCaptcha",REQUESTHEADER] andParameter:@{@"userAccount":phonetf.text} success:^(id successResponse) {
            isClickYanzhengmaBtn = YES;
            [MBProgressHUD showSuccess:@"验证码发送成功"];
            loginBtn.userInteractionEnabled = YES;
         
        } andFailure:^(id failureResponse) {
            
          [MBProgressHUD showError:@"验证码发送失败"];
        }];
    }else{
        [MBProgressHUD showError:@"请输入正确的手机号"];
    }
}

- (void)timeAction:(NSTimer *)timer
{
    [getCheckBtn setTitle:[NSString stringWithFormat:@"%ld秒后重试",(long)_time] forState:UIControlStateNormal];
    if (_time == -1) {
        [timer invalidate];
        timer = nil;
        _time = 60;
        
        [getCheckBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        getCheckBtn.enabled = YES;
    }
    
    _time--;
}


#pragma mark    ----登录
- (void)login{
    
    if ([CommonTool isMobile:phonetf.text] == NO) {
        [MBProgressHUD showError:@"手机号不正确"];
        return;
    }
    if (isClickYanzhengmaBtn == NO) {
        [MBProgressHUD showError:@"请点击获取验证码"];
        return;
    }
    loginBtn.userInteractionEnabled = YES;
        latitude = @"0";
        longitude = @"0";
        [MBProgressHUD showMessage:@"登录中..."];
        MLOG(@"DEVICETOKEN : %@",kAppDelegate.deviceToken);
        if (!kAppDelegate.deviceToken) {
            kAppDelegate.deviceToken = @"bb63b19106f3108798b7a271447e40df8a75c0b7cec8d99f54b43728713edc37";
        }
    
        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/login/loginUser",REQUESTHEADER] andParameter:@{@"userAccount":phonetf.text,@"captcha":checktf.text,@"deviceType":@"1",@"deviceToken":kAppDelegate.deviceToken,@"userLongitude":longitude,@"userLatitude":latitude} success:^(id successResponse) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [MBProgressHUD hideHUD];
           if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqual:@"200"]) {
    //           [MBProgressHUD showSuccess:@"登陆成功"];
               MLOG(@"登录结果:%@",successResponse);
               [self loginHuanXin:successResponse[@"data"]];
               [self saveToUserDefault:successResponse[@"data"]];
               [self checkUserInfo];
    
               
           }else {
               [MBProgressHUD hideHUD];
               [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
           }
    
        } andFailure:^(id failureResponse) {
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"服务器繁忙,请重试"];
     }];
    
}
////    if (!longitude) {
////        longitude = @"";
////    }
////    if (!latitude) {
////        latitude = @"";
////    }
////    if ([CommonTool dx_isNullOrNilWithObject:checktf.text]) {
////         [MBProgressHUD showSuccess:@"请输入验证码"];
////        return;
////    }
//    latitude = @"0";
//    longitude = @"0";
////    [MBProgressHUD showSuccess:@"登录中..."];
//    MLOG(@"DEVICETOKEN : %@",kAppDelegate.deviceToken);
//    if (!kAppDelegate.deviceToken) {
//        kAppDelegate.deviceToken = @"bb63b19106f3108798b7a271447e40df8a75c0b7cec8d99f54b43728713edc37";
//    }
//    
//    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/login/loginUser",REQUESTHEADER] andParameter:@{@"userAccount":phonetf.text,@"captcha":checktf.text,@"deviceType":@"1",@"deviceToken":kAppDelegate.deviceToken,@"userLongitude":longitude,@"userLatitude":latitude} success:^(id successResponse) {
//        
//       if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
////           [MBProgressHUD showSuccess:@"登陆成功"];
//           MLOG(@"登录结果:%@",successResponse);
//           NSDictionary *userDict = successResponse[@"data"];
//           [CommonTool saveAccessTokenToLocal:userDict];
////           [CommonTool checkUserInfo];
//
//          }
//
//    } andFailure:^(id failureResponse) {
//        [MBProgressHUD hideHUD];
//        [MBProgressHUD showError:@"服务器繁忙,请重试"];
// }];
//
//    
//}
//
- (void)checkUserInfo{
    
    
    
    NSString *str = [CommonTool getUserID];
    [ LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/checkUserInfo",REQUESTHEADER]  andParameter:@{@"userId":str} success:^(id successResponse) {
        NSLog(@"3333%@",successResponse);
        if ([successResponse[@"data"] isEqualToString:@""]) {
//            UIWindow *window = [UIApplication sharedApplication].keyWindow;
//            perfactInfoVC *vc = [[perfactInfoVC alloc] init];
//            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
//            window.rootViewController = nav;
                        perfactInfoVC *info = [[perfactInfoVC alloc]init];
            info.userName = userName;
            info.iconUrl = icon;
                        [self.navigationController pushViewController:info animated:YES];
           
        }else{
            //            [self.navigationController popViewControllerAnimated:YES];
            NSLog(@"nnicheng--%@",successResponse[@"data"]);
        
            [CommonTool gotoMain];
        }
        
    } andFailure:^(id failureResponse) {
        NSLog(@"%@",failureResponse);
    }];
    
}

//#pragma mark   ---保存用户信息到本地
- (void)saveToUserDefault:(NSDictionary *)userDict {
    @synchronized (self) {
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        [user setObject:[NSString stringWithFormat:@"%@",userDict[@"userId"]] forKey:@"userId"];
        [user setObject:[NSString stringWithFormat:@"%@",longitude] forKey:@"longitude"];
        [user setObject:[NSString stringWithFormat:@"%@",latitude] forKey:@"latitude"];
       
      
        [user setObject:[NSString stringWithFormat:@"%@",userDict[@"userCaptcha"]] forKey:@"userCaptcha"];
       
        [user setObject:[NSString stringWithFormat:@"%@",userDict[@"userNickname"]] forKey:@"userNickname"];
        
        
    }
    
    
    
}


-(void)loginHuanXin:(NSDictionary *)userDict{

  
    
    [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:[NSString stringWithFormat:@"qp%@",userDict[@"userId"]] password:@"111111" completion:^(NSDictionary *loginInfo, EMError *error) {
        NSLog(@"loginInfo---%@  error---%@",loginInfo,error);
        if (!error && loginInfo) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            //设置是否自动登录
            [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:YES];
           
            
            /*---------------- 配置apns ---------------*/
            EMPushNotificationOptions *options = [[EaseMob sharedInstance].chatManager pushNotificationOptions];
            //设置推送用户昵称
            [[EaseMob sharedInstance].chatManager setApnsNickname:[NSString stringWithFormat:@"%@",userDict[@"userNickname"]]];
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
            
//            //异步更新本地数据库(好友体系中的用户和群组植入)
      //      [self buddyDataBaseOperation];
//            [self groupDataBaseOperation];
            
            //实时更新自己的未读系统消息数
            [LYUserService sharedInstance].userID = userDict[@"userId"];
            [[LYUserService sharedInstance] getCurrentUnReadSystemMessageNumber];
        }else{
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"登录失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView show];
        }
    } onQueue:nil];
  
}

#pragma mark - 数据库操作  先不植入  这里model有问题而且userid 必须是环信的ID才能进行查询
//建立本地数据库的好友体系
- (void)buddyDataBaseOperation {
    //异步更新本地数据库(好友体系中的用户植入)
    [_buddyArray removeAllObjects];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/circle/getFriend",REQUESTHEADER] andParameter:@{@"userId":[LYUserService sharedInstance].userID} success:^(id successResponse) {
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            NSArray *list = successResponse[@"data"];
            for (NSDictionary *dict in list) {
                MyBuddyModel *model = [[MyBuddyModel alloc] initWithDict:dict];
                [_buddyArray addObject:model];
            }
            [kAppDelegate.dataBaseQueue inDatabase:^(FMDatabase *db) {
                //如果数据库打开成功
                if ([kAppDelegate.dataBase open]) {
                    for (MyBuddyModel *model in _buddyArray) {
                        //如果用户模型在本地数据库表中没有，则插入，否则更新 好友列表
                        NSString *findSql = [NSString stringWithFormat:@"SELECT * FROM '%@' WHERE userID = '%@'",@"Firends",model.buddyID];
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
                            NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO '%@'('%@','%@','%@','%@') VALUES('%@','%@','%@','%@')",@"Firends",@"userID",@"name",@"remark",@"icon",model.buddyID,model.name,model.remark,model.icon];
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



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
