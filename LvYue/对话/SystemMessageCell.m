//
//  SystemMessageCell.m
//  LvYue
//
//  Created by apple on 15/10/28.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import "SystemMessageCell.h"
#import "SystemMessageModel.h"
#import "AllWordViewController.h"

@implementation SystemMessageCell

- (void)awakeFromNib {
    // Initialization code
 
    self.timeStampLabel.layer.cornerRadius = 5.0;
    self.timeStampLabel.clipsToBounds = YES;
    self.messageLabel.superview.layer.cornerRadius = 10.0;
    self.messageLabel.superview.clipsToBounds = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(lookAll:)];
    self.messageLabel.userInteractionEnabled = YES;
    [self.messageLabel addGestureRecognizer:tap];
}


+ (SystemMessageCell *)systemMessageCellWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath{
    SystemMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"systemMessageCell"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SystemMessageCell" owner:nil options:nil] lastObject];
        
        //侧滑删除
        UIView *deleteView = [[UIView alloc]initWithFrame:CGRectMake(kMainScreenWidth, 0, kMainScreenWidth, 100)];
        deleteView.backgroundColor = [UIColor whiteColor];
        [cell.contentView addSubview:deleteView];
        UIButton *deleteBtn=[[UIButton alloc]initWithFrame:CGRectMake(0, 40, 30, 30)];
        [deleteBtn setBackgroundImage:[UIImage imageNamed:@"deleteIcon.jpg"] forState:UIControlStateNormal];
        [deleteView addSubview:deleteBtn];
    }
    return cell;
}

- (void)fillDataWithModel:(SystemMessageModel *)model {
    self.messageLabel.text =[NSString stringWithFormat:@"%@",model.content] ;
    self.timeStampLabel.text = [CommonTool timestampSwitchTime:[model.timeStamp doubleValue]/1000 andFormatter:@"YYYY-MM-dd hh:mm:ss"]  ;
}

- (void)lookAll:(UIGestureRecognizer *)ges{
    AllWordViewController *all = [[AllWordViewController alloc] init];
    all.title = @"详情";
    all.detail = self.messageLabel.text;
    [self.navi pushViewController:all animated:YES];
}

@end
