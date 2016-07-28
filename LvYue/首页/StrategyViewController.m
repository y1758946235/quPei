//
//  StrategyViewController.m
//  LvYue
//
//  Created by 广有射怪鸟事 on 15/10/19.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import "StrategyViewController.h"
#import "UMSocial.h"

@interface StrategyViewController ()<UMSocialUIDelegate>

@property (nonatomic,strong) UIWebView *web;
@property (nonatomic,strong) UIView *controlView;

@end

@implementation StrategyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setRightButton:nil title:@"分享" target:self action:@selector(shareWebPage) rect:CGRectMake(0, 0, 44, 44)];
//    [self setLeftButton:[UIImage imageNamed:@"back"] title:nil target:self action:@selector(back:)];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeHomeFrame" object:nil];
    
    self.title = @"旅游攻略";
    [self getDataFromWeb];
}

- (void)getDataFromWeb{
    
    self.web = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight - 44)];
    self.web.scalesPageToFit = YES;
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/assets/strategy",REQUESTHEADER]]];
    [self.web loadRequest:request];
    self.web.userInteractionEnabled = YES;
    [self.view addSubview:self.web];
    
    self.controlView = [[UIView alloc] initWithFrame:CGRectMake(0, kMainScreenHeight - 44, kMainScreenWidth, 44)];
    self.controlView.userInteractionEnabled = YES;
    self.controlView.backgroundColor = [UIColor whiteColor];
    
    UIButton *refresh = [[UIButton alloc] initWithFrame:CGRectMake(kMainScreenWidth - 50, 10, 40, 30)];
    [refresh setTitle:@"刷新" forState:UIControlStateNormal];
    [refresh addTarget:self action:@selector(webRefreshAction) forControlEvents:UIControlEventTouchUpInside];
    [refresh setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.controlView addSubview:refresh];
    
    [self.view addSubview:self.controlView];
}

- (void)back:(UIButton *)btn{
    NSString *urlString = [NSString stringWithFormat:@"%@",self.web.request.URL];
    NSString *home = [NSString stringWithFormat:@"%@/assets/strategy",REQUESTHEADER];
    if ([urlString isEqualToString:home]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        [self.web goBack];
    }
}

- (void)webBackAction{
    [self.web goBack];
}

- (void)webRefreshAction{
    [self.web reload];
}

#pragma mark - 分享
- (void)shareWebPage {
    NSString *currentAddress = [self.web.request.URL absoluteString];
    //设置微信
    [UMSocialData defaultData].extConfig.wechatSessionData.title = @"豆客，出售您的空余时间，向导大家旅行、寻找美食、搭伴健身..除了能带给您经济收入外，互动的过程还能互相深入了解，交到真正、合适的各方朋友，他、她正在豆客等您..";
    [UMSocialData defaultData].extConfig.wechatTimelineData.title = @"豆客，出售您的空余时间，向导大家旅行、寻找美食、搭伴健身..除了能带给您经济收入外，互动的过程还能互相深入了解，交到真正、合适的各方朋友，他、她正在豆客等您..";
    [UMSocialData defaultData].extConfig.wechatSessionData.url = currentAddress;
    [UMSocialData defaultData].extConfig.wechatTimelineData.url = currentAddress;
    
    //设置新浪微博
    [[UMSocialData defaultData].urlResource setResourceType:UMSocialUrlResourceTypeImage url:currentAddress];
    
    
    //设置QQ
    [UMSocialData defaultData].extConfig.qqData.title = @"豆客，出售您的空余时间，向导大家旅行、寻找美食、搭伴健身..除了能带给您经济收入外，互动的过程还能互相深入了解，交到真正、合适的各方朋友，他、她正在豆客等您..";
    [UMSocialData defaultData].extConfig.qzoneData.title = @"豆客，出售您的空余时间，向导大家旅行、寻找美食、搭伴健身..除了能带给您经济收入外，互动的过程还能互相深入了解，交到真正、合适的各方朋友，他、她正在豆客等您..";
    [UMSocialData defaultData].extConfig.qqData.url = currentAddress;
    [UMSocialData defaultData].extConfig.qzoneData.url = currentAddress;
    
    //分享
    [UMSocialSnsService presentSnsIconSheetView:self appKey:@"55f3983c67e58e502a00167d" shareText:@"我分享了一篇攻略，快来看看吧~\n\n——尽在\"豆客\"APP" shareImage:[UIImage imageNamed:@"logo108"] shareToSnsNames:[NSArray arrayWithObjects:UMShareToWechatTimeline,UMShareToWechatSession,UMShareToSina,UMShareToQQ,UMShareToQzone,nil] delegate:self];
}


@end
