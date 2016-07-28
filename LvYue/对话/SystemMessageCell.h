//
//  SystemMessageCell.h
//  LvYue
//
//  Created by apple on 15/10/28.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SystemMessageModel;

@interface SystemMessageCell : UITableViewCell

@property (weak, nonatomic ) IBOutlet UILabel *timeStampLabel;

@property (weak, nonatomic ) IBOutlet UILabel *messageLabel;

@property (nonatomic,strong) UINavigationController *navi;

+ (SystemMessageCell *)systemMessageCellWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath;

- (void)fillDataWithModel:(SystemMessageModel *)model;

@end
