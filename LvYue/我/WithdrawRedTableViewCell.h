//
//  WithdrawRedTableViewCell.h
//  LvYue
//
//  Created by 広有射怪鸟事 on 15/12/15.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WithdrawRedTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *redBeanNumLabel;

+ (WithdrawRedTableViewCell *)cellWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath;

@end
