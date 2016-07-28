//
//  VideoPublishPerson.h
//  LvYue
//
//  Created by Olive on 15/12/31.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideoPublishPerson : NSObject

@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *icon;
@property (nonatomic, copy) NSString *isVip; //0不是 1是
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *sex; //0男 1女
@property (nonatomic, copy) NSString *age;

- (instancetype)initWithDict:(NSDictionary *)dict;

@end
