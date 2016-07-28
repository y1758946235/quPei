//
//  AllOrederTableViewCellTableViewCell.m
//  豆客项目
//
//  Created by Xia Wei on 15/10/12.
//  Copyright © 2015年 Xia Wei. All rights reserved.
//


#import "AllOrederTableViewCell.h"
#import "LYUserService.h"


@interface AllOrederTableViewCell ()

@property (nonatomic,strong) UILabel *dateLabel;//创建时间
@property (nonatomic,strong) UILabel *orderNumber;//订单号
@property (nonatomic,strong) UILabel *stateLabel;//状态
@property (nonatomic,strong) UILabel *guideName;//导游名字

@end

@implementation AllOrederTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier frame:(CGRect)cellFrame{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.allOrderArray = [[NSMutableArray alloc] init];
        
        [self setFrame:CGRectMake(0,0,cellFrame.size.width, cellFrame.size.height)];
        //所有label的高度
        float firstLineHeight = 20;
        CGFloat firstLineFontSize = 12;
        CGFloat secondLineFontSize = 14;
        
        UILabel *orderLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 45, firstLineHeight)];
        orderLabel.font = [UIFont boldSystemFontOfSize:firstLineFontSize];
        orderLabel.text = @"订单号:";
        orderLabel.textColor = UIColorWithRGBA(166, 166, 166, 1);
        //[orderLabel setBackgroundColor:[UIColor redColor]];
        [self addSubview:orderLabel];
        
        //日期label
        self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - 132, 10, 122,firstLineHeight)];
        self.dateLabel.textColor = UIColorWithRGBA(166, 166, 166, 1);
        self.dateLabel.font = [UIFont systemFontOfSize:12.0];
        //[dateLabel setBackgroundColor:[UIColor redColor]];
        
        [self addSubview:self.dateLabel];
        
        //自适应时压缩订单号label的长度
        self.orderNumber = [[UILabel alloc]initWithFrame:
                        CGRectMake(CGRectGetMaxX(orderLabel.frame), 10,
    (cellFrame.size.width - self.dateLabel.frame.size.width - self.dateLabel.frame.size.width + 37),firstLineHeight)];
        self.orderNumber.textColor = UIColorWithRGBA(166, 166, 166, 1);
        self.orderNumber.font = [UIFont systemFontOfSize:12.0];
        //[orderNumber setBackgroundColor:[UIColor blueColor]];
        
        [self addSubview:self.orderNumber];
        
        //创建左边向导姓名旅客姓名那个label 
        self.nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(10,cellFrame.size.height - firstLineHeight - 10, 76, firstLineHeight)];
        self.nameLabel.font = [UIFont boldSystemFontOfSize:secondLineFontSize];
        //[nameLabel setBackgroundColor:[UIColor grayColor]];
        [self addSubview:self.nameLabel];
        
        self.stateLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.frame.size.width - 150 - 10,cellFrame.size.height - firstLineHeight - 10, 150, firstLineHeight)];
        self.stateLabel.font = [UIFont boldSystemFontOfSize:secondLineFontSize];
        self.stateLabel.textAlignment = NSTextAlignmentRight;
        //[stateLabel setBackgroundColor:[UIColor grayColor]];
        [self addSubview:self.stateLabel];
        
        //自适应时压缩姓名label的长度
        self.guideName = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.nameLabel.frame), cellFrame.size.height - firstLineHeight - 10,
    (cellFrame.size.width -self.stateLabel.frame.size.width - self.nameLabel.frame.size.width),firstLineHeight)];
        self.guideName.font = [UIFont boldSystemFontOfSize:secondLineFontSize];
        //[guideName setBackgroundColor:[UIColor blueColor]];
        
        [self addSubview:self.guideName];
        
    }
    return self;
}

- (void)fillDataWithModel:(OrderModel *)myModel{
    self.dateLabel.text = myModel.create_time;
    self.orderNumber.text = myModel.order_no;
    switch ([myModel.status integerValue]) {
        case 0:
        {

            self.stateLabel.text = @"未付款";
            [self.stateLabel setTextColor:UIColorWithRGBA(250, 95, 92, 1)];
        }
            break;
        case 1:
        {
            self.stateLabel.text = @"已付款未接单";
            [self.stateLabel setTextColor:[UIColor blueColor]];
        }
            break;
        case 2:
        {
            self.stateLabel.text = @"已完成";
            [self.stateLabel setTextColor:UIColorWithRGBA(156,156,156, 1)];
        }
            break;
        case 3:
        {
            self.stateLabel.text = @"退款中";
            [self.stateLabel setTextColor:UIColorWithRGBA(172, 109, 62, 1)];
        }
            break;
        case 4:
        {
            self.stateLabel.text = @"已退款";
            [self.stateLabel setTextColor:UIColorWithRGBA(156,156,156, 1)];
        }
            break;
        case 5:
        {
            self.stateLabel.text = @"支付失败";
            [self.stateLabel setTextColor:UIColorWithRGBA(250, 95, 92, 1)];
            break;
        }
        case 6:
        {
            self.stateLabel.text = @"拒绝订单";
            [self.stateLabel setTextColor:UIColorWithRGBA(250, 95, 92, 1)];
            break;
        }
        case 7:
        {
            self.stateLabel.text = @"已付款已接单";
            [self.stateLabel setTextColor:UIColorWithRGBA(250, 95, 92, 1)];
        }
            break;
        default:
            break;
    }
    if ([[NSString stringWithFormat:@"%@",myModel.buyer]
         isEqualToString:[NSString stringWithFormat:@"%@",[LYUserService sharedInstance].userID]]) {
        self.guideName.text = myModel.seller_name;
    }
    else{
        self.guideName.text = myModel.buyer_name;
    }
    
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
