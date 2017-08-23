//
//  GoldsRecordModel.m
//  LvYue
//
//  Created by X@Han on 17/7/21.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "GoldsRecordModel.h"

@implementation GoldsRecordModel
- (id)initWithModelDic:(NSDictionary *)dic{
    // NSLog(@">>>%@",dic);
    self = [super init];
    if (self) {
        
        self.userId  = dic[@"userId"];
        self.userNickname = dic[@"userNickname"];
        self.userIcon = dic[@"userIcon"];
        self.otherUserId = dic[@"otherUserId"];
        self.otherUserNickname = dic[@"otherUserNickname"];
        self.otherUserIcon = dic[@"otherUserIcon"];
        self.type = dic[@"type"];
        self.userGold = dic[@"userGold"];
        self.userPoint = dic[@"userPoint"];
        self.createTime = dic[@"createTime"];
        self.videoTime = dic[@"videoTime"];
    }
    
    return self;
}

+ (id)createWithModelDic:(NSDictionary *)dic{
    
    return [[self alloc]initWithModelDic:dic];
}
@end
