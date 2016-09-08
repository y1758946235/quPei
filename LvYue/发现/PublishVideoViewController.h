//
//  PublishVideoViewController.h
//  LvYue
//
//  Created by apple on 16/1/2.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "BaseViewController.h"

/**
 *  上传视频
 */

typedef void(^ReturnBlock)(BOOL isPublishVideo);

@interface PublishVideoViewController : BaseViewController

@property (nonatomic, copy) NSString *videoPath;//视频路径
@property (nonatomic, assign) BOOL isFriendVideo; //是否为朋友圈视频

@property (nonatomic, copy) ReturnBlock isPublishVideo;


@end
