//
//  BuddySelectionCell.h
//  LvYue
//
//  Created by apple on 15/10/9.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MyBuddyModel;

@interface BuddySelectionCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *selectView;

@property (weak, nonatomic) IBOutlet UIImageView *iconView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

+ (BuddySelectionCell *)buddySelectionCellWithTableView:(UITableView *)tableView;

- (void)fillDataWithModel:(MyBuddyModel *)model;

@end
