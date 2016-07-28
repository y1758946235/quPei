//
//  VideoDetailModel.h
//  LvYue
//
//  Created by Olive on 15/12/31.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VideoPublishPerson.h"

/**
 *  视频模型
 */

@interface VideoDetailModel : NSObject

/**** 发布人详情 ****/
@property (nonatomic, strong) VideoPublishPerson *person;

/**** 视频详情 ****/
@property (nonatomic, copy) NSString *publishTime;
@property (nonatomic, copy) NSString *videoUrl;
@property (nonatomic, copy) NSString *videoDesc;
@property (nonatomic, strong) UIImage *videoCover; //视频第一秒的截图

- (instancetype)initWithDict:(NSDictionary *)dict;

@end
