//
//  UserPoolCollectionViewCell.h
//  LvYue
//
//  Created by X@Han on 17/4/11.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserPoolCollectionViewCell : UICollectionViewCell

@property(nonatomic,strong)UIImageView *photoImage;  //头像
@property(nonatomic,strong)UILabel *nickLabel;   //昵称
@property(nonatomic,strong)UIButton *heartImageBtn;  //选择的聊天图片
@property(nonatomic,strong)UILabel *ageLabel;  //年龄
@property(nonatomic,strong)UILabel *contLabel;  //填充label；
-(void)setDataArr:(NSMutableArray *)dataArr;
@end
