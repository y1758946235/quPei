//
//  OrderDetailFirstTableViewCell.m
//  豆客项目
//
//  Created by Xia Wei on 15/10/13.
//  Copyright © 2015年 Xia Wei. All rights reserved.
//

#import "OrderDetailFirstTableViewCell.h"

@implementation OrderDetailFirstTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)fillData:(NSString *)price andTrade:(NSString *)status{
    self.price.text = [NSString stringWithFormat:@"%@",price];
    switch ([status integerValue]) {
        //-----------------
        case 0:
        {
            self.tradeStatus.text = @"未付款";
            [self.tradeStatus setTextColor:UIColorWithRGBA(250, 95, 92, 1)];
        }
            break;
        case 1:
        {
            self.tradeStatus.text = @"已付款未接单";
            [self.tradeStatus setTextColor:UIColorWithRGBA(198, 145, 110, 1)];
            break;
        }
        case 2:
        {
            self.tradeStatus.text = @"已完成";
            [self.tradeStatus setTextColor:UIColorWithRGBA(156,156,156, 1)];
            break;
        }
        case 3:
        {
            self.tradeStatus.text = @"退款中";
            [self.tradeStatus setTextColor:UIColorWithRGBA(172, 109, 62, 1)];
        }
            break;
        case 4:
        {
            self.tradeStatus.text = @"已退款";
            [self.tradeStatus setTextColor:UIColorWithRGBA(156,156,156, 1)];
        }
            break;
        case 5:
        {
            self.tradeStatus.text = @"支付失败";
            [self.tradeStatus setTextColor:UIColorWithRGBA(250, 95, 92, 1)];
            break;
        }
        case 6:
        {
            self.tradeStatus.text = @"拒绝订单退款中";
            [self.tradeStatus setTextColor:UIColorWithRGBA(250, 95, 92, 1)];
            break;
        }
        case 7:
        {
            self.tradeStatus.text = @"已付款已接单";
            [self.tradeStatus setTextColor:UIColorWithRGBA(250, 95, 92, 1)];
            break;
        }
        default:
            break;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
