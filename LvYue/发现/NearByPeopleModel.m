//
//  NearByPeopleModel.m
//  LvYue
//
//  Created by 广有射怪鸟事 on 15/10/7.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import "NearByPeopleModel.h"

@implementation NearByPeopleModel

- (id)initWithDict:(NSDictionary *)dict{
    if (self = [super init]) {
        self.id = [dict[@"id"] integerValue];
        self.icon = dict[@"icon"];
        self.name = dict[@"name"];
        self.sex = [dict[@"sex"] integerValue];
        self.age = [dict[@"age"] integerValue];
        self.signature = dict[@"signature"];
        self.auth_video = [dict[@"auth_video"] integerValue];
        self.auth_identity = [dict[@"auth_identity"] integerValue];
        self.auth_edu = [dict[@"auth_edu"] integerValue];
        self.auth_car = [dict[@"auth_car"] integerValue];
        self.distance = [dict[@"distance"] floatValue];
        self.vip = [dict[@"vip"] integerValue];
        self.type = [dict[@"type"] integerValue];
    }
    return self;
}

@end
