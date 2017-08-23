//
//  taskModel.m
//  LvYue
//
//  Created by X@Han on 17/4/10.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "taskModel.h"

@implementation taskModel
- (id)initWithModelDic:(NSDictionary *)dic{
    if (self) {
        self.taskId = dic[@"taskId"];
        self.taskContent = dic[@"taskContent"];
        self.keyNumber = dic[@"keyNumber"];
        self.interfaceName =  dic[@"interfaceName"];
        self.isFinish =  dic[@"isFinish"];
        if ([[NSString stringWithFormat:@"%@",self.isFinish] isEqualToString:@"0"]) {
            self.isFinishStr = @"未完成";
        }
        if ([[NSString stringWithFormat:@"%@",self.isFinish] isEqualToString:@"1"]) {
            self.isFinishStr = @"已完成";
        }
        if ([[NSString stringWithFormat:@"%@",self.isFinish] isEqualToString:@"2"]) {
            self.isFinishStr = @"完成未领取";
        }
            }
    return self;
}


+ (id)createWithModelDic:(NSDictionary *)dic{
    return [[self alloc]initWithModelDic:dic];
}


@end
