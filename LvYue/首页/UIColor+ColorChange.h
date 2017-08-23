//
//  UIColor+ColorChange.h
//  LvYue
//
//  Created by X@Han on 16/11/30.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (ColorChange)

//颜色转换  iOS中（以#号开头）  十六进制颜色转换成UIColor(RGB)
+ (UIColor *) colorWithHexString :(NSString *)color;



@end
