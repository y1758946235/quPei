//
//  RigisterViewController.m
//  LvYue
//
//  Created by apple on 15/9/30.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import "RigisterViewController.h"
#import "MBProgressHUD+NJ.h"
#import "FinishRigisterViewController.h"
#import "LYHttpPoster.h"
#import "LYFactory.h"
#import "PrivacyPolicyViewController.h"

@interface RigisterViewController () {
    UIButton *_coverBtn;
    BOOL isSelect;
}

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign) int time;

@end

@implementation RigisterViewController


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _getCheckNumBtn.layer.cornerRadius = 5.0;
    _getCheckNumBtn.clipsToBounds = YES;
    _rigisterBtn.layer.cornerRadius = 5.0;
    _rigisterBtn.clipsToBounds = YES;
    isSelect = false;
    [self.selectBtn setBackgroundImage:[UIImage imageNamed:@"组-3"] forState:UIControlStateSelected];
    [self.selectBtn setBackgroundImage:[UIImage imageNamed:@"矩形-17-拷贝-2"] forState:UIControlStateNormal];
    self.selectBtn.selected = NO;
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissRigisterView:) name:@"dismissRigisterView" object:nil];
    
    _time = 60;
    
    _coverBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _coverBtn.frame = _getCheckNumBtn.frame;
    _coverBtn.backgroundColor = [UIColor clearColor];
    _coverBtn.hidden = YES;
    [self.view addSubview:_coverBtn];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}


- (IBAction)back:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)getCheckNum:(UIButton *)sender {

    if ([LYFactory isPhone:_phoneField.text]) {
        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/checkMobile",REQUESTHEADER] andParameter:@{@"mobile":_phoneField.text} success:^(id successResponse) {
            NSString *exist = [NSString stringWithFormat:@"%@",successResponse[@"data"][@"exist"]];
            if ([exist isEqualToString:@"0"]) {
                [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/captcha",REQUESTHEADER] andParameter:@{@"mobile":_phoneField.text} success:^(id successResponse) {
                    MLOG(@"验证码信息:%@",successResponse);
                    if (kMainScreenWidth == 320.0f) {
                        sender.titleLabel.font = kFont14;
                    }
                    [sender setTitle:[NSString stringWithFormat:@"(%ds)重新获取",_time] forState:UIControlStateNormal];
                    [sender setBackgroundColor:[UIColor lightGrayColor]];
                    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeToSendAgain) userInfo:nil repeats:YES];
                    [_timer fire];
                    _coverBtn.hidden = NO;
                } andFailure:^(id failureResponse) {
                    [MBProgressHUD showError:@"验证码发送失败"];
                }];
            } else {
                [MBProgressHUD showError:@"该手机号已经被注册!"];
            }
        } andFailure:^(id failureResponse) {
            [MBProgressHUD showError:@"服务器繁忙,请重试"];
        }];
    } else {
        [MBProgressHUD showError:@"请输入正确的手机号"];
    }
}

- (IBAction)userRigister:(UIButton *)sender {
    
    if (_checkField.text.length < 1 || ([_checkField.text rangeOfString:@" "].location != NSNotFound)) {
        [MBProgressHUD showError:@"验证码不能为空!"];
        return;
    }
    if (![_passwordField.text isEqualToString:_passwordField2.text]) {
        [MBProgressHUD showError:@"两次密码不一致!"];
        return;
    }
    if (_passwordField.text.length < 6 || _passwordField.text.length > 16) {
        [MBProgressHUD showError:@"密码长度须在6-16位之间!"];
        return;
    }
    if (!isSelect) {
        [MBProgressHUD showError:@"请阅读《豆客使用条款及隐私条款》"];
        return;
    }

    FinishRigisterViewController *finishDest = [[FinishRigisterViewController alloc] init];
    finishDest.mobile = _phoneField.text;
    finishDest.checkNum = _checkField.text;
    finishDest.password = _passwordField.text;
    [self presentViewController:finishDest animated:NO completion:nil];
}

- (IBAction)checkPrivate:(UIButton *)sender {
    
    PrivacyPolicyViewController *pri = [[PrivacyPolicyViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:pri];
    [self presentViewController:nav animated:YES completion:nil];
    
}

- (IBAction)didSelect:(UIButton *)sender {
    if (isSelect) {
        sender.selected = NO;
        isSelect = false;
    }
    else{
        sender.selected = YES;
        isSelect = true;
    }
}


#pragma mark - 定时器
- (void)timeToSendAgain {
    _time --;
    if (_time == 0) {
        [_getCheckNumBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        [_getCheckNumBtn setBackgroundColor:RGBACOLOR(231, 99, 83, 1.0)];
        _coverBtn.hidden = YES;
        [_timer invalidate];
        _timer = nil;
        _time = 60;
    } else {
        [_getCheckNumBtn setTitle:[NSString stringWithFormat:@"(%ds)重新获取",_time] forState:UIControlStateNormal];
    }
}


#pragma mark - 通知
- (void)dismissRigisterView:(NSNotification *)aNotification {
    
    [self dismissViewControllerAnimated:NO completion:^{
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

@end
