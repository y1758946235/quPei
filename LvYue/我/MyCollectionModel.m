//
//  MyCollectionModel.m
//  LvYue
//
//  Created by 广有射怪鸟事 on 15/10/9.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import "MyCollectionModel.h"

@implementation MyCollectionModel

- (id)initWithDict:(NSDictionary *)dict{
    if (self = [super init]) {
        self.content = dict[@"content"];
        self.create_time = dict[@"create_time"];
        self.photo = dict[@"photo"];
        self.title = dict[@"title"];
        self.type = dict[@"type"];
        self.url = dict[@"url"];
        self.collId = dict[@"id"];
        self.userId = dict[@"user_id"];
    }
    return self;
}

@end
