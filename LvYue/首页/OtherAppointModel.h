//
//  OtherAppointModel.h
//  LvYue
//
//  Created by X@Han on 17/1/12.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OtherAppointModel : NSObject

@property(nonatomic,copy)NSString *dateName;   //约会类型名
@property(nonatomic,copy)NSString *sendDateTime;   //发布约会的时间
@property(nonatomic,copy)NSString *dateTime;  //约会的时间
@property(nonatomic,copy)NSString *BuyLabel;

@property(copy,nonatomic)NSString *dateCity;  //约会城市
@property(copy,nonatomic)NSString *dateProvince; //约会省份
@property(copy,nonatomic)NSString *dateDistrict;  //约会区域
@property(copy,nonatomic)NSString *datePhoto;  //约会发布的图片
@property(copy,nonatomic)NSString *dataDescription;  //约会描述的内容

@property(copy,nonatomic)NSString *insrName;  //被感兴趣的发布人名字





- (id)initWithModelDic:(NSDictionary *)dic;
+ (id)createWithModelDic:(NSDictionary *)dic;

@end
