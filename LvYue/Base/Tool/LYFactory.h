//
//  LYFactory.h
//  LvYue
//
//  Created by apple on 15/10/7.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LYFactory : NSObject

//判断是否是邮箱
+ (BOOL)isEmailAddress:(NSString*)candidate;

//判断是否为合法手机号
+ (BOOL)isPhone:(NSString *)phoneNum;

//判断是否为QQ号
+ (BOOL)isQQ:(NSString *)qq;

//判断是否为身份证
+ (BOOL)isIDCard:(NSString *)idCard;

//判断是否为邮编
+ (BOOL)isPostcode:(NSString *)code;

@end
