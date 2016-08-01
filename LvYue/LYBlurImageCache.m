//
//  LYBlurImageCache.m
//  LvYue
//
//  Created by KentonYu on 16/7/29.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "LYBlurImageCache.h"

static LYBlurImageCache *lyBlurImageCache;

@implementation LYBlurImageCache

+ (instancetype)shareCache {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        lyBlurImageCache            = [[LYBlurImageCache alloc] init];
        lyBlurImageCache.countLimit = 50;
    });
    return lyBlurImageCache;
}

@end
