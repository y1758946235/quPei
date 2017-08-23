//
//  WhoEvaluatTableViewCell.h
//  LvYue
//
//  Created by X@Han on 17/4/26.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WhoEvaluationModel;
@interface WhoEvaluatTableViewCell : UITableViewCell

@property(nonatomic,retain)UILabel *nickLabel; //昵称
@property(nonatomic,retain)UILabel *gradeContentLabel; 
@property(nonatomic,retain)UILabel *timeLabe; //时间
@property(nonatomic,retain)UIImageView *headImage;
-(void)creatModel:(WhoEvaluationModel *)model;
@end
