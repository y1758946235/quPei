//
//  AlterSendGiftCollectionReusableView.m
//  LvYue
//
//  Created by X@Han on 17/6/22.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "AlterSendGiftCollectionReusableView.h"
#import "MyAccountViewController.h"
@implementation AlterSendGiftCollectionReusableView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = RGBCOLOR(240, 239, 245);
        
        UILabel * coinLabe = [[UILabel alloc]init];
        coinLabe.frame  = CGRectMake(16, 0, 150, 40);
        coinLabe.font = [UIFont  systemFontOfSize:14];
        [self addSubview:coinLabe];
        self.coinLabel = coinLabe;
         self.coinLabel.text = @"账户余额：0金币";
        
        UIButton * getCoinBtn = [[UIButton alloc]init];
        getCoinBtn.frame  = CGRectMake(SCREEN_WIDTH-86, 10, 70, 20);
        [getCoinBtn setTitle:@"获取金币" forState:UIControlStateNormal];
        getCoinBtn.titleLabel.font =[UIFont  systemFontOfSize:14];
        [getCoinBtn setTitleColor:[UIColor colorWithHexString:@"#ff5252"] forState:UIControlStateNormal];
        getCoinBtn.layer.cornerRadius = 8;
        getCoinBtn.clipsToBounds = YES;
        getCoinBtn.layer.borderWidth = 1;
        getCoinBtn.layer.borderColor = [UIColor colorWithHexString:@"#ff5252"].CGColor;
//        [getCoinBtn addTarget:self action:@selector(getCoinClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:getCoinBtn];
        self.getCoinBtn = getCoinBtn;
    
    }
    return self;
}
//-(void)getCoinClick:(UIButton *)sender{
//    if (self.fetchCoinBlock) {
//        self.fetchCoinBlock(sender);
//    }
//}
- (void)configDataAccountAmount:(NSString *)accountAmount{
    if ([CommonTool dx_isNullOrNilWithObject:accountAmount] == YES) {
        accountAmount = @"0";
    }
    self.coinLabel.text =[NSString  stringWithFormat:@"账户余额：%@金币",accountAmount];
}
@end
