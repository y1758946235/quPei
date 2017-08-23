//
//  UserAgreeViewController.m
//  LvYue
//
//  Created by X@Han on 17/5/26.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "UserAgreeViewController.h"

@interface UserAgreeViewController ()

@end

@implementation UserAgreeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"用户协议";
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
    [self.view addSubview:webView];    //网络地址
    NSURL *url = [[NSURL alloc] initWithString:@"http://114.215.184.120:8088/mobile/vipagreement.html"];    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
