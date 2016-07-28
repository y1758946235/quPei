//
//  SearchResultPerson.h
//  LvYue
//
//  Created by apple on 15/10/10.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  搜索新的朋友 模型
 */

@interface SearchResultPerson : NSObject

@property (nonatomic, copy) NSString *userID; //环信用户名,唯一

@property (nonatomic, copy) NSString *name; //用户昵称

@property (nonatomic, copy) NSString *sex; //0男 1女

@property (nonatomic, copy) NSString *age;

@property (nonatomic, copy) NSString *icon;

@property (nonatomic, copy) NSString *signature; //个性签名

- (instancetype)initWithDict:(NSDictionary *)dict;

+ (instancetype)searchResultPersonWithDict:(NSDictionary *)dict;

@end
