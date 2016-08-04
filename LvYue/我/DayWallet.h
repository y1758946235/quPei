//
//  DayWallet.h
//  LvYue
//
//  Created by KFallen on 16/8/4.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DayWallet : NSObject

@property (nonatomic, strong) NSString* createTime;    //创建时间
@property (nonatomic, strong) NSString* day;   //日期
@property (nonatomic, copy) NSString* ID;  //明细ID
@property (nonatomic, copy) NSString* price;  //明细金额
@property (nonatomic, copy) NSString* smallType;//类型明细 type为1时,1.收到礼物;2.充值金币  3.打赏照片;4.送礼退款;type为2时,1.购买礼物;2.购买会员;3.提现;4.打赏
@property (nonatomic, copy) NSString* type;   //类型 1.收入;2.支出
@property (nonatomic, copy) NSString* userId; //登录者Id

//+ (instancetype)dayWalletWithDict:(NSDictionary *)dict;

- (instancetype)initWithDict:(NSDictionary *)dict;

@end
