//
//  LocationModel.m
//  LvYue
//
//  Created by 広有射怪鸟事 on 15/10/21.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import "LocationModel.h"

@implementation LocationModel

- (id)initWithDict:(NSDictionary *)dict{
    if (self = [super init]) {
        self.level = dict[@"provinceId"];
        
        self.name = dict[@"provinceName"];
        self.parent_id = dict[@"parentId"];
        
    }
    return self;
}

@end
