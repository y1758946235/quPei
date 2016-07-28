//
//  LYMeHeaderView.m
//  LvYue
//
//  Created by KentonYu on 16/7/22.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "LYMeHeaderView.h"
#import "MyInfoModel.h"
#import "MyDetailInfoModel.h"

#import "UIImageView+WebCache.h"

@interface LYMeHeaderView ()

@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UIControl *avatarControlView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;


@end

@implementation LYMeHeaderView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.avatarControlView.layer.cornerRadius  = 60.f;
    self.avatarControlView.layer.masksToBounds = YES;
    self.avatarControlView.layer.borderWidth = 2.f;
    self.avatarControlView.layer.borderColor = [UIColor whiteColor].CGColor;
    
    self.avatarImageView.image = [UIImage imageNamed:@"默认头像"];
    self.avatarImageView.layer.cornerRadius  = 50.f;
    self.avatarImageView.layer.masksToBounds = YES;
    self.avatarImageView.layer.borderWidth   = 5.f;
    self.avatarImageView.layer.borderColor   = [UIColor whiteColor].CGColor;
}

- (void)configHeaderViewDataSource:(MyDetailInfoModel *)detailModel infoModel:(MyInfoModel *)infoModel {
    _detailModel = detailModel;
    _infoModel   = infoModel;
    
    NSURL *avatarImageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,self.infoModel.icon]];
    [self.avatarImageView sd_setImageWithURL:avatarImageURL placeholderImage:[UIImage imageNamed:@"默认头像"]];
    
    self.userNameLabel.text = self.infoModel.name;
    if (self.detailModel.cityName && self.detailModel.cityName.length > 0) {
        self.addressLabel.text = self.detailModel.cityName;
    } 
    
}

- (IBAction)clickAvatarControlView:(id)sender {
    if (self.changeAvatarImageBlock) {
        self.changeAvatarImageBlock(sender);
    }
}

@end
