//
//  InvitaModel.m
//  LvYue
//
//  Created by X@Han on 17/4/20.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "InvitaModel.h"

@implementation InvitaModel
- (id)initWithDict:(NSDictionary *)dict{
    if (self) {
        
        
        
        
        
        self.userNickname = dict[@"userNickname"];
        self.userIcon = dict[@"userIcon"];
        self.dateActivityId = dict[@"dateActivityId"];
        self.dateTypeName = dict[@"dateTypeName"];
        self.createTime = dict[@"createTime"];
        self.userId = dict[@"userId"];
        
        
    }
    
    return self;
}


+ (id)createModelWithDic:(NSDictionary *)dic{
    return [[self alloc]initWithDict:dic];
}
@end
