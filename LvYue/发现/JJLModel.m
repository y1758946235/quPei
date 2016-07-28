//
//  JJLModel.m
//  LvYue
//
//  Created by 广有射怪鸟事 on 15/10/17.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import "JJLModel.h"

@implementation JJLModel

- (id)initWithDict:(NSDictionary *)dict{
    if (self = [super init]) {
        self.icon = dict[@"user"][@"icon"];
        self.create_time = dict[@"icon"];
        self.noticeListId = dict[@"id"];
        self.notice_detail = dict[@"notice_detail"];
        self.notice_user = dict[@"notice_user"];
        self.update_time = dict[@"update_time"];
        self.age = dict[@"user"][@"age"];
        self.auth_car = dict[@"user"][@"auth_car"];
        self.auth_edu = dict[@"user"][@"auth_edu"];
        self.auth_identity = dict[@"user"][@"auth_identity"];
        self.auth_video = dict[@"user"][@"auth_video"];
        self.type = dict[@"user"][@"type"];
        self.sex = dict[@"user"][@"sex"];
        self.distance = dict[@"distance"];
        self.minute = dict[@"minute"];
        self.vip = dict[@"user"][@"vip"];
        self.userId = [NSString stringWithFormat:@"%@",dict[@"user_id"]];
    }
    return self;
}

@end
