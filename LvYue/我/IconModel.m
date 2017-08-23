//
//  IconModel.m
//  LvYue
//
//  Created by X@Han on 17/1/5.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "IconModel.h"

@implementation IconModel

- (id)initWithModelDic:(NSDictionary *)dic{
    if (self) {
        self.money = dic[@"userGold"];
        self.instesd = dic[@"interestNumber"];
        self.aboutAppoint = dic[@"dateNumber"];
        self.userKey =  dic[@"userKey"];
        self.gift =  dic[@"gift"];
        self.userPoint =  dic[@"userPoint"];
        self.vipLevel =  dic[@"vipLevel"];
        if ([CommonTool dx_isNullOrNilWithObject:self.money]) {
            self.money = @"0";
        }
        if ([CommonTool dx_isNullOrNilWithObject:self.userKey]) {
            self.userKey = @"0";
        }
        if ([CommonTool dx_isNullOrNilWithObject:self.gift]) {
            self.gift = @"0";
        }
        if ([CommonTool dx_isNullOrNilWithObject:self.instesd]) {
            self.instesd = @"";
        }
        if ([CommonTool dx_isNullOrNilWithObject:self.aboutAppoint]) {
            self.aboutAppoint = @"";
        }
        if ([CommonTool dx_isNullOrNilWithObject:self.userPoint]) {
            self.userPoint = @"0";
        }
    }
    return self;
}


+ (id)createWithModelDic:(NSDictionary *)dic{
    return [[self alloc]initWithModelDic:dic];
}


@end
