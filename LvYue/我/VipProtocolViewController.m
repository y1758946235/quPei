//
//  VipProtocolViewController.m
//  LvYue
//
//  Created by 広有射怪鸟事 on 16/1/9.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "VipProtocolViewController.h"

@interface VipProtocolViewController ()

@end

@implementation VipProtocolViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"会员协议";
    
    UIWebView *web = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight)];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/assets/vipagree",REQUESTHEADER]]];
    [web loadRequest:request];
    [self.view addSubview:web];
    
}

@end
