//
//  LYHttpPoster.h
//  LvYue
//
//  Created by apple on 15/9/28.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LYHttpPoster : NSObject

#define SUCCESSBLOCK void(^)(id successResponse)
#define FAILUREBLOCK void(^)(id failureResponse)

//POST请求
+ (void)postHttpRequestByPost:(NSString *)requestUrl andParameter:(NSDictionary *)requestDict success:(SUCCESSBLOCK) successBlock andFailure:(FAILUREBLOCK)failureBlock;

//GET请求
+ (void)postHttpRequestByGet:(NSString *)requestUrl andParameter:(NSDictionary *)requestDict success:(SUCCESSBLOCK) successBlock andFailure:(FAILUREBLOCK)failureBlock;

@end
