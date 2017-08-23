//
//  DyVideoListModel.m
//  LvYue
//
//  Created by X@Han on 17/5/22.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "DyVideoListModel.h"

@implementation DyVideoListModel
- (id)initWithModelDic:(NSDictionary *)dic{
    if (self) {
        
        self.userId = dic[@"userId"];
        self.createTime = dic[@"createTime"];
          self.insertTime = dic[@"insertTime"];
        self.isRelay = dic[@"isRelay"];
        self.shareUrl = dic[@"videoUrl"];
        self.showUrl = dic[@"showUrl"];
        self.userIcon = dic[@"userIcon"];
        self.userNickname = dic[@"userNickname"];
        self.vipLevel = dic[@"vipLevel"];
        self.otherUserId = dic[@"otherUserId"];
        self.shareType = dic[@"shareType"];
        self.shareSignature= dic[@"videoSignature"];
        self.videoId= dic[@"videoId"];
        self.isTest = dic[@"isTest"];
        
        
        self.isVideoTopic= dic[@"isVideoTopic"];
        self.videoTopicId= dic[@"videoTopicId"];
        self.videoTopicName= dic[@"videoTopicName"];
        self.videoTopicPosition= dic[@"videoTopicPosition"];
        
        self.videoSignature= dic[@"videoSignature"];
        if ([CommonTool dx_isNullOrNilWithObject:dic[@"videoSignature"]]) {
            self.videoSignature= @"";
        }
        
    }
    return self;
}
+ (id)createWithModelDic:(NSDictionary *)dic{
    
    return [[self alloc]initWithModelDic:dic];
    
}
@end
