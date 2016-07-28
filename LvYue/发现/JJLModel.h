//
//  JJLModel.h
//  LvYue
//
//  Created by 广有射怪鸟事 on 15/10/17.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JJLModel : NSObject

@property (nonatomic,strong) NSString *icon;//头像
@property (nonatomic,strong) NSString *create_time;//创建时间
@property (nonatomic,strong) NSString *noticeListId;//救急令id
@property (nonatomic,strong) NSString *notice_detail;//内容
@property (nonatomic,strong) NSString *notice_user;//用户名
@property (nonatomic,strong) NSString *update_time;//更新时间
@property (nonatomic,strong) NSString *age;//年龄
@property (nonatomic,strong) NSString *auth_car;
@property (nonatomic,strong) NSString *auth_edu;
@property (nonatomic,strong) NSString *auth_identity;
@property (nonatomic,strong) NSString *auth_video;
@property (nonatomic,strong) NSString *userId;
@property (nonatomic,strong) NSString *type;
@property (nonatomic,strong) NSString *sex;
@property (nonatomic,strong) NSString *distance;//距离
@property (nonatomic,strong) NSString *minute;//时间
@property (nonatomic,strong) NSString *vip;
@property (nonatomic,strong) NSString *id;


- (id)initWithDict:(NSDictionary *)dict;

@end
