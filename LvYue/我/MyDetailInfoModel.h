//
//  MyDetailInfoModel.h
//  LvYue
//
//  Created by 广有射怪鸟事 on 15/10/8.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyDetailInfoModel : NSObject

@property (nonatomic, strong) NSString *city;     //城市
@property (nonatomic, strong) NSString *cityName; //城市名
@property (nonatomic, strong) NSString *countryName;
@property (nonatomic, strong) NSString *provinceName;
@property (nonatomic, strong) NSString *contact;         //联系方式
@property (nonatomic, strong) NSString *country;         //国家
@property (nonatomic, strong) NSString *explain;         //个人说明
@property (nonatomic, strong) NSString *industry;        //行业
@property (nonatomic, assign) NSInteger provide_stay;    //是否提供住宿，0为否，1为是
@property (nonatomic, strong) NSString *province;        //省份
@property (nonatomic, strong) NSString *service_price;   //服务价格
@property (nonatomic, strong) NSString *service_content; //服务内容
@property (nonatomic, strong) NSString *vip_time;        //会员到期时间
@property (nonatomic, assign) NSInteger tradeNum;        //交易单数
@property (nonatomic, strong) NSString *alipay_id;       //支付宝账号
@property (nonatomic, strong) NSString *weixin_id;       //微信账号
@property (nonatomic, strong) NSString *status;          //导游申请状态
@property (nonatomic, copy) NSString *authVideoPath;     //认证视频路径

- (id)initWithDict:(NSDictionary *)dict;

@end
