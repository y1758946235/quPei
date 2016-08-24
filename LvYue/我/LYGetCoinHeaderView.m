//
//  LYGetCoinHeaderView.m
//  LvYue
//
//  Created by KentonYu on 16/8/2.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "LYGetCoinHeaderView.h"

@interface LYGetCoinHeaderView ()

@property (weak, nonatomic) IBOutlet UILabel *accountAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *desLabel;

@end

@implementation LYGetCoinHeaderView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"ShowGetCoinKey"] boolValue]) {
        self.desLabel.text = @"金币可用于升级VIP、购买礼物、购买服务等";
    }
}

- (void)setAccountAmount:(NSInteger)accountAmount {
    _accountAmount = accountAmount;

    self.accountAmountLabel.text = [NSString stringWithFormat:@"%d", accountAmount];
}

@end
