//
//  VideoDetail.m
//  LvYue
//
//  Created by Olive on 16/1/6.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "VideoDetail.h"
#import "NSDate+Extension.h"
#import "NSString+StringFrame.h"

@implementation VideoDetail

- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        self.videoID = [NSString stringWithFormat:@"%@",dict[@"id"]];
        self.url = [NSString stringWithFormat:@"%@%@",IMAGEHEADER,dict[@"video"]];
        self.publishTime = [NSString stringWithFormat:@"%@",dict[@"create_time"]];
        self.videoDesc = [NSString stringWithFormat:@"%@",dict[@"describe"]];
        self.videoType = [NSString stringWithFormat:@"%@",dict[@"type"]];
        NSDictionary *ownerDict = @{@"user_id":dict[@"user_id"],@"name":dict[@"name"],@"icon":dict[@"icon"],@"vip":dict[@"vip"],@"sex":dict[@"sex"],@"age":dict[@"age"]};
        self.praiseNum = [NSString stringWithFormat:@"%@",dict[@"praise_num"]];
        self.isPraiseByMe = [NSString stringWithFormat:@"%@",dict[@"ispraise"]];
        self.owner = [[VideoOwner alloc] initWithDict:ownerDict];
    }
    return self;
}


- (NSString *)getPerfectTime {
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
    fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
   // #warning  如果是真机调试，转换这种欧美时间，需要设置locale
    fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    //微博的创建日期
    NSDate *creatDate = [fmt dateFromString:self.publishTime];
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
            return [fmt stringFromDate:creatDate];
        }else if ([creatDate isToday]){
            
            if (cmps.hour > 1) {
                return [NSString stringWithFormat:@"%d小时前",(int)cmps.hour];
            }else if (cmps.minute > 1){
                return [NSString stringWithFormat:@"%d分钟前",(int)cmps.minute];
            }else{
                return @"刚刚";
            }
        }else{//今年其他日子
            fmt.dateFormat = @"MM-dd HH:mm";
            return [fmt stringFromDate:creatDate];
        }
    }else{//非今年
        fmt.dateFormat = @"yyyy-MM-dd HH:mm";
        return [fmt stringFromDate:creatDate];
    }
    
    return self.publishTime;
}


- (CGFloat)getCellHeight {
    //获得视频描述尺寸
    CGSize contentSize = [self.videoDesc boundingRectWithSize:CGSizeMake(kMainScreenWidth-30, 1000) font:[UIFont systemFontOfSize:12.0]];
    if ([self.videoDesc isEqualToString:@"(null)"]) {
        self.videoDesc = @"视频介绍信息是个谜";
        contentSize.height = 4;
    }
    //计算总的cell高度
    return (15+50+10+contentSize.height+10+220+10+1+10+25+10 - 10);
}


- (CGFloat)getDescHeight {
    //获得视频描述尺寸
    CGSize contentSize = [self.videoDesc boundingRectWithSize:CGSizeMake(kMainScreenWidth-30, 1000) font:[UIFont systemFontOfSize:12.0]];
    return contentSize.height;
}


- (CGFloat)getNameWidth {
    CGSize contentSize = [self.owner.name boundingRectWithSize:CGSizeMake(120, 20) font:[UIFont systemFontOfSize:14.0]];
    return contentSize.width;
}


@end
