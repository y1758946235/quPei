//
//  BuddySelectionCell.m
//  LvYue
//
//  Created by apple on 15/10/9.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import "BuddySelectionCell.h"
#import "MyBuddyModel.h"
#import "UIImageView+WebCache.h"

@implementation BuddySelectionCell

- (void)awakeFromNib {
    self.iconView.layer.cornerRadius = 2.0;
    self.iconView.clipsToBounds = YES;
    self.selectView.layer.cornerRadius = 10.0;
    self.selectView.clipsToBounds = YES;
    self.selectView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.selectView.layer.borderWidth = 1.0;
}


+ (BuddySelectionCell *)buddySelectionCellWithTableView:(UITableView *)tableView {
    
    BuddySelectionCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"BuddySelectionCell" owner:nil options:nil] lastObject];
    return cell;
}


- (void)fillDataWithModel:(MyBuddyModel *)model {
    
    [self.iconView sd_setImageWithURL:[NSURL URLWithString:model.icon]];
    self.nameLabel.text = model.remark;
}


@end
