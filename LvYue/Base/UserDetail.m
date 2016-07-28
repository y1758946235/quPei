//
//  UserDetail.m
//  LvYue
//
//  Created by apple on 15/10/7.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import "UserDetail.h"

@implementation UserDetail

//@property (nonatomic, copy) NSString *userName; //用户昵称
//@property (nonatomic, assign) int sex; //性别 0男 1女
//@property (nonatomic, assign) int userType; //用户类型 0普通用户 1向导
//@property (nonatomic, assign) int isVip; //是否是会员 0否 1是
//@property (nonatomic, assign) int auth_video; //视频认证 0未认证 1认证
//@property (nonatomic, assign) int auth_identity; //身份认证 0未认证 1认证
//@property (nonatomic, assign) int auth_edu; //学历认证 0未认证 1认证
//@property (nonatomic, assign) int auth_car; //车辆认证 0未认证 1认证

- (void)reloadUserDetail {
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    self.userName = [user objectForKey:@"userName"];
    self.umengID = [user objectForKey:@"umengID"];
    self.sex = [user objectForKey:@"sex"];
    self.userType = [user objectForKey:@"userType"];
    self.isVip = [user objectForKey:@"isVip"];
    self.auth_video = [user objectForKey:@"auth_video"];
    self.auth_identity = [user objectForKey:@"auth_identity"];
    self.auth_edu = [user objectForKey:@"auth_edu"];
    self.auth_car = [user objectForKey:@"auth_car"];
}

@end
