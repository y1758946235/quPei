//
//  friendTableCell.h
//  LvYue
//
//  Created by X@Han on 16/12/30.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FriendModel;

@interface friendTableCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

+ (friendTableCell *)buddyCellWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath;

- (void)fillDataWithModel:(FriendModel *)model;



@end
