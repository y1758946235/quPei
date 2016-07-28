//
//  OrderModel.m
//  LvYue
//
//  Created by 广有射怪鸟事 on 15/10/16.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import "OrderModel.h"

@implementation OrderModel

- (id)initWithDict:(NSDictionary *)dict{
    if (self = [super init]) {
        self.amount = dict[@"amount"];
        self.begin_time = dict[@"begin_time"];
        self.buyer = dict[@"buyer"];
        self.buyer_name = dict[@"buyer_name"];
        self.channel = dict[@"channel"];
        self.content = dict[@"content"];
        self.create_ip = dict[@"create_ip"];
        self.create_time = dict[@"create_time"];
        self.end_time = dict[@"end_time"];
        if ([dict[@"evaluation"] isKindOfClass:[NSNull class]]) {
            self.evaluation = @"";
        }
        else{
            self.evaluation = dict[@"evaluation"];
        }
        self.orderId = dict[@"id"];
        self.order_no = dict[@"order_no"];
        self.out_order_no = dict[@"out_order_no"];
        self.pay = dict[@"pay"];
        if ([dict[@"refund_no"] isKindOfClass:[NSNull class]]) {
            self.refund_no = @"";
        }
        else{
            self.refund_no = dict[@"refund_no"];
        }
        if ([dict[@"end_time"] isKindOfClass:[NSNull class]]) {
            self.end_time = @"";
        }
        else{
            self.end_time = dict[@"end_time"];
        }
        self.seller = dict[@"seller"];
        self.seller_name = dict[@"seller_name"];
        self.status = dict[@"status"];
        self.update_time = dict[@"update_time"];
        self.buyer_mobile = dict[@"buyer_mobile"];
        self.seller_mobile = dict[@"seller_mobile"];
    }
    return self;
}

@end
