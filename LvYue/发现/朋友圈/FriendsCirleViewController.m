//
//  FriendsCirleViewController.m
//  LvYueDemo
//
//  Created by 蒋俊 on 15/9/17.
//  Copyright (c) 2015年 vison. All rights reserved.
//

#import "FriendsCircleCell.h"
#import "FriendsCircleMessage.h"
#import "FriendsCirleViewController.h"
#import "FriendsMessageViewController.h"
#import "LYDetailDataViewController.h"
#import "PublishMessageViewController.h"
#import "LYDetailDataViewController.h"
#import "AFNetworking.h"
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "MBProgressHUD+NJ.h"
#import "MJRefresh.h"
#import "MyDetailInfoModel.h"
#import "MyInfoModel.h"
#import "QiniuSDK.h"
#import "UIImagePickerController+CheckCanTakePicture.h"
#import "UIImageView+WebCache.h"
#import "VipInfoViewController.h"
#import "WhoComeViewController.h"
#import "ReportViewController.h"
#import "HotTopicViewController.h"
#import "TopicTitle.h"
#import "PublishVideoViewController.h"

#import "VideoCommitViewController.h"
#import <MediaPlayer/MediaPlayer.h>

#define kSingleContentHeight 17.895f

@interface FriendsCirleViewController () <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    BOOL isAttention;           //是否关注，默认未选中

    NSURL *_currentVideoURL; //当前准备要播放的视频的URL
    BOOL isupdateVideo;        //是否视频， yes是 no
    
    NSTimer *timer; //定时器轮询
    UIView *_addView;
    UIView *headerView;
    UIButton *_newMsgBtn;          //新消息提示
    UIButton *_clearBtn;           //透明按钮
    UIView *_inputView;            //输入条
    UITextView *_textView;         //输入框
    NSDictionary *_dataDict;       //数据源
    UIButton *_sendBtn;            //发送按钮
    NSMutableArray *_messageArray; //模型数组
    NSMutableArray *_commentList;  //评论列表
    NSMutableArray *_praiseList;   //点赞列表
    NSMutableArray *_noticeList;   //消息列表
    NSMutableArray *_topicList;    //热门话题数量
    UIButton* tipButton;            //热门
    UILabel* hotLabel;              //热门Label
    
    UIButton *_newMsg;             //新消息条数提示
    NSString *_newMsgIcon;         //新消息提示的头像图片
    NSInteger _newMsgNumber;       //新消息数
    NSInteger _currentPage;        //当前分页

    /*****************评论中回复他人用到的过渡字段*******************/
    NSString *_reply;           //回复的对象id
    NSString *_replyName;       //回复的对象名字
    NSString *_noticeId;        //评论的消息id
    NSString *_commenter;       //评论用户id
    UILabel *_placeHolderLabel; //评论时的提示label

    /*****************评论中删除评论用到的过渡字典*******************/
    NSDictionary *_deleteCommentDict;

    UIImageView *newMsgHeadImg;
    UILabel *newMsgTitle;
    UIImageView *myIcon;
    UILabel *myName;
    UIImageView *bgImageView; //背景图片

    UIView *hotBackView;  //热门话题

    /*****************封面图片Url*****************/
    NSURL *_coverImageUrl;     //网络封面图片URL
    UIImage *_localCoverImage; //本地缓存的图片
}

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) MyInfoModel *myInfoModel;
@property (nonatomic, strong) MyDetailInfoModel *myDetailModel;

@property (nonatomic, strong) MPMoviePlayerViewController* player;
@property (nonatomic, strong) UIImagePickerController *imagePicker; //摄像控制器

@end

@implementation FriendsCirleViewController

- (UIImagePickerController *)imagePicker {
    if (!_imagePicker) {
        _imagePicker                      = [[UIImagePickerController alloc] init];
        _imagePicker.sourceType           = UIImagePickerControllerSourceTypeCamera;
        _imagePicker.mediaTypes           = @[(NSString *) kUTTypeMovie];
        _imagePicker.videoQuality         = UIImagePickerControllerQualityTypeMedium;
        _imagePicker.cameraCaptureMode    = UIImagePickerControllerCameraCaptureModeVideo;
        _imagePicker.videoMaximumDuration = 300.0f;
        _imagePicker.allowsEditing        = YES;
        _imagePicker.delegate             = self;
    }
    return _imagePicker;
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

//    _currentPage = 1;
//
//    //获得朋友圈消息列表
    [self postRequest];
//    //热门话题
//    [self getHotTopic];
//    //[self getDataFromWeb];
//    //注册通知
//    [self addObserver];
}


- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    //    从runloop中移除
    [timer invalidate];
    timer = nil;


    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)viewDidLoad {
    [super viewDidLoad];

    //取消边界边缘化
    [self setEdgesForExtendedLayout:UIRectEdgeNone];


    //初始化
    _messageArray  = [NSMutableArray array];
    _commentList   = [NSMutableArray array];
    _praiseList    = [NSMutableArray array];
    _noticeList    = [NSMutableArray array];
    _topicList     = [NSMutableArray array];
    _coverImageUrl = nil;
    isAttention = NO;
    isupdateVideo = NO;

    _tableView                 = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.delegate        = self;
    _tableView.dataSource      = self;
    _tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];

    
    //数据
    _currentPage = 1;
    
    //获得朋友圈消息列表
    //[self postRequest];
    //热门话题
    [self getHotTopic];
    //[self getDataFromWeb];
    //注册通知
    [self addObserver];
    //数据*******
    
    
    [self setStatus];
    //[self getHotTopic];
    
    [self getDataFromWeb];
    //上拉下拉刷新
    [self addRefresh];

    //[self addCome];//添加来过记录
}

- (void)setStatus {
    //初始化头部segment
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithFrame:CGRectMake(0, 0, 120, 30)];
    segmentedControl.tintColor           = [UIColor whiteColor];
    [segmentedControl insertSegmentWithTitle:@"全部" atIndex:0 animated:YES];
    [segmentedControl insertSegmentWithTitle:@"关注" atIndex:1 animated:YES];
    NSDictionary *attrs = @{
        NSFontAttributeName: kFont16
    };
    [segmentedControl setTitleTextAttributes:attrs forState:UIControlStateNormal];
    [segmentedControl setTitleTextAttributes:attrs forState:UIControlStateSelected];

    self.navigationItem.titleView         = segmentedControl;
    segmentedControl.selectedSegmentIndex = 0;
    [segmentedControl addTarget:self action:@selector(controlPressed:) forControlEvents:UIControlEventValueChanged];

    //数据
    if ([self.userId isEqualToString:@""] || [self.userId isKindOfClass:[NSNull class]] || self.userId == nil) {
        self.userId = [LYUserService sharedInstance].userID;
        //self.userId = [NSString stringWithFormat:@""];
        self.isFriendsCircle = YES;
        self.title           = @"朋友圈";
        self.personName      = [LYUserService sharedInstance].userDetail.userName;
    }

    if (_isFriendsCircle) {
        [self setRightButton:[UIImage imageNamed:@"more"] title:@"" target:self action:@selector(addClick) rect:CGRectMake(0, 0, 43, 43)];
    } else {
        self.title                                    = @"Ta的动态";
        self.navigationController.navigationBarHidden = NO;
        if ([self.userId isEqualToString:[LYUserService sharedInstance].userID]) {
            [self setRightButton:nil title:@"最近来访" target:self action:@selector(whoCome) rect:CGRectMake(0, 0, 80, 20)];
        }
    }

    //获得朋友圈消息列表
    //    [self postRequest];
    //[self getDataFromWeb];
}

- (void)controlPressed:(UISegmentedControl *)sender {
    NSInteger selectedIndex = [sender selectedSegmentIndex];

    /* 添加代码,处理值的变化 */
    if (selectedIndex == 0) { //全部
        MLOG(@"%ld", (long) selectedIndex);
        isAttention = NO;
    } else { //关注
        MLOG(@"%ld", (long) selectedIndex);
        isAttention = YES;
        
    }
    //获得朋友圈消息列表
    [self postRequest];
    //上拉下拉刷新
    [self addRefresh];
}



#pragma mark 添加最近来访请求

- (void)addCome {
    if ([self.userId isEqualToString:[LYUserService sharedInstance].userID]) {
        return;
    } else {
        self.userId = [NSString stringWithFormat:@""];
        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/notice/iosNoticeList", REQUESTHEADER] andParameter:@{ @"own_id": [NSString stringWithFormat:@"%@", [LYUserService sharedInstance].userID],
                                                                                                                                         @"userId": self.userId,
                                                                                                                                         @"status": @"2",
                                                                                                                                         @"noticeType": @"0" }
            success:^(id successResponse) {
                MLOG(@"最近来访结果:%@", successResponse);
                if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {

                } else {
                }
            }
            andFailure:^(id failureResponse){

            }];
    }
}


#pragma mark 最近来访事件

- (void)whoCome {
    WhoComeViewController *come = [[WhoComeViewController alloc] init];
    [self.navigationController pushViewController:come animated:YES];
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
    //[self getHotTopic];
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
//    if (_isFriendsCircle) { //朋友圈
//        NSString* type ;
//        if (self.userId) {  //y
//            type = @"2";
//        }
//        else if (self.userId == nil) {
//            type = @"0";
//        }
//        parameters = @{ @"userId": [NSString stringWithFormat:@"%@", self.userId],
//                        @"noticeType": @"0",
//                        @"pageNum": [NSString stringWithFormat:@"%d", (int) _currentPage],
//                        @"type": type };
//    } else { //ta的动态
//        parameters = @{ @"userId": [NSString stringWithFormat:@"%@", self.userId],
//                        @"noticeType": @"0",
//                        @"pageNum": [NSString stringWithFormat:@"%d", (int) _currentPage],
//                        @"status": @"1",
//                        @"type": @"1" };
//    }
    if (isAttention == NO) {  //全部
        if (_isFriendsCircle) { //自己的动态
            
            NSString* type ;
            if (self.userId) {  //y
                type = @"2";
            }
            else if (self.userId == nil) {
                if (!self.userId) {
                    self.userId = @"";
                }
                type = @"0";
            }
            parameters = @{ @"userId": [NSString stringWithFormat:@"%@", self.userId],
                            @"noticeType": @"0",
                            @"pageNum": [NSString stringWithFormat:@"%d", (int) _currentPage],
                            @"type": type };
            
        }
        else { //ta的动态
            parameters = @{ @"userId": [NSString stringWithFormat:@"%@", self.userId],
                            @"noticeType": @"0",
                            @"pageNum": [NSString stringWithFormat:@"%d", (int) _currentPage],
                            @"status": @"1",
                            @"type": @"1" };
        }
    }
    else {
        if (_isFriendsCircle) { //自己的动态
            
            //            NSString* type ;
            //            if (self.userId) {  //y
            //                type = @"2";
            //            }
            //            else if (self.userId == nil) {
            //                if (!self.userId) {
            //                    self.userId = @"";
            //                }
            //                type = @"0";
            //            }
            parameters = @{ @"userId": [NSString stringWithFormat:@"%@", self.userId],
                            @"noticeType": @"0",
                            @"pageNum": [NSString stringWithFormat:@"%d", (int) _currentPage],
                            @"type": @"3" };
            
        }
        else { //ta的动态
            parameters = @{ @"userId": [NSString stringWithFormat:@"%@", self.userId],
                            @"noticeType": @"0",
                            @"pageNum": [NSString stringWithFormat:@"%d", (int) _currentPage],
                            @"status": @"1",
                            @"type": @"3" };
        }
        
    }


    [manager POST:urlStr parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"上拉获取朋友圈列表:%@", responseObject);
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

        if ([[NSString stringWithFormat:@"%@", responseObject[@"code"]] isEqualToString:@"200"]) {

            _dataDict = [NSMutableDictionary dictionaryWithDictionary:responseObject[@"data"]];

            if ([_dataDict[@"noticeList"] count]) {
                //有新数据
                //保存模型数组
                for (NSDictionary *dict in _dataDict[@"noticeList"]) {

                    //消息数据源数组
                    [_noticeList addObject:dict];

                    //消息模型数组
                    FriendsCircleMessage *message = [[FriendsCircleMessage alloc] initWithDict:dict];
                    [_messageArray addObject:message];
                }

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
                [_tableView reloadData];
                [_tableView.mj_footer endRefreshing];

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

//获取朋友圈
- (void)postRequest {
    //type 0 所有； 1 屏蔽动态； 2 他人动态
    //清空数据源
    [_messageArray removeAllObjects];
    [_commentList removeAllObjects];
    [_praiseList removeAllObjects];
    [_noticeList removeAllObjects];

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/notice/iosNoticeList", REQUESTHEADER];

    NSDictionary *parameters;
    //NSString* allUserId = @"";
    //type 0->自己的朋友圈 1->自己的动态加上userID

    if (isAttention == NO) {  //全部
        if (_isFriendsCircle) { //自己的动态
            
            NSString* type ;
            if (self.userId) {  //y
                type = @"2";
            }
            else if (self.userId == nil) {
                if (!self.userId) {
                    self.userId = @"";
                }
                type = @"0";
            }
            parameters = @{ @"userId": [NSString stringWithFormat:@"%@", self.userId],
                            @"noticeType": @"0",
                            @"pageNum": [NSString stringWithFormat:@"%d", (int) _currentPage],
                            @"type": type };
            
        }
        else { //ta的动态
            parameters = @{ @"userId": [NSString stringWithFormat:@"%@", self.userId],
                            @"noticeType": @"0",
                            @"pageNum": [NSString stringWithFormat:@"%d", (int) _currentPage],
                            @"status": @"1",
                            @"type": @"1" };
        }
    }
    else {
        if (_isFriendsCircle) { //自己的动态
            
//            NSString* type ;
//            if (self.userId) {  //y
//                type = @"2";
//            }
//            else if (self.userId == nil) {
//                if (!self.userId) {
//                    self.userId = @"";
//                }
//                type = @"0";
//            }
            parameters = @{ @"userId": [NSString stringWithFormat:@"%@", self.userId],
                            @"noticeType": @"0",
                            @"pageNum": [NSString stringWithFormat:@"%d", (int) _currentPage],
                            @"type": @"3" };
            
        }
        else { //ta的动态
            parameters = @{ @"userId": [NSString stringWithFormat:@"%@", self.userId],
                            @"noticeType": @"0",
                            @"pageNum": [NSString stringWithFormat:@"%d", (int) _currentPage],
                            @"status": @"1",
                            @"type": @"3" };
        }
    
    }
    
    
    [MBProgressHUD showMessage:nil toView:self.view];

    [manager POST:urlStr parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        MLOG(@"获取朋友圈列表:%@", responseObject);
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

            if (!timer) {
                //初始化计时器 每3秒轮询是否有新消息
                timer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(getNewMsgNumber) userInfo:nil repeats:YES];

                //立即请求一次新消息
                [self getNewMsgNumber];
            }

        } else {

            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [MBProgressHUD showError:responseObject[@"msg"]];
        }
    }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"获取朋友圈列表失败%@", error);
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [MBProgressHUD showError:@"请检查您的网络"];
        }];
}

//获取热门话题
- (void)getHotTopic {
    //清空数据源
    [_topicList removeAllObjects];
    
    NSString* urlStr = [NSString stringWithFormat:@"%@/mobile/notice/getHotTitle",REQUESTHEADER];
    NSDictionary* params = nil;
    
    [MBProgressHUD showMessage:nil toView:self.view];
    [LYHttpPoster postHttpRequestByPost:urlStr andParameter:params success:^(id successResponse) {
        MLOG(@"获取热门话题:%@", successResponse);
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
            NSMutableArray* topicsM = successResponse[@"data"][@"topics"];
            for (NSDictionary* dict in topicsM) {
                TopicTitle* topic = [TopicTitle topicTitleWithDict:dict];
                [_topicList addObject:topic];
            }
            hotLabel.height = 35*(_topicList.count+1);
            hotBackView.height = 35*(_topicList.count+1)+3;
            
            [_tableView.mj_header endRefreshing];
            [_tableView reloadData];
        }
        else {
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [MBProgressHUD showError:successResponse[@"msg"]];
        }
    } andFailure:^(id failureResponse) {
        NSLog(@"获取热门话题%@", failureResponse);
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

                _addView                    = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 130, 10, 120, 88+44)];
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
                publishVideoLabel.text          = @"发布视频";
                [publishVideoBtn addSubview:publishVideoLabel];

                //消息
                UIButton *msgBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 88, _addView.frame.size.width, 44)];
                [msgBtn addTarget:self action:@selector(pushMessageList) forControlEvents:UIControlEventTouchUpInside];
                [_addView addSubview:msgBtn];

                UIImageView *msgImageView = [[UIImageView alloc] initWithFrame:CGRectMake((44 - 20) / 2, (44 - 20) / 2, 20, 20)];
                msgImageView.image        = [UIImage imageNamed:@"对话2"];
                msgImageView.contentMode  = UIViewContentModeScaleAspectFit;
                [msgBtn addSubview:msgImageView];

                UILabel *msgLabel      = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(msgImageView.frame) - 5, 0, _addView.frame.size.width - CGRectGetMaxX(msgImageView.frame), 44)];
                msgLabel.textAlignment = NSTextAlignmentCenter;
                msgLabel.font          = [UIFont systemFontOfSize:17];
                msgLabel.text          = @"消息";
                [msgBtn addSubview:msgLabel];

                _newMsg = [[UIButton alloc] initWithFrame:CGRectMake(95, (44 - 18) / 2, 18, 18)];
                [_newMsg setBackgroundImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
                _newMsg.hidden          = YES;
                _newMsg.titleLabel.font = [UIFont systemFontOfSize:14];
                [msgBtn addSubview:_newMsg];

            } else {

                _addView.hidden  = !_addView.hidden;
                _clearBtn.hidden = !_clearBtn.hidden;
            }
        }
    }];
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

//获得新消息数量提示
- (void)getNewMsgNumber {

    [[LYUserService sharedInstance] fetchLoginStateWithCompeletionBlock:^(UserLoginStateType type) {
        if (type == UserLoginStateTypeWaitToLogin) {

        } else {
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            NSString *urlStr                       = [NSString stringWithFormat:@"%@/mobile/notice/iosFindNumByUser", REQUESTHEADER];
            [manager POST:urlStr parameters:@{ @"userId": [NSString stringWithFormat:@"%@", [LYUserService sharedInstance].userID] } success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"新消息数量:%@", responseObject);

                if ([[NSString stringWithFormat:@"%@", responseObject[@"code"]] isEqualToString:@"200"]) {

                    _newMsgNumber = [responseObject[@"data"][@"infoNum"] integerValue];
                    _newMsgIcon   = [NSString stringWithFormat:@"%@%@", IMAGEHEADER, responseObject[@"data"][@"icon"]];

                    //如果大于0，则提示新消息
                    if (_newMsgNumber > 0) {
                        [_tableView reloadData];
                    } else {
                        [_tableView reloadData];
                    }
                }
            }
                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"新消息数量%@", error);
                    [MBProgressHUD showError:@"请检查您的网络"];
                }];
        }
    }];
}

//进入消息列表
- (void)pushMessageList {

    [self hiddenAddView];
    _newMsgNumber = 0;

    FriendsMessageViewController *friendsMessageViewController = [[FriendsMessageViewController alloc] init];
    [self.navigationController pushViewController:friendsMessageViewController animated:YES];
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

//发布视频
- (void)publishVideoClick:(UIButton *)sender {
    if ([LYUserService sharedInstance].canPublishFriend) {
        [self hiddenAddView];
        
//        PublishVideoViewController *publishMessageViewController = [[PublishVideoViewController alloc] init];
//        [self.navigationController pushViewController:publishMessageViewController animated:YES];
        
        if ([[LYUserService sharedInstance] canPublishVideo]) { //如果没有权限约束
            [self presentViewController:self.imagePicker animated:YES completion:nil];
            [[[UIAlertView alloc] initWithTitle:nil message:@"视频录制最长时间不能超过5分钟\n超过5分钟将自动结束录制" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil] show];
            isupdateVideo = YES;
        } else { //如果有权限约束
            if ([[LYUserService sharedInstance].userDetail.isVip isEqualToString:@"1"]) {
                [self presentViewController:self.imagePicker animated:YES completion:nil];
                [[[UIAlertView alloc] initWithTitle:nil message:@"视频录制最长时间不能超过5分钟\n超过5分钟将自动结束录制" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil] show];
            } else {
                [[[UIAlertView alloc] initWithTitle:nil message:@"您还不是会员，将无法享受发布功能" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"成为会员", nil] show];
            }
        }
        
        
    } else {
        if ([[LYUserService sharedInstance].userDetail.isVip isEqualToString:@"0"]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"您需要开通会员才能发消息" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:@"去开通", nil];
            alert.delegate     = self;
            [alert show];
            
        } else {
            [self hiddenAddView];
            
            PublishVideoViewController *publishMessageViewController = [[PublishVideoViewController alloc] init];
            [self.navigationController pushViewController:publishMessageViewController animated:YES];
        }
    }
}


//点击蒙层 隐藏输入框等
- (void)hiddenAddView {

    //清空
    _textView.text = @"";
    [_textView resignFirstResponder];

    _addView.hidden  = YES;
    _clearBtn.hidden = YES;
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

//点击头像
- (void)tapHeadImg:(UITapGestureRecognizer *)tap {

    NSInteger userId                                   = [_noticeList[tap.view.tag][@"user_id"] integerValue];
    LYDetailDataViewController *detailDataViewController = [[LYDetailDataViewController alloc] init];
    detailDataViewController.userId                  = [NSString stringWithFormat:@"%ld", (long)userId];
    [self.navigationController pushViewController:detailDataViewController animated:YES];

}


#pragma mark - UITableViewDataSource & Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    //    return [_dataDict[@"noticeList"]count];
    /**
     *  @author KF, 16-07-15 12:07:09
     */
    //return _noticeList.count;
    return _messageArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

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
#pragma mark - 下拉tableview，增加报错
        /**
         *  @author KF, 16-07-15 11:07:18
         *
         *  @brief  reason: '*** -[__NSArrayM objectAtIndex:]: index 32 beyond bounds [0 .. 19]'
         */
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
    //视频播放
    [cell.videoBtn addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
    cell.videoBtn.tag = 100 + indexPath.row;
    
    cell.deleteBtn.tag = indexPath.row;
    [cell.deleteBtn addTarget:self action:@selector(deleteNoticeClick:) forControlEvents:UIControlEventTouchUpInside];

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (_messageArray.count) {
        FriendsCircleMessage *message = _messageArray[indexPath.row];
        return [message returnCellHeight];
    } else {
        return 0.1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {

    if (_newMsgNumber > 0) {
        _newMsgBtn.hidden = NO;
        hotBackView.y = CGRectGetMaxY(_newMsgBtn.frame)+5;
        headerView.frame  = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH * 0.5 + 70 + hotBackView.height);
        return SCREEN_WIDTH * 0.5 + 70+hotBackView.height;
    } else {
        //设置热门的frame
        hotBackView.y = CGRectGetMaxY(myIcon.frame)+5;
        headerView.frame  = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH * 0.5 + 30 +hotBackView.height);

        _newMsgBtn.hidden = YES;
        return SCREEN_WIDTH * 0.5 + 30+hotBackView.height;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {

    return 0.1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (!headerView) {
        headerView                 = [[UIView alloc] init];
        headerView.backgroundColor = [UIColor whiteColor];

        //大图片
        bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH * 0.5)];
        if (_coverImageUrl) {
            [bgImageView sd_setImageWithURL:_coverImageUrl placeholderImage:[UIImage imageNamed:@"封面"]];
        } else {
            bgImageView.image = [UIImage imageNamed:@"封面"];
        }
        bgImageView.userInteractionEnabled = YES;
        //bgImageView.contentMode = UIViewContentModeScaleToFill;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCoverImage:)];
        [bgImageView addGestureRecognizer:tap];
        [headerView addSubview:bgImageView];

        //自己的头像
        myIcon                     = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 80, SCREEN_WIDTH * 0.5 - 35, 70, 70)];
        myIcon.layer.cornerRadius  = myIcon.frame.size.width / 2;
        myIcon.layer.masksToBounds = YES;
        if (self.myInfoModel.icon) {
            [myIcon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", IMAGEHEADER, self.myInfoModel.icon]] placeholderImage:[UIImage imageNamed:@"默认头像"]];
        } else {
            myIcon.image = [UIImage imageNamed:@"默认头像"];
        }

        [headerView addSubview:myIcon];

        //自己的昵称
        [[LYUserService sharedInstance] fetchLoginStateWithCompeletionBlock:^(UserLoginStateType type) {
            if (type == UserLoginStateTypeWaitToLogin) {

            } else {
                myName = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(myIcon.frame) - 150, myIcon.centerY, 140, 20)];
                if (self.isFriendsCircle) {
                    myName.text = [LYUserService sharedInstance].userDetail.userName;
                } else {
                    myName.text = self.personName;
                }

                myName.textAlignment = NSTextAlignmentRight;
                myName.textColor     = [UIColor whiteColor];
                [myName setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15]];
                [headerView addSubview:myName];
            }
        }];


    } else {
        if (_coverImageUrl) {
            [bgImageView sd_setImageWithURL:_coverImageUrl placeholderImage:[UIImage imageNamed:@"封面"]];
        } else {
            bgImageView.image = [UIImage imageNamed:@"封面"];
        }
    }

    //消息提示
    if (!_newMsgBtn) {
        _newMsgBtn                    = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 140) / 2, CGRectGetMaxY(bgImageView.frame) + 30, 140, 35)];
        _newMsgBtn.backgroundColor    = UIColorWithRGBA(58, 58, 58, 1);
        _newMsgBtn.layer.cornerRadius = 5.0;
        _newMsgBtn.hidden             = YES;
        [_newMsgBtn addTarget:self action:@selector(pushMessageList) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:_newMsgBtn];
    }

    //消息提示头像
    if (!newMsgHeadImg) {
        newMsgHeadImg = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 25, 25)];
        [newMsgHeadImg sd_setImageWithURL:[NSURL URLWithString:_newMsgIcon] placeholderImage:[UIImage imageNamed:@"默认头像"]];
        newMsgHeadImg.layer.cornerRadius = 5.0;
        [_newMsgBtn addSubview:newMsgHeadImg];
    } else {
        [newMsgHeadImg sd_setImageWithURL:[NSURL URLWithString:_newMsgIcon] placeholderImage:[UIImage imageNamed:@"默认头像"]];
    }

    //消息提示文字
    if (!newMsgTitle) {
        newMsgTitle               = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, _newMsgBtn.frame.size.width - 30, _newMsgBtn.frame.size.height)];
        newMsgTitle.text          = [NSString stringWithFormat:@"%ld条新消息", (long) _newMsgNumber];
        newMsgTitle.textAlignment = NSTextAlignmentCenter;
        newMsgTitle.textColor     = [UIColor whiteColor];
        newMsgTitle.font          = [UIFont systemFontOfSize:13];
        [_newMsgBtn addSubview:newMsgTitle];
    } else {
        newMsgTitle.text = [NSString stringWithFormat:@"%ld条新消息", (long) _newMsgNumber];
    }

    //一个热门话题的高度
    static CGFloat hotTipH = 35;
    
    //设置热门话题
    if (!hotBackView) {
        //背景
        hotBackView = [[UIView alloc] init];
        hotBackView.backgroundColor = [UIColor clearColor];
        hotBackView.x = 0;
        hotBackView.y = CGRectGetMaxY(_newMsgBtn.frame);
        hotBackView.width = kMainScreenWidth;
        hotBackView.height = 60;
        [headerView addSubview:hotBackView];
        
        //热门
        hotLabel = [[UILabel alloc] init];
        hotLabel.x = 10;
        hotLabel.y = 0;
        hotLabel.width = hotTipH;
        hotLabel.height = 60;
        hotLabel.backgroundColor = [UIColor whiteColor];
        hotLabel.numberOfLines = 0;
        hotLabel.text = @"热话";
        hotLabel.font = kFont20;
        hotLabel.textColor = THEME_COLOR;
        //阴影
//        hotLabel.layer.shadowColor = [UIColor blackColor].CGColor;//shadowColor阴影颜色
////        hotLabel.layer.shadowOffset = CGSizeMake(4,4);//shadowOffset阴影偏移,x向右偏移4，y向下偏移4，默认(0, -3),这个跟shadowRadius配合使用
//        hotLabel.layer.shadowOffset = CGSizeMake(4,0);//shadowOffset阴影偏移,x向右偏移4，y向下偏移4，默认(0, -3),这个跟shadowRadius配合使用
//        hotLabel.layer.shadowOpacity = 0.2;//阴影透明度，默认0
////        hotLabel.layer.shadowRadius = 4;//阴影半径，默认3
//        hotLabel.layer.shadowRadius = 2;//阴影半径，默认3
        
        //阴影
        hotLabel.layer.shadowColor   = [UIColor blackColor].CGColor;
        hotLabel.layer.shadowOffset  = CGSizeMake(4, 0);
        UIBezierPath *shadowPath     = [UIBezierPath bezierPathWithRect:CGRectMake(hotLabel.x + hotLabel.width, 0, 1, hotLabel.height)];
        hotLabel.layer.shadowPath    = shadowPath.CGPath;
        hotLabel.layer.shadowOpacity = 0.8f;
        
        
        hotLabel.textAlignment = NSTextAlignmentCenter;
        [hotBackView addSubview:hotLabel];
        
        //话题内容
//        UIButton* tipButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        tipButton.x = CGRectGetMaxX(hotLabel.frame) + 3;
//        tipButton.y = hotLabel.y;
//        tipButton.width = kMainScreenWidth - CGRectGetMaxX(hotLabel.frame) - 3;
//        tipButton.height = hotTipH;
//        //        tipButton.backgroundColor = [UIColor redColor];
//        [tipButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [tipButton setTitle:@"#赵薇新片撤换戴立忍#" forState:UIControlStateNormal];
//        tipButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//        tipButton.titleEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
//        [tipButton addTarget:self action:@selector(clickTipButton:) forControlEvents:UIControlEventTouchUpInside];
//        [hotBackView addSubview:tipButton];
//        //虚线
//        UIView* lineView =[[UIView alloc] init];
//        lineView.x = 0;
//        lineView.y = tipButton.height - 1;
//        lineView.width = kMainScreenWidth;
//        lineView.height = 1.0f;
//        [UIView drawDashLine:lineView lineLength:3.0f lineSpacing:3.0f lineColor:[UIColor grayColor]];
//        [tipButton addSubview:lineView];
//        
//        UIButton* tip2Button = [UIButton buttonWithType:UIButtonTypeCustom];
//        tip2Button.x = CGRectGetMaxX(hotLabel.frame) + 3;
//        tip2Button.y = CGRectGetMaxY(tipButton.frame) + 1;
//        tip2Button.width = kMainScreenWidth - CGRectGetMaxX(hotLabel.frame) - 3;
//        tip2Button.height = hotTipH;
//        //        tip2Button.backgroundColor = [UIColor blueColor];
//        tip2Button.titleLabel.textColor = [UIColor blackColor];
//        [tip2Button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [tip2Button setTitle:@"#赵薇新片撤换戴立忍#" forState:UIControlStateNormal];
//        tip2Button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//        tip2Button.titleEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
//        [tip2Button addTarget:self action:@selector(clickTipButton:) forControlEvents:UIControlEventTouchUpInside];
//        [hotBackView addSubview:tip2Button];
//
//        for (int i = 0; i<_topicList.count; i++) {
//            //话题内容
//            UIButton* tipButton = [UIButton buttonWithType:UIButtonTypeCustom];
//            tipButton.height = hotTipH;
//            tipButton.width = kMainScreenWidth - CGRectGetMaxX(hotLabel.frame) - 3;
//            tipButton.x = CGRectGetMaxX(hotLabel.frame) + 3;
//            tipButton.y = hotLabel.y + i*(tipButton.y+hotTipH+1);
//            
//            tipButton.backgroundColor = [UIColor redColor];
//            [tipButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//            TopicTitle* titleModel = _topicList[i+1];
//            NSString* title = [NSString stringWithFormat:@"#%@#",titleModel.title];
//            
//            tipButton.tag = 1000+ [titleModel.ID integerValue];
//            
//            [tipButton setTitle:title forState:UIControlStateNormal];
//            tipButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//            tipButton.titleEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
//            [tipButton addTarget:self action:@selector(clickTipButton:) forControlEvents:UIControlEventTouchUpInside];
//            [hotBackView addSubview:tipButton];
//            //虚线
//            UIView* lineView =[[UIView alloc] init];
//            lineView.x = 0;
//            lineView.y = tipButton.height - 1;
//            lineView.width = kMainScreenWidth;
//            lineView.height = 1.0f;
//            [UIView drawDashLine:lineView lineLength:3.0f lineSpacing:3.0f lineColor:[UIColor grayColor]];
//            [tipButton addSubview:lineView];
//            if (_topicList.count - 1 == i) {
//                lineView.hidden = YES;
//            }
//
//        }
        
    }
    else {
        
        //hotLabel.height = hotTipH*(_topicList.count+1);
        
        for (int i = 0; i<_topicList.count; i++) {
            //话题内容
            if (!tipButton) {
                tipButton = [UIButton buttonWithType:UIButtonTypeCustom];
                tipButton.height = hotTipH;
                tipButton.width = kMainScreenWidth - CGRectGetMaxX(hotLabel.frame) - 3;
                tipButton.x = CGRectGetMaxX(hotLabel.frame) + 3;
                tipButton.y = hotLabel.y + i*(tipButton.y+hotTipH+1)+10;
//                tipButton.centerY = hotLabel.centerY;
                
//                tipButton.backgroundColor = [UIColor redColor];
                [tipButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                TopicTitle* titleModel = _topicList[i];
                NSString* title = [NSString stringWithFormat:@"#%@#",titleModel.title];
                
                tipButton.tag = 1000+ [titleModel.ID integerValue];
                
                [tipButton setTitle:title forState:UIControlStateNormal];
                tipButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                tipButton.titleEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
                [tipButton addTarget:self action:@selector(clickTipButton:) forControlEvents:UIControlEventTouchUpInside];
                [hotBackView addSubview:tipButton];
                //虚线
                UIView* lineView =[[UIView alloc] init];
                lineView.x = 0;
                lineView.y = tipButton.height - 1;
                lineView.width = kMainScreenWidth;
                lineView.height = 1.0f;
                [UIView drawDashLine:lineView lineLength:3.0f lineSpacing:3.0f lineColor:[UIColor grayColor]];
                [tipButton addSubview:lineView];
                if (_topicList.count - 1 == i) {
                    lineView.hidden = YES;
                }
            }
        }
        
    }
  
    return headerView;
}

#pragma mark - clickTopButton:
- (void)clickTipButton:(UIButton* )sender {
    MLOG(@"%@",sender);
    HotTopicViewController* vc = [[HotTopicViewController alloc] init];
    vc.userId = self.userId;
    vc.topic_id = [NSString stringWithFormat:@"%ld",sender.tag-1000];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[LYUserService sharedInstance] fetchLoginStateWithCompeletionBlock:^(UserLoginStateType type) {
        if (type == UserLoginStateTypeWaitToLogin) {
            [[LYUserService sharedInstance] jumpToLoginWithController:self.tabBarController];
        }
    }];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
        NSInteger index    = sender.tag - 100;
        FriendsCircleMessage *message = _messageArray[index];
        message.videoUrl = [message.videoUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        _currentVideoURL   = [NSURL URLWithString:[NSString stringWithFormat:@"%@", message.videoUrl]];
        _player            = nil;
        
        [self presentMoviePlayerViewControllerAnimated:self.player];
    } else { //如果有权限约束
        if ([[LYUserService sharedInstance].userDetail.isVip isEqualToString:@"1"]) {
            NSInteger index    = sender.tag - 100;
            FriendsCircleMessage *message = _messageArray[index];
            _currentVideoURL   = [NSURL URLWithString:[NSString stringWithFormat:@"%@", message.videoUrl]];
            _player            = nil;
            [self presentMoviePlayerViewControllerAnimated:self.player];
        } else {
            [[[UIAlertView alloc] initWithTitle:nil message:@"您还不是会员，将无法享受播放功能" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"成为会员", nil] show];
        }
    }
}

#pragma mark - 通知中心处理
//当视频做好准备时
- (void)videoDidFinishLaunch:(NSNotification *)aNotification {
    MLOG(@"视频准备好了");
}


#pragma mark 网络请求

- (void)getDataFromWeb {
    if (_isFriendsCircle) { //如果是朋友圈
        [[LYUserService sharedInstance] fetchLoginStateWithCompeletionBlock:^(UserLoginStateType type) {
            if (type == UserLoginStateTypeWaitToLogin) {
                myIcon       = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 80, SCREEN_WIDTH * 0.5 - 35, 70, 70)];
                myIcon.image = [UIImage imageNamed:@"默认头像"];

                myName           = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(myIcon.frame) - 100, kMainScreenWidth * 0.5 - 25, 100, 20)];
                myName.text      = @"用户_游客";
                myName.textColor = [UIColor whiteColor];
                //myName.backgroundColor =[UIColor redColor];
                //[self.tableView addSubview:myName];
                //                [bgImageView sd_setImageWithURL:_coverImag1eUrl placeholderImage:[UIImage imageNamed:@"封面"]];
                //游客身份
                //self.isFriendsCircle = YES;

                [headerView addSubview:myName];

            } else {
                [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/getDetailInfo", REQUESTHEADER] andParameter:@{ @"id": [NSString stringWithFormat:@"%@", [LYUserService sharedInstance].userID] } success:^(id successResponse) {
                    MLOG(@"获取用户资料 : %@", successResponse);
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
                        NSDictionary *infoDict       = successResponse[@"data"][@"user"];
                        self.myInfoModel             = [[MyInfoModel alloc] initWithDict:infoDict];
                        NSDictionary *detailInfoDict = successResponse[@"data"][@"userDetail"];
                        self.myDetailModel           = [[MyDetailInfoModel alloc] initWithDict:detailInfoDict];
                        [myIcon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", IMAGEHEADER, self.myInfoModel.icon]]];
                        myName.text = self.myInfoModel.name;
                        CGRect rect = [myName.text boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 100, 20) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:@{ NSFontAttributeName: myName.font } context:nil];

                        myName.frame = CGRectMake(CGRectGetMinX(myIcon.frame) - rect.size.width - 5, bgImageView.frame.size.height - 25, rect.size.width, 20);

                        NSString *urlString = @"";
                        if (successResponse[@"data"][@"user"][@"circle_cover"] && (![successResponse[@"data"][@"user"][@"circle_cover"] isEqualToString:@""]) && (![successResponse[@"data"][@"user"][@"circle_cover"] isEqualToString:@"<null>"])) {
                            urlString = [NSString stringWithFormat:@"%@", successResponse[@"data"][@"user"][@"circle_cover"]];
                            //更新到最新的封面图片URL
                            _coverImageUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", IMAGEHEADER, urlString]];
                        } else {
                            _coverImageUrl = nil;
                        }
                        [self.tableView reloadData];
                    } else {
                        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                        [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"msg"]]];
                    }
                }
                    andFailure:^(id failureResponse) {
                        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                        [MBProgressHUD showError:@"1服务器繁忙,请重试"];
                    }];
            }
        }];
    } else { //如果是个人动态
             //        [MBProgressHUD showMessage:nil toView:self.view];
        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/getDetailInfo", REQUESTHEADER] andParameter:@{ @"id": self.userId } success:^(id successResponse) {
            MLOG(@"结果:%@", successResponse);
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
                NSDictionary *infoDict       = successResponse[@"data"][@"user"];
                self.myInfoModel             = [[MyInfoModel alloc] initWithDict:infoDict];
                NSDictionary *detailInfoDict = successResponse[@"data"][@"userDetail"];
                self.myDetailModel           = [[MyDetailInfoModel alloc] initWithDict:detailInfoDict];
                [myIcon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", IMAGEHEADER, self.myInfoModel.icon]]];
                NSString *urlString = @"";
                if (successResponse[@"data"][@"user"][@"circle_cover"] && (![successResponse[@"data"][@"user"][@"circle_cover"] isEqualToString:@""]) && (![successResponse[@"data"][@"user"][@"circle_cover"] isEqualToString:@"<null>"])) {
                    urlString = [NSString stringWithFormat:@"%@", successResponse[@"data"][@"user"][@"circle_cover"]];
                    //更新到最新的封面图片URL
                    _coverImageUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", IMAGEHEADER, urlString]];
                } else {
                    _coverImageUrl = nil;
                }
                [self.tableView reloadData];
            } else {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"msg"]]];
            }
        }
            andFailure:^(id failureResponse) {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [MBProgressHUD showError:@"2服务器繁忙,请重试"];
            }];
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
            _inputView.frame = CGRectMake(0, SCREEN_HEIGHT - 64, SCREEN_WIDTH, 40 + kSingleContentHeight);
        } else {
            _inputView.frame = CGRectMake(0, SCREEN_HEIGHT - keyboardF.size.height - 54 - 64, SCREEN_WIDTH, 40 + kSingleContentHeight);
        }
    }];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {

    if (actionSheet.tag == 1000) {                          //点击换封面
        if (0 == buttonIndex) {                             //拍照
            if ([UIImagePickerController canTakePicture]) { //检查设备是否可以拍照
                UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
                imagePickerController.sourceType               = UIImagePickerControllerSourceTypeCamera;
                imagePickerController.mediaTypes               = [[NSArray alloc] initWithObjects:(NSString *) kUTTypeImage, nil];
                imagePickerController.allowsEditing            = YES;
                imagePickerController.delegate                 = self;
                [self presentViewController:imagePickerController animated:YES completion:nil];
            }
        } else if (1 == buttonIndex) { //手机相册
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.sourceType               = UIImagePickerControllerSourceTypePhotoLibrary;
            imagePickerController.mediaTypes               = [[NSArray alloc] initWithObjects:(NSString *) kUTTypeImage, nil];
            imagePickerController.allowsEditing            = YES;
            imagePickerController.delegate                 = self;
            [self presentViewController:imagePickerController animated:YES completion:nil];
        } else {
            //不做操作
        }
    } else {
        if (buttonIndex == 0) {
            //删除
            [self deleteMyComment];
        }
    }
}

#pragma mark uialertview代理

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        VipInfoViewController *info = [[VipInfoViewController alloc] init];
        [self.navigationController pushViewController:info animated:YES];
    }
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


#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *, id> *)info {
    if (isupdateVideo == YES) {
        //发布视频
        NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
        if ([mediaType isEqualToString:(NSString *) kUTTypeMovie]) { //如果是录制视频
            NSURL *url          = [info objectForKey:UIImagePickerControllerMediaURL];
            NSString *urlString = [url path];
            if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(urlString)) {
                //保存视频到相簿
                UISaveVideoAtPathToSavedPhotosAlbum(urlString, self, @selector(video:didFinishSavingWithError:contextInfo:), nil); //保存视频到相簿
            }
        }
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }
    else {
        //获取七牛Token
        [MBProgressHUD showMessage:@"更新封面中.."];
        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/getQiniuToken", REQUESTHEADER] andParameter:@{} success:^(id successResponse) {
            if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
                
                NSString *token = successResponse[@"data"][@"qiniuToken"];
                
                //获取当前时间
                NSDate *now                     = [NSDate date];
                NSCalendar *calendar            = [NSCalendar currentCalendar];
                NSUInteger unitFlags            = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
                NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
                NSInteger year                  = [dateComponent year];
                NSInteger month                 = [dateComponent month];
                NSInteger day                   = [dateComponent day];
                NSInteger hour                  = [dateComponent hour];
                NSInteger minute                = [dateComponent minute];
                NSInteger second                = [dateComponent second];
                
                NSString *locationString = [NSString stringWithFormat:@"iosLvYue_CircleCover_%@_%ld%ld%ld%ld%ld%ld", [LYUserService sharedInstance].userID, (long) year, (long) month, (long) day, (long) hour, (long) minute, (long) second];
                
                //压缩
                UIImage *editImage = info[UIImagePickerControllerEditedImage];
                NSData *savedData  = UIImageJPEGRepresentation(editImage, 0.3);
                
                //七牛上传图片
                QNUploadManager *upManager = [[QNUploadManager alloc] init];
                [upManager putData:savedData key:locationString token:token
                          complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                              MLOG(@"七牛返回内容 : info = \n%@ \n resp = \n%@", info, resp);
                              if (resp == nil) {
                                  [MBProgressHUD hideHUD];
                                  [MBProgressHUD showError:@"上传失败"];
                              } else { //如果七牛上传成功
                                  //同步服务器
                                  [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/updateNotice", REQUESTHEADER] andParameter:@{ @"token": token,
                                                                                                                                                                @"user_id": [LYUserService sharedInstance].userID,
                                                                                                                                                                @"circle_cover": locationString }
                                                              success:^(id successResponse) {
                                                                  if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
                                                                      [MBProgressHUD hideHUD];
                                                                      //弹出
                                                                      [self dismissViewControllerAnimated:YES completion:^{
                                                                          //重新请求/刷新
                                                                          [self getDataFromWeb];
                                                                      }];
                                                                  } else {
                                                                      [MBProgressHUD hideHUD];
                                                                      [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"msg"]]];
                                                                  }
                                                              }
                                                           andFailure:^(id failureResponse) {
                                                               [MBProgressHUD hideHUD];
                                                               [MBProgressHUD showError:@"3服务器繁忙,请重试"];
                                                           }];
                              }
                          }
                            option:nil];
                
            } else {
                [MBProgressHUD hideHUD];
                [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"msg"]]];
            }
        }
                                 andFailure:^(id failureResponse) {
                                     [MBProgressHUD hideHUD];
                                     [MBProgressHUD showError:@"4服务器繁忙,请重试"];
                                 }];
    }
    
    
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

//视频保存后的回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error) {
        NSLog(@"保存视频过程中发生错误，错误信息:%@", error.localizedDescription);
    } else {
        MLOG(@"视频保存成功.");
        //跳转到发布界面
        PublishVideoViewController *dest = [[PublishVideoViewController alloc] init];
        dest.videoPath                   = videoPath;
        [self.navigationController pushViewController:dest animated:YES];
        //恢复初始化
        isupdateVideo = NO;
    }
}


#pragma mark - Private
//点击选择封面
- (void)tapCoverImage:(UITapGestureRecognizer *)gesture {
    if ([LYUserService sharedInstance].userID) {
        UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"从相册中选择", nil];
        action.tag            = 1000;
        [action showInView:self.view];
    }
}


- (void)reloadFriendCircle:(NSNotification *)aNotification {
    [self.tableView.mj_header beginRefreshing];
}


@end
