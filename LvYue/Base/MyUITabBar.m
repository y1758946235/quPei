//
//  MyUITabBar.m
//  LvYue
//
//  Created by X@Han on 17/6/13.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "MyUITabBar.h"

@implementation MyUITabBar

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype) initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.roundButton.frame = self.frame;
        self.backgroundColor = [UIColor whiteColor];
        
        [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(roundBtnClicked) name:@"roundBtnClicked" object:nil];
//        [self.roundButton setBackgroundImage:[UIImage imageNamed:@"动态大" ] forState:UIControlStateNormal];
       
        [self addSubview:self.roundButton];
    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]  removeObserver:self];
}
//懒加载
- (UIButton *)roundButton
{
    if (!_roundButton) {
        _roundButton = [[UIButton alloc] init];
        _roundButton.layer.cornerRadius = 32;
        _roundButton.layer.borderColor = RGBA(227, 227, 227, 1).CGColor;
        _roundButton.layer.borderWidth = 1;
        _roundButton.clipsToBounds = YES;
        _roundButton.backgroundColor = [UIColor colorWithHexString:@"#ffffff"];
        _roundButton.contentVerticalAlignment =UIControlContentHorizontalAlignmentCenter;
        _roundButton.imageEdgeInsets = UIEdgeInsetsMake(17, 17, 17, 17);
        
      
    }
    return _roundButton;
}

- (void)roundBtnClicked{
    self.roundButton.transform = CGAffineTransformMakeRotation(M_PI_2);
    [UIView  animateWithDuration:0.5 animations:^{
        self.roundButton.transform = CGAffineTransformRotate( self.roundButton.transform, -M_PI_4*4);
        
    }];
    
//    if ([self.myDelegate respondsToSelector:@selector(RoundButtonClicked)]) {
//        [self.myDelegate RoundButtonClicked];
//    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    //系统自带的按钮类型是UITabBarButton，找出这些类型的按钮，然后重新排布位置，空出中间的位置
    Class class = NSClassFromString(@"UITabBarButton");
    
    self.roundButton.size = CGSizeMake(self.roundButton.currentBackgroundImage.size.width, self.roundButton.currentBackgroundImage.size.height);
    
    self.roundButton.centerX = self.centerX;
    //调整发布按钮的中线点Y值
    self.roundButton.centerY = self.height-24.5;
    
    self.roundButton.bounds = CGRectMake(0, 0, 64, 64);
    
   
    UIImageView *imagV = [[UIImageView  alloc]init];
    imagV.frame = CGRectMake(17, 17, 29.9, 29.9);
    imagV.image = [UIImage imageNamed:@"动态大" ];
    [_roundButton addSubview:imagV];
//
//
//    UILabel *label = [[UILabel alloc] init];
//    label.text = @"发布";
//    label.font = [UIFont systemFontOfSize:11];
//    [label sizeToFit];
//    label.textColor = [UIColor grayColor];
//    [self addSubview:label];
//    label.centerX = self.roundButton.centerX;
//    label.centerY = CGRectGetMaxY(self.roundButton.frame) + LBMagin ;
    
    
    
    int btnIndex = 0;
    for (UIView *btn in self.subviews) {//遍历tabbar的子控件
        if ([btn isKindOfClass:class]) {//如果是系统的UITabBarButton，那么就调整子控件位置，空出中间位置
            //每一个按钮的宽度==tabbar的五分之一
            btn.width = self.width / 5;
            
            btn.x = btn.width * btnIndex;
            
            btnIndex++;
            //如果是索引是2(从0开始的)，直接让索引++，目的就是让消息按钮的位置向右移动，空出来发布按钮的位置
//            if (btnIndex == 2) {
//            
////                btnIndex++;
//            }
            
        }
    }
}

//响应触摸事件，如果触摸位置位于圆形按钮控件上，则由圆形按钮处理触摸消息
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    //判断tabbar是否隐藏
    if (self.hidden == NO) {
//        if ([self touchPointInsideCircle:self.roundButton.center radius:30 targetPoint:point]) {
//            //如果位于圆形按钮上，则由圆形按钮处理触摸消息
//            return self.roundButton;
//        }
//        else{
//            //否则系统默认处理
//            return [super hitTest:point withEvent:event];
//        }
    }
    return [super hitTest:point withEvent:event];
}

- (BOOL)touchPointInsideCircle:(CGPoint)center radius:(CGFloat)radius targetPoint:(CGPoint)point
{
    CGFloat dist = sqrtf((point.x - center.x) * (point.x - center.x) +
                         (point.y - center.y) * (point.y - center.y));
    return (dist <= radius);
}

@end
