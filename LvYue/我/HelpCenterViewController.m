//
//  HelpCenterViewController.m
//  LvYue
//
//  Created by 广有射怪鸟事 on 15/10/10.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import "HelpCenterViewController.h"
#import "LYHttpPoster.h"
#import "MBProgressHUD+NJ.h"


@interface HelpCenterViewController ()

@property (nonatomic,strong) UIWebView *web;

@end

@implementation HelpCenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"帮助中心";
    
    [self setLeftButton:[UIImage imageNamed:@"back"] title:nil target:self action:@selector(back:)];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeHomeFrame" object:nil];
    
    self.web = [[UIWebView alloc] init];
    self.web.frame = CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight);
    [self.web scalesPageToFit];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/assets/index",REQUESTHEADER]]];
    [self.web loadRequest:request];
    [self.view addSubview:self.web];
    
    
}

- (void)back:(UIButton *)btn{
    NSString *urlString = [NSString stringWithFormat:@"%@",self.web.request.URL];
    NSString *home = [NSString stringWithFormat:@"%@/assets/index",REQUESTHEADER];
    if ([urlString isEqualToString:home]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        [self.web goBack];
    }
}

@end
