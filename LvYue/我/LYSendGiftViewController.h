//
//  LYSendGiftViewController.h
//  LvYue
//
//  Created by KentonYu on 16/7/27.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "BaseViewController.h"

typedef NS_ENUM(NSUInteger, LYSendGiftFunType) {
    LYSendGiftFunTypeDefalut = 0,
    LYSendGiftFunTypeInvite  = 1 // 邀请视频认证
};

@interface LYSendGiftViewController : BaseViewController

@property (nonatomic, assign) LYSendGiftFunType type;
@property (nonatomic, strong) NSString *avatarImageURL; //对方的头像
@property (nonatomic, copy) NSString *userName;         //对方的名字
@property (nonatomic, copy) NSString *friendID;         //对方的ID

@end
