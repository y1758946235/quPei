//
//  AllOrderScrollView.m
//  豆客项目
//
//  Created by Xia Wei on 15/10/12.
//  Copyright © 2015年 Xia Wei. All rights reserved.
//

#import "AllOrderScrollView.h"
#import "AllOrederTableViewCell.h"
#import "OrderDetailsViewController.h"
#import "OrderModel.h"
#import "LYUserService.h"
#import "AffirmOrderViewController.h"
#import "RefundSuccessViewController.h"
@interface AllOrderScrollView()<UITableViewDataSource,UITableViewDelegate>{
    UINib *nib;
}
//@property (nonatomic,strong) NSMutableArray *allOrderArray;
@property (nonatomic,assign) NSInteger allCnt;
@property (nonatomic,assign) NSInteger touristCnt;
@property (nonatomic,strong) OrderModel *myModel;
@end

@implementation AllOrderScrollView
- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentSize = CGSizeMake(3 * (frame.size.width + 1), frame.size.height);
        self.pagingEnabled =YES;
        
        //添加分割线
//        UIView *separateLine = [[UIView alloc]initWithFrame:CGRectMake(frame.size.width, 0, 1, frame.size.height)];
//        [separateLine setBackgroundColor:[UIColor blackColor]];
//        [self addSubview:separateLine];
        
        self.showsHorizontalScrollIndicator = NO;
        
        //创建全部、发送、接受订单页面的tableView
        self.allTableV = [[UITableView alloc] init];
        self.sendTableV = [[UITableView alloc] init];
        self.receiveTableV = [[UITableView alloc] init];
        //利用tag的值区分不同的tableView
        self.allTableV.tag = 100;
        self.sendTableV.tag = 200;
        self.receiveTableV.tag = 300;
        [self tableViewCreated:self.allTableV origin_x:0];
        [self tableViewCreated:self.sendTableV origin_x:frame.size.width + 1];
        [self tableViewCreated:self.receiveTableV origin_x:(frame.size.width + 1) * 2];
    }
    return self;
}

- (void) tableViewCreated:(UITableView *)tableV origin_x:(float)origin_x{
    [tableV setFrame:CGRectMake(origin_x, 0, kMainScreenWidth, self.frame.size.height)];
    tableV.delegate = self;
    tableV.dataSource = self;
    tableV.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableV.showsVerticalScrollIndicator = NO;
    [self addSubview:tableV];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView.tag == 100) {
        NSLog(@"xw : %lu",(unsigned long)self.allOrderArray.count);
        return self.allOrderArray.count;
    }
    else if(tableView.tag == 200){
        return self.touristOrderArray.count;
    }
    return self.guideOrderArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString  *identifier = @"myCell";
    AllOrederTableViewCell *cell = [tableView
                                    dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        CGRect frame = cell.frame;
        frame.size.width = kMainScreenWidth;
        frame.size.height = 80;
        cell = [[AllOrederTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier frame:frame];
    }
    
    if (tableView.tag == 100) {
        self.myModel = self.allOrderArray[indexPath.row];
        if ([[NSString stringWithFormat:@"%@",self.myModel.buyer]
             isEqualToString:[NSString stringWithFormat:@"%@",[LYUserService sharedInstance].userID]]) {
            cell.nameLabel.text = @"服务者:";
        }
        else{
            cell.nameLabel.text = @"消费者:";
        }

    }
    else if(tableView.tag == 200){
        self.myModel = self.touristOrderArray[indexPath.row];
        if ([[NSString stringWithFormat:@"%@",self.myModel.buyer]
             isEqualToString:[NSString stringWithFormat:@"%@",[LYUserService sharedInstance].userID]]) {
            cell.nameLabel.text = @"服务者:";
        }
        else{
            cell.nameLabel.text = @"消费者:";
        }
    }
    else{
        self.myModel = self.guideOrderArray[indexPath.row];
        if ([[NSString stringWithFormat:@"%@",self.myModel.buyer]
             isEqualToString:[NSString stringWithFormat:@"%@",[LYUserService sharedInstance].userID]]) {
            cell.nameLabel.text = @"服务者:";
        }
        else{
            cell.nameLabel.text = @"消费者:";
        }
    }
    [cell fillDataWithModel:self.myModel];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView.tag == 100) {
        OrderModel *tempOrder = (OrderModel *)self.allOrderArray[indexPath.row];
        NSLog(@"%ld %ld",(long)indexPath.section,(long)indexPath.row);
        NSLog(@"%@ %@ %@",self.myModel.buyer,[LYUserService sharedInstance].userID,tempOrder.status);
        if ((![[NSString stringWithFormat:@"%@",tempOrder.buyer]
             isEqualToString:[NSString stringWithFormat:@"%@",[LYUserService sharedInstance].userID]]) && ([[NSString stringWithFormat:@"%@",tempOrder.status ] isEqualToString:@"1"] ||
                                                                                                        [[NSString stringWithFormat:@"%@",tempOrder.status ] isEqualToString:@"7"])) {
            //如果是导游接单就跳到确认订单界面
            AffirmOrderViewController *affirmView = [[AffirmOrderViewController alloc]init];
            affirmView.model = tempOrder;
            [self.navi pushViewController:affirmView animated:YES];
            return;
        }
        else if(([[NSString stringWithFormat:@"%@",tempOrder.buyer]
                 isEqualToString:[NSString stringWithFormat:@"%@",[LYUserService sharedInstance].userID]]) && ([[NSString stringWithFormat:@"%@",tempOrder.status] isEqualToString:@"3"])){
            RefundSuccessViewController *refund = [[RefundSuccessViewController alloc]init];
            refund.orderID = [NSString stringWithFormat:@"%@",tempOrder.order_no];
            refund.date = [tempOrder.update_time substringWithRange:NSMakeRange(0, [tempOrder.update_time length] - 9)];
            [self.navi pushViewController:refund animated:YES];
            return;
        }
        else{
            //如果是游客看详细订单
            OrderDetailsViewController *detail = [[OrderDetailsViewController alloc] init];
            detail.model = self.allOrderArray[indexPath.row];
            [self.navi pushViewController:detail animated:YES];
            return;
        }
    }
    else if (tableView.tag == 200){//若果是发出的订单
        //申请退款中
        OrderModel *tempModel = self.touristOrderArray[indexPath.row];
        if ([[NSString stringWithFormat:@"%@",tempModel.status] isEqualToString:@"3"]) {
            RefundSuccessViewController *refundVC = [[RefundSuccessViewController alloc]init];
            refundVC.orderID = tempModel.order_no;
            refundVC.date = [tempModel.update_time substringWithRange:NSMakeRange(0, [tempModel.update_time length] - 9)];
            [self.navi pushViewController:refundVC animated:YES];
            return;
        }
        OrderDetailsViewController *detail = [[OrderDetailsViewController alloc] init];
        detail.model = self.touristOrderArray[indexPath.row];
        [self.navi pushViewController:detail animated:YES];
        return;
    }
    else{
        OrderModel *tempOrder = (OrderModel *)self.guideOrderArray[indexPath.row];
        if ([[NSString stringWithFormat:@"%@",tempOrder.status] isEqualToString:@"1"] ||
                            [[NSString stringWithFormat:@"%@",tempOrder.status ] isEqualToString:@"7"]){           //如果是已付款已接单和已付款未接单界面则跳到确认订单界面
            AffirmOrderViewController *affirmView = [[AffirmOrderViewController alloc]init];
            affirmView.model = tempOrder;
            [self.navi pushViewController:affirmView animated:YES];
            return;
        }
        OrderDetailsViewController *detail = [[OrderDetailsViewController alloc] init];
        detail.model = self.guideOrderArray[indexPath.row];
        [self.navi pushViewController:detail animated:YES];
        return;
    }
}

@end

