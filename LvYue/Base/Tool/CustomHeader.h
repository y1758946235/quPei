//
//  CustomHeader.h
//  YiChatClient
//
//  Created by 张泽楠 on 15/11/2.
//  Copyright © 2015年 ds. All rights reserved.
//



#ifndef CustomHeader_h
#define CustomHeader_h



//RGBA颜色
#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
//判断字符串是否为空
#define strIsEmpty(str) ([str isKindOfClass:[NSNull class]] || str == nil || [str length]<1 ? YES : NO )

//防止Block中的self循环引用的宏定义
#if __has_feature(objc_arc)
#define WS(weakSelf)  __weak  __typeof(&*self)weakSelf = self;
#else
#define WS(weakSelf)  __block __typeof(&*self)weakSelf = self;
#endif


#warning 这是一个MRC/ARC通用的weakify和strongify
/**
 * 强弱引用转换，用于解决代码块（block）与强引用self之间的循环引用问题
 * 调用方式: `@weakify_self`实现弱引用转换，`@strongify_self`实现强引用转换
 *
 * 示例：
 * @weakify_self
 * [obj block:^{
 * @strongify_self
 * self.property = something;
 * }];
 */
#ifndef    weakify_self
#if __has_feature(objc_arc)
#define weakify_self autoreleasepool{} __weak __typeof__(self) weakSelf = self;
#else
#define weakify_self autoreleasepool{} __block __typeof__(self) blockSelf = self;
#endif
#endif

#ifndef    strongify_self
#if __has_feature(objc_arc)
#define strongify_self try{} @finally{} __typeof__(weakSelf) self = weakSelf;
#else
#define strongify_self try{} @finally{} __typeof__(blockSelf) self = blockSelf;
#endif
#endif
/**
 * 强弱引用转换，用于解决代码块（block）与强引用对象之间的循环引用问题
 * 调用方式: `@weakify(object)`实现弱引用转换，`@strongify(object)`实现强引用转换
 *
 * 示例：
 * @weakify(object)
 * [obj block:^{
 * @strongify(object)
 * strong_object = something;
 * }];
 */
#ifndef    weakify
#if __has_feature(objc_arc)
#define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
#endif
#endif
#ifndef    strongify
#if __has_feature(objc_arc)
#define strongify(object) try{} @finally{} __typeof__(object) strong##_##object = weak##_##object;
#else
#define strongify(object) try{} @finally{} __typeof__(object) strong##_##object = block##_##object;
#endif
#endif

#define USER_DEFAULTS [NSUserDefaults standardUserDefaults]

// 网络切换
//外网
//#define SeedingServer @"http://funongchang.com:8090/api/"
//#define SeedingAllServer @"http://funongchang.com:8090/"

// 内网
#define SeedingServer @"http://192.168.0.109:8080/api/"
#define SeedingAllServer @"http://192.168.0.109:8080/"
//龙哥电脑
//#define SeedingServer @"http://192.168.0.129:8080/api/"
//#define SeedingServer @"http://192.168.0.134:8080/api/"
//#define SeedingServer @"http://192.168.0.123:8080/api/"
//#define SeedingServer @"http://test.funongchang.com:8088/api/"
//正式环境
//#define SeedingServer @"http://funongchang.com:8080/api/"



#define APP_URL @"http://itunes.apple.com/lookup?id=1130836470"
//1118809303
//自定义NSLog
#ifdef DEBUG
#define DLog(...) NSLog(__VA_ARGS__)
#else
#define DLog(...)
#endif

//number
#define NUMBERS @"0123456789"
//尺寸及版本 **************************************************************************
#define SCREEN_WIDTH [[UIScreen mainScreen]bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen]bounds].size.height

//#define isIPhone4 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)
//
//#define isIPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
//
//#define isIOS7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0 ? YES : NO)

//
#define VerifyValue(value)\
({id tmp;\
if ([value isKindOfClass:[NSNull class]])\
tmp = nil;\
else\
tmp = value;\
tmp;\
})\
//判断数据是否为空

#define checkNull(__X__) (__X__) == [NSNull null] || (__X__) == nil ? @"" : [NSString stringWithFormat:@"%@", (__X__)]
//判断数据是否为空
#define arrayNoNull(array)  if (array != nil && ![array isKindOfClass:[NSNull class]] && array.count != 0)
//判断数据是否为空 （通用）
  #define shuju(shuju)  if (shuju && ![shuju isKindOfClass:[NSNull class]])
//按比例适配5S  

//#define AutoSizeScaleY [[UIScreen mainScreen] bounds].size.height/568
#define AutoSizeScaleY [[UIScreen mainScreen] bounds].size.width/320
#define AutoSizeScaleX [[UIScreen mainScreen] bounds].size.width/320
////按比例适配6
//
//#define AutoSizeScaleY [[UIScreen mainScreen] bounds].size.height/667
//
#define AutoSixSizeScaleX [[UIScreen mainScreen] bounds].size.width/375
//按比例适配6p
//#define ProportionY [[UIScreen mainScreen] bounds].size.height/979.5
//#define ProportionX  [[UIScreen mainScreen] bounds].size.width/540
#endif /* CustomHeader_h */

// 状态条高度
#define SCStatusBarHeight [UIApplication sharedApplication].statusBarFrame.size.height
#define SCnavigationHeight self.navigationController.navigationBar.frame.size.height 

//读取本地图片
#define LOADIMAGE(file,ext) [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:file ofType:ext]]

//定义UIImage对象
#define IMAGE(A) [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:A ofType:nil]]

//定义UIImage对象
#define ImageNamed(_pointer) [UIImage imageNamed:[UIUtil imageName:_pointer]]
//判断
#define  REQUEST(__X__)  (__X__) == ([[NSString  stringWithFormat:@"%@",result[@"code"]] isEqualToString:@"1"] ) {(__X__)}else{ MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES]; hud.mode = MBProgressHUDModeText;hud.label.text=result[@"msg"]; hud.removeFromSuperViewOnHide = YES;[hud hideAnimated:YES afterDelay:1];}
//判断是不是数字
#define NUMBERS @"0123456789\n"



// 友盟APIKey
#define UMeng_APIKey   @"5760f8ce67e58e58d3002952"//友盟appKey
#define WX_APP_KEY @"wxb573bea7274a2241"//微信appId
#define QQ_APP_ID @"1105473424"
#define QQ_APP_KEY @"2Eo8oJ2bKqCzFtmi"//QQappkey
#define QQ_APP_SECRET @"N4BmFH3LRvG6OHeT"//QQappSecret  QQ41E30FA5
#define WX_APP_SECRET @"96b0f893e771be22b02185340a2e8f70"//微信appSecret
#define share_title @"下载种菜宝，您身边的种菜专家"//分享标题
#define share_content @"我最近在使用种菜宝APP，病虫害在线咨询，科学的种植方案，让种菜变得更简单~~"//分享内容
#define share_url @"http://a.app.qq.com/o/simple.jsp?pkgname=com.whkj.app.zcb"//分享url
//极光推送
#define JPUSH_APP_KEY @"b987d9ce6019a125a0333ce7"
