//
//  CheckMessageCell.m
//  LvYue
//
//  Created by apple on 15/10/7.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import "CheckMessageCell.h"
#import "UIImageView+WebCache.h"
#import "CheckMessageModel.h"

@implementation CheckMessageCell

- (void)awakeFromNib {
    self.iconView.layer.cornerRadius = 2.0;
    self.iconView.clipsToBounds = YES;
    self.handleBtn.layer.cornerRadius = 5.0;
    self.handleBtn.clipsToBounds = YES;
    self.signalLabel.layer.cornerRadius = 1.0;
    self.signalLabel.clipsToBounds = YES;
}

+ (CheckMessageCell *)checkMessageCellWithTableView:(UITableView *)tableView {
    
    static NSString *reuseName = @"checkMessageCell";
    CheckMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseName];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"CheckMessageCell" owner:nil options:nil] lastObject];
    }
    return cell;
}


- (void)fillDataWithModel:(CheckMessageModel *)model {
    
    [self.iconView sd_setImageWithURL:[NSURL URLWithString:model.icon]];
    self.nameLabel.text = model.name;
    self.messageLabel.text = model.requestInfo;
    //状态 0=未处理 1=已读 2=同意 3=拒绝
    if ([model.status isEqualToString:@"0"]) {
        [self.handleBtn setTitle:@"同意" forState:UIControlStateNormal];
        [self.handleBtn setBackgroundColor:RGBACOLOR(250, 82, 74, 1.0)];
        [self.handleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.alreadyReadLabel.hidden = YES;
    } else if ([model.status isEqualToString:@"1"]) {
        [self.handleBtn setTitle:@"同意" forState:UIControlStateNormal];
        [self.handleBtn setBackgroundColor:RGBACOLOR(250, 82, 74, 1.0)];
        [self.handleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.alreadyReadLabel.hidden = NO;
    } else if ([model.status isEqualToString:@"2"]) {
        [self.handleBtn setTitle:@"已通过" forState:UIControlStateNormal];
        [self.handleBtn setBackgroundColor:[UIColor clearColor]];
        [self.handleBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        self.alreadyReadLabel.hidden = NO;
    } else {
        [self.handleBtn setTitle:@"已拒绝" forState:UIControlStateNormal];
        [self.handleBtn setBackgroundColor:[UIColor clearColor]];
        [self.handleBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        self.alreadyReadLabel.hidden = NO;
    }
    //类型分类 1=添加好友申请 2=添加群申请 3=邀请加群申请 4=豆客应邀申请
    if ([model.type isEqualToString:@"1"]) {
        self.signalLabel.text = @"添加好友申请";
    } else if ([model.type isEqualToString:@"2"]) {
        self.signalLabel.text = @"添加群申请";
    } else if ([model.type isEqualToString:@"3"]) {
        self.signalLabel.text = @"邀请加群申请";
    } else {
        self.signalLabel.text = @"豆客应邀申请";
    }
}

@end
