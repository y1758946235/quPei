//
//  WithDrawViewController.m
//  LvYue
//
//  Created by 郑洲 on 16/4/5.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "WithDrawViewController.h"
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "MBProgressHUD+NJ.h"
#import "MyMoneyVC.h"
@interface WithDrawViewController ()<
UIActionSheetDelegate>{
   
    UITextField *moneyField;
    UITextField *accountField;
    UIButton *weixinbtn;
    UIButton *aliPayBtn;
    NSString *withDrawType; //0支付宝 1微信
}

@end

@implementation WithDrawViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"提现积分";
    withDrawType = @"1";//默认是微信支付
    self.view.backgroundColor = RGBACOLOR(244, 245, 246, 1);
    //导航栏返回按钮
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(16, 38, 28, 14)];
    [button setTitleColor:[UIColor colorWithHexString:@"#424242"] forState:UIControlStateNormal];
    [button setTitle:@"返回" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [button addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = back;

    [self setHeadUI];
    [self setMiddleUI];
    [self setBottomUI];
    
    UIButton *withDrawBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 394, SCREEN_WIDTH - 20, 40)];
    [withDrawBtn setTitle:@"提现" forState:UIControlStateNormal];
    [withDrawBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    withDrawBtn.backgroundColor = RGBACOLOR(29, 189, 159, 1);
    withDrawBtn.layer.cornerRadius = 3.0;
    [withDrawBtn addTarget:self action:@selector(withDraw) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:withDrawBtn];
}
-(void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
    
    
}
- (void)setHeadUI {
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 14, SCREEN_WIDTH, 100)];
    headView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:headView];
    
    UILabel *noteLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(8, 10, SCREEN_WIDTH - 16, 20)];
    noteLabel1.text = @"请输入提现积分";
    noteLabel1.font = [UIFont systemFontOfSize:16];
    [headView addSubview:noteLabel1];
    
    UILabel *rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 2.5, 40, 25)];
    rightLabel.text = @"积分";
    rightLabel.textAlignment = NSTextAlignmentCenter;
    
    moneyField = [[UITextField alloc] initWithFrame:CGRectMake(10, 40, SCREEN_WIDTH - 20, 35)];
    moneyField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 35)];
    moneyField.leftViewMode = UITextFieldViewModeAlways;
    moneyField.keyboardType = UIKeyboardTypeDecimalPad;
    moneyField.rightView = rightLabel;
    moneyField.rightViewMode = UITextFieldViewModeAlways;
    moneyField.layer.borderWidth = 1.0;
    moneyField.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:1].CGColor;
    [headView addSubview:moneyField];
    
    UIImageView *noteImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 78, 14, 14)];
    noteImageView.image = [UIImage imageNamed:@"提醒"];
    [headView addSubview:noteImageView];
    
    UILabel *noteLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(30, 75, SCREEN_WIDTH - 20, 20)];
    noteLabel2.text = @"提现积分不得少于3000个";
    noteLabel2.font = [UIFont systemFontOfSize:12];
    noteLabel2.textColor = [UIColor grayColor];
    [headView addSubview:noteLabel2];
    
}

- (void)setMiddleUI {
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 124, SCREEN_WIDTH, 100)];
    headView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:headView];
    
    UILabel *noteLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(8, 10, SCREEN_WIDTH - 16, 20)];
    noteLabel1.text = @"请输入提现帐号";
    noteLabel1.font = [UIFont systemFontOfSize:16];
    [headView addSubview:noteLabel1];
    
    UILabel *rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 2.5, 40, 25)];
    rightLabel.text = @"帐号";
    rightLabel.textAlignment = NSTextAlignmentCenter;
    
    accountField = [[UITextField alloc] initWithFrame:CGRectMake(10, 40, SCREEN_WIDTH - 20, 35)];
    accountField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 35)];
    accountField.leftViewMode = UITextFieldViewModeAlways;
    //http://jingyan.baidu.com/article/e75aca855a7c03142edac6c9.html 11种键盘展示
    accountField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    accountField.rightView = rightLabel;
    accountField.rightViewMode = UITextFieldViewModeAlways;
    accountField.layer.borderWidth = 1.0;
    accountField.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:1].CGColor;
    [headView addSubview:accountField];
    
    UIImageView *noteImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 78, 14, 14)];
    noteImageView.image = [UIImage imageNamed:@"提醒"];
    [headView addSubview:noteImageView];
    
    UILabel *noteLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(30, 75, SCREEN_WIDTH - 20, 20)];
    noteLabel2.text = @"请认真填写支付宝或微信帐号";
    noteLabel2.font = [UIFont systemFontOfSize:12];
    noteLabel2.textColor = [UIColor grayColor];
    [headView addSubview:noteLabel2];
    
}

- (void)setBottomUI {
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 234, SCREEN_WIDTH, 140)];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomView];
    
    UILabel *noteLabel3 = [[UILabel alloc] initWithFrame:CGRectMake(8, 10, SCREEN_WIDTH -  20, 20)];
    noteLabel3.text = @"请选择提现账户";
    noteLabel3.font = [UIFont systemFontOfSize:16];
    [bottomView addSubview:noteLabel3];
    
    //[UIImage imageNamed:@"支付宝-1"]
    NSArray *arr = @[@"微信",@"支付宝-1"];
    
    for (int i = 0; i < 2; i++) {
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(10, 40 + i * 50, SCREEN_WIDTH - 20, 1)];
        line.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
        [bottomView addSubview:line];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 50 + i * 50, 30, 30)];
        imageView.image = [UIImage imageNamed:arr[i]];
        [bottomView addSubview:imageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(55, 50 + i * 50, 100, 30)];
        label.text = arr[i];
        if (i == 1) {
            label.text = @"支付宝";
        }
        label.font = [UIFont systemFontOfSize:14];
        [bottomView addSubview:label];
    }
    weixinbtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 40, 52.5, 25, 25)];
    [weixinbtn setImage:[UIImage imageNamed:@"选中"] forState:UIControlStateNormal];
    [weixinbtn addTarget:self action:@selector(changeWay:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:weixinbtn];
    
    aliPayBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 40, 102.5, 25, 25)];
    [aliPayBtn setImage:[UIImage imageNamed:@"未选"] forState:UIControlStateNormal];
    [aliPayBtn addTarget:self action:@selector(changeWay:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:aliPayBtn];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self.view endEditing:YES];
}

- (void)changeWay:(UIButton *)btn {
    if (btn == weixinbtn) {
        [weixinbtn setImage:[UIImage imageNamed:@"选中"] forState:UIControlStateNormal];
        [aliPayBtn setImage:[UIImage imageNamed:@"未选"] forState:UIControlStateNormal];
        withDrawType = @"1";//微信
    }else {
        [weixinbtn setImage:[UIImage imageNamed:@"未选"] forState:UIControlStateNormal];
        [aliPayBtn setImage:[UIImage imageNamed:@"选中"] forState:UIControlStateNormal];
        withDrawType = @"0";//支付宝
    }
}

- (void)withDraw {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"请仔细核对下该提现帐号哦～" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
//    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/cache/getWithdrawalFee",REQUESTHEADER] andParameter:nil success:^(id successResponse) {
//        
//        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
//          
//        } else {
//            [MBProgressHUD hideHUD];
//            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
//        }
//    } andFailure:^(id failureResponse) {
//        [MBProgressHUD hideHUD];
//        [MBProgressHUD showError:@"服务器繁忙,请重试"];
//    }];
    

//    if ([moneyField.text rangeOfString:@"."].length > 1) {
//        [MBProgressHUD showError:@"金额格式错误"];
//        return;
//    }
//    
//    if ([moneyField.text integerValue] < 50) {
//        [MBProgressHUD showError:@"提现金币不得少于50个" toView:self.view];
//        return ;
//    }
//    
//    if (self.coinNum.integerValue < [moneyField.text integerValue]) {
//        [MBProgressHUD showError:@"提现的金币数超过拥有的金币数" toView:self.view];
//        return;
//    }
//    
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    if ([[userDefaults objectForKey:@"alipay_Id"] isEqualToString:@""] && [withDrawType isEqualToString:@"2"]) {
//        [MBProgressHUD showError:@"请到资料认证处先完善支付宝账号信息"];
//        return;
//    }else if ([[userDefaults objectForKey:@"weixin_Id"] isEqualToString:@""] && [withDrawType isEqualToString:@"1"]){
//        [MBProgressHUD showError:@"请到资料认证处先完善微信账号信息"];
//        return;
//    }
//    
//    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/need/withdraw",REQUESTHEADER] andParameter:@{@"user_id":[LYUserService sharedInstance].userID,@"num":moneyField.text} success:^(id successResponse) {
//        MLOG(@"结果:%@",successResponse);
//        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
//            [moneyField resignFirstResponder];
//            [MBProgressHUD showSuccess:@"提现成功，请等待审核后到账" toView:self.view];
//            
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshAccount" object:nil];
//            
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [self.navigationController popViewControllerAnimated:YES];
//            });
//        } else {
//            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
//        }
//    } andFailure:^(id failureResponse) {
//        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//        [MBProgressHUD showError:@"服务器繁忙,请重试"];
//    }];
//     
//    
//    
//    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/cash",REQUESTHEADER] andParameter:@{@"user_id":[LYUserService sharedInstance].userID,@"num":moneyField.text} success:^(id successResponse) {
//        MLOG(@"结果:%@",successResponse);
//        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
//            [moneyField resignFirstResponder];
//            [MBProgressHUD showSuccess:@"提现成功，请等待审核后到账" toView:self.view];
//            
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshAccount" object:nil];
//            
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [self.navigationController popViewControllerAnimated:YES];
//            });
//        } else {
//            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
//        }
//    } andFailure:^(id failureResponse) {
//        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//        [MBProgressHUD showError:@"服务器繁忙,请重试"];
//    }];

}
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {//确定的造作
        //操作的代码
        [self sendRequest];
    }
}
- (void)sendRequest{
    
    
        if ([moneyField.text rangeOfString:@"."].length > 1) {
            [MBProgressHUD showError:@"金额格式错误"];
            return;
        }
    
        if ([moneyField.text integerValue] < 3000) {
            [MBProgressHUD showError:@"提现积分不得少于3000" toView:self.view];
            return ;
        }
    
        if (self.coinNum.integerValue < [moneyField.text integerValue]) {
            [MBProgressHUD showError:@"提现的积分数超过拥有的积分数" toView:self.view];
            return;
        }
    
    if ([CommonTool dx_isNullOrNilWithObject:accountField.text] || [self isBlankString:accountField.text]) {
        [MBProgressHUD showError:@"请填写提现帐号" toView:self.view];
        return;
    }
    if ([CommonTool dx_isNullOrNilWithObject:withDrawType]) {
        [MBProgressHUD showError:@"请选择支付方式" toView:self.view];
        return;
    }
    //提现方式：0为支付宝，1为微信
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/order/addWithdrawal",REQUESTHEADER] andParameter:@{@"userId":[NSString stringWithFormat:@"%@",[CommonTool getUserID]],@"withdrawalPoint":moneyField.text,@"withdrawalChannel":withDrawType,@"withdrawalAccount":accountField.text} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            [[[UIAlertView alloc] initWithTitle:nil message:@"提交成功，审核成功后将打入您的账户" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil] show];
            
//            [self.navigationController popToViewController:self.navigationController.viewControllers[1] animated:YES];
            [self.navigationController popToViewController:self.navigationController.viewControllers[1] animated:YES];
            
        } else {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
    
    
}
#pragma mark 判断是否为空或只有空格

- (BOOL)isBlankString:(NSString *)string{
    
    if (string == nil) {
        return YES;
    }
    
    if (string == NULL) {
        return YES;
    }
    
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}
@end
