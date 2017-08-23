//
//  IntegralModel.m
//  LvYue
//
//  Created by X@Han on 17/7/5.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "IntegralModel.h"

@implementation IntegralModel
- (id)initWithModelDic:(NSDictionary *)dic{
    if (self) {
        self.userId = dic[@"userId"];
        self.userNickname = dic[@"userNickname"];
        self.type = dic[@"type"];
        self.userGold = dic[@"userGold"];
        self.userPoint = dic[@"userPoint"];
        self.createTime = dic[@"createTime"];
    }
    return self;
}


+ (id)createWithModelDic:(NSDictionary *)dic{
    return [[self alloc]initWithModelDic:dic];
}

@end
