//
//  MoneyListModel.m
//  LvYue
//
//  Created by X@Han on 17/4/6.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "MoneyListModel.h"

@implementation MoneyListModel

- (id)initWithModelDic:(NSDictionary *)dic{
    if (self) {
        self.userId = dic[@"userId"];
        self.createTime = dic[@"createTime"];
        self.updateTime = dic[@"updateTime"];
        self.orderAmount = dic[@"orderAmount"];
        self.goldNumber = dic[@"orderNumber"];
        self.orderStatus = dic[@"orderStatus"];
        if ([[NSString stringWithFormat:@"%@",self.orderStatus]  isEqualToString:@"0"]) {
            self.orderStatusStr = @"未付款";
        }
        if ([[NSString stringWithFormat:@"%@",self.orderStatus]  isEqualToString:@"2"]) {
            self.orderStatusStr = @"支付成功";
        }
        if ([[NSString stringWithFormat:@"%@",self.orderStatus]  isEqualToString:@"5"]) {
            self.orderStatusStr = @"支付失败";
        }
        
        
        
    }
    return self;
}
+ (id)createWithModelDic:(NSDictionary *)dic{
    
    return [[self alloc]initWithModelDic:dic];
    
}
@end
