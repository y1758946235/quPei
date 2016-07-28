//
//  SearchNewFriendResultCell.h
//  LvYue
//
//  Created by apple on 15/10/8.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SearchResultGroup;

@interface SearchNewGroupResultCell : UITableViewCell

@property (nonatomic, strong) NSIndexPath *indexPath;

@property (weak, nonatomic) IBOutlet UIImageView *iconView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *descLabel; //群组简介

@property (weak, nonatomic) IBOutlet UIButton *applyBtn;

- (IBAction)applyToJoinGroup:(UIButton *)sender;

+ (SearchNewGroupResultCell *)searchNewGroupResultCellWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath;

- (void)fillDataWithModel:(SearchResultGroup *)model;

@end
