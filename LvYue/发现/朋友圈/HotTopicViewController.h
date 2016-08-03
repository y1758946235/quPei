//
//  HotTopicViewController.h
//  LvYue
//
//  Created by KFallen on 16/7/29.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "BaseViewController.h"

@interface HotTopicViewController : BaseViewController

@property (nonatomic,strong) NSString *userId;
@property (nonatomic,assign) BOOL isFriendsCircle;//是否是朋友圈
@property (nonatomic,strong) NSString *personName;

@property (nonatomic, assign) NSString* topic_id;//热门话题id

@end
