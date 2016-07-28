//
//  UserInfo.m
//  LvYue
//
//  Created by KFallen on 16/7/8.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "UserInfo.h"

@implementation UserInfo

+ (instancetype)userInfoWithDict:(NSDictionary *)dict {
    UserInfo* info = [[UserInfo alloc] init];
    info.openid = [NSString stringWithFormat:@"%@",dict[@"openid"]];
    info.nickname = [NSString stringWithFormat:@"%@",dict[@"nickname"]];
    info.sex = [NSString stringWithFormat:@"%@",dict[@"sex"]];
    info.province = [NSString stringWithFormat:@"%@",dict[@"province"]];
    info.city = [NSString stringWithFormat:@"%@",dict[@"city"]];
    info.country = [NSString stringWithFormat:@"%@",dict[@"country"]];
    info.headimgurl = [NSString stringWithFormat:@"%@",dict[@"headimgurl"]];
    return info;
}


@end
