//
//  LYMyGiftViewController.m
//  LvYue
//
//  Created by KentonYu on 16/8/1.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "LYMyGiftViewController.h"

@interface LYMyGiftViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navBottomLineLeading;
@property (weak, nonatomic) IBOutlet UIView *navBottomLineView;

@property (weak, nonatomic) IBOutlet UILabel *wealthLabel;
@property (weak, nonatomic) IBOutlet UILabel *meiliLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation LYMyGiftViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //去navigation分割线
    // bg.png为自己ps出来的想要的背景颜色。
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigationBar"] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    //translucen透明度，NO不透明，控件的frame从navigationBar的左下角开始算；YES，透明从状态栏开始算。
    self.navigationController.navigationBar.translucent = NO;

    self.title = @"我的礼物";

    [self clickMyGiftButton:nil];
}

// 我收到的
- (IBAction)clickMyGiftButton:(id)sender {
    self.navBottomLineLeading.constant = (SCREEN_WIDTH / 2.f - 60.f) / 2.f;
    [UIView animateWithDuration:1.0f animations:^{
        [self.navBottomLineView layoutIfNeeded];
    }];
}

// 我送出的
- (IBAction)clickSendButton:(id)sender {
    self.navBottomLineLeading.constant = (SCREEN_WIDTH / 2.f - 60.f) / 2.f + SCREEN_WIDTH / 2.f;
    [UIView animateWithDuration:1.0f animations:^{
        [self.navBottomLineView layoutIfNeeded];
    }];
}


@end
