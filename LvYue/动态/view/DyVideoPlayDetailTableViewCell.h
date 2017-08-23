//
//  DyVideoPlayDetailTableViewCell.h
//  LvYue
//
//  Created by X@Han on 17/8/3.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DyVideoPlayerDetailModel;
@interface DyVideoPlayDetailTableViewCell : UITableViewCell
@property(nonatomic,strong)UIImageView *headImageV;  //头像
@property(nonatomic,strong)UILabel *nickLabel;   //昵称
@property(nonatomic,strong)UIImageView *sexImage;  //
@property(nonatomic,strong)UILabel *ageLabel;  //年龄
@property(nonatomic,strong)UILabel *contLabel;  //填充label；

-(void)creatModel:(DyVideoPlayerDetailModel*)model;
@end
