//
//  CityModel.m
//  LvYue
//
//  Created by X@Han on 16/12/29.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "CityModel.h"

@implementation CityModel

- (id)initWithDict:(NSDictionary *)dict{
    if (self = [super init]) {
        self.level = dict[@"cityId"];
        
        self.name = dict[@"cityName"];
        self.parent_id = dict[@"parentId"];
        
    }
    return self;
}


@end
