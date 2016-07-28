//
//  XWOrderModel.h
//  LvYue
//
//  Created by Xia Wei on 15/10/21.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XWOrderModel : NSObject

- (id)initWithDict:(NSDictionary *)dict;
@property(nonatomic,strong)NSString *begin_time;//开始时间
@property(nonatomic,strong)NSString *end_time;//结束时间
@property(nonatomic,strong)NSString *price;//价格
@property(nonatomic,strong)NSString *orderID;//订单ID
@property(nonatomic,strong)NSString *order_no;//订单编号
@property(nonatomic,strong)NSString *status;//订单状态
@property(nonatomic,strong)NSString *buyer;//买家用户
@property(nonatomic,strong)NSString *seller;//卖家用户
@property(nonatomic,strong)NSString *amount;//金额（单位元
@property(nonatomic,strong)NSString *content;//服务内容
@property(nonatomic,strong)NSString *create_time;//创建时间
@property(nonatomic,strong)NSString *update_time;//修改时间
@property(nonatomic,strong)NSString *channel;//支付渠道
@property(nonatomic,strong)NSString *pay;//唤起支付请求参数字符串
@property(nonatomic,strong)NSString *create_ip;//创建客户端ip

@end
