//
//  focusCell.h
//  LvYue
//
//  Created by X@Han on 16/12/29.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface focusCell : UITableViewCell


@property(nonatomic,retain)UILabel *userAge;
@property(nonatomic,retain)UIImageView *userIcon;
@property(nonatomic,retain)UILabel *userName;
//@property(nonatomic,retain)UILabel *userSex;
@property(nonatomic,retain)UILabel *userheight;
@property(nonatomic,retain)UIImageView *vip;
@property(nonatomic,retain)UILabel *conStella;//星座
@property(nonatomic,retain)UIButton *focuBtn; //关注按钮

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;


@end
