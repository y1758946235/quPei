//
//  SystemMessageModel.h
//  LvYue
//
//  Created by apple on 15/10/27.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  系统消息 模型
 */

@interface SystemMessageModel : NSObject

@property (nonatomic, copy ) NSString *messageID;//消息ID

@property (nonatomic, copy ) NSString *content;//内容

@property (nonatomic, copy ) NSString *timeStamp;//时间戳

@property (nonatomic,strong) NSString *title;//标题

- (instancetype)initWithDict:(NSDictionary *)dict;

+ (instancetype)systemMessageModelWithDict:(NSDictionary *)dict;

@end
