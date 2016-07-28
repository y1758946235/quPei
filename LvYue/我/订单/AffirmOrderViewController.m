//
//  AffirmOrderViewController.m
//  豆客项目
//
//  Created by Xia Wei on 15/10/13.
//  Copyright © 2015年 Xia Wei. All rights reserved.
//

#import "AffirmOrderViewController.h"
#import "OrderDetailFirstTableViewCell.h"
#import "OrderDetailsFourthTableViewCell.h"
#import "MBProgressHUD+NJ.h"
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "ChatViewController.h"

@interface AffirmOrderViewController ()<UITableViewDataSource,UITableViewDelegate>{
    NSString *_touristName;
    NSString *_guideName;
    NSString *_startTime;
    NSString *_endTime;
    NSString *_orderNumber;
    NSString *_payNumber;
    NSString *_dealTime;
    NSString *_channel;
}

@end

@implementation AffirmOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationBar];
    [self tableViewCreated];
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
    titleView.textAlignment = NSTextAlignmentCenter;
    titleView.font = [UIFont systemFontOfSize:16];
    self.navigationItem.titleView = titleView;
    
    self.tabBarController.tabBar.hidden = YES;
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
    return 8;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return 65;
    }
    else if (indexPath.row == 2){
        return 130;
    }
    else if (indexPath.row == 3){
        return 10;
    }
    else if (indexPath.row == 5){
        return 50;
    }
    else if (indexPath.row == 6){
        return 100;
    }
    else if (indexPath.row == 7){
        return 130;
    }
    else
        return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        NSArray *nibArr = [[NSBundle mainBundle]loadNibNamed:@"OrderDetailFirstTableViewCell" owner:nil options:nil];
        OrderDetailFirstTableViewCell *cell = [nibArr lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.price.text = [NSString stringWithFormat:@"%@",self.model.amount];
        return cell;
    }
    else if(indexPath.row == 1){
        UITableViewCell *cell = [[UITableViewCell alloc]init];
        cell.imageView.image = [UIImage imageNamed:@"拍"];
        //裁剪年月日后面的时间
        NSString *tempeStartTime = [_startTime substringWithRange:NSMakeRange(0, [_startTime length] - 9)];
        NSLog(@"%@",_startTime);
        NSString *tempEndTime = [_endTime substringWithRange:NSMakeRange(0, [_endTime length] - 9)];
        NSString *str = [NSString stringWithFormat:@"预约时间: %@ 至 %@",tempeStartTime,tempEndTime];
        cell.textLabel.text = str;
        cell.textLabel.font = [UIFont systemFontOfSize:14.0];
        UIView *separaLine = [[UIView alloc]initWithFrame:CGRectMake(0,43,kMainScreenWidth, 1)];
        [separaLine setBackgroundColor:UIColorWithRGBA(234, 234, 234, 1)];
        [cell addSubview:separaLine];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if (indexPath.row == 2){
        OrderDetailsFourthTableViewCell *cell = [[OrderDetailsFourthTableViewCell alloc]initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 10)];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if (indexPath.row == 3){
        UITableViewCell *cell = [[UITableViewCell alloc]init];
        [cell setBackgroundColor:UIColorWithRGBA(234, 234, 234, 1)];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if (indexPath.row == 4){
        UITableViewCell *cell = [[UITableViewCell alloc]init];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.imageView.image = [UIImage imageNamed:@"拍"];
        NSString *str = [NSString stringWithFormat:@"消费者: %@",self.model.buyer_name];
        cell.textLabel.text = str;
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        
        //Cell下面的分割线
        UIView *separaLine = [[UIView alloc]initWithFrame:CGRectMake(0,43,kMainScreenWidth, 1)];
        [separaLine setBackgroundColor:UIColorWithRGBA(234, 234, 234, 1)];
        // [cell addSubview:separaLine];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if (indexPath.row == 5){
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
        
        //cell点击没效果
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if (indexPath.row == 6){
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
        return cell;
    }
    else{
        UITableViewCell *cell = [[UITableViewCell alloc]init];
        [cell setBackgroundColor:UIColorWithRGBA(0, 0, 0, 0)];
        
        //创建确认服务按钮
        UIButton *affirmBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        UIButton *noBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];//拒绝订单按钮
        if ([[NSString stringWithFormat:@"%@",self.model.status] isEqualToString:@"1"]) {
            [affirmBtn setTitle:@"确认订单" forState:UIControlStateNormal];
            [affirmBtn addTarget:self action:@selector(sureSurvice) forControlEvents:UIControlEventTouchUpInside];
            [affirmBtn setBackgroundColor:UIColorWithRGBA(249, 82, 74, 1)];
            
            [noBtn setTitle:@"拒绝订单" forState:UIControlStateNormal];
            [noBtn addTarget:self action:@selector(noGet:) forControlEvents:UIControlEventTouchUpInside];
            [noBtn setBackgroundColor:[UIColor whiteColor]];
            [noBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
        else if ([[NSString stringWithFormat:@"%@",self.model.status] isEqualToString:@"3"]){
            [affirmBtn setTitle:@"退款" forState:UIControlStateNormal];
            [affirmBtn setBackgroundColor:UIColorWithRGBA(249, 82, 74, 1)];
        }
        else if ([[NSString stringWithFormat:@"%@",self.model.status] isEqualToString:@"7"]){
            [affirmBtn setTitle:@"等待消费者确认服务..." forState:UIControlStateNormal];
            [affirmBtn setBackgroundColor:UIColorWithRGBA(251,94,45, 1)];
        }
        [affirmBtn setFrame:CGRectMake(15, 15, kMainScreenWidth - 30, 39)];
        affirmBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        [affirmBtn.layer setCornerRadius:5];
        [affirmBtn setTintColor:[UIColor whiteColor]];
        [noBtn setFrame:CGRectMake(affirmBtn.frame.origin.x, CGRectGetMaxY(affirmBtn.frame) + 20, affirmBtn.frame.size.width, affirmBtn.frame.size.height)];
        noBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        [noBtn.layer setCornerRadius:5];
        [cell addSubview:affirmBtn];
        [cell addSubview:noBtn];
        return cell;
    }
}

//私信他按钮点击事件
- (void)sxtBtnAction{
    NSString *sendID;
    if ([[NSString stringWithFormat:@"%@",self.model.buyer]
         isEqualToString:[NSString stringWithFormat:@"%@",[LYUserService sharedInstance].userID]]) {
        sendID = [NSString stringWithFormat:@"%@",self.model.seller];
    }
    else{
        sendID = [NSString stringWithFormat:@"%@",self.model.buyer];
    }
    ChatViewController *chatVC = [[ChatViewController alloc]initWithChatter:sendID isGroup:NO];
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

#pragma mark 确认服务

- (void)sureSurvice{
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/order/acceptOrder",REQUESTHEADER] andParameter:@{@"orderId":self.model.orderId} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showSuccess:nil];
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

#pragma mark 拒绝订单

- (void)noGet:(UIButton *)btn{
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/order/cancalOrder",REQUESTHEADER] andParameter:@{@"orderId":self.model.orderId} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showSuccess:nil];
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
