//
//  UIView+KFFrame.h
//  LvYue
//
//  Created by KFallen on 16/6/28.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (KFFrame)

@property (assign, nonatomic) CGFloat x;
@property (assign, nonatomic) CGFloat y;
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;
@property (assign, nonatomic) CGFloat width;
@property (assign, nonatomic) CGFloat height;

@property (assign, nonatomic) CGSize size; //大小

@property (assign, nonatomic) CGPoint origin; //位置


/**
 ** lineView:	   需要绘制成虚线的view
 ** lineLength:	   虚线的宽度
 ** lineSpacing:   虚线的间距
 ** lineColor:	   虚线的颜色
 **/
+ (void)drawDashLine:(UIView *)lineView lineLength:(int)lineLength lineSpacing:(int)lineSpacing lineColor:(UIColor *)lineColor;

@end
