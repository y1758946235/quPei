//
//  InvitaTableViewCell.h
//  LvYue
//
//  Created by X@Han on 17/4/20.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>
@class InvitaModel;

@interface InvitaTableViewCell : UITableViewCell
@property(nonatomic,retain)UILabel *nickLabel; //昵称
@property(nonatomic,retain)UILabel *contetLabel; //内容
@property(nonatomic,retain)UILabel *timeLabe; //时间
//@property(nonatomic,retain)UIImageView *vipImage;
@property(nonatomic,retain)UIImageView *headImage;



- (void)fillDataWithModel:(InvitaModel *)model;
@end
