//
//  DayWallet.m
//  LvYue
//
//  Created by KFallen on 16/8/4.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "DayWallet.h"
#import "NSDateFormatter+Category.h"

@implementation DayWallet

- (NSString *)getYearFromNSDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    [dateFormatter setDateFormat:@"dd"];
    NSString *theDay = [dateFormatter stringFromDate:date];//日期的年月日
    
    return theDay;
}


- (instancetype)initWithDict:(NSDictionary *)dict {
    DayWallet* model = [[DayWallet alloc] init];
    
    //NSData *data =[[NSString stringWithFormat:@"%@",dict[@"createTime"]] dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@",dict[@"createTime"]]];
    
    model.day = [NSString stringWithFormat:@"%@日",[self getYearFromNSDate:date]];

    model.ID = [NSString stringWithFormat:@"%@", dict[@"id"]];
    model.price = [NSString stringWithFormat:@"%@", dict[@"price"]];
    model.userId = [NSString stringWithFormat:@"%@", dict[@"userId"]];
    model.smallType = [NSString stringWithFormat:@"%@", dict[@"smallType"]];
    model.type = [NSString stringWithFormat:@"%@", dict[@"type"]];
    return model;
}



@end
