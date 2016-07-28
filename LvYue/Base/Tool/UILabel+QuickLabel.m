//
//  UILabel+QuickLabel.m
//  LvYue
//
//  Created by Olive on 16/1/14.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "UILabel+QuickLabel.h"

@implementation UILabel (QuickLabel)

+ (UILabel *)_quickInitWithFrame:(CGRect)frame bgColor:(UIColor *)bgColor text:(NSString *)text textColor:(UIColor *)textColor font:(CGFloat)font textAlignment:(NSTextAlignment)textAlignment numberOfLines:(NSInteger)lines {
    UILabel *label;
    if (!CGRectIsNull(frame)) {
        label = [[UILabel alloc] initWithFrame:frame];
    } else {
        label = [[UILabel alloc] init];
    }
    if (bgColor) {
        label.backgroundColor = bgColor;
    }
    if (text) {
        label.text = text;
    }
    if (textColor) {
        label.textColor = textColor;
    }
    if (font) {
        label.font = [UIFont systemFontOfSize:font];
    }
    if (textAlignment) {
        label.textAlignment = textAlignment;
    }
    if (lines) {
        label.numberOfLines = lines;
    }
    return label;
}

@end
