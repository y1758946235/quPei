//
//  WXModel.m
//  LvYue
//
//  Created by 広有射怪鸟事 on 15/10/28.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import "WXModel.h"

@implementation WXModel

- (id)initWithDict:(NSDictionary *)dict{
    if (self = [super init]) {
        self.appid = dict[@"appid"];
        self.nonceStr = dict[@"noncestr"];
        self.package = dict[@"package"];
        self.partnerid = dict[@"partnerid"];
        self.prepayid = dict[@"prepayid"];
        self.sign = dict[@"sign"];
        self.timestamp = dict[@"timestamp"];
        
    }
    return self;
}

@end
