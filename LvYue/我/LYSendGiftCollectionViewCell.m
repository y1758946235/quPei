//
//  LYSendGiftCollectionViewCell.m
//  LvYue
//
//  Created by KentonYu on 16/7/27.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "LYSendGiftCollectionViewCell.h"

@interface LYSendGiftCollectionViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIView *coinView;
@property (weak, nonatomic) IBOutlet UILabel *coinNumLabel;

@property (weak, nonatomic) IBOutlet UIImageView *selectedImageView;
@end

@implementation LYSendGiftCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)configData:(NSDictionary *)data {
    self.iconImageView.image = [UIImage imageNamed:data[@"icon"]];
    self.nameLabel.text      = data[@"name"];

    self.coinNumLabel.text = data[@"coin"];
    [self.coinView sizeToFit];
}

- (void)selected {
    self.selectedImageView.hidden    = NO;
    self.contentView.backgroundColor = RGBCOLOR(228, 227, 233);
}

- (void)unSelected {
    self.selectedImageView.hidden    = YES;
    self.contentView.backgroundColor = RGBCOLOR(240, 239, 245);
}

@end
