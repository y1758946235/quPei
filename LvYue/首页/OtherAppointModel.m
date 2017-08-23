//
//  OtherAppointModel.m
//  LvYue
//
//  Created by X@Han on 17/1/12.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "OtherAppointModel.h"

@implementation OtherAppointModel

- (id)initWithModelDic:(NSDictionary *)dic{
   
    self = [super init];
    if (self) {
      
        self.dateName = dic[@"dateTypeName"];
        self.dateTime = dic[@"activityTime"];
        self.sendDateTime = dic[@"createTime"];
        self.BuyLabel = dic[@"dateTagNameArr"];
        self.dateCity = dic[@"dateCity"];
        self.dateProvince = dic[@"dateProvince"];
        self.dateDistrict = dic[@"dateDistrict"];
        self.dataDescription = dic[@"dateSignature"];
        self.insrName = dic[@"userNickname"];
    }
    
    return self;
}

+ (id)createWithModelDic:(NSDictionary *)dic{
    
    return [[self alloc]initWithModelDic:dic];
}


@end
