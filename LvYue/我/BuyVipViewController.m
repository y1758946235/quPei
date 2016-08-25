//
//  BuyVipViewController.m
//  LvYue
//
//  Created by 广有射怪鸟事 on 15/10/7.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import "BuyVipViewController.h"
#import "CustomTableViewCell.h"
#import "MBProgressHUD+NJ.h"
#import "LYUserService.h"
#import "LYHttpPoster.h"
#import "Order.h"
#import "DataSigner.h"
#import <AlipaySDK/AlipaySDK.h>
#import "VipModel.h"
#import "WXModel.h"
#import "WXApi.h"
#import "AFNetworking.h"
#import "VipProtocolViewController.h"

#import "APAuthV2Info.h"

//苹果内购
#import "ConstPriceEnum.h"
#import <StoreKit/StoreKit.h>

@interface BuyVipViewController ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,SKPaymentTransactionObserver,SKProductsRequestDelegate, CustomTableViewCellDelegate>{
    enum WXScene _scene;
    NSString *Token;
    long token_time;
    
    //内购参数
    NSString *_selectProductID; //已选的商品ID
}

@property (nonatomic,strong) NSString *selectMonth;//记录我点击了几月
@property (nonatomic,strong) NSString *totalPrice;//记录我要花多少钱3
@property (nonatomic,strong) NSString *sale;

@property (nonatomic,strong) NSString *payType;//支付方式,0支付宝，1微信 2金币 3苹果内购

@property (nonatomic,strong) VipModel *vipModel;
@property (nonatomic,strong) WXModel *wxModel;

@property (nonatomic,strong) UITableView *table;

@end

@implementation BuyVipViewController

- (instancetype)init
{
    if (self = [super init]) {
        _scene = WXSceneSession;
    }
    token_time = 0;
    return self;
}



- (void)viewDidLoad {
    [super viewDidLoad];

    
    [self.navigationController setNavigationBarHidden:NO];
    
    self.sale = @"0";
    self.selectMonth = @"三个月";
    NSInteger pr = [self.vip_price integerValue];
    self.totalPrice = [NSString stringWithFormat:@"%ld",pr * 3];
    //默认苹果内购(3)
    self.payType = @"3";
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    _selectProductID = CONSTPRICE_VIP_3;
    
    self.title = @"购买会员";
    
    self.table = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    self.table.delegate = self;
    self.table.dataSource = self;
    //self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.table];
}

- (void)dealloc {
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

#pragma mark tableview代理

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 3;
    }
    else if (section == 1) {
        return 3;
    }
    else{
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
   
    CustomTableViewCell* cell  = [CustomTableViewCell cellWithTableView:tableView indexPath:indexPath];
    cell.delegate = self;
    if (indexPath.section == 0) { //月数
        cell.selectBtn.selected = NO;
        if (indexPath.row == [self.sale intValue]) { //设置默认选中
            cell.selectBtn.selected = YES;
        }
        
    }
    else if (indexPath.section == 1) { //支付方式
        cell.leftPayButton.selected = NO;
        cell.rightPayButton.selected = NO;
//        if (indexPath.row == 1) { //在金币（3）与支付宝（0）的cell
//            if ([self.payType integerValue] == 2) { //金币
//                cell.leftPayButton.selected = YES;
//                cell.rightPayButton.selected = NO;
//            }
//            else if ([self.payType integerValue] == 0) {//支付宝
//                cell.leftPayButton.selected = NO;
//                cell.rightPayButton.selected = YES;
//            }
//        }
//        else if (indexPath.row == 2) { //在微信（1）与苹果（4）的cell
//            if ([self.payType integerValue] == 1) { //微信
//                cell.leftPayButton.selected = YES;
//                cell.rightPayButton.selected = NO;
//            }
//            else if ([self.payType integerValue] == 3) {//苹果
//                cell.leftPayButton.selected = NO;
//                cell.rightPayButton.selected = YES;
//            }
//        }
        
        if (indexPath.row == 1) { //在金币（3）与苹果（3）的cell
            //judge hide CoinBtn
            cell.rightPayButton.hidden = YES;//hide //judge hide Coin
            if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"ShowGetCoinKey"] integerValue]== 0) {
                cell.rightPayButton.hidden = YES;
            }
            else {
                cell.rightPayButton.hidden = NO;
            }
            
            if ([self.payType integerValue] == 2) { //金币
                cell.leftPayButton.selected = NO;
                cell.rightPayButton.selected = YES;
                
            }
            else if ([self.payType integerValue] == 3) {//苹果
                cell.leftPayButton.selected = YES;
                cell.rightPayButton.selected = NO;
            }
        }
        else if (indexPath.row == 2) { //在微信（1）与支付宝（0）的cell
            if ([self.payType integerValue] == 1) { //微信
                cell.leftPayButton.selected = YES;
                cell.rightPayButton.selected = NO;
            }
            else if ([self.payType integerValue] == 0) {//支付宝
                cell.leftPayButton.selected = NO;
                cell.rightPayButton.selected = YES;
            }
            //判断隐藏
            if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"ShowGetCoinKey"] integerValue]== 0) {
                cell.hidden = YES;
            }
            else {
                cell.hidden = NO;
            }
            
        }
        
    }
    else { //月数与价格
        NSInteger typeID = [self.payType integerValue];
        
        //设置月数
        cell.month.text = self.selectMonth;
        
        //设置价格
        switch (typeID) {
            case 0:  {  //支付宝
                cell.price.text = [NSString stringWithFormat:@"%@元",self.totalPrice];
                break;
            }
            case 1:  {  //微信支付
                cell.price.text = [NSString stringWithFormat:@"%@元",self.totalPrice];
                break;
            }
            case 2:  {  //金币支付
                NSInteger spendCoin = [self.totalPrice integerValue] * 100;
                //self.totalPrice = [NSString stringWithFormat:@"%ld",(long)spendCoin];
                cell.price.text = [NSString stringWithFormat:@"%ld金币",(long)spendCoin];
                break;
            }
            case 3:  {  //苹果内购
                cell.price.text = [NSString stringWithFormat:@"%@元",self.totalPrice];
                break;
            }
            
            default:
                break;
    }
        
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    float p = [self.vip_price floatValue];
    float a = [self.vip_year_price floatValue];
    //月数,默认金币
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
            {
                p = p * 3;
                self.totalPrice = [NSString stringWithFormat:@"%.0f",p];
                self.selectMonth = @"3个月";
                _selectProductID = CONSTPRICE_VIP_3;
            }
                break;
            case 1:
            {
                p = p * 6;
                self.totalPrice = [NSString stringWithFormat:@"%.0f",p];
                self.selectMonth = @"6个月";
                _selectProductID = CONSTPRICE_VIP_6;
            }
                break;
            case 2:
            {
                self.totalPrice = [NSString stringWithFormat:@"%.0f",a];
                self.selectMonth = @"12个月";
                _selectProductID = CONSTPRICE_VIP_12;
            }
                break;
            default:
                break;
        }
        self.sale = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
        [tableView reloadData];

    }
    //支付方式
    if (indexPath.section == 1) {
//        if (indexPath.row == 0) {
//            UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"支付方式" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"支付宝",@"微信支付",@"苹果内购", nil];
//            [action showInView:self.view];
//        }
//        switch (indexPath.row) {
//            case 0:
//            {
//                self.payType = @"0";
//            }
//                break;
//            case 1:
//            {
//                self.payType = @"1";
//            }
//                break;
//            case 2:
//            {
//                self.payType = @"2";
//            }
//                break;
//            default:
//                break;
//        }
//        [tableView reloadData];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 44;
    }
    else if (indexPath.section == 1) {
        //判断隐藏
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"ShowGetCoinKey"] integerValue]== 0) {
            if (indexPath.row == 2) {
                return 0.000001;
            }
        }
        return 50;
    }
    else {
        return 44;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    UILabel *becomeLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 20, 150, 20)];
    becomeLabel.font = [UIFont systemFontOfSize:14.0];
    becomeLabel.text = @"成为会员即表示同意";
    [view addSubview:becomeLabel];
    
    UIButton *proBtn = [[UIButton alloc] initWithFrame:CGRectMake(150, 20, 100, 20)];
    [proBtn.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
    [proBtn setTitleColor:RGBCOLOR(29, 189, 159) forState:UIControlStateNormal];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"豆客会员协议"];
    NSRange strRange = {0,[str length]};
    [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange];
    [str addAttribute:NSForegroundColorAttributeName value:RGBCOLOR(29, 189, 159) range:strRange];
    [proBtn setAttributedTitle:str forState:UIControlStateNormal];
    [proBtn addTarget:self action:@selector(checkProtocol) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:proBtn];
    
    UIButton *payBtn = [[UIButton alloc] initWithFrame:CGRectMake(30, 180, kMainScreenWidth - 60, 50)];
    [payBtn setBackgroundColor:RGBACOLOR(29, 189, 159, 1)];
    [payBtn setTitle:@"确认支付" forState:UIControlStateNormal];
    [payBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [payBtn.layer setCornerRadius:4];
    [payBtn addTarget:self action:@selector(surePay) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:payBtn];
    
    if (section == 0 || section == 1) {
        
        return nil;
    }
    else{
        return view;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 2) {
        return 300;
    }
    else{
        return 0.1;
    }
}

#pragma mark actionsheetdelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
        {
            self.payType = @"0";
            [self pay];
        }
            break;
        case 1:
        {
            self.payType = @"1";
            [self pay];
        }
            break;
        case 2:
        {
//            self.payType = @"2";
//            [self.table reloadData];
            //验证输入金额
            if ([self.totalPrice isEqualToString:@"0.0"]) {
                [[[UIAlertView alloc] initWithTitle:nil message:@"您还没有选择开通的会员期限" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil] show];
                return;
            }
            
            [self enterInAppPurchase];
        }
            break;
        default:
            break;
    }
}

#pragma mark - CustomTableViewCellDelegate
- (void)customTableViewCell:(CustomTableViewCell *)customTableViewCell didClickButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {       //支付宝(0)
        self.payType = @"0";
        
    }
    else if (buttonIndex == 1) {  //微信支付(1)
        self.payType = @"1";
    }
    else if (buttonIndex == 2) {  //苹果内购(3)
        self.payType = @"3";
    }
    else if (buttonIndex == 3) {  //金币支付(2)
        self.payType = @"2";
    }
    
    [self.table reloadData];
}

#pragma mark 购买事件

- (void)surePay{
    if ([self.payType isEqualToString:@"2"]) {                                       //金币
        [self payWithCoin];
        return;
    }
    
    if ([self.payType isEqualToString:@"0"]||[self.payType isEqualToString:@"1"]) {  //支付宝、微信支付
        [self pay];
        return;
    }
    if ([self.payType isEqualToString:@"0"]||[self.payType isEqualToString:@"3"]) {  //苹果支付
        [self enterInAppPurchase];
    }
//    if (_isShow) {
//        [self pay]; //支付宝、微信支付
//    }else {//苹果支付
//        [self enterInAppPurchase];
//    }
    
    
}

- (void)payWithCoin {
    if ([self.payType integerValue] == 2){//金币
        if (self.coinNum.integerValue < self.totalPrice.integerValue) {
            [MBProgressHUD showError:@"金币数不足"];
            return;
        }
        
        [MBProgressHUD showMessage:nil toView:self.view];
        NSString* coins = [NSString stringWithFormat:@"%ld", self.totalPrice.integerValue*100];
        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/buyVipByHongdou",REQUESTHEADER] andParameter:@{@"userId":[LYUserService sharedInstance].userID,@"amount": coins, @"detail":self.selectMonth,@"createIp":@"127.0.0.1",@"channel":self.payType} success:^(id successResponse) {
            MLOG(@"结果:%@",successResponse);
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {//成功
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [MBProgressHUD showSuccess:[NSString stringWithFormat:@"会员购买%@",successResponse[@"msg"]]];
                    
                });
                [self.navigationController popToRootViewControllerAnimated:YES];
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                
            }
            else {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
            }
        } andFailure:^(id failureResponse) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [MBProgressHUD showError:@"服务器繁忙,请重试"];
        }];
    }
}

- (void)pay {
    [MBProgressHUD showMessage:nil toView:self.view];
    //获取购买金额

    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/buyVip",REQUESTHEADER] andParameter:@{@"userId":[LYUserService sharedInstance].userID,@"amount": self.totalPrice, @"detail":self.selectMonth,@"createIp":@"127.0.0.1",@"channel":self.payType} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            
            if ([self.payType integerValue] == 0) {
                self.vipModel = [[VipModel alloc] initWithDict:successResponse[@"data"][@"pay"]];
                if (self.vipModel) {
                    [self sendBuy];//支付宝支付
                    
                }
            }
            else if ([self.payType integerValue] == 1){
                self.wxModel = [[WXModel alloc] initWithDict:successResponse[@"data"][@"pay"]];
                if (self.wxModel) {
                    [self sendPay];//微信支付
                    
                }
            }
        }
        else {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
}

//进入苹果内购流程
- (void)enterInAppPurchase {
    if ([SKPaymentQueue canMakePayments]) {
        [self requestProductPayment:_selectProductID];
    } else {
        [[[UIAlertView alloc] initWithTitle:nil message:@"发起购买失败,您已禁止应用内付费购买" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil] show];
    }
}

//获取个人信息
- (void)getUserInfo {
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/need/wallet",REQUESTHEADER] andParameter:@{@"user_id":[LYUserService sharedInstance].userID} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            //_allMoneyLabel.text = [NSString stringWithFormat:@"¥%@",successResponse[@"data"][@"data"][@"money"]];
            //_withDrawingLabel.text = [NSString stringWithFormat:@"¥%@",successResponse[@"data"][@"data"][@"tixian"]];
            //CGFloat money = [successResponse[@"data"][@"data"][@"money"] floatValue] - [successResponse[@"data"][@"data"][@"tixian"] floatValue];
            //_noWithDrawLabel.text = [NSString stringWithFormat:@"¥%.2f",money];
            
        } else {
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
}


//请求商品
- (void)requestProductPayment:(NSString *)productID {
    NSArray *product = @[productID];
    NSSet *productSet = [NSSet setWithArray:product];
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:productSet];
    request.delegate = self;
    [request start];
    [EageProgressHUD eage_circleWaitShown:YES];
}



#pragma mark - SKProductsRequestDelegate
//收到产品返回信息
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSArray *product = response.products;
    if([product count] == 0){
        MLOG(@"--------------没有商品------------------");
        return;
    }
    NSLog(@"productID:%@", response.invalidProductIdentifiers);
    NSLog(@"产品付费数量:%ld",[product count]);
    
    SKProduct *p = nil;
    for (SKProduct *pro in product) {
        MLOG(@"%@", [pro description]);
        MLOG(@"%@", [pro localizedTitle]);
        MLOG(@"%@", [pro localizedDescription]);
        MLOG(@"%@", [pro price]);
        MLOG(@"%@", [pro productIdentifier]);
        
        if([pro.productIdentifier isEqualToString:_selectProductID]){
            p = pro;
        }
    }
    
    SKPayment *payment = [SKPayment paymentWithProduct:p];
    
    MLOG(@"发送购买请求");
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}



//请求失败
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error{
    MLOG(@"------------------错误-----------------:%@", error);
}

- (void)requestDidFinish:(SKRequest *)request{
    MLOG(@"------------反馈信息结束-----------------");
}



//监听购买结果
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transaction{
    
    for(SKPaymentTransaction *tran in transaction){
        
        switch (tran.transactionState) {
            case SKPaymentTransactionStatePurchased:
                MLOG(@"交易完成");
                [self completeTransaction:tran];
                break;
            case SKPaymentTransactionStatePurchasing:
                MLOG(@"商品添加进列表");
                break;
            case SKPaymentTransactionStateRestored:
                MLOG(@"已经购买过商品");
                [self restoreTransaction:tran];
                [EageProgressHUD eage_circleWaitShown:NO];
                break;
            case SKPaymentTransactionStateFailed:
                MLOG(@"交易失败");
                [self failedTransaction:tran];
                [EageProgressHUD eage_circleWaitShown:NO];
                break;
            default:
                break;
        }
    }
}


//购买成功结束交易
- (void)completeTransaction:(SKPaymentTransaction *)transaction{
    NSLog(@"交易结束");
    [EageProgressHUD eage_circleWaitShown:NO];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    //通知服务器
    NSString *selectTime = @"";
    if ([_selectProductID isEqualToString:CONSTPRICE_VIP_3]) {
        selectTime = @"3";
    } else if ([_selectProductID isEqualToString:CONSTPRICE_VIP_6]) {
        selectTime = @"6";
    } else {
        selectTime = @"12";
    }
    [EageProgressHUD eage_circleWaitShown:YES];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/buyAppleVip",REQUESTHEADER] andParameter:@{@"user_id":[LYUserService sharedInstance].userID,@"amount":selectTime,@"detail":[NSString stringWithFormat:@"用户%@通过苹果内购流程成功购买了%@的会员权限",[LYUserService sharedInstance].userID,_selectMonth]} success:^(id successResponse) {
        MLOG(@"%@",successResponse);
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            [EageProgressHUD eage_circleWaitShown:NO];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMyInfomation" object:nil];
        } else {
            MLOG(@"信息:%@",successResponse[@"msg"]);
            [EageProgressHUD eage_circleWaitShown:NO];
            [[[UIAlertView alloc] initWithTitle:@"错误" message:@"发生了未知的错误,导致您的交易失败,请及时联系客服" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil] show];
        }
    } andFailure:^(id failureResponse) {
        MLOG(@"%@",failureResponse);
        [EageProgressHUD eage_circleWaitShown:NO];
        [[[UIAlertView alloc] initWithTitle:@"错误" message:@"发生了未知的错误,导致您的交易失败,请及时联系客服" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil] show];
    }];
}


//购买失败终止交易
- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    if (transaction.error.code != SKErrorPaymentCancelled) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"购买失败,请重试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
    } else {
        MLOG(@"用户取消交易");
    }
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}


//对于已购商品,处理恢复购买的逻辑
- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}


#pragma mark 金币支付
- (void) butWithCoin {
    
}


#pragma mark 微信支付

- (void)sendPay{

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

#pragma mark 支付宝
- (void)sendBuy{
    /*============================================================================*/
    /*=======================需要填写商户app申请的===================================*/
    /*============================================================================*/
    NSString *partner = self.vipModel.partner;
    NSString *seller = self.vipModel.seller_id;
    NSString *privateKey = self.vipModel.rsa_key;
    /*============================================================================*/
    /*============================================================================*/
    /*============================================================================*/

    
    //partner和seller获取失败,提示
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
    //将商品信息赋予AlixPayOrder的成员变量
    Order *order = [[Order alloc] init];
    order.partner = partner;
    order.seller = seller;
    order.tradeNO = self.vipModel.out_trade_no; //订单ID（由商家自行制定）
    order.productName = self.vipModel.subject; //商品标题
    order.productDescription = self.vipModel.body; //商品描述
    order.amount = self.vipModel.total_fee; //商品价格
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
                NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
                [user setObject:@"1" forKey:@"isVip"];
                [user synchronize];
                [LYUserService sharedInstance].userDetail.isVip = [user objectForKey:@"isVip"];
                [MBProgressHUD showSuccess:@"开通成功"];
            }
            else{
                [MBProgressHUD showError:@"开通失败"];
            }
        }];
    }
}


#pragma mark 会员协议

- (void)checkProtocol{
    VipProtocolViewController *pro = [[VipProtocolViewController alloc] init];
    [self.navigationController pushViewController:pro animated:YES];
}

@end
