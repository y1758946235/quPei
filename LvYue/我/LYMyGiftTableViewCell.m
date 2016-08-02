//
//  LYMyGiftTableViewCell.m
//  LvYue
//
//  Created by KentonYu on 16/8/1.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "LYMyGiftTableViewCell.h"
#import "UIImageView+WebCache.h"

@interface LYMyGiftTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *giftIconImageView;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end

@implementation LYMyGiftTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.giftIconImageView.layer.cornerRadius  = 35.f;
    self.giftIconImageView.layer.masksToBounds = YES;

    self.mainView.layer.cornerRadius  = 5.f;
    self.mainView.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)configData:(NSDictionary *)dic {

    NSMutableAttributedString *contentAttrStr;
    switch (self.type) {
        case LYMyGiftViewControllerTypeFetch: {
            contentAttrStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"送给你一%@%@\n增加%@金币", dic[@"word"],dic[@"gift_name"], dic[@"price"]]];
            // 金币数量颜色
            NSUInteger location = contentAttrStr.length - 2 - [NSString stringWithFormat:@"%@", dic[@"price"]].length;
            NSUInteger length   = [NSString stringWithFormat:@"%@", dic[@"price"]].length;
            [contentAttrStr addAttribute:NSForegroundColorAttributeName value:RGBCOLOR(210, 0, 5) range:NSMakeRange(location, length)];
            break;
        }
        case LYMyGiftViewControllerTypeSend: {
            contentAttrStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"我送给%@一%@价值\n%@金币的%@", dic[@"userName"], dic[@"word"],dic[@"price"], dic[@"gift_name"]]];
            // 用户名颜色
            [contentAttrStr addAttribute:NSForegroundColorAttributeName value:RGBCOLOR(46, 186, 239) range:NSMakeRange(3, [dic[@"userName"] length])];
            // 金币数量颜色
            NSUInteger location = contentAttrStr.length - [dic[@"gift_name"] length] - 3 - [NSString stringWithFormat:@"%@", dic[@"price"]].length;
            NSUInteger length   = [NSString stringWithFormat:@"%@", dic[@"price"]].length;
            [contentAttrStr addAttribute:NSForegroundColorAttributeName value:RGBCOLOR(210, 0, 5) range:NSMakeRange(location, length)];

            break;
        }
    }
    self.contentLabel.attributedText = [contentAttrStr copy];

    self.dateLabel.text     = dic[@"create_time"];
    self.userNameLabel.text = dic[@"userName"];

    [self.giftIconImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", IMAGEHEADER, dic[@"icon"]]] placeholderImage:[UIImage imageNamed:@"logo108"]];
}

@end
