//
//  MyCenterTableViewCell.h
//  澜庭
//
//  Created by 广有射怪鸟事 on 15/9/25.
//  Copyright (c) 2015年 刘瀚韬. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyCenterTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *iconImageView;
@property (strong, nonatomic) IBOutlet UILabel *sbLabel;

@property (strong, nonatomic)  UIImageView *iconImageView2;
@property (strong, nonatomic)  UILabel *sbLabel2;

+ (instancetype)myCenterTableViewCellWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath sbArray:(NSArray *)sbArray iconArray:(NSArray *)iconArray;

@end
