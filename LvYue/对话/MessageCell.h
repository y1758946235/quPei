//
//  MessageCell.h
//  LvYue
//
//  Created by apple on 15/10/6.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconView;

@property (weak, nonatomic) IBOutlet UIButton *unReadCountBtn;

@property (weak, nonatomic) IBOutlet UIImageView *vipIconView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *lastMessageLabel;

+ (MessageCell *)messageCellWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath;

- (void)fillDataWithConversation:(EMConversation *)conversation;

@end
