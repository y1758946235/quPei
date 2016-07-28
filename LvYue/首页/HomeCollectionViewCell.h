//
//  HomeCollectionViewCell.h
//  LvYue
//
//  Created by 郑洲 on 16/3/14.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "HomeModel.h"
#import <UIKit/UIKit.h>
@class HomeCollectionViewCell;
@protocol HomeCollectionViewCellDelegate <NSObject>
@optional
- (void)homeCollectionViewCell:(HomeCollectionViewCell *)cell didClickPlayButton:(UIButton *)sender;

@end

@interface HomeCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) id<HomeCollectionViewCellDelegate> delegate;

@property (nonatomic, strong) UIImageView *userShowImgView; //大图
@property (nonatomic, strong) UIImageView *userHeadImgView; //头像
@property (nonatomic, strong) UIButton *videoBtn;           //播放视频按钮
@property (nonatomic, strong) UIImageView *vipNoteView;     //vip标志
@property (nonatomic, strong) UIImageView *video_authView;  //视频认证
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *ageLabel;
@property (nonatomic, strong) UIImageView *sexImgView;
@property (nonatomic, strong) UILabel *noteLabel;
@property (nonatomic, strong) UINavigationController *navi;
@property (nonatomic, strong) UILabel *comeLabel;
@property (nonatomic, strong) UIImageView *firstImgView;
@property (nonatomic, strong) UIImageView *secondImgView;
@property (nonatomic, strong) UIImageView *thirdImgView;
@property (nonatomic, strong) UIImageView *forthImgView;

@property (nonatomic, strong) NSArray *comeImageArray;   //来访用户图片数组
@property (nonatomic, strong) NSMutableArray *comeArray; //来访用户数组

- (void)fillData:(HomeModel *)model;

@end
