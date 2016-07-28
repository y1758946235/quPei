//
//  GroupMemberModel.m
//  LvYue
//
//  Created by apple on 15/10/19.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import "GroupMemberModel.h"

@implementation GroupMemberModel

- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        self.memberID = [NSString stringWithFormat:@"%@",dict[@"id"]];
        self.name = [NSString stringWithFormat:@"%@",dict[@"name"]];
        self.isVip = [NSString stringWithFormat:@"%@",dict[@"vip"]];
        self.icon = [NSString stringWithFormat:@"%@%@",IMAGEHEADER,dict[@"icon"]];
    }
    return self;
}

+ (instancetype)groupMemberModelWithDict:(NSDictionary *)dict {
    return [[self alloc] initWithDict:dict];
}

@end
