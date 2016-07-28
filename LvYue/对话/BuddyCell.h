//
//  BuddyCell.h
//  LvYue
//
//  Created by apple on 15/10/6.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MyBuddyModel;

@interface BuddyCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (nonatomic, strong) UILabel *promptLabel; //推送提醒器

+ (BuddyCell *)buddyCellWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath;

- (void)fillDataWithModel:(MyBuddyModel *)model;

- (void)createPromptLabelWithIndexPath:(NSIndexPath *)indexPath;

@end
