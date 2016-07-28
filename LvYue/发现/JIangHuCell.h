//
//  JIangHuCell.h
//  LvYueDemo
//
//  Created by 蒋俊 on 15/9/12.
//  Copyright (c) 2015年 vison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JJLModel.h"
/**
 *  江湖救急令
 */
@interface JIangHuCell : UITableViewCell
@property(nonatomic,strong) UIImageView *iconView;

@property (nonatomic,strong) UIButton *iconBtn;

@property(nonatomic,strong) UIImageView *VipView;

@property(nonatomic,strong) UILabel *name;

@property(nonatomic,strong) UIImageView *ageView;

@property(nonatomic,strong) UILabel *ageLable;

@property(nonatomic,strong) UIImageView *image1;

@property(nonatomic,strong) UIImageView *image2;

@property(nonatomic,strong) UIImageView *image3;

@property(nonatomic,strong) UIImageView *image4;

@property(nonatomic,strong) UIImageView *image5;

@property(nonatomic,strong) UILabel *detil;

@property(nonatomic,strong) UILabel *distanceLabel;

@property(nonatomic,strong) UILabel *timeLabel;

@property(nonatomic,strong) UIImageView *locImageView;

@property(nonatomic,strong) UIImageView *soundImageView;

@property (nonatomic,strong) UINavigationController *navi;

@property (nonatomic,strong) NSString *userId;

@property (nonatomic,strong) NSString *userName;

- (void)fillDateWith:(JJLModel *)model;

@property (nonatomic,strong) UIButton *helpBtn;

@end
