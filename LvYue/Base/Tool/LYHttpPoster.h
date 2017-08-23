//
//  LYHttpPoster.h
//  LvYue
//
//  Created by apple on 15/9/28.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LYHttpPoster : NSObject

#define SUCCESSBLOCK void(^)(id successResponse)
#define FAILUREBLOCK void(^)(id failureResponse)

//POST请求
+ (void)postHttpRequestByPost:(NSString *)requestUrl andParameter:(NSDictionary *)requestDict success:(void (^)(id))successBlock andFailure:(void (^)(id))failureBlock;

//GET请求
+ (void)postHttpRequestByGet:(NSString *)requestUrl andParameter:(NSDictionary *)requestDict success:(SUCCESSBLOCK) successBlock andFailure:(FAILUREBLOCK)failureBlock;

//首页 获取约会内容
+ (void)requestAppointContentDataWithParameters:(NSDictionary *)parameters Block:(void(^)(NSArray *arr))myBlock;


//用户池
+ (void)requestUserChiWithParameters:(NSDictionary *)parameters Block:(void(^)(NSMutableArray *arr))myBlock;
#pragma mark   -- -- 推送用户数据
+ (void)requestUserpPushDataWithParameters:(NSDictionary *)parameters Block:(void (^)(NSMutableArray *))myBlock;
//购买金币记录
+ (void)requestBuyMoneyWithParameters:(NSDictionary *)parameters block:(void (^)(NSMutableArray *))myBlock;
//提现记录
+ (void)requestWithdrawalRcordWithParameters:(NSDictionary *)parameters block:(void (^)(NSMutableArray *))myBlock;

//个人首页信息
+ (void)requestPersonalInfoWithBlock:(void(^)(NSMutableArray *arr))myBlock;

//个人约会内容
+ (void)requestPersonAppointContentDataWithParameters:(NSDictionary *)parameters Block:(void(^)(NSArray *arr))myBlock;
#pragma mark   -- -- 增加谁看过我
+ (void)requestAddSeeMeDataWithParameters:(NSDictionary *)parameters Block:(void(^)(NSArray *arr))myBlock;
#pragma mark   -- -- 谁评价我  复用谁看过我的model跟cell
+ (void)requestGetWhoEvaluationMeDataWithParameters:(NSDictionary *)parameters Block:(void(^)(NSArray *arr))myBlock;
#pragma mark   -- -- 增加谁看过我的关系
+ (void)requestAddSeeMeRelationshipDataWithParameters:(NSDictionary *)parameters Block:(void(^)(NSArray *arr))myBlock;

#pragma mark   -- -- 谁看过我列表
+ (void)requestGetSeeMeDataWithParameters:(NSDictionary *)parameters Block:(void(^)(NSArray *arr))myBlock;

#pragma mark   -- -- 判断用户是否购买过
+ (void)requestCheckUserIsBuyedWithParameters:(NSDictionary *)parameters Block:(void(^)(NSArray *arr))myBlock;
#pragma mark   -- -- 消耗钥匙
+ (void)requestSpendUserKeyWithParameters:(NSDictionary *)parameters Block:(void(^)(NSString *codeStr))myBlock;
#pragma mark   -- -- 花费金币
+ (void)requestSpendGoldsWithParameters:(NSDictionary *)parameters Block:(void(^)(NSString *codeStr))myBlock;
#pragma mark   -- -- 邀请类消息
+ (void)requestGtSystemInviteDataWithParameters:(NSDictionary *)parameters Block:(void(^)(NSArray *arr))myBlock;
#pragma mark   -- -- 获取金币消耗
+ (void)requestGettUserWithdrawalDetailDataWithParameters:(NSDictionary *)parameters Block:(void(^)(NSArray *arr))myBlock;
#pragma mark   -- -- 获取通话消耗
+ (void)requestGetUserGoldOrPointDetailDataWithParameters:(NSDictionary *)parameters Block:(void(^)(NSArray *arr))myBlock;

//#pragma mark   -- -- 获取礼物信息
+ (void)requestGetGiftInfomationWithParameters:(NSDictionary *)parameters Block:(void(^)(NSArray *arr))myBlock;
@end
