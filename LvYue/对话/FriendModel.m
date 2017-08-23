//
//  FriendModel.m
//  LvYue
//
//  Created by X@Han on 16/12/30.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "FriendModel.h"

@implementation FriendModel

- (id)initWithModelDic:(NSDictionary *)dic{
    
    if (self) {
        self.userId = dic[@"userId"];
        self.userIcon = dic[@"userIcon"];
        self.userName = dic[@"userNickname"];
    }
    return self;
}
+ (id)createWithModelDic:(NSDictionary *)dic{
    return [[self alloc]initWithModelDic:dic];
}





@end
