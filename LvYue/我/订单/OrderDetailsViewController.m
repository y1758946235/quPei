//
//  OrderDetailsViewController.m
//  豆客项目
//
//  Created by Xia Wei on 15/10/13.
//  Copyright © 2015年 Xia Wei. All rights reserved.
//

#import "OrderDetailsViewController.h"
#import "OrderDetailFirstTableViewCell.h"
#import "OrderDetailsFourthTableViewCell.h"
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "MBProgressHUD+NJ.h"
#import "VipModel.h"
#import "Order.h"
#import <AlipaySDK/AlipaySDK.h>
#import "DataSigner.h"
#import "LYUserService.h"
#import "DetailDataViewController.h"
#import "ChatViewController.h"
#import "WXModel.h"

@interface OrderDetailsViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,UIActionSheetDelegate>{
    NSString *_touristName;
    NSString *_guideName;
    NSString *_startTime;
    NSString *_endTime;
    NSString *_orderNumber;
    NSString *_payNumber;
    NSString *_dealTime;
    NSString *_channel;
    int serviceEvaluation;//服务评价等级
}

@property(nonatomic,strong)NSMutableArray *starsArr;
@property(nonatomic,strong)UIView *modalView;
@property(nonatomic,strong)UIView *alertView;
@property(nonatomic,strong)VipModel *vipModel;
@property(nonatomic,strong)UIButton *affirmBtn;//确认服务按钮
@property(nonatomic,strong)UIButton *applyForRefund;//申请退款按钮
@property(nonatomic,strong)UIButton *cancelModalBtn;
@property(nonatomic,strong)UIView *refundV;//填写退单理由的视图
@property(nonatomic,strong)NSString *refundReason;
@property(nonatomic,strong)UIButton *cantTouchBtn;//创建一个label使评价星星不能被点击

@property (nonatomic,strong) NSString *payType;
@property (nonatomic,strong) WXModel *wxModel;

@end

@implementation OrderDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationBar];
    [self tableViewCreated];
    [self modalViewCreated];
    [self cancelModalViewCreated];
    //未评价服务状态
    serviceEvaluation = 0;
    
    self.payType = @"0";
    
    //管理评价星星按钮的数组
    _starsArr = [[NSMutableArray alloc]init];
    
    _cantTouchBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 343, VIEW_WIDTH, 50)];
    [_cantTouchBtn setBackgroundColor:[UIColor clearColor]];
    _cantTouchBtn.hidden = NO;
    [self.view addSubview:_cantTouchBtn];
    //添加数据接口
    _touristName = self.model.buyer_name;
    _guideName = self.model.seller_name;
    _startTime = self.model.begin_time;
    _endTime = self.model.end_time;
    _orderNumber = self.model.order_no;
    _payNumber = self.model.out_order_no;
    _dealTime = self.model.update_time;
    _channel = self.model.channel;
}

- (void)setNavigationBar{
    //设置标题，把标题设置成全局是为了点击按钮时方便标题的改变
    UILabel *titleView = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 50)];
    titleView.text = @"订单详情";
    titleView.textColor = [UIColor whiteColor];
    titleView.textAlignment = NSTextAlignmentCenter;
    titleView.font = [UIFont systemFontOfSize:16];
    self.navigationItem.titleView = titleView;
    
    //设置左边的返回按钮
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [leftBtn setFrame:CGRectMake(0, 0, 16, 22)];
    UIImageView *imageV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, leftBtn.frame.size.width, leftBtn.frame.size.height)];
    imageV.image = [UIImage imageNamed:@"back"];
    [leftBtn addTarget:self action:@selector(backToFront) forControlEvents:UIControlEventTouchUpInside];
    [leftBtn addSubview:imageV];
    UIBarButtonItem *left = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = left;
    
    self.tabBarController.tabBar.hidden = YES;
}

#pragma mark 未评价弹出的模态视图
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
    textLabel.text = @"您未对服务进行评价,不能确认服务";
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

#pragma mark 取消订单弹出的模态视图
//创建一个模态视图
- (void)cancelModalViewCreated{
    //创建黑色背景
    _cancelModalBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight)];
    [_cancelModalBtn setBackgroundColor:[UIColor blackColor]];
    [_cancelModalBtn addTarget:self action:@selector(cancelModalViewHidden) forControlEvents:UIControlEventTouchUpInside];
    _cancelModalBtn.alpha = 0;
    [self.view addSubview:_cancelModalBtn];
    
     UILabel *textLabel = [[UILabel alloc]init];
    UITextView *refundTextView = [[UITextView alloc]init];
    float btnHeight;
    //创建输入退款理由的view
    if (VIEW_HEIGHT > 600) {
         _refundV = [[UIView alloc]initWithFrame:CGRectMake(15, 100 / 667.0 * VIEW_HEIGHT, kMainScreenWidth - 30,270 / 667.0 * VIEW_HEIGHT)];
        [textLabel setFrame:CGRectMake(0, 0,_refundV.frame.size.width, 40 / 667.0 * VIEW_HEIGHT)];
        [refundTextView setFrame:CGRectMake(0,CGRectGetMaxY(textLabel.frame), _refundV.frame.size.width,180 / 667.0 * VIEW_HEIGHT)];
       btnHeight  = 50  / 667.0 * VIEW_HEIGHT;//设置下方确认取消按钮的高度

    }
    else if (VIEW_HEIGHT < 500){
        _refundV = [[UIView alloc]initWithFrame:CGRectMake(15, 100 / 667.0 * VIEW_HEIGHT, kMainScreenWidth - 30,270 / 667.0 * VIEW_HEIGHT - 50)];
        [textLabel setFrame:CGRectMake(0, 0,_refundV.frame.size.width, 40 / 667.0 * VIEW_HEIGHT - 10)];
        [refundTextView setFrame:CGRectMake(0,CGRectGetMaxY(textLabel.frame), _refundV.frame.size.width,180 / 667.0 * VIEW_HEIGHT - 30)];
        btnHeight = 50  / 667.0 * VIEW_HEIGHT - 10;//设置下方确认取消按钮的高度

    }
    else{
        _refundV = [[UIView alloc]initWithFrame:CGRectMake(15, 100 / 667.0 * VIEW_HEIGHT, kMainScreenWidth - 30,270 / 667.0 * VIEW_HEIGHT - 30)];
        [textLabel setFrame:CGRectMake(0, 0,_refundV.frame.size.width, 40 / 667.0 * VIEW_HEIGHT - 5)];
        [refundTextView setFrame:CGRectMake(0,CGRectGetMaxY(textLabel.frame), _refundV.frame.size.width,180 / 667.0 * VIEW_HEIGHT - 20)];
        btnHeight = 50  / 667.0 * VIEW_HEIGHT -5;//设置下方确认取消按钮的高度

    }
    
    //创建提示语言label
    textLabel.text = @"亲,为什么要退款啊？";
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.font = [UIFont systemFontOfSize:14];
    [textLabel setBackgroundColor:UIColorWithRGBA(250, 82, 74, 1)];
    textLabel.textColor = [UIColor whiteColor];
    [_refundV addSubview:textLabel];
    //创建输入框
    [refundTextView setBackgroundColor:[UIColor whiteColor]];
    refundTextView.font = [UIFont systemFontOfSize:14];
    [_refundV addSubview:refundTextView];
    //创建下方确认按钮
    UIButton *ackBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [ackBtn setFrame:CGRectMake(0,CGRectGetMaxY(refundTextView.frame),
                                            _refundV.frame.size.width / 2.0, btnHeight)];
    [ackBtn setTitle:@"确定" forState:UIControlStateNormal];
    [ackBtn.layer setBorderColor:UIColorWithRGBA(234, 234, 234, 1).CGColor];
    [ackBtn.layer setBorderWidth:1];
    [ackBtn addTarget:self action:@selector(refundOrderAction) forControlEvents:UIControlEventTouchUpInside];
    [ackBtn setBackgroundColor:UIColorWithRGBA(250, 82, 74, 1)];
    [ackBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_refundV addSubview:ackBtn];
    
    //创建下方取消按钮
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [cancelBtn setFrame:CGRectMake(_refundV.frame.size.width / 2.0,CGRectGetMaxY(refundTextView.frame),
                                _refundV.frame.size.width / 2.0, btnHeight)];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn.layer setBorderColor:UIColorWithRGBA(234, 234, 234, 1).CGColor];
    [cancelBtn.layer setBorderWidth:1];
    [cancelBtn setBackgroundColor:UIColorWithRGBA(250, 82, 74, 1)];
    [cancelBtn addTarget:self action:@selector(cancelModalViewHidden)
                                                forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_refundV addSubview:cancelBtn];
    
    _refundV.hidden = YES;
    [self.view addSubview:_refundV];
    [self.view bringSubviewToFront:_refundV];
}

//确定取消订单事件
- (void)refundOrderAction{
    [MBProgressHUD showMessage:nil];
    for (UIView *view in [_refundV subviews]) {
        if ([view isKindOfClass:[UITextView class]]) {
            UITextView *textView = (UITextView *)view;
            [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/order/orderRefund",REQUESTHEADER] andParameter:@{@"refundReason":textView.text,@"orderId":self.model.orderId} success:^(id successResponse) {
                MLOG(@"结果:%@",successResponse);
                if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
                    [MBProgressHUD hideHUD];
                    [self.navigationController popViewControllerAnimated:YES];
                    
                } else {
                    [MBProgressHUD hideHUD];
                    [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
                }
            } andFailure:^(id failureResponse) {
                [MBProgressHUD hideHUD];
                [MBProgressHUD showError:@"服务器繁忙,请重试"];
            }];
            break;
        }
    }
}

- (void)cancelOrder{
    [UIView animateWithDuration:0.2 animations:^{
        _cancelModalBtn.alpha = 0.6;
        _refundV.hidden = NO;
    }];
}

- (void)cancelModalViewHidden{
    [UIView animateWithDuration:0.2 animations:^{
        _cancelModalBtn.alpha = 0;
        _refundV.hidden = YES;
    }];
    for (UIView *view in [_refundV subviews]) {
        if ([view isKindOfClass:[UITextView class]]) {
            UITextView *textView = (UITextView *)view;
            [textView resignFirstResponder];
            break;
        }
    }
}

- (void)backToFront{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)tableViewCreated{
    UITableView *tableV = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight)];
    tableV.delegate = self;
    tableV.dataSource = self;
    tableV.showsVerticalScrollIndicator = NO;
    tableV.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableV setBackgroundColor:UIColorWithRGBA(234, 234, 234, 1)];
    [self.view addSubview:tableV];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return 65;
    }
    else if (indexPath.row == 3){
        return 130;
    }
    else if (indexPath.row == 4){
        return 10;
    }
    else if (indexPath.row == 7){
        return 50;
    }
    else if (indexPath.row == 8){
        return 100;
    }
    else if (indexPath.row == 9){
        return 100;
    }
    else
        return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        NSArray *nibArr = [[NSBundle mainBundle]loadNibNamed:@"OrderDetailFirstTableViewCell" owner:nil options:nil];
        OrderDetailFirstTableViewCell *cell = [nibArr lastObject];
        [cell fillData:self.model.amount andTrade:self.model.status];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if(indexPath.row == 1){
        UITableViewCell *cell = [[UITableViewCell alloc]init];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.imageView.image = [UIImage imageNamed:@"拍"];
        if([[NSString stringWithFormat:@"%@",self.model.buyer]
            isEqualToString:[NSString stringWithFormat:@"%@",[LYUserService sharedInstance].userID]]){//如果用户是买家
            NSString *str = [NSString stringWithFormat:@"消费者: %@",_touristName];
            cell.textLabel.text = str;
        }
        else{//如果用户是向导
            NSString *str = [NSString stringWithFormat:@"服务者: %@",_guideName];
            cell.textLabel.text = str;
        }
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        UIView *separaLine = [[UIView alloc]initWithFrame:CGRectMake(0,43,kMainScreenWidth, 1)];
        [separaLine setBackgroundColor:UIColorWithRGBA(234, 234, 234, 1)];
        [cell addSubview:separaLine];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if(indexPath.row == 2){
        UITableViewCell *cell = [[UITableViewCell alloc]init];
        cell.imageView.image = [UIImage imageNamed:@"拍"];
        NSString *tempeStartTime = [_startTime substringWithRange:NSMakeRange(0, [_startTime length] - 9)];
        NSString *tempEndTime = [_endTime substringWithRange:NSMakeRange(0, [_endTime length] - 9)];
        NSString *str = [NSString stringWithFormat:@"预约时间:  %@  至  %@",tempeStartTime,tempEndTime];
        cell.textLabel.text = str;
        cell.textLabel.font = [UIFont systemFontOfSize:14.0];
        UIView *separaLine = [[UIView alloc]initWithFrame:CGRectMake(0,43,kMainScreenWidth, 1)];
        [separaLine setBackgroundColor:UIColorWithRGBA(234, 234, 234, 1)];
        [cell addSubview:separaLine];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if (indexPath.row == 3){
        OrderDetailsFourthTableViewCell *cell = [[OrderDetailsFourthTableViewCell alloc]initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 10)];
        [cell fillDataWithData:self.model.content];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if (indexPath.row == 4){
        UITableViewCell *cell = [[UITableViewCell alloc]init];
        [cell setBackgroundColor:UIColorWithRGBA(234, 234, 234, 1)];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if (indexPath.row == 5){
        UITableViewCell *cell = [[UITableViewCell alloc]init];
        cell.imageView.image = [UIImage imageNamed:@"拍"];
        cell.textLabel.text = @"服务评价:";
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        UIView *separaLine = [[UIView alloc]initWithFrame:CGRectMake(0,43,kMainScreenWidth, 1)];
        [separaLine setBackgroundColor:UIColorWithRGBA(234, 234, 234, 1)];
        [cell addSubview:separaLine];
        
        //创建5个星星从最右边的开始创建
        for (int i = 0; i < 5; i ++) {
            UIButton *tempBtn = [self starsCreated:kMainScreenWidth - 40 - i * 23];
            tempBtn.tag = 5 - i;
            [cell addSubview:tempBtn];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if (indexPath.row == 6){
        UITableViewCell *cell = [[UITableViewCell alloc]init];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.imageView.image = [UIImage imageNamed:@"拍"];
        if([[NSString stringWithFormat:@"%@",self.model.buyer]
            isEqualToString:[NSString stringWithFormat:@"%@",[LYUserService sharedInstance].userID]]){//如果用户是买家
            NSString *str = [NSString stringWithFormat:@"服务者: %@",_guideName];
            cell.textLabel.text = str;
        }
        else{//如果用户是向导
            NSString *str = [NSString stringWithFormat:@"消费者: %@",_touristName];
            cell.textLabel.text = str;
        }
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        
        //Cell下面的分割线
        UIView *separaLine = [[UIView alloc]initWithFrame:CGRectMake(0,43,kMainScreenWidth, 1)];
        [separaLine setBackgroundColor:UIColorWithRGBA(234, 234, 234, 1)];
       // [cell addSubview:separaLine];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if (indexPath.row == 7){
        UITableViewCell *cell = [[UITableViewCell alloc]init];
        //Button到边框的距离
        float distance = 15;
        //创建私信他按钮
        UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [leftBtn setFrame:CGRectMake(distance,0,kMainScreenWidth / 2.0 - distance - 10, 30)];
        [leftBtn.layer setBorderWidth:1];
        [leftBtn.layer setBorderColor:UIColorWithRGBA(234, 234, 234, 1).CGColor];
        UIImageView *messageImg = [[UIImageView alloc]initWithFrame:CGRectMake(30,(leftBtn.frame.size.height - 15) / 2.0, 17, 15)];
        messageImg.image = [UIImage imageNamed:@"sixin"];
        [leftBtn addSubview:messageImg];
        
        UILabel *sixin = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(messageImg.frame) + 10, 0, 60, leftBtn.frame.size.height)];
        sixin.text = @"私信他";
        sixin.font = [UIFont systemFontOfSize:12];
        [leftBtn addSubview:sixin];
        [leftBtn addTarget:self action:@selector(sxtBtnAction) forControlEvents:UIControlEventTouchUpInside];
        
        //创建拨打电话按钮
        UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [rightBtn setFrame:CGRectMake(kMainScreenWidth - distance - (kMainScreenWidth / 2.0 - distance - 10), 0,kMainScreenWidth / 2.0 - distance - 10, 30)];
        [rightBtn.layer setBorderWidth:1];
        [rightBtn.layer setBorderColor:UIColorWithRGBA(234, 234, 234, 1).CGColor];
        UIImageView *phoneImg = [[UIImageView alloc]initWithFrame:CGRectMake(30,(rightBtn.frame.size.height - 15) / 2.0, 17, 15)];
        phoneImg.image = [UIImage imageNamed:@"Phones"];
        [rightBtn addSubview:phoneImg];
        
        UILabel *phone = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(messageImg.frame) + 10, 0, 60, rightBtn.frame.size.height)];
        phone.text = @"拨打电话";
        phone.font = [UIFont systemFontOfSize:12];
        [rightBtn addSubview:phone];
        [rightBtn addTarget:self action:@selector(callHim) forControlEvents:UIControlEventTouchUpInside];
        
        [cell addSubview:leftBtn];
        [cell addSubview:rightBtn];
        
        //Cell下面的分割线
        UIView *separaLine = [[UIView alloc]initWithFrame:CGRectMake(0,49,kMainScreenWidth, 1)];
        [separaLine setBackgroundColor:UIColorWithRGBA(234, 234, 234, 1)];
        [cell addSubview:separaLine];
        
        //cell不能被点击
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if (indexPath.row == 8){
        UITableViewCell *cell = [[UITableViewCell alloc]init];
        UILabel *orderNumberLabel = [[UILabel alloc]initWithFrame:CGRectMake(15,10,67, 15)];
        orderNumberLabel.text = @"豆客订单号:";
        orderNumberLabel.font = [UIFont systemFontOfSize:12];
        orderNumberLabel.textColor = UIColorWithRGBA(137,137,137, 1);
        [cell addSubview:orderNumberLabel];
        
        UILabel *orderNumber = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(orderNumberLabel.frame), CGRectGetMinY(orderNumberLabel.frame), 200, orderNumberLabel.frame.size.height)];
        orderNumber.textColor = UIColorWithRGBA(137,137,137, 1);
        orderNumber.text = _orderNumber;
        orderNumber.font = [UIFont systemFontOfSize:12];
        [cell addSubview:orderNumber];
        
        //第二行内容
        UILabel *payNumberLabel = [[UILabel alloc]initWithFrame:CGRectMake(15,CGRectGetMaxY(orderNumber.frame) + 10,80, 15)];
        payNumberLabel.text = @"支付宝订单号:";
        if ([[NSString stringWithFormat:@"%@",_channel] isEqualToString:@"1"]) {
            payNumberLabel.text = @"微信订单号:";
        }
        payNumberLabel.font = [UIFont systemFontOfSize:12];
        payNumberLabel.textColor = UIColorWithRGBA(137,137,137, 1);
        [cell addSubview:payNumberLabel];
        
        UILabel *payNumber = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(payNumberLabel.frame), CGRectGetMinY(payNumberLabel.frame), 300, payNumberLabel.frame.size.height)];
        payNumber.textColor = UIColorWithRGBA(137,137,137, 1);
        payNumber.text = _payNumber;
        payNumber.font = [UIFont systemFontOfSize:12];
        [cell addSubview:payNumber];
        
        //第三行内容
        UILabel *dealTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(15,CGRectGetMaxY(payNumber.frame) + 10,56, 15)];
        dealTimeLabel.text = @"成交时间:";
        dealTimeLabel.font = [UIFont systemFontOfSize:12];
        dealTimeLabel.textColor = UIColorWithRGBA(137,137,137, 1);
        [cell addSubview:dealTimeLabel];
        
        UILabel *dealTime = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(dealTimeLabel.frame), CGRectGetMinY(dealTimeLabel.frame), 200, dealTimeLabel.frame.size.height)];
        dealTime.textColor = UIColorWithRGBA(137,137,137, 1);
        dealTime.text = _dealTime;
        dealTime.font = [UIFont systemFontOfSize:12];
        [cell addSubview:dealTime];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else{
        UITableViewCell *cell = [[UITableViewCell alloc]init];
        [cell setBackgroundColor:UIColorWithRGBA(0, 0, 0, 0)];
        //创建确认服务按钮
        self.affirmBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.affirmBtn setFrame:CGRectMake(15, 15, kMainScreenWidth - 30, 35)];
        if ([[NSString stringWithFormat:@"%@",self.model.status] isEqualToString:@"0"]) {
            [self.affirmBtn setTitle:@"去付款" forState:UIControlStateNormal];
            [self.affirmBtn setBackgroundColor:UIColorWithRGBA(249, 82, 74, 1)];
            [self.affirmBtn addTarget:self action:@selector(surePay) forControlEvents:UIControlEventTouchUpInside];
            //创建申请退款按钮
            self.applyForRefund = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [self.applyForRefund setFrame:CGRectMake(15,CGRectGetMaxY(self.affirmBtn.frame) + 10, kMainScreenWidth - 30, 35)];
            [self.applyForRefund setTitle:@"取消订单" forState:UIControlStateNormal];
            self.applyForRefund.titleLabel.font = [UIFont boldSystemFontOfSize:16];
            [self.applyForRefund addTarget:self action:@selector(cancelOrder) forControlEvents:UIControlEventTouchUpInside];
            [self.applyForRefund setBackgroundColor:[UIColor whiteColor]];
            [self.applyForRefund.layer setCornerRadius:2];
            [self.applyForRefund setTintColor:UIColorWithRGBA(74, 74, 74, 1)];
            [cell addSubview:self.applyForRefund];
        }
        else if ([[NSString stringWithFormat:@"%@",self.model.status] isEqualToString:@"1"]){
            _cantTouchBtn.hidden = NO;
          //  [_cantTouchBtn setBackgroundColor:[UIColor redColor]];
            [self.affirmBtn setTitle:@"取消订单" forState:UIControlStateNormal];
            [self.affirmBtn setBackgroundColor:UIColorWithRGBA(249, 82, 74, 1)];
            [self.affirmBtn addTarget:self action:@selector(cancelOrder) forControlEvents:UIControlEventTouchUpInside];
        }
        else if ([[NSString stringWithFormat:@"%@",self.model.status] isEqualToString:@"2"]){
            [self.affirmBtn setTitle:@"交易完成" forState:UIControlStateNormal];
            UIButton *btn = [[UIButton alloc]init];
            btn.tag = [self.model.evaluation integerValue];
            [self starAction:btn];
            [self.affirmBtn setBackgroundColor:UIColorWithRGBA(223,223,223, 1)];
        }
        else if ([[NSString stringWithFormat:@"%@",self.model.status] isEqualToString:@"3"]){
            [self.affirmBtn setTitle:@"退款中..." forState:UIControlStateNormal];
            [self.affirmBtn setBackgroundColor:UIColorWithRGBA(251,94,45, 1)];
            //增加下面的一行字
            UILabel *phoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(15,CGRectGetMaxY(self.affirmBtn.frame), kMainScreenWidth - 30, 35)];
            phoneLabel.text = @"如有疑问请致电0571-81622361";
            phoneLabel.textAlignment = NSTextAlignmentCenter;
            phoneLabel.font = [UIFont boldSystemFontOfSize:12];
            [phoneLabel setTextColor:UIColorWithRGBA(147, 147, 147, 147)];
            [cell addSubview:phoneLabel];
        }
        else if ([[NSString stringWithFormat:@"%@",self.model.status] isEqualToString:@"4"]){
            [self.affirmBtn setTitle:@"已退款" forState:UIControlStateNormal];
            [self.affirmBtn setBackgroundColor:UIColorWithRGBA(223,223,223, 1)];
        }
        else if ([[NSString stringWithFormat:@"%@",self.model.status] isEqualToString:@"5"]){
            [self.affirmBtn setTitle:@"支付失败" forState:UIControlStateNormal];
            [self.affirmBtn setBackgroundColor:UIColorWithRGBA(223,223,223, 1)];
        }
        else if ([[NSString stringWithFormat:@"%@",self.model.status] isEqualToString:@"6"]){
            [self.affirmBtn setTitle:@"退款中..." forState:UIControlStateNormal];
            [self.affirmBtn setBackgroundColor:UIColorWithRGBA(251,94,45, 1)];
            //增加下面的一行字
            UILabel *phoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(15,CGRectGetMaxY(self.affirmBtn.frame), kMainScreenWidth - 30, 35)];
            phoneLabel.text = @"如有疑问请致电0571-81622361";
            phoneLabel.textAlignment = NSTextAlignmentCenter;
            phoneLabel.font = [UIFont boldSystemFontOfSize:12];
            [phoneLabel setTextColor:UIColorWithRGBA(147, 147, 147, 147)];
            [cell addSubview:phoneLabel];
        }
        else{
            _cantTouchBtn.hidden = YES;
            [self.affirmBtn setTitle:@"确认服务" forState:UIControlStateNormal];
            [self.affirmBtn setBackgroundColor:UIColorWithRGBA(249, 82, 74, 1)];
            [self.affirmBtn addTarget:self action:@selector(affirmBtnAction) forControlEvents:UIControlEventTouchUpInside];
            //创建申请退款按钮
            self.applyForRefund = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [self.applyForRefund setFrame:CGRectMake(15,CGRectGetMaxY(self.affirmBtn.frame) + 10, kMainScreenWidth - 30, 35)];
            [self.applyForRefund setTitle:@"申请退款" forState:UIControlStateNormal];
            self.applyForRefund.titleLabel.font = [UIFont boldSystemFontOfSize:16];
            [self.applyForRefund setBackgroundColor:[UIColor whiteColor]];
            [self.applyForRefund.layer setCornerRadius:2];
            [self.applyForRefund addTarget:self action:@selector(cancelOrder) forControlEvents:UIControlEventTouchUpInside];
            [self.applyForRefund setTintColor:UIColorWithRGBA(74, 74, 74, 1)];
            [cell addSubview:self.applyForRefund];

        }
        self.affirmBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        [self.affirmBtn.layer setCornerRadius:2];
        [self.affirmBtn setTintColor:[UIColor whiteColor]];

        [cell addSubview:self.affirmBtn];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

//私信他按钮点击事件
- (void)sxtBtnAction{
    NSString *sendID;
    NSString *name;
    if ([[NSString stringWithFormat:@"%@",self.model.buyer]
         isEqualToString:[NSString stringWithFormat:@"%@",[LYUserService sharedInstance].userID]]) {
        sendID = [NSString stringWithFormat:@"%@",self.model.seller ];
        name = [NSString stringWithFormat:@"%@",self.model.seller_name];
    }
    else{
        sendID = [NSString stringWithFormat:@"%@",self.model.buyer];
        name = [NSString stringWithFormat:@"%@",self.model.buyer_name];
    }
    ChatViewController *chatVC = [[ChatViewController alloc]initWithChatter:sendID isGroup:NO];
    chatVC.title = name;
    [self.navigationController pushViewController:chatVC animated:YES];
}

//拨打电话事件
- (void)callHim{
    
    NSString *str;
    if ([[NSString stringWithFormat:@"%@",self.model.buyer]
         isEqualToString:[NSString stringWithFormat:@"%@",[LYUserService sharedInstance].userID]]) {
        if ([self isBlankString:self.model.seller_mobile]) {
            [MBProgressHUD showError:@"尚未填写联系电话"];
            return;
        }
        str = [NSString stringWithFormat:@"tel://%@",self.model.seller_mobile];
    }
    else{
        if ([self isBlankString:self.model.buyer_mobile]) {
            [MBProgressHUD showError:@"尚未填写联系电话"];
            return;
        }
        str = [NSString stringWithFormat:@"tel://%@",self.model.buyer_mobile];
    }
    UIWebView * callWebview = [[UIWebView alloc] init];
    [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
    [self.view addSubview:callWebview];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    self.payType = [NSString stringWithFormat:@"%ld",(long)buttonIndex];
    if (buttonIndex == 0 || buttonIndex == 1) {
        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/order/createOrder",REQUESTHEADER] andParameter:@{@"buyer":[LYUserService sharedInstance].userID,@"seller":self.model.seller,@"createIp":@"1.1.1.1",@"channel": self.payType,@"amount":self.model.amount,@"beginTime":_startTime,@"endTime":_endTime,@"content":@"向导订购服务"} success:^(id successResponse) {
            MLOG(@"结果:%@",successResponse);
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
            } else {
                [MBProgressHUD hideHUD];
                [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
            }
        } andFailure:^(id failureResponse) {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"服务器繁忙,请重试"];
        }];
    }
    
}

#pragma mark 购买事件

- (void)surePay{
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"支付方式" delegate: self cancelButtonTitle:@"取消" destructiveButtonTitle: nil otherButtonTitles:@"支付宝",@"微信支付", nil];
    [action showInView:self.view];
    
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
    order.amount = @"0.01";//self.vipModel.total_fee; //商品价格
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
                [MBProgressHUD showSuccess:@"付款成功"];
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
            else{
                [MBProgressHUD showError:@"付款失败"];
            }
        }];
    }
}

- (UIButton *)starsCreated:(float)origin_x{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    float starHeight = 15;
    [btn setFrame:
                CGRectMake(origin_x, (44 - starHeight) / 2.0, starHeight, starHeight)];
    [btn setBackgroundImage:[UIImage imageNamed:@"Star2"]
                                            forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(starAction:) forControlEvents:UIControlEventTouchUpInside];
    [_starsArr addObject:btn];
    return btn;
}

- (void)starAction:(UIButton *)btn{
    for (UIButton *tempBtn in _starsArr) {
        if (tempBtn.tag <= btn.tag) {
            [tempBtn setBackgroundImage:[UIImage imageNamed:@"Star"] forState:UIControlStateNormal];
        }
        else{
            [tempBtn setBackgroundImage:[UIImage imageNamed:@"Star2"] forState:UIControlStateNormal];
        }
    }
    serviceEvaluation = btn.tag;
}

//点击确认服务按钮后如果未对服务进行评价则弹出提示框
- (void)affirmBtnAction{
    if (serviceEvaluation == 0) {
       [UIView animateWithDuration:0.2 animations:^{
           _modalView.alpha = 0.4;
           _alertView.hidden = NO;
       }];
        
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"确认服务后将不能申请退款" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.tag = 501;
        [alert show];
    }
}

#pragma mark uialertview代理方法

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 501) {
        if (buttonIndex == 0) {
            return;
        }
        else{
            //确认订单发送请求
            [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/order/orderPay",REQUESTHEADER] andParameter:@{@"orderId":self.model.orderId,@"evaluation":[NSString stringWithFormat:@"%d",serviceEvaluation]} success:^(id successResponse) {
                MLOG(@"结果:%@",successResponse);
                if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
                    [MBProgressHUD hideHUD];
                    [MBProgressHUD showSuccess:@"提交成功"];
                    [self.navigationController popViewControllerAnimated:YES];
                } else {
                    [MBProgressHUD hideHUD];
                    [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
                }
            } andFailure:^(id failureResponse) {
                [MBProgressHUD hideHUD];
                [MBProgressHUD showError:@"服务器繁忙,请重试"];
            }];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 1) {
         DetailDataViewController *nextPage = [[DetailDataViewController alloc]init];
        if([[NSString stringWithFormat:@"%@",self.model.buyer]
            isEqualToString:[NSString stringWithFormat:@"%@",[LYUserService sharedInstance].userID]]){//如果用户是买家
            nextPage.friendId = [self.model.buyer integerValue];
        }
        else{
            nextPage.friendId = [self.model.seller integerValue];
        }
       
        [self.navigationController pushViewController:nextPage animated:YES];
    }
    else if(indexPath.row == 6){
        DetailDataViewController *nextPage = [[DetailDataViewController alloc]init];
        if([[NSString stringWithFormat:@"%@",self.model.buyer]
            isEqualToString:[NSString stringWithFormat:@"%@",[LYUserService sharedInstance].userID]]){//如果用户是买家
            nextPage.friendId = [self.model.seller integerValue];
        }
        else{
            nextPage.friendId = [self.model.buyer integerValue];
        }
        
        [self.navigationController pushViewController:nextPage animated:YES];
    }
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
