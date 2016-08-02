//
//  TopicTitle.m
//  LvYue
//
//  Created by KFallen on 16/8/2.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "TopicTitle.h"

@implementation TopicTitle

+ (instancetype)topicTitleWithDict:(NSDictionary *)dict {
    TopicTitle* model = [[TopicTitle alloc] init];
    model.ID = [NSString stringWithFormat:@"%@",dict[@"id"]];
    model.back_img = [NSString stringWithFormat:@"%@",dict[@"back_img"]];
    model.intro = [NSString stringWithFormat:@"%@",dict[@"intro"]];
    model.title = [NSString stringWithFormat:@"%@",dict[@"title"]];
    model.partNums = [NSString stringWithFormat:@"%@",dict[@"partNums"]];
    return model;
}

@end
