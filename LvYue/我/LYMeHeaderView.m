//
//  LYMeHeaderView.m
//  LvYue
//
//  Created by KentonYu on 16/7/22.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "LYMeHeaderView.h"
#import "MyDetailInfoModel.h"
#import "MyInfoModel.h"

#import "UIImageView+WebCache.h"

@interface LYMeHeaderView ()

@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UIControl *avatarControlView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *addressButton;
@property (weak, nonatomic) IBOutlet UILabel *focusOnLabel;
@property (weak, nonatomic) IBOutlet UILabel *fansLabel;
@property (weak, nonatomic) IBOutlet UIButton *genderAgeButton;


@end

@implementation LYMeHeaderView

- (void)awakeFromNib {
    [super awakeFromNib];

    self.avatarControlView.layer.cornerRadius  = 57.5f;
    self.avatarControlView.layer.masksToBounds = YES;
    self.avatarControlView.layer.borderWidth   = 1.f;
    self.avatarControlView.layer.borderColor   = [UIColor whiteColor].CGColor;

    self.avatarImageView.image               = [UIImage imageNamed:@"默认头像"];
    self.avatarImageView.layer.cornerRadius  = 50.f;
    self.avatarImageView.layer.masksToBounds = YES;
    self.avatarImageView.layer.borderWidth   = 6.f;
    self.avatarImageView.layer.borderColor   = RGBCOLOR(185, 184, 184).CGColor;

    self.addressButton.layer.cornerRadius  = 15.f;
    self.addressButton.layer.masksToBounds = YES;

    UITapGestureRecognizer *focusLabelTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFocusLabel:)];
    [self.focusOnLabel addGestureRecognizer:focusLabelTap];

    UITapGestureRecognizer *fansLabelTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFansLabel:)];
    [self.fansLabel addGestureRecognizer:fansLabelTap];
}

- (void)configHeaderViewDataSource:(MyDetailInfoModel *)detailModel infoModel:(MyInfoModel *)infoModel {
    _detailModel = detailModel;
    _infoModel   = infoModel;

    NSURL *avatarImageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", IMAGEHEADER, self.infoModel.icon]];
    [self.avatarImageView sd_setImageWithURL:avatarImageURL placeholderImage:[UIImage imageNamed:@"默认头像"]];

    self.userNameLabel.text = self.infoModel.name;

    if (self.detailModel.cityName && self.detailModel.cityName.length > 0) {
        self.addressButton.hidden = NO;
        [self.addressButton setTitle:self.detailModel.cityName forState:UIControlStateNormal];
    } else {
        self.addressButton.hidden = YES;
    }
    [self.genderAgeButton setTitle:[NSString stringWithFormat:@"%ld岁", (long) self.infoModel.age] forState:UIControlStateNormal];
    [self.genderAgeButton setImage:[UIImage imageNamed:(self.infoModel.sex ? @"女" : @"男")] forState:UIControlStateNormal];

    self.focusOnLabel.text = [NSString stringWithFormat:@"关注\n%ld", (long) self.infoModel.focusNum];
    [self.focusOnLabel sizeToFit];
    self.fansLabel.text = [NSString stringWithFormat:@"粉丝\n%ld", (long) self.infoModel.fansNum];
    [self.fansLabel sizeToFit];
}

- (IBAction)clickAvatarControlView:(id)sender {
    if (self.changeAvatarImageBlock) {
        self.changeAvatarImageBlock(sender);
    }
}

- (void)tapFocusLabel:(UITapGestureRecognizer *)tap {
    if (self.tapFocusLabelBlock) {
        self.tapFocusLabelBlock(tap);
    }
}

- (void)tapFansLabel:(UITapGestureRecognizer *)tap {
    if (self.tapFansLabelBlock) {
        self.tapFansLabelBlock(tap);
    }
}

@end
