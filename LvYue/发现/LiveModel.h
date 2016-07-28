//
//  LiveModel.h
//  LvYue
//
//  Created by LHT on 15/11/17.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LiveModel : NSObject

@property (nonatomic,strong) NSString *city;//城市 id
@property (nonatomic,strong) NSString *content;//介绍
@property (nonatomic,strong) NSString *create_time;//创建时间
@property (nonatomic,strong) NSString *create_userID;//创建者 id
@property (nonatomic,strong) NSString *liveId;//民宿 id
@property (nonatomic,strong) NSString *photos;//照片
@property (nonatomic,strong) NSString *price;//价格
@property (nonatomic,strong) NSString *update_time;//更新时间
@property (nonatomic,strong) NSString *icon;//头像
@property (nonatomic,strong) NSString *userId;//发布者 id
@property (nonatomic,strong) NSString *name;//用户名
@property (nonatomic,strong) NSString *vip;//vip状态
@property (nonatomic,strong) NSString *contact;//联系方式
@property (nonatomic,strong) NSString *cityName;//城市名

- (id)initWithDict:(NSDictionary *)dict;

@end
