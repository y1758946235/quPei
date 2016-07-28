//
//  WhatsRedViewController.m
//  LvYue
//
//  Created by 広有射怪鸟事 on 15/12/26.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import "WhatsRedViewController.h"
#import "MBProgressHUD+NJ.h"
#import "LYHttpPoster.h"

@interface WhatsRedViewController ()
{
    UITextView *introductText;
}

@end

@implementation WhatsRedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"什么是金币";
    
    UIWebView *web = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight)];
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/assets/hongdouforApple",REQUESTHEADER]]];
    [web loadRequest:request];
    [self.view addSubview:web];
    
}

@end
