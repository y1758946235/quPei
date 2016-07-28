//
//  NearByPeopleModel.h
//  LvYue
//
//  Created by 广有射怪鸟事 on 15/10/7.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NearByPeopleModel : NSObject

@property (nonatomic,assign) NSInteger age;//年龄
@property (nonatomic,assign) NSInteger auth_car;//车辆认证,0未认证，1认证中，2已认证
@property (nonatomic,assign) NSInteger auth_edu;//学历认证
@property (nonatomic,assign) NSInteger auth_identity;//身份认证
@property (nonatomic,assign) NSInteger auth_video;//视频认证
@property (nonatomic,assign) float distance;//距离，单位米
@property (nonatomic,strong) NSString *icon;//头像
@property (nonatomic,assign) NSInteger id;//id
@property (nonatomic,strong) NSString *name;//名字
@property (nonatomic,assign) NSInteger sex;//性别，0为男，1为女
@property (nonatomic,strong) NSString *signature;//个性签名
@property (nonatomic,assign) NSInteger vip;
@property (nonatomic,assign) NSInteger type;//类型，0为普通用户，1为导游


- (id)initWithDict:(NSDictionary *)dict;

@end
