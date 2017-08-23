//
//  YHBModel.m
//  LvYue
//
//  Created by X@Han on 17/3/2.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "YHBModel.h"

@implementation YHBModel

+(instancetype)modelWithDict:(NSDictionary *)dict{
    return [[YHBModel alloc]initWithDict:dict];
}
-(instancetype)initWithDict:(NSDictionary *)dict{
    if (self = [super init]) {
    }
    return self;
}

@end
