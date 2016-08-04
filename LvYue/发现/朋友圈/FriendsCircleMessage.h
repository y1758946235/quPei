//
//  FriendsCircleMessage.h
//  LvYueDemo
//
//  Created by 蒋俊 on 15/10/19.
//  Copyright (c) 2015年 vison. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FriendsCircleMessage : NSObject

@property (nonatomic,strong) NSString *headImgStr;//头像
@property (nonatomic,strong) NSString *name;//昵称
@property (nonatomic,strong) NSString *content;//内容
@property (nonatomic,strong) NSString *time;//时间
@property (nonatomic,strong) NSString *praiseNum;//点赞数
@property (nonatomic,strong) NSString *commentNum;//评论数
@property (nonatomic,strong) NSString *imageStr;//图片资源数据源
@property (nonatomic,strong) NSArray *commentArray;//评论数据源
@property (nonatomic,strong) NSString *userId;//用户id
@property (nonatomic,copy) NSString *commentUserName; //评论人名字
@property (nonatomic,copy) NSString *replyUserName; //回复人名字

@property (nonatomic, copy) NSString* isHot;     //是否为热门热门话题的热门动态
@property (nonatomic, copy) NSString* videoUrl;  //视频地址
@property (nonatomic, copy) NSString* nType;     //1图文说说;2.视频

@property (nonatomic, copy) NSString* hotName;  //热门话题名字
@property (nonatomic, copy) NSString* hot_id;   //热门话题的ID



@property (nonatomic,assign) CGFloat cellHeight;//cell的自适应高度

- (id)initWithDict:(NSDictionary *)dict;
- (void)setCommentList:(NSMutableArray *)commentArray;
- (void)setPraiseList:(NSMutableArray *)praiseArray;

- (NSString *)getTime;//获取转化时间
- (CGFloat)returnCellHeight;//返回cell的高度
@end
