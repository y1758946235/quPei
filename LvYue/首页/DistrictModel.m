//
//  DistrictModel.m
//  LvYue
//
//  Created by X@Han on 16/12/29.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "DistrictModel.h"

@implementation DistrictModel

- (id)initWithDict:(NSDictionary *)dict{
    if (self = [super init]) {
        self.level = dict[@"districtId"];
        
        self.name = dict[@"districtName"];
        self.parent_id = dict[@"parentId"];
        
    }
    return self;
}


+ (id)createModelWithDic:(NSDictionary *)dic{
    return [[self alloc]initWithDict:dic];
}

@end
