//
//  XWOrderModel.m
//  LvYue
//
//  Created by Xia Wei on 15/10/21.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import "XWOrderModel.h"

@implementation XWOrderModel

- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        self.orderID = dict[@"id"];
        self.order_no = dict[@"order_no"];
        self.status = dict[@"status"];
        self.buyer = dict[@"buyer"];
        self.seller = dict[@"seller"];
        self.amount = dict[@"amount"];
        self.content = dict[@"content"];
        self.begin_time = dict[@"begin_time"];
        self.end_time = dict[@"end_time"];
        self.create_time = dict[@"create_time"];
        self.update_time = dict[@"update_time"];
        self.create_ip = dict[@"create_ip"];
        self.channel = dict[@"channel"];
        self.pay = dict[@"pay"];
    }
    return self;
}

@end
