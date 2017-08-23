//
//  UserModel.m
//  LvYue
//
//  Created by X@Han on 16/12/14.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "UserModel.h"

@implementation UserModel

- (id)initWithModelDic:(NSDictionary *)dic{
    if (self) {
        self.nick = dic[@"userNickname"];
        self.agel = dic[@"userAge"];
        self.sexStr = dic[@"userSex"];
        self.dateImage = dic[@"userIcon"];
        self.userId = dic[@"userId"];
         self.isAffirm = dic[@"isAffirm"];
        self.userVideo = dic[@"userVideo"];
    }
    return self;
}
+ (id)createWithModelDic:(NSDictionary *)dic{
    
    return [[self alloc]initWithModelDic:dic];
    
}



@end
