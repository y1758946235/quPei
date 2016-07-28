//
//  BlockListTableViewCell.m
//  LvYue
//
//  Created by 広有射怪鸟事 on 16/1/19.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "BlockListTableViewCell.h"
#import "UIImageView+WebCache.h"

@implementation BlockListTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    self.iconImageView.layer.masksToBounds = YES;
    self.iconImageView.layer.cornerRadius = 30;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (BlockListTableViewCell *)cellWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath{
    static NSString *myId = @"BlockListTableViewCell";
    BlockListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myId];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"BlockListTableViewCell" owner:nil options:nil] lastObject];
    }
    return cell;
}

- (void)fillWithDate:(BlockListModel *)model{
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,model.icon]]];
    self.nameLabel.text = model.name;
}

@end
