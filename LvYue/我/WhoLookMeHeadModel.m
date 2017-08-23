//
//  WhoLookMeHeadModel.m
//  LvYue
//
//  Created by X@Han on 16/12/20.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "WhoLookMeHeadModel.h"

@implementation WhoLookMeHeadModel

- (id)initWithDi:(NSDictionary *)dic{
    
    if (self) {
        self.hadImage = dic[@"userIcon"];
    }
    
    return self;
}
+ (id)creModelWithDic:(NSDictionary *)dic{
    
    return [[self alloc]initWithDi:dic];
}

@end
