//
//  DynamicListModel.h
//  LvYue
//
//  Created by X@Han on 17/6/7.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DynamicListModel : NSObject
@property(copy,nonatomic)NSString *shareId;  //用户主键
@property(copy,nonatomic)NSString *userId;  //用户主键
@property(copy,nonatomic)NSString *otherUserId;  //用户主键
@property(copy,nonatomic)NSString *createTime;  //
@property(copy,nonatomic)NSString *insertTime;  //
@property(copy,nonatomic)NSString *userSex;  //
@property(copy,nonatomic)NSString *userAge;  //
@property(copy,nonatomic)NSString *isRelay;  //
@property(copy,nonatomic)NSString *shareUrl;  //视频地址
@property(copy,nonatomic)NSString *showUrl;  //图片地址
@property(copy,nonatomic)NSString *userIcon;  //
@property(copy,nonatomic)NSString *userNickname;  //
@property(copy,nonatomic)NSString *vipLevel;
@property(copy,nonatomic)NSString *shareType;
@property(copy,nonatomic)NSString *shareSignature;
@property (nonatomic,strong) NSArray *showImageArr;
@property(assign,nonatomic)CGFloat contLabelHeight;
@property(assign,nonatomic)CGFloat showImageVheight;

@property(copy,nonatomic)NSString *videoCommentNumber;  //
@property(copy,nonatomic)NSString *isLike;
@property(copy,nonatomic)NSString *likeNumber;
@property(copy,nonatomic)NSString *playNumber;
@property(copy,nonatomic)NSString *videoId;

- (id)initWithModelDic:(NSDictionary *)dic;
+ (id)createWithModelDic:(NSDictionary *)dic;
@end
