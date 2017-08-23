//
//  DynamicTableViewCell.h
//  LvYue
//
//  Created by X@Han on 17/5/22.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DynamicListModel;
@interface DynamicTableViewCell : UITableViewCell
@property(nonatomic,strong)UIImageView *headImageV;  //头像
@property(nonatomic,strong)UILabel *nickLabel;   //昵称
@property(nonatomic,strong)UIImageView *shareImageV;  //
@property(nonatomic,strong)UIImageView *sexImage;  //
@property(nonatomic,strong)UILabel *ageLabel;  //年龄
@property(nonatomic,strong)UILabel *contLabel;  //填充label；
@property(nonatomic,strong) UIButton *edit;  //；

@property(nonatomic,strong)UILabel *videoPlayerLabel;
@property(nonatomic,strong)UILabel *lineLabel;
@property(nonatomic,strong)UIButton *sendMessBtn;
@property(nonatomic,strong)UIButton *PraiseBtn;
@property(nonatomic,strong)UILabel *sendMessLabel;
@property(nonatomic,strong)UILabel *PraiseNumLabel;
-(void)creatModel:(DynamicListModel*)model;
@end
