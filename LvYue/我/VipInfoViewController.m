//
//  VipInfoViewController.m
//  LvYue
//
//  Created by 广有射怪鸟事 on 15/10/7.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import "VipInfoViewController.h"
#import "BuyVipViewController.h"
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "MBProgressHUD+NJ.h"
#import "UIView+SZYOperation.h"

@interface VipInfoViewController ()<UIAlertViewDelegate>

@property (nonatomic,strong) UILabel *whatMore;
@property (nonatomic,strong) UILabel *howMore;
@property (nonatomic,strong) UILabel *whenMore;

@property (nonatomic,strong) NSString *vip_price;
@property (nonatomic,strong) NSString *vip_year_price;
@property (nonatomic,strong) NSString *vip_benefit;//会员好处
@property (nonatomic,strong) NSString *vip_method;//方法
@property (nonatomic,strong) NSString *isVip;//是否是 vip
@property (nonatomic,strong) NSString *vipTime;//vip 到期时间
@property (nonatomic,assign) BOOL isShow;

@end

@implementation VipInfoViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"会员说明";
    
    [self getDataFromWeb];
}

#pragma mark 网络请求

- (void)getDataFromWeb{
    [MBProgressHUD showMessage:nil toView:self.view];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/vipPrice",REQUESTHEADER] andParameter:@{} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            NSString *vip_price = successResponse[@"data"][@"vip_price"];
            NSString *vip_year_price = successResponse[@"data"][@"vip_year_price"];
            NSString *vip_benefit = successResponse[@"data"][@"vip_benefit"];
            NSString *vip_method = successResponse[@"data"][@"vip_method"];
            self.vip_price = vip_price;
            self.vip_year_price = vip_year_price;
            self.vip_benefit = vip_benefit;
            self.vip_method = vip_method;
            if (![vip_method isEqualToString:@""]) {
                [self createView];
            }
            if ([successResponse[@"data"][@"vip_status"] integerValue] == 0) {  //非会员
                _isShow = NO;
            }else {  //会员
                _isShow = YES;
            }
        } else {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
            
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
}

//创建view
- (void)createView{
    
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight)];
    scroll.contentSize = CGSizeMake(0, kMainScreenHeight);
    scroll.userInteractionEnabled = YES;
    [self.view addSubview:scroll];
    
    UIImageView *quitImg = [[UIImageView alloc] initWithFrame:CGRectMake(20, 50, 15, 15)];
    quitImg.image = [UIImage imageNamed:@"拍"];
    [scroll addSubview:quitImg];
    
    UILabel *what = [[UILabel alloc] initWithFrame:CGRectMake(40, 45, 200, 30)];
    what.text = @"成为会员有什么好处?";
    what.font = [UIFont systemFontOfSize:16.0];
    what.textColor = RGBACOLOR(174, 174, 174, 1);
    [scroll addSubview:what];
    
    self.whatMore = [[UILabel alloc] initWithFrame:CGRectMake(40, 80, kMainScreenWidth - 50, 100)];
    self.whatMore.numberOfLines = 0;
    self.whatMore.text = self.vip_benefit;
    self.whatMore.textColor = [UIColor blackColor];
    self.whatMore.font = [UIFont systemFontOfSize:14.0];
    CGSize size = [self.whatMore sizeThatFits:CGSizeMake(self.whatMore.frame.size.width, MAXFLOAT)];
    self.whatMore.frame = CGRectMake(40, 80, kMainScreenWidth - 50, size.height);
    [scroll addSubview:self.whatMore];
    
    UIImageView *quit1 = [[UIImageView alloc] initWithFrame:CGRectMake(20, self.whatMore.frame.origin.y + self.whatMore.frame.size.height + 20, 15, 15)];
    quit1.image = [UIImage imageNamed:@"拍"];
    [scroll addSubview:quit1];
    
    UILabel *how = [[UILabel alloc] initWithFrame:CGRectMake(40, quit1.frame.origin.y - 5, 200, 30)];
    how.text = @"如何成为会员?";
    how.font = [UIFont systemFontOfSize:16.0];
    how.textColor = RGBACOLOR(174, 174, 174, 1);
    [scroll addSubview:how];
    
    self.howMore = [[UILabel alloc] initWithFrame:CGRectMake(40, how.frame.origin.y + 20, kMainScreenWidth - 50, 30)];
    self.howMore.numberOfLines = 0;
    self.howMore.text = self.vip_method;
    self.howMore.textColor = [UIColor blackColor];
    self.howMore.font = [UIFont systemFontOfSize:14.0];
    CGSize hsize = [self.whatMore sizeThatFits:CGSizeMake(self.howMore.frame.size.width, MAXFLOAT)];
    self.howMore.frame = CGRectMake(40, how.frame.origin.y + 20, kMainScreenWidth - 50, hsize.height);
    [scroll addSubview:self.howMore];
    
    UIImageView *quit2 = [[UIImageView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(self.howMore.frame) + 10, 15, 15)];
    quit2.image = [UIImage imageNamed:@"拍"];
    [scroll addSubview:quit2];
    
    UILabel *when = [[UILabel alloc] initWithFrame:CGRectMake(40, quit2.frame.origin.y - 5, 200, 30)];
    when.text = @"会员期限是多少?";
    when.font = [UIFont systemFontOfSize:16.0];
    when.textColor = RGBACOLOR(174, 174, 174, 1);
    [scroll addSubview:when];
    
    self.whenMore = [[UILabel alloc] initWithFrame:CGRectMake(40, when.frame.origin.y + 40, kMainScreenWidth - 50, 30)];
    NSString *half = [NSString stringWithFormat:@"%ld",[self.vip_price integerValue] * 6];
    self.whenMore.text = [NSString stringWithFormat:@"￥%@/月 ￥%@/半年 ￥%@/年",self.vip_price,half,self.vip_year_price];
    self.whenMore.font = [UIFont systemFontOfSize:14.0];
    [scroll addSubview:self.whenMore];
    
    
    UIButton *buyBtn = [[UIButton alloc] init];
    buyBtn.frame = CGRectMake(30, CGRectGetMaxY(self.whenMore.frame) + 20, kMainScreenWidth - 60, 44);
    [buyBtn setTitle:@"成为会员" forState:UIControlStateNormal];
    [buyBtn setBackgroundColor:[UIColor colorWithRed:29/255.0 green:189/255.0 blue:159/255.0 alpha:1]];
    [buyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [buyBtn.layer setCornerRadius:4];
    [buyBtn addTarget:self action:@selector(buyVip) forControlEvents:UIControlEventTouchUpInside];
    [scroll addSubview:buyBtn];
}

//购买vip
- (void)buyVip{
    [MBProgressHUD showMessage:nil toView:self.view];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/getDetailInfo",REQUESTHEADER] andParameter:@{@"id":[NSString stringWithFormat:@"%@",[LYUserService sharedInstance].userID]} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            self.isVip = [NSString stringWithFormat:@"%@",successResponse[@"data"][@"user"][@"vip"]];
            self.vipTime = [NSString stringWithFormat:@"%@",successResponse[@"data"][@"userDetail"][@"vip_time"]];
            if ([self.isVip integerValue] == 1) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"您的会员到期时间为%@,确定续费吗?",self.vipTime] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                [alert show];
            }
            else{
                BuyVipViewController *buyVip = [[BuyVipViewController alloc] init];
                buyVip.coinNum = self.coinNum;
                buyVip.vip_price = self.vip_price;
                buyVip.vip_year_price = self.vip_year_price;
                buyVip.isShow = _isShow;
                [self.navigationController pushViewController:buyVip animated:YES];
            }
        } else {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
    
}

#pragma mark - alertView

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        BuyVipViewController *buyVip = [[BuyVipViewController alloc] init];
        buyVip.coinNum = self.coinNum;
        buyVip.vip_price = self.vip_price;
        buyVip.vip_year_price = self.vip_year_price;
        buyVip.isShow = _isShow;
        [self.navigationController pushViewController:buyVip animated:YES];
    }
}

@end
