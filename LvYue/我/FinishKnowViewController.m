//
//  FinishKnowViewController.m
//  LvYue
//
//  Created by 广有射怪鸟事 on 15/10/4.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import "FinishKnowViewController.h"

@interface FinishKnowViewController ()

@end

@implementation FinishKnowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationController setNavigationBarHidden:NO];
    
    [self setLeftButton:nil title:@"返回" target:self action:@selector(backAction)];
    [self setRightButton:nil title:@"确定" target:self action:@selector(backAction)];
    self.title = @"认证";
    
    UILabel *okLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, kMainScreenWidth, 20)];
    okLabel.text = @"认证完成！我们将尽快为您核实";
    okLabel.font = [UIFont systemFontOfSize:14.0];
    okLabel.textAlignment = NSTextAlignmentCenter;
    okLabel.textColor = RGBACOLOR(167, 167, 167, 1);
    [self.view addSubview:okLabel];
    
    UILabel *wishLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 170, kMainScreenWidth, 30)];
    wishLabel.text = @"趣陪祝愿您能遇到志趣相投的朋友！";
    wishLabel.textAlignment = NSTextAlignmentCenter;
    wishLabel.textColor = [UIColor blackColor];
    [self.view addSubview:wishLabel];
    
    UILabel *reLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 200, kMainScreenWidth, 30)];
    reLabel.textAlignment = NSTextAlignmentCenter;
    reLabel.font = [UIFont systemFontOfSize:14.0];
    reLabel.text = @"请保证最新的认证状态";
    reLabel.textColor = [UIColor grayColor];
    [self.view addSubview:reLabel];
    
}

- (void)backAction{
    [self.navigationController popToViewController:self.navigationController.viewControllers[1] animated:YES];
//    NSArray *array = [self.navigationController viewControllers];
//    [self.navigationController popToViewController:array[1] animated:YES];
//    NSDictionary *dict;
//    if (self.edu) {
//        dict = @{@"edu":self.edu};
//    }
//    if (self.car) {
//        dict = @{@"car":self.car};
//    }
//    if (self.iden) {
//        dict = @{@"iden":self.iden};
//    }
//    if (self.video) {
//        dict = @{@"video":self.video};
//    }
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"knowChange" object:nil userInfo:dict];
}


@end
