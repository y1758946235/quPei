//
//  WhoEvaluationModel.m
//  LvYue
//
//  Created by X@Han on 17/4/26.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "WhoEvaluationModel.h"

@implementation WhoEvaluationModel
- (id)initWithDict:(NSDictionary *)dict{
    if (self) {
        
        
        self.createTime = dict[@"createTime"];
        self.gradeContent = dict[@"gradeContent"];
        self.gradeNumber = dict[@"gradeNumber"];
        self.userNickname = dict[@"userNickname"];
        self.otherUserId = dict[@"otherUserId"];
        self.userIcon = dict[@"userIcon"];
        self.userId = dict[@"userId"];
    }
    return self;
}


+ (id)createModelWithDic:(NSDictionary *)dic{
    return [[self alloc]initWithDict:dic];
}

@end
