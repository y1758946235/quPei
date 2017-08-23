//
//  VipModel.h
//  LvYue
//
//  Created by 广有射怪鸟事 on 15/10/15.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VipModel : NSObject


@property (nonatomic,strong) NSString *_input_charset;
@property (nonatomic,strong) NSString *body;
@property (nonatomic,strong) NSString *it_b_pay;
@property (nonatomic,strong) NSString *notify_url;
@property (nonatomic,strong) NSString *out_trade_no;
@property (nonatomic,strong) NSString *partner;
@property (nonatomic,strong) NSString *payment_type;
@property (nonatomic,strong) NSString *rsa_key;
@property (nonatomic,strong) NSString *seller_id;
@property (nonatomic,strong) NSString *subject;
@property (nonatomic,strong) NSString *total_fee;
@property (nonatomic,strong) NSString *service;

- (id)initWithDict:(NSDictionary *)dict;


@end
