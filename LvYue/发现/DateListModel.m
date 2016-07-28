//
//  DateListModel.m
//  LvYue
//
//  Created by 广有射怪鸟事 on 15/10/13.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import "DateListModel.h"

@implementation DateListModel

- (id)initWithDict:(NSDictionary *)dict{
    
    if (self = [super init]) {
        self.content = dict[@"content"];
        self.create_time = dict[@"create_time"];
        self.create_user_id = dict[@"create_user_id"];
        self.group_id = dict[@"group_id"];
        self.photos = dict[@"photos"];
        self.status = dict[@"status"];
        self.type = dict[@"type"];
        self.update_time = dict[@"update_time"];
        if ([dict[@"distance"] isKindOfClass:[NSNull class]]) {
            self.distance = @"";
        }
        else{
            self.distance = [NSString stringWithFormat:@"%@",dict[@"distance"]];
        }
        self.user = dict[@"user"];
        self.lyId = [NSString stringWithFormat:@"%@",dict[@"id"]];
    }
    
    return self;
}

@end
