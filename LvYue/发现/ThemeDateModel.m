//
//  ThemeDateModel.m
//  LvYue
//
//  Created by 广有射怪鸟事 on 15/10/14.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import "ThemeDateModel.h"

@implementation ThemeDateModel

- (id)initWithDict:(NSDictionary *)dict{
    if (self = [super init]) {
        self.icon = [NSString stringWithFormat:@"%@",dict[@"icon"]];
        self.name = [NSString stringWithFormat:@"%@",dict[@"name"]];
        self.master = @"官方管理员";
        self.member_count = [NSString stringWithFormat:@"%@",dict[@"member_count"]];
        self.city = [NSString stringWithFormat:@"%@",dict[@"city"]];
        self.desc = [NSString stringWithFormat:@"%@",dict[@"desc"]];
        self.status = [NSString stringWithFormat:@"%@",dict[@"status"]];
        self.group_id = [NSString stringWithFormat:@"%@",dict[@"id"]];
    }
    return self;
}

@end
