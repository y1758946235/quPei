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

@interface WithDrawViewController (){
    UITextField *moneyField;
    UIButton *weixinbtn;
    UIButton *aliPayBtn;
    NSString *withDrawType;
}

@end

@implementation WithDrawViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"提现金币";
    withDrawType = @"1";
    self.view.backgroundColor = RGBACOLOR(244, 245, 246, 1);
    [self setHeadUI];
    [self setBottomUI];
    
    UIButton *withDrawBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 354, SCREEN_WIDTH - 20, 40)];
    [withDrawBtn setTitle:@"提现" forState:UIControlStateNormal];
    [withDrawBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    withDrawBtn.backgroundColor = RGBACOLOR(29, 189, 159, 1);
    withDrawBtn.layer.cornerRadius = 3.0;
    [withDrawBtn addTarget:self action:@selector(withDraw) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:withDrawBtn];
}

- (void)setHeadUI {
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 84, SCREEN_WIDTH, 100)];
    headView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:headView];
    
    UILabel *noteLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(8, 10, SCREEN_WIDTH - 16, 20)];
    noteLabel1.text = @"请输入提现金额";
    noteLabel1.font = [UIFont systemFontOfSize:16];
    [headView addSubview:noteLabel1];
    
    UILabel *rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 2.5, 40, 25)];
    rightLabel.text = @"金币";
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
    noteLabel2.text = @"提现金币不得少于50个";
    noteLabel2.font = [UIFont systemFontOfSize:12];
    noteLabel2.textColor = [UIColor grayColor];
    [headView addSubview:noteLabel2];
    
}

- (void)setBottomUI {
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 194, SCREEN_WIDTH, 140)];
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
        withDrawType = @"1";
    }else {
        [weixinbtn setImage:[UIImage imageNamed:@"未选"] forState:UIControlStateNormal];
        [aliPayBtn setImage:[UIImage imageNamed:@"选中"] forState:UIControlStateNormal];
        withDrawType = @"2";
    }
}

- (void)withDraw {
    if ([moneyField.text rangeOfString:@"."].length > 1) {
        [MBProgressHUD showError:@"金额格式错误"];
        return;
    }
    
    if ([moneyField.text integerValue] < 50) {
        [MBProgressHUD showError:@"提现金币不得少于50个" toView:self.view];
        return ;
    }
    
    if (self.coinNum.integerValue < [moneyField.text integerValue]) {
        [MBProgressHUD showError:@"提现的金币数超过拥有的金币数" toView:self.view];
        return;
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([[userDefaults objectForKey:@"alipay_Id"] isEqualToString:@""] && [withDrawType isEqualToString:@"2"]) {
        [MBProgressHUD showError:@"请到资料认证处先完善支付宝账号信息"];
        return;
    }else if ([[userDefaults objectForKey:@"weixin_Id"] isEqualToString:@""] && [withDrawType isEqualToString:@"1"]){
        [MBProgressHUD showError:@"请到资料认证处先完善微信账号信息"];
        return;
    }
    
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/need/withdraw",REQUESTHEADER] andParameter:@{@"user_id":[LYUserService sharedInstance].userID,@"num":moneyField.text} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            [moneyField resignFirstResponder];
            [MBProgressHUD showSuccess:@"提现成功，请等待审核后到账" toView:self.view];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshAccount" object:nil];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        } else {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
     
    
    
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/cash",REQUESTHEADER] andParameter:@{@"user_id":[LYUserService sharedInstance].userID,@"num":moneyField.text} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            [moneyField resignFirstResponder];
            [MBProgressHUD showSuccess:@"提现成功，请等待审核后到账" toView:self.view];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshAccount" object:nil];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        } else {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];

}


@end
