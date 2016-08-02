//
//  TopicTitle.h
//  LvYue
//
//  Created by KFallen on 16/8/2.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TopicTitle : NSObject

@property (nonatomic, copy) NSString* ID;  //热门话题ID
@property (nonatomic, copy) NSString* back_img; //背景图
@property (nonatomic, copy) NSString* intro; //简介
@property (nonatomic, copy) NSString* title;    //标题
@property (nonatomic, copy) NSString* partNums; //热门话题参与人数

+ (instancetype)topicTitleWithDict:(NSDictionary *)dict;

@end
