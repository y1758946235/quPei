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
@property (weak, nonatomic) IBOutlet UIButton *addressButton;   //地址按钮  不要
@property (weak, nonatomic) IBOutlet UILabel *focusOnLabel;    //关注 不要了
@property (weak, nonatomic) IBOutlet UILabel *fansLabel;  //粉丝   不要了
@property (weak, nonatomic) IBOutlet UIButton *genderAgeButton;
@property (weak, nonatomic) IBOutlet UIView *redBadgeView; //不要了


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



}

- (void)configHeaderViewDataSource:(MyDetailInfoModel *)detailModel infoModel:(MyInfoModel *)infoModel {
    _detailModel = detailModel;
    _infoModel   = infoModel;

    NSURL *avatarImageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", IMAGEHEADER, self.infoModel.icon]];
    [self.avatarImageView sd_setImageWithURL:avatarImageURL placeholderImage:[UIImage imageNamed:@"默认头像"]];

    self.userNameLabel.text = self.infoModel.name;


    [self.genderAgeButton setTitle:[NSString stringWithFormat:@"%ld岁", (long) self.infoModel.age] forState:UIControlStateNormal];
    [self.genderAgeButton setImage:[UIImage imageNamed:(self.infoModel.sex ? @"女" : @"男")] forState:UIControlStateNormal];

}

- (IBAction)clickAvatarControlView:(id)sender {
    if (self.changeAvatarImageBlock) {
        self.changeAvatarImageBlock(sender);
    }
}



@end
