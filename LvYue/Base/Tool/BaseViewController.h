//
//  BaseViewController.h
//  Delan
//
//  Created by qf on 15/5/21.
//  Copyright (c) 2015年 wdb. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController

@property (nonatomic, assign) CGFloat g_OffsetY;
@property (nonatomic, strong) UIButton *rightButton;

- (UIButton *)setLeftButton:(UIImage *)image title:(NSString *)title target:(id)target action:(SEL)selector;

- (UIButton *)setLeftButton:(UIImage *)image title:(NSString *)title target:(id)target action:(SEL)selector rect:(CGRect)rect;

- (UIButton *)setRightButton:(UIImage *)image title:(NSString *)title target:(id)target action:(SEL)selector;

- (UIButton *)setRightButton:(UIImage *)image title:(NSString *)title target:(id)target action:(SEL)selector rect:(CGRect)rect;

@end
