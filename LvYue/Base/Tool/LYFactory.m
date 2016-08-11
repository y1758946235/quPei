//
//  LYFactory.m
//  LvYue
//
//  Created by apple on 15/10/7.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import "LYFactory.h"

@implementation LYFactory

#pragma mark  - 正则匹配

//判断是否是邮箱
+ (BOOL)isEmailAddress:(NSString*)candidate
{
    NSString* emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate* emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:candidate];
}

//判断是否为合法手机号
+ (BOOL)isPhone:(NSString *)phoneNum{
    // 正则判断手机号码地址格式
    
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    
    NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    return (([regextestmobile evaluateWithObject:phoneNum] == YES)
            || ([regextestcm evaluateWithObject:phoneNum] == YES)
            || ([regextestct evaluateWithObject:phoneNum] == YES)
            || ([regextestcu evaluateWithObject:phoneNum] == YES));
}

//判断是否为QQ号
+ (BOOL)isQQ:(NSString *)qq{
    NSString *regex = @"[1-9][0-9]{4,}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    return [pred evaluateWithObject:qq];
}

//判断是否为身份证
+ (BOOL)isIDCard:(NSString *)idCard{
    BOOL flag;
    if (idCard.length <= 0) {
        flag = NO;
        return flag;
    }
    NSString *regex2 = @"^(\\d{14}|\\d{17})(\\d|[xX])$";
    NSPredicate *identityCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex2];
    return [identityCardPredicate evaluateWithObject:idCard];
}

//判断是否为邮编
+ (BOOL)isPostcode:(NSString *)code{
    NSString *      regex = @"[1-9]\d{5}";
    NSPredicate *   pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    return [pred evaluateWithObject:code];
}


@end
