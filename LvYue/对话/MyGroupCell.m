//
//  BuddyCell.m
//  LvYue
//
//  Created by apple on 15/10/6.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import "MyGroupCell.h"
#import "GroupModel.h"
#import "UIImageView+WebCache.h"

@implementation MyGroupCell

- (void)awakeFromNib {
    
    self.iconView.layer.cornerRadius = 2.0;
    self.iconView.clipsToBounds = YES;
}


+ (MyGroupCell *)myGroupCellWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *reuseName = @"myGroupCell";
    MyGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseName];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"MyGroupCell" owner:nil options:nil] lastObject];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.imageView.contentMode = UIViewContentModeScaleToFill;
    cell.backgroundColor = [UIColor whiteColor];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.iconView.image = [UIImage imageNamed:@"搜索群组"];
            cell.nameLabel.text = @"搜索群组";
        } else {
            cell.iconView.image = [UIImage imageNamed:@"创建群组"];
            cell.nameLabel.text = @"创建新的群组";
        }
    }
    return cell;
}


- (void)fillDataWithModel:(GroupModel *)model {
    
    [self.iconView sd_setImageWithURL:[NSURL URLWithString:model.icon]];
    self.nameLabel.text = model.name;
}

@end
