//
//  WithdrawalRecordTableViewCell.h
//  LvYue
//
//  Created by X@Han on 17/4/11.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WithdrawalRecordModel;
@interface WithdrawalRecordTableViewCell : UITableViewCell

@property(nonatomic,retain)UILabel *iConNumLabel; //金币个数
@property(nonatomic,retain)UILabel *moneyTimeLabel; //充值时间
@property(nonatomic,retain)UILabel *moneyLabel; //支付钱
@property(nonatomic,retain)UILabel *accountLabel; //帐号
@property(nonatomic,retain)UIButton *suceBtn; //支付成功
@property(nonatomic,retain)UILabel *suceLabel; //支付成功
@property(nonatomic,retain)WithdrawalRecordModel *withRecordModel;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier ;

-(void)setWithRecordModel:(WithdrawalRecordModel *)withRecordModel;
@end
