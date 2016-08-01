//
//  LYHttpPoster.m
//  LvYue
//
//  Created by apple on 15/9/28.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import "AFNetworking.h"
#import "LYHttpPoster.h"

@implementation LYHttpPoster

+ (void)postHttpRequestByPost:(NSString *)requestUrl andParameter:(NSDictionary *)requestDict success:(void (^)(id))successBlock andFailure:(void (^)(id))failureBlock {

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

    manager.requestSerializer.timeoutInterval = 20.0;

    [manager POST:requestUrl parameters:requestDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        successBlock(responseObject);
    }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            MLOG(@"\n请求失败 原因 : %@", error);
            failureBlock(error);
        }];
}


+ (void)postHttpRequestByGet:(NSString *)requestUrl andParameter:(NSDictionary *)requestDict success:(void (^)(id))successBlock andFailure:(void (^)(id))failureBlock {

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

    manager.requestSerializer.timeoutInterval = 20.0;

    [manager GET:requestUrl parameters:requestDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        successBlock(responseObject);
    }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            MLOG(@"\n请求失败 原因 : %@", error);
            failureBlock(error);
        }];
}

@end
