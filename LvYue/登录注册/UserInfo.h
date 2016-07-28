//
//  UserInfo.h
//  LvYue
//
//  Created by KFallen on 16/7/8.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfo : NSObject

/**
 *  {
 "openid":"OPENID",
 "nickname":"NICKNAME",
 "sex":1,
 "province":"PROVINCE",
 "city":"CITY",
 "country":"COUNTRY",
 "headimgurl": "http://wx.qlogo.cn/mmopen/g3MonUZtNHkdmzicIlibx6iaFqAc56vxLSUfpb6n5WKSYVY0ChQKkiaJSgQ1dZuTOgvLLrhJbERQQ4eMsv84eavHiaiceqxibJxCfHe/0",
 "privilege":[
 "PRIVILEGE1",
 "PRIVILEGE2"
 ],
 "unionid": " o6_bmasdasdsad6_2sgVt7hMZOPfL"
 
 }
 */

@property (copy, nonatomic) NSString* openid;       //普通用户的标识
@property (nonatomic, copy) NSString* nickname;     //普通用户昵称
@property (nonatomic, copy) NSString* sex;          //普通用户性别，1为男性，2为女性
@property (nonatomic, copy) NSString* province;     //普通用户个人资料填写的省份
@property (nonatomic, copy) NSString* city;         //普通用户个人资料填写的城市
@property (nonatomic, copy) NSString* country;      //国家，如中国为CN
@property (nonatomic, copy) NSString* headimgurl;   //用户头像，最后一个数值代表正方形头像大小（有0、46、64、96、132数值可选，0代表640*640正方形头像），用户没有头像时该项为空

+ (instancetype)userInfoWithDict:(NSDictionary *)dict;

@end
