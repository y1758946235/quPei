//
//  IconModel.h
//  LvYue
//
//  Created by X@Han on 17/1/5.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IconModel : NSObject


@property(copy,nonatomic)NSString *instesd;  //感兴趣
@property(copy,nonatomic)NSString *aboutAppoint; //我的约会
@property(copy,nonatomic)NSString *money;  //金币
@property(copy,nonatomic)NSString *userKey;  //钥匙
@property(copy,nonatomic)NSString *gift;  //礼物
@property(copy,nonatomic)NSString *userPoint;  //积分
@property(copy,nonatomic)NSString *vipLevel;  //积分

- (id)initWithModelDic:(NSDictionary *)dic;
+ (id)createWithModelDic:(NSDictionary *)dic;


@end
