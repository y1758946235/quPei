//
//  CommonTool.h
//  Seedling
//
//  Created by whkj on 16/6/3.
//  Copyright © 2016年 whkj. All rights reserved.
//

#import <Foundation/Foundation.h>
#define dispatch_once _dispatch_once
@interface CommonTool : NSObject
+ (instancetype)sharedCommonTool;

////存储登陆信息
//+ (void)saveAccessTokenToLocal:(NSDictionary *)aDic;

//获取getDeviceToken
+ (NSString *)getDeviceToken;
//获取getUserCaptcha
+ (NSString *)getUserCaptcha;
//获取getUserID
+ (NSString *)getUserID;
//获取头像
+ (NSString *)getUserIcon;
//获取其他人头像
+ (NSString *)getOtherUserIcon ;
//获取userNickname
+ (NSString *)getUserNickname;
//获取OtherUserNickname
+ (NSString *)getOtherUserNickname;
//获取userSex
+ (NSString *)getUserSex;
//获取userVIP等级
+ (NSString *)getUserVipLevel;
//获取是否第一次进入聊天界面  弹出提示界面
+ (NSString *)getIsFirstGotoChatVC;
//获取姓名
+ (NSString *)getRealName;
//存储iPhone
+ (void)saveiPhoneToLocal:(NSDictionary *)aDic;
//获取手机号
+ (NSString *)getiPhone;
;
//跳转主界面
+ (void)gotoMain;
//跳转到登录界面
+ (void)gotoLogin;
//判断是否已经登录
+(BOOL)isLogin;
/**
 *  手机号码验证
 *
 *  @param mobileNumbel 传入的手机号码
 *
 *  @return 格式正确返回true  错误 返回fals
 */
+ (BOOL) isMobile:(NSString *)mobileNumbel;
//判断是不是手机号码
+ (NSString *)valiMobile:(NSString *)mobile;
//存储当前时间
+ (void)saveDateToLocal:(NSDictionary *)aDic;
//存储当前位置
+ (void)saveLocationToLocal:(NSDictionary *)aDic;
//获取时间
+ (NSString *)getDate;
//时间返回格式
+ (NSString *)timeStr:(NSString *)timeStr;

+ (NSString *)nianyueriTimeStr:(NSString *)timeStr;

+ (NSString *)timeStr3:(NSString *)timeStr;

+ (NSString *)timeStr4:(NSString *)timeStr;


+ (NSString*)dictionaryToJson:(NSDictionary *)dic;

//shuzi数字 是不是浮点型 也可以是整形
+ (BOOL)isPureFloat:(NSString *)string;

//类型识别:将所有的NSNull类型转化成@""
+(NSDictionary *)nullDic:(NSDictionary *)myDic;
+(NSArray *)nullArr:(NSArray *)myArr;
+(NSString *)stringToString:(NSString *)string;
+(NSString *)nullToString;
+(id)changeType:(id)myObj;

//清除本地数据
+ (void)removeAllData;

+(NSString*)imageNameStr:(int)index;
//字符串转字典
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString ;
/** * 判断对象是否为空 * PS：nil、NSNil、@""、@0 以上4种返回YES * * @return YES 为空 NO 为实例对象 */
+ (BOOL)dx_isNullOrNilWithObject:(id)object;

//获取当前系统时间
+(NSString*)getNowTime;
//获取当前系统时间的时间戳

#pragma mark - 获取当前时间的 时间戳

+(NSInteger)getNowTimestamp;
//将某个时间转化成 时间戳

#pragma mark - 将某个时间转化成 时间戳

+(NSInteger)timeSwitchTimestamp:(NSString *)formatTime andFormatter:(NSString *)format;
#pragma mark - 将某个时间戳转化成 时间

+(NSString *)timestampSwitchTime:(NSInteger)timestamp andFormatter:(NSString *)format;
//该构造方法将时间戳转换为几分钟前/几小时前/几天前/几年前
+ (NSString *)updateTimeForRow:(NSString *)createTimeString;
#pragma mark - 环信聊天时间显示
+ (NSString *)timeHuanXinStr:(long long)timestamp;
#pragma mark -MD5
+ (NSString *) md5:(NSString *) input;
#pragma mark -图片压缩
+(UIImage *)scaleImage:(UIImage *)image toKb:(NSInteger)kb;
#pragma mark -获取视频里任一诊的图片
+ (UIImage*) thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time;
#pragma mark -button图片文字上下排位
+(void)initButton:(UIButton*)btn;

/**
 * 判断当前时间是否处于某个时间段内
 *

 */
+ (BOOL)isBetweenFromHour:(NSInteger)fromHour FromMinute:(NSInteger)fromMin toHour:(NSInteger)toHour toMinute:(NSInteger)toMin;


#pragma mark -获取一个随机整数，范围在[from,to），包括from，包括to
+(int)getRandomNumber:(int)from to:(int)to;


@end
