//
//  VideoDetail.h
//  LvYue
//
//  Created by Olive on 16/1/6.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VideoOwner.h"

/**
 *  视频模型
 */

@interface VideoDetail : NSObject

@property (nonatomic, copy) NSString *videoID;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *publishTime;
@property (nonatomic, copy) NSString *videoDesc;
@property (nonatomic, copy) NSString *videoType;
@property (nonatomic, copy) NSString *praiseNum;
@property (nonatomic, copy) NSString *isPraiseByMe; //是否被自己赞过
@property (nonatomic, strong) VideoOwner *owner; //视频拥有者

- (instancetype)initWithDict:(NSDictionary *)dict;

//获得处理后的时间描述
- (NSString *)getPerfectTime;

//计算cell的高度
- (CGFloat)getCellHeight;

//计算"视频描述"的文字高度
- (CGFloat)getDescHeight;

//计算"发布者名字"的文字宽度
- (CGFloat)getNameWidth;

@end
