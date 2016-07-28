//
//  BuyRedBeanCell.h
//  LvYue
//
//  Created by KFallen on 16/7/12.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BuyRedBeanCell;
@protocol BuyRedBeanCellDelegate <NSObject>
@optional
- (void)buyRedBeanCell:(BuyRedBeanCell *)cell didClickButtonIndex:(NSInteger) buttonIndex;

@end


@interface BuyRedBeanCell : UITableViewCell

@property (nonatomic, weak) id<BuyRedBeanCellDelegate> delegate;

+ (instancetype)cellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;

@end
