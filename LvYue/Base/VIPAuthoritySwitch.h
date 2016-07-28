//
//  VIPAuthoritySwitch.h
//  LvYue
//
//  Created by apple on 15/10/28.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  VIP权限开关
 */

@interface VIPAuthoritySwitch : NSObject

//聊天发消息权限
@property (nonatomic, copy) NSString *chatSwitch;

//查看联系方式权限
@property (nonatomic, copy) NSString *phoneSwitch;

//朋友圈发布动态权限
@property (nonatomic, copy) NSString *publishSwith;//0为非会员也可以发布，1就是会员才可发布

//播放视频圈视频的权限
@property (nonatomic, copy) NSString *playVideoSwitch;

//发布视频圈视频的权限
@property (nonatomic, copy) NSString *publishVideoSwitch;

@end
