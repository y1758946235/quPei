//
//  CustomTableViewCell.h
//  cellXibDemo
//
//  Created by 广有射怪鸟事 on 15/10/6.
//  Copyright © 2015年 刘瀚韬. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CustomTableViewCell;
@protocol CustomTableViewCellDelegate <NSObject>
@optional
- (void)customTableViewCell:(CustomTableViewCell *)customTableViewCell didClickButtonIndex:(NSInteger) buttonIndex;

@end

@interface CustomTableViewCell : UITableViewCell

@property (nonatomic, weak) id<CustomTableViewCellDelegate> delegate;

@property (strong, nonatomic) IBOutlet UILabel *month;
@property (strong, nonatomic) IBOutlet UILabel *cheap;
@property (strong, nonatomic) IBOutlet UIButton *selectBtn;
@property (strong, nonatomic) IBOutlet UILabel *price;

@property (weak, nonatomic) IBOutlet UIButton *leftPayButton;   //左边支付方式的按钮
@property (weak, nonatomic) IBOutlet UIButton *rightPayButton;  //右边支付方式的按钮
@property (weak, nonatomic) IBOutlet UILabel *payMethodLabel;   //支付方式

+ (instancetype)cellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;

@end
