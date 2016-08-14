
//
//  LYSendGiftHeaderView.m
//  LvYue
//
//  Created by KentonYu on 16/7/27.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "LYSendGiftHeaderView.h"
#import "UIImageView+WebCache.h"

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

    if (![[[NSUserDefaults standardUserDefaults] valueForKey:@"ShowGetCoinKey"] boolValue]) {
        self.getCoinLabel.hidden = YES;
        return;
    }
    
    self.getCoinLabel.layer.cornerRadius  = 5.f;
    self.getCoinLabel.layer.masksToBounds = YES;
}

- (void)configData:(NSString *)userName avatarImageURL:(NSString *)avatarImageURL accountAmount:(NSString *)accountAmount {
    self.userNameLabel.text = userName;
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", IMAGEHEADER, avatarImageURL]] placeholderImage:[UIImage imageNamed:@"logo108"]];

    if (!accountAmount || accountAmount.length == 0) {
        accountAmount = @"加载中";
    }
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"余额:%@", accountAmount]];
    [attrStr addAttribute:NSForegroundColorAttributeName value:RGBCOLOR(17, 198, 173) range:NSMakeRange(3, accountAmount.length)];
    self.coinLabel.attributedText = [attrStr copy];
}

- (IBAction)clickGetCoinButton:(id)sender {
    if (self.fetchCoinBlock) {
        self.fetchCoinBlock(sender);
    }
}

@end
