//
//  CheckMessageCell.h
//  LvYue
//
//  Created by apple on 15/10/7.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CheckMessageModel;

@interface CheckMessageCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@property (weak, nonatomic) IBOutlet UIButton *handleBtn;

@property (weak, nonatomic) IBOutlet UILabel *alreadyReadLabel;

@property (weak, nonatomic) IBOutlet UILabel *signalLabel; //标记请求类型

+ (CheckMessageCell *)checkMessageCellWithTableView:(UITableView *)tableView;

- (void)fillDataWithModel:(CheckMessageModel *)model;

@end
