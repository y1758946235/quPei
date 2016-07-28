//
//  WalletDetailCell.h
//  LvYue
//
//  Created by KFallen on 16/6/30.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WalletDetailCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;           //时间
@property (weak, nonatomic) IBOutlet UIImageView *iconImgView;     //图标
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;          //内容

@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;          //钱数

+ (instancetype)cellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;

@end
