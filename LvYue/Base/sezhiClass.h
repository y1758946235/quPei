//
//  sezhiClass.h
//  FuNongChang
//
//  Created by whkj on 16/4/8.
//  Copyright © 2016年 whkj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface sezhiClass : NSObject


+ (UIColor *) colorWithHexString: (NSString *)color;
//颜色生成图片方法
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;



@end
