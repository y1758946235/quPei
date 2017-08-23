//
//  newMyInfoModel.h
//  LvYue
//
//  Created by X@Han on 16/12/26.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface newMyInfoModel : NSObject


@property(copy,nonatomic)NSString *dateCity;  //约会城市
@property(copy,nonatomic)NSString *dateProvince; //约会省份
@property(copy,nonatomic)NSString *cityName;  //约会城市
@property(copy,nonatomic)NSString *provinceName; //约会省份
@property(copy,nonatomic)NSString *headImage; //头像
@property(copy,nonatomic)NSString *nickName; //昵称
@property(copy,nonatomic)NSString *sign;//签名
@property(copy,nonatomic)NSString *sex;
@property(copy,nonatomic)NSString *age;
@property(copy,nonatomic)NSString *height; //身高
@property(copy,nonatomic)NSString *constelation; //星座
@property(copy,nonatomic)NSString *edu; //学历
@property(copy,nonatomic)NSString *work; //职业
@property(copy,nonatomic)NSString *weight; //体重
@property(copy,nonatomic)NSString *userGoodAt;//擅长
@property(strong,nonatomic)NSArray *userGoodAtArr;//擅长数组

@property(copy,nonatomic)NSString *vipLevel;
@property(copy,nonatomic)NSString *aboutLove;  //关于爱情
@property(copy,nonatomic)NSString *aboutOther;
@property(copy,nonatomic)NSString *aboutSex;

@property(copy,nonatomic)NSString *money;  //金币
@property(copy,nonatomic)NSString *userId;

@property(copy,nonatomic)NSString *userMobile;
@property(copy,nonatomic)NSString *userWX;
@property(copy,nonatomic)NSString *userQQ;



- (id)initWithModelDic:(NSDictionary *)dic;
+ (id)createWithModelDic:(NSDictionary *)dic;


@end

//再次解析
@interface provinceModel : NSObject

@property (nonatomic,copy)NSString *provinceName;

+ (instancetype)modelWithDictionary:(NSDictionary *)dic;
- (instancetype)initWithDictionary:(NSDictionary *)dic;
@end

//再次解析
@interface cityModel : NSObject

@property (nonatomic,copy)NSString *provinceName;
@property (nonatomic,copy)NSString *cityName;
@property (nonatomic,copy)NSString *distrName;
+ (instancetype)modelWithDictionary:(NSDictionary *)dic;
- (instancetype)initWithDictionary:(NSDictionary *)dic;
@end
//再次解析
@interface distrModel : NSObject



@property (nonatomic,copy)NSString *distrName;
+ (instancetype)modelWithDictionary:(NSDictionary *)dic;
- (instancetype)initWithDictionary:(NSDictionary *)dic;
@end
