//
//  VideoDynamiclistCollectionViewCell.h
//  LvYue
//
//  Created by X@Han on 17/5/22.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DyVideoListModel;
@interface VideoDynamiclistCollectionViewCell : UICollectionViewCell

@property(nonatomic,strong)UIImageView *boottImagV;  //
@property(nonatomic,strong)UILabel *topicLabel;  //填充label；
@property(nonatomic,strong)UIImageView *headImageV;  //头像
@property(nonatomic,strong)UILabel *nickLabel;   //昵称
@property(nonatomic,strong)UIImageView *videoImageV;  //视频图片
@property(nonatomic,strong)UILabel *ageLabel;  //年龄
@property(nonatomic,strong)UILabel *contLabel;  //填充label；
@property(nonatomic,strong)UIButton *affVideoBtn;  //验证视频

-(void)creatModel:(DyVideoListModel*)model;
@end
