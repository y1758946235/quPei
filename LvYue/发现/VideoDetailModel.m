//
//  VideoDetailModel.m
//  LvYue
//
//  Created by Olive on 15/12/31.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import "VideoDetailModel.h"

@implementation VideoDetailModel

- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        self.publishTime = [NSString stringWithFormat:@"%@",dict[@"time"]];
        self.videoUrl = [NSString stringWithFormat:@"%@%@",IMAGEHEADER,dict[@"url"]];
        self.videoDesc = [NSString stringWithFormat:@"%@",dict[@"desc"]];
        self.person = [[VideoPublishPerson alloc] initWithDict:@{@"id":dict[@"id"],@"name":dict[@"name"],@"icon":dict[@"icon"],@"vip":dict[@"vip"],@"sex":dict[@"sex"],@"age":dict[@"age"]}];
    }
    return self;
}

@end
