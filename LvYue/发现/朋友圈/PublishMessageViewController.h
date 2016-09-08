//
//  PublishMessageViewController.h
//  LvYueDemo
//
//  Created by 蒋俊 on 15/10/10.
//  Copyright (c) 2015年 vison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

/**
 *  发布 消息动态 - 朋友圈
 */
//定义一个block
//typedef void(^ReturnIsPublish)(NSString *isPublish);
typedef void(^ReturnIsPublish)(BOOL isPublish);

@interface PublishMessageViewController : BaseViewController

@property (nonatomic, copy) NSString* hotId;        //话题ID, 是否为热门话题

@property (nonatomic, copy) ReturnIsPublish isPublish;


//@property (nonatomic, strong) ReturnIsPublish isPublishBlock;

//- (void)ReturnIsPublish:(ReturnIsPublish)block;
@end
