//
//  MyBuddyModel.h
//  LvYue
//
//  Created by apple on 15/10/10.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  我的好友模型(列表中)
 */

@interface MyBuddyModel : NSObject

@property (nonatomic, copy) NSString *buddyID; //环信用户名,唯一

@property (nonatomic, copy) NSString *icon;

@property (nonatomic, copy) NSString *remark; //好友备注

@property (nonatomic, copy) NSString *name; //好友昵称

- (instancetype)initWithDict:(NSDictionary *)dict;

+ (instancetype)myBuddyModelWithDict:(NSDictionary *)dict;

@end
