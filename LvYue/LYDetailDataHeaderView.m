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
@property (weak, nonatomic) IBOutlet UIView *valideIconView;
@property (weak, nonatomic) IBOutlet UILabel *meiLiValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *fansValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *caiFuValueLabel;

@property (weak, nonatomic) IBOutlet UIView *fouceOnAndSendGiftView;
@property (weak, nonatomic) IBOutlet UIButton *foucsOnButton;
@property (weak, nonatomic) IBOutlet UIButton *sendGiftButton;


@end

@implementation LYDetailDataHeaderView

- (void)awakeFromNib {
    [super awakeFromNib];

    self.avatarImageView.layer.cornerRadius  = 5.f;
    self.avatarImageView.layer.masksToBounds = YES;

    UITapGestureRecognizer *tap                 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAvatarImageView:)];
    self.avatarImageView.userInteractionEnabled = YES;
    [self.avatarImageView addGestureRecognizer:tap];
}

- (void)configData:(MyInfoModel *)infoModel mySelf:(BOOL)mySelf {

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

    if (mySelf) {
        self.fouceOnAndSendGiftView.hidden = YES;
    }

    // 已关注
    if (infoModel.isFocus) {
        [self.foucsOnButton setTitle:@"取消关注" forState:UIControlStateNormal];
    } else {
        [self.foucsOnButton setTitle:@"关注 TA" forState:UIControlStateNormal];
    }

    NSInteger flag = 0;

    // 车辆认证
    if (infoModel.auth_car == 2) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"car"]];
        imageView.frame        = CGRectMake(CGRectGetWidth(self.valideIconView.frame) - 15 - 20 * flag, 0, 15.f, 15.f);
        [self.valideIconView addSubview:imageView];
        flag++;
    }
    // 教育认证
    if (infoModel.auth_edu == 2) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"xue"]];
        imageView.frame        = CGRectMake(CGRectGetWidth(self.valideIconView.frame) - 15 - 20 * flag, 0, 15.f, 15.f);
        [self.valideIconView addSubview:imageView];
        flag++;
    }
    // 身份认证
    if (infoModel.auth_identity == 2) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"zhen"]];
        imageView.frame        = CGRectMake(CGRectGetWidth(self.valideIconView.frame) - 15 - 20 * flag, 0, 15.f, 15.f);
        [self.valideIconView addSubview:imageView];
        flag++;
    }
    // 性别
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:(infoModel.sex == 0 ? @"男" : @"女")]];
    imageView.frame        = CGRectMake(CGRectGetWidth(self.valideIconView.frame) - 15 - 20 * flag, 0, 15.f, 15.f);
    [self.valideIconView addSubview:imageView];
    flag++;
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

// 点击头像
- (void)tapAvatarImageView:(UITapGestureRecognizer *)sender {
    if (self.tapAvatarImageViewBlock) {
        self.tapAvatarImageViewBlock(self.avatarImageView);
    }
}

@end
