//
//  LYFocusOnAndFansTableViewCell.m
//  LvYue
//
//  Created by KentonYu on 16/8/1.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "LYFocusOnAndFansTableViewCell.h"
#import "UIImageView+WebCache.h"

@interface LYFocusOnAndFansTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *signatureLabel;
@property (weak, nonatomic) IBOutlet UIImageView *focusOnImageView;

@end

@implementation LYFocusOnAndFansTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.avatarImageView.layer.cornerRadius  = 36.f;
    self.avatarImageView.layer.masksToBounds = YES;

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFocusOnImageView:)];
    [self.focusOnImageView addGestureRecognizer:tap];
}

- (void)configData:(NSDictionary *)dic {

    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", IMAGEHEADER, dic[@"icon"]]] placeholderImage:[UIImage imageNamed:@"logo108"]];

    self.nameLabel.text = dic[@"name"];
}

- (void)tapFocusOnImageView:(id)sender {
    if (self.tapFocusOnImageViewBlock) {
        self.tapFocusOnImageViewBlock(sender);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
