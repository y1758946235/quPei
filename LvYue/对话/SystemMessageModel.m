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
        self.content = dict[@"messageContent"];
        self.timeStamp = dict[@"createTime"]  ;
        self.messageID = dict[@"id"];
        self.title = dict[@"title"];
        if ([CommonTool dx_isNullOrNilWithObject:self.messageID ]) {
            self.messageID  =@"";
        }
        if ([CommonTool dx_isNullOrNilWithObject:self.title ]) {
            self.title  =@"";
        }
        self.userIcon = dict[@"userIcon"];
        self.userId = dict[@"userId"];
        self.userNickname = dict[@"userNickname"];
        
        CGRect size = [self.content boundingRectWithSize:CGSizeMake(SCREEN_WIDTH-96, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]} context:nil];
        self.descriptionHeight =  size.size.height;
        self.descriptionWieth =  size.size.width;
        
        self.cellHeight =  self.descriptionHeight+60;
    }
    

    return self;
}


+ (instancetype)systemMessageModelWithDict:(NSDictionary *)dict {
    return [[self alloc] initWithDict:dict];
}

@end
