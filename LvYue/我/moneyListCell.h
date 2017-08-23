//
//  moneyListCell.h
//  LvYue
//
//  Created by X@Han on 16/12/17.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MoneyListModel;

@interface moneyListCell : UITableViewCell

@property(nonatomic,retain)UILabel *iConNumLabel; //金币个数
@property(nonatomic,retain)UILabel *moneyTimeLabel; //充值时间
@property(nonatomic,retain)UILabel *moneyLabel; //支付钱
@property(nonatomic,retain)UILabel *suceLabel; //支付成功

@property(nonatomic,retain)MoneyListModel *model;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
-(void)setModel:(MoneyListModel *)model;


@end
