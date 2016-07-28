//
//  BuddyCell.m
//  LvYue
//
//  Created by apple on 15/10/6.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import "BuddyCell.h"
#import "UIImageView+WebCache.h"
#import "MyBuddyModel.h"

@implementation BuddyCell

- (void)awakeFromNib {
    
    self.iconView.layer.cornerRadius = 2.0;
    self.iconView.clipsToBounds = YES;
}


+ (BuddyCell *)buddyCellWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *reuseName = @"buddyCell";
    BuddyCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseName];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"BuddyCell" owner:nil options:nil] lastObject];
        //推送提醒器
        cell.promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(kMainScreenWidth - 80, 23, 14, 14)];
        cell.promptLabel.backgroundColor = RGBACOLOR(29, 189, 159, 1.0);
        cell.promptLabel.layer.cornerRadius = 7.0;
        cell.promptLabel.clipsToBounds = YES;
        [cell addSubview:cell.promptLabel];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.iconView.contentMode = UIViewContentModeScaleToFill;
    cell.backgroundColor = [UIColor whiteColor];

    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.iconView.image = [UIImage imageNamed:@"验证消息"];
            cell.nameLabel.text = @"验证消息";
        } else {
            cell.iconView.image = [UIImage imageNamed:@"群聊"];
            cell.nameLabel.text = @"群聊";
        }
    }
    return cell;
}


- (void)fillDataWithModel:(MyBuddyModel *)model {
    
    [self.iconView sd_setImageWithURL:[NSURL URLWithString:model.icon]];
    self.nameLabel.text = model.remark;
}


- (void)createPromptLabelWithIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        if ([[user objectForKey:kHavePrompt] isEqualToString:@"1"]) {
            self.promptLabel.hidden = NO;
        } else {
            self.promptLabel.hidden = YES;
        }
    } else {
        self.promptLabel.hidden = YES;
    }
}

@end
