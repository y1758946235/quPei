//
//  LYMyAccountTableViewCell.m
//  LvYue
//
//  Created by KentonYu on 16/8/2.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "LYMyAccountTableViewCell.h"

@interface LYMyAccountTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIButton *fetchCoinButton;
@property (weak, nonatomic) IBOutlet UIImageView *rightArrowImageView;

@end

@implementation LYMyAccountTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.iconImageView.layer.cornerRadius  = 14.f;
    self.iconImageView.layer.masksToBounds = YES;

    self.fetchCoinButton.layer.cornerRadius  = 5.f;
    self.fetchCoinButton.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)configData:(LYMyAccountTableViewCellType)type coin:(NSString *)coin {
    switch (type) {
        case LYMyAccountTableViewCellTypeCoin: {
            self.selectionStyle                = UITableViewCellSelectionStyleNone;
            self.iconImageView.image           = [UIImage imageNamed:@"icon_coin"];
            NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"金币：%@", coin]];
            [attrStr addAttribute:NSForegroundColorAttributeName value:RGBCOLOR(210, 0, 5) range:NSMakeRange(3, coin.length)];
            self.contentLabel.attributedText = [attrStr copy];
            self.fetchCoinButton.hidden      = NO;
            self.rightArrowImageView.hidden  = YES;
            break;
        }
        case LYMyAccountTableViewCellWithDraw: {
            self.selectionStyle             = UITableViewCellSelectionStyleDefault;
            self.iconImageView.image        = [UIImage imageNamed:@"icon_withDraw"];
            self.contentLabel.text          = @"提现";
            self.fetchCoinButton.hidden     = YES;
            self.rightArrowImageView.hidden = NO;
            break;
        }
    }
}

- (IBAction)clickFetchCoinButton:(id)sender {
    if (self.fetchBlock) {
        self.fetchBlock(sender);
    }
}

@end
