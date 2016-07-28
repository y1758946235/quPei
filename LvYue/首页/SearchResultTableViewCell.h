//
//  SearchResultTableViewCell.h
//  LvYue
//
//  Created by 郑洲 on 16/3/18.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeModel.h"

@interface SearchResultTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UIImageView *vipImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *sexImageView;
@property (weak, nonatomic) IBOutlet UILabel *markLabel;
@property (nonatomic, strong) UIView *line;

+ (SearchResultTableViewCell *)cellWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath;
- (void)fillData:(HomeModel *)model;
@end
