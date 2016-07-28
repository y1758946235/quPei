//
//  BlockListTableViewCell.h
//  LvYue
//
//  Created by 広有射怪鸟事 on 16/1/19.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BlockListModel.h"

@interface BlockListTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *iconImageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;

+ (BlockListTableViewCell *)cellWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath;

- (void)fillWithDate:(BlockListModel *)model;

@end
