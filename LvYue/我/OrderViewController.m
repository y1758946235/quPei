//
//  OrderViewController.m
//  豆客项目
//
//  Created by Xia Wei on 15/9/29.
//  Copyright © 2015年 Xia Wei. All rights reserved.
//

#import "OrderViewController.h"
#import "OrderTableView.h"
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "MBProgressHUD+NJ.h"
#import "Order.h"
#import "DataSigner.h"

#import "VipModel.h"
#import "NSString+DeleteLastWord.h"
#import "WXModel.h"

@interface OrderViewController ()<UIActionSheetDelegate>

@property (nonatomic,strong) VipModel *vipModel;
@property (nonatomic,strong) OrderTableView *tableV;
@property(nonatomic,strong)UIView *modalView;
@property(nonatomic,strong)UIView *alertView;
@property(nonatomic,strong)UIButton *cancelBtn;
@property (nonatomic,strong) WXModel *wxModel;


@property (nonatomic,strong) NSString *payType;//0为支付宝，1为微信支付

@end

@implementation OrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //创建tableView
    [self tableViewCreated];
    [self modalViewCreated];
    self.payType = @"0";
    self.title = @"咨询向导";
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [_tableV.buyBtn addTarget:self action:@selector(surePay) forControlEvents:UIControlEventTouchUpInside];
    self.cancelBtn = _tableV.cancelBtn;
    [self.cancelBtn addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void) tableViewCreated{
    _tableV = [[OrderTableView alloc]initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight)];
    _tableV.guideName = self.guideName;
    _tableV.guideNum = self.guideNum;
    _tableV.guidePrice = self.guidePrice;
    [self.view addSubview:_tableV];
}

//取消按钮事件
- (void)cancelAction{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark uiactionsheet

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    self.payType = [NSString stringWithFormat:@"%ld",(long)buttonIndex];
    NSInteger price = [_tableV.textField.text integerValue];
    if (buttonIndex == 0 || buttonIndex == 1) {
        [MBProgressHUD showMessage:nil toView:self.view];
        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/order/createOrder",REQUESTHEADER] andParameter:@{@"buyer":[LYUserService sharedInstance].userID,@"seller":self.guideId,@"createIp":@"1.1.1.1",@"channel":self.payType,@"amount":[NSString stringWithFormat:@"%ld",(long)price],@"beginTime":_tableV.startTime,@"endTime":_tableV.endTime,@"content":_tableV.content} success:^(id successResponse) {
            MLOG(@"结果:%@",successResponse);
            if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                if ([self.payType integerValue] == 0) {
                    self.vipModel = [[VipModel alloc] initWithDict:successResponse[@"data"][@"pay"]];
//                    [self sendBuy];
                }
                else if ([self.payType integerValue] == 1){
                    self.wxModel = [[WXModel alloc] initWithDict:successResponse[@"data"][@"pay"]];
                    if (self.wxModel) {
                        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                        [MBProgressHUD showMessage:nil toView:self.view];
                        [self sendPay];//微信支付
                    }
                }
                
            } else {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
            }
        } andFailure:^(id failureResponse) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [MBProgressHUD showError:@"服务器繁忙,请重试"];
        }];
    }
}

#pragma mark 购买事件

- (void)surePay{
    [_tableV.textField resignFirstResponder];
    if ((!_tableV.startTime) || (!_tableV.endTime) || [_tableV.textField.text isEqualToString:@""] || [self isBlankString:_tableV.content]) {
        [self affirmBtnAction:@"内容不能为空"];
        return;
    }
    else if (_tableV.timeIsSuitable == NO){
        [self affirmBtnAction:@"亲！结束日期不能比开始日期早"];
        return;
    }
    else if ([_tableV.textField.text isEqualToString:@"0元"] || [_tableV.textField.text integerValue] <= 0){
        [self affirmBtnAction:@"亲！给个价呗"];
        return;
    }
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"请选择支付方式" delegate: self cancelButtonTitle:@"取消" destructiveButtonTitle: nil otherButtonTitles:@"支付宝",@"微信支付", nil];
    [actionSheet showInView:self.view];
    
}

#pragma mark 微信支付

- (void)sendPay{
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    //向微信注册
    [WXApi registerApp:self.wxModel.appid];
    
    PayReq *request = [[PayReq alloc] init];
    request.partnerId = [NSString stringWithFormat:@"%@",self.wxModel.partnerid];
    request.prepayId = [NSString stringWithFormat:@"%@",self.wxModel.prepayid];
    request.package = [NSString stringWithFormat:@"Sign=WXPay"];
    request.nonceStr = [NSString stringWithFormat:@"%@",self.wxModel.nonceStr];
    request.timeStamp = [self.wxModel.timestamp intValue];
    request.sign = [NSString stringWithFormat:@"%@",self.wxModel.sign];
    request.openID = [NSString stringWithFormat:@"%@",self.wxModel.appid];
    [WXApi sendReq:request];
}


//点击购买后若内容有空则弹出提示框
- (void)affirmBtnAction:(NSString *)text{
    for (UIView *subview in [_alertView subviews]) {
        if ([subview isKindOfClass:[UILabel class]]) {
            UILabel *tempLabel = (UILabel *)subview;
            tempLabel.text = text;
        }
    }
    [UIView animateWithDuration:0.2 animations:^{
        _modalView.alpha = 0.4;
        _alertView.hidden = NO;
    }];
}


//创建一个模态视图
- (void)modalViewCreated{
    //创建黑色背景
    _modalView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight)];
    [_modalView setBackgroundColor:[UIColor blackColor]];
    _modalView.alpha = 0;
    [self.view addSubview:_modalView];
    
    //创建提示框
    float alertViewHeight = 100;//提示框高度
    _alertView = [[UIView alloc]initWithFrame:CGRectMake(15, (kMainScreenHeight - alertViewHeight) / 2.0, kMainScreenWidth - 30,alertViewHeight)];
    [_alertView setBackgroundColor:[UIColor whiteColor]];
    //创建提示语言label
    UILabel *textLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, _alertView.frame.size.width, 20)];
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.font = [UIFont systemFontOfSize:12];
    textLabel.textColor = UIColorWithRGBA(100, 100, 100, 1);
    [_alertView addSubview:textLabel];
    
    //创建确定按钮
    float btnWidth = 120;//button的长度
    float btnHeight = 35;//button的高度
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn setFrame:CGRectMake((_alertView.frame.size.width - btnWidth) / 2.0, _alertView.frame.size.height - 15 - btnHeight, btnWidth, btnHeight)];
    [btn.layer setBorderColor:UIColorWithRGBA(234, 234, 234, 1).CGColor];
    [btn.layer setBorderWidth:1];
    [btn setTitle:@"确定" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(modalViewHidden) forControlEvents:UIControlEventTouchUpInside];
    btn.titleLabel.font = [UIFont systemFontOfSize:12];
    [btn setTintColor:UIColorWithRGBA(249, 60, 54, 1)];
    [_alertView addSubview:btn];
    [self.view addSubview:_alertView];
    _alertView.hidden = YES;
}

- (void)modalViewHidden{
    [UIView animateWithDuration:0.2 animations:^{
        _modalView.alpha = 0;
        _alertView.hidden = YES;
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
