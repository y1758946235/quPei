//
//  FriendsMessageViewController.h
//  LvYueDemo
//
//  Created by 蒋俊 on 15/10/12.
//  Copyright (c) 2015年 vison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
/**
 *  朋友圈 - 消息  控制器
 */
//设置block 来设置隐藏view
typedef void(^hideMsgViewBlock)(BOOL ishide);

@interface FriendsMessageViewController : BaseViewController

@property (nonatomic, copy) hideMsgViewBlock hideMsgViewBlock;


@end
