//
//  focusModel.m
//  LvYue
//
//  Created by X@Han on 16/12/29.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "focusModel.h"

@implementation focusModel

- (id)initWithModelDic:(NSDictionary *)dic{
    
    if (self) {
        self.userId = dic[@"userId"];
        self.userIcon = dic[@"userIcon"];
        self.userSex = dic[@"userSex"];
        self.userName = dic[@"userNickname"];
        self.userheight = dic[@"userHeight"];
        self.vip = dic[@"isVip"];
        self.userAge = dic[@"userAge"];
        self.conStella = dic[@"userConstellation"];
        
    }
    return self;
}
+ (id)createWithModelDic:(NSDictionary *)dic{
    return [[self alloc]initWithModelDic:dic];
}

@end
