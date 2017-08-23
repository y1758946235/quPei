//
//  WithdrawalRecordModel.h
//  LvYue
//
//  Created by X@Han on 17/4/11.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WithdrawalRecordModel : NSObject
@property(copy,nonatomic)NSString *createTime;//:提现创建时间
@property(copy,nonatomic)NSString *updateTime;//:提现修改时间
@property(copy,nonatomic)NSString* withdrawalAmount;//:提现金额(Double)
@property(copy,nonatomic)NSString *withdrawalPoint;//:提现金币(Integer)
@property(copy,nonatomic)NSString *withdrawalStatus;//:状态0等待确认1关闭提现2已完成5提现失败(Integer)
@property(copy,nonatomic)NSString *withdrawalStatusStr;//订单状态
@property(copy,nonatomic)NSString *userId;  //用户主键
@property(copy,nonatomic)NSString *withdrawalId;//:提现记录id(Integer)
@property(copy,nonatomic)NSString *withdrawalChannel;//:提现渠道0支付宝1微信(Integer)
@property(copy,nonatomic)NSString *withdrawalAccount;//:提现帐号
- (id)initWithModelDic:(NSDictionary *)dic;
+ (id)createWithModelDic:(NSDictionary *)dic;
@end
