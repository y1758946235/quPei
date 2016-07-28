//
//  ForgetPasswordController.m
//  LvYue
//
//  Created by apple on 15/9/30.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import "ForgetPasswordController.h"
#import "MBProgressHUD+NJ.h"
#import "LYHttpPoster.h"
#import "LYFactory.h"

@interface ForgetPasswordController (){
    UIButton *_coverBtn;
}

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign) int time;

@end

@implementation ForgetPasswordController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _getCheckBtn.layer.cornerRadius = 5.0;
    _getCheckBtn.clipsToBounds = YES;
    _sureBtn.layer.cornerRadius = 5.0;
    _sureBtn.clipsToBounds = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _time = 60;
    
    _coverBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _coverBtn.frame = _getCheckBtn.frame;
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
        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/captcha",REQUESTHEADER] andParameter:@{@"mobile":_phoneField.text} success:^(id successResponse) {
            [sender setTitle:[NSString stringWithFormat:@"(%ds)重新获取",_time] forState:UIControlStateNormal];
            [sender setBackgroundColor:[UIColor lightGrayColor]];
            _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeToSendAgain) userInfo:nil repeats:YES];
            [_timer fire];
            _coverBtn.hidden = NO;
        } andFailure:^(id failureResponse) {
            [MBProgressHUD showError:@"验证码发送失败"];
        }];
    } else {
        [MBProgressHUD showError:@"请输入正确的手机号"];
    }
}

- (IBAction)sure:(UIButton *)sender {

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
    if ([LYFactory isPhone:_phoneField.text]) {
        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/checkMobile",REQUESTHEADER] andParameter:@{@"mobile":_phoneField.text} success:^(id successResponse) {
            NSString *exist = [NSString stringWithFormat:@"%@",successResponse[@"data"][@"exist"]];
            if ([exist isEqualToString:@"1"]) {
                [MBProgressHUD showMessage:@"申请找回中..."];
                [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/forgetPassword",REQUESTHEADER] andParameter:@{@"mobile":_phoneField.text,@"password":_passwordField.text,@"captcha":_checkField.text} success:^(id successResponse) {
                    [MBProgressHUD hideHUD];
                    [MBProgressHUD showSuccess:@"找回密码成功!"];
                    [self dismissViewControllerAnimated:YES completion:nil];
                } andFailure:^(id failureResponse) {
                    [MBProgressHUD hideHUD];
                    [MBProgressHUD showError:@"找回密码失败!"];
                }];
            } else {
                [MBProgressHUD showError:@"该手机号未被注册!"];
            }
        } andFailure:^(id failureResponse) {
            [MBProgressHUD showError:@"服务器繁忙,请重试"];
        }];
    } else {
        [MBProgressHUD showError:@"请输入正确的手机号"];
    }
}

#pragma mark - 定时器
- (void)timeToSendAgain {
    _time --;
    if (_time == 0) {
        [_getCheckBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        [_getCheckBtn setBackgroundColor:RGBACOLOR(231, 99, 83, 1.0)];
        _coverBtn.hidden = YES;
        [_timer invalidate];
        _timer = nil;
        _time = 60;
    } else {
        [_getCheckBtn setTitle:[NSString stringWithFormat:@"(%ds)重新获取",_time] forState:UIControlStateNormal];
    }
}

@end
