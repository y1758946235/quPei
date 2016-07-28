//
//  SystemMessageModel.m
//  LvYue
//
//  Created by apple on 15/10/27.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import "SystemMessageModel.h"

@implementation SystemMessageModel

- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        self.content = dict[@"content"];
        self.timeStamp = dict[@"create_time"];
        self.messageID = dict[@"id"];
        self.title = dict[@"title"];
    }
    return self;
}


+ (instancetype)systemMessageModelWithDict:(NSDictionary *)dict {
    return [[self alloc] initWithDict:dict];
}

@end
