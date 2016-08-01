//
//  HotTopicViewController.m
//  LvYue
//
//  Created by KFallen on 16/7/29.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "HotTopicViewController.h"
#import "LYUserService.h"
#import "FriendsCircleCell.h"
#import "FriendsCircleMessage.h"
#import "DetailDataViewController.h"
#import "AFNetworking.h"
#import "MBProgressHUD+NJ.h"
#import "MJRefresh.h"

#import "ReportViewController.h"
#import "PublishMessageViewController.h"
#import "FriendsMessageViewController.h"

#define kSingleContentHeight 17.895f
@interface HotTopicViewController ()<UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UIActionSheetDelegate>{
    UILabel* shortLabel;    //内容Label
    CGFloat contentHeight;  //内容真实高度
    UIButton* joinBtn;      //话题参与按钮
    UIView* headerView;     //头部视图
    
    UIView *_addView;
    UIButton *_clearBtn;           //透明按钮
    UIView *_inputView;            //输入条
    UITextView *_textView;         //输入框
    NSDictionary *_dataDict;       //数据源
    UIButton *_sendBtn;            //发送按钮
    NSMutableArray *_messageArray; //模型数组
    NSMutableArray *_commentList;  //评论列表
    NSMutableArray *_praiseList;   //点赞列表
    NSMutableArray *_noticeList;   //消息列表
    NSInteger _currentPage;        //当前分页
    
    
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

@property (nonatomic, weak) UITableView* tableView;  //主tableview



@end

@implementation HotTopicViewController
#pragma mark - 懒加载
- (UITableView *)tableView {
    if (_tableView == nil) {
        UITableView* tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        tableView.dataSource = self;
        tableView.delegate = self;
        
        [self createHeaderView];
        _tableView = tableView;
        _tableView.tableHeaderView = headerView;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

#pragma mark - 视图加载
- (void)viewDidLoad {
    self.title = @"热门话题";
    [self setUI];
    
    //获得朋友圈消息列表
    [self postRequest];
    
}


- (void)setUI {
    self.tableView.hidden = NO;
    _currentPage = 1;
    //初始化
    _messageArray  = [NSMutableArray array];
    _commentList   = [NSMutableArray array];
    _praiseList    = [NSMutableArray array];
    _noticeList    = [NSMutableArray array];
    _coverImageUrl = nil;
    
    //右边按钮
    [self setRightButton:[UIImage imageNamed:@"more"] title:@"" target:self action:@selector(addClick) rect:CGRectMake(0, 0, 43, 43)];
    [self setLeftButton:[UIImage imageNamed:@"返回"] title:nil target:self action:@selector(back)];
    
    //设置tableview的头部view
    //[self createHeaderView];
}

//设置tableview的头部view
- (void)createHeaderView {
    headerView = [[UIView alloc] init];
    //背景图
    UIImageView* backImageView = [[UIImageView alloc] init];
    backImageView.x = 0;
    backImageView.y = 0;
    backImageView.width = kMainScreenWidth;
    backImageView.height = 160;
    backImageView.image = [UIImage imageNamed:@"朋友圈背景"];
    //backImageView.userInteractionEnabled = YES;
    [headerView addSubview:backImageView];
    
    //背景上的文字
    UILabel* joinLabel = [[UILabel alloc] init];
    joinLabel.text = @"397人参与";
    joinLabel.textColor = [UIColor whiteColor];
    joinLabel.width = 80;
    joinLabel.height = 20;
    joinLabel.font = kFont14;
    joinLabel.centerX = kMainScreenWidth*0.5;
    joinLabel.y = backImageView.height - joinLabel.height - 10;
//    joinLabel.backgroundColor = [UIColor redColor];
    [backImageView addSubview:joinLabel];
    
    UILabel* titleLabel = [[UILabel alloc] init];
    NSString* titleStr = @"#那些美好的风景#";
    titleLabel.text = titleStr;
    titleLabel.font = kFont20;
    titleLabel.textColor = [UIColor whiteColor];
    NSDictionary* attrs = @{
                            NSFontAttributeName:kFont20
                            };
    CGSize titleSize = [titleStr boundingRectWithSize:CGSizeMake(320, 50) options:NSStringDrawingTruncatesLastVisibleLine attributes:attrs context:nil].size;
    titleLabel.width = titleSize.width;
    titleLabel.height = 35;
    titleLabel.centerX = kMainScreenWidth*0.5;
    titleLabel.y = joinLabel.y - titleLabel.height;
//    titleLabel.backgroundColor = [UIColor redColor];
    [backImageView addSubview:titleLabel];
    
    //简略内容Label
    shortLabel = [[UILabel alloc] init];
    shortLabel.numberOfLines = 0;
    shortLabel.font = kFont14;
    shortLabel.x = 10;
    shortLabel.y = backImageView.height + shortLabel.x;
    shortLabel.width = kMainScreenWidth - 2*shortLabel.x;
    shortLabel.height = 80;
    //计算高度
    NSString* contentStr = @"此刻她是白锦曦，是苏眠，是《美人为馅》里的绝色警花…时间倒退，她是毓秀，是小寒，是采月，是袭香，是唤云，是八姐，是成君，是灵珊，是梅超风，是小风筝，是佟腊月，是无数无数传奇的女子…记不清多少的前世今生，她总是时而娇俏，时而狠辣，时而温柔，时而霸气，时而为情所伤，时而绝不回头…她是独立女性的代表，是绝对的演技派…时间再倒退，上戏的操场上，长发及腰的白族姑娘，十五岁的大学生，翩翩舞姿迷倒了大部分男生，但她总是安静地沉浸在戏剧的世界中，不受尘世骚扰…她信佛、念经、放生、执着…她度己亦度人，在方寸的屏幕间把热泪洒尽…她是杨蓉，她是天地的钟灵之秀…明天是她的生日，是一次新的起航…人间最美不过是把自身所学淋漓尽致地挥洒…我们渴望未来的日子里有更多的传奇女子涌现，比如刘楚玉，这是我接这个项目的唯一理由… 因为有杨蓉，戏的世界如此美好！";
    NSDictionary* shortLabelAttrs = @{
                            NSFontAttributeName:kFont14
                            };
    CGSize shortLabelSize = [contentStr boundingRectWithSize:CGSizeMake(shortLabel.width, 1000) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:shortLabelAttrs context:nil].size;
    contentHeight = shortLabelSize.height;
    if (shortLabelSize.height > 80) { //4行
        shortLabel.height = 80;
    }
    else {
        shortLabel.height = shortLabelSize.height;
        
    }
    shortLabel.text = contentStr;
    [headerView addSubview:shortLabel];
    
    //设置查看按钮
    UIButton* lookAllBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [lookAllBtn setTitle:@"查看全部" forState:UIControlStateNormal];
    [lookAllBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    lookAllBtn.titleLabel.font = kFont16;
    if (shortLabel.height < 65) { //内容少
        [lookAllBtn setFrame:CGRectZero];
    }
    else {
        [lookAllBtn setFrame:CGRectMake(shortLabel.x, CGRectGetMaxY(shortLabel.frame)+shortLabel.x, 80, 20)];
        
    }
    [lookAllBtn addTarget:self action:@selector(lookAllClick:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:lookAllBtn];
    
    //参与按钮
    joinBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [joinBtn setBackgroundColor:THEME_COLOR];
    [joinBtn setTitle:@"参与话题" forState:UIControlStateNormal];
    [joinBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    joinBtn.titleLabel.font = kFont14;
    joinBtn.x = shortLabel.x;
    joinBtn.y = 2 * joinBtn.x + CGRectGetMaxY(shortLabel.frame)+lookAllBtn.height;
    joinBtn.width = kMainScreenWidth - 2* joinBtn.x;
    joinBtn.height = 45;
    joinBtn.layer.cornerRadius = 10.0f;
    joinBtn.layer.masksToBounds = YES;
    [headerView addSubview:joinBtn];
    
    //设置headerView的frame
    headerView.x = 0;
    headerView.y = 0;
    headerView.width = kMainScreenWidth;
    headerView.height = CGRectGetMaxY(joinBtn.frame) + 15;
    headerView.backgroundColor = [UIColor whiteColor];
    //_tableView.tableHeaderView = headerView;
}


#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return 2;
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    if (section == 0) {
//        return _messageArray.count;
//    }
//    else {
//        return 2;
//    }
    return _messageArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"myCell";
    FriendsCircleCell* cell = [tableView dequeueReusableCellWithIdentifier:cellID];
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
        
        //保持最新的评论数据 和  点赞数据
        [message setCommentList:_commentList[indexPath.row]];
        [message setPraiseList:_praiseList[indexPath.row]];
        [cell initWithModel:message];
        
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
    cell.deleteBtn.tag = indexPath.row;
    [cell.deleteBtn addTarget:self action:@selector(deleteNoticeClick:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_messageArray.count) {
        FriendsCircleMessage *message = _messageArray[indexPath.row];
        return [message returnCellHeight];
    } else {
        return 0.1;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView* containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 60)];
    containerView.backgroundColor = [UIColor clearColor];
    UIView* sectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 8, kMainScreenWidth, 44)];
    sectionHeaderView.backgroundColor = [UIColor whiteColor];
    //竖线
    UIView* lineView = [[UIView alloc] init];
    lineView.width = 4;
    lineView.height = 25;
    lineView.centerY = 22;
    lineView.x = 10;
    lineView.backgroundColor = THEME_COLOR;
    [sectionHeaderView addSubview:lineView];
    
    //标题
    UILabel* titleLabel = [[UILabel alloc] init];
    titleLabel.x = CGRectGetMaxX(lineView.frame) + 10;
    titleLabel.y = 0;
    titleLabel.height = sectionHeaderView.height;
    titleLabel.width = 80;
    if (section == 0) {  //热门动态
        titleLabel.text = @"热门动态";
    }
//    else {
//        titleLabel.text = @"全部动态";
//    }
    titleLabel.textColor = [UIColor blackColor];
    [sectionHeaderView addSubview:titleLabel];
    [containerView addSubview:sectionHeaderView];
    return containerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 60;
}


//点击头像
- (void)tapHeadImg:(UITapGestureRecognizer *)tap {
    NSInteger userId                                   = [_noticeList[tap.view.tag][@"user_id"] integerValue];
    DetailDataViewController *detailDataViewController = [[DetailDataViewController alloc] init];
    detailDataViewController.friendId                  = userId;
    [self.navigationController pushViewController:detailDataViewController animated:YES];
}

#pragma mark - 点击方法
//改变frame
- (void)lookAllClick:(UIButton*)sender {
    [UIView animateWithDuration:0.05 animations:^{//隐藏按钮
        [sender setFrame:CGRectZero];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{//展开内容
            //下移距离
            CGFloat margin = contentHeight - shortLabel.height;
            //内容
            shortLabel.height = contentHeight;
            //参与按钮下移
            joinBtn.y = joinBtn.y + margin - 20;
            
            //headerView变大
            headerView.height = CGRectGetMaxY(joinBtn.frame) + 15;
            _tableView.tableHeaderView = headerView;
        }];
    }];
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

                //消息
                UIButton *msgBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 44, _addView.frame.size.width, 44)];
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
    
    if ([LYUserService sharedInstance].canPublishFriend) {
        [self hiddenAddView];
        
        PublishMessageViewController *publishMessageViewController = [[PublishMessageViewController alloc] init];
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
- (void)reportClick:(UIButton *)sender {
    ReportViewController* vc = [[ReportViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)senderGift:(UIButton *)sender {
    // NSLog(@"senderGift");
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

//点击回复
- (void)commentClick:(NSNotification *)notification {
    
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
    _commenter = _noticeList[[notification.userInfo[@"index"] integerValue]][@"user_id"];
    
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
            NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/notice/comment", REQUESTHEADER];
            [manager POST:urlStr parameters:@{ @"noticeId": _dataDict[@"noticeList"][sender.tag / 10][@"id"],
                                               @"commentType": @"0",
                                               @"commenter": [NSString stringWithFormat:@"%@", [LYUserService sharedInstance].userID],
                                               @"commentDetail": detailStr }
                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                      NSLog(@"发送评论:%@", responseObject);
                      [MBProgressHUD hideHUD];
                      
                      if ([[NSString stringWithFormat:@"%@", responseObject[@"code"]] isEqualToString:@"200"]) {
                          
                          NSLog(@"发送评论成功");
                          //1.隐藏输入框 评论显示+1
                          [self hiddenAddView];
                          //2.手动加入数据源
                          NSString *comment_id = responseObject[@"data"][@"id"];
                          NSDictionary *dict   = @{ @"comment_id": comment_id,
                                                    @"comment_user": [NSString stringWithFormat:@"%@", [LYUserService sharedInstance].userDetail.userName],
                                                    @"comment_user_id": [NSString stringWithFormat:@"%@", [LYUserService sharedInstance].userID],
                                                    @"detail": detailStr,
                                                    @"notice_id": _dataDict[@"noticeList"][sender.tag / 10][@"id"],
                                                    @"reply_user": @"",
                                                    @"reply_user_id": @"",
                                                    @"type": @"0" };
                          [_commentList[sender.tag / 10] addObject:dict];
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
                                                    @"notice_id": _dataDict[@"noticeList"][sender.tag / 10][@"id"],
                                                    @"reply_user": _replyName,
                                                    @"reply_user_id": _reply,
                                                    @"type": @"1" };
                          [_commentList[sender.tag / 10] addObject:dict];
                          
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
    
    //取出cell
    FriendsCircleCell *cell;
    if (kSystemVersion >= 8.0) {
        cell = (FriendsCircleCell *) [sender superview];
    } else {
        cell = (FriendsCircleCell *) [[sender superview] superview];
    }
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSInteger row          = indexPath.row;
    
    if (sender.selected == NO) {
        //按钮变红，数量+1,tag+1
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSString *urlStr                       = [NSString stringWithFormat:@"%@/mobile/notice/praise", REQUESTHEADER];
        [manager POST:urlStr parameters:@{ @"noticeId": _noticeList[row][@"id"],
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
                      NSDictionary *dict  = @{ @"notice_id": _noticeList[row][@"id"],
                                               @"praise_id": praise_id,
                                               @"praise_user": [NSString stringWithFormat:@"%@", [LYUserService sharedInstance].userDetail.userName],
                                               @"praise_user_id": [NSString stringWithFormat:@"%@", [LYUserService sharedInstance].userID] };
                      [_praiseList[row] addObject:dict];
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
        for (NSDictionary *dict in _praiseList[row]) {
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
                [_praiseList[row] removeObject:deltDict];
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
                  //保存模型数组
                  for (NSDictionary *dict in _noticeList) {
                      
                      //消息模型数组
                      FriendsCircleMessage *message = [[FriendsCircleMessage alloc] initWithDict:dict];
                      [_messageArray addObject:message];
                  }
                  
                  [_commentList removeObjectAtIndex:sender.tag];
                  [_praiseList removeObjectAtIndex:sender.tag];
                  
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
    [_commentList removeAllObjects];
    [_praiseList removeAllObjects];
    [_noticeList removeAllObjects];
    AFHTTPRequestOperationManager* manager = [AFHTTPRequestOperationManager manager];
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/notice/iosNoticeList", REQUESTHEADER];
    
    NSDictionary *parameters;
    //NSString* allUserId = @"";
    //type 0->自己的朋友圈 1->自己的动态加上userID
    if (!self.userId) {
        self.userId = @"";
    }
    
    if (_isFriendsCircle) { //自己的动态
        parameters = @{ @"userId": [NSString stringWithFormat:@"%@", self.userId],
                        @"noticeType": @"0",
                        @"pageNum": [NSString stringWithFormat:@"%d", (int) _currentPage],
                        @"type": @"0" };
    }
    else { //ta的动态
        parameters = @{ @"userId": [NSString stringWithFormat:@"%@", self.userId],
                        @"noticeType": @"0",
                        @"pageNum": [NSString stringWithFormat:@"%d", (int) _currentPage],
                        @"status": @"1",
                        @"type": @"1" };
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
            
        }
        else {
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [MBProgressHUD showError:responseObject[@"msg"]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"获取朋友圈列表%@", error);
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [MBProgressHUD showError:@"请检查您的网络"];
    }];
}
//注册通知
- (void)addObserver {
    
    //点击评论
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commentClick:) name:@"commentClick_KF" object:nil];
    //键盘高度变化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    //删除评论
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showActionSheet:) name:@"deleteMyComment" object:nil];
    //更新朋友圈
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadFriendCircle:) name:@"ReloadFriendCircleVC" object:nil];
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
            _inputView.frame = CGRectMake(0, SCREEN_HEIGHT - 64, SCREEN_WIDTH, 40 + kSingleContentHeight);
        } else {
            _inputView.frame = CGRectMake(0, SCREEN_HEIGHT - keyboardF.size.height - 54 - 64, SCREEN_WIDTH, 40 + kSingleContentHeight);
        }
    }];
}

- (void)reloadFriendCircle:(NSNotification *)aNotification {
    [self.tableView.mj_header beginRefreshing];
}

@end
