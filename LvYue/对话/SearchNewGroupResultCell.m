//
//  SearchNewFriendResultCell.m
//  LvYue
//
//  Created by apple on 15/10/8.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import "SearchNewGroupResultCell.h"
#import "UIImageView+WebCache.h"
#import "SearchResultGroup.h"

@implementation SearchNewGroupResultCell

- (void)awakeFromNib {
    self.iconView.layer.cornerRadius = 5.0;
    self.iconView.clipsToBounds = YES;
    self.applyBtn.layer.cornerRadius = 5.0;
    self.applyBtn.clipsToBounds = YES;
}


+ (SearchNewGroupResultCell *)searchNewGroupResultCellWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *reuseName = @"searchResultCell";
    SearchNewGroupResultCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseName];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SearchNewGroupResultCell" owner:nil options:nil] lastObject];
    }
    cell.indexPath = indexPath;
    return cell;
}


- (void)fillDataWithModel:(SearchResultGroup *)model {
    self.nameLabel.text = model.name;
    [self.iconView sd_setImageWithURL:[NSURL URLWithString:model.icon] placeholderImage:[UIImage imageNamed:@"group_header"]];
    self.descLabel.text = model.desc;
}


//申请加入群
- (IBAction)applyToJoinGroup:(UIButton *)sender {
    //发送通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"applyToJoinGroup" object:nil userInfo:@{@"indexPath":self.indexPath}];
}

@end
