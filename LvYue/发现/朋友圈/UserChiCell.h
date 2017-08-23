//
//  UserChiCell.h
//  LvYue
//
//  Created by X@Han on 16/12/14.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UserModel;
@interface UserChiCell : UICollectionViewCell

@property(nonatomic,strong)UIImageView *photoImage;  //头像
@property(nonatomic,strong)UILabel *nickLabel;   //昵称
@property(nonatomic,strong)UIImageView *sexImage;  //性别图片
@property(nonatomic,strong)UILabel *ageLabel;  //年龄
@property(nonatomic,strong)UIView *contView;  //填充label；
@property(nonatomic,strong)UIButton *affVideoBtn;  //验证视频

-(void)creatModel:(UserModel*)model;
@end
