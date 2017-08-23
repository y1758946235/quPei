//
//  TaskTableViewCell.h
//  LvYue
//
//  Created by X@Han on 17/4/10.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>
@class taskModel;
@interface TaskTableViewCell : UITableViewCell
@property(retain,nonatomic)UILabel *videoLabel;
@property(retain,nonatomic)UILabel *numLabel;
@property(retain,nonatomic)UIButton *getRewardBtn;
@property (nonatomic,retain)taskModel *model;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
-(void)setModel:(taskModel *)model;
@end
