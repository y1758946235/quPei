//
//  WithdrawRedViewController.m
//  LvYue
//
//  Created by 広有射怪鸟事 on 15/12/15.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import "BuyRedBeanViewController.h"
#import "Order.h"
#import "DataSigner.h"
#import <AlipaySDK/AlipaySDK.h>
#import "WXModel.h"
#import "WXApi.h"
#import "LYUserService.h"
#import "LYHttpPoster.h"
#import "MBProgressHUD+NJ.h"
#import "VipModel.h"
#import "BuyRedBeanCell.h"


//苹果内购
#import "ConstPriceEnum.h"
#import <StoreKit/StoreKit.h>

@interface BuyRedBeanViewController ()<UITableViewDataSource,UITableViewDelegate,SKPaymentTransactionObserver,SKProductsRequestDelegate, BuyRedBeanCellDelegate>
{
    UITableView *tableV;
    NSString *payType;//1为支付宝，2为微信支付
    NSString *payImage;
    
    UITextField *moneyTextField;
    
//    NSInteger _selectIndex; //选中的row
//    NSString *_selectProductID; //选中商品的产品ID
}

@property (nonatomic,strong) VipModel *vipModel;
@property (nonatomic,strong) WXModel *wxModel;


/***************  szy **************/
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *footer;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *nextStepBtn;

@end

@implementation BuyRedBeanViewController


//- (void)viewDidLoad {
//    [super viewDidLoad];
//    [self setEdgesForExtendedLayout:UIRectEdgeNone];
//    self.title = @"购买红豆";
//    [self.view setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
//    [self.view addSubview:self.tableView];
//    [self.view addSubview:self.footer];
//    [self.view addSubview:self.nextStepBtn];
//    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
//    _selectProductID = CONSTPRICE_HD_600;
//}
//
//
//
//- (UITableView *)tableView {
//    if (!_tableView) {
//        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 20, kMainScreenWidth, 200) style:UITableViewStylePlain];
//        _tableView.backgroundColor = [UIColor whiteColor];
//        _tableView.dataSource = self;
//        _tableView.delegate = self;
//        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
//        _tableView.scrollEnabled = NO;
//    }
//    return _tableView;
//}
//
//
//
//- (UIView *)footer {
//    if (!_footer) {
//        _footer = [[UIView alloc] initWithFrame:CGRectMake(0, kMainScreenHeight - 234, kMainScreenWidth, 44)];
//        _footer.backgroundColor = [UIColor whiteColor];
//        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
//        titleLabel.backgroundColor = [UIColor clearColor];
//        titleLabel.text = @"充值金额";
//        titleLabel.textColor = [UIColor darkGrayColor];
//        titleLabel.textAlignment = NSTextAlignmentRight;
//        titleLabel.font = kFont16;
//        [_footer addSubview:titleLabel];
//        [_footer addSubview:self.textField];
//    }
//    return _footer;
//}
//
//
//
//- (UITextField *)textField {
//    if (!_textField) {
//        _textField = [[UITextField alloc] initWithFrame:CGRectMake(120, 0, kMainScreenWidth - 150, 44)];
//        _textField.backgroundColor = [UIColor clearColor];
//        _textField.font = kFont17;
//        _textField.textAlignment = NSTextAlignmentRight;
//        _textField.keyboardType = UIKeyboardTypeNumberPad;
//        _textField.userInteractionEnabled = NO;
//        _textField.textColor = RGBACOLOR(29, 189, 159, 1.0);
//        _textField.text = @"¥ 6.0";
//    }
//    return _textField;
//}
//
//
//
//- (UIButton *)nextStepBtn {
//    if (!_nextStepBtn) {
//        _nextStepBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_nextStepBtn setFrame:CGRectMake(30, kMainScreenHeight - 144, kMainScreenWidth - 60, 44)];
//        _nextStepBtn.layer.cornerRadius = 5.0;
//        _nextStepBtn.layer.masksToBounds = YES;
//        [_nextStepBtn setTitle:@"下 一 步" forState:UIControlStateNormal];
//        _nextStepBtn.titleLabel.font = kFontBold17;
//        [_nextStepBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        [_nextStepBtn setBackgroundColor:RGBACOLOR(29, 189, 159, 1.0)];
//        [_nextStepBtn addTarget:self action:@selector(goToPay:) forControlEvents:UIControlEventTouchUpInside];
//        _nextStepBtn.titleLabel.font = kFont16;
//    }
//    return _nextStepBtn;
//}
//
//
//
//- (void)dealloc {
//    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
//}
//
//
//
//- (void)goToPay:(UIButton *)sender {
//    //验证输入金额
//    if ([_textField.text isEqualToString:@"0.0"]) {
//        [[[UIAlertView alloc] initWithTitle:nil message:@"充值金额不能为0" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil] show];
//        return;
//    }
//    
//    [self enterInAppPurchase];
//}
//
//
//
//
////进入苹果内购流程
//- (void)enterInAppPurchase {
//    if ([SKPaymentQueue canMakePayments]) {
//        [self requestProductPayment:_selectProductID];
//    } else {
//        [[[UIAlertView alloc] initWithTitle:nil message:@"发起购买失败,您已禁止应用内付费购买" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil] show];
//    }
//}
//
//
////请求商品
//- (void)requestProductPayment:(NSString *)productID {
//    NSArray *product = @[productID];
//    NSSet *productSet = [NSSet setWithArray:product];
//    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:productSet];
//    request.delegate = self;
//    [request start];
//    [EageProgressHUD eage_circleWaitShown:YES];
//}
//
//
//
//#pragma mark - SKProductsRequestDelegate
////收到产品返回信息
//- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
//    NSArray *product = response.products;
//    if([product count] == 0){
//        NSLog(@"--------------没有商品------------------");
//        return;
//    }
//    NSLog(@"productID:%@", response.invalidProductIdentifiers);
//    NSLog(@"产品付费数量:%ld",[product count]);
//    
//    SKProduct *p = nil;
//    for (SKProduct *pro in product) {
//        NSLog(@"%@", [pro description]);
//        NSLog(@"%@", [pro localizedTitle]);
//        NSLog(@"%@", [pro localizedDescription]);
//        NSLog(@"%@", [pro price]);
//        NSLog(@"%@", [pro productIdentifier]);
//        
//        if([pro.productIdentifier isEqualToString:_selectProductID]){
//            p = pro;
//        }
//    }
//    
//    SKPayment *payment = [SKPayment paymentWithProduct:p];
//    
//    NSLog(@"发送购买请求");
//    [[SKPaymentQueue defaultQueue] addPayment:payment];
//}
//
//
//
////请求失败
//- (void)request:(SKRequest *)request didFailWithError:(NSError *)error{
//    NSLog(@"------------------错误-----------------:%@", error);
//}
//
//- (void)requestDidFinish:(SKRequest *)request{
//    NSLog(@"------------反馈信息结束-----------------");
//}
//
//
//
////监听购买结果
//- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transaction{
//    
//    for(SKPaymentTransaction *tran in transaction){
//        
//        switch (tran.transactionState) {
//            case SKPaymentTransactionStatePurchased:
//                NSLog(@"交易完成");
//                [self completeTransaction:tran];
//                break;
//            case SKPaymentTransactionStatePurchasing:
//                NSLog(@"商品添加进列表");
//                break;
//            case SKPaymentTransactionStateRestored:
//                NSLog(@"已经购买过商品");
//                [self restoreTransaction:tran];
//                [EageProgressHUD eage_circleWaitShown:NO];
//                break;
//            case SKPaymentTransactionStateFailed:
//                NSLog(@"交易失败");
//                [self failedTransaction:tran];
//                [EageProgressHUD eage_circleWaitShown:NO];
//                break;
//            default:
//                break;
//        }
//    }
//}
//
//
////购买成功结束交易
//- (void)completeTransaction:(SKPaymentTransaction *)transaction{
//    NSLog(@"交易结束");
//    [EageProgressHUD eage_circleWaitShown:NO];
//    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
//    //通知服务器
//    NSString *selectAmount = @"";
//    if ([_selectProductID isEqualToString:CONSTPRICE_HD_600]) {
//        selectAmount = @"600";
//    } else if ([_selectProductID isEqualToString:CONSTPRICE_HD_1800]) {
//        selectAmount = @"1800";
//    } else if ([_selectProductID isEqualToString:CONSTPRICE_HD_5000]) {
//        selectAmount = @"5000";
//    } else if ([_selectProductID isEqualToString:CONSTPRICE_HD_10800]) {
//        selectAmount = @"10800";
//    } else if ([_selectProductID isEqualToString:CONSTPRICE_HD_29800]) {
//        selectAmount = @"29800";
//    }
//    [EageProgressHUD eage_circleWaitShown:YES];
//    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/buyHDFinish",REQUESTHEADER] andParameter:@{@"user_id":[LYUserService sharedInstance].userID,@"num":selectAmount} success:^(id successResponse) {
//        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
//            [EageProgressHUD eage_circleWaitShown:NO];
//        } else {
//            [EageProgressHUD eage_circleWaitShown:NO];
//            [[[UIAlertView alloc] initWithTitle:@"错误" message:@"发生了未知的错误,导致您的交易失败,请及时联系客服" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil] show];
//        }
//    } andFailure:^(id failureResponse) {
//        [EageProgressHUD eage_circleWaitShown:NO];
//        [[[UIAlertView alloc] initWithTitle:@"错误" message:@"发生了未知的错误,导致您的交易失败,请及时联系客服" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil] show];
//    }];
//}
//
//
////购买失败终止交易
//- (void)failedTransaction:(SKPaymentTransaction *)transaction {
//    if (transaction.error.code != SKErrorPaymentCancelled) {
//        [[[UIAlertView alloc] initWithTitle:nil message:@"购买失败,请重试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
//    } else {
//        NSLog(@"用户取消交易");
//    }
//    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
//}
//
//
////对于已购商品,处理恢复购买的逻辑
//- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
//    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
//}
//
//
//#pragma mark - UITableViewDataSource
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return 1;
//}
//
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return 5;
//}
//
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
//    UIImageView *selectIcon = [[UIImageView alloc] initWithFrame:CGRectMake(kMainScreenWidth - 50, 10, 20, 20)];
//    switch (indexPath.row) {
//        case 0: {
//            cell.textLabel.text = @"600颗红豆";
//            break;
//        }
//        case 1: {
//            cell.textLabel.text = @"1800颗红豆";
//            break;
//        }
//        case 2: {
//            cell.textLabel.text = @"5000颗红豆";
//            break;
//        }
//        case 3: {
//            cell.textLabel.text = @"10800颗红豆";
//            break;
//        }
//        case 4: {
//            cell.textLabel.text = @"29800颗红豆";
//            break;
//        }
//    }
//    cell.textLabel.textColor = [UIColor darkGrayColor];
//    cell.textLabel.font = kFont15;
//    [selectIcon setImage:((_selectIndex == indexPath.row) ? [UIImage imageNamed:@"选中"] : [UIImage imageNamed:@"未选"])];
//    [cell addSubview:selectIcon];
//    return cell;
//}
//
//
//
//#pragma mark - UITableViewDelegate
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [tableView deselectRowAtIndexPath:indexPath animated:NO];
//    _selectIndex = indexPath.row;
//    [self.tableView reloadData];
//    //更新结算价格
//    switch (_selectIndex) {
//        case 0: {
//            _textField.text = @"¥ 6.0";
//            _selectProductID = CONSTPRICE_HD_600;
//            break;
//        }
//        case 1: {
//            _textField.text = @"¥ 18.0";
//            _selectProductID = CONSTPRICE_HD_1800;
//            break;
//        }
//        case 2: {
//            _textField.text = @"¥ 50.0";
//            _selectProductID = CONSTPRICE_HD_5000;
//            break;
//        }
//        case 3: {
//            _textField.text = @"¥ 108.0";
//            _selectProductID = CONSTPRICE_HD_10800;
//            break;
//        }
//        case 4: {
//            _textField.text = @"¥ 298.0";
//            _selectProductID = CONSTPRICE_HD_29800;
//            break;
//        }
//    }
//}
//
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return 40.0f;
//}




#pragma mark - 支付宝+微信支付版本代码

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    payType = @"1";
    //payImage = @"alipay2";
    
    self.title = @"购买金币";
    
    [self createView];
    
}

- (void)createView{
    tableV = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight) style:UITableViewStyleGrouped];
    tableV.delegate = self;
    tableV.dataSource = self;
    [self.view addSubview:tableV];
}

- (void)nextStep{
    
    NSLog(@"%@",moneyTextField.text);
    
    if ([moneyTextField.text isEqualToString:@""] || [moneyTextField.text integerValue] == 0) {
        [MBProgressHUD showError:@"金额有误"];
        return;
    }
    
    if ([moneyTextField.text integerValue] > 1000) {
        [MBProgressHUD showError:@"金额不得超过1000"];
        return;
    }
    
    [self buy];
}

#pragma mark 购买请求

- (void)buy{
    
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
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/buyHongdou",REQUESTHEADER] andParameter:@{@"buyer":[LYUserService sharedInstance].userID,@"content":@"购买金币",@"amount":moneyTextField.text,@"createIp":@"128.0.0.1",@"channel":channel} success:^(id successResponse) {
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
                    [self wxPay];//微信支付
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
    order.amount = moneyTextField.text; //商品价格
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

#pragma mark tableview代理

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 44;
    }
    else{
        return 60;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 10;
    }
    else{
        return 20;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 1) {
        return @"付款方式";
    }
    else{
        return nil;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    if (section == 1) {
        return @"100金币=1元人民币";
    }
    else{
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        static NSString *myId = @"myId";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myId];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:myId];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = @"金额";
        
        UITextField *moneyText = [[UITextField alloc] initWithFrame:CGRectMake(100, cell.textLabel.frame.origin.y, kMainScreenWidth - CGRectGetMaxX(cell.textLabel.frame), 44)];
        moneyText.placeholder = @"请输入购买的金额";
        moneyText.keyboardType = UIKeyboardTypeNumberPad;
        [cell addSubview:moneyText];
        
        moneyTextField = moneyText;
        
        return cell;
    }
    else{
//        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"pay"];
//        cell.imageView.image = [UIImage imageNamed:payImage];
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//        if ([payType isEqualToString:@"1"]) {
//            cell.textLabel.text = @"支付宝";
//        }
//        else if ([payType isEqualToString:@"2"]){
//            cell.textLabel.text = @"微信支付";
//        }
        BuyRedBeanCell* cell = [BuyRedBeanCell cellWithTableView:tableView indexPath:indexPath];
        cell.delegate = self;
        //设置初始状态
        
        return cell;
    }
}

#pragma mark - BuyRedBeanCellDelegate
- (void)buyRedBeanCell:(BuyRedBeanCell *)cell didClickButtonIndex:(NSInteger) buttonIndex {
    if (buttonIndex == 1) {         //支付宝
        payType = @"1";
        
    }
    else if (buttonIndex == 2) {    //微信
        payType = @"2";
    }
    else if (buttonIndex == 3) {    //苹果
        payType = @"3";
        MLOG(@"苹果内购");
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
//    if (indexPath.section == 1) {
//        [moneyTextField resignFirstResponder];
//        UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"支付宝",@"微信支付", nil];
//        [action showInView:self.view];
//    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 1) {
        return 300;
    }
    return 20;
}



- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *foot = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 300)];
    UILabel* tipLabel = [[UILabel alloc] init];
    tipLabel.x = 20;
    tipLabel.y = 0;
    tipLabel.width = 200;
    tipLabel.height = 30;
    //tipLabel.backgroundColor = [UIColor redColor];
    tipLabel.text = @"100金币=1元人民币";
    tipLabel.textColor = [UIColor grayColor];
    [foot addSubview:tipLabel];
    
    UIButton *sureBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 150, kMainScreenWidth - 20, 50)];
    [sureBtn setTitle:@"下一步" forState:UIControlStateNormal];
    [sureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sureBtn addTarget:self action:@selector(nextStep) forControlEvents:UIControlEventTouchUpInside];
    [sureBtn setBackgroundColor:THEME_COLOR];
    sureBtn.layer.cornerRadius = 4;
    [sureBtn.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
    [foot addSubview:sureBtn];
    
    if (section == 1) {
        return foot;
    }
    
    return nil;
}

#pragma mark actionsheet代理

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        payType = @"1";
        payImage = @"alipay2";
        [tableV reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
    }
    else if (buttonIndex == 1){
        payType = @"2";
        payImage = @"weixin-2";
        [tableV reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
    }
}

#pragma mark scrollerview代理

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [moneyTextField resignFirstResponder];
}

@end
