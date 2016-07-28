//
//  peopleModel.m
//  LvYue
//
//  Created by 郑洲 on 16/4/18.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "PeopleModel.h"

@implementation PeopleModel

- (id)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        _imageName = dict[@"fUser"][@"icon"];
        _peopleName = dict[@"fUser"][@"name"];
        _age = [NSString stringWithFormat:@"%@",dict[@"fUser"][@"age"]];
        _sex = [NSString stringWithFormat:@"%@",dict[@"fUser"][@"sex"]];
        if (![dict[@"skill"][@"price"] isKindOfClass:[NSString class]]) {
            _price = [NSString stringWithFormat:@"%@",dict[@"skill"][@"price"]];
        }else {
            _price = nil;
        }
        if (![dict[@"skill"][@"onlinePrice"] isKindOfClass:[NSString class]]) {
            _onLinePrice = [NSString stringWithFormat:@"%@",dict[@"skill"][@"onlinePrice"]];
        }else {
            _onLinePrice = nil;
        }
        _advantage = [NSString stringWithFormat:@"%@",dict[@"skill"][@"advantage"]];
        _invitedTime = [NSString stringWithFormat:@"%@",dict[@"matchTime"]];
        _distance = [NSString stringWithFormat:@"%@",dict[@"distance"]];
        _peopleId = [NSString stringWithFormat:@"%@",dict[@"fUser"][@"id"]];
        _alipayId = [NSString stringWithFormat:@"%@",dict[@"alipay_id"]];
        _weixinId = [NSString stringWithFormat:@"%@",dict[@"weixin_id"]];
    }
    return self;
}
@end
