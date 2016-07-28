//
//  VideoOwner.h
//  LvYue
//
//  Created by Olive on 16/1/6.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  视频拥有者
 */

@interface VideoOwner : NSObject

@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *icon;
@property (nonatomic, copy) NSString *isVip;
@property (nonatomic, copy) NSString *sex;
@property (nonatomic, copy) NSString *age;

- (instancetype)initWithDict:(NSDictionary *)dict;

@end
