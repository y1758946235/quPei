//
//  otherZhuYeVC.h
//  LvYue
//
//  Created by X@Han on 16/12/8.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "BaseViewController.h"

@interface otherZhuYeVC : BaseViewController
@property (nonatomic, assign) BOOL isChatVC; //是否从聊天界面进入主页的页面的,防止重复注册

@property (nonatomic, assign) BOOL isExistedSendGiftAskNotification;

@property(nonatomic,copy)NSString *userId;
@property(nonatomic,copy)NSString *userNickName;



@end
