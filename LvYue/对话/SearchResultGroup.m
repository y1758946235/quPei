//
//  SearchResultGroup.m
//  LvYue
//
//  Created by apple on 15/10/18.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import "SearchResultGroup.h"

@implementation SearchResultGroup

- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        self.groupID = [NSString stringWithFormat:@"%@",dict[@"id"]];
        self.easemob_id = [NSString stringWithFormat:@"%@",dict[@"easemob_id"]];
        self.name = [NSString stringWithFormat:@"%@",dict[@"name"]];
        self.desc = [NSString stringWithFormat:@"%@",dict[@"desc"]];
        self.icon = [NSString stringWithFormat:@"%@%@",IMAGEHEADER,dict[@"icon"]];
        self.memberCount = [NSString stringWithFormat:@"%@",dict[@"member_count"]];
        self.maxCount = [NSString stringWithFormat:@"%@",dict[@"max_users"]];
    }
    return self;
}


+ (instancetype)searchResultGroupWithDict:(NSDictionary *)dict {
    return [[self alloc] initWithDict:dict];
}


@end
