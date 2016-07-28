//
//  GroupModel.h
//  LvYue
//
//  Created by apple on 15/10/18.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GroupModel : NSObject

/**
 *  群组模型
 */

@property (nonatomic, copy) NSString *groupID;

@property (nonatomic, copy) NSString *easeMob_id; //环信群id

@property (nonatomic, copy) NSString *type; //群类别 0官方群 1普通群

@property (nonatomic, copy) NSString *icon; //群头像

@property (nonatomic, copy) NSString *name; //群名称

@property (nonatomic, copy) NSString *desc; //群描述

@property (nonatomic, copy) NSString *maxCount; //最大成员数量

@property (nonatomic, copy) NSString *memberCount; //当前成员数量

@property (nonatomic, copy) NSString *bossID; //群主id (普通群=群主用户id 官方群=管理员id)

- (instancetype)initWithDict:(NSDictionary *)dict;

+ (instancetype)groupWithDict:(NSDictionary *)dict;

@end
