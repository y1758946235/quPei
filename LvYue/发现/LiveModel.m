//
//  LiveModel.m
//  LvYue
//
//  Created by LHT on 15/11/17.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import "LiveModel.h"

@implementation LiveModel

- (id)initWithDict:(NSDictionary *)dict{
    if (self = [super init]) {
        self.city = [NSString stringWithFormat:@"%@",dict[@"city"]];
        self.content = [NSString stringWithFormat:@"%@",dict[@"content"]];
        self.create_time = [NSString stringWithFormat:@"%@",dict[@"create_time"]];
        self.create_userID = [NSString stringWithFormat:@"%@",dict[@"create_userID"]];
        self.liveId = [NSString stringWithFormat:@"%@",dict[@"id"]];
        self.photos = [NSString stringWithFormat:@"%@",dict[@"photos"]];
        self.price = [NSString stringWithFormat:@"%@",dict[@"price"]];
        self.update_time = [NSString stringWithFormat:@"%@",dict[@"update_time"]];
        self.icon = [NSString stringWithFormat:@"%@",dict[@"user"][@"icon"]];
        self.userId = [NSString stringWithFormat:@"%@",dict[@"user"][@"id"]];
        self.name = [NSString stringWithFormat:@"%@",dict[@"user"][@"name"]];
        self.vip = [NSString stringWithFormat:@"%@",dict[@"user"][@"vip"]];
        self.contact = [NSString stringWithFormat:@"%@",dict[@"user"][@"contact"]];
        self.cityName = [NSString stringWithFormat:@"%@",dict[@"name"]];
    }
    return self;
}

@end
