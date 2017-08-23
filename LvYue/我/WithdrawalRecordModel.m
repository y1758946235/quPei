//
//  WithdrawalRecordModel.m
//  LvYue
//
//  Created by X@Han on 17/4/11.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "WithdrawalRecordModel.h"

@implementation WithdrawalRecordModel
- (id)initWithModelDic:(NSDictionary *)dic{
    if (self) {
        self.userId = dic[@"userId"];
        self.createTime = dic[@"createTime"];
        self.updateTime = dic[@"updateTime"];
        self.withdrawalId = dic[@"withdrawalId"];
        self.withdrawalPoint = dic[@"withdrawalPoint"];
        self.withdrawalAmount = dic[@"withdrawalAmount"];
        self.withdrawalChannel = dic[@"withdrawalChannel"];
        self.withdrawalAccount = dic[@"withdrawalAccount"];
         self.withdrawalStatus = dic[@"withdrawalStatus"];
//        if ([[NSString stringWithFormat:@"%@",self.withdrawalChannel]  isEqualToString:@"0"]) {
            if ([[NSString stringWithFormat:@"%@",self.withdrawalStatus]  isEqualToString:@"0"]) {
                self.withdrawalStatusStr = @"等待确认提现";
            }
            if ([[NSString stringWithFormat:@"%@",self.withdrawalStatus]  isEqualToString:@"1"]) {
                self.withdrawalStatusStr = @"关闭提现";
            }
            if ([[NSString stringWithFormat:@"%@",self.withdrawalStatus]  isEqualToString:@"2"]) {
                self.withdrawalStatusStr = @"提现已完成";
            }
            if ([[NSString stringWithFormat:@"%@",self.withdrawalStatus]  isEqualToString:@"5"]) {
                self.withdrawalStatusStr = @"提现失败";
            }
            

//        }
//        if ([[NSString stringWithFormat:@"%@",self.withdrawalChannel]  isEqualToString:@"1"]) {
//            if ([[NSString stringWithFormat:@"%@",self.withdrawalStatus]  isEqualToString:@"0"]) {
//                self.withdrawalStatusStr = @"等待确认微信提现";
//            }
//            if ([[NSString stringWithFormat:@"%@",self.withdrawalStatus]  isEqualToString:@"1"]) {
//                self.withdrawalStatusStr = @"关闭微信提现";
//            }
//            if ([[NSString stringWithFormat:@"%@",self.withdrawalStatus]  isEqualToString:@"2"]) {
//                self.withdrawalStatusStr = @"微信提现已完成";
//            }
//            if ([[NSString stringWithFormat:@"%@",self.withdrawalStatus]  isEqualToString:@"5"]) {
//                self.withdrawalStatusStr = @"微信提现失败";
//            }
//            
//            
//        }
        
    }
    return self;
}
+ (id)createWithModelDic:(NSDictionary *)dic{
    
    return [[self alloc]initWithModelDic:dic];
    
}
@end
