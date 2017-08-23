//
//  IntegralModel.h
//  LvYue
//
//  Created by X@Han on 17/7/5.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IntegralModel : NSObject
@property(copy,nonatomic)NSString *userId;
@property(copy,nonatomic)NSString *userNickname;
@property(copy,nonatomic)NSString *type;
@property(copy,nonatomic)NSString *userGold;
@property(copy,nonatomic)NSString *userPoint;
@property(copy,nonatomic)NSString *createTime;
- (id)initWithModelDic:(NSDictionary *)dic;
+ (id)createWithModelDic:(NSDictionary *)dic;
@end
