//
//  OrderServiceTableViewCell.m
//  豆客项目
//
//  Created by Xia Wei on 15/10/2.
//  Copyright © 2015年 Xia Wei. All rights reserved.
//

#import "OrderServiceTableViewCell.h"

@implementation OrderServiceTableViewCell

- (void)awakeFromNib {
    
    UIColor *fontColor = [UIColor colorWithRed:100 / 256.0 green:100 / 256.0 blue:100 / 256.0 alpha:1];
    UIColor *color = [UIColor colorWithRed:229 / 255.0 green:229 / 255.0 blue:229 / 255.0 alpha:1];
    
    _textView.textColor = fontColor;
    _textView.editable = YES;
    [_textView.layer setBorderWidth:1];
    [_textView.layer setBorderColor:color.CGColor];
    [_textView.layer setCornerRadius:5];
    
    _textField.textColor = fontColor;
    [_textField.layer setBorderWidth:1];
    [_textField.layer setBorderColor:color.CGColor];
    [_textField.layer setCornerRadius:5];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
