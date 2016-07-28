//
//  CheckMessageModel.m
//  LvYue
//
//  Created by apple on 15/10/12.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import "CheckMessageModel.h"

@implementation CheckMessageModel

- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        self.messageID = [NSString stringWithFormat:@"%@",dict[@"id"]];
        self.senderID = [NSString stringWithFormat:@"%@",dict[@"user_id"]];
        self.groupID = [NSString stringWithFormat:@"%@",dict[@"other_id"]];
        self.easemob_id = [NSString stringWithFormat:@"%@",dict[@"easemob_id"]];
        self.icon = [NSString stringWithFormat:@"%@%@",IMAGEHEADER,dict[@"user"][@"icon"]];
        self.name = [NSString stringWithFormat:@"%@",dict[@"user"][@"name"]];
        self.requestInfo = [NSString stringWithFormat:@"%@",dict[@"request_info"]];
        self.type = [NSString stringWithFormat:@"%@",dict[@"type"]];
        self.status = [NSString stringWithFormat:@"%@",dict[@"status"]];
    }
    return self;
}

+ (instancetype)checkMessageModelWithDict:(NSDictionary *)dict {
    
    return [[self alloc] initWithDict:dict];
}

@end
