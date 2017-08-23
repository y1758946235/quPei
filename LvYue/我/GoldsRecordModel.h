//
//  GoldsRecordModel.h
//  LvYue
//
//  Created by X@Han on 17/7/21.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GoldsRecordModel : NSObject

@property(copy,nonatomic)NSString *userId;
@property(copy,nonatomic)NSString *userNickname;
@property(copy,nonatomic)NSString *userIcon;
@property(copy,nonatomic)NSString *otherUserId;
@property(copy,nonatomic)NSString *otherUserNickname;
@property(copy,nonatomic)NSString *otherUserIcon;
@property(copy,nonatomic)NSString *type;
@property(copy,nonatomic)NSString *userGold;
@property(copy,nonatomic)NSString *userPoint;
@property(copy,nonatomic)NSString *createTime;
@property(copy,nonatomic)NSString *videoTime;
- (id)initWithModelDic:(NSDictionary *)dic;
+ (id)createWithModelDic:(NSDictionary *)dic;
@end
