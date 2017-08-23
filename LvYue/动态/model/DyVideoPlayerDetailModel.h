//
//  DyVideoPlayerDetailModel.h
//  LvYue
//
//  Created by X@Han on 17/8/3.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DyVideoPlayerDetailModel : NSObject
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
@property(copy,nonatomic)NSString *shareId;
@property(copy,nonatomic)NSString *videoComment;
@property(copy,nonatomic)NSString *userAge;
@property(copy,nonatomic)NSString *userSex;

@property(assign,nonatomic)CGFloat contLabelHeight;

- (id)initWithModelDic:(NSDictionary *)dic;
+ (id)createWithModelDic:(NSDictionary *)dic;
@end
