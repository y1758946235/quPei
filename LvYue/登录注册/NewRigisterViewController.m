//
//  NewRigisterViewController.m
//  LvYue
//
//  Created by 郑洲 on 16/3/15.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "NewRigisterViewController.h"
#import "MBProgressHUD+NJ.h"
#import "NewFinishRigisterViewController.h"
#import "LYHttpPoster.h"
#import "LYFactory.h"
#import "PrivacyPolicyViewController.h"

@interface NewRigisterViewController ()<UITextFieldDelegate> {
    UITextField *_phoneField;
    UITextField *_inviteField;
    UITextField *_checkField;
    UIButton *_getCheckNumBtn;
    UITextField *_passwordField;
    UITextField *_passwordField2;
    UIButton *_rigisterBtn;
    UIButton *_selectBtn;
    
    UIButton *_coverBtn;
    BOOL isSelect;
    
    UIView *textFiledView;
}

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign) int time;

@end

@implementation NewRigisterViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    isSelect = false;
    self.view.backgroundColor = [UIColor whiteColor];
    if (_isForgetPassword) {
        self.navigationItem.title = @"忘记密码";
    }else {
        self.navigationItem.title = @"注册";
    }
    [self setLeftButton:[UIImage imageNamed:@"back"] title:nil target:self action:@selector(back)];
    [self setUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissRigisterView:) name:@"dismissRigisterView" object:nil];
    
    _time = 60;
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setUI {
    textFiledView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    textFiledView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:textFiledView];
    
    UIImageView *numberIcon = [[UIImageView alloc] initWithFrame:CGRectMake(15, 7.5, 14, 25)];
    numberIcon.image = [UIImage imageNamed:@"手机"];
    
    UIImageView *inviteIcon = [[UIImageView alloc] initWithFrame:CGRectMake(13, 10, 20, 19)];
    inviteIcon.image = [UIImage imageNamed:@"邀请码"];

    UIImageView *checkIcon = [[UIImageView alloc] initWithFrame:CGRectMake(15, 7.5, 16, 25)];
    checkIcon.image = [UIImage imageNamed:@"验证码"];
    
    UIImageView *passWordIcon = [[UIImageView alloc] initWithFrame:CGRectMake(15, 7.5, 13, 25)];
    passWordIcon.image = [UIImage imageNamed:@"密码"];
    
    UIImageView *passWordIcon2 = [[UIImageView alloc] initWithFrame:CGRectMake(15, 7.5, 13, 25)];
    passWordIcon2.image = [UIImage imageNamed:@"密码"];

    UIView *number = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
    [number addSubview:numberIcon];
    UIView *invite = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
    [invite addSubview:inviteIcon];
    UIView *checkNum = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
    [checkNum addSubview:checkIcon];
    UIView *password = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
    [password addSubview:passWordIcon];
    UIView *password2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
    [password2 addSubview:passWordIcon2];
    
    _phoneField = [[UITextField alloc] initWithFrame:CGRectMake(20, 84, SCREEN_WIDTH - 40, 40)];
    _phoneField.placeholder = @"请输入您的手机号";
    _phoneField.font = [UIFont systemFontOfSize:18];
    _phoneField.delegate = self;
    _phoneField.leftView = number;
    _phoneField.keyboardType = UIKeyboardTypeNumberPad;
    _phoneField.leftViewMode = UITextFieldViewModeAlways;
    _phoneField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [textFiledView addSubview:_phoneField];
    
    _inviteField = [[UITextField alloc] initWithFrame:CGRectMake(20, 134, SCREEN_WIDTH - 40, 40)];
    _inviteField.placeholder = @"请输入您的邀请码(选填)";
    _inviteField.font = [UIFont systemFontOfSize:18];
    _inviteField.delegate = self;
    _inviteField.leftView = invite;
    _inviteField.leftViewMode = UITextFieldViewModeAlways;
    _inviteField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [textFiledView addSubview:_inviteField];
    
    _getCheckNumBtn = [[UIButton alloc] initWithFrame:CGRectMake(1, 0, 110, 40)];
    [_getCheckNumBtn setTitle:@"发送验证码" forState:UIControlStateNormal];
    [_getCheckNumBtn setTitleColor:[UIColor colorWithRed:29/255.0 green:189/255.0 blue:159/255.0 alpha:1] forState:UIControlStateNormal];
    [_getCheckNumBtn addTarget:self action:@selector(getCheckNum:) forControlEvents:UIControlEventTouchUpInside];
    
    _coverBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _coverBtn.frame = _getCheckNumBtn.frame;
    _coverBtn.backgroundColor = [UIColor clearColor];
    [_coverBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    _coverBtn.hidden = YES;
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 5, 1, 30)];
    line.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
    
    UIView *checkView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 110, 40)];
    [checkView addSubview:_getCheckNumBtn];
    [checkView addSubview:_coverBtn];
    [checkView addSubview:line];
    
    _checkField = [[UITextField alloc] initWithFrame:CGRectMake(20, 184, SCREEN_WIDTH - 40, 40)];
    _checkField.placeholder = @"请输入验证码";
    _checkField.font = [UIFont systemFontOfSize:18];
    _checkField.delegate = self;
    _checkField.leftView = checkNum;
    _checkField.leftViewMode = UITextFieldViewModeAlways;
    _checkField.rightView = checkView;
    _checkField.rightViewMode = UITextFieldViewModeAlways;
    _checkField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [textFiledView addSubview:_checkField];
    
    _passwordField = [[UITextField alloc] initWithFrame:CGRectMake(20, 234, SCREEN_WIDTH - 40, 40)];
    _passwordField.placeholder = @"请输入您的密码";
    _passwordField.font = [UIFont systemFontOfSize:18];
    _passwordField.delegate = self;
    _passwordField.leftView = password;
    _passwordField.keyboardType = UIKeyboardTypeNamePhonePad;
    _passwordField.secureTextEntry = YES;
    _passwordField.leftViewMode = UITextFieldViewModeAlways;
    _passwordField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [textFiledView addSubview:_passwordField];

    _passwordField2 = [[UITextField alloc] initWithFrame:CGRectMake(20, 284, SCREEN_WIDTH - 40, 40)];
    _passwordField2.placeholder = @"请再次输入您的密码";
    _passwordField2.font = [UIFont systemFontOfSize:18];
    _passwordField2.delegate = self;
    _passwordField2.leftView = password2;
    _passwordField2.keyboardType = UIKeyboardTypeNamePhonePad;
    _passwordField2.secureTextEntry = YES;
    _passwordField2.leftViewMode = UITextFieldViewModeAlways;
    _passwordField2.clearButtonMode = UITextFieldViewModeWhileEditing;
    [textFiledView addSubview:_passwordField2];
    
    for (int i = 0; i < 5; i++) {
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(20, 124 + i * 50, SCREEN_WIDTH - 40, 1)];
        line.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
        [textFiledView addSubview:line];
    }
    
    UILabel *noteLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, _passwordField2.frame.origin.y + 44, SCREEN_WIDTH - 40, 20)];
    noteLabel.text = @"密码需6-16位，建议使用字母和数字或符号的组合";
    noteLabel.textColor = [UIColor lightGrayColor];
    noteLabel.font = [UIFont systemFontOfSize:12];
    [textFiledView addSubview:noteLabel];
    
    _rigisterBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, noteLabel.frame.origin.y + 37, SCREEN_WIDTH - 40, 40)];
    _rigisterBtn.backgroundColor = [UIColor colorWithRed:29/255.0 green:189/255.0 blue:159/255.0 alpha:1];
    [_rigisterBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    if (_isForgetPassword) {
        [_rigisterBtn setTitle:@"确认" forState:UIControlStateNormal];
    }else {
        [_rigisterBtn setTitle:@"下一步" forState:UIControlStateNormal];
    }
    [_rigisterBtn addTarget:self action:@selector(userRigister:) forControlEvents:UIControlEventTouchUpInside];
    [textFiledView addSubview:_rigisterBtn];
    
    _selectBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, _rigisterBtn.frame.origin.y + 50, 15, 15)];
    [_selectBtn setImage:[UIImage imageNamed:@"未选"] forState:UIControlStateNormal];
    [_selectBtn addTarget:self action:@selector(didSelect:) forControlEvents:UIControlEventTouchUpInside];
    [textFiledView addSubview:_selectBtn];
    
    NSString *str = @"已阅读并同意";
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(_selectBtn.frame.origin.x + 20, _selectBtn.frame.origin.y - 2, str.length * 13, 18)];
    label.text = str;
    label.textColor = [UIColor lightGrayColor];
    label.font = [UIFont systemFontOfSize:13];
    [textFiledView addSubview:label];
    
    NSString *list = @"《豆客使用条款及隐私条款》";
    UIButton *checkPrivateBtn = [[UIButton alloc] initWithFrame:CGRectMake(label.frame.origin.x + label.frame.size.width, label.frame.origin.y, list.length * 13, 18)];
    [checkPrivateBtn setTitleColor:[UIColor colorWithRed:215/255.0 green:36/255.0 blue:45/255.0 alpha:1] forState:UIControlStateNormal];
    [checkPrivateBtn setTitle:list forState:UIControlStateNormal];
    checkPrivateBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [checkPrivateBtn addTarget:self action:@selector(checkPrivate:) forControlEvents:UIControlEventTouchUpInside];
    [textFiledView addSubview:checkPrivateBtn];
    
    if (_isForgetPassword) {
        _selectBtn.hidden = YES;
        label.hidden = YES;
        checkPrivateBtn.hidden = YES;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    }];
}

- (void)getCheckNum:(UIButton *)sender {
    
    if (_isForgetPassword) {
        if ([LYFactory isPhone:_phoneField.text]) {
            [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/captcha",REQUESTHEADER] andParameter:@{@"mobile":_phoneField.text} success:^(id successResponse) {
                [sender setTitle:[NSString stringWithFormat:@"(%ds)重新获取",_time] forState:UIControlStateNormal];
                [sender setBackgroundColor:[UIColor whiteColor]];
                _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeToSendAgain) userInfo:nil repeats:YES];
                [_timer fire];
                _coverBtn.hidden = NO;
            } andFailure:^(id failureResponse) {
                [MBProgressHUD showError:@"验证码发送失败"];
            }];
        } else {
            [MBProgressHUD showError:@"请输入正确的手机号"];
        }
    }else {
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
                        [sender setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
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
}

- (void)userRigister:(UIButton *)sender {
    
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
    if (!isSelect && !_isForgetPassword) {
        [MBProgressHUD showError:@"请阅读《豆客使用条款及隐私条款》"];
        return;
    }
    
    if (_isForgetPassword) {
        if ([LYFactory isPhone:_phoneField.text]) {
            [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/checkMobile",REQUESTHEADER] andParameter:@{@"mobile":_phoneField.text} success:^(id successResponse) {
                NSString *exist = [NSString stringWithFormat:@"%@",successResponse[@"data"][@"exist"]];
                if ([exist isEqualToString:@"1"]) {
                    [MBProgressHUD showMessage:@"申请找回中..."];
                    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/forgetPassword",REQUESTHEADER] andParameter:@{@"mobile":_phoneField.text,@"password":_passwordField.text,@"captcha":_checkField.text} success:^(id successResponse) {
                        [MBProgressHUD hideHUD];
                        [MBProgressHUD showSuccess:@"找回密码成功!"];
                        [self dismissViewControllerAnimated:YES completion:nil];
                        [self.navigationController popViewControllerAnimated:YES];
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

    }else {
        NewFinishRigisterViewController *finishDest = [[NewFinishRigisterViewController alloc] init];
        finishDest.mobile = _phoneField.text;
        finishDest.checkNum = _checkField.text;
        finishDest.password = _passwordField.text;
        finishDest.longitude = _longitude;
        finishDest.latitude = _latitude;
        
        [self.navigationController pushViewController:finishDest animated:YES];
    }
}

- (void)checkPrivate:(UIButton *)sender {
    
    PrivacyPolicyViewController *pri = [[PrivacyPolicyViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:pri];
    [self presentViewController:nav animated:YES completion:nil];
    
}

- (void)didSelect:(UIButton *)sender {
    if (isSelect) {
        [sender setImage:[UIImage imageNamed:@"未选"] forState:UIControlStateNormal];
        isSelect = false;
    }
    else{
        [sender setImage:[UIImage imageNamed:@"选中"] forState:UIControlStateNormal];
        isSelect = true;
    }
}

#pragma mark - 定时器
- (void)timeToSendAgain {
    _getCheckNumBtn.titleLabel.font = kFont16;
    _time --;
    if (_time == 0) {
        [_getCheckNumBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        [_getCheckNumBtn setTitleColor:THEME_COLOR forState:UIControlStateNormal];
        
        _coverBtn.hidden = YES;
        [_timer invalidate];
        _timer = nil;
        _time = 60;
    }
    else {
        [_getCheckNumBtn setTitle:[NSString stringWithFormat:@"(%ds)重新获取",_time] forState:UIControlStateNormal];
    }
}

#pragma mark - 通知
- (void)dismissRigisterView:(NSNotification *)aNotification {
    
    [self dismissViewControllerAnimated:NO completion:^{
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (ISIPHONE4) {
        if (textField == _passwordField || textField ==_passwordField2) {
            [UIView animateWithDuration:0.3 animations:^{
                self.view.frame = CGRectMake(0, -60, SCREEN_WIDTH, SCREEN_HEIGHT);
            }];
        }else if (textField == _inviteField) {
            [UIView animateWithDuration:0.3 animations:^{
                self.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
            }];
        }
    }
}

@end
