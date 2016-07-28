//
//  GroupModel.m
//  LvYue
//
//  Created by apple on 15/10/18.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import "GroupModel.h"

@implementation GroupModel

- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        self.groupID = [NSString stringWithFormat:@"%@",dict[@"id"]];
        self.easeMob_id = [NSString stringWithFormat:@"%@",dict[@"easemob_id"]];
        self.type = [NSString stringWithFormat:@"%@",dict[@"type"]];
        self.icon = [NSString stringWithFormat:@"%@%@",IMAGEHEADER,dict[@"icon"]];
        self.name = [NSString stringWithFormat:@"%@",dict[@"name"]];
        self.desc = [NSString stringWithFormat:@"%@",dict[@"desc"]];
        self.memberCount = [NSString stringWithFormat:@"%@",dict[@"member_count"]];
        self.maxCount = [NSString stringWithFormat:@"%@",dict[@"max_users"]];
        self.bossID = [NSString stringWithFormat:@"%@",dict[@"create_user_id"]];
    }
    return self;
}


+ (instancetype)groupWithDict:(NSDictionary *)dict {
    return [[self alloc] initWithDict:dict];
}

@end
