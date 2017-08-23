//
//  ReceiveGiftModel.m
//  LvYue
//
//  Created by X@Han on 17/3/21.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "ReceiveGiftModel.h"

@implementation ReceiveGiftModel
- (id)initWithModelDic:(NSDictionary *)dic{
    if (self) {
        self.userId = dic[@"userId"];
        self.createTime = dic[@"createTime"];
        self.userIcon = dic[@"userIcon"];
        self.userNickname = dic[@"userNickname"];
        self.otherUserId = dic[@"otherUserId"];
        self.giftId = dic[@"giftId"];
        self.goldPrice = dic[@"goldPrice"];
         self.giftName = dic[@"giftName"];
        self.giftIcon = dic[@"giftIcon"];

       
        
        
    }
    return self;
}
+ (id)createWithModelDic:(NSDictionary *)dic{
    
    return [[self alloc]initWithModelDic:dic];
    
}
@end
