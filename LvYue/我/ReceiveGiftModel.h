//
//  ReceiveGiftModel.h
//  LvYue
//
//  Created by X@Han on 17/3/21.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReceiveGiftModel : NSObject
@property(copy,nonatomic)NSString *userId;//赠送主键id(Integer)
@property(copy,nonatomic)NSString *userIcon;//:赠送人头像
@property(copy,nonatomic)NSString* userNickname;//:赠送人昵称
@property(copy,nonatomic)NSString *otherUserId;//:被动接收人主键id(Integer)
@property(copy,nonatomic)NSString *createTime;//:购买时间
@property(copy,nonatomic)NSString *giftId;//:礼物主键id(Integer)
@property(copy,nonatomic)NSString *goldPrice;//:金币价格(Integer)
@property(copy,nonatomic)NSString *giftIcon;//:礼物giftIcon(Integer)
@property(copy,nonatomic)NSString *giftName;//:礼物giftName(Integer)

- (id)initWithModelDic:(NSDictionary *)dic;
+ (id)createWithModelDic:(NSDictionary *)dic;
@end
