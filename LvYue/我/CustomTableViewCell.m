//
//  CustomTableViewCell.m
//  cellXibDemo
//
//  Created by 广有射怪鸟事 on 15/10/6.
//  Copyright © 2015年 刘瀚韬. All rights reserved.
//

#import "CustomTableViewCell.h"

@interface CustomTableViewCell ()


@end

@implementation CustomTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    self.cheap.hidden = YES;            //隐藏优惠文字
    //self.price.hidden = NO;            //价格
    self.payMethodLabel.hidden = YES;   //支付方式
    self.leftPayButton.hidden = YES;    //左边支付方式的按钮
    [self.leftPayButton addTarget:self action:@selector(chosePayMenthod:) forControlEvents:UIControlEventTouchUpInside];
    self.rightPayButton.hidden = YES;   //右边支付方式的按钮
    [self.rightPayButton addTarget:self action:@selector(chosePayMenthod:) forControlEvents:UIControlEventTouchUpInside];
    self.selectBtn.hidden = YES;        //选中图标
    self.month.hidden = YES;            //月数
}

- (void)chosePayMenthod:(UIButton *)sender {
    //点击则选中
    //sender.isSelected == sender.selected;
    if (sender.isSelected == sender.selected) { //被选中
        sender.selected = YES;
    }
    else {
        sender.selected = NO;
    }
    //代理
    NSInteger buttonIndex =0;
    if ([sender.titleLabel.text isEqualToString:@"支付宝"]) {
        buttonIndex = 0;
    }
    else if ([sender.titleLabel.text isEqualToString:@"微信支付"]) {
        buttonIndex = 1;
    }
    else if ([sender.titleLabel.text isEqualToString:@"苹果内购"]) {
        buttonIndex = 2;
    }
    else if ([sender.titleLabel.text isEqualToString:@"金币支付"]) {
        buttonIndex = 3;
    }
    
    if ([self.delegate respondsToSelector:@selector(customTableViewCell:didClickButtonIndex:)]) {
        [self.delegate customTableViewCell:self didClickButtonIndex:buttonIndex];
    }
}


+ (instancetype)cellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    
    
    static NSString *myId = @"CustomTableViewCell";
    CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myId];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:myId owner:nil options:nil] lastObject];
    }
    cell.cheap.hidden = YES;
    if (indexPath.section == 0) {  //支付月数
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.price.hidden = NO;
        cell.selectBtn.hidden = NO;
        cell.month.hidden = NO;
        [cell.selectBtn setBackgroundImage:[UIImage imageNamed:@"未选"] forState:UIControlStateNormal];
        [cell.selectBtn setBackgroundImage:[UIImage imageNamed:@"选中"] forState:UIControlStateSelected];
        
        cell.selectBtn.selected = NO;
        
//        if (indexPath.row == [self.sale intValue]) {
//            cell.selectBtn.selected = YES;
//        }
        
        cell.month.textColor = [UIColor colorWithHexString:@"#424242"];
        cell.month.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        
        switch (indexPath.row) {
            case 0:
                cell.month.text = @"3个月";
                break;
            case 1:
                cell.month.text = @"6个月";
                break;
            case 2:
            {
                cell.month.text = @"12个月";
                cell.cheap.hidden = NO;
            }
                break;
            default:
                break;
        }
    }
    else if (indexPath.section == 1) {  //支付方式
        //支付方式
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        //去掉分割线
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        cell.price.hidden = YES;
        cell.month.hidden = YES;
        cell.selectBtn.hidden = YES;
        switch (indexPath.row) { //支付方式
            case 0: { //支付方式文字
                cell.payMethodLabel.hidden = NO;
                cell.leftPayButton.hidden = YES;
                cell.rightPayButton.hidden = YES;
                break;
            }
            case 1: { //金币支付与苹果内购
                cell.payMethodLabel.hidden = YES;
//                //金币支付
//                cell.leftPayButton.hidden = NO;
//                cell.leftPayButton.selected = NO;
//                [cell.leftPayButton setImage:[UIImage imageNamed:@"多边形-1"] forState:UIControlStateNormal];
//                [cell.leftPayButton setTitle:@"金币支付" forState:UIControlStateNormal];
//                [cell.leftPayButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateSelected];
//                [cell.leftPayButton setImage:[UIImage imageNamed:@"金币（绿）"] forState:UIControlStateSelected];
//                [cell.leftPayButton setTitle:@"金币支付" forState:UIControlStateSelected];
//                [cell.leftPayButton setTitleColor:THEME_COLOR forState:UIControlStateSelected];
//                
//                //苹果内购
//                cell.rightPayButton.hidden = NO;
//                cell.rightPayButton.selected = NO;
//                [cell.rightPayButton setImage:[UIImage imageNamed:@"苹果"] forState:UIControlStateNormal];
//                [cell.rightPayButton setTitle:@"苹果内购" forState:UIControlStateNormal];
//                [cell.rightPayButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateSelected];
//                [cell.rightPayButton setImage:[UIImage imageNamed:@"苹果（绿）"] forState:UIControlStateSelected];
//                [cell.rightPayButton setTitle:@"苹果内购" forState:UIControlStateSelected];
//                [cell.rightPayButton setTitleColor:THEME_COLOR forState:UIControlStateSelected];
                
                //金币支付
                cell.rightPayButton.hidden = NO;
                cell.rightPayButton.selected = NO;
                [cell.rightPayButton setImage:[UIImage imageNamed:@"多边形-1"] forState:UIControlStateNormal];
                [cell.rightPayButton setTitle:@"金币支付" forState:UIControlStateNormal];
                [cell.rightPayButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateSelected];
                [cell.rightPayButton setImage:[UIImage imageNamed:@"金币（绿）"] forState:UIControlStateSelected];
                [cell.rightPayButton setTitle:@"金币支付" forState:UIControlStateSelected];
                [cell.rightPayButton setTitleColor:THEME_COLOR forState:UIControlStateSelected];
                
                //苹果内购
                cell.leftPayButton.hidden = NO;
                cell.leftPayButton.selected = YES;
                [cell.leftPayButton setImage:[UIImage imageNamed:@"苹果"] forState:UIControlStateNormal];
                [cell.leftPayButton setTitle:@"苹果内购" forState:UIControlStateNormal];
                [cell.leftPayButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateSelected];
                [cell.leftPayButton setImage:[UIImage imageNamed:@"苹果（绿）"] forState:UIControlStateSelected];
                [cell.leftPayButton setTitle:@"苹果内购" forState:UIControlStateSelected];
                [cell.leftPayButton setTitleColor:THEME_COLOR forState:UIControlStateSelected];
                break;
            }
            case 2: { //微信支付与支付宝
                cell.payMethodLabel.hidden = YES;
                
                //微信支付
                cell.leftPayButton.hidden = NO;
                cell.leftPayButton.selected = NO;
                [cell.leftPayButton setImage:[UIImage imageNamed:@"微信支付"] forState:UIControlStateNormal];
                [cell.leftPayButton setTitle:@"微信支付" forState:UIControlStateNormal];
                [cell.leftPayButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateSelected];
                [cell.leftPayButton setImage:[UIImage imageNamed:@"微信支付（绿）"] forState:UIControlStateSelected];
                [cell.leftPayButton setTitle:@"微信支付" forState:UIControlStateSelected];
                [cell.leftPayButton setTitleColor:THEME_COLOR forState:UIControlStateSelected];
                
//                //苹果内购
//                cell.rightPayButton.hidden = NO;
//                cell.rightPayButton.selected = NO;
//                [cell.rightPayButton setImage:[UIImage imageNamed:@"苹果"] forState:UIControlStateNormal];
//                [cell.rightPayButton setTitle:@"苹果内购" forState:UIControlStateNormal];
//                [cell.rightPayButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateSelected];
//                [cell.rightPayButton setImage:[UIImage imageNamed:@"苹果（绿）"] forState:UIControlStateSelected];
//                [cell.rightPayButton setTitle:@"苹果内购" forState:UIControlStateSelected];
//                [cell.rightPayButton setTitleColor:THEME_COLOR forState:UIControlStateSelected];
                //支付宝
                cell.rightPayButton.hidden = NO;
                cell.rightPayButton.selected = NO;
                [cell.rightPayButton setImage:[UIImage imageNamed:@"支付宝"] forState:UIControlStateNormal];
                [cell.rightPayButton setTitle:@"支付宝" forState:UIControlStateNormal];
                [cell.rightPayButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateSelected];
                [cell.rightPayButton setImage:[UIImage imageNamed:@"支付宝（绿）"] forState:UIControlStateSelected];
                [cell.rightPayButton setTitle:@"支付宝" forState:UIControlStateSelected];
                [cell.rightPayButton setTitleColor:THEME_COLOR forState:UIControlStateSelected];


                break;
            }
            default:
                break;
        }
    }
    else{  //月数与总计价钱
        cell.selectBtn.hidden = YES;
        
        cell.month.hidden = NO;//月数
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.price.hidden = NO;
        //cell.price.text = [NSString stringWithFormat:@"%@元",self.totalPrice];
        
        //        cell.selectBtn.selected = NO;
        //        if (indexPath.row == [self.payType intValue]) {
        //            cell.selectBtn.selected = YES;
        //        }
        //        switch (indexPath.row) {
        //            case 0:
        //            {
        //                cell.month.text = @"支付宝";
        //
        //            }
        //                break;
        //            case 1:
        //            {
        //                cell.month.text = @"微信支付";
        //
        //            }
        //                break;
        //            case 2:
        //            {
        //                cell.month.text = @"苹果内购";
        //
        //            }
        //                break;
        //            case 3:
        //            {
        //                cell.month.text = @"支付总计";
        //                cell.accessoryType = UITableViewCellAccessoryNone;
        //                cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //                cell.price.text = [NSString stringWithFormat:@"%@元",self.totalPrice];
        //                cell.price.hidden = NO;
        //                cell.selectBtn.hidden = YES;
        //            }
        //                break;
        //            default:
        //                break;
        //        } 
    }
    return cell;

}



@end
