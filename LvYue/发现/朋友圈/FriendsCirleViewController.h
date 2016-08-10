//
//  FriendsCirleViewController.h
//  LvYueDemo
//
//  Created by 蒋俊 on 15/9/17.
//  Copyright (c) 2015年 vison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface FriendsCirleViewController : BaseViewController

@property (nonatomic,strong) NSString *userId;
@property (nonatomic,assign) BOOL isFriendsCircle;// 朋友圈|个人动态  默认YES
@property (nonatomic,strong) NSString *personName;

@end
