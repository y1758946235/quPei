//
//  CycleScrollView.h
//  豆客项目
//
//  Created by Xia Wei on 15/9/25.
//  Copyright © 2015年 Xia Wei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CycleScrollView : UIView

@property(nonatomic,strong)UIScrollView *scrollView;
@property(nonatomic,strong)UIPageControl *page;
@property(nonatomic,assign)int currentPage;

- (id) initWithFrame:(CGRect)frame animationDuration:(NSTimeInterval)animationDuration;
- (void)changeImages:(int)currentPage;

@end
