//
//  VideoOwner.m
//  LvYue
//
//  Created by Olive on 16/1/6.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "VideoOwner.h"

@implementation VideoOwner

- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        self.userID = [NSString stringWithFormat:@"%@",dict[@"user_id"]];
        self.name = [NSString stringWithFormat:@"%@",dict[@"name"]];
        self.icon = [NSString stringWithFormat:@"%@%@",IMAGEHEADER,dict[@"icon"]];
        self.isVip = [NSString stringWithFormat:@"%@",dict[@"vip"]];
        self.sex = [NSString stringWithFormat:@"%@",dict[@"sex"]];
        self.age = [NSString stringWithFormat:@"%@",dict[@"age"]];
    }
    return self;
}

@end
