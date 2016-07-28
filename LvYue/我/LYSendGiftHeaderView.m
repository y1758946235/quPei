
//
//  LYSendGiftHeaderView.m
//  LvYue
//
//  Created by KentonYu on 16/7/27.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "LYSendGiftHeaderView.h"

@interface LYSendGiftHeaderView ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *coinLabel;
@property (weak, nonatomic) IBOutlet UIButton *getCoinLabel;


@end

@implementation LYSendGiftHeaderView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.avatarImageView.layer.cornerRadius  = 10.f;
    self.avatarImageView.layer.masksToBounds = YES;

    self.getCoinLabel.layer.cornerRadius  = 5.f;
    self.getCoinLabel.layer.masksToBounds = YES;
}

@end
