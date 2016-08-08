//
//  HotTopicViewController.h
//  LvYue
//
//  Created by KFallen on 16/7/29.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "BaseViewController.h"

//NS_ASSUME_NONNULL_BEGIN
@interface HotTopicViewController : BaseViewController

@property (nonatomic,strong) NSString *userId; //sssws
@property (nonatomic,assign) BOOL isFriendsCircle;//是否是朋友圈
@property (nonatomic,strong) NSString *personName;


@property (nonatomic, copy) NSString* topic_id;//热门话题id

@end

//NS_ASSUME_NONNULL_END