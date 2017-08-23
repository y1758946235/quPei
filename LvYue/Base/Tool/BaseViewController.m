//
//  BaseViewController.m
//  Delan
//
//  Created by qf on 15/5/21.
//  Copyright (c) 2015年 wdb. All rights reserved.
//

#import "BaseViewController.h"
#import "UIView+RSAdditions.h"

@interface BaseViewController () {
    UIButton *_currentButton;
}

@end

@implementation BaseViewController
@synthesize g_OffsetY;

- (void)dealloc {
    NSLog(@"%@", NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //导航颜色
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:@"#ffffff"];
        //导航栏title的颜色
        [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithHexString:@"#424242"],UITextAttributeTextColor, [UIFont fontWithName:@"PingFangSC-Medium" size:18],UITextAttributeFont, nil]];
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:@"#ffffff"];
    // 布局从导航栏下面开始布局
    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self.navigationController setNavigationBarHidden:NO];

    if (self != [self.navigationController.viewControllers objectAtIndex:0]) {
//        [self setLeftButton:[UIImage imageNamed:@"返回"] title:nil target:self action:@selector(back) rect:CGRectMake(0, 0, 28, 28)];
         [self setLeftButton:nil title:@"返回" target:self action:@selector(back) rect:CGRectMake(0, 0, 28, 28)];
    }

    self.view.backgroundColor = [UIColor whiteColor];

    //统一设置输入框的样式
    //    [UITextField appearance].tintColor = [UIColor redColor];
    //    [UITextView appearance].tintColor = [UIColor redColor];
    //    [UITextView appearance].textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10);
    
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}
- (UIButton *)setRightButton:(UIImage *)image title:(NSString *)title target:(id)target action:(SEL)selector
{
    UIButton *currentButton = [self setRightButton:image title:title target:target action:selector rect:CGRectNull];
    return currentButton;
}

- (UIButton *)setRightButton:(UIImage *)image title:(NSString *)title target:(id)target action:(SEL)selector rect:(CGRect)rect {
    if (self.navigationController && self.navigationItem) {
        CGRect buttonFrame;
        CGRect viewFrame;
        if (CGRectIsNull(rect)) {
            buttonFrame = CGRectMake(0, 0, 44, 44);
            viewFrame   = CGRectMake(0, 0, 44, 44);
        } else {
            buttonFrame = rect;
            viewFrame   = rect;
        }
        UIButton *button = [[UIButton alloc] initWithFrame:buttonFrame];
        if (image) {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            imageView.center       = CGPointMake(button.width / 2, button.height / 2);
            imageView.bounds       = CGRectMake(0, 0, 20, 16);
            [button addSubview:imageView];
        }
        if (title) {
            [button setTitle:title forState:UIControlStateNormal];
           // button.titleLabel.font = kFont16;
            button.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
            //Customzied TitleColor..
            [button setTitleColor:[UIColor colorWithHexString:@"#424242"]  forState:UIControlStateNormal];
        }
        [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
        UIView *view = [[UIView alloc] initWithFrame:viewFrame];
        [view addSubview:button];
        _currentButton                         = button;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:view];
    }
    return _currentButton;
}

- (UIButton *)setLeftButton:(UIImage *)image title:(NSString *)title target:(id)target action:(SEL)selector {
    UIButton *currentButton = [self setLeftButton:image title:title target:target action:selector rect:CGRectNull];
    return currentButton;
}

- (UIButton *)setLeftButton:(UIImage *)image title:(NSString *)title target:(id)target action:(SEL)selector rect:(CGRect)rect {
    if (self.navigationItem && self.navigationController) {

        CGRect buttonFrame;
        CGRect viewFrame;
        if (CGRectIsNull(rect)) {
            buttonFrame = CGRectMake(0, 0, 44, 44);
            viewFrame   = CGRectMake(0, 0, 44, 44);
            
        } else {
            buttonFrame = rect;
            viewFrame   = rect;
        }

        UIButton *button = [[UIButton alloc] initWithFrame:buttonFrame];
        UIView *view     = [[UIView alloc] initWithFrame:viewFrame];
       
        if (image) {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            imageView.center       = CGPointMake(button.width / 2, button.height / 2);
            imageView.bounds       = CGRectMake(0, 0, 14, 22);
        
            [button addSubview:imageView];
        }
        if (title) {
            [button setTitle:title forState:UIControlStateNormal];
            // button.titleLabel.font = kFont16;
            button.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
            //Customzied TitleColor..
            [button setTitleColor:[UIColor colorWithHexString:@"#424242"]  forState:UIControlStateNormal];
        }
        [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:button];
        _currentButton = button;

        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:view];
    }
    return _currentButton;
}


@end
