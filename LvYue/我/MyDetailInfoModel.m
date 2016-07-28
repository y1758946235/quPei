//
//  MyDetailInfoModel.m
//  LvYue
//
//  Created by 广有射怪鸟事 on 15/10/8.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import "MyDetailInfoModel.h"

@implementation MyDetailInfoModel

- (id)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        if ([dict[@"city"] isKindOfClass:[NSNull class]]) {
            self.city = @"";
        } else {
            self.city = [NSString stringWithFormat:@"%@", dict[@"city"]];
        }
        if ([dict[@"city"] isKindOfClass:[NSNull class]]) {
            self.cityName = @"";
        } else {
            self.cityName = [NSString stringWithFormat:@"%@", dict[@"cityName"]];
        }
        if ([dict[@"country"] isKindOfClass:[NSNull class]]) {
            self.countryName = @"";
        } else {
            self.countryName = [NSString stringWithFormat:@"%@", dict[@"countryName"]];
        }
        if ([dict[@"province"] isKindOfClass:[NSNull class]]) {
            self.provinceName = @"";
        } else {
            self.provinceName = [NSString stringWithFormat:@"%@", dict[@"provinceName"]];
        }
        if ([dict[@"contact"] isKindOfClass:[NSNull class]]) {
            self.contact = @"";
        } else {
            self.contact = [NSString stringWithFormat:@"%@", dict[@"contact"]];
        }
        if ([dict[@"country"] isKindOfClass:[NSNull class]]) {
            self.country = @"";
        } else {
            self.country = [NSString stringWithFormat:@"%@", dict[@"country"]];
        }
        self.explain = dict[@"explain"];
        if ([dict[@"industry"] isKindOfClass:[NSNull class]]) {
            self.industry = @"";
        } else {
            self.industry = [NSString stringWithFormat:@"%@", dict[@"industry"]];
        }
        self.provide_stay = [dict[@"provide_stay"] integerValue];
        if ([dict[@"province"] isKindOfClass:[NSNull class]]) {
            self.province = @"";
        } else {
            self.province = [NSString stringWithFormat:@"%@", dict[@"province"]];
        }
        if ([dict[@"service_content"] isKindOfClass:[NSNull class]]) {
            self.service_content = @"";
        } else {
            self.service_content = [NSString stringWithFormat:@"%@", dict[@"service_content"]];
        }
        if ([dict[@"service_price"] isKindOfClass:[NSNull class]]) {
            self.service_price = @"0";
        } else {
            self.service_price = [NSString stringWithFormat:@"%@", dict[@"service_price"]];
        }
        if ([dict[@"vip_time"] isKindOfClass:[NSNull class]]) {
            self.vip_time = @"";
        } else {
            self.vip_time = [NSString stringWithFormat:@"%@", dict[@"vip_time"]];
        }
        if ([dict[@"alipay_id"] isKindOfClass:[NSNull class]]) {
            self.alipay_id = @"";
        } else {
            self.alipay_id = [NSString stringWithFormat:@"%@", dict[@"alipay_id"]];
        }
        if ([dict[@"weixin_id"] isKindOfClass:[NSNull class]]) {
            self.weixin_id = @"";
        } else {
            self.weixin_id = [NSString stringWithFormat:@"%@", dict[@"weixin_id"]];
        }
        if ([dict[@"auth_video_path"] isKindOfClass:[NSNull class]]) {
            self.authVideoPath = @"";
        } else {
            self.authVideoPath = dict[@"auth_video_path"];
        }

        self.tradeNum = [dict[@"tradeNum"] integerValue];
        self.status   = [NSString stringWithFormat:@"%@", dict[@"status"]];
    }

    return self;
}

@end
