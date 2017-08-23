//
//  DyVideoListModel.h
//  LvYue
//
//  Created by X@Han on 17/5/22.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DyVideoListModel : NSObject
@property(copy,nonatomic)NSString *userId;  //用户主键
@property(copy,nonatomic)NSString *otherUserId;  //用户主键
@property(copy,nonatomic)NSString *createTime;  //
@property(copy,nonatomic)NSString *insertTime;  //
@property(copy,nonatomic)NSString *isRelay;  //
@property(copy,nonatomic)NSString *shareUrl;  //视频地址
@property(copy,nonatomic)NSString *showUrl;  //图片地址
@property(copy,nonatomic)NSString *userIcon;  //
@property(copy,nonatomic)NSString *userNickname;  //
@property(copy,nonatomic)NSString *vipLevel;
@property(copy,nonatomic)NSString *shareType;
@property(copy,nonatomic)NSString *shareSignature;
@property(copy,nonatomic)NSString *videoId;
@property(copy,nonatomic)NSString *isTest;


@property(copy,nonatomic)NSString *isVideoTopic;
@property(copy,nonatomic)NSString *videoTopicId;
@property(copy,nonatomic)NSString *videoTopicName;
@property(copy,nonatomic)NSString *videoTopicPosition;
@property(copy,nonatomic)NSString *videoSignature;

- (id)initWithModelDic:(NSDictionary *)dic;
+ (id)createWithModelDic:(NSDictionary *)dic;
@end
