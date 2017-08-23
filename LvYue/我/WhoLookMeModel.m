//
//  WhoLookMeModel.m
//  LvYue
//
//  Created by X@Han on 16/12/19.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "WhoLookMeModel.h"

@implementation WhoLookMeModel

- (id)initWithDict:(NSDictionary *)dict{
    if (self) {
        
       
        self.peopleName = dict[@"userNickname"];
        self.imageName = dict[@"userIcon"];
        self.age = dict[@"userAge"];
        self.height = dict[@"userHeight"];
        self.collean = dict[@"userGold"];
        self.Time = dict[@"createTime"];
        self.userId = dict[@"userId"];
         self.vipLevel = dict[@"vipLevel"];
        if ([CommonTool dx_isNullOrNilWithObject:self.collean]) {
            self.collean = @"";
        }
        if ([CommonTool dx_isNullOrNilWithObject:self.height]) {
            self.height = @"";
        }
        if ([CommonTool dx_isNullOrNilWithObject:self.age]) {
            self.age = @"";
        }
        
    }
    
    return self;
}


+ (id)createModelWithDic:(NSDictionary *)dic{
    return [[self alloc]initWithDict:dic];
}


@end
