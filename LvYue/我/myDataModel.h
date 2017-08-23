//
//  myDataModel.h
//  LvYue
//
//  Created by X@Han on 17/1/10.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface myDataModel : NSObject


@property(copy,nonatomic)NSString *appointType;  //约会类型
@property(copy,nonatomic)NSString *activityTime; //约会时间
@property(copy,nonatomic)NSString *createTime;  //发布约会的时间
@property(copy,nonatomic)NSString *isTest;  //是否为马甲用户 1是马甲用户 0不是马甲用户
@property(copy,nonatomic)NSString *dateCity;  //约会城市
@property(copy,nonatomic)NSString *dateProvince; //约会省份
@property(copy,nonatomic)NSString *dateDistrict;  //约会区域
@property(copy,nonatomic)NSString *datePhoto;  //约会发布的图片
@property(copy,nonatomic)NSString *dataDescription;  //约会描述的内容
@property (nonatomic,strong) NSArray *imageArr;
@property (nonatomic,assign) CGFloat cellHeight;
@property (nonatomic,assign) CGFloat dataDescriptionHeight;
@property (nonatomic,assign) CGFloat datePhotHeight;
@property(copy,nonatomic)NSString *aaLabel;  //AA
@property(copy,nonatomic)NSString *pickLabel;  //接送
@property(copy,nonatomic)NSString *sexLabel;

@property(copy,nonatomic)NSString *dataId;  //约会主键   

- (id)initWithModelDic:(NSDictionary *)dic;
+ (id)createWithModelDic:(NSDictionary *)dic;

@end
