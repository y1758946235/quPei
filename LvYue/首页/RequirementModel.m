//
//  RequirementModel.m
//  LvYue
//
//  Created by 郑洲 on 16/4/11.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "RequirementModel.h"

@implementation RequirementModel

- (id)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        _requirementDetail = dict[@"detail"];
        _publishTime = dict[@"createTime"];
        _address = dict[@"address"];
        _needId = [NSString stringWithFormat:@"%@",dict[@"id"]];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYY-MM-dd"];
        
        _status = [NSString stringWithFormat:@"%@",dict[@"status"]];
        _appointmentTime = [NSString stringWithFormat:@"%ld", (long)[[dateFormatter dateFromString:[NSString stringWithFormat:@"%@",dict[@"appointmentTime"]]] timeIntervalSince1970]];
        _deadTime = [NSString stringWithFormat:@"%ld", (long)[[dateFormatter dateFromString:[NSString stringWithFormat:@"%@",dict[@"deadTime"]]] timeIntervalSince1970]];
    }
    return self;
}

@end
