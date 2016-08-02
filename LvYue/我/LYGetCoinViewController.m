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
#import <AlipaySDK/AlipaySDK.h>

typedef NS_ENUM(NSUInteger, LYGetCoinPayType) {
    LYGetCoinPayTypeAlipay = 0,
    LYGetCoinPayTypeWeixin = 1,
    LYGetCoinPayTypeApple  = 2
};

static NSString *const LYGetCoinTableViewCellIdentity = @"LYGetCoinTableViewCellIdentity";
static NSArray *LYGetCoinGetTableViewDataArray;

@interface LYGetCoinViewController () <
    UITableViewDelegate,
    UITableViewDataSource,
    UIActionSheetDelegate,
    WXApiDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) LYGetCoinHeaderView *tableViewHeaderView;
@property (nonatomic, strong) UIActionSheet *payActionSheet;

@end

@implementation LYGetCoinViewController

+ (void)initialize {
    LYGetCoinGetTableViewDataArray = @[
        @{
            @"coinNum": @1500
        },
        @{
            @"coinNum": @3000
        },
        @{
            @"coinNum": @6000
        },
        @{
            @"coinNum": @10800
        },
        @{
            @"coinNum": @21800
        }
    ];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"WeXinPayResponse" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"获取金币";

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_completePay:) name:@"WeXinPayResponse" object:nil];

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
    // 把选中的金额通过 tag 传过去
    self.payActionSheet.tag = [LYGetCoinGetTableViewDataArray[indexPath.row][@"coinNum"] integerValue];
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
    [self.payActionSheet showInView:self.view];

    // 支付宝 微信支付
    if (buttonIndex == 0 || buttonIndex == 1) {
        [self buy:buttonIndex coinNum:actionSheet.tag];
    }
}

#pragma mark - Pravite

- (void)buy:(LYGetCoinPayType)type coinNum:(NSInteger)coinNum {

    NSString *channel;
    NSNumber *payCoinNum = @(coinNum / 100);

    switch (type) {
        case LYGetCoinPayTypeAlipay: {
            channel = @"0";
            break;
        }
        case LYGetCoinPayTypeWeixin: {
            channel = @"1";
            break;
        }
        case LYGetCoinPayTypeApple: {

            break;
        }
    }

    [MBProgressHUD showMessage:nil toView:self.view];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/buyHongdou", REQUESTHEADER]
        andParameter:@{
            @"buyer": [LYUserService sharedInstance].userID,
            @"content": @"购买金币",
            @"amount": payCoinNum,
            @"createIp": @"128.0.0.1",
            @"channel": channel
        }
        success:^(id successResponse) {
            MLOG(@"结果:%@", successResponse);
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
                switch (type) {
                    case LYGetCoinPayTypeAlipay: {
                        [self aliPay:[[VipModel alloc] initWithDict:successResponse[@"data"][@"pay"]]]; //支付宝支付
                        break;
                    }
                    case LYGetCoinPayTypeWeixin: {
                        [self wxPay:[[WXModel alloc] initWithDict:successResponse[@"data"][@"pay"]]]; //微信支付
                        break;
                    }
                    case LYGetCoinPayTypeApple: {

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

- (void)aliPay:(VipModel *)vipModel {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    /*============================================================================
     =======================需要填写商户app申请的===================================
     ============================================================================*/
    NSString *partner    = vipModel.partner;
    NSString *seller     = vipModel.seller_id;
    NSString *privateKey = vipModel.rsa_key;

    //    partner和seller获取失败,提示
    if ([partner length] == 0 ||
        [seller length] == 0 ||
        [privateKey length] == 0) {
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
    Order *order             = [[Order alloc] init];
    order.partner            = partner;
    order.seller             = seller;
    order.tradeNO            = vipModel.out_trade_no; //订单ID（由商家自行制定）
    order.productName        = vipModel.subject;      //商品标题
    order.productDescription = vipModel.body;         //商品描述
    order.amount             = vipModel.total_fee;    //商品价格
    order.notifyURL          = vipModel.notify_url;   //回调URL

    order.service      = @"mobile.securitypay.pay";
    order.paymentType  = @"1";
    order.inputCharset = @"utf-8";
    order.itBPay       = vipModel.it_b_pay;
    order.showUrl      = @"m.alipay.com";

    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
    NSString *appScheme = @"LvYue";

    //将商品信息拼接成字符串
    NSString *orderSpec = [order description];
    NSLog(@"orderSpec = %@", orderSpec);

    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    id<DataSigner> signer  = CreateRSADataSigner(privateKey);
    NSString *signedString = [signer signString:orderSpec];

    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                                                 orderSpec, signedString, @"RSA"];

        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            NSLog(@"reslut = %@", resultDic);
            if ([resultDic[@"resultStatus"] integerValue] == 9000) {
                [MBProgressHUD showSuccess:@"购买成功"];
                [self p_completePay:nil];
            } else {
                [MBProgressHUD showError:@"购买失败"];
            }
        }];
    }
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

- (void)p_completePay:(NSNotification *)obj {

    if (obj) {
        if (![obj.object boolValue]) {
            [MBProgressHUD showError:@"充值失败"];
            return;
        }
    }

    [EageProgressHUD eage_circleWaitShown:YES];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/buyHDFinish", REQUESTHEADER]
        andParameter:@{
            @"user_id": [LYUserService sharedInstance].userID,
            @"num": @(self.payActionSheet.tag)
        }
        success:^(id successResponse) {
            if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
                [EageProgressHUD eage_circleWaitShown:NO];
                // 更新账户余额
                self.tableViewHeaderView.accountAmount += self.payActionSheet.tag;
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
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"获取金币" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"支付宝", @"微信", nil];
            actionSheet;
        });
    }
    return _payActionSheet;
}


@end
