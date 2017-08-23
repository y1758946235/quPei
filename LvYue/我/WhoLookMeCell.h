//
//  WhoLookMeCell.h
//  LvYue
//
//  Created by X@Han on 16/12/19.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WhoLookMeModel;
@interface WhoLookMeCell : UITableViewCell

@property(nonatomic,retain)UILabel *nickLabel; //昵称
@property(nonatomic,retain)UILabel *ageLabel; //年龄
@property(nonatomic,retain)UILabel *heightLabel; //身高
@property(nonatomic,retain)UILabel *colleanLabel; //星座
@property(nonatomic,retain)UILabel *timeLabe; //时间
@property(nonatomic,retain)UIButton *vipImageBtn;
@property(nonatomic,retain)UIImageView *headImage;
@property(nonatomic,retain) WhoLookMeModel*model;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
-(void)creatModel:(WhoLookMeModel *)model;
@end
