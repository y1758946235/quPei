//
//  moneyListCell.m
//  LvYue
//
//  Created by X@Han on 16/12/17.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "moneyListCell.h"
#import "MoneyListModel.h"

@implementation moneyListCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
       
        
    }
    return self;
    
}
- (void)removeAllSubViews
{
    for (UIView *subView in self.contentView.subviews)
    {
        [subView removeFromSuperview];
    }
}

- (void)createCell{
    [self removeAllSubViews];
    self.iConNumLabel = [[UILabel alloc]initWithFrame:CGRectMake(16, 10, 152, 14)];
//    self.iConNumLabel.text = @"150金币";
    self.iConNumLabel.textAlignment = NSTextAlignmentLeft;
    self.iConNumLabel.textColor = [UIColor colorWithHexString:@"#424242"];
    self.iConNumLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [self.contentView addSubview:self.iConNumLabel];
    
    self.moneyTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(16, 32, 214, 12)];
    self.moneyTimeLabel.textAlignment = NSTextAlignmentLeft;
    self.moneyTimeLabel.text = @"2016/12/12 00:10:20";
    self.moneyTimeLabel.textColor = [UIColor colorWithHexString:@"#9e9e9e"];
    self.moneyTimeLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
    [self.contentView addSubview:self.moneyTimeLabel];
    
     UILabel *moneyLabel = [[UILabel alloc]init];
    moneyLabel.translatesAutoresizingMaskIntoConstraints = NO;
//    moneyLabel.text = @"¥0.01";
    moneyLabel.textColor = [UIColor colorWithHexString:@"#ff5252"];
    moneyLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    [self.contentView addSubview:moneyLabel];
    self.moneyLabel = moneyLabel;
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[moneyLabel(==36)]-16-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(moneyLabel)]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-16-[moneyLabel(==14)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(moneyLabel)]];
    
     UILabel *suceLabel = [[UILabel alloc]init];
    suceLabel.translatesAutoresizingMaskIntoConstraints = NO;
    suceLabel.textAlignment = NSTextAlignmentRight;
//     suceLabel.text = @"支付宝充值成功";
     suceLabel.textColor = [UIColor colorWithHexString:@"#9e9e9e"];
     suceLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
    [self.contentView addSubview:suceLabel];
    self.suceLabel = suceLabel;
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[suceLabel(==154)]-16-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(suceLabel)]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-32-[suceLabel(==12)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(suceLabel)]];


}

-(void)setModel:(MoneyListModel *)model{
    _model = model;
     [self createCell];
         self.iConNumLabel.text = [NSString stringWithFormat:@"%@金币",_model.goldNumber];
   
            self.moneyTimeLabel.text =[CommonTool timestampSwitchTime:[_model.createTime doubleValue]/1000 andFormatter:@"YYYY-MM-dd hh:mm:ss"] ;
            self.moneyLabel.text =[NSString stringWithFormat:@"¥%@",_model.orderAmount] ;
          self.suceLabel.text = _model.orderStatusStr;
            
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}




- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
