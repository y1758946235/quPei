//
//  RequirementPayViewController.m
//  LvYue
//
//  Created by 郑洲 on 16/4/18.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "RequirementPayViewController.h"
#import "MBProgressHUD+NJ.h"
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "VipModel.h"
#import "WXModel.h"
#import "Order.h"
#import "DataSigner.h"
#import <AlipaySDK/AlipaySDK.h>
#import "WXApi.h"

@interface RequirementPayViewController (){
    UITextField *moneyField;
    UIButton *weixinbtn;
    UIButton *aliPayBtn;
    NSString *payType;//1为支付宝，2为微信支付
}
@property (nonatomic,strong) VipModel *vipModel;
@property (nonatomic,strong) WXModel *wxModel;

@end

@implementation RequirementPayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"支付";
    payType = @"1";
    self.view.backgroundColor = RGBACOLOR(244, 245, 246, 1);
    [self setHeadUI];
    [self setBottomUI];
    
    UIButton *payBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 334, SCREEN_WIDTH - 20, 40)];
    [payBtn setTitle:@"支付订单" forState:UIControlStateNormal];
    [payBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    payBtn.backgroundColor = RGBACOLOR(29, 189, 159, 1);
    payBtn.layer.cornerRadius = 3.0;
    [payBtn addTarget:self action:@selector(buy) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:payBtn];
}

- (void)setHeadUI {
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 84, SCREEN_WIDTH, 80)];
    headView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:headView];
    
    UILabel *noteLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(8, 10, SCREEN_WIDTH - 16, 20)];
    noteLabel1.text = @"请输入支付金额";
    noteLabel1.font = [UIFont systemFontOfSize:16];
    [headView addSubview:noteLabel1];
    
    UILabel *rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 2.5, 25, 25)];
    rightLabel.text = @"元";
    rightLabel.textAlignment = NSTextAlignmentCenter;
    
    moneyField = [[UITextField alloc] initWithFrame:CGRectMake(10, 40, SCREEN_WIDTH - 20, 30)];
    moneyField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    moneyField.rightView = rightLabel;
    moneyField.rightViewMode = UITextFieldViewModeAlways;
    moneyField.keyboardType = UIKeyboardTypeDecimalPad;
    moneyField.layer.borderWidth = 1.0;
    moneyField.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:1].CGColor;
    [headView addSubview:moneyField];
    
}

- (void)setBottomUI {
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 174, SCREEN_WIDTH, 140)];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomView];
    
    UILabel *noteLabel3 = [[UILabel alloc] initWithFrame:CGRectMake(8, 10, SCREEN_WIDTH -  20, 20)];
    noteLabel3.text = @"请选择支付方式";
    noteLabel3.font = [UIFont systemFontOfSize:16];
    [bottomView addSubview:noteLabel3];
    
    NSArray *arr = @[@"微信",@"支付宝"];
    
    for (int i = 0; i < 2; i++) {
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(10, 40 + i * 50, SCREEN_WIDTH - 20, 1)];
        line.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
        [bottomView addSubview:line];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 50 + i * 50, 30, 30)];
        imageView.image = [UIImage imageNamed:arr[i]];
        [bottomView addSubview:imageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(55, 50 + i * 50, 100, 30)];
        label.text = arr[i];
        label.font = [UIFont systemFontOfSize:14];
        [bottomView addSubview:label];
    }
    weixinbtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 40, 52.5, 25, 25)];
    [weixinbtn setImage:[UIImage imageNamed:@"未选"] forState:UIControlStateNormal];
    [weixinbtn addTarget:self action:@selector(changeWay:) forControlEvents:UIControlEventTouchUpInside];
    weixinbtn.selected = NO;
    [bottomView addSubview:weixinbtn];
    
    aliPayBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 40, 102.5, 25, 25)];
    [aliPayBtn setImage:[UIImage imageNamed:@"选中"] forState:UIControlStateNormal];
    [aliPayBtn addTarget:self action:@selector(changeWay:) forControlEvents:UIControlEventTouchUpInside];
    aliPayBtn.selected = YES;
    [bottomView addSubview:aliPayBtn];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self.view endEditing:YES];
}

- (void)changeWay:(UIButton *)btn {
    if (btn == weixinbtn) {
        [weixinbtn setImage:[UIImage imageNamed:@"选中"] forState:UIControlStateNormal];
        [aliPayBtn setImage:[UIImage imageNamed:@"未选"] forState:UIControlStateNormal];
        payType = @"2";
    }else {
        [weixinbtn setImage:[UIImage imageNamed:@"未选"] forState:UIControlStateNormal];
        [aliPayBtn setImage:[UIImage imageNamed:@"选中"] forState:UIControlStateNormal];
        payType = @"1";
    }
}

#pragma mark 购买请求

- (void)buy{

    if ([moneyField.text rangeOfString:@"."].length > 1) {
        [MBProgressHUD showError:@"金额格式错误"];
        return;
    }
    
    NSString *channel;

    switch ([payType integerValue]) {
        case 1:
        {
            channel = @"0";
        }
            break;
        case 2:
        {
            channel = @"1";
        }
            break;
        default:
            break;
    }

    [MBProgressHUD showMessage:nil toView:self.view];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/need/buyNeed",REQUESTHEADER] andParameter:@{@"buyer":[LYUserService sharedInstance].userID,@"content":@"支付需求消费",@"amount":moneyField.text,@"createIp":@"128.0.0.1",@"channel":channel,@"seller":self.sellId} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            if ([payType isEqualToString:@"1"]) {
                self.vipModel = [[VipModel alloc] initWithDict:successResponse[@"data"][@"pay"]];
                if (self.vipModel) {
                    [self aliPay];//支付宝支付
                }
            }
            else if ([payType isEqualToString:@"2"]){
                self.wxModel = [[WXModel alloc] initWithDict:successResponse[@"data"][@"pay"]];
                if (self.wxModel) {
//                    [self wxPay];//微信支付
                    [MBProgressHUD showSuccess:@"暂不支持" toView:self.view];
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

#pragma makr 支付

- (void)aliPay{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    /*============================================================================
    =======================需要填写商户app申请的===================================
    ============================================================================*/
    NSString *partner = self.vipModel.partner;
    NSString *seller = self.vipModel.seller_id;
    NSString *privateKey = self.vipModel.rsa_key;

//    partner和seller获取失败,提示
    if ([partner length] == 0 ||
        [seller length] == 0 ||
        [privateKey length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"缺少partner或者seller或者私钥。"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }

    /*
     *生成订单信息及签名
     */
//    将商品信息赋予AlixPayOrder的成员变量
    Order *order = [[Order alloc] init];
    order.partner = partner;
    order.seller = seller;
    order.tradeNO = self.vipModel.out_trade_no; //订单ID（由商家自行制定）
    order.productName = self.vipModel.subject; //商品标题
    order.productDescription = self.vipModel.body; //商品描述
    order.amount = moneyField.text; //商品价格
    order.notifyURL =  self.vipModel.notify_url; //回调URL

    order.service = @"mobile.securitypay.pay";
    order.paymentType = @"1";
    order.inputCharset = @"utf-8";
    order.itBPay = self.vipModel.it_b_pay;
    order.showUrl = @"m.alipay.com";

    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
    NSString *appScheme = @"LvYue";

    //将商品信息拼接成字符串
    NSString *orderSpec = [order description];
    NSLog(@"orderSpec = %@",orderSpec);

    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    id<DataSigner> signer = CreateRSADataSigner(privateKey);
    NSString *signedString = [signer signString:orderSpec];

    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];

        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            NSLog(@"reslut = %@",resultDic);
            if ([resultDic[@"resultStatus"] integerValue] == 9000) {
                [MBProgressHUD showSuccess:@"购买成功"];
                
                [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/need/push",REQUESTHEADER] andParameter:@{@"user_id":self.sellId,@"content":@"应邀需求成功,发布者已付款",@"ticker":@"",@"title":@""} success:^(id successResponse) {
                    MLOG(@"结果:%@",successResponse);
                    
                } andFailure:^(id failureResponse) {
                    
                }];
                
            }
            else{
                [MBProgressHUD showError:@"购买失败"];
            }
        }];
    }
}

- (void)wxPay{
    //向微信注册
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
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

-(void)onResp:(BaseResp*)resp{
    if ([resp isKindOfClass:[PayResp class]]){
        PayResp*response=(PayResp*)resp;
        switch(response.errCode){
            caseWXSuccess:
                //服务器端查询支付通知或查询API返回的结果再提示成功
                [MBProgressHUD showSuccess:@"支付成功"];
                
                [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/need/push",REQUESTHEADER] andParameter:@{@"user_id":self.sellId,@"content":@"应邀需求成功,发布者已付款",@"ticker":@"",@"title":@""} success:^(id successResponse) {
                    MLOG(@"结果:%@",successResponse);
                    
                } andFailure:^(id failureResponse) {
                    
                }];
                break;
            default:
                [MBProgressHUD showError:@"支付失败"];
                break;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
