//
//  WithDrawRedNumViewController.m
//  LvYue
//
//  Created by 広有射怪鸟事 on 15/12/15.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import "WithDrawRedNumViewController.h"
#import "MBProgressHUD+NJ.h"
#import "LYUserService.h"
#import "LYHttpPoster.h"

@interface WithDrawRedNumViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITextField *moneyTextField;
}

@end

@implementation WithDrawRedNumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"账户提现";
    
    UITableView *table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight) style:UITableViewStyleGrouped];
    table.delegate = self;
    table.dataSource = self;
    [self.view addSubview:table];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"申请提现后一般须5-7个工作日会将现金打入账户\n最少50元起";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myId"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"myId"];
    }
    cell.textLabel.text = @"金额";
    moneyTextField = [[UITextField alloc] initWithFrame:CGRectMake(100, cell.textLabel.frame.origin.y, kMainScreenWidth - CGRectGetMaxX(cell.textLabel.frame), 44)];
    moneyTextField.placeholder = @"请输入提现的金额";
    moneyTextField.keyboardType = UIKeyboardTypeNumberPad;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell addSubview:moneyTextField];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 100;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *foot = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 300)];
    
    UIButton *okBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 40, kMainScreenWidth - 40, 40)];
    [okBtn.layer setCornerRadius:4];
    [okBtn setTitle:@"下一步" forState:UIControlStateNormal];
    [okBtn addTarget:self action:@selector(sendWithDraw) forControlEvents:UIControlEventTouchUpInside];
    [okBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [okBtn setBackgroundColor:[UIColor colorWithRed:29/255.0 green:189/255.0 blue:159/255.0 alpha:1]];
    [foot addSubview:okBtn];
    
    return foot;
}

- (void)sendWithDraw{
    if ([moneyTextField.text integerValue] < 50) {
        [MBProgressHUD showError:@"金额不得小于50"];
        return;
    }
    
    if ([moneyTextField.text integerValue] > [self.hongdou integerValue]) {
        [MBProgressHUD showError:@"红豆余额不足"];
        return;
    }
    
    if ([self.payType integerValue] == 1) {
        if ([self.alipay isEqualToString:@""]) {
            [MBProgressHUD showError:@"收款账号为空"];
            return;
        }
    }
    else if ([self.payType integerValue] == 2){
        if ([self.weixin isEqualToString:@""]) {
            [MBProgressHUD showError:@"收款账号为空"];
            return;
        }
    }
    
    [self sendRequest];
}

- (void)sendRequest{
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/cash",REQUESTHEADER] andParameter:@{@"user_id":[NSString stringWithFormat:@"%@",[LYUserService sharedInstance].userID],@"num":moneyTextField.text} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            [[[UIAlertView alloc] initWithTitle:nil message:@"提交成功，审核成功后将打入您的账户" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil] show];
            
            [self.navigationController popToViewController:self.navigationController.viewControllers[1] animated:YES];
            
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
