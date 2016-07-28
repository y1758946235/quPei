//
//  CheckMessageModel.h
//  LvYue
//
//  Created by apple on 15/10/12.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  验证列表模型
 */

@interface CheckMessageModel : NSObject

@property (nonatomic, copy) NSString *messageID;

@property (nonatomic, copy) NSString *senderID; //请求对象的ID

@property (nonatomic, copy) NSString *groupID; //邀请方群组ID

@property (nonatomic, copy) NSString *easemob_id; //环信群组ID

@property (nonatomic, copy) NSString *icon;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *type; //请求类型 1=添加好友申请 2=添加群申请 3=邀请加群申请 4=豆客应邀申请

@property (nonatomic, copy) NSString *status; //状态 0=未处理 1=已读 2=同意 3=拒绝

@property (nonatomic, copy) NSString *requestInfo; //验证信息

- (instancetype)initWithDict:(NSDictionary *)dict;

+ (instancetype)checkMessageModelWithDict:(NSDictionary *)dict;

@end
