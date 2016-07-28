//
//  SubscriptionViewController.m
//  LvYue
//
//  Created by 广有射怪鸟事 on 15/10/19.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import "SubscriptionViewController.h"
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "MBProgressHUD+NJ.h"
#import "AFNetworking.h"

@interface SubscriptionViewController ()<UIWebViewDelegate>

@property (nonatomic,strong) UIView *controlView;
@property (nonatomic,strong) UIWebView *web;

@end

@implementation SubscriptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"资讯";
    [self getDataFromWeb];
    
    [self setLeftButton:[UIImage imageNamed:@"back"] title:nil target:self action:@selector(back:)];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeHomeFrame" object:nil];
    
}

- (void)getDataFromWeb{
    
    self.web = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight - 44)];
    self.web.scalesPageToFit = YES;
    self.web.delegate = self;
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/assets/news",REQUESTHEADER]]];
    [self.web loadRequest:request];
    [self.view addSubview:self.web];
    
    self.controlView = [[UIView alloc] initWithFrame:CGRectMake(0, kMainScreenHeight - 44, kMainScreenWidth, 44)];
    self.controlView.backgroundColor = [UIColor whiteColor];
    self.controlView.layer.borderWidth = 0.5;
    
    UIButton *refresh = [[UIButton alloc] initWithFrame:CGRectMake(kMainScreenWidth - 50, 10, 40, 30)];
    [refresh setTitle:@"刷新" forState:UIControlStateNormal];
    [refresh addTarget:self action:@selector(refreshAction) forControlEvents:UIControlEventTouchUpInside];
    [refresh setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.controlView addSubview:refresh];
    [self.view addSubview:self.controlView];

}

- (void)back:(UIButton *)btn{
    NSString *urlString = [NSString stringWithFormat:@"%@",self.web.request.URL];
    NSString *home = [NSString stringWithFormat:@"%@/assets/news",REQUESTHEADER];
    if ([urlString isEqualToString:home]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        [self.web goBack];
    }
}

- (void)refreshAction{
    [self.web reload];
}


@end
