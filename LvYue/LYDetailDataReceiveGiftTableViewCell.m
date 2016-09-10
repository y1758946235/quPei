//
//  LYDetailDataReceiveGiftTableViewCell.m
//  LvYue
//
//  Created by KentonYu on 16/9/10.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "LYDetailDataReceiveGiftTableViewCell.h"
#import "UIImageView+WebCache.h"

@interface LYDetailDataReceiveGiftTableViewCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) NSMutableArray<UIImageView *> *imageViewArray;

@end

@implementation LYDetailDataReceiveGiftTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.titleLabel];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configData:(NSArray *)receviedGiftInfoArray {
    [self.imageViewArray enumerateObjectsUsingBlock:^(UIImageView *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        [obj removeFromSuperview];
    }];
    self.imageViewArray = nil;

    if (!receviedGiftInfoArray) {
        return;
    }

    [receviedGiftInfoArray enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if (idx > 4) {
            return;
        }
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((30 + 10) * idx + CGRectGetMaxX(self.titleLabel.frame) + 10, 2, 30, 30)];
        [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", IMAGEHEADER, obj[@"icon"]]]];
        [self.contentView addSubview:imageView];
        [self.imageViewArray addObject:imageView];
    }];
}

#pragma mark - Getter

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel           = [[UILabel alloc] init];
        _titleLabel.text      = @"TA 收到的礼物";
        _titleLabel.textColor = [UIColor lightGrayColor];
        _titleLabel.font      = [UIFont systemFontOfSize:15.f];
        [_titleLabel sizeToFit];
        _titleLabel.frame = CGRectMake(20.f, (44.f - _titleLabel.height) / 2.f, _titleLabel.width, _titleLabel.height);
    }
    return _titleLabel;
}

- (NSMutableArray *)imageViewArray {
    if (!_imageViewArray) {
        _imageViewArray = [[NSMutableArray alloc] init];
    }
    return _imageViewArray;
}


@end
