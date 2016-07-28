//
//  LYDetailDataHeaderView.m
//  LvYue
//
//  Created by KentonYu on 16/7/22.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "LYDetailDataHeaderView.h"
#import "MyInfoModel.h"
#import "UIImageView+WebCache.h"

@interface LYDetailDataHeaderView ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UIImageView *vipImageView;
@property (weak, nonatomic) IBOutlet UIButton *playVideoButton;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *meiLiValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *fansValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *caiFuValueLabel;

@property (weak, nonatomic) IBOutlet UIButton *foucsOnButton;
@property (weak, nonatomic) IBOutlet UIButton *sendGiftButton;


@end

@implementation LYDetailDataHeaderView

- (void)awakeFromNib {
    [super awakeFromNib];

    self.avatarImageView.layer.cornerRadius  = 5.f;
    self.avatarImageView.layer.masksToBounds = YES;
}

- (void)configData:(MyInfoModel *)infoModel {

    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", IMAGEHEADER, infoModel.icon]] placeholderImage:[UIImage imageNamed:@"logo108"]];

    if (!infoModel.vip) {
        self.vipImageView.hidden = YES;
    }

    self.userNameLabel.text = infoModel.name;

    if (!infoModel.auth_video) {
        self.playVideoButton.hidden = YES;
    }

    self.meiLiValueLabel.text = [NSString stringWithFormat:@"%ld", (long) infoModel.charm];
    self.caiFuValueLabel.text = [NSString stringWithFormat:@"%ld", (long) infoModel.wealth];
    self.fansValueLabel.text  = [NSString stringWithFormat:@"%ld", (long) infoModel.fansNum];

    // 已关注
    if (infoModel.isFocus) {
        [self.foucsOnButton setTitle:@"取消关注" forState:UIControlStateNormal];
    } else {
        [self.foucsOnButton setTitle:@"关注 TA" forState:UIControlStateNormal];
    }
}

// 关注，取消关注
- (IBAction)clickFoucsOnButton:(id)sender {
    if (self.foucsOnButtonBlock) {
        self.foucsOnButtonBlock();
    }
}

// 送礼物
- (IBAction)clickSendGiftButton:(id)sender {
    if (self.sendGiftButtonBlock) {
        self.sendGiftButtonBlock();
    }
}

// 播放认证视频
- (IBAction)clickPlayVideoButton:(id)sender {
    if (self.playAuthVideoBlock) {
        self.playAuthVideoBlock();
    }
}

@end
