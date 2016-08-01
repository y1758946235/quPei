//
//  FriendsCircleCell.h
//  LvYueDemo
//
//  Created by 蒋俊 on 15/9/18.
//  Copyright (c) 2015年 vison. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FriendsCircleMessage;
/**
 *  朋友圈 状态cell
 */
@interface FriendsCircleCell : UITableViewCell<UITableViewDataSource,UITableViewDelegate>


@property (nonatomic,strong) UIImageView *headImg;//头像
@property (nonatomic,strong) UILabel *nameLabel;//昵称
@property (nonatomic, strong) UIButton* reportBtn;//举报
@property (nonatomic,strong) UILabel *contentLabel;//内容
@property (nonatomic,strong) UILabel *timeLabel;//时间
@property (nonatomic,strong) UIButton *deleteBtn;//删除

@property (nonatomic, strong) UIButton* giftBtn; //礼物
@property (nonatomic,strong) UILabel *praiseNum;//点赞数
@property (nonatomic,strong) UIButton *praiseBtn;//点赞
@property (nonatomic,strong) UILabel *commentNum;//评论数
@property (nonatomic,strong) UIButton *commentBtn;//评论

@property (nonatomic,strong) NSString *imageStr;//图片资源数据源
@property (nonatomic,strong) UITableView *commentTableView;//评论tableView

@property (nonatomic,strong) NSArray *commentArray;//评论数据源

@property (nonatomic,strong) NSMutableArray *imageArray;//图片数组
@property (nonatomic,strong) UIView *separatorLine;//分割线

- (void)initWithModel:(FriendsCircleMessage *)model;

@end
