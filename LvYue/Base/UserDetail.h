//
//  UserDetail.h
//  LvYue
//
//  Created by apple on 15/10/7.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  用户详细信息(缓存)
 */

@interface UserDetail : NSObject

@property (nonatomic, copy) NSString *userName; //用户昵称
@property (nonatomic, copy) NSString *umengID; //友盟ID,第三方登录用
@property (nonatomic, copy) NSString *sex; //性别 0男 1女
@property (nonatomic, copy) NSString *userType; //用户类型 0普通用户 1向导
@property (nonatomic, copy) NSString *isVip; //是否是会员 0否 1是
@property (nonatomic, copy) NSString *auth_video; //视频认证 0未认证 1认证
@property (nonatomic, copy) NSString *auth_identity; //身份认证 0未认证 1认证
@property (nonatomic, copy) NSString *auth_edu; //学历认证 0未认证 1认证
@property (nonatomic, copy) NSString *auth_car; //车辆认证 0未认证 1认证
@property (nonatomic, copy) NSString *startTime;
@property (nonatomic, copy) NSString *endTime;

//重载userDefault的数据
- (void)reloadUserDetail;

@end
