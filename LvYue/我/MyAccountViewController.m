//
//  MyAccountViewController.m
//  LvYue
//
//  Created by 郑洲 on 16/3/17.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "MyAccountViewController.h"
#import "WithDrawViewController.h"
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "MBProgressHUD+NJ.h"
#import "WalletDetailViewController.h"
#import "WithDrawRedNumViewController.h"
#import "VipInfoViewController.h"
#import "MyInfoModel.h"
#import "WhatsRedViewController.h"
#import "GetRedBeanViewController.h"
#import "BuyCoinViewController.h"
#import "BuyRedBeanViewController.h"
#import "UIView+KFFrame.h"

@interface MyAccountViewController ()

//@property (weak, nonatomic) IBOutlet UILabel *allMoneyLabel;            //金币
//@property (weak, nonatomic) IBOutlet UILabel *withDrawingLabel;         //提现中
//@property (weak, nonatomic) IBOutlet UILabel *noWithDrawLabel;          //未提现
//@property (weak, nonatomic) IBOutlet UIButton *exchangeMoneyBtn;        //充值按钮
//@property (weak, nonatomic) IBOutlet UIButton *withDrawingBtn;          //提现按钮
//@property (weak, nonatomic) IBOutlet UIButton *buyVipBtn;               //买会员
//@property (weak, nonatomic) IBOutlet UILabel *withDrawingLabelTitle;    //提现中文字
//@property (weak, nonatomic) IBOutlet UILabel *withDrawLabelTitle;       //未提现文字
//@property (weak, nonatomic) IBOutlet UIView *centerLine;                //中间线
//@property (weak, nonatomic) IBOutlet UILabel *centerLabel;              //充值与提现的分割线
//@property (nonatomic, strong) UIButton* aboutCoinBtn;                   //关于金币
//@property (nonatomic, strong) UIButton* shareGetCoinBtn;                //分享邀请码获取金币
//@property (nonatomic, copy) NSString* coinNum;                          //未提现金币数
@property (strong, nonatomic) UILabel *allMoneyLabel;            //金币
@property (strong, nonatomic) UILabel *withDrawingLabel;         //提现中
@property (strong, nonatomic) UILabel *noWithDrawLabel;          //未提现
@property (strong, nonatomic) UIButton *exchangeMoneyBtn;        //充值按钮
@property (strong, nonatomic) UIButton *withDrawingBtn;          //提现按钮
@property (strong, nonatomic) UIButton *buyVipBtn;               //买会员
@property (strong, nonatomic) UILabel *withDrawingLabelTitle;    //提现中文字
@property (strong, nonatomic) UILabel *withDrawLabelTitle;       //未提现文字
@property (strong, nonatomic) UIView *centerLine;                //中间线
@property (strong, nonatomic) UILabel *centerLabel;              //充值与提现的分割线
@property (nonatomic, strong) UIButton* aboutCoinBtn;            //关于金币
@property (nonatomic, strong) UIButton* shareGetCoinBtn;         //分享邀请码获取金币
@property (nonatomic, copy) NSString* coinNum;                   //未提现金币数


@end

@implementation MyAccountViewController
//初始状态
- (void)setUI {
    UIScrollView* scrollView = [[UIScrollView alloc] init];
    scrollView.x = 0;
    scrollView.y = 0;
    scrollView.width = kMainScreenWidth;
    scrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:scrollView];
    
    self.view.backgroundColor = RGBACOLOR(241, 240, 246, 1);
    //1.设置钱包图片
    UIImageView* walletImageView =[[UIImageView alloc] init];
    walletImageView.image = [UIImage imageNamed:@"大钱包"];
    walletImageView.width = 131;
    walletImageView.height = 99;
    walletImageView.centerX = self.view.centerX;
    walletImageView.y = 20 + 64;
    [scrollView addSubview:walletImageView];
    
    //金币文字
    static NSInteger margin = 10;
    UILabel* coinTitlerLabel = [[UILabel alloc] init];
    coinTitlerLabel.x = 0;
    coinTitlerLabel.y =  CGRectGetMaxY(walletImageView.frame) + 2*margin;
    coinTitlerLabel.width = kMainScreenWidth;
    coinTitlerLabel.height = 30;
//    coinTitlerLabel.backgroundColor = [UIColor redColor];
    coinTitlerLabel.text = @"金币";
    coinTitlerLabel.textAlignment = NSTextAlignmentCenter;
    [scrollView addSubview:coinTitlerLabel];
    
    //金币数
    self.allMoneyLabel = [[UILabel alloc] init];
    _allMoneyLabel.width = coinTitlerLabel.width;
    _allMoneyLabel.height = coinTitlerLabel.height;
    _allMoneyLabel.x = coinTitlerLabel.x;
    _allMoneyLabel.y = CGRectGetMaxY(coinTitlerLabel.frame) + margin;
//    _allMoneyLabel.backgroundColor = [UIColor redColor];
    _allMoneyLabel.textAlignment = NSTextAlignmentCenter;
    [scrollView addSubview:_allMoneyLabel];
    
    
    //未提现标题
    self.withDrawLabelTitle = [[UILabel alloc] init];
    _withDrawLabelTitle.x = margin;
    _withDrawLabelTitle.y = CGRectGetMaxY(_allMoneyLabel.frame) + 3*margin;
    self.withDrawLabelTitle.width = kMainScreenWidth - 2*10;
    //_withDrawLabelTitle.width = kMainScreenWidth * 0.5 - margin*2;
    _withDrawLabelTitle.height =  _allMoneyLabel.height;
//    _withDrawLabelTitle.backgroundColor = [UIColor redColor];
    self.withDrawLabelTitle.text = @"剩余";
    //_withDrawLabelTitle.text = @"未提现";
    _withDrawLabelTitle.textAlignment = NSTextAlignmentCenter;
    [scrollView addSubview:_withDrawLabelTitle];
    
    //未提现金币
    self.noWithDrawLabel = [[UILabel alloc] init];
    _noWithDrawLabel.height =  _allMoneyLabel.height;
    self.noWithDrawLabel.width = self.withDrawLabelTitle.width;
    //_noWithDrawLabel.width = kMainScreenWidth * 0.5 - margin*2;
    _noWithDrawLabel.x = _withDrawLabelTitle.x;
    _noWithDrawLabel.y = CGRectGetMaxY(_withDrawLabelTitle.frame) + margin;
//    _noWithDrawLabel.backgroundColor = [UIColor redColor];
    _noWithDrawLabel.textAlignment = NSTextAlignmentCenter;
    [scrollView addSubview:_noWithDrawLabel];
    
    //提现中标题
    self.withDrawingLabelTitle = [[UILabel alloc] init];
    _withDrawingLabelTitle.x = kMainScreenWidth * 0.5+margin;
    _withDrawingLabelTitle.y = _withDrawLabelTitle.y;
    _withDrawingLabelTitle.width = kMainScreenWidth * 0.5 - margin*2;
    _withDrawingLabelTitle.height =  _withDrawLabelTitle.height;
//    _withDrawingLabelTitle.backgroundColor = [UIColor redColor];
    _withDrawingLabelTitle.text = @"提现中";
    _withDrawingLabelTitle.textAlignment = NSTextAlignmentCenter;
    self.withDrawingLabelTitle.hidden = YES;
    [scrollView addSubview:_withDrawingLabelTitle];
    
    //提现中金币
    self.withDrawingLabel = [[UILabel alloc] init];
    _withDrawingLabel.centerX = _withDrawingLabelTitle.x;
    _withDrawingLabel.y = _noWithDrawLabel.y;
    _withDrawingLabel.width = _withDrawingLabelTitle.width;
    _withDrawingLabel.height =  _noWithDrawLabel.height;
//    _withDrawingLabel.backgroundColor = [UIColor redColor];
    _withDrawingLabel.textAlignment = NSTextAlignmentCenter;
    self.withDrawingLabel.hidden = YES;
    [scrollView addSubview:_withDrawingLabel];
    
    //中间竖线
    self.centerLine = [[UILabel alloc] init];
    self.centerLine.centerX = kMainScreenWidth*0.5;
    self.centerLine.y = _withDrawLabelTitle.y;
    self.centerLine.width = 1;
    self.centerLine.height = CGRectGetMaxY(_withDrawingLabel.frame) - _withDrawingLabelTitle.y;
    self.centerLine.backgroundColor = [UIColor blackColor];
    self.centerLine.hidden = YES;
    [scrollView addSubview:self.centerLine];
    
    //金币充值按钮
    self.exchangeMoneyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.exchangeMoneyBtn.x = _noWithDrawLabel.x;
    self.exchangeMoneyBtn.y = CGRectGetMaxY(_withDrawingLabel.frame) + margin;
    //self.exchangeMoneyBtn.width = _withDrawingLabel.width;
    self.exchangeMoneyBtn.width = self.withDrawLabelTitle.width;
    self.exchangeMoneyBtn.height = 44;
    self.exchangeMoneyBtn.backgroundColor = THEME_COLOR;
    [self.exchangeMoneyBtn setTitle:@"充值" forState:UIControlStateNormal];
    [self.exchangeMoneyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.exchangeMoneyBtn addTarget:self action:@selector(buyCoinClick:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:self.exchangeMoneyBtn];
    
    //金币提现按钮
    self.withDrawingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.withDrawingBtn.x = _withDrawingLabel.x;
    self.withDrawingBtn.y = CGRectGetMaxY(_withDrawingLabel.frame) + margin;
    self.withDrawingBtn.width = _withDrawingLabel.width;
    self.withDrawingBtn.height = 44;
    self.withDrawingBtn.backgroundColor = THEME_COLOR;
    [self.withDrawingBtn setTitle:@"提现" forState:UIControlStateNormal];
    [self.withDrawingBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.withDrawingBtn addTarget:self action:@selector(withDrawMoney:) forControlEvents:UIControlEventTouchUpInside];
    self.withDrawingBtn.hidden = YES;
    [scrollView addSubview:self.withDrawingBtn];
    
    //购买会员按钮
    self.buyVipBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.buyVipBtn.x = self.exchangeMoneyBtn.x;
    self.buyVipBtn.y = CGRectGetMaxY(_withDrawingBtn.frame) + 4*margin;
    self.buyVipBtn.width = kMainScreenWidth - 2*margin;
    self.buyVipBtn.height = 44;
    [self.buyVipBtn setBackgroundColor:[UIColor whiteColor]];
    [self.buyVipBtn setTitle:@"成为会员" forState:UIControlStateNormal];
    
    //判断vip按钮
    if (self.myInfoModel.vip == 0) {//非会员
        [self.buyVipBtn setTitle:@"成为会员" forState:UIControlStateNormal];
    }
    else {//会员
        [self.buyVipBtn setTitle:@"VIP续费" forState:UIControlStateNormal];
    }
    
    [self.buyVipBtn setTitleColor:THEME_COLOR forState:UIControlStateNormal];
    [self.buyVipBtn addTarget:self action:@selector(buyVipClick:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:self.buyVipBtn];
    
    //关于金币
    self.aboutCoinBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.aboutCoinBtn.width = kMainScreenWidth * 0.5 - margin*2;
    self.aboutCoinBtn.height = 44;
    self.aboutCoinBtn.x = self.exchangeMoneyBtn.x;
    //self.aboutCoinBtn.y = kMainScreenHeight - self.aboutCoinBtn.height - 2*margin;
    self.aboutCoinBtn.y = CGRectGetMaxY(self.buyVipBtn.frame) + 80;
    [self.aboutCoinBtn setBackgroundColor:[UIColor clearColor]];
    [self.aboutCoinBtn setTitle:@"关于金币" forState:UIControlStateNormal];
    self.aboutCoinBtn.titleLabel.font = kFont14;
    [self.aboutCoinBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.aboutCoinBtn addTarget:self action:@selector(aboutCoin:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:self.aboutCoinBtn];
    
    //分享邀请码获取金币
    self.shareGetCoinBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.shareGetCoinBtn.x = self.withDrawingBtn.x;
    self.shareGetCoinBtn.y = self.aboutCoinBtn.y;
    self.shareGetCoinBtn.width = kMainScreenWidth*0.5 - 2*margin;
    self.shareGetCoinBtn.height = 44;
    [self.shareGetCoinBtn setBackgroundColor:[UIColor clearColor]];
    [self.shareGetCoinBtn setTitle:@"分享邀请码获取金币" forState:UIControlStateNormal];
    self.shareGetCoinBtn.titleLabel.font = kFont14;
    [self.shareGetCoinBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.shareGetCoinBtn addTarget:self action:@selector(shareGetCoin:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:self.shareGetCoinBtn];
    
    //scrollView.height = CGRectGetMaxY(self.aboutCoinBtn.frame) + 10;
    scrollView.height = kMainScreenHeight;
    
    // 设置内容大小
    scrollView.contentSize = CGSizeMake(kMainScreenWidth, CGRectGetMaxY(self.aboutCoinBtn.frame) + 30);
    // 是否反弹
    scrollView.bounces = YES;
    
}


- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"个人账户";
    self.view.backgroundColor = RGBACOLOR(247, 247, 247, 1);
    [self getUserInfo];
    [self setState];
    
    [self setUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getUserInfo) name:@"refreshAccount" object:nil];
    
    /**
     *  @author KF, 16-07-19 17:07:19
     *
     *  @brief 钱包明细
     */
    [self setRightButton:[UIImage imageNamed:@"明细"] title:nil target:self action:@selector(push)];

}

//钱包push
- (void)push {
    WalletDetailViewController* vc = [[WalletDetailViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)setState {
    
    /**
     *  @property (weak, nonatomic) IBOutlet UILabel *allMoneyLabel;        //金币
     @property (weak, nonatomic) IBOutlet UILabel *withDrawingLabel;     //提现中
     @property (weak, nonatomic) IBOutlet UILabel *noWithDrawLabel;      //未提现
     @property (weak, nonatomic) IBOutlet UIButton *exchangeMoneyBtn;    //充值按钮
     @property (weak, nonatomic) IBOutlet UIButton *withDrawingBtn;      //提现按钮
     @property (weak, nonatomic) IBOutlet UIButton *buyVipBtn;           //买会员
        
     @property (weak, nonatomic) IBOutlet UILabel *withDrawingLabelTitle; //提现中标题
     
     @property (weak, nonatomic) IBOutlet UILabel *withDrawLabelTitle;     //未体现标题
     @property (weak, nonatomic) IBOutlet UIView *centerLine;              //竖线
     */
    
    //判断，若用户提现中数值为0，则隐藏
    self.withDrawingLabelTitle.hidden = NO;
    self.withDrawingLabel.hidden = NO;
    
    self.withDrawingBtn.hidden = NO;
    self.centerLine.hidden = NO;
//    if ([_withDrawingLabel.text isEqualToString:@"0"]) {
//        self.withDrawingLabelTitle.hidden = YES;
//        self.withDrawingLabel.hidden = YES;
//        self.centerLine.hidden = YES;
//        self.withDrawingBtn.hidden = YES;
//    }
    self.withDrawingLabelTitle.hidden = YES;
    self.withDrawingLabel.hidden = YES;
    self.centerLine.hidden = YES;
    self.withDrawingBtn.hidden = YES;
    self.centerLabel.hidden = YES;
    
    //改变frame
    self.withDrawLabelTitle.x = (kMainScreenWidth - self.withDrawLabelTitle.width)*0.5;
    self.noWithDrawLabel.centerX = self.withDrawLabelTitle.centerX;
    CGFloat exchangeMoneyBtnWidth = 2 * self.exchangeMoneyBtn.width;
    self.exchangeMoneyBtn.width = exchangeMoneyBtnWidth;
    
    
}


//提现
- (void)withDrawMoney:(id)sender {
//    WithDrawRedNumViewController* withDrawVC = [[WithDrawRedNumViewController alloc] init];
//    WithDrawViewController *withDrawVC = [[WithDrawViewController alloc] init];
    WithDrawViewController* withDrawVC = [[WithDrawViewController alloc] init];
    withDrawVC.coinNum  = self.coinNum;
    [self.navigationController pushViewController:withDrawVC animated:YES];
}

//购买vip
- (void)buyVipClick:(UIButton *)sender {
    
    VipInfoViewController* vipInfo = [[VipInfoViewController alloc] init];
    vipInfo.coinNum  = self.coinNum;
    [self.navigationController pushViewController:vipInfo animated:YES];
    
}

//充值
- (void)buyCoinClick:(id)sender {
    BuyRedBeanViewController* vc = [[BuyRedBeanViewController alloc] init];
    //BuyCoinViewController* vc = [[BuyCoinViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

//关于金币
- (void)aboutCoin:(UIButton *)sender {
    WhatsRedViewController* vc = [[WhatsRedViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

//热门
- (void)shareGetCoin:(id)sender {
    GetRedBeanViewController* vc = [[GetRedBeanViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}


//获取个人信息
- (void)getUserInfo {
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/need/hongdou",REQUESTHEADER] andParameter:@{@"user_id":[LYUserService sharedInstance].userID} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            
            NSString* noWithDrawStr = [NSString stringWithFormat:@"%@",successResponse[@"data"][@"data"][@"hongdou"]];
            _noWithDrawLabel.text = noWithDrawStr;
            
            NSString* withDrawStr = [NSString stringWithFormat:@"%@",successResponse[@"data"][@"data"][@"tixian"]];
            _withDrawingLabel.text = withDrawStr;
            
            //判断，若用户提现中数值为0，则隐藏提现
            if (![_withDrawingLabel.text isEqualToString:@"0"]) {
                self.withDrawingLabelTitle.hidden = NO;
                self.withDrawingLabel.hidden = NO;
                self.centerLine.hidden = NO;
                self.withDrawingBtn.hidden = NO;
                
//                self.withDrawLabelTitle.text = @"剩余";
//                self.withDrawLabelTitle.width = kMainScreenWidth - 2*10;
//                self.noWithDrawLabel.width = self.withDrawLabelTitle.width;
//                self.exchangeMoneyBtn.width = self.withDrawLabelTitle.width;
                
                
                //不等于0
                _withDrawLabelTitle.text = @"未提现";
                _withDrawLabelTitle.width = kMainScreenWidth * 0.5 - 10*2;
                _noWithDrawLabel.width = kMainScreenWidth * 0.5 - 10*2;
                self.exchangeMoneyBtn.width = _withDrawLabelTitle.width;
            }
   
            _allMoneyLabel.text = [NSString stringWithFormat:@"%ld",noWithDrawStr.integerValue + withDrawStr.integerValue];
            self.coinNum = noWithDrawStr;
        } else {
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
