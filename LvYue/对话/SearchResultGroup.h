//
//  SearchResultGroup.h
//  LvYue
//
//  Created by apple on 15/10/18.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchResultGroup : NSObject

/**
 *  搜索群组 模型
 */

@property (nonatomic, copy) NSString *groupID;

@property (nonatomic, copy) NSString *easemob_id; //环信群ID

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *desc;

@property (nonatomic, copy) NSString *icon;

@property (nonatomic, copy) NSString *memberCount; //当前群成员数

@property (nonatomic, copy) NSString *maxCount; //群最大成员数

- (instancetype)initWithDict:(NSDictionary *)dict;

+ (instancetype)searchResultGroupWithDict:(NSDictionary *)dict;

@end
