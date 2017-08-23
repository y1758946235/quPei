//
//  TopicTagModel.h
//  LvYue
//
//  Created by X@Han on 17/6/8.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TopicTagModel : NSObject
@property(copy,nonatomic)NSString *shareTopicId;
@property(copy,nonatomic)NSString *shareTopicName;

- (id)initWithModelDic:(NSDictionary *)dic;
+ (id)createWithModelDic:(NSDictionary *)dic;
@end
