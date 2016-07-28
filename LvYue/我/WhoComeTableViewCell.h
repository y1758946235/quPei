//
//  WhoComeTableViewCell.h
//  LvYue
//
//  Created by 広有射怪鸟事 on 15/12/18.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WhoComeModel.h"

@interface WhoComeTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *headIconImageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *signLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;

+ (WhoComeTableViewCell *)cellWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath;
- (void)fillDataWithModel:(WhoComeModel *)model;

@end
