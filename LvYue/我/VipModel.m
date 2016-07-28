//
//  VipModel.m
//  LvYue
//
//  Created by 广有射怪鸟事 on 15/10/15.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import "VipModel.h"

@implementation VipModel

- (id)initWithDict:(NSDictionary *)dict{
    if (self = [super init]) {
        self._input_charset = dict[@"_input_charset"];
        self.body = dict[@"body"];
        self.it_b_pay = dict[@"it_b_pay"];
        self.notify_url = dict[@"notify_url"];
        self.out_trade_no = dict[@"out_trade_no"];
        self.partner = dict[@"partner"];
        self.payment_type = dict[@"payment_type"];
        self.rsa_key = dict[@"rsa_key"];
        self.seller_id = dict[@"seller_id"];
        self.service = dict[@"service"];
        self.subject = dict[@"subject"];
        self.total_fee = dict[@"total_fee"];
    }
    return self;
}

@end
