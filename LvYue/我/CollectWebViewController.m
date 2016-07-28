//
//  CollectWebViewController.m
//  LvYue
//
//  Created by 广有射怪鸟事 on 15/10/14.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import "CollectWebViewController.h"

@interface CollectWebViewController ()

@end

@implementation CollectWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIWebView *web = [[UIWebView alloc] initWithFrame:self.view.frame];
    NSURL *url = [NSURL URLWithString:self.url];
    
    // 判断有没有协议头，没有的话拼接
    if (!url.scheme || [url.scheme isEqualToString:@""]) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", self.url]];
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [web loadRequest:request];
    [self.view addSubview:web];
}


@end
