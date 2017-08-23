//
//  TopicTagModel.m
//  LvYue
//
//  Created by X@Han on 17/6/8.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "TopicTagModel.h"

@implementation TopicTagModel
- (id)initWithModelDic:(NSDictionary *)dic{
    if (self) {
        self.shareTopicId = dic[@"videoTopicId"];
        self.shareTopicName= dic[@"videoTopicName"];
    }
    return self;
}
+ (id)createWithModelDic:(NSDictionary *)dic{
    
    return [[self alloc]initWithModelDic:dic];
    
}
@end
