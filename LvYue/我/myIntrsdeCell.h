//
//  myIntrsdeCell.h
//  LvYue
//
//  Created by X@Han on 17/1/17.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>
@class myIntrsedModel;

@interface myIntrsdeCell : UITableViewCell



@property(retain,nonatomic)UILabel *appointLabel;  //约会类型
@property(retain,nonatomic)UIImageView *headImage;   //头像
@property(retain,nonatomic)UIImageView *vipImage;  //vip图片

@property(retain,nonatomic)UILabel *nickName; //昵称
@property(retain,nonatomic)UIImageView *sexImage; //性别图片
@property(retain,nonatomic)UILabel *ageLabe;  //年龄
@property(retain,nonatomic)UILabel *heightLabel; //身高
@property(retain,nonatomic)UILabel *constellationLable; //星座
@property(retain,nonatomic)UILabel *professionLable; //职业
@property(retain,nonatomic)UILabel *publishLabel;  //发布约会的时间
@property(retain,nonatomic)UIImageView *timeImage;  //约会的时间
@property(retain,nonatomic)UILabel *timeLabel;
@property(retain,nonatomic)UIImageView *aaImage;
@property(retain,nonatomic)UILabel *aaLabel;
@property(retain,nonatomic)UIImageView *distiImage;  //目的地图片
@property(retain,nonatomic)UILabel *distLabel;

@property(retain,nonatomic)UIImageView *leftImage;
@property(retain,nonatomic)UIImageView *rightImage;

@property(retain,nonatomic)UILabel *contenLabel; //约会内容

@property(retain,nonatomic)UIImageView *contenImage; //约会图片

@property(retain,nonatomic)UIButton *intreBtn;  //感兴趣
@property(retain,nonatomic)UIButton *chatBtn;  //聊一聊

@property(retain,nonatomic)UILabel *instrstedLabel; //感兴趣人数
@property(retain,nonatomic)UIImageView *instrstedImage;//感兴趣头像
@property(retain,nonatomic)UIButton *otherHomeBtn;   //进入他人主页


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

//- (void)setImageBottom:(NSArray *)imageData;

- (void)setIntrstedHeadImage:(NSString *)imageData;

- (void)createCell:(myIntrsedModel *)model;

@end
