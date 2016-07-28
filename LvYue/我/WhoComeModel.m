//
//  WhoComeModel.m
//  LvYue
//
//  Created by 広有射怪鸟事 on 15/12/18.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import "WhoComeModel.h"
#import "NSDate+Extension.h"

@implementation WhoComeModel

- (id)initWithDict:(NSDictionary *)dict{
    if (self = [super init]) {
        self.headIcon = [NSString stringWithFormat:@"%@",dict[@"icon"]];
        self.userId = [NSString stringWithFormat:@"%@",dict[@"id"]];
        self.name = [NSString stringWithFormat:@"%@",dict[@"name"]];
        self.sign = [NSString stringWithFormat:@"%@",dict[@"signature"]];
        self.oriTime = [NSString stringWithFormat:@"%@",dict[@"visitor_time"]];
        self.last_time = [self getTime];
    }
    return self;
}

- (NSString *)getTime{

    //_created_at = @"Thu Oct 16 17:06:25 +0800 2012";

    //日期格式器
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];

    // E:星期几
    // M:月份
    // d:几号(这个月的第几天)
    // H:24小时制的小时
    // m:分钟
    // s:秒
    // y:年
    // _created_at == Thu Oct 16 17:06:25 +0800 2014
    //读取当前的日期格式，然后自动转化为yyyy-MM-dd HH:mm:ss 0000
//    NSRange range = [self.oriTime rangeOfString:@"."];
//    NSString *final = [self.oriTime substringToIndex:range.location];
    fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
#warning  如果是真机调试，转换这种欧美时间，需要设置locale
    fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    //微博的创建日期
    NSDate *creatDate = [fmt dateFromString:self.oriTime];
    //当前时间
    NSDate *now = [NSDate date];
    //日历对象（方便两个日期之前的差距比较）
    NSCalendar *calendar = [NSCalendar currentCalendar];

    //计算两个日期之间的差值,NSCalendarUnit枚举代表想获得哪些差值
    NSCalendarUnit unit = kCFCalendarUnitYear | kCFCalendarUnitMonth | kCFCalendarUnitDay | kCFCalendarUnitHour | kCFCalendarUnitMinute;
    NSDateComponents *cmps = [calendar components:unit fromDate:creatDate toDate:now options:0];

    if ([creatDate isThisYear]) {
        if ([creatDate isYesterday]) {
            fmt.dateFormat = @"昨天 HH:mm";
            self.timeType = @"1";
            return [fmt stringFromDate:creatDate];
        }else if ([creatDate isToday]){
            self.timeType = @"1";
            if (cmps.hour > 1) {
                return [NSString stringWithFormat:@"%d小时前",(int)cmps.hour];
            }else if (cmps.minute > 1){
                return [NSString stringWithFormat:@"%d分钟前",(int)cmps.minute];
            }else{
                return @"刚刚";
            }
        }else{//今年其他日子
            self.timeType = @"2";
            fmt.dateFormat = @"MM-dd HH:mm";
            return [fmt stringFromDate:creatDate];
        }
    }else{//非今年
        self.timeType = @"2";
        fmt.dateFormat = @"yyyy-MM-dd HH:mm";
        return [fmt stringFromDate:creatDate];
    }

    return self.oriTime;
}

@end
