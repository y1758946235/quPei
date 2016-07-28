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
        self.id = dict[@"id"];
        self.level = dict[@"level"];
        self.name = dict[@"name"];
        self.parent_id = dict[@"parent_id"];
        self.status = dict[@"status"];
    }
    return self;
}

@end
