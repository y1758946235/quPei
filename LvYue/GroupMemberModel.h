//
//  GroupMemberModel.h
//  LvYue
//
//  Created by apple on 15/10/19.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  群成员 模型
 */

@interface GroupMemberModel : NSObject

@property (nonatomic, copy) NSString *memberID;

@property (nonatomic, copy) NSString *name; //用户昵称

@property (nonatomic, copy) NSString *isVip; //0不是 1是

@property (nonatomic, copy) NSString *icon;

- (instancetype)initWithDict:(NSDictionary *)dict;

+ (instancetype)groupMemberModelWithDict:(NSDictionary *)dict;

@end
