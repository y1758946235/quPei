//
//  CommonTool.m
//  Seedling
//
//  Created by whkj on 16/6/3.
//  Copyright © 2016年 whkj. All rights reserved.
//

#import "CommonTool.h"
#import "CustomHeader.h"
#import<CommonCrypto/CommonDigest.h>
//#import "MyTabBarController.h"
//#import "LoginViewController.h"
//#import "Question and answerViewController.h"

@implementation CommonTool

static CommonTool *instance = nil;
+ (instancetype)sharedCommonTool{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self class] new];
    });
    return instance;
    
}

////存储access token
//+ (void)saveAccessTokenToLocal:(NSDictionary *)aDic{
//    NSString *userId = aDic[@"userId"];
//    NSString *userNickname = aDic[@"userNickname"];
//
//    NSString *userCaptcha = aDic[@"userCaptcha"];
//
//    
//   
//    
//    [USER_DEFAULTS setObject:userId forKey:@"userId"];
//
//    [USER_DEFAULTS setObject:userNickname forKey:@"userNickname"];
//   
//      [USER_DEFAULTS setObject:userCaptcha forKey:@"userCaptcha"];
//
//    [USER_DEFAULTS synchronize];
//}

+ (NSString *)getDeviceToken{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *Str = [defaults objectForKey:@"deviceToken"];
    if ([CommonTool dx_isNullOrNilWithObject:Str]) {
        return @"bb63b19106f3108798b7a271447e40df8a75c0b7cec8d99f54b43728713edc37";
    }
    
    return Str;
}
+ (NSString *)getUserCaptcha{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *Str = [defaults objectForKey:@"userCaptcha"];
    if ([CommonTool dx_isNullOrNilWithObject:Str]) {
        return @"";
    }

    return Str;
}
+ (NSString *)getUserID{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *Str = [NSString stringWithFormat:@"%@",[defaults objectForKey:@"userId"]];
    if ([CommonTool dx_isNullOrNilWithObject:Str]) {
        return @"";
    }
    
    return Str;
}
+ (NSString *)getUserIcon{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *Str = [NSString stringWithFormat:@"%@",[defaults objectForKey:@"userIcon"]];
    if ([CommonTool dx_isNullOrNilWithObject:Str]) {
        return @"";
    }
    
    return Str;
}
+ (NSString *)getOtherUserIcon{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *Str = [NSString stringWithFormat:@"%@",[defaults objectForKey:@"otherUserIcon"]];
    if ([CommonTool dx_isNullOrNilWithObject:Str]) {
        return @"";
    }
    
    return Str;
}
+ (NSString *)getUserNickname{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *Str = [NSString stringWithFormat:@"%@",[defaults objectForKey:@"userNickname"]];
    if ([CommonTool dx_isNullOrNilWithObject:Str]) {
        return @"";
    }
    
    return Str;
}
+ (NSString *)getOtherUserNickname{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *Str = [NSString stringWithFormat:@"%@",[defaults objectForKey:@"otherUserNickname"]];
    if ([CommonTool dx_isNullOrNilWithObject:Str]) {
        return @"";
    }
    
    return Str;
}
+ (NSString *)getUserSex{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *Str = [NSString stringWithFormat:@"%@",[defaults objectForKey:@"userSex"]];
    if ([CommonTool dx_isNullOrNilWithObject:Str]) {
        return @"";
    }
    
    return Str;
}
+ (NSString *)getUserVipLevel{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *Str = [NSString stringWithFormat:@"%@",[defaults objectForKey:@"vipLevel"]];
    if ([CommonTool dx_isNullOrNilWithObject:Str]) {
        return @"0";
    }
    
    return Str;
}


//获取姓名
+ (NSString *)getRealName{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    return [defaults objectForKey:@"name"];
}
//存储iPhone

+ (void)saveiPhoneToLocal:(NSDictionary *)aDic{
    [USER_DEFAULTS setObject:aDic[@"iphone"] forKey:@"iphone"];
    
    [USER_DEFAULTS synchronize];
}
//获取手机号
+ (NSString *)getiPhone {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"iphone--%@",[defaults objectForKey:@"iphone"]);
    return [defaults objectForKey:@"iphone"];
}

+ (NSString *)getIsFirstGotoChatVC{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *Str = [NSString stringWithFormat:@"%@",[defaults objectForKey:@"getIsFirstGotoChatVC"]];
    NSLog(@"Str---%@",Str);
    if ([CommonTool dx_isNullOrNilWithObject:Str] || [Str isEqualToString:@"(null)"]|| [Str isEqualToString:@"null"]) {
        return @"";
    }
   
    return Str;
}

//跳转主界面
+ (void)gotoMain{

    
    //直接进入主页
    RootTabBarController *rootVc = [[RootTabBarController alloc] init];
    kAppDelegate.rootTabC = rootVc;
    KEYWINDOW.rootViewController = rootVc;
    rootVc.selectedIndex = 0;

}

//跳转到登录界面
+ (void)gotoLogin{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    NewLoginViewController *vc = [[NewLoginViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    window.rootViewController = nav;
    

}

//判断是否已经登录
+ (BOOL)isLogin{
    NSString *accessTokenStr = [USER_DEFAULTS objectForKey:@"access_token"];
    
    NSDate *expiresDate = [USER_DEFAULTS objectForKey:@"time"];
    
    //  判断如果access token存在，并且没有过期。就返回YES.
    if (accessTokenStr && [[NSDate date] compare:expiresDate] == NSOrderedAscending) {
        return YES;
    }
    return NO;
    
}
//存储buttonNum
+ (void)savebuttonNumToLocal:(NSDictionary *)aDic{
    [USER_DEFAULTS setObject:aDic[@"buttonNum"] forKey:@"buttonNum"];
    
    [USER_DEFAULTS synchronize];
}
//获取buttonNum
+ (NSString *)getbuttonNum{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    return [defaults objectForKey:@"buttonNum"];
}

/**
 *  手机号码验证
 *
 *  @param mobileNumbel 传入的手机号码
 *
 *  @return 格式正确返回true  错误 返回fals
 */
+ (BOOL) isMobile:(NSString *)mobileNumbel{
    
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,152,157,158,159,182,183,184,187,188,178
     * 联通：130、131、132、156、155、186、185、145、176
     * 电信：133、153、189、180、181、177、173
     */
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    /**
     10         * 中国移动：China Mobile
     11         * 134[0-8],135,136,137,138,139,150,151,152,157,158,159,182,183,184,187,188,147,178,1705
     12         */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[0127-9]|8[23478]|4[7]|7[8]|7[0])\\d)\\d{7}$";
    /**
     15         * 中国联通：China Unicom
     16         * 130,131,132,155,156,185,186,145,149,176,177,173，171，175
     17         */
    NSString * CU = @"^1(3[0-2]|4[59]|5[56]|7[135-7]|8[56])\\d{8}$";
    /**
     20         * 中国电信：China Telecom
     21         * 133,1349,153,180,181,189
     22         */
    NSString * CT = @"^1((33|53|8[019])[0-9]|349)\\d{7}$";
    /**
     25         * 大陆地区固话及小灵通
     26         * 区号：010,020,021,022,023,024,025,027,028,029
     27         * 号码：七位或八位
     28         */
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    if (([regextestmobile evaluateWithObject:mobileNumbel]
         || [regextestcm evaluateWithObject:mobileNumbel]
         || [regextestct evaluateWithObject:mobileNumbel]
         || [regextestcu evaluateWithObject:mobileNumbel])) {
        return YES;
    }
    
    return NO;
    
}
+ (NSString *)valiMobile:(NSString *)mobile{
    if (mobile.length < 11)
    {
        return @"手机号长度只能是11位";
    }else{
        /**
         * 移动号段正则表达式
         */
        NSString *CM_NUM = @"^((13[4-9])|(147)|(15[0-2,7-9])|(178)|(18[2-4,7-8]))\\d{8}|(1705)\\d{7}$";
        /**
         * 联通号段正则表达式
         */
        NSString *CU_NUM = @"^((13[0-2])|(145)|(15[5-6])|(176)|(18[5,6]))\\d{8}|(1709)\\d{7}$";
        /**
         * 电信号段正则表达式
         */
        NSString *CT_NUM = @"^((133)|(153)|(177)|(18[0,1,9]))\\d{8}$";
        NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM_NUM];
        BOOL isMatch1 = [pred1 evaluateWithObject:mobile];
        NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU_NUM];
        BOOL isMatch2 = [pred2 evaluateWithObject:mobile];
        NSPredicate *pred3 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT_NUM];
        BOOL isMatch3 = [pred3 evaluateWithObject:mobile];
        
        if (isMatch1 || isMatch2 || isMatch3) {
            return nil;
        }else{
            return @"请输入正确的*****号码";
        }
    }
    return nil;
}
//存储当前时间
+ (void)saveDateToLocal:(NSDictionary *)aDic{
    [USER_DEFAULTS setObject:aDic[@"dateTime"] forKey:@"dateTime"];
    
    [USER_DEFAULTS synchronize];
 
  
}

+ (void)saveLocationToLocal:(NSDictionary *)aDic{
    
}
//获取时间
+ (NSString *)getDate{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"dateTime--%@",[defaults objectForKey:@"dateTime"]);
    return [defaults objectForKey:@"dateTime"];
}
+ (NSString *)timeStr:(NSString *)timeStr{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    
    
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];//设置源时间字符串的格式
    
    
    
    NSDate* date = [formatter dateFromString:timeStr];//将源时间字符串转化为NSDate
    
    NSDateFormatter* toformatter = [[NSDateFormatter alloc] init];
    
    
    
    [toformatter setDateFormat:@"MM-dd HH:mm"];//设置目标时间字符串的格式
    
    NSString *targetTime = [toformatter stringFromDate:date];//将时间转化成目标时间字符串
    return targetTime;
}


+ (NSString *)nianyueriTimeStr:(NSString *)timeStr{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    
    [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];//设置源时间字符串的格式
    
    
    
    NSDate* date = [formatter dateFromString:timeStr];//将源时间字符串转化为NSDate
    
    NSDateFormatter* toformatter = [[NSDateFormatter alloc] init];
    
    
    [toformatter setDateFormat:@"yyyy年MM月dd日"];//设置目标时间字符串的格式
    
    NSString *targetTime = [toformatter stringFromDate:date];//将时间转化成目标时间字符串
    return targetTime;
}


+ (NSString *)timeStr3:(NSString *)timeStr{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    
    [formatter setDateFormat:@"yyyy年MM月dd日"];//设置源时间字符串的格式
    
    
    
    NSDate* date = [formatter dateFromString:timeStr];//将源时间字符串转化为NSDate
    
    NSDateFormatter* toformatter = [[NSDateFormatter alloc] init];
    
    
    [toformatter setDateFormat:@"yyyy/MM/dd hh:mm:ss"];//设置目标时间字符串的格式
    
    NSString *targetTime = [toformatter stringFromDate:date];//将时间转化成目标时间字符串
    return targetTime;
}

+ (NSString *)timeStr4:(NSString *)timeStr{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    
    
    [formatter setDateFormat:@"yyyy-MM-dd"];//设置源时间字符串的格式
    
    
    
    NSDate* date = [formatter dateFromString:timeStr];//将源时间字符串转化为NSDate
    
    NSDateFormatter* toformatter = [[NSDateFormatter alloc] init];
    
    
    [toformatter setDateFormat:@"MM-dd"];//设置目标时间字符串的格式
    
    NSString *targetTime = [toformatter stringFromDate:date];//将时间转化成目标时间字符串
    return targetTime;
}





+ (NSString*)dictionaryToJson:(NSDictionary *)dic

{
    
    NSError *parseError = nil;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
}



//.浮点形判断：
+ (BOOL)isPureFloat:(NSString *)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    float val;
    return [scan scanFloat:&val] && [scan isAtEnd];
}

#pragma mark - 私有方法
//将NSDictionary中的Null类型的项目转化成@""
+(NSDictionary *)nullDic:(NSDictionary *)myDic
{
    NSArray *keyArr = [myDic allKeys];
    NSMutableDictionary *resDic = [[NSMutableDictionary alloc]init];
    for (int i = 0; i < keyArr.count; i ++)
    {
        id obj = [myDic objectForKey:keyArr[i]];
        
        obj = [self changeType:obj];
        
        [resDic setObject:obj forKey:keyArr[i]];
    }
    return resDic;
}

//将NSDictionary中的Null类型的项目转化成@""
+(NSArray *)nullArr:(NSArray *)myArr
{
    NSMutableArray *resArr = [[NSMutableArray alloc] init];
    for (int i = 0; i < myArr.count; i ++)
    {
        id obj = myArr[i];
        
        obj = [self changeType:obj];
        
        [resArr addObject:obj];
    }
    return resArr;
}

//将NSString类型的原路返回
+(NSString *)stringToString:(NSString *)string
{
    return string;
}

//将Null类型的项目转化成@""
+(NSString *)nullToString
{
    return @"";
}

#pragma mark - 公有方法
//类型识别:将所有的NSNull类型转化成@""
+(id)changeType:(id)myObj
{
    if ([myObj isKindOfClass:[NSDictionary class]])
    {
        return [self nullDic:myObj];
    }
    else if([myObj isKindOfClass:[NSArray class]])
    {
        return [self nullArr:myObj];
    }
    else if([myObj isKindOfClass:[NSString class]])
    {
        return [self stringToString:myObj];
    }
    else if([myObj isKindOfClass:[NSNull class]])
    {
        return [self nullToString];
    }
    else
    {
        return myObj;
    }
}

+ (void)removeAllData{
    
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentFolderPath = [searchPaths objectAtIndex:0];
    NSError *err;
    [[NSFileManager defaultManager] removeItemAtPath:documentFolderPath error:&err];
}

+(NSString*)imageNameStr:(int )index{
    NSArray * imageArr = [NSArray arrayWithObjects:@"Avatar-Mask2",@"farm_activity_water",@"Collection",@"Chemical fertilizers",@"ddd",@"farm_activity_grow_seedlings",@"farm_activity_harvest",@"farm_activity_manure",@"farm_activity_pesticide",@"farm_activity_seed",@"farm_activity_water",@"farm_activity_pesticide",@"farm_activity_seed",@"farm_activity_water",@"Growing-batches",@"farm_activity_pesticide",@"Collection",@"Avatar-Mask2",@"Chemical fertilizers",@"ddd",@"farm_activity_grow_seedlings",@"farm_activity_harvest",@"farm_activity_manure",@"farm_activity_pesticide",@"farm_activity_seed",@"farm_activity_water",@"farm_activity_pesticide",@"farm_activity_seed",@"farm_activity_water",@"Growing-batches",@"farm_activity_pesticide", nil];
    return imageArr[index];
}
/*!
 * @brief 把格式化的JSON格式的字符串转换成字典
 * @param jsonString JSON格式的字符串
 * @return 返回字典
 */
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

+ (BOOL)dx_isNullOrNilWithObject:(id)object
{ if (object == nil|| [object  isEqual:@"(null)"] || [object isEqual:[NSNull null]]) { return YES; }
    else if ([object isKindOfClass:[NSString class]]) { if ([object isEqualToString:@""]) { return YES; } else { return NO; } }
    else if ([object isKindOfClass:[NSNumber class]]) { if ([object isEqualToNumber:@0]) { return YES; } else { return NO; } }
    
    return NO; }



#pragma mark - 获取当前时间的 时间戳

+(NSString*)getNowTime{
    
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    [formatter setDateFormat:@"YYYY-MM-dd"]; // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    
    //设置时区,这个对于时间的处理有时很重要
    
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    
    [formatter setTimeZone:timeZone];
    
    NSDate *datenow = [NSDate date];//现在时间
    
    
    
    NSLog(@"设备当前的时间:%@",[formatter stringFromDate:datenow]);
    return [formatter stringFromDate:datenow];
    
}
//获取当前系统时间的时间戳

#pragma mark - 获取当前时间的 时间戳

+(NSInteger)getNowTimestamp{
    
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"]; // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    
    //设置时区,这个对于时间的处理有时很重要
    
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    
    [formatter setTimeZone:timeZone];
    
    NSDate *datenow = [NSDate date];//现在时间
    
    
    
    NSLog(@"设备当前的时间:%@",[formatter stringFromDate:datenow]);
    
    //时间转时间戳的方法:
    
    
    
    NSInteger timeSp = [[NSNumber numberWithDouble:[datenow timeIntervalSince1970]] integerValue];
    
    
    
    NSLog(@"设备当前的时间戳:%ld",(long)timeSp); //时间戳的值
    
    
    
    return timeSp;
    
}



//将某个时间转化成 时间戳

#pragma mark - 将某个时间转化成 时间戳

+(NSInteger)timeSwitchTimestamp:(NSString *)formatTime andFormatter:(NSString *)format{
    
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    [formatter setDateFormat:format]; //(@"YYYY-MM-dd hh:mm:ss") ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    
    
    
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    
    [formatter setTimeZone:timeZone];
    
    
    
    NSDate* date = [formatter dateFromString:formatTime]; //------------将字符串按formatter转成nsdate
    
    //时间转时间戳的方法:
    
    NSInteger timeSp = [[NSNumber numberWithDouble:[date timeIntervalSince1970]] integerValue];
    
    
    
    NSLog(@"将某个时间转化成 时间戳&&&&&&&timeSp:%ld",(long)timeSp); //时间戳的值
    
    
    
    return timeSp;
    
}



//将某个时间戳转化成 时间

#pragma mark - 将某个时间戳转化成 时间

+(NSString *)timestampSwitchTime:(NSInteger)timestamp andFormatter:(NSString *)format{
    
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    [formatter setDateFormat:format]; // （@"YYYY-MM-dd hh:mm:ss"）----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    
    [formatter setTimeZone:timeZone];
    
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:timestamp];
    
    NSLog(@"1296035591  = %@",confromTimesp);
    
    
    
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    
    
    
    NSLog(@"&&&&&&&confromTimespStr = : %@",confromTimespStr);
    
    
    
    return confromTimespStr;
    
}
//createTimeString为后台传过来的13位纯数字时间戳
+ (NSString *)updateTimeForRow:(NSString *)createTimeString {
    
    // 获取当前时时间戳 1466386762.345715 十位整数 6位小数
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    // 创建歌曲时间戳(后台返回的时间 一般是13位数字)
    NSTimeInterval createTime = [createTimeString longLongValue]/1000;
    // 时间差
    NSTimeInterval time = currentTime - createTime;
    
    NSInteger sec = time/60;
    if (sec<60) {
        return [NSString stringWithFormat:@"%ld分钟前",sec];
    }
    
    // 秒转小时
    NSInteger hours = time/3600;
    if (hours<24) {
        return [NSString stringWithFormat:@"%ld小时前",hours];
    }
    //秒转天数
    NSInteger days = time/3600/24;
    if (days < 30) {
        return [NSString stringWithFormat:@"%ld天前",days];
    }
    //秒转月
    NSInteger months = time/3600/24/30;
    if (months < 12) {
        return [NSString stringWithFormat:@"%ld月前",months];
    }
    //秒转年
    NSInteger years = time/3600/24/30/12;
    return [NSString stringWithFormat:@"%ld年前",years];
}

+ (NSString *)timeHuanXinStr:(long long)timestamp
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *currentDate = [NSDate date];
    
    // 获取当前时间的年、月、日
    NSDateComponents *components = [calendar components:NSCalendarUnitYear| NSCalendarUnitMonth|NSCalendarUnitDay fromDate:currentDate];
    NSInteger currentYear = components.year;
    NSInteger currentMonth = components.month;
    NSInteger currentDay = components.day;
    
    // 获取消息发送时间的年、月、日
    NSDate *msgDate = [NSDate dateWithTimeIntervalSince1970:timestamp/1000.0];
    components = [calendar components:NSCalendarUnitYear| NSCalendarUnitMonth|NSCalendarUnitDay fromDate:msgDate];
    CGFloat msgYear = components.year;
    CGFloat msgMonth = components.month;
    CGFloat msgDay = components.day;
    
    // 判断
    NSDateFormatter *dateFmt = [[NSDateFormatter alloc] init];
    if (currentYear == msgYear && currentMonth == msgMonth && currentDay == msgDay) {
        //今天
        dateFmt.dateFormat = @"HH:mm";
    }else if (currentYear == msgYear && currentMonth == msgMonth && currentDay-1 == msgDay ){
        //昨天
        dateFmt.dateFormat = @"昨天 HH:mm";
    }else{
        //昨天以前
        dateFmt.dateFormat = @"yyyy-MM-dd HH:mm";
    }
    
    return [dateFmt stringFromDate:msgDate];
}

+ (NSString *) md5:(NSString *) input {
    const char *cStr = [input UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}

#pragma mark -图片压缩

+(UIImage *)scaleImage:(UIImage *)image toKb:(NSInteger)kb{
        
        if (!image) {
            return image;
        }
        if (kb<1) {
            return image;
        }
        
        kb*=1024;
        
        
        
        CGFloat compression = 0.9f;
        CGFloat maxCompression = 0.0f;
        NSData *imageData = UIImageJPEGRepresentation(image, compression);
        while ([imageData length] > kb && compression > maxCompression) {
            compression -= 0.1;
            imageData = UIImageJPEGRepresentation(image, compression);
        }
        NSLog(@"当前大小:%fkb",(float)[imageData length]/1024.0f);
        UIImage *compressedImage = [UIImage imageWithData:imageData];
        return compressedImage;
        
}

+ (UIImage*) thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time {
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    NSParameterAssert(asset);
    AVAssetImageGenerator *assetImageGenerator =[[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = time;
    NSError *thumbnailImageGenerationError = nil;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60)actualTime:NULL error:&thumbnailImageGenerationError];
    
    if(!thumbnailImageRef)
        NSLog(@"thumbnailImageGenerationError %@",thumbnailImageGenerationError);
    
    UIImage*thumbnailImage = thumbnailImageRef ? [[UIImage alloc]initWithCGImage: thumbnailImageRef] : nil;
    
    return thumbnailImage;
}

+(void)initButton:(UIButton*)btn{
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;//使图片和文字水平居中显示
    
    
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(btn.imageView.frame.size.height+20 ,-btn.imageView.frame.size.width, 0.0,0.0)];//文字距离上边框的距离增加imageView的高度，距离左边框减少imageView的宽度，距离下边框和右边框距离不变
    [btn setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0,20.0, -btn.titleLabel.bounds.size.width)];//图片距离右边框距离减少图片的宽度，其它不边
    
}


/**
 * @brief 判断当前时间是否在fromHour和toHour之间。如，fromHour=8，toHour=23时，即为判断当前时间是否在8:00-23:00之间
 */
+ (BOOL)isBetweenFromHour:(NSInteger)fromHour FromMinute:(NSInteger)fromMin toHour:(NSInteger)toHour toMinute:(NSInteger)toMin
{
    NSDate *date8 = [self getCustomDateWithHour:fromHour andMinute:fromMin];
    NSDate *date23 = [self getCustomDateWithHour:toHour andMinute:toMin];
    
    NSDate *currentDate = [NSDate date];
    
    if ([currentDate compare:date8]==NSOrderedDescending && [currentDate compare:date23]==NSOrderedAscending)
    {
        NSLog(@"该时间在 %d:%d-%d:%d 之间！", fromHour, fromMin, toHour, toMin);
        return YES;
    }
    return NO;
}

/**
 * @brief 生成当天的某个点（返回的是伦敦时间，可直接与当前时间[NSDate date]比较）
 * @param hour 如hour为“8”，就是上午8:00（本地时间）
 */
+ (NSDate *)getCustomDateWithHour:(NSInteger)hour andMinute:(NSInteger)minute
{
    //获取当前时间
    NSDate *currentDate = [NSDate date];
    NSCalendar *currentCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *currentComps = [[NSDateComponents alloc] init];
    
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    
    currentComps = [currentCalendar components:unitFlags fromDate:currentDate];
    
    //设置当天的某个点
    NSDateComponents *resultComps = [[NSDateComponents alloc] init];
    [resultComps setYear:[currentComps year]];
    [resultComps setMonth:[currentComps month]];
    [resultComps setDay:[currentComps day]];
    [resultComps setHour:hour];
    [resultComps setMinute:minute];
    
    NSCalendar *resultCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    return [resultCalendar dateFromComponents:resultComps];
}

//3、  获取一个随机整数，范围在[from,to），包括from，包括to
                 
+(int)getRandomNumber:(int)from to:(int)to

{
    
    return (int)(from + (arc4random() % (to - from + 1)));
    
}

@end
