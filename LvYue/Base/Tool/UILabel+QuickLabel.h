//
//  UILabel+QuickLabel.h
//  LvYue
//
//  Created by Olive on 16/1/14.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (QuickLabel)

/**
 *  快速创建方法
 */
+ (UILabel *)_quickInitWithFrame:(CGRect)frame bgColor:(UIColor *)bgColor text:(NSString *)text textColor:(UIColor *)textColor font:(CGFloat)font textAlignment:(NSTextAlignment)textAlignment numberOfLines:(NSInteger)lines;

@end
