//
//  SkillModel.m
//  LvYue
//
//  Created by 郑洲 on 16/4/9.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "SkillModel.h"

@implementation SkillModel

- (id)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        _skillName = dict[@"name"];
        if (![dict[@"price"] isKindOfClass:[NSString class]]) {
            _underLinePrice = [NSString stringWithFormat:@"%@",dict[@"price"]];
        }else {
            _underLinePrice = nil;
        }
        if (![dict[@"onlinePrice"] isKindOfClass:[NSString class]]) {
            _onLinePrice = [NSString stringWithFormat:@"%@",dict[@"onlinePrice"]];
        }else {
            _onLinePrice = nil;
        }
        _skillDetail = dict[@"detail"];
        _publishTime = dict[@"createTime"];
        _skillId = [NSString stringWithFormat:@"%@",dict[@"id"]];
    }
    return self;
}
@end
