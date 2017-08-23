//
//  LYGetCoinViewController.m
//  LvYue
//
//  Created by KentonYu on 16/8/2.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "DataSigner.h"
#import "LYGetCoinHeaderView.h"
#import "LYGetCoinTableViewCell.h"
#import "LYGetCoinViewController.h"
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "MBProgressHUD+NJ.h"
#import "Order.h"
#import "VipModel.h"
#import "WXApi.h"
#import "WXModel.h"

#import <StoreKit/StoreKit.h>

typedef NS_ENUM(NSUInteger, LYGetCoinPayType) {
//    LYGetCoinPayTypeApple  = 0,
    LYGetCoinPayTypeAlipay = 0,
    LYGetCoinPayTypeWeixin = 1
};

static NSString *const LYGetCoinTableViewCellIdentity = @"LYGetCoinTableViewCellIdentity";
static NSArray *LYGetCoinGetTableViewDataArray;

@interface LYGetCoinViewController () <
    UITableViewDelegate,
    UITableViewDataSource,
    UIActionSheetDelegate,
    WXApiDelegate,
SKPaymentTransactionObserver,
SKProductsRequestDelegate
>
{
    NSString *_orderNo;//订单编号
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) LYGetCoinHeaderView *tableViewHeaderView;
@property (nonatomic, strong) UIActionSheet *payActionSheet;

@property (nonatomic, copy) NSString *selectedAppleProductID;

@end

@implementation LYGetCoinViewController

+ (void)initialize {

    LYGetCoinGetTableViewDataArray = @[
        @{
            @"coinNum": @1500,
            @"applePayID":@"com.51xiexieni.1500_4"
        },
        @{
            @"coinNum": @3000,
            @"applePayID":@"com.51xiexieni.3000_4"
        },
        @{
            @"coinNum": @12000,
            @"applePayID":@"com.51xiexieni.12000_4"
        },
        @{
            @"coinNum": @60000,
            @"applePayID":@"com.51xiexieni.60000_4"
        },
        @{
            @"coinNum": @180000,
            @"applePayID":@"com.51xiexieni.180000_4"
        }
    ];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"WeXinPayResponse" object:nil];
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"获取金币";

//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_completePay:) name:@"WeXinPayResponse" object:nil];

    [self.tableView reloadData];
   
    
}

#pragma mark TableView DataSource & Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return LYGetCoinGetTableViewDataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.f;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LYGetCoinTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LYGetCoinTableViewCellIdentity forIndexPath:indexPath];
    [cell configData:LYGetCoinGetTableViewDataArray[indexPath.row][@"coinNum"]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    [self.payActionSheet showInView:self.view];
    // 把选中的行数通过 tag 传过去
    self.payActionSheet.tag = indexPath.row;//[LYGetCoinGetTableViewDataArray[indexPath.row][@"coinNum"] integerValue];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
//    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"ShowGetCoinKey"] boolValue]) {
//        if (buttonIndex == 0 || buttonIndex == 1 || buttonIndex == 2) {
            [self buy:buttonIndex rowIndex:actionSheet.tag];
//        }
//    } else {
//        if (buttonIndex == 0) {
//            [self buy:buttonIndex rowIndex:actionSheet.tag];
//        }
//    }
}


#pragma mark -

//收到产品返回信息
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    
    NSLog(@"--------------收到产品反馈消息---------------------");
    NSArray *product = response.products;
    if([product count] == 0){
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        NSLog(@"--------------没有商品------------------");
        return;
    }
    
    NSLog(@"productID:%@", response.invalidProductIdentifiers);
    NSLog(@"产品付费数量:%lu",(unsigned long)[product count]);
    
    SKProduct *p = nil;
    for (SKProduct *pro in product) {
        NSLog(@"%@", [pro description]);
        NSLog(@"%@", [pro localizedTitle]);
        NSLog(@"%@", [pro localizedDescription]);
        NSLog(@"%@", [pro price]);
        NSLog(@"%@", [pro productIdentifier]);
        
        if([pro.productIdentifier isEqualToString:self.selectedAppleProductID]){
            p = pro;
        }
    }
    
    SKPayment *payment = [SKPayment paymentWithProduct:p];
    
    NSLog(@"发送购买请求");
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

//请求失败
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [MBProgressHUD showError:@"支付失败"];
    NSLog(@"------------------错误-----------------:%@", error);
}

- (void)requestDidFinish:(SKRequest *)request{
    NSLog(@"------------反馈信息结束-----------------");
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transaction{
    for(SKPaymentTransaction *tran in transaction){
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        switch (tran.transactionState) {
            case SKPaymentTransactionStatePurchased:{
                NSLog(@"交易完成");
                [self p_completePay:nil];
                [[SKPaymentQueue defaultQueue] finishTransaction:tran];
            }
                break;
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"商品添加进列表");
                break;
            case SKPaymentTransactionStateRestored:{
                NSLog(@"已经购买过商品");
                [[SKPaymentQueue defaultQueue] finishTransaction:tran];
            }
                break;
            case SKPaymentTransactionStateFailed:{
                NSLog(@"交易失败");
                [[SKPaymentQueue defaultQueue] finishTransaction:tran];
                [MBProgressHUD showError:@"购买失败"];
            }
                break;
            default:
                break;
        }
    }
}

//交易结束
- (void)completeTransaction:(SKPaymentTransaction *)transaction{
    NSLog(@"交易结束");
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

#pragma mark - Pravite

- (void)buy:(LYGetCoinPayType)type rowIndex:(NSInteger)rowIndex {

    NSDictionary *payInfo = LYGetCoinGetTableViewDataArray[rowIndex];
    
    NSString *channel;
    NSNumber *payCoinNum = @([payInfo[@"coinNum"] integerValue] / 100);
  
    switch (type) {
        case LYGetCoinPayTypeAlipay: {
            channel = @"0";
            break;
        }
        case LYGetCoinPayTypeWeixin: {
            channel = @"1";
            break;
            
        default:
            break;
        }
            
//        case LYGetCoinPayTypeApple: {
//            channel = @"2";
//            break;
//        }
    }

    [MBProgressHUD showMessage:nil toView:self.view];
    //@"orderAmount": payCoinNum,@"orderNumber":[NSString stringWithFormat:@"%@",payInfo[@"coinNum"]],
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/order/addOrderDetail", REQUESTHEADER]
        andParameter:@{
            @"userId": [CommonTool getUserID],
            @"orderContent": @"购买金币",
            @"orderAmount": payCoinNum,
            @"orderNumber":[NSString stringWithFormat:@"%@",payInfo[@"coinNum"]],
            @"createIp": @"128.0.0.1",
            @"orderChannel": channel
        }
        success:^(id successResponse) {
            MLOG(@"结果:%@", successResponse);
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
                
                _orderNo = successResponse[@"data"][@"orderDetail"][@"orderNo"];
                switch (type) {
                    case LYGetCoinPayTypeAlipay: {
//                        [self aliPay:[[VipModel alloc] initWithDict:successResponse[@"data"][@"pay"]]]; //支付宝支付
                        break;
                    }
                    case LYGetCoinPayTypeWeixin: {
                        [self wxPay:[[WXModel alloc] initWithDict:successResponse[@"data"][@"pay"]]]; //微信支付
                        break;
                        
                    default:
                        break;
                    }

                }
            } else {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"msg"]]];
            }
        }
        andFailure:^(id failureResponse) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [MBProgressHUD showError:@"服务器繁忙,请重试"];
        }];
}


- (void)wxPay:(WXModel *)wxModel {
    //向微信注册
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [WXApi registerApp:wxModel.appid];

    PayReq *request   = [[PayReq alloc] init];
    request.partnerId = [NSString stringWithFormat:@"%@", wxModel.partnerid];
    request.prepayId  = [NSString stringWithFormat:@"%@", wxModel.prepayid];
    request.package   = [NSString stringWithFormat:@"Sign=WXPay"];
    request.nonceStr  = [NSString stringWithFormat:@"%@", wxModel.nonceStr];
    request.timeStamp = [wxModel.timestamp intValue];
    request.sign      = [NSString stringWithFormat:@"%@", wxModel.sign];
    request.openID    = [NSString stringWithFormat:@"%@", wxModel.appid];
    [WXApi sendReq:request];
}

- (void)applePay:(NSString *)productID {
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    if([SKPaymentQueue canMakePayments]){
        NSLog(@"-------------请求对应的产品信息----------------");
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        NSSet *nsset = [NSSet setWithArray:@[productID]];
        SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:nsset];
        request.delegate = self;
        [request start];
    }else{
        NSLog(@"不允许程序内付费");
    }
}


- (void)p_completePay:(NSNotification *)obj {

    if (obj) {
        if (![obj.object boolValue]) {
            [MBProgressHUD showError:@"充值失败"];
            return;
        }
    }

//    NSDictionary *payInfo = LYGetCoinGetTableViewDataArray[self.payActionSheet.tag];
    
    [EageProgressHUD eage_circleWaitShown:YES];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/order/updateOrderDetail", REQUESTHEADER]
        andParameter:@{
                       @"orderNo": _orderNo,
                       @"userCaptcha":[CommonTool getUserCaptcha],
                       @"orderToken":[CommonTool md5:[NSString stringWithFormat:@"%@%@",_orderNo,[CommonTool getUserID]]]
        }
        success:^(id successResponse) {
            if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
                [EageProgressHUD eage_circleWaitShown:NO];
                // 更新账户余额
                self.accountAmount += [LYGetCoinGetTableViewDataArray[self.payActionSheet.tag][@"coinNum"] integerValue];
                self.tableViewHeaderView.accountAmount = self.accountAmount;
//                // 更新前一个页面的余额
                self.changeAmount(self.accountAmount);
            } else {
                [EageProgressHUD eage_circleWaitShown:NO];
                [[[UIAlertView alloc] initWithTitle:@"错误" message:@"发生了未知的错误,导致您的交易失败,请及时联系客服" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil] show];
            }
        }
        andFailure:^(id failureResponse) {
            [EageProgressHUD eage_circleWaitShown:NO];
            [[[UIAlertView alloc] initWithTitle:@"错误" message:@"发生了未知的错误,导致您的交易失败,请及时联系客服" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil] show];
        }];
}

#pragma mark - Getter

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = ({
            UITableView *tableView    = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64.f) style:UITableViewStylePlain];
            tableView.tableHeaderView = self.tableViewHeaderView;
            tableView.tableFooterView = [[UIView alloc] init];
            tableView.delegate        = self;
            tableView.dataSource      = self;
            [tableView registerNib:[UINib nibWithNibName:@"LYGetCoinTableViewCell" bundle:nil] forCellReuseIdentifier:LYGetCoinTableViewCellIdentity];
            [self.view addSubview:tableView];
            tableView;
        });
    }
    return _tableView;
}

- (LYGetCoinHeaderView *)tableViewHeaderView {
    if (!_tableViewHeaderView) {
        _tableViewHeaderView = ({
            LYGetCoinHeaderView *view = [[[NSBundle mainBundle] loadNibNamed:@"LYGetCoinHeaderView" owner:self options:nil] objectAtIndex:0];
            view.frame                = CGRectMake(0, 0, SCREEN_WIDTH, 100.f);
            view.accountAmount        = self.accountAmount;
            view;
        });
    }
    return _tableViewHeaderView;
}

- (UIActionSheet *)payActionSheet {
    if (!_payActionSheet) {
        _payActionSheet = ({
            UIActionSheet *actionSheet = nil;
//            if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"ShowGetCoinKey"] boolValue]) {
                actionSheet = [[UIActionSheet alloc] initWithTitle:@"获取金币" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"支付宝", @"微信", nil];
//            } else {
//                actionSheet = [[UIActionSheet alloc] initWithTitle:@"获取金币" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"苹果内购", nil];
//            }
            actionSheet;
        });
    }
    return _payActionSheet;
}


@end
