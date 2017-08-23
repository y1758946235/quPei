//
//  PublicTool.m
//  LvYue
//
//  Created by Mac on 16/12/7.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "PublicTool.h"

@implementation PublicTool
////⚠️获取当前屏幕显示的viewcontroller
//+ (UIViewController *)getCurrentVC
//{
//    UIViewController *result = nil;
//    
//    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
//    if (window.windowLevel != UIWindowLevelNormal)
//    {
//        NSArray *windows = [[UIApplication sharedApplication] windows];
//        for(UIWindow * tmpWin in windows)
//        {
//            if (tmpWin.windowLevel == UIWindowLevelNormal)
//            {
//                window = tmpWin;
//                break;
//            }
//        }
//    }
//    
//    UIView *frontView = [[window subviews] objectAtIndex:0];
//    id nextResponder = [frontView nextResponder];
//    
//    if ([nextResponder isKindOfClass:[UIViewController class]])
//        result = nextResponder;
//    else
//        result = window.rootViewController;
//    
//    return result;
//}

@end
