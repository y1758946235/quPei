//
//  appointModel.h
//  LvYue
//
//  Created by X@Han on 16/12/5.
//  Copyright © 2016年 OLFT. All rights reserved.
//
typedef void (^ReturnDiquBlock)(NSString *provinceStr,NSString *cityStr,NSString *districtStr);
#import <Foundation/Foundation.h>

@interface appointModel : NSObject
@property(copy,nonatomic)NSString *appointType;  //约会类型
@property(copy,nonatomic)NSString *activityTime; //约会时间
@property(copy,nonatomic)NSString *createTime;  //发布约会的时间
@property(copy,nonatomic)NSString *createTimestamp;  //发布约会的时间戳
@property(copy,nonatomic)NSString *isTest;  //是否为马甲用户 1是马甲用户 0不是马甲用户
@property(copy,nonatomic)NSString *dateCity;  //约会城市
@property(copy,nonatomic)NSString *dateProvince; //约会省份
@property(copy,nonatomic)NSString *dateDistrict;  //约会区域
@property(copy,nonatomic)NSString *dateCityStr;  //约会城市
@property(copy,nonatomic)NSString *dateProvinceStr; //约会省份
@property(copy,nonatomic)NSString *dateDistrictStr;  //约会区域
@property(copy,nonatomic)NSString *datePhoto;  //约会发布的图片
@property(copy,nonatomic)NSString *nickName; //昵称
@property(copy,nonatomic)NSString *remark; //备注 （目前还不可以备注）
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
@property(copy,nonatomic)NSString *vipLevel;
@property(copy,nonatomic)NSMutableArray *intrestedImageArr; //感兴趣人的头像
@property(retain,nonatomic)NSArray *integerDatePersonArr; //感兴趣人的信息
@property(copy,nonatomic)NSString *inststates; //感兴趣状态

@property(copy,nonatomic)NSString *dataDescription;  //约会描述的内容
@property (nonatomic,strong) NSArray *imageArr;
@property (nonatomic,assign) CGFloat cellHeight;
@property (nonatomic,assign) CGFloat  dataDescriptionHeight;
@property (nonatomic,assign) CGFloat  imageTopY;
@property (nonatomic,assign) CGFloat  imageHeight;
@property (nonatomic,assign) CGFloat  chatBtnTopY;

@property(nonatomic,copy)NSString *otherId; //进入别人主页的ID
@property(nonatomic,copy)NSString *dateActivityId; //本次活动的ID


- (id)initWithModelDic:(NSDictionary *)dic;
+ (id)createWithModelDic:(NSDictionary *)dic;


//@property (nonatomic, copy) ReturnDiquBlock returnDiquBlock;
//
//- (void)ReturnDiquName:(ReturnDiquBlock)block;
@end
////再次解析
//@interface integerDatePerson : NSObject
//
//@property (nonatomic,copy)NSString *userId;
//@property (nonatomic,copy)NSString *userIcon;
//+ (instancetype)modelWithDictionary:(NSDictionary *)dic;
//- (instancetype)initWithDictionary:(NSDictionary *)dic;
//@end
