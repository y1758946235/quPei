//
//  FriendsCircleMessage.m
//  LvYueDemo
//
//  Created by 蒋俊 on 15/10/19.
//  Copyright (c) 2015年 vison. All rights reserved.
//

#import "FriendsCircleMessage.h"
#import "NSDate+Extension.h"

@implementation FriendsCircleMessage

- (id)initWithDict:(NSDictionary *)dict{
    
    if (self = [super init]) {
        
        _headImgStr = [NSString stringWithFormat:@"%@%@",IMAGEHEADER,dict[@"icon"]];
        _name = dict[@"notice_user"];
        _content = dict[@"notice_detail"];
        _time = dict[@"create_time"];
        _commentNum = [NSString stringWithFormat:@"%lu",(unsigned long)[dict[@"commentList"]count]];
        _praiseNum = [NSString stringWithFormat:@"%lu",(unsigned long)[dict[@"praiseList"]count]];
        _imageStr = dict[@"photos"];
        _commentArray = dict[@"commentList"];
        _userId = dict[@"user_id"];
        if ([[NSString stringWithFormat:@"%@",dict[@"comment_user"]] isEqualToString:@"<null>"] || [[NSString stringWithFormat:@"%@",dict[@"comment_user"]] isKindOfClass:[NSNull class]]) {
            _commentUserName = @"";
        } else {
            _commentUserName = [NSString stringWithFormat:@"%@",dict[@"comment_user"]];
        }
        if ([[NSString stringWithFormat:@"%@",dict[@"reply_user"]] isEqualToString:@"<null>"] || [[NSString stringWithFormat:@"%@",dict[@"reply_user"]] isKindOfClass:[NSNull class]]) {
            _replyUserName = @"";
        } else {
            _replyUserName = [NSString stringWithFormat:@"%@",dict[@"reply_user"]];
        }
        
        //热门话题
        self.isHot = [NSString stringWithFormat:@"%@", dict[@"isHot"]]; //1是 2不是
        self.videoUrl = [[NSString stringWithFormat:@"%@%@",IMAGEHEADER, dict[@"videoUrl"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        //self.videoUrl = [NSString stringWithFormat:@"%@%@",IMAGEHEADER, dict[@"videoUrl"]];
        self.nType = [NSString stringWithFormat:@"%@", dict[@"nType"]];
        self.hotName = [NSString stringWithFormat:@"%@",dict[@"hotName"]];
        self.hot_id = [NSString stringWithFormat:@"%@", dict[@"hot_id"]];
        self.ID = [NSString stringWithFormat:@"%@",dict[@"id"]];
        
    }
    return self;
}

- (void)setCommentList:(NSMutableArray *)commentArray{
    
    _commentArray = commentArray;
}

- (void)setPraiseList:(NSMutableArray *)praiseArray{
    
    _praiseNum = [NSString stringWithFormat:@"%ld",(long)praiseArray.count];
}

- (CGFloat)returnCellHeight{
    
    
    //判断   保证imageArray不为null 或者 @“”
    CGFloat imageHeight = 0.0;
    if (![_imageStr isKindOfClass:[NSNull class]] && _imageStr.length) {
        //分割字符串,count - 1 如果有图的话会多一个 需要减去
        NSArray *imageArray = [_imageStr componentsSeparatedByString:@";"]; //从字符A中分隔成2个元素的数组
        NSMutableArray *finalImageArray = [NSMutableArray arrayWithArray:imageArray];
        //如果最后一个图片url为@“”,则删除最后一个url
        if ([finalImageArray.lastObject isEqualToString:@""]) {
            [finalImageArray removeLastObject];
        }
        //获取照片所需的高度
        if ((finalImageArray.count)%3 == 0) {
            imageHeight = finalImageArray.count/3*80;
        }else{
            imageHeight = (finalImageArray.count/3+1)*80;
        }
    }
    
    if (imageHeight == 0) {
        imageHeight += 5;
    }
    
    if ([self.nType isEqualToString:@"2"]) { //视频
        imageHeight  = 130;
    }

    //获取评论的所需高度
    CGFloat commentHeight = 0;
    for (NSDictionary *dict in _commentArray) {
        NSString *finalStr = @"";
        NSString *commentStr = dict[@"detail"];
        if ([_replyUserName isEqualToString:@""]) {
            finalStr = [NSString stringWithFormat:@"%@:%@",_commentUserName,commentStr];
        } else {
            finalStr = [NSString stringWithFormat:@"%@回复%@:%@",_commentUserName,_replyUserName,commentStr];
        }
        
        CGSize contentSize = [finalStr sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(SCREEN_WIDTH - 50 - 5 - 20 - 30, 1000) lineBreakMode:UILineBreakModeCharacterWrap];
        commentHeight += contentSize.height + 10;
    }
    
    if (commentHeight != 0) {
        //如果有评论，加10的间距
        commentHeight += 10;
    }
    
    //获取文本所需的高度
    CGSize contentSize = [_content sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(SCREEN_WIDTH - 50 - 5, 1000) lineBreakMode:UILineBreakModeCharacterWrap];
    
    return imageHeight + contentSize.height + commentHeight + 95 - 10;
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
    fmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
#warning  如果是真机调试，转换这种欧美时间，需要设置locale
    fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    //微博的创建日期
    NSDate *creatDate = [fmt dateFromString:_time];
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
    
    return _time;
}

@end
