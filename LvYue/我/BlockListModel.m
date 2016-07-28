//
//  BlockListModel.m
//  LvYue
//
//  Created by 広有射怪鸟事 on 16/1/19.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "BlockListModel.h"

@implementation BlockListModel

- (id)initWithDict:(NSDictionary *)dict{
    if (self = [super init]) {
        self.icon = [NSString stringWithFormat:@"%@",dict[@"icon"]];
        self.userId = [NSString stringWithFormat:@"%@",dict[@"id"]];
        self.name = [NSString stringWithFormat:@"%@",dict[@"name"]];
    }
    return self;
}

@end
