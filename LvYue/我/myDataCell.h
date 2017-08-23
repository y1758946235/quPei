//
//  myDataCell.h
//  LvYue
//
//  Created by X@Han on 16/12/22.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "appointModel.h"

@interface myDataCell : UITableViewCell

@property(retain,nonatomic)UILabel *appointLabel;  //约会类型
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

@property(retain,nonatomic)UIButton *deleteBtn;
@property(retain,nonatomic)UIButton *changeBtn;




- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

- (void)createCell:(appointModel *)model placeName:(NSString *)placeName;

@end
