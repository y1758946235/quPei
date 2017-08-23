//
//  DyVideoPlayerDetailModel.m
//  LvYue
//
//  Created by X@Han on 17/8/3.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "DyVideoPlayerDetailModel.h"

@implementation DyVideoPlayerDetailModel
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
        self.videoComment= dic[@"videoComment"];
        self.userAge= dic[@"userAge"];
        self.userSex= dic[@"userSex"];
        
        
        
        CGRect size = [self.videoComment boundingRectWithSize:CGSizeMake(SCREEN_WIDTH-92, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil];
        self.contLabelHeight = size.size.height;
    }
    return self;
}
+ (id)createWithModelDic:(NSDictionary *)dic{
    
    return [[self alloc]initWithModelDic:dic];
    
}
@end
