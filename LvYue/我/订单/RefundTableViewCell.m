//
//  RefundTableViewCell.m
//  豆客项目
//
//  Created by Xia Wei on 15/10/13.
//  Copyright © 2015年 Xia Wei. All rights reserved.
//

#import "RefundTableViewCell.h"
#import "UILabel+CalculateSize.h"

@implementation RefundTableViewCell

- (id)initWithFrame:(CGRect)frame orderID:(NSString *)orderID date:(NSString *)date{
    self = [super initWithFrame:frame];
    if (self) {
        float fontSize;
        
        if (frame.size.width > 370) {
            fontSize = 15;
        }
        else
        {
            fontSize = 13;
        }
        UILabel *secondLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 140, frame.size.width, 40)];
        secondLine.text = @"管理人员正在处理,请耐心等候";
        secondLine.textAlignment = NSTextAlignmentCenter;
        secondLine.textColor = UIColorWithRGBA(132, 132, 132, 1);
        secondLine.font = [UIFont systemFontOfSize:fontSize];
        [self addSubview:secondLine];
        
        UILabel *thirdLine = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(secondLine.frame),frame.size.width, 20)];
        thirdLine.text = @"有疑问请致电0571-81622361";
        thirdLine.textAlignment = NSTextAlignmentCenter;
        thirdLine.font = [UIFont systemFontOfSize:fontSize];
        thirdLine.textColor = UIColorWithRGBA(132, 132, 132, 1);
        [self addSubview:thirdLine];
        [self setBackgroundColor:[UIColor whiteColor]];
        
        UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width - 220, frame.size.height - 60, 200, 20)];
        dateLabel.text = date;
        dateLabel.font = [UIFont systemFontOfSize:fontSize];
        dateLabel.textAlignment = NSTextAlignmentRight;
      //  [dateLabel setBackgroundColor:[UIColor redColor]];
        dateLabel.textColor = UIColorWithRGBA(132, 132, 132, 1);
        [self addSubview:dateLabel];
        
        //算出两个label的大小然后根据总的长度居中
        UILabel *orderNumber = [[UILabel alloc]init];
        orderNumber.text = [NSString stringWithFormat:@"订单号%@",orderID];
        if (frame.size.width > 370) {
            orderNumber.font = [UIFont systemFontOfSize:13];
        }
        else
        {
            orderNumber.font = [UIFont systemFontOfSize:11];
        }
        orderNumber.textColor = UIColorWithRGBA(251, 35, 0, 1);
        UILabel *firstLine = [[UILabel alloc] init];
        firstLine.font = [UIFont systemFontOfSize:fontSize];
        firstLine.text = @"正在申请退款服务";
        firstLine.textColor = UIColorWithRGBA(132, 132, 132, 1);
        CGSize orderSize = [orderNumber calculateSize:orderNumber];
        CGSize firstLineSize = [firstLine calculateSize:firstLine];
        
        [orderNumber setFrame:CGRectMake((frame.size.width - orderSize.width - firstLineSize.width) / 2.0, CGRectGetMinY(secondLine.frame) - 20,orderSize.width, 20)];
        [firstLine setFrame:CGRectMake(CGRectGetMaxX(orderNumber.frame) + 1, CGRectGetMinY(secondLine.frame) - 20, firstLineSize.width, 20)];
        [self addSubview:orderNumber];
        [self addSubview:firstLine];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
