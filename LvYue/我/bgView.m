//
//  bgView.m
//  澜庭
//
//  Created by 广有射怪鸟事 on 15/9/27.
//  Copyright (c) 2015年 刘瀚韬. All rights reserved.
//

#import "bgView.h"

@implementation bgView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    [self setFrame:frame];
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:frame];
    [btn addTarget:self action:@selector(backChangeName) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];
    
    return self;
}


- (void)backChangeName{
    [self removeFromSuperview];
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

@end
