//
//  MyInfoModel.h
//  LvYue
//
//  Created by 广有射怪鸟事 on 15/10/8.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyInfoModel : NSObject

@property (nonatomic, assign) NSInteger age;           //年龄
@property (nonatomic, assign) NSInteger auth_car;      //车辆认证,0未认证，1认证中，2已认证
@property (nonatomic, assign) NSInteger auth_edu;      //学历认证
@property (nonatomic, assign) NSInteger auth_identity; //身份认证
@property (nonatomic, assign) NSInteger auth_video;    //视频认证
@property (nonatomic, strong) NSString *icon;          //头像
@property (nonatomic, assign) NSInteger id;            //id
@property (nonatomic, strong) NSString *name;          //名字
@property (nonatomic, assign) NSInteger sex;           //性别，0为男，1为女
@property (nonatomic, strong) NSString *signature;     //个性签名
@property (nonatomic, assign) NSInteger vip;           //是否vip 0否 1是
@property (nonatomic, assign) NSInteger type;          //类型，0为普通用户，1为导游
@property (nonatomic, strong) NSString *edu;           //学历
@property (nonatomic, strong) NSString *mobile;        //手机号
@property (nonatomic, assign) NSInteger score;         //星级
@property (nonatomic, strong) NSString *is_show;       //是否显示豆客账号
@property (nonatomic, strong) NSString *provide_stay;  //民宿状态
@property (nonatomic, strong) NSString *hongdou;       //红豆数量
@property (nonatomic, assign) BOOL isFocus;            //是否关注
@property (nonatomic, assign) NSInteger fansNum;       // 粉丝数
@property (nonatomic, assign) NSInteger focusNum;      // 关注数
@property (nonatomic, assign) NSInteger charm;         // 魅力值
@property (nonatomic, assign) NSInteger wealth;        // 财富值


- (id)initWithDict:(NSDictionary *)dict;


@end
