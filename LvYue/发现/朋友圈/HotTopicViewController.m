//
//  HotTopicViewController.m
//  LvYue
//
//  Created by KFallen on 16/7/29.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "AFNetworking.h"
#import "FriendsCircleCell.h"
#import "FriendsCircleMessage.h"
#import "HotTopicViewController.h"
#import "LYDetailDataViewController.h"
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "MBProgressHUD+NJ.h"
#import "MJRefresh.h"
#import "UIImageView+WebCache.h"

#import "FriendsMessageViewController.h"
#import "LYSendGiftViewController.h"
#import "PublishMessageViewController.h"
#import "ReportViewController.h"
#import "TopicTitle.h"

#import <MediaPlayer/MediaPlayer.h>
#import <objc/runtime.h>

#define kSingleContentHeight 17.895f
@interface HotTopicViewController () <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UIActionSheetDelegate> {
    UILabel *shortLabel;        //内容Label
    UIImageView *backImageView; //话题背景图
    UILabel *joinLabel;         //参与人数
    CGFloat margin;             //下移距离
    NSString *topicStr;         //热门话题


    CGFloat contentHeight; //内容真实高度
    UIButton *joinBtn;     //话题参与按钮
    UIButton *lookAllBtn;  //查看按钮
    UIView *headerView;    //头部视图

    NSURL *_currentVideoURL; //当前准备要播放的视频的URL


    UIView *_addView;
    UIButton *_clearBtn;              //透明按钮
    UIView *_inputView;               //输入条
    UITextView *_textView;            //输入框
    NSDictionary *_dataDict;          //数据源
    NSDictionary *_hotDataDict;       //热门数据源
    UIButton *_sendBtn;               //发送按钮
    
    NSMutableArray *_messageArray;    //全部热门话题模型数组
    NSMutableArray *_hotMessageArray; //最热话题模型数组
    
    NSMutableArray *_commentList;     //评论列表
    NSMutableArray *_praiseList;      //点赞列表
    
    NSMutableArray *_hotCommentList;     //热门动态评论列表
    NSMutableArray *_hotPraiseList;      //热门动态点赞列表
    
    NSMutableArray *_noticeList;      //消息列表
    NSMutableArray *_hotNoticeList;    //热门消息列表
    
    NSInteger _currentPage;           //当前分页

    NSMutableArray *_topicArray; //话题内容


    /*****************评论中回复他人用到的过渡字段*******************/
    NSString *_reply;           //回复的对象id
    NSString *_replyName;       //回复的对象名字
    NSString *_noticeId;        //评论的消息id
    NSString *_commenter;       //评论用户id
    UILabel *_placeHolderLabel; //评论时的提示label

    /*****************评论中删除评论用到的过渡字典*******************/
    NSDictionary *_deleteCommentDict;

    /*****************封面图片Url*****************/
    NSURL *_coverImageUrl;     //网络封面图片URL
    UIImage *_localCoverImage; //本地缓存的图片
}

@property (nonatomic, weak) UITableView *tableView; //主tableview

@property (nonatomic, strong) MPMoviePlayerViewController *player; //视频播放
@property (nonatomic, copy) NSString *hotId;                       //热门话题Id

@property (nonatomic, assign) BOOL isHotDataList;    //是否为热门动态

@end

@implementation HotTopicViewController
#pragma mark - 懒加载
- (UITableView *)tableView {
    if (_tableView == nil) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        tableView.dataSource   = self;
        tableView.delegate     = self;

        [self createHeaderView];
        _tableView                 = tableView;
        _tableView.tableHeaderView = headerView;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}


- (MPMoviePlayerViewController *)player {
    if (!_player) {
        _player                            = [[MPMoviePlayerViewController alloc] initWithContentURL:_currentVideoURL];
        _player.moviePlayer.shouldAutoplay = YES;
        [self addVideoNotifications];
    }
    return _player;
}

//添加视频监听通知
- (void)addVideoNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoDidFinishLaunch:) name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification object:_player.moviePlayer];
}

#pragma mark - 通知中心处理
//当视频做好准备时
- (void)videoDidFinishLaunch:(NSNotification *)aNotification {
    MLOG(@"视频准备好了");
}

#pragma mark - 视图加载
- (void)viewDidLoad {
    self.title = @"热门话题";
    [self setUI];

    //获得朋友圈消息列表
    [self postRequest];
    //话题详情
    [self getTopicDetail];

    //获取热门动态
    [self getHotTopic];
    //上拉下拉刷新
    [self addRefresh];

    [self addObserver];
}


- (void)setUI {
    self.tableView.hidden = NO;
    _currentPage          = 1;
    //初始化
    _messageArray    = [NSMutableArray array];
    _hotMessageArray = [NSMutableArray array];
    _commentList     = [NSMutableArray array];
    _praiseList      = [NSMutableArray array];
    _hotCommentList  = [NSMutableArray array];
    _hotPraiseList   = [NSMutableArray array];
    _praiseList      = [NSMutableArray array];
    _noticeList      = [NSMutableArray array];
    _hotNoticeList   = [NSMutableArray array];
    _topicArray      = [NSMutableArray array];
    _coverImageUrl   = nil;
    _isHotDataList = YES;
    //右边按钮
    //[self setRightButton:[UIImage imageNamed:@"more"] title:@"" target:self action:@selector(addClick) rect:CGRectMake(0, 0, 43, 43)];
    [self setLeftButton:[UIImage imageNamed:@"返回"] title:nil target:self action:@selector(back)];

    //设置tableview的头部view
    //[self createHeaderView];
}

//设置tableview的头部view
- (void)createHeaderView {

    headerView = [[UIView alloc] init];
    //背景图
    backImageView          = [[UIImageView alloc] init];
    backImageView.x        = 0;
    backImageView.y        = 0;
    backImageView.width    = kMainScreenWidth;
    backImageView.height   = 160;
    TopicTitle *titleModel = _topicArray[0];
    NSString *imgStr       = [NSString stringWithFormat:@"%@%@", IMAGEHEADER, titleModel.back_img];
    NSURL *url             = [NSURL URLWithString:imgStr];
    [backImageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"朋友圈背景"] options:SDWebImageRetryFailed];

    //backImageView.image = [UIImage imageNamed:@"朋友圈背景"];
    //backImageView.userInteractionEnabled = YES;
    [headerView addSubview:backImageView];

    //获取热门话题Id
    self.hotId = titleModel.ID;

    //背景上的文字
    joinLabel             = [[UILabel alloc] init];
    NSString *partNumsStr = [NSString stringWithFormat:@"%@人参与", titleModel.partNums];
    joinLabel.text        = partNumsStr;
    joinLabel.textColor   = [UIColor whiteColor];
    joinLabel.width       = 80;
    joinLabel.height      = 20;
    joinLabel.font        = kFont14;
    joinLabel.centerX     = kMainScreenWidth * 0.5;
    joinLabel.y           = backImageView.height - joinLabel.height - 10;
    //    joinLabel.backgroundColor = [UIColor redColor];
    [backImageView addSubview:joinLabel];

    UILabel *titleLabel = [[UILabel alloc] init];
    NSString *titleStr  = [NSString stringWithFormat:@"#%@#", titleModel.title];
    topicStr            = titleStr;
    //NSString* titleStr = @"#那些美好的风景#";
    titleLabel.text      = titleStr;
    titleLabel.font      = kFont20;
    titleLabel.textColor = [UIColor whiteColor];
    NSDictionary *attrs  = @{
        NSFontAttributeName: kFont20
    };
    CGSize titleSize   = [titleStr boundingRectWithSize:CGSizeMake(320, 50) options:NSStringDrawingTruncatesLastVisibleLine attributes:attrs context:nil].size;
    titleLabel.width   = titleSize.width;
    titleLabel.height  = 35;
    titleLabel.centerX = kMainScreenWidth * 0.5;
    titleLabel.y       = joinLabel.y - titleLabel.height;
    //    titleLabel.backgroundColor = [UIColor redColor];
    [backImageView addSubview:titleLabel];

    //简略内容Label
    shortLabel               = [[UILabel alloc] init];
    shortLabel.numberOfLines = 0;
    shortLabel.font          = kFont14;
    shortLabel.x             = 10;
    shortLabel.y             = backImageView.height + shortLabel.x;
    shortLabel.width         = kMainScreenWidth - 2 * shortLabel.x;
    shortLabel.height        = 80;
    //计算高度
    //    NSString* contentStr = @"此刻她是白锦曦，是苏眠，是《美人为馅》里的绝色警花…时间倒退，她是毓秀，是小寒，是采月，是袭香，是唤云，是八姐，是成君，是灵珊，是梅超风，是小风筝，是佟腊月，是无数无数传奇的女子…记不清多少的前世今生，她总是时而娇俏，时而狠辣，时而温柔，时而霸气，时而为情所伤，时而绝不回头…她是独立女性的代表，是绝对的演技派…时间再倒退，上戏的操场上，长发及腰的白族姑娘，十五岁的大学生，翩翩舞姿迷倒了大部分男生，但她总是安静地沉浸在戏剧的世界中，不受尘世骚扰…她信佛、念经、放生、执着…她度己亦度人，在方寸的屏幕间把热泪洒尽…她是杨蓉，她是天地的钟灵之秀…明天是她的生日，是一次新的起航…人间最美不过是把自身所学淋漓尽致地挥洒…我们渴望未来的日子里有更多的传奇女子涌现，比如刘楚玉，这是我接这个项目的唯一理由… 因为有杨蓉，戏的世界如此美好！";
    NSString *contentStr          = [NSString stringWithFormat:@"%@", titleModel.intro];
    NSDictionary *shortLabelAttrs = @{
        NSFontAttributeName: kFont14
    };
    CGSize shortLabelSize = [contentStr boundingRectWithSize:CGSizeMake(shortLabel.width, 1000) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:shortLabelAttrs context:nil].size;
    contentHeight         = shortLabelSize.height;
    if (shortLabelSize.height > 80) { //4行
        shortLabel.height = 80;
    } else {
        shortLabel.height = shortLabelSize.height;
    }
    shortLabel.text = contentStr;
    [headerView addSubview:shortLabel];

    //设置查看按钮
    lookAllBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [lookAllBtn setTitle:@"查看全部" forState:UIControlStateNormal];
    [lookAllBtn setTitleColor:RGBCOLOR(107, 140, 172) forState:UIControlStateNormal];
    lookAllBtn.titleLabel.font = kFont16;
    if (shortLabel.height < 65) { //内容少
        [lookAllBtn setFrame:CGRectZero];
    } else {
        [lookAllBtn setFrame:CGRectMake(shortLabel.x, CGRectGetMaxY(shortLabel.frame) + 3, 80, 20)];
    }
    lookAllBtn.selected = YES;
    [lookAllBtn addTarget:self action:@selector(lookAllClick:) forControlEvents:UIControlEventTouchUpInside];

    [headerView addSubview:lookAllBtn];

    //参与按钮
    joinBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [joinBtn setBackgroundColor:THEME_COLOR];
    [joinBtn setTitle:@"参与话题" forState:UIControlStateNormal];
    [joinBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    joinBtn.titleLabel.font     = kFont14;
    joinBtn.x                   = shortLabel.x;
    joinBtn.y                   = 2 * joinBtn.x + CGRectGetMaxY(shortLabel.frame) + lookAllBtn.height;
    joinBtn.width               = kMainScreenWidth - 2 * joinBtn.x;
    joinBtn.height              = 45;
    joinBtn.layer.cornerRadius  = 10.0f;
    joinBtn.layer.masksToBounds = YES;

    [joinBtn addTarget:self action:@selector(publishClick) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:joinBtn];

    //设置headerView的frame
    headerView.x               = 0;
    headerView.y               = 0;
    headerView.width           = kMainScreenWidth;
    headerView.height          = CGRectGetMaxY(joinBtn.frame) + 15;
    headerView.backgroundColor = [UIColor whiteColor];
    //_tableView.tableHeaderView = headerView;
}


#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
    //    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return _hotMessageArray.count;
    } else {
        return _messageArray.count;
    }
    //return _messageArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) { //热门动态
        static NSString *cellID = @"myCell";
        FriendsCircleCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [[FriendsCircleCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
        }

        //给头像添加手势
        cell.headImg.tag                = indexPath.row;
        UITapGestureRecognizer *headTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHotHeadImg:)];
        [cell.headImg addGestureRecognizer:headTap];

        //举报
        [cell.reportBtn addTarget:self action:@selector(reportHotClick:) forControlEvents:UIControlEventTouchUpInside];

        //送礼
        [cell.giftBtn addTarget:self action:@selector(senderHotGift:) forControlEvents:UIControlEventTouchUpInside];
        cell.giftBtn.tag = 10 + indexPath.row;
        
        
        //添加分割线
        if (_hotMessageArray.count) {
            FriendsCircleMessage *message = _hotMessageArray[indexPath.row];
            cell.separatorLine.frame      = CGRectMake(0, [message returnCellHeight] - 1, SCREEN_WIDTH, 1);

            cell.giftBtn.hidden = NO;
            NSString* tempId =nil;
            if (self.userId == nil) {
                self.userId = @"";
                tempId = @"wo";
            }
            else {
                tempId = self.userId;
            }
            if ([[NSString stringWithFormat:@"%@",message.userId] isEqualToString:tempId]) {
                cell.giftBtn.hidden = YES;
                
            }
            
            //保持最新的评论数据 和  点赞数据
            [message setCommentList:_hotCommentList[indexPath.row]];
            [message setPraiseList:_hotPraiseList[indexPath.row]];
            
            NSString *tempStr = topicStr;
            [cell initWithModel:message topicStr:tempStr];

            UITapGestureRecognizer *hotTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hotTapTitle:)];
            objc_setAssociatedObject(hotTap, @"hotTapTitleTag", @([message.hot_id integerValue] + 100), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            [cell.contentLabel addGestureRecognizer:hotTap];

            //记录当前cell的数据源索引
            cell.tag = indexPath.row;

            if ([_hotPraiseList[indexPath.row] count]) {

                for (NSDictionary *dict in _hotPraiseList[indexPath.row]) {
                    if ([[NSString stringWithFormat:@"%@", dict[@"praise_user_id"]] isEqualToString:[NSString stringWithFormat:@"%@", [LYUserService sharedInstance].userID]]) {
                        [cell.praiseBtn setImage:[UIImage imageNamed:@"Hearts red"] forState:UIControlStateNormal];
                        cell.praiseBtn.selected = YES;
                    }
                }
            } else {
                [cell.praiseBtn setImage:[UIImage imageNamed:@"Hearts gray"] forState:UIControlStateNormal];
                cell.praiseBtn.selected = NO;
            }
        }

        [cell.praiseBtn addTarget:self action:@selector(praiseClick:) forControlEvents:UIControlEventTouchUpInside];

        //给cell tag赋值
        cell.commentBtn.tag = indexPath.row;
        [cell.commentBtn addTarget:self action:@selector(commentBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        //视频播放
        [cell.videoBtn addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
        cell.videoBtn.tag = 100 + indexPath.row;

        cell.deleteBtn.tag = indexPath.row;
        [cell.deleteBtn addTarget:self action:@selector(deleteNoticeClick:) forControlEvents:UIControlEventTouchUpInside];

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else { //全部动态
        static NSString *cellID = @"myCell";
        FriendsCircleCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [[FriendsCircleCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
        }

        //给头像添加手势
        cell.headImg.tag                = indexPath.row;
        UITapGestureRecognizer *headTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHeadImg:)];
        [cell.headImg addGestureRecognizer:headTap];

        //举报
        [cell.reportBtn addTarget:self action:@selector(reportClick:) forControlEvents:UIControlEventTouchUpInside];

        //送礼
        [cell.reportBtn addTarget:self action:@selector(senderGift:) forControlEvents:UIControlEventTouchUpInside];

        //添加分割线
        if (_messageArray.count) {
            FriendsCircleMessage *message = _messageArray[indexPath.row];
            cell.separatorLine.frame      = CGRectMake(0, [message returnCellHeight] - 1, SCREEN_WIDTH, 1);
            
            cell.giftBtn.hidden = NO;
            NSString* tempId =nil;
            if (self.userId == nil) {
                self.userId = @"";
                tempId = @"wo";
            }
            else {
                tempId = self.userId;
            }
            if ([[NSString stringWithFormat:@"%@",message.userId] isEqualToString:tempId]) {
                cell.giftBtn.hidden = YES;
                
            }

            //保持最新的评论数据 和  点赞数据

            [message setCommentList:_commentList[indexPath.row]];
            [message setPraiseList:_praiseList[indexPath.row]];
            
            [cell initWithModel:message topicStr:topicStr];
            //NSInteger tagInteger  = cell.contentLabel.tag;
            //cell.contentLabel.userInteractionEnabled = YES;
            UITapGestureRecognizer *hotTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hotTapTitle:)];
            objc_setAssociatedObject(hotTap, @"hotTapTitleTag", @([message.hot_id integerValue] + 100), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            [cell.contentLabel addGestureRecognizer:hotTap];


            //记录当前cell的数据源索引
            cell.tag = indexPath.row;

            if ([_praiseList[indexPath.row] count]) {

                for (NSDictionary *dict in _praiseList[indexPath.row]) {
                    if ([[NSString stringWithFormat:@"%@", dict[@"praise_user_id"]] isEqualToString:[NSString stringWithFormat:@"%@", [LYUserService sharedInstance].userID]]) {
                        [cell.praiseBtn setImage:[UIImage imageNamed:@"Hearts red"] forState:UIControlStateNormal];
                        cell.praiseBtn.selected = YES;
                    }
                }
            } else {
                [cell.praiseBtn setImage:[UIImage imageNamed:@"Hearts gray"] forState:UIControlStateNormal];
                cell.praiseBtn.selected = NO;
            }
        }

        [cell.praiseBtn addTarget:self action:@selector(praiseClick:) forControlEvents:UIControlEventTouchUpInside];

        //给cell tag赋值
        cell.commentBtn.tag = indexPath.row;
        [cell.commentBtn addTarget:self action:@selector(commentBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        //视频播放
        [cell.videoBtn addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
        cell.videoBtn.tag = 100 + indexPath.row;

        cell.deleteBtn.tag = indexPath.row;
        [cell.deleteBtn addTarget:self action:@selector(deleteNoticeClick:) forControlEvents:UIControlEventTouchUpInside];

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 0) {
        if (_hotMessageArray.count) {
            FriendsCircleMessage *message = _hotMessageArray[indexPath.row];
            return [message returnCellHeight];
        } else {
            return 0.1;
        }
    } else {
        if (_messageArray.count) {
            FriendsCircleMessage *message = _messageArray[indexPath.row];
            return [message returnCellHeight];
        } else {
            return 0.1;
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *containerView             = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 60)];
    containerView.backgroundColor     = [UIColor clearColor];
    UIView *sectionHeaderView         = [[UIView alloc] initWithFrame:CGRectMake(0, 8, kMainScreenWidth, 44)];
    sectionHeaderView.backgroundColor = [UIColor whiteColor];
    //竖线
    UIView *lineView         = [[UIView alloc] init];
    lineView.width           = 4;
    lineView.height          = 25;
    lineView.centerY         = 22;
    lineView.x               = 10;
    lineView.backgroundColor = THEME_COLOR;
    [sectionHeaderView addSubview:lineView];

    //标题
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.x        = CGRectGetMaxX(lineView.frame) + 10;
    titleLabel.y        = 0;
    titleLabel.height   = sectionHeaderView.height;
    titleLabel.width    = 80;
    if (section == 0) { //热门动态
        titleLabel.text = @"热门动态";
    } else {
        titleLabel.text = @"全部动态";
    }
    titleLabel.textColor = [UIColor blackColor];
    [sectionHeaderView addSubview:titleLabel];
    [containerView addSubview:sectionHeaderView];
    return containerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}


//点击头像
- (void)tapHotHeadImg:(UITapGestureRecognizer *)tap {
    [[LYUserService sharedInstance] fetchLoginStateWithCompeletionBlock:^(UserLoginStateType type) {
        if (type == UserLoginStateTypeWaitToLogin) {
            [[LYUserService sharedInstance] jumpToLoginWithController:self.tabBarController];
            return ;
        }
    }];
    NSInteger userId                                     = [_hotNoticeList[tap.view.tag][@"user_id"] integerValue];
    LYDetailDataViewController *detailDataViewController = [[LYDetailDataViewController alloc] init];
    detailDataViewController.userId                      = [NSString stringWithFormat:@"%ld", (long) userId];
    [self.navigationController pushViewController:detailDataViewController animated:YES];
}

- (void)tapHeadImg:(UITapGestureRecognizer *)tap {
    [[LYUserService sharedInstance] fetchLoginStateWithCompeletionBlock:^(UserLoginStateType type) {
        if (type == UserLoginStateTypeWaitToLogin) {
            [[LYUserService sharedInstance] jumpToLoginWithController:self.tabBarController];
            return ;
        }
    }];
    NSInteger userId                                     = [_noticeList[tap.view.tag][@"user_id"] integerValue];
    LYDetailDataViewController *detailDataViewController = [[LYDetailDataViewController alloc] init];
    detailDataViewController.userId                      = [NSString stringWithFormat:@"%ld", (long) userId];
    [self.navigationController pushViewController:detailDataViewController animated:YES];
}

//点击热门话题
- (void)hotTapTitle:(UITapGestureRecognizer *)tap {
    HotTopicViewController *vc = [[HotTopicViewController alloc] init];
    vc.userId                  = self.userId;
    NSNumber *tag              = (NSNumber *) objc_getAssociatedObject(tap, @"hotTapTitleTag");
    vc.topic_id                = [NSString stringWithFormat:@"%ld", [tag integerValue] - 100];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 点击方法
//改变frame
- (void)lookAllClick:(UIButton *)sender {
    if (sender.selected == YES) {
        [UIView animateWithDuration:0.05 animations:^{ //下移按钮
            //[sender setFrame:CGRectZero];
            [sender setTitle:@"收起" forState:UIControlStateNormal];
        }
            completion:^(BOOL finished) {
                [UIView animateWithDuration:0.1 animations:^{ //展开内容
                    //下移距离
                    margin = contentHeight - shortLabel.height;
                    //内容
                    shortLabel.height = contentHeight;
                    sender.y          = sender.y + margin;

                    //参与按钮下移
                    joinBtn.y = joinBtn.y + margin;

                    //headerView变大
                    headerView.height          = CGRectGetMaxY(joinBtn.frame) + 15;
                    _tableView.tableHeaderView = headerView;
                    sender.selected            = NO;
                }];
            }];
    } else {
        [UIView animateWithDuration:0.05 animations:^{ //隐藏按钮
            //[sender setFrame:CGRectZero];
            [sender setTitle:@"全部查看" forState:UIControlStateNormal];
        }
            completion:^(BOOL finished) {
                [UIView animateWithDuration:0.1 animations:^{ //收起内容
                    //下移距离

                    //内容
                    shortLabel.height = shortLabel.height - margin;

                    sender.y = sender.y - margin;
                    //参与按钮下移
                    joinBtn.y = joinBtn.y - margin;

                    //headerView变大
                    headerView.height          = CGRectGetMaxY(joinBtn.frame) + 15;
                    _tableView.tableHeaderView = headerView;
                    sender.selected            = YES;
                }];
            }];
    }
}

// +号  按钮
- (void)addClick {
    [[LYUserService sharedInstance] fetchLoginStateWithCompeletionBlock:^(UserLoginStateType type) {
        if (type == UserLoginStateTypeWaitToLogin) {
            [[LYUserService sharedInstance] jumpToLoginWithController:self.tabBarController];
        } else {
            if (!_addView) {

                if (!_clearBtn) {
                    //添加一个透明的按钮，点击addView外的部分会隐藏addView
                    _clearBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
                    [_clearBtn addTarget:self action:@selector(hiddenAddView) forControlEvents:UIControlEventTouchUpInside];
                    [self.view addSubview:_clearBtn];
                }

                _addView                    = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 130, 10, 120, 88)];
                _addView.layer.cornerRadius = 5.0;
                _addView.layer.shadowColor  = [UIColor blackColor].CGColor;
                _addView.layer.borderWidth  = 1;
                _addView.layer.borderColor  = TABLEVIEW_BACKGROUNDCOLOR.CGColor;
                _addView.backgroundColor    = [UIColor whiteColor];
                [self.view addSubview:_addView];

                //发布动态
                UIButton *publishBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, _addView.frame.size.width, 44)];
                [publishBtn addTarget:self action:@selector(publishClick) forControlEvents:UIControlEventTouchUpInside];
                [_addView addSubview:publishBtn];

                UIImageView *publishImageView = [[UIImageView alloc] initWithFrame:CGRectMake((44 - 20) / 2, (44 - 20) / 2, 20, 20)];
                publishImageView.image        = [UIImage imageNamed:@"动态"];
                publishImageView.contentMode  = UIViewContentModeScaleAspectFit;
                [publishBtn addSubview:publishImageView];

                UILabel *publishLabel      = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(publishImageView.frame), 0, _addView.frame.size.width - CGRectGetMaxX(publishImageView.frame), 44)];
                publishLabel.textAlignment = NSTextAlignmentCenter;
                publishLabel.font          = [UIFont systemFontOfSize:17];
                publishLabel.text          = @"发布动态";
                [publishBtn addSubview:publishLabel];

                //发布视频
                UIButton *publishVideoBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 44, _addView.frame.size.width, 44)];
                [publishVideoBtn addTarget:self action:@selector(publishVideoClick:) forControlEvents:UIControlEventTouchUpInside];
                [_addView addSubview:publishVideoBtn];

                UIImageView *publishVideoView = [[UIImageView alloc] initWithFrame:CGRectMake((44 - 20) / 2, (44 - 20) / 2, 20, 20)];
                publishVideoView.image        = [UIImage imageNamed:@"个人动态"];
                publishVideoView.contentMode  = UIViewContentModeScaleAspectFit;
                [publishVideoBtn addSubview:publishVideoView];

                UILabel *publishVideoLabel      = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(publishVideoView.frame), 0, _addView.frame.size.width - CGRectGetMaxX(publishVideoView.frame), 44)];
                publishVideoLabel.textAlignment = NSTextAlignmentCenter;
                publishVideoLabel.font          = [UIFont systemFontOfSize:17];
                publishVideoLabel.text          = @"发布动态";
                [publishVideoBtn addSubview:publishVideoLabel];

                //消息
                UIButton *msgBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 88, _addView.frame.size.width, 44)];
                [msgBtn addTarget:self action:@selector(pushMessageList) forControlEvents:UIControlEventTouchUpInside];
                [_addView addSubview:msgBtn];

                UIImageView *msgImageView = [[UIImageView alloc] initWithFrame:CGRectMake((44 - 20) / 2, (44 - 20) / 2, 20, 20)];
                msgImageView.image        = [UIImage imageNamed:@"对话2"];
                msgImageView.contentMode  = UIViewContentModeScaleAspectFit;
                [msgBtn addSubview:msgImageView];

                //                UILabel *msgLabel      = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(msgImageView.frame) - 5, 0, _addView.frame.size.width - CGRectGetMaxX(msgImageView.frame), 44)];
                //                msgLabel.textAlignment = NSTextAlignmentCenter;
                //                msgLabel.font          = [UIFont systemFontOfSize:17];
                //                msgLabel.text          = @"消息";
                //                [msgBtn addSubview:msgLabel];
                //
                //                _newMsg = [[UIButton alloc] initWithFrame:CGRectMake(95, (44 - 18) / 2, 18, 18)];
                //                [_newMsg setBackgroundImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
                //                _newMsg.hidden          = YES;
                //                _newMsg.titleLabel.font = [UIFont systemFontOfSize:14];
                //                [msgBtn addSubview:_newMsg];

            } else {

                _addView.hidden  = !_addView.hidden;
                _clearBtn.hidden = !_clearBtn.hidden;
            }
        }
    }];
}

//朋友圈发消息
- (void)publishClick {
    [[LYUserService sharedInstance] fetchLoginStateWithCompeletionBlock:^(UserLoginStateType type) {
        if (type == UserLoginStateTypeWaitToLogin) {
            [[LYUserService sharedInstance] jumpToLoginWithController:self.tabBarController];
            return ;
        }
    }];

    if ([LYUserService sharedInstance].canPublishFriend) {
        [self hiddenAddView];

        PublishMessageViewController *publishMessageViewController = [[PublishMessageViewController alloc] init];
        publishMessageViewController.hotId                         = self.hotId;
        [self.navigationController pushViewController:publishMessageViewController animated:YES];
    } else {
        if ([[LYUserService sharedInstance].userDetail.isVip isEqualToString:@"0"]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"您需要开通会员才能发消息" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:@"去开通", nil];
            alert.delegate     = self;
            [alert show];

        } else {
            [self hiddenAddView];

            PublishMessageViewController *publishMessageViewController = [[PublishMessageViewController alloc] init];
            [self.navigationController pushViewController:publishMessageViewController animated:YES];
        }
    }
}

//进入消息列表
- (void)pushMessageList {

    [self hiddenAddView];
    //_newMsgNumber = 0;

    FriendsMessageViewController *friendsMessageViewController = [[FriendsMessageViewController alloc] init];
    [self.navigationController pushViewController:friendsMessageViewController animated:YES];
}


- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

//举报
- (void)reportHotClick:(UIButton *)sender {
    [[LYUserService sharedInstance] fetchLoginStateWithCompeletionBlock:^(UserLoginStateType type) {
        if (type == UserLoginStateTypeWaitToLogin) {
            [[LYUserService sharedInstance] jumpToLoginWithController:self.tabBarController];
            return ;
        }
    }];
    
    ReportViewController *vc = [[ReportViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)reportClick:(UIButton *)sender {
    [[LYUserService sharedInstance] fetchLoginStateWithCompeletionBlock:^(UserLoginStateType type) {
        if (type == UserLoginStateTypeWaitToLogin) {
            [[LYUserService sharedInstance] jumpToLoginWithController:self.tabBarController];
            return ;
        }
    }];

    ReportViewController *vc = [[ReportViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

//送礼
- (void)senderHotGift:(UIButton *)sender {
    [[LYUserService sharedInstance] fetchLoginStateWithCompeletionBlock:^(UserLoginStateType type) {
        if (type == UserLoginStateTypeWaitToLogin) {
            [[LYUserService sharedInstance] jumpToLoginWithController:self.tabBarController];
            return ;
        }
    }];
    
    FriendsCircleMessage *message = _hotMessageArray[sender.tag - 10];
    LYSendGiftViewController *vc  = [[LYSendGiftViewController alloc] init];
    vc.avatarImageURL             = message.headImgStr;
    vc.friendID                   = message.userId;
    vc.userName                   = message.name;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)senderGift:(UIButton *)sender {
    [[LYUserService sharedInstance] fetchLoginStateWithCompeletionBlock:^(UserLoginStateType type) {
        if (type == UserLoginStateTypeWaitToLogin) {
            [[LYUserService sharedInstance] jumpToLoginWithController:self.tabBarController];
            return ;
        }
    }];

    FriendsCircleMessage *message = _messageArray[sender.tag - 10];
    LYSendGiftViewController *vc  = [[LYSendGiftViewController alloc] init];
    vc.avatarImageURL             = message.headImgStr;
    vc.friendID                   = message.userId;
    vc.userName                   = message.name;
    [self.navigationController pushViewController:vc animated:YES];
}


//UIActionSheet 确认删除
- (void)showActionSheet:(NSNotification *)notification {

    //保存需要的字段
    _deleteCommentDict = @{ @"commentId": notification.userInfo[@"commentId"],
                            @"noticeIndex": notification.userInfo[@"noticeIndex"],
                            @"commentIndex": notification.userInfo[@"commentIndex"] };

    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                 initWithTitle:nil
                      delegate:self
             cancelButtonTitle:@"取消"
        destructiveButtonTitle:@"删除"
             otherButtonTitles:nil];
    [actionSheet showInView:self.view];
    //防止  actionSheet闪退      解决Sheet can not be presented because the view is not in a window这样的问题
    //    UIWindow* window = [[[UIApplication sharedApplication] delegate] window];
    //    if ([window.subviews containsObject:self.view]) {
    //        [actionSheet showInView:self.view];
    //    } else {
    //        NSLog(@"%@",self.view);
    //        [actionSheet showInView:self.view];
    //    }
}

//删除自己的评论
- (void)deleteMyComment {

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [MBProgressHUD showMessage:@"正在加载"];
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/notice/cancelComment", REQUESTHEADER];
    [manager POST:urlStr parameters:@{ @"commentId": _deleteCommentDict[@"commentId"] } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"删除评论:%@", responseObject);

        if ([[NSString stringWithFormat:@"%@", responseObject[@"code"]] isEqualToString:@"200"]) {

            [MBProgressHUD hideHUD];

            //移除数据源
            NSInteger noticeIndex  = [_deleteCommentDict[@"noticeIndex"] integerValue];
            NSInteger commentIndex = [_deleteCommentDict[@"commentIndex"] integerValue];
            [_commentList[noticeIndex] removeObjectAtIndex:commentIndex];
            [_hotCommentList[noticeIndex] removeObjectAtIndex:commentIndex];
            //重载
            [_tableView reloadData];
        } else {

            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [MBProgressHUD showError:responseObject[@"msg"]];
        }
    }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"删除评论%@", error);
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [MBProgressHUD showError:@"请检查您的网络"];
        }];
}

//点击播放按钮
- (void)playVideo:(UIButton *)sender {
    //#warning 权限开关
    //    if ([[LYUserService sharedInstance].userDetail.isVip isEqualToString:@"1"]) {
    //        NSInteger index = sender.tag - 100;
    //        VideoDetail *model = self.videoArray[index];
    //        _currentVideoURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",model.url]];
    //        _player = nil;
    //        [self presentMoviePlayerViewControllerAnimated:self.player];
    //    }
    //    else {
    //        [[[UIAlertView alloc] initWithTitle:nil message:@"您还不是会员，将无法享受播放功能" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"成为会员", nil] show];
    //    }
    /**
     *  @author KF, 16-07-20 13:07:18
     *
     *  @brief 权限开关
     */
    if ([[LYUserService sharedInstance] canPlayVideo]) { //如果没有权限约束
        NSInteger index               = sender.tag - 100;
        FriendsCircleMessage *message = _messageArray[index];
        message.videoUrl              = [message.videoUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        _currentVideoURL              = [NSURL URLWithString:[NSString stringWithFormat:@"%@", message.videoUrl]];
        _player                       = nil;

        [self presentMoviePlayerViewControllerAnimated:self.player];
    } else { //如果有权限约束
        if ([[LYUserService sharedInstance].userDetail.isVip isEqualToString:@"1"]) {
            NSInteger index               = sender.tag - 100;
            FriendsCircleMessage *message = _messageArray[index];
            _currentVideoURL              = [NSURL URLWithString:[NSString stringWithFormat:@"%@", message.videoUrl]];
            _player                       = nil;
            [self presentMoviePlayerViewControllerAnimated:self.player];
        } else {
            [[[UIAlertView alloc] initWithTitle:nil message:@"您还不是会员，将无法享受播放功能" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"成为会员", nil] show];
        }
    }
}


//点击回复
- (void)commentClick:(NSNotification *)notification {
    [[LYUserService sharedInstance] fetchLoginStateWithCompeletionBlock:^(UserLoginStateType type) {
        if (type == UserLoginStateTypeWaitToLogin) {
            [[LYUserService sharedInstance] jumpToLoginWithController:self.tabBarController];
            return ;
        }
    }];

    _inputView = nil;
    if (!_inputView) {

        if (!_clearBtn) {
            //添加一个透明的按钮，点击addView外的部分会隐藏addView
            _clearBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
            [_clearBtn addTarget:self action:@selector(hiddenAddView) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:_clearBtn];
        }

        _inputView                   = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 64, SCREEN_WIDTH, 40 + kSingleContentHeight)];
        _inputView.layer.borderColor = TABLEVIEW_BACKGROUNDCOLOR.CGColor;
        _inputView.layer.borderWidth = 1;
        _inputView.backgroundColor   = [UIColor whiteColor];
        _inputView.alpha             = 0.95;
        [self.view addSubview:_inputView];

        //输入框
        _textView                    = [[UITextView alloc] initWithFrame:CGRectMake(Kinterval, Kinterval / 2, SCREEN_WIDTH - Kinterval - 60, 20 + kSingleContentHeight)];
        _textView.backgroundColor    = [UIColor clearColor];
        _textView.layer.cornerRadius = 5.0;
        _textView.font               = [UIFont systemFontOfSize:15];
        _textView.layer.borderColor  = TABLEVIEW_BACKGROUNDCOLOR.CGColor;
        _textView.layer.borderWidth  = 1;
        _textView.delegate           = self;
        _textView.scrollEnabled      = NO;
        [_inputView addSubview:_textView];

        //PlaceHolder Label
        _placeHolderLabel                 = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, _textView.frame.size.width - 20, 20 + kSingleContentHeight)];
        _placeHolderLabel.enabled         = NO;
        _placeHolderLabel.backgroundColor = [UIColor clearColor];
        _placeHolderLabel.font            = [UIFont systemFontOfSize:15.0];
        _placeHolderLabel.textColor       = [UIColor lightGrayColor];
        _placeHolderLabel.textAlignment   = NSTextAlignmentLeft;
        [_textView addSubview:_placeHolderLabel];

        //发送
        _sendBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_textView.frame) + 10, 10, 40, 20 + kSingleContentHeight)];
        [_sendBtn setBackgroundColor:[UIColor clearColor]];
        [_sendBtn setTitle:@"发送" forState:UIControlStateNormal];
        _sendBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [_sendBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_sendBtn addTarget:self action:@selector(sendClick:) forControlEvents:UIControlEventTouchUpInside];
        [_inputView addSubview:_sendBtn];
    }

    //区别是回复而非评论
    _textView.tag = 100000;

    _reply     = notification.userInfo[@"reply"];
    _noticeId  = notification.userInfo[@"noticeId"];
    _replyName = notification.userInfo[@"replyName"];
    
#warning [[notification.userInfo[@"index"] integerValue]][@"user_id"];
    _commenter = _noticeList[[notification.userInfo[@"index"] integerValue]][@"user_id"];
    //_hotCommentList = _hotNoticeList[[notification.userInfo[@"index"] integerValue]][@"user_id"];
    
    //btn.tag*10，末尾为1表示对他人评论
    _sendBtn.tag = [notification.userInfo[@"index"] integerValue] * 10 + 1;

    //获得第一响应者
    [_textView becomeFirstResponder];
    _placeHolderLabel.text = [NSString stringWithFormat:@"回复%@:", _replyName];
    _clearBtn.hidden       = NO;
}

//点击蒙层 隐藏输入框等
- (void)hiddenAddView {

    //清空
    _textView.text = @"";
    [_textView resignFirstResponder];

    _addView.hidden  = YES;
    _clearBtn.hidden = YES;
}

//点击评论(添加评论栏)
- (void)commentBtnClick:(UIButton *)btn {
    //    if ([[LYUserService sharedInstance].userDetail.isVip isEqualToString:@"0"]) {
    //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"您需要开通会员才能评论" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:@"去开通", nil];
    //        alert.delegate = self;
    //        [alert show];
    //
    //    }
    //    else{

    [[LYUserService sharedInstance] fetchLoginStateWithCompeletionBlock:^(UserLoginStateType type) {
        if (type == UserLoginStateTypeWaitToLogin) {
            [[LYUserService sharedInstance] jumpToLoginWithController:self.tabBarController];
            return ;
        }
    }];

    //取出cell
    FriendsCircleCell *cell;
    if (kSystemVersion >= 8.0) {
        cell = (FriendsCircleCell *) [btn superview];
    } else {
        cell = (FriendsCircleCell *) [[btn superview] superview];
    }
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (indexPath.section == 0) {//热门动态
        self.isHotDataList = YES;
    }
    else {
        self.isHotDataList = NO;
    }


    
    _inputView = nil;
    if (!_inputView) {

        if (!_clearBtn) {
            //添加一个透明的按钮，点击addView外的部分会隐藏addView
            _clearBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
            [_clearBtn addTarget:self action:@selector(hiddenAddView) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:_clearBtn];
        }

        _inputView                   = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 64, SCREEN_WIDTH, 40 + kSingleContentHeight)];
        _inputView.layer.borderColor = TABLEVIEW_BACKGROUNDCOLOR.CGColor;
        _inputView.layer.borderWidth = 1;
        _inputView.backgroundColor   = [UIColor whiteColor];
        _inputView.alpha             = 0.95;

        //输入框
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(Kinterval, Kinterval / 2, SCREEN_WIDTH - Kinterval - 60, 20 + kSingleContentHeight)];
        [_textView setBackgroundColor:[UIColor clearColor]];
        _textView.layer.cornerRadius = 5.0;
        _textView.font               = [UIFont systemFontOfSize:15];
        _textView.layer.borderColor  = TABLEVIEW_BACKGROUNDCOLOR.CGColor;
        _textView.layer.borderWidth  = 1;
        _textView.delegate           = self;
        _textView.scrollEnabled      = NO;
        [_inputView addSubview:_textView];

        //PlaceHolder Label
        _placeHolderLabel                 = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, _textView.frame.size.width - 20, 20 + kSingleContentHeight)];
        _placeHolderLabel.enabled         = NO;
        _placeHolderLabel.backgroundColor = [UIColor clearColor];
        _placeHolderLabel.font            = [UIFont systemFontOfSize:15.0];
        _placeHolderLabel.textColor       = [UIColor lightGrayColor];
        _placeHolderLabel.textAlignment   = NSTextAlignmentLeft;
        [_textView addSubview:_placeHolderLabel];

        //发送
        _sendBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_textView.frame) + 10, 10, 40, 20 + kSingleContentHeight)];
        [_sendBtn setBackgroundColor:[UIColor clearColor]];
        [_sendBtn setTitle:@"发送" forState:UIControlStateNormal];
        _sendBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_sendBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        //        sendBtn.tag = btn.tag;
        [_sendBtn addTarget:self action:@selector(sendClick:) forControlEvents:UIControlEventTouchUpInside];
        [_inputView addSubview:_sendBtn];
        [self.view addSubview:_inputView];
    }

    //区别是评论而非回复
    _textView.tag = 10000;

    //btn.tag*10，末尾为0表示评论
    _sendBtn.tag = btn.tag * 10;
    //获得第一响应者
    [_textView becomeFirstResponder];
    _placeHolderLabel.text = @"写点儿评论吧";
    _clearBtn.hidden       = NO;
    //    }
}

//发送评论
- (void)sendClick:(UIButton *)sender {

    NSString *detailStr = _textView.text;

    if (detailStr.length) {

        if (sender.tag % 10 == 0) {
            //评论
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            [MBProgressHUD showMessage:@"正在加载"];
            NSDictionary* tempDict;
            if (self.isHotDataList == YES) { //所处section，0是
                tempDict = _hotDataDict;
            }
            else {
                tempDict = _dataDict;
            }
  
            NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/notice/comment", REQUESTHEADER];
            [manager POST:urlStr parameters:@{ @"noticeId": tempDict[@"noticeList"][sender.tag / 10][@"id"],
                                               @"commentType": @"0",
                                               @"commenter": [NSString stringWithFormat:@"%@", [LYUserService sharedInstance].userID],
                                               @"commentDetail": detailStr }
                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSLog(@"发送评论:%@", responseObject);
                    [MBProgressHUD hideHUD];

                    if ([[NSString stringWithFormat:@"%@", responseObject[@"code"]] isEqualToString:@"200"]) {

                        MLOG(@"发送评论成功");
                        //1.隐藏输入框 评论显示+1
                        [self hiddenAddView];
                        //2.手动加入数据源
                        NSString *comment_id = responseObject[@"data"][@"id"];//获取传回的Id
                        NSDictionary *dict   = @{ @"comment_id": comment_id,
                                                @"comment_user": [NSString stringWithFormat:@"%@", [LYUserService sharedInstance].userDetail.userName],
                                                @"comment_user_id": [NSString stringWithFormat:@"%@", [LYUserService sharedInstance].userID],
                                                @"detail": detailStr,
                                                @"notice_id": tempDict[@"noticeList"][sender.tag / 10][@"id"],
                                                @"reply_user": @"",
                                                @"reply_user_id": @"",
                                                @"type": @"0" };
                        NSString* isHot = [NSString stringWithFormat:@"%@", tempDict[@"noticeList"][sender.tag / 10][@"isHot"]];
                        if ([isHot isEqualToString:@"1"]) { //isHot 1.是;2.不是
                            if (self.isHotDataList == YES) { //是
                                //tempDict = _hotDataDict;
                                [_hotCommentList[sender.tag / 10] addObject:dict];
                            }
                            else {
                                //tempDict = _dataDict;
                                [_commentList[sender.tag / 10] addObject:dict];
                            }
                            
                        }
                        else if ([isHot isEqualToString:@"2"]) {
                            [_commentList[sender.tag / 10] addObject:dict];
                        }
                        //3.重载评论
                        //                    //3.1 获取该行消息的cell
                        //                    FriendsCircleCell *cell = (FriendsCircleCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:(sender.tag/10) inSection:0]];
                        //                    //3.2 给cell的评论赋 新的数据源
                        //                    //更新最新的模型数组
                        //                    cell.commentArray = _commentList[sender.tag/10];
                        //                    //3.3 重载cell.commentTableView
                        //                    [cell.commentTableView reloadData];
                        //
                        //                    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:(sender.tag/10) inSection:0];
                        //                    [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                        [_tableView reloadData];
                    } else {

                        [MBProgressHUD showError:responseObject[@"msg"]];
                    }
                }
                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"%@", error);
                    [MBProgressHUD hideHUD];
                    [MBProgressHUD showError:@"请检查您的网络"];
                }];
        } else {
            //回复他人
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            [MBProgressHUD showMessage:@"正在加载"];
            //通过_noticeId获取到id,再获取到isHot，判断
           // NSMutableArray* dictM = [NSMutableArray array];
            NSDictionary* tempDict;
            for (FriendsCircleMessage* message in _messageArray) {
                if ([message.ID isEqualToString:_noticeId]) { //获取到评论的message
                    if ([message.isHot isEqualToString:@"1"]) { //是热门
                        tempDict = _hotDataDict;
                    }
                    else {
                        tempDict = _dataDict;
                    }
                }
            }
            
            
            NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/notice/comment", REQUESTHEADER];
            [manager POST:urlStr parameters:@{ @"noticeId": _noticeId,
                                               @"commentType": @"1",
                                               @"commenter": [NSString stringWithFormat:@"%@", [LYUserService sharedInstance].userID],
                                               @"commentDetail": detailStr,
                                               @"reply": _reply }
                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSLog(@"发送评论:%@", responseObject);
                    [MBProgressHUD hideHUD];

                    if ([[NSString stringWithFormat:@"%@", responseObject[@"code"]] isEqualToString:@"200"]) {

                        NSLog(@"回复他人成功");
                        //1.隐藏输入框,评论显示+1
                        [self hiddenAddView];
                        //2.手动加入数据源
                        NSString *comment_id = responseObject[@"data"][@"id"];
                        NSDictionary *dict   = @{ @"comment_id": comment_id,
                                                @"comment_user": [NSString stringWithFormat:@"%@", [LYUserService sharedInstance].userDetail.userName],
                                                @"comment_user_id": [NSString stringWithFormat:@"%@", [LYUserService sharedInstance].userID],
                                                @"detail": detailStr,
                                                @"notice_id": tempDict[@"noticeList"][sender.tag / 10][@"id"],
                                                @"reply_user": _replyName,
                                                @"reply_user_id": _reply,
                                                @"type": @"1" };
                        
                        NSString* isHot = [NSString stringWithFormat:@"%@", tempDict[@"noticeList"][sender.tag / 10][@"isHot"]];
                        if ([isHot isEqualToString:@"1"]) { //isHot 1.是;2.不是
                            if (self.isHotDataList == YES) { //是
                                //tempDict = _hotDataDict;
                                [_hotCommentList[sender.tag / 10] addObject:dict];
                            }
                            else {
                                //tempDict = _dataDict;
                                [_commentList[sender.tag / 10] addObject:dict];
                            }
                            //              [_hotCommentList[sender.tag / 10] addObject:dict];
                        }
                        else if ([isHot isEqualToString:@"2"]) {
                            [_commentList[sender.tag / 10] addObject:dict];
                        }
                        /**
                         *  @author KF, 16-08-04 22:08:50
                         *
                         *  @brief 热门话题
                         */
                        //[_commentList[sender.tag / 10] addObject:dict];

                        //3.重载评论
                        //3.1 获取该行消息的cell
                        //                    FriendsCircleCell *cell = (FriendsCircleCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:(sender.tag/10) inSection:0]];
                        //3.2 给cell的评论赋 新的数据源
                        //更新最新的模型数组
                        //                    cell.commentArray = _commentList[sender.tag/10];
                        //3.3 重载cell.commentTableView
                        //                    [cell.commentTableView reloadData];
                        //
                        //
                        [_tableView reloadData];
                        //                    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:(sender.tag/10) inSection:0];
                        //                    [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];

                    } else {

                        [MBProgressHUD showError:responseObject[@"msg"]];
                    }
                }
                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"%@", error);
                    [MBProgressHUD hideHUD];
                    [MBProgressHUD showError:@"请检查您的网络"];
                }];
        }
    }
}

//点赞&取消赞
- (void)praiseClick:(UIButton *)sender {
    [[LYUserService sharedInstance] fetchLoginStateWithCompeletionBlock:^(UserLoginStateType type) {
        if (type == UserLoginStateTypeWaitToLogin) {
            [[LYUserService sharedInstance] jumpToLoginWithController:self.tabBarController];
            return ;
        }
    }];


    //取出cell
    FriendsCircleCell *cell;
    if (kSystemVersion >= 8.0) {
        cell = (FriendsCircleCell *) [sender superview];
    } else {
        cell = (FriendsCircleCell *) [[sender superview] superview];
    }
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSMutableArray* tempNoticeListM = [NSMutableArray array];
    NSMutableArray* tempPraiseListM = [NSMutableArray array];
    if (indexPath.section == 0) {//热门动态
        tempNoticeListM = _hotNoticeList;
        tempPraiseListM = _hotPraiseList;
    }
    else {
        tempNoticeListM = _noticeList;
        tempPraiseListM = _praiseList;
    }
    NSInteger row          = indexPath.row;

    if (sender.selected == NO) {
        //按钮变红，数量+1,tag+1
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSString *urlStr                       = [NSString stringWithFormat:@"%@/mobile/notice/praise", REQUESTHEADER];
        [manager POST:urlStr parameters:@{ @"noticeId": tempNoticeListM[row][@"id"],
                                           @"praiser": [NSString stringWithFormat:@"%@", [LYUserService sharedInstance].userID] }
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"点赞:%@", responseObject);
                [MBProgressHUD hideHUD];

                if ([[NSString stringWithFormat:@"%@", responseObject[@"code"]] isEqualToString:@"200"]) {

                    sender.selected     = YES;
                    NSInteger number    = [cell.praiseNum.text integerValue];
                    cell.praiseNum.text = [NSString stringWithFormat:@"%d", (int) number + 1];
                    [sender setImage:[UIImage imageNamed:@"Hearts red"] forState:UIControlStateNormal];

                    //编辑新的点赞 数据字典。并手动添入数据源
                    NSString *praise_id = responseObject[@"data"][@"id"];
                    NSDictionary *dict  = @{ @"notice_id": tempNoticeListM[row][@"id"],
                                            @"praise_id": praise_id,
                                            @"praise_user": [NSString stringWithFormat:@"%@", [LYUserService sharedInstance].userDetail.userName],
                                            @"praise_user_id": [NSString stringWithFormat:@"%@", [LYUserService sharedInstance].userID] };
                    
                    if (indexPath.section == 0) {
                        [_hotPraiseList[row] addObject:dict];
//                        NSIndexSet* indexSet = [[NSIndexSet alloc] initWithIndex:0];
//                        _tableView reloadSections:<#(nonnull NSIndexSet *)#> withRowAnimation:<#(UITableViewRowAnimation)#>
                        [_tableView reloadData];
                    }
                    else {
                        [_praiseList[row] addObject:dict];
                        [_tableView reloadData];
                    }
                    
                } else {

                    [MBProgressHUD showError:responseObject[@"msg"]];
                }
            }
            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"%@", error);
                [MBProgressHUD hideHUD];
                [MBProgressHUD showError:@"请检查您的网络"];
            }];
    } else {

        
        //获得点赞的praise_id   先遍历比较，若praise_user_id等于自己的user_id。获取praise_id
        NSString *praise_id = @"";
        NSDictionary *deltDict;
        for (NSDictionary *dict in tempPraiseListM[row]) {
            if ([[NSString stringWithFormat:@"%@", dict[@"praise_user_id"]] isEqualToString:[NSString stringWithFormat:@"%@", [LYUserService sharedInstance].userID]]) {
                praise_id = dict[@"praise_id"];
                deltDict  = dict;
                break;
            }
        }
        //按钮变黑，数量-1,tag - 1
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSString *urlStr                       = [NSString stringWithFormat:@"%@/mobile/notice/cancelPraise", REQUESTHEADER];
        [manager POST:urlStr parameters:@{ @"praiseId": praise_id } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"取消点赞:%@", responseObject);
            [MBProgressHUD hideHUD];

            if ([[NSString stringWithFormat:@"%@", responseObject[@"code"]] isEqualToString:@"200"]) {

                sender.selected     = NO;
                NSInteger number    = [cell.praiseNum.text integerValue];
                cell.praiseNum.text = [NSString stringWithFormat:@"%d", (int) number - 1];
                [sender setImage:[UIImage imageNamed:@"Hearts gray"] forState:UIControlStateNormal];

                //手动从数据源中移除
//                [_praiseList[row] removeObject:deltDict];
//                [_hotPraiseList[row] removeObject:deltDict];
                
                [tempPraiseListM[row] removeObject:deltDict];
                [_tableView reloadData];
                
            } else {

                [MBProgressHUD showError:responseObject[@"msg"]];
            }
        }
            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"%@", error);
                [MBProgressHUD hideHUD];
                [MBProgressHUD showError:@"请检查您的网络"];
            }];
    }
}

//删除朋友圈 自己发的消息
- (void)deleteNoticeClick:(UIButton *)sender {
    [[LYUserService sharedInstance] fetchLoginStateWithCompeletionBlock:^(UserLoginStateType type) {
        if (type == UserLoginStateTypeWaitToLogin) {
            [[LYUserService sharedInstance] jumpToLoginWithController:self.tabBarController];
            return ;
        }
    }];

    NSString *noticeId = _noticeList[sender.tag][@"id"];

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [MBProgressHUD showMessage:@"正在加载" toView:self.view];
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/notice/deleteNotice", REQUESTHEADER];
    [manager POST:urlStr parameters:@{ @"user_id": [NSString stringWithFormat:@"%@", [LYUserService sharedInstance].userID],
                                       @"notice_id": noticeId }
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"删除朋友圈:%@", responseObject);
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

            if ([[NSString stringWithFormat:@"%@", responseObject[@"code"]] isEqualToString:@"200"]) {

                //移除该消息
                NSDictionary *notice = _noticeList[sender.tag];
                [_noticeList removeObject:notice];

                //先清空模型数组
                [_messageArray removeAllObjects];
                [_hotMessageArray removeAllObjects];
                //保存模型数组
                for (NSDictionary *dict in _noticeList) {

                    //消息模型数组
                    FriendsCircleMessage *message = [[FriendsCircleMessage alloc] initWithDict:dict];
                    [_messageArray addObject:message];
                    if ([message.isHot isEqualToString:@"1"]) { //是热门动态
                        [_hotMessageArray addObject:message];
                    }
                }
                
                [_commentList removeObjectAtIndex:sender.tag];
                [_praiseList removeObjectAtIndex:sender.tag];
                [_hotCommentList removeObjectAtIndex:sender.tag];
                [_hotPraiseList removeObjectAtIndex:sender.tag];
                
                [_tableView reloadData];
            } else {

                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [MBProgressHUD showError:responseObject[@"msg"]];
            }
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"删除朋友圈%@", error);
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [MBProgressHUD showError:@"请检查您的网络"];
        }];
}


#pragma mark - 网络请求
- (void)postRequest {
    //清空数据源
    [_messageArray removeAllObjects];
    //[_hotMessageArray removeAllObjects];
    [_commentList removeAllObjects];
    [_praiseList removeAllObjects];
    [_noticeList removeAllObjects];

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *urlStr                       = [NSString stringWithFormat:@"%@/mobile/notice/iosNoticeList", REQUESTHEADER];

    NSDictionary *parameters;
    //NSString* allUserId = @"";
    //type 0->自己的朋友圈 1->自己的动态加上userID
    //    if (!self.userId) {
    //        self.userId = @"";
    //    }
    //热门话题
    if (!self.userId) { //游客
        if (!self.userId) {
            self.userId = @"";
        }
        parameters = @{ @"userId": [NSString stringWithFormat:@"%@", self.userId],
                        @"noticeType": @"0",
                        @"pageNum": [NSString stringWithFormat:@"%d", (int) _currentPage],
                        @"hotId": self.topic_id,
                        @"type": @"4" };
    } else { //用户
        parameters = @{ @"userId": [NSString stringWithFormat:@"%@", self.userId],
                        @"noticeType": @"0",
                        @"pageNum": [NSString stringWithFormat:@"%d", (int) _currentPage],
                        @"hotId": self.topic_id,
                        @"type": @"5" };
    }


    [MBProgressHUD showMessage:nil toView:self.view];
    [manager POST:urlStr parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        MLOG(@"获取朋友圈列表：%@", responseObject);
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if ([[NSString stringWithFormat:@"%@", responseObject[@"code"]] isEqualToString:@"200"]) {
            _dataDict = [NSMutableDictionary dictionaryWithDictionary:responseObject[@"data"]];

            //保存模型数组
            for (NSDictionary *dict in _dataDict[@"noticeList"]) {

                //消息-数据源数组
                [_noticeList addObject:dict];

                //消息模型数组
                FriendsCircleMessage *message = [[FriendsCircleMessage alloc] initWithDict:dict];
                [_messageArray addObject:message];

                //                if ([message.isHot isEqualToString:@"1"]) { //是热门动态
                //                    [_hotMessageArray addObject:message];
                //                }
            }
            [_tableView reloadData];
            //评论列表
            for (int i = 0; i < [_dataDict[@"noticeList"] count]; i++) {

                NSMutableArray *array = [_dataDict[@"noticeList"][i][@"commentList"] mutableCopy];
                [_commentList addObject:array];
            }
            //点赞列表
            for (int i = 0; i < [_dataDict[@"noticeList"] count]; i++) {

                NSMutableArray *array = [_dataDict[@"noticeList"][i][@"praiseList"] mutableCopy];
                [_praiseList addObject:array];
            }

            [_tableView.mj_header endRefreshing];
            [_tableView reloadData];

        } else {

            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [MBProgressHUD showError:responseObject[@"msg"]];
        }
    }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"获取朋友圈列表%@", error);
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [MBProgressHUD showError:@"请检查您的网络"];
        }];
}

//获取热门话题的热门动态
- (void)getHotTopic {

    [_hotMessageArray removeAllObjects];

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *urlStr                       = [NSString stringWithFormat:@"%@/mobile/notice/iosNoticeList", REQUESTHEADER];

    NSDictionary *parameters;
    //热门话题
    if (!self.userId) { //游客
        if (!self.userId) {
            self.userId = @"";
        }
        parameters = @{ @"userId": [NSString stringWithFormat:@"%@", self.userId],
                        @"noticeType": @"0",
                        @"pageNum": [NSString stringWithFormat:@"%d", (int) _currentPage],
                        @"hotId": self.topic_id,
                        @"type": @"6" };
    } else { //用户
        parameters = @{ @"userId": [NSString stringWithFormat:@"%@", self.userId],
                        @"noticeType": @"0",
                        @"pageNum": [NSString stringWithFormat:@"%d", (int) _currentPage],
                        @"hotId": self.topic_id,
                        @"type": @"6" };
    }
    [MBProgressHUD showMessage:nil toView:self.view];
    [manager POST:urlStr parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        MLOG(@"获取热门动态列表：%@", responseObject);
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if ([[NSString stringWithFormat:@"%@", responseObject[@"code"]] isEqualToString:@"200"]) {
            _hotDataDict = [NSMutableDictionary dictionaryWithDictionary:responseObject[@"data"]];

            //保存模型数组
            for (NSDictionary *dict in _hotDataDict[@"noticeList"]) {

                //消息-数据源数组
                [_hotNoticeList addObject:dict];

                //消息模型数组
                FriendsCircleMessage *message = [[FriendsCircleMessage alloc] initWithDict:dict];
                //[_messageArray addObject:message];

                if ([message.isHot isEqualToString:@"1"]) { //是热门动态
                    [_hotMessageArray addObject:message];
                }
            }
            [_tableView reloadData];
            //评论列表
            for (int i = 0; i < [_hotDataDict[@"noticeList"] count]; i++) {

                NSMutableArray *array = [_hotDataDict[@"noticeList"][i][@"commentList"] mutableCopy];
                [_hotCommentList addObject:array];
            }
            //点赞列表
            for (int i = 0; i < [_hotDataDict[@"noticeList"] count]; i++) {

                NSMutableArray *array = [_hotDataDict[@"noticeList"][i][@"praiseList"] mutableCopy];
                [_hotPraiseList addObject:array];
            }

            [_tableView.mj_header endRefreshing];
            [_tableView reloadData];

        } else {

            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [MBProgressHUD showError:responseObject[@"msg"]];
        }
    }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"获取朋友圈列表%@", error);
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [MBProgressHUD showError:@"请检查您的网络"];
        }];
}

//获取详情
- (void)getTopicDetail {
    //NSNumber* topicInt = [NSNumber numberWithInteger:self.topic_id]

    NSString *urlStr     = [NSString stringWithFormat:@"%@/mobile/notice/getHotTopicDetail", REQUESTHEADER];
    NSDictionary *params = @{
        @"topic_id": self.topic_id
    };

    [MBProgressHUD showMessage:nil toView:self.view];
    [LYHttpPoster postHttpRequestByPost:urlStr andParameter:params success:^(id successResponse) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        MLOG(@"话题详情%@", successResponse);
        if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
            NSMutableArray *detailM = successResponse[@"data"][@"topic"];

            //            for (NSDictionary* dict in detailM) {
            //                TopicTitle* model = [TopicTitle topicTitleWithDict:dict];
            //                [_topicArray addObject:model];
            //            }
            TopicTitle *model = [[TopicTitle alloc] init];
            model.ID          = [NSString stringWithFormat:@"%@", successResponse[@"data"][@"topic"][@"id"]];
            model.title       = [NSString stringWithFormat:@"%@", successResponse[@"data"][@"topic"][@"title"]];
            model.partNums    = [NSString stringWithFormat:@"%@", successResponse[@"data"][@"topic"][@"partNums"]];
            model.back_img    = [NSString stringWithFormat:@"%@", successResponse[@"data"][@"topic"][@"back_img"]];
            model.intro       = [NSString stringWithFormat:@"%@", successResponse[@"data"][@"topic"][@"intro"]];
            [_topicArray addObject:model];

            [self createHeaderView];
            _tableView.tableHeaderView = headerView;
            [_tableView.mj_header endRefreshing];
            [_tableView reloadData];
        } else {

            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [MBProgressHUD showError:successResponse[@"msg"]];
        }
    }
        andFailure:^(id failureResponse) {
            NSLog(@"热门话题%@", failureResponse);
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [MBProgressHUD showError:@"请检查您的网络"];
        }];
}


//注册通知
- (void)addObserver {

    //点击评论
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commentClick:) name:@"commentClick" object:nil];
    //键盘高度变化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    //删除评论
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showActionSheet:) name:@"deleteMyComment" object:nil];
    //更新朋友圈
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadFriendCircle:) name:@"ReloadFriendCircleVC" object:nil];
}

//添加刷新
- (void)addRefresh {
    // 1.下拉刷新(进入刷新状态就会调用self的headerRereshing)
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRereshing)];

    //    [_tableView headerBeginRefreshing];

    // 2.上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    _tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRefreshing)];
}

//下拉
- (void)headerRereshing {
    _currentPage = 1;

    //获取网络
    //加载数据
    [self postRequest];
    [self getHotTopic];
}

//上拉
//上拉加载方法
- (void)footerRefreshing {

    _currentPage++;

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [MBProgressHUD showMessage:@"正在加载" toView:self.view];
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/notice/iosNoticeList", REQUESTHEADER];
    NSDictionary *parameters;
    //type 0->自己的动态 1->自己的动态加上userID
    //热门话题
    if (!self.userId) { //游客
        if (!self.userId) {
            self.userId = @"";
        }
        parameters = @{ @"userId": [NSString stringWithFormat:@"%@", self.userId],
                        @"noticeType": @"0",
                        @"pageNum": [NSString stringWithFormat:@"%d", (int) _currentPage],
                        @"hotId": self.topic_id,
                        @"type": @"4" };
    } else { //用户
        parameters = @{ @"userId": [NSString stringWithFormat:@"%@", self.userId],
                        @"noticeType": @"0",
                        @"pageNum": [NSString stringWithFormat:@"%d", (int) _currentPage],
                        @"hotId": self.topic_id,
                        @"type": @"5" };
    }

    [manager POST:urlStr parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"上拉获取朋友圈列表:%@", responseObject);
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

        if ([[NSString stringWithFormat:@"%@", responseObject[@"code"]] isEqualToString:@"200"]) {

            _dataDict = [NSMutableDictionary dictionaryWithDictionary:responseObject[@"data"]];

            if ([_dataDict[@"noticeList"] count]) {
                //                //有新数据
                //                //保存模型数组
                //                for (NSDictionary *dict in _dataDict[@"noticeList"]) {
                //
                //                    //消息数据源数组
                //                    [_noticeList addObject:dict];
                //
                //                    //消息模型数组
                //                    FriendsCircleMessage *message = [[FriendsCircleMessage alloc] initWithDict:dict];
                //                    [_messageArray addObject:message];
                //                }
                //
                //                //评论列表
                //                for (int i = 0; i < [_dataDict[@"noticeList"] count]; i++) {
                //
                //                    NSMutableArray *array = [_dataDict[@"noticeList"][i][@"commentList"] mutableCopy];
                //                    [_commentList addObject:array];
                //                }
                //
                //                //点赞列表
                //                for (int i = 0; i < [_dataDict[@"noticeList"] count]; i++) {
                //
                //                    NSMutableArray *array = [_dataDict[@"noticeList"][i][@"praiseList"] mutableCopy];
                //                    [_praiseList addObject:array];
                //                }
                //                [_tableView reloadData];
                //                [_tableView.mj_footer endRefreshing];

                //保存模型数组
                for (NSDictionary *dict in _dataDict[@"noticeList"]) {

                    //消息-数据源数组
                    [_noticeList addObject:dict];

                    //消息模型数组
                    FriendsCircleMessage *message = [[FriendsCircleMessage alloc] initWithDict:dict];
                    [_messageArray addObject:message];

                    if ([message.isHot isEqualToString:@"1"]) { //是热门动态
                        [_hotMessageArray addObject:message];
                    }
                }
                [_tableView reloadData];
                //评论列表
                for (int i = 0; i < [_dataDict[@"noticeList"] count]; i++) {

                    NSMutableArray *array = [_dataDict[@"noticeList"][i][@"commentList"] mutableCopy];
                    [_commentList addObject:array];
                }
                //点赞列表
                for (int i = 0; i < [_dataDict[@"noticeList"] count]; i++) {

                    NSMutableArray *array = [_dataDict[@"noticeList"][i][@"praiseList"] mutableCopy];
                    [_praiseList addObject:array];
                }

                [_tableView.mj_header endRefreshing];
                [_tableView reloadData];

            } else {
                //没有新数据，到头了
                _currentPage--;
                [_tableView.mj_footer endRefreshing];

                [MBProgressHUD showMessage:@"已经到底啦~"];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUD];
                });
            }
        } else {

            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [MBProgressHUD showError:responseObject[@"msg"]];
        }
    }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"上拉获取朋友圈列表失败%@", error);
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"请检查您的网络"];
        }];
}


#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    NSString *text = textView.text;
    if (text.length == 0) {
        if (textView.tag == 100000) {
            _placeHolderLabel.text = [NSString stringWithFormat:@"回复%@:", _replyName];
        } else {
            _placeHolderLabel.text = [NSString stringWithFormat:@"写点儿评论吧"];
        }
    } else {
        _placeHolderLabel.text = @"";
        NSString *content      = textView.text;
        CGSize contentSize     = [content sizeWithFont:[UIFont systemFontOfSize:15.0] constrainedToSize:CGSizeMake(textView.frame.size.width - 20, 1000) lineBreakMode:NSLineBreakByWordWrapping];
        CGFloat contentHeight  = contentSize.height;
        //如果文本内容超过textView的高度
        if (20 + contentHeight > textView.frame.size.height && contentHeight < 6 * kSingleContentHeight) {
            textView.scrollEnabled = NO;
            CGFloat margin         = 20 + contentHeight - textView.frame.size.height;
            [UIView animateWithDuration:0.2 animations:^{
                //调整inputView
                CGRect inputFrame = _inputView.frame;
                inputFrame.origin.y -= margin;
                inputFrame.size.height = 40 + contentHeight;
                _inputView.frame       = inputFrame;
                //textView增加height
                CGRect temp      = textView.frame;
                temp.size.height = 20 + contentHeight;
                textView.frame   = temp;
            }];
        } else if (contentHeight >= 6 * kSingleContentHeight) { //如果达到高度极限
            textView.scrollEnabled = YES;
        }

        if (contentHeight + kSingleContentHeight + 10 <= textView.frame.size.height) { //如果文本内容行数正在缩减
            textView.scrollEnabled = NO;
            CGFloat margin         = textView.frame.size.height - 20 - contentHeight;
            [UIView animateWithDuration:0.2 animations:^{
                //调整inputView
                CGRect inputFrame = _inputView.frame;
                inputFrame.origin.y += margin;
                inputFrame.size.height = 40 + contentHeight;
                _inputView.frame       = inputFrame;
                //textView缩减height
                CGRect temp      = textView.frame;
                temp.size.height = 20 + contentHeight;
                textView.frame   = temp;
            }];
        }
    }
}


#pragma mark - 监听方法
/**
 * 键盘的frame发生改变时调用（显示、隐藏等）
 */
- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    //    if (self.picking) return;
    /**
     notification.userInfo = @{
     // 键盘弹出\隐藏后的frame
     UIKeyboardFrameEndUserInfoKey = NSRect: {{0, 352}, {320, 216}},
     // 键盘弹出\隐藏所耗费的时间
     UIKeyboardAnimationDurationUserInfoKey = 0.25,
     // 键盘弹出\隐藏动画的执行节奏（先快后慢，匀速）
     UIKeyboardAnimationCurveUserInfoKey = 7
     }
     */

    NSDictionary *userInfo = notification.userInfo;

    // 动画的持续时间
    double duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];

    // 键盘的frame
    CGRect keyboardF = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];

    // 执行动画
    [UIView animateWithDuration:duration animations:^{
        //        // 工具条的Y值 == 键盘的Y值 - 工具条的高度
        //        if (keyboardF.origin.y > self.view.height) { // 键盘的Y值已经远远超过了控制器view的高度
        //            self.toolbar.y = self.view.height - self.toolbar.height;//这里的<span style="background-color: rgb(240, 240, 240);">self.toolbar就是我的输入框。</span>
        //
        //        } else {
        //            _inputView.frame.origin.y = keyboardF.origin.y - _inputView.frame.size.height;
        //        }
        if (keyboardF.origin.y >= SCREEN_HEIGHT) {
            _inputView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 40 + kSingleContentHeight);
        } else {
            _inputView.frame = CGRectMake(0, SCREEN_HEIGHT - keyboardF.size.height - 54, SCREEN_WIDTH, 40 + kSingleContentHeight);
        }
    }];
}

- (void)reloadFriendCircle:(NSNotification *)aNotification {
    [self.tableView.mj_header beginRefreshing];
}

@end
