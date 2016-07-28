//
//  WhoComeModel.h
//  LvYue
//
//  Created by 広有射怪鸟事 on 15/12/18.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WhoComeModel : NSObject

@property (nonatomic,copy) NSString *headIcon;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *sign;
@property (nonatomic,copy) NSString *last_time;//转化后的时间
@property (nonatomic,copy) NSString *userId;
@property (nonatomic,copy) NSString *oriTime;//原始时间

@property (nonatomic,copy) NSString *timeType;//时间类型，最近的为1，过去的为2

- (id)initWithDict:(NSDictionary *)dict;
- (NSString *)getTime;

@end
