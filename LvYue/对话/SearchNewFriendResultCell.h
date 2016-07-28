//
//  SearchNewFriendResultCell.h
//  LvYue
//
//  Created by apple on 15/10/8.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SearchResultPerson;

@interface SearchNewFriendResultCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UIImageView *sexView;

@property (weak, nonatomic) IBOutlet UILabel *ageLabel;

@property (weak, nonatomic) IBOutlet UILabel *signalLabel; //个性签名

+ (SearchNewFriendResultCell *)searchNewFriendResultCellWithTableView:(UITableView *)tableView;

- (void)fillDataWithModel:(SearchResultPerson *)model;

@end
