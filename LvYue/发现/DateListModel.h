//
//  DateListModel.h
//  LvYue
//
//  Created by 广有射怪鸟事 on 15/10/13.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateListModel : NSObject

@property (nonatomic,strong) NSString *content;//豆客内容
@property (nonatomic,strong) NSString *create_time;//创建时间
@property (nonatomic,strong) NSString *create_user_id;//创建者id
@property (nonatomic,strong) NSString *group_id;//群id
@property (nonatomic,strong) NSString *photos;//图片名字，；隔开
@property (nonatomic,strong) NSString *status;//状态，0为未应邀，1为是
@property (nonatomic,strong) NSString *type;//豆客类型
@property (nonatomic,strong) NSString *update_time;//更新时间
@property (nonatomic,strong) NSString *distance;//距离
@property (nonatomic,strong) NSDictionary *user;//用户资料
@property (nonatomic,strong) NSString *lyId;//豆客id

- (id)initWithDict:(NSDictionary *)dict;

@end
