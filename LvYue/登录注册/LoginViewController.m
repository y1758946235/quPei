//
//  LoginViewController.m
//  LvYue
//
//  Created by apple on 15/9/28.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import "LoginViewController.h"
#import "RootTabBarController.h"
#import "LYHttpPoster.h"
#import "MBProgressHUD+NJ.h"
#import "LYUserService.h"
#import "UMSocial.h"
#import "MyBuddyModel.h"
#import "GroupModel.h"
#import "LYFactory.h"

@interface LoginViewController ()<CLLocationManagerDelegate>{
    NSString *longitude;//经纬度
    NSString *latitude;
    UITextField *phonetf;
    UITextField *checktf;
    UIButton *getCheckBtn;
}

@property(nonatomic,strong)NSTimer *timer;
@property(nonatomic,assign)int time;


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

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
    [super viewWillAppear:animated];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
    _time = 60;
    _buddyArray = [NSMutableArray array];
    _groupArray = [NSMutableArray array];
    
    
    phonetf = [[UITextField alloc]init];
    phonetf.translatesAutoresizingMaskIntoConstraints = NO;
    phonetf.placeholder = @"手机号码";
    [self.view addSubview:phonetf];
    NSArray *phonetfH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[phonetf]-20-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(phonetf)];
    NSArray *phonetfV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-70-[phonetf(==50)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(phonetf)];
    [self.view addConstraints:phonetfH];
    [self.view addConstraints:phonetfV];
    
    
    checktf = [[UITextField alloc]init];
    checktf.translatesAutoresizingMaskIntoConstraints = NO;
    checktf.placeholder = @"验证码";
    [self.view addSubview:checktf];
    
    NSArray *checktfH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[checktf]-120-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(checktf)];
    NSArray *checktfV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[phonetf]-10-[checktf(==50)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(checktf,phonetf)];
    [self.view addConstraints:checktfH];
    [self.view addConstraints:checktfV];
    
    
    getCheckBtn = [[UIButton alloc]init];
    getCheckBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [getCheckBtn setTitle:@"发送验证码" forState:UIControlStateNormal];
    [getCheckBtn addTarget:self action:@selector(getCheckNum:) forControlEvents:UIControlEventTouchUpInside];
    [getCheckBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.view addSubview:getCheckBtn];
    
    NSArray *getBtnH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[checktf]-0-[getCheckBtn]-20-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(getCheckBtn,checktf)];
    NSArray *getBtnV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[phonetf]-10-[getCheckBtn(==50)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(getCheckBtn,phonetf)];
    
    [self.view addConstraints:getBtnH];
    [self.view addConstraints:getBtnV];
    
    
    // 富文本
    NSString *allText = @"点击'登录'即同意<<XX用户协议>>";
    
    NSRange rangeBlack = [allText rangeOfString:@"点击'登录'即同意"];
    NSRange rangeBlue = [allText rangeOfString:@"<<XX用户协议>>"];
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:allText];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:rangeBlack];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:rangeBlue];//颜色
    
    
   
    UILabel *noteLabel = [[UILabel alloc]init];
    noteLabel.translatesAutoresizingMaskIntoConstraints = NO;
    noteLabel.attributedText = str;
    noteLabel.userInteractionEnabled = YES;
    noteLabel.font = [UIFont systemFontOfSize:13];
    [self.view addSubview:noteLabel];
    
    NSArray *noteH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[noteLabel]-80-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(noteLabel)];
    NSArray *noteV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[checktf]-10-[noteLabel(==20)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(noteLabel,checktf)];
    [self.view addConstraints:noteH];
    [self.view addConstraints:noteV];
    
    UIButton *protoBtn = [[UIButton alloc]init];
    protoBtn.backgroundColor = [UIColor clearColor];
    protoBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [protoBtn addTarget:self action:@selector(showProto:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:protoBtn];
    
    NSArray *pBtnH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-60-[protoBtn]-80-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(protoBtn)];
    NSArray *pBtnV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[checktf]-10-[protoBtn(==20)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(protoBtn,checktf)];
    [self.view addConstraints:pBtnH];
    [self.view addConstraints:pBtnV];
    
    //登录
    UIButton *loginBtn = [[UIButton alloc]initWithFrame:CGRectMake(40, 240, 290, 50)];
    loginBtn.translatesAutoresizingMaskIntoConstraints = NO;
    loginBtn.backgroundColor = [UIColor redColor];
    [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [loginBtn addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:loginBtn];
    
    NSArray *loginH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[loginBtn]-15-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(loginBtn)];
    NSArray *loginV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[noteLabel]-20-[loginBtn(==50)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(loginBtn,noteLabel)];
    [self.view addConstraints:loginH];
    [self.view addConstraints:loginV];
    
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

#pragma mark   ------ 显示协议
- (void)showProto:(UIButton *)sender{
    
    
    
}


#pragma mark  -----得到验证码
- (void)getCheckNum:(UIButton *)sender{
    if ([LYFactory isPhone:phonetf.text]) {
        
        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/getCaptcha",REQUESTHEADER] andParameter:@{@"userAccount":phonetf.text} success:^(id successResponse) {
            
            NSLog(@"验证码信息^^^^^^^^^^^^^^%@",successResponse);
            if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
                NSLog(@"验证码发送成功");
            }
         
          [sender setTitle:[NSString stringWithFormat:@"(%ds)重新获取",_time] forState:UIControlStateNormal];
            _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeToSendAgain) userInfo:nil repeats:YES];
            [_timer fire];
            
        } andFailure:^(id failureResponse) {
            [MBProgressHUD showError:@"验证码发送失败"];
            NSLog(@"ttttttttttttttt%@",failureResponse);
        }];
    
}else{
        [MBProgressHUD showError:@"请输入正确的手机号"];
    }


}


#pragma mark   ------重新获取验证码

#pragma mark - 定时器
- (void)timeToSendAgain {
    _time --;
    if (_time == 0) {
        [getCheckBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        [getCheckBtn setBackgroundColor:RGBACOLOR(231, 99, 83, 1.0)];
       // _coverBtn.hidden = YES;
        [_timer invalidate];
        _timer = nil;
        _time = 60;
    } else {
        [getCheckBtn setTitle:[NSString stringWithFormat:@"(%ds)重新获取",_time] forState:UIControlStateNormal];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self.view endEditing:YES];
}


#pragma mark   ------------------登录------------
- (void)login:(UIButton *)sender{
  
    
    
    
}

- (IBAction)ThirdLogin:(UIButton *)sender {
   



}


//游客进入
- (IBAction)visitorEnter:(UIButton *)sender {
    //直接进入主页
    RootTabBarController *rootVc = [[RootTabBarController alloc] init];
    kAppDelegate.rootTabC = rootVc;
    KEYWINDOW.rootViewController = rootVc;
    rootVc.selectedIndex = 0;
}



@end
