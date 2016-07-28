//
//  OrderModel.h
//  LvYue
//
//  Created by 广有射怪鸟事 on 15/10/16.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderModel : NSObject

@property (nonatomic,strong) NSString *amount;//金额，元
@property (nonatomic,strong) NSString *begin_time;//开始时间
@property (nonatomic,strong) NSString *buyer;//买家id
@property (nonatomic,strong) NSString *buyer_name;//买家名
@property (nonatomic,strong) NSString *channel;//支付渠道，0支付宝（默认
@property (nonatomic,strong) NSString *content;//服务内容
@property (nonatomic,strong) NSString *create_ip;//创建客户端ip
@property (nonatomic,strong) NSString *create_time;//创建时间
@property (nonatomic,strong) NSString *end_time;//服务结束时间
@property (nonatomic,strong) NSString *evaluation;//评价星级
@property (nonatomic,strong) NSString *orderId;//订单id
@property (nonatomic,strong) NSString *order_no;//订单编号
@property (nonatomic,strong) NSString *out_order_no;//外部订单号
@property (nonatomic,strong) NSString *pay;//是否支付给导游，0没，1是
@property (nonatomic,strong) NSString *refund_no;//退款单号
@property (nonatomic,strong) NSString *refund_reason;//退款理由
@property (nonatomic,strong) NSString *seller;//卖家id
@property (nonatomic,strong) NSString *seller_name;//卖家名
@property (nonatomic,strong) NSString *status;//订单状态(0-未付款；1-已付款未接单；2-已完成；3-退款中；4-已退款；5-支付失败;6-导游拒绝订单退款中;7-已付款已接单)
@property (nonatomic,strong) NSString *update_time;//更新时间
@property (nonatomic,strong) NSString *buyer_mobile;//买家电话号码
@property (nonatomic,strong) NSString *seller_mobile;//卖家电话号码

- (id)initWithDict:(NSDictionary *)dict;


@end
