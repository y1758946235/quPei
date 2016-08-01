//
//  MyInfoModel.m
//  LvYue
//
//  Created by 广有射怪鸟事 on 15/10/8.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import "MyInfoModel.h"

@implementation MyInfoModel

- (id)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        if ([dict[@"age"] isKindOfClass:[NSNull class]]) {
            self.age = 0;
        } else {
            self.age = [dict[@"age"] integerValue];
        }
        self.auth_car      = [dict[@"auth_car"] integerValue];
        self.auth_edu      = [dict[@"auth_edu"] integerValue];
        self.auth_identity = [dict[@"auth_identity"] integerValue];
        self.auth_video    = [dict[@"auth_video"] integerValue];
        self.edu           = [NSString stringWithFormat:@"%@", dict[@"edu"]];
        self.icon          = [NSString stringWithFormat:@"%@", dict[@"icon"]];
        self.id            = [dict[@"id"] integerValue];
        self.mobile        = [NSString stringWithFormat:@"%@", dict[@"mobile"]];
        self.name          = [NSString stringWithFormat:@"%@", dict[@"name"]];
        self.score         = [dict[@"score"] integerValue];
        self.sex           = [dict[@"sex"] integerValue];
        self.signature     = [NSString stringWithFormat:@"%@", dict[@"signature"]];
        self.type          = [dict[@"type"] integerValue];
        self.vip           = [dict[@"vip"] integerValue];
        if ([dict[@"is_show"] isKindOfClass:[NSNull class]]) {
            self.is_show = @"";
        } else {
            self.is_show = [NSString stringWithFormat:@"%@", dict[@"is_show"]];
        }
        self.provide_stay = [NSString stringWithFormat:@"%@", dict[@"provide_stay"]];
        self.hongdou      = [NSString stringWithFormat:@"%@", dict[@"hongdou"]];
        self.charm        = [dict[@"charm"] integerValue];
        self.wealth       = [dict[@"wealth"] integerValue];

        self.isFocus  = [dict[@"isFocus"] boolValue];
        self.fansNum  = [dict[@"fansNum"] integerValue] ?: [dict[@"fansCount"] integerValue];
        self.focusNum = [dict[@"focusCount"] integerValue];
    }

    return self;
}

@end
