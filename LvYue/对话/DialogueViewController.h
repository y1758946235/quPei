//
//  DialogueViewController.h
//  LvYue
//
//  Created by apple on 15/9/28.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import "BaseViewController.h"
@class MessageViewController;
@class MyContractsViewController;

@interface DialogueViewController : BaseViewController

//消息控制器
@property (nonatomic, strong) MessageViewController *messageVC;

//通讯录列表控制器
@property (nonatomic, strong) MyContractsViewController *myContactVC;

//通讯录消息提醒器
@property (nonatomic, strong) UILabel *unReadLabel;

@end
