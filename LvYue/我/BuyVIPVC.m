//
//  BuyVIPVC.m
//  LvYue
//
//  Created by X@Han on 16/12/27.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "BuyVIPVC.h"
#import "goodOfVIPVC.h"
#import "MBProgressHUD+NJ.h"
#import "LYHttpPoster.h"

#import "WXApi.h"
#import "AFNetworking.h"
#import "APAuthV2Info.h"
//苹果内购
#import "ConstPriceEnum.h"
#import <StoreKit/StoreKit.h>

#import "VipModel.h"
#import "WXModel.h"
#import "Order.h"
#import "DataSigner.h"
#import "LYUserService.h"

@interface BuyVIPVC ()<UITableViewDelegate,UITableViewDataSource,SKPaymentTransactionObserver,SKProductsRequestDelegate>{
    NSArray *monthArr;
    UITableView *table;
    UIButton *lastTimeBtn;   //选择vip时间的按钮
    UIButton *lastTypeBtn;    //选择支付类型的vip
    enum WXScene _scene;
    NSString *Token;
    long token_time;
    
    //内购参数
    NSString *_selectProductID; //已选的商品ID
    
    NSMutableArray *moneArr;
}

@property (nonatomic,strong) NSString *selectMonth;//记录我点击了几月
@property (nonatomic,strong) NSString *totalPrice;//记录我要花多少钱
@property (nonatomic,strong) NSString *sale;
@property(nonatomic,retain)NSMutableArray *typeArr;
@property (nonatomic,strong) NSString *payType;//支付方式,2支付宝，3微信  1苹果内购
@property (nonatomic,strong) VipModel *vipModel;
@property (nonatomic,strong) WXModel *wxModel;


@end

@implementation BuyVIPVC


- (instancetype)init
{
    if (self = [super init]) {
        _scene = WXSceneSession;
    }
    token_time = 0;
    return self;
}


- (NSMutableArray *)typeArr{
    if (!_typeArr) {
        _typeArr =[[NSMutableArray alloc]init];
    }
    return _typeArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    moneArr = [[NSMutableArray alloc]init];
    self.sale = @"0";
//    NSInteger pr = [self.vip_price integerValue];
//    self.totalPrice = [NSString stringWithFormat:@"%ld",pr * 3];
    //默认苹果内购(1)
    self.payType = @"1";
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    _selectProductID = CONSTPRICE_VIP_3;
    
   // [self getPayType];
    
    [self setNav];
    
    [self getCoinNum];
  
}

- (void)dealloc{
    
    [[SKPaymentQueue defaultQueue]removeTransactionObserver:self];
}


//金币个数
- (void)getCoinNum{
    
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/getMyIndex",REQUESTHEADER] andParameter:@{@"userId":@"1000006"} success:^(id successResponse) {
        
        NSDictionary *userDic = successResponse[@"data"][@"userInfo"];
        NSString *mone = userDic[@"userGold"];
        [moneArr addObject:mone];
        [self getPayType];
    } andFailure:^(id failureResponse) {
        
    }];
    
    
}

- (void)getPayType{
   
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/order/getIsPay",REQUESTHEADER]andParameter:nil success:^(id successResponse) {
       NSString  *type = successResponse[@"data"];
       [self.typeArr addObject:type];
        [self setContent];
    } andFailure:^(id failureResponse) {
        
    }];
    
    
    
}

#pragma mark   -------配置导航栏
- (void)setNav{
    self.title = @"购买VIP";
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:@"#ffffff"];
    //导航栏title的颜色
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithHexString:@"#424242"],UITextAttributeTextColor, [UIFont fontWithName:@"PingFangSC-Medium" size:18],UITextAttributeFont, nil]];
    
    //导航栏返回按钮
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(16, 38, 28, 14)];
    [button setTitleColor:[UIColor colorWithHexString:@"#424242"] forState:UIControlStateNormal];
    [button setTitle:@"返回" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = back;
    
    
    UIButton *edit = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-16-28, 38, 56, 14)];
    [edit setTitleColor:[UIColor colorWithHexString:@"#ff5252"] forState:UIControlStateNormal];
    [edit setTitle:@"查看特权" forState:UIControlStateNormal];
    edit.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [edit addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *edited = [[UIBarButtonItem alloc]initWithCustomView:edit];
    self.navigationItem.rightBarButtonItem = edited;
    
       }

- (void)setContent{
    
    monthArr = @[@"3个月",@"6个月",@"12个月"];
    table = [[UITableView alloc] initWithFrame:CGRectMake(0, 16, SCREEN_WIDTH, SCREEN_HEIGHT-16-64) style:UITableViewStylePlain];
    table.delegate = self;
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    table.dataSource = self;
    table.rowHeight = 48;
    [self.view addSubview:table];
    
    UIButton *buyBtn = [[UIButton alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-160)/2, 260, 160, 40)];
   // buyBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [buyBtn setTitle:@"确定支付" forState:UIControlStateNormal];
    buyBtn.layer.cornerRadius = 20;
    buyBtn.clipsToBounds = YES;
    buyBtn.backgroundColor = [UIColor colorWithHexString:@"#ff5252"];
    buyBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    buyBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [buyBtn setTitleColor:[UIColor colorWithHexString:@"#ffffff"] forState:UIControlStateNormal];
    [self.view addSubview:buyBtn];
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-80-[buyBtn]-80-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(buyBtn)]];
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-300-[buyBtn(==40)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(buyBtn)]];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
   // return 2;
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    if (section == 0) {
//        return 3;
//    }else {
//        return 4;
//    }
    
    return 3;
    
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    if (section==0) {
//        return 0;
//    }else{
//        return 32;
//    }
//}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section==1) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 32)];
        UILabel *moneyLabel = [[UILabel alloc]initWithFrame:CGRectMake(16, 8, 56, 14)];
        moneyLabel.textColor = [UIColor colorWithHexString:@"#424242"];
        moneyLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        moneyLabel.text = @"支付方式";
        [view addSubview:moneyLabel];
        return view;
        
    }else{
        return nil;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    
    if (indexPath.section==0) {
        cell.textLabel.text = monthArr[indexPath.row];
        cell.textLabel.textColor = [UIColor colorWithHexString:@"#424242"];
        cell.textLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    }
    if (indexPath.section==0&&indexPath.row==0) {
        UILabel *moneyLabel = [[UILabel alloc]init];
        moneyLabel.translatesAutoresizingMaskIntoConstraints = NO;
        moneyLabel.textColor = [UIColor colorWithHexString:@"#ff5252"];
        moneyLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        moneyLabel.text = @"¥60";
        [cell addSubview:moneyLabel];
        [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[moneyLabel(==26)]-48-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(moneyLabel)]];
        [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-16-[moneyLabel(==14)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(moneyLabel)]];
        
        UIButton *YiBtn = [[UIButton alloc]init];
        
        YiBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [YiBtn setBackgroundImage:[UIImage imageNamed:@"select_off"] forState:UIControlStateNormal];
        [YiBtn setBackgroundImage:[UIImage imageNamed:@"select_on"] forState:UIControlStateSelected];
        [YiBtn addTarget:self action:@selector(changeTime:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:YiBtn];
        [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[YiBtn(==24)]-16-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(YiBtn)]];
        [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-12-[YiBtn(==24)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(YiBtn)]];
        
    }
    
    if (indexPath.section==0&&indexPath.row==1) {
        UILabel *moneyLabel = [[UILabel alloc]init];
        moneyLabel.translatesAutoresizingMaskIntoConstraints = NO;
        moneyLabel.textColor = [UIColor colorWithHexString:@"#ff5252"];
        moneyLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        moneyLabel.text = @"¥120";
        [cell addSubview:moneyLabel];
        [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[moneyLabel(==32)]-48-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(moneyLabel)]];
        [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-16-[moneyLabel(==14)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(moneyLabel)]];
        
        UIButton *YiBtn = [[UIButton alloc]init];
        YiBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [YiBtn setBackgroundImage:[UIImage imageNamed:@"select_off"] forState:UIControlStateNormal];
         [YiBtn setBackgroundImage:[UIImage imageNamed:@"select_on"] forState:UIControlStateSelected];
         [YiBtn addTarget:self action:@selector(changeTime:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:YiBtn];
        [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[YiBtn(==24)]-16-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(YiBtn)]];
        [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-12-[YiBtn(==24)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(YiBtn)]];
        
    }
    
    if (indexPath.section==0&&indexPath.row==2) {
        //优惠
        UILabel *Label = [[UILabel alloc]init];
        Label.translatesAutoresizingMaskIntoConstraints = NO;
        Label.backgroundColor = [UIColor colorWithHexString:@"#ff5252"];
        Label.layer.cornerRadius = 2;
        Label.clipsToBounds = YES;
        Label.textColor = [UIColor colorWithHexString:@"#ffffff"];
        Label.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
        Label.text = @"优惠";
        Label.textAlignment = NSTextAlignmentCenter;
        [cell addSubview:Label];
        [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[Label(==40)]-88-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(Label)]];
        [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-14-[Label(==20)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(Label)]];
        
        
        UILabel *moneyLabel = [[UILabel alloc]init];
        moneyLabel.translatesAutoresizingMaskIntoConstraints = NO;
        moneyLabel.textColor = [UIColor colorWithHexString:@"#ff5252"];
        moneyLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        moneyLabel.text = @"¥200";
        [cell addSubview:moneyLabel];
        [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[moneyLabel(==34)]-48-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(moneyLabel)]];
        [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-16-[moneyLabel(==14)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(moneyLabel)]];
        
        UIButton *YiBtn = [[UIButton alloc]init];
        YiBtn.translatesAutoresizingMaskIntoConstraints = NO;
         [YiBtn addTarget:self action:@selector(changeTime:) forControlEvents:UIControlEventTouchUpInside];
        [YiBtn setBackgroundImage:[UIImage imageNamed:@"select_off"] forState:UIControlStateNormal];
        [YiBtn setBackgroundImage:[UIImage imageNamed:@"select_on"] forState:UIControlStateSelected];
        [cell addSubview:YiBtn];
        [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[YiBtn(==24)]-16-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(YiBtn)]];
        [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-12-[YiBtn(==24)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(YiBtn)]];
        
    }
    
//    if (indexPath.section==1&&indexPath.row==0) {
//        
//        UIImageView *image = [[UIImageView alloc]initWithFrame:CGRectMake(16, 12, 24, 24)];
//        image.image = [UIImage imageNamed:@"pay_itunes"];
//        image.layer.cornerRadius = 12;
//        image.clipsToBounds = YES;
//        [cell addSubview:image];
//       
//            UILabel *moneyLabel = [[UILabel alloc]initWithFrame:CGRectMake(56, 16, 56, 14)];
//            moneyLabel.textColor = [UIColor colorWithHexString:@"#424242"];
//            moneyLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
//            moneyLabel.text = @"苹果内购";
//            [cell addSubview:moneyLabel];
//        
//            
//            UIButton *YiBtn = [[UIButton alloc]init];
//           YiBtn.tag = 1000;
//            YiBtn.translatesAutoresizingMaskIntoConstraints = NO;
//            [YiBtn setBackgroundImage:[UIImage imageNamed:@"select_off"] forState:UIControlStateNormal];
//           [YiBtn setBackgroundImage:[UIImage imageNamed:@"select_on"] forState:UIControlStateSelected];
//          [YiBtn addTarget:self action:@selector(changeType:) forControlEvents:UIControlEventTouchUpInside];
//            [cell addSubview:YiBtn];
//            [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[YiBtn(==24)]-16-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(YiBtn)]];
//            [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-12-[YiBtn(==24)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(YiBtn)]];
//            
//    }
//    
//    if (indexPath.section==1&&indexPath.row==1) {
//        
//       
//        
//        UIImageView *image = [[UIImageView alloc]initWithFrame:CGRectMake(16, 12, 24, 24)];
//        image.image = [UIImage imageNamed:@"pay_alipay"];
//        image.layer.cornerRadius = 12;
//        image.clipsToBounds = YES;
//        [cell addSubview:image];
//        
//        UILabel *moneyLabel = [[UILabel alloc]initWithFrame:CGRectMake(56, 16, 70, 14)];
//        moneyLabel.textColor = [UIColor colorWithHexString:@"#424242"];
//        moneyLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
//        moneyLabel.text = @"支付宝支付";
//        [cell addSubview:moneyLabel];
//        
//        
//        UIButton *YiBtn = [[UIButton alloc]init];
//        YiBtn.tag = 1001;
//        YiBtn.translatesAutoresizingMaskIntoConstraints = NO;
//        [YiBtn setBackgroundImage:[UIImage imageNamed:@"select_off"] forState:UIControlStateNormal];
//        [YiBtn setBackgroundImage:[UIImage imageNamed:@"select_on"] forState:UIControlStateSelected];
//        [YiBtn addTarget:self action:@selector(changeType:) forControlEvents:UIControlEventTouchUpInside];
//        [cell addSubview:YiBtn];
//        [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[YiBtn(==24)]-16-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(YiBtn)]];
//        [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-12-[YiBtn(==24)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(YiBtn)]];
//       
////        if ([[NSString stringWithFormat:@"%@",self.typeArr[0]] isEqualToString:@"0"]) {
////            cell.hidden = YES;
////        }
////        
////        if ([[NSString stringWithFormat:@"%@",self.typeArr[0]] isEqualToString:@"1"]) {
////            cell.hidden = NO;
////        }
//    }
//    
//    if (indexPath.section==1&&indexPath.row==2) {
//        
//        UIImageView *image = [[UIImageView alloc]initWithFrame:CGRectMake(16, 12, 24, 24)];
//        image.image = [UIImage imageNamed:@"pay_wechat"];
//        image.layer.cornerRadius = 12;
//        image.clipsToBounds = YES;
//        [cell addSubview:image];
//        
//        UILabel *moneyLabel = [[UILabel alloc]initWithFrame:CGRectMake(56, 16, 56, 14)];
//        moneyLabel.textColor = [UIColor colorWithHexString:@"#424242"];
//        moneyLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
//        moneyLabel.text = @"微信支付";
//        [cell addSubview:moneyLabel];
//        
//        
//        UIButton *YiBtn = [[UIButton alloc]init];
//        YiBtn.tag = 1002;
//        YiBtn.translatesAutoresizingMaskIntoConstraints = NO;
//        [YiBtn setBackgroundImage:[UIImage imageNamed:@"select_off"] forState:UIControlStateNormal];
//        [YiBtn setBackgroundImage:[UIImage imageNamed:@"select_on"] forState:UIControlStateSelected];
//        [YiBtn addTarget:self action:@selector(changeType:) forControlEvents:UIControlEventTouchUpInside];
//        [cell addSubview:YiBtn];
//        [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[YiBtn(==24)]-16-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(YiBtn)]];
//        [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-12-[YiBtn(==24)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(YiBtn)]];
 //      ************************************获得支付方式----------------------------------------------
//        if ([[NSString stringWithFormat:@"%@",self.typeArr[0]] isEqualToString:@"0"]) {
//            cell.hidden = YES;
//        }
//        
//        if ([[NSString stringWithFormat:@"%@",self.typeArr[0]] isEqualToString:@"1"]) {
//            cell.hidden = NO;
//        }
       // }
    
    
//    if (indexPath.section==1&&indexPath.row==3) {
//        
//        UIImageView *image = [[UIImageView alloc]initWithFrame:CGRectMake(16, 12, 24, 24)];
//        image.image = [UIImage imageNamed:@"m_money"];
//        image.layer.cornerRadius = 12;
//        image.clipsToBounds = YES;
//        [cell addSubview:image];
//        
//        UILabel *moneyLabel = [[UILabel alloc]initWithFrame:CGRectMake(56, 16, 56, 14)];
//        moneyLabel.textColor = [UIColor colorWithHexString:@"#424242"];
//        moneyLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
//        moneyLabel.text = @"金币购买";
//        [cell addSubview:moneyLabel];
//        
//        
//        UIButton *YiBtn = [[UIButton alloc]init];
//        YiBtn.tag = 1003;
//        YiBtn.translatesAutoresizingMaskIntoConstraints = NO;
//        [YiBtn setBackgroundImage:[UIImage imageNamed:@"select_off"] forState:UIControlStateNormal];
//        [YiBtn setBackgroundImage:[UIImage imageNamed:@"select_on"] forState:UIControlStateSelected];
//        [YiBtn addTarget:self action:@selector(changeType:) forControlEvents:UIControlEventTouchUpInside];
//        [cell addSubview:YiBtn];
//        [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[YiBtn(==24)]-16-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(YiBtn)]];
//        [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-12-[YiBtn(==24)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(YiBtn)]];
    
        //        if ([[NSString stringWithFormat:@"%@",self.typeArr[0]] isEqualToString:@"0"]) {
        //            cell.hidden = YES;
        //        }
        //
        //        if ([[NSString stringWithFormat:@"%@",self.typeArr[0]] isEqualToString:@"1"]) {
        //            cell.hidden = NO;
        //        }
   // }
    
    
    
    return cell;
}


#pragma mark   ---选择成为vip时间
- (void)changeTime:(UIButton *)sender{
    if (lastTimeBtn == sender) {
        return;
    }
    sender.selected = YES;
    lastTimeBtn.selected = NO;
    lastTimeBtn = sender;

    
}


//#pragma mark  ---选择购买vip类型
//- (void)changeType:(UIButton *)sender{
//    if (lastTypeBtn == sender) {
//        return;
//    }
//    sender.selected = YES;
//    lastTypeBtn.selected = NO;
//    lastTypeBtn = sender;
//    
//    if (sender.tag == 1003) {
//      //金币开通会员
//        if (self.coinNum.integerValue < 30) {
//            [MBProgressHUD showError:@"您的金币不足,请换种充值方式"];
//            return;
//        }
//        NSString *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userId"];
//        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/order/updateOrderGold",REQUESTHEADER] andParameter:@{@"userId":userId,@"vipLength":@"1",@"goldPrice":@"30",@"usedType":@"vip"} success:^(id successResponse) {
//            
//            //NSLog(@"金币开通会员:%@",successResponse[@"errorMsg"]);
//           [MBProgressHUD showSuccess:@"购买会员成功"];
//            
//        } andFailure:^(id failureResponse) {
//            
//        }];
//       
//    }
//    
//}

#pragma mark   -----查看VIP特权
- (void)save{
    goodOfVIPVC *good = [[goodOfVIPVC alloc]init];
    [self.navigationController pushViewController:good animated:YES];
    
    
    
}

//返回
- (void)back{
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark  ---苹果内购
- (void)appleBuy{
    if ([SKPaymentQueue canMakePayments]) {
        [self requestProductPayment:_selectProductID];
    } else {
        [[[UIAlertView alloc] initWithTitle:nil message:@"发起购买失败,您已禁止应用内付费购买" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil] show];
    }
    
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
    
//    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/buyAppleVip",REQUESTHEADER] andParameter:@{@"user_id":@"1000006",@"amount":selectTime,@"detail":[NSString stringWithFormat:@"用户%@通过苹果内购流程成功购买了%@的会员权限",[LYUserService sharedInstance].userID,_selectMonth]} success:^(id successResponse) {
//        MLOG(@"%@",successResponse);
//        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
//            [EageProgressHUD eage_circleWaitShown:NO];
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMyInfomation" object:nil];
//        } else {
//            MLOG(@"信息:%@",successResponse[@"msg"]);
//            [EageProgressHUD eage_circleWaitShown:NO];
//            [[[UIAlertView alloc] initWithTitle:@"错误" message:@"发生了未知的错误,导致您的交易失败,请及时联系客服" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil] show];
//        }
//    } andFailure:^(id failureResponse) {
//        MLOG(@"%@",failureResponse);
//        [EageProgressHUD eage_circleWaitShown:NO];
//        [[[UIAlertView alloc] initWithTitle:@"错误" message:@"发生了未知的错误,导致您的交易失败,请及时联系客服" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil] show];
//    }];
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






- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
