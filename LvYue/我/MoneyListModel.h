//
//  MoneyListModel.h
//  LvYue
//
//  Created by X@Han on 17/4/6.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MoneyListModel : NSObject
@property(copy,nonatomic)NSString *createTime;//下单时间
@property(copy,nonatomic)NSString *updateTime; //变化时间
//@property(assign,nonatomic)double orderAmount;//现金金额(Double)
//@property(assign,nonatomic)NSInteger *goldNumber;//金币金额(Integer)
//@property(assign,nonatomic)NSInteger *orderStatus;//订单状态0未付款2已完成5支付失败(Integer)
@property(copy,nonatomic)NSString* orderAmount;//现金金额(Double)
@property(copy,nonatomic)NSString *goldNumber;//金币金额(Integer)
@property(copy,nonatomic)NSString *orderStatus;//订单状态0未付款2已完成5支付失败(Integer)
@property(copy,nonatomic)NSString *orderStatusStr;//订单状态
@property(copy,nonatomic)NSString *userId;  //用户主键

- (id)initWithModelDic:(NSDictionary *)dic;
+ (id)createWithModelDic:(NSDictionary *)dic;
@end
