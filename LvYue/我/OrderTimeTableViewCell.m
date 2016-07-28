//
//  OrderTimeTableViewCell.m
//  豆客项目
//
//  Created by Xia Wei on 15/9/29.
//  Copyright © 2015年 Xia Wei. All rights reserved.
//

#import "OrderTimeTableViewCell.h"

@implementation OrderTimeTableViewCell

- (void)awakeFromNib {
    UIColor *color = [UIColor colorWithRed:229 / 255.0 green:229 / 255.0 blue:229 / 255.0 alpha:1];
    
    [_startBtn.layer setCornerRadius:5];
    [_startBtn.layer setBorderWidth:1];
    [_startBtn.layer setBorderColor:color.CGColor];
    
    [_endBtn.layer setCornerRadius:5];
    [_endBtn.layer setBorderWidth:1];
    [_endBtn.layer setBorderColor:color.CGColor];
    
    UIColor *fontColor = [UIColor colorWithRed:100 / 256.0 green:100 / 256.0 blue:100 / 256.0 alpha:1];
    [_startBtn setTintColor:fontColor];
    [_endBtn setTintColor:fontColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
