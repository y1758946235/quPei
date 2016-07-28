//
//  VideoPublishPerson.m
//  LvYue
//
//  Created by Olive on 15/12/31.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import "VideoPublishPerson.h"

@implementation VideoPublishPerson

- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        self.userID = [NSString stringWithFormat:@"%@",dict[@"id"]];
        self.icon = [NSString stringWithFormat:@"%@%@",IMAGEHEADER,dict[@"icon"]];
        self.isVip = [NSString stringWithFormat:@"%@",dict[@"vip"]];
        self.name = [NSString stringWithFormat:@"%@",dict[@"name"]];
        self.sex = [NSString stringWithFormat:@"%@",dict[@"sex"]];
        self.age = [NSString stringWithFormat:@"%@",dict[@"age"]];
    }
    return self;
}

@end
