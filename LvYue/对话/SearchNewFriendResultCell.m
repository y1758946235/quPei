//
//  SearchNewFriendResultCell.m
//  LvYue
//
//  Created by apple on 15/10/8.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import "SearchNewFriendResultCell.h"
#import "SearchResultPerson.h"
#import "UIImageView+WebCache.h"

@implementation SearchNewFriendResultCell

- (void)awakeFromNib {
    self.iconView.layer.cornerRadius = 5.0;
    self.iconView.clipsToBounds = YES;
    self.iconView.contentMode = UIViewContentModeScaleAspectFill;
}

+ (SearchNewFriendResultCell *)searchNewFriendResultCellWithTableView:(UITableView *)tableView {
    
    static NSString *reuseName = @"searchResultCell";
    SearchNewFriendResultCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseName];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SearchNewFriendResultCell" owner:nil options:nil] lastObject];
    }
    return cell;
}


- (void)fillDataWithModel:(SearchResultPerson *)model {
    [self.iconView sd_setImageWithURL:[NSURL URLWithString:model.icon]];
    self.nameLabel.text = model.name;
    self.ageLabel.text = model.age;
    if ([model.sex isEqualToString:@"0"]) {
        self.sexView.image = [UIImage imageNamed:@"男"];
    } else {
        self.sexView.image = [UIImage imageNamed:@"女"];
    }
    self.signalLabel.text = model.signature;
}

@end
