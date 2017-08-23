//
//  DyVideoPlayerFirHeadView.m
//  LvYue
//
//  Created by X@Han on 17/8/4.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "DyVideoPlayerFirHeadView.h"

@implementation DyVideoPlayerFirHeadView

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor =[UIColor  cyanColor];
      
    }
    return self;
    
}
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    
    if (CGRectContainsPoint(CGRectMake(0, 0, SCREEN_WIDTH, 50),point)) {
        return YES;
    }
    return NO;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
