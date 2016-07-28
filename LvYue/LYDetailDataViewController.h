//
//  LYDetailDataViewController.h
//  LvYue
//
//  Created by KentonYu on 16/7/22.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "BaseViewController.h"

@interface LYDetailDataViewController : BaseViewController

// 来自聊天界面
@property (nonatomic, assign) BOOL fromChatVC;
// 用户ID
@property (nonatomic, copy) NSString *userId;

@end
