//
//  myIntrsedModel.h
//  LvYue
//
//  Created by X@Han on 17/1/17.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface myIntrsedModel : NSObject

@property(copy,nonatomic)NSString *appointType;  //约会类型
@property(copy,nonatomic)NSString *activityTime; //约会时间
@property(copy,nonatomic)NSString *createTime;  //发布约会的时间
@property(copy,nonatomic)NSString *dateCity;  //约会城市
@property(copy,nonatomic)NSString *dateProvince; //约会省份
@property(copy,nonatomic)NSString *dateDistrict;  //约会区域
@property(copy,nonatomic)NSString *datePhoto;  //约会发布的图片
@property(copy,nonatomic)NSString *nickName; //昵称
@property(copy,nonatomic)NSString *age;
@property(copy,nonatomic)NSString *height; //身高
@property(copy,nonatomic)NSString *constelation; //星座
@property(copy,nonatomic)NSString *sex; //性别
@property(copy,nonatomic)NSString *work; //职业
@property(copy,nonatomic)NSString *headImage;  //头像
@property(copy,nonatomic)NSString *aaLabel;  //AA
@property(copy,nonatomic)NSString *pickLabel;  //接送
@property(copy,nonatomic)NSString *sexLabel;
//@property(copy,nonatomic)NSString *dateImage; //发布约会的图片
@property(copy,nonatomic)NSString *vip;
@property(copy,nonatomic)NSString *intrestedImage; //感兴趣人的头像
@property(copy,nonatomic)NSString *dataDescription;  //约会描述的内容
@property (nonatomic,strong) NSArray *imageArr;
@property (nonatomic,assign) CGFloat cellHeight;

@property(nonatomic,copy)NSString *otherId; //进入别人主页的ID


- (id)initWithModelDic:(NSDictionary *)dic;
+ (id)createWithModelDic:(NSDictionary *)dic;

@end
