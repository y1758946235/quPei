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

@end

@implementation LYGetCoinHeaderView

- (void)setAccountAmount:(NSInteger)accountAmount {
    _accountAmount = accountAmount;

    self.accountAmountLabel.text = [NSString stringWithFormat:@"%d", accountAmount];
}

@end
