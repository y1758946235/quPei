//
//  LYGetCoinTableViewCell.m
//  LvYue
//
//  Created by KentonYu on 16/8/2.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "LYGetCoinTableViewCell.h"

@interface LYGetCoinTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *coinNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *rmbLabel;

@end

@implementation LYGetCoinTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configData:(NSNumber *)coinNum {
    self.coinNumLabel.text = [NSString stringWithFormat:@"%@", coinNum];
    self.rmbLabel.text     = [NSString stringWithFormat:@"¥ %d", [coinNum integerValue] / 100];
}

@end
