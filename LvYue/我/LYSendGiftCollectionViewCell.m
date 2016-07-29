//
//  LYSendGiftCollectionViewCell.m
//  LvYue
//
//  Created by KentonYu on 16/7/27.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "LYSendGiftCollectionViewCell.h"

@interface LYSendGiftCollectionViewCell ()

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *coinNumLabel;
@property (nonatomic, strong) UIImageView *coinImageView;
@property (nonatomic, strong) UIImageView *selectedImageView;


@end

@implementation LYSendGiftCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = RGBCOLOR(240, 239, 245);

        [self addSubview:self.iconImageView];
        [self addSubview:self.nameLabel];
        [self addSubview:self.coinImageView];
        [self addSubview:self.coinNumLabel];
        [self addSubview:self.selectedImageView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat iconImageViewWH  = (self.width - 20.f) / 2.f;
    self.iconImageView.frame = CGRectMake((self.width - iconImageViewWH) / 2.f, 10.f, iconImageViewWH, iconImageViewWH);

    [self.nameLabel sizeToFit];
    self.nameLabel.frame = CGRectMake((self.width - self.nameLabel.width) / 2.f, CGRectGetMaxY(self.iconImageView.frame) + 5.f, self.nameLabel.width, self.nameLabel.height);

    [self.coinNumLabel sizeToFit];
    self.coinNumLabel.frame = CGRectMake((self.width - self.coinNumLabel.width - 20) / 2.f, CGRectGetMaxY(self.nameLabel.frame) + 5.f, self.coinNumLabel.width, self.coinNumLabel.height);

    self.coinImageView.frame = CGRectMake(CGRectGetMaxX(self.coinNumLabel.frame) + 5.f, CGRectGetMaxY(self.nameLabel.frame) + 5.f, 15.f, 15.f);

    self.selectedImageView.frame = CGRectMake(0, 0, 34.f, 34.f);
}

- (void)configData:(NSDictionary *)data {
    self.iconImageView.image = [UIImage imageNamed:data[@"icon"]];
    self.nameLabel.text      = data[@"name"];
    self.coinNumLabel.text   = data[@"coin"];
}

- (void)selected {
    self.selectedImageView.hidden    = NO;
    self.contentView.backgroundColor = RGBCOLOR(228, 227, 233);
}

- (void)unSelected {
    self.selectedImageView.hidden    = YES;
    self.contentView.backgroundColor = RGBCOLOR(240, 239, 245);
}

#pragma mark - Getter

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] init];
    }
    return _iconImageView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = ({
            UILabel *label  = [[UILabel alloc] init];
            label.textColor = [UIColor blackColor];
            label.font      = [UIFont systemFontOfSize:15.f];
            label;
        });
    }
    return _nameLabel;
}

- (UILabel *)coinNumLabel {
    if (!_coinNumLabel) {
        _coinNumLabel = ({
            UILabel *label  = [[UILabel alloc] init];
            label.textColor = RGBCOLOR(255, 176, 0);
            label.font      = [UIFont systemFontOfSize:14.f];
            label;
        });
    }
    return _coinNumLabel;
}

- (UIImageView *)coinImageView {
    if (!_coinImageView) {
        _coinImageView = ({
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.image        = [UIImage imageNamed:@"vip"];
            imageView.size         = CGSizeMake(15.f, 15.f);
            imageView;
        });
    }
    return _coinImageView;
}

- (UIImageView *)selectedImageView {
    if (!_selectedImageView) {
        _selectedImageView = ({
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"对号"]];
            imageView.size         = CGSizeMake(34.f, 34.f);
            imageView.hidden       = YES;
            imageView;
        });
    }
    return _selectedImageView;
}

@end
