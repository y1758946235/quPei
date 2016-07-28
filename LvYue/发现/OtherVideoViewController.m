//
//  VideoListViewController.m
//  LvYue
//
//  Created by Olive on 15/12/24.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import "OtherVideoViewController.h"
#import "NSDate+Extension.h"
#import "OtherVideoPlayerCell.h"
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "MBProgressHUD+NJ.h"
#import "VideoDetail.h"
#import "MJRefresh.h"
#import "DetailDataViewController.h"
#import "UMSocial.h"

#define kNavigationHiddenAnimationDuration 0.25f

@interface OtherVideoViewController () <UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UMSocialUIDelegate> {
    CGFloat _startY; //记录本次拖拽开始滑动的焦点的Y值
    CGFloat _endY; //记录本次拖拽结束滑动的焦点的Y值
    BOOL _statusBarHidden; //状态栏是否隐藏
    NSURL *_currentVideoURL; //当前准备要播放的视频的URL
    
    //分页
    NSInteger _currentPage; //当前页
}

/**** UI ****/
@property (nonatomic, strong) UIView *statusBarBGView;
@property (nonatomic, strong) UIView *navigationView; //自定义导航栏
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) MPMoviePlayerViewController *player; //视频播放器

/** property **/
@property (nonatomic, strong) NSMutableArray *videoArray; //视频模型数组

@end

@implementation OtherVideoViewController


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.view addSubview:self.statusBarBGView];
    [self.view addSubview:self.navigationView];
    [self.view addSubview:self.tableView];
    [self addPullToRefresh];
    [self addAllNotifications];
    //init property
    self.videoArray = [NSMutableArray array];
    _currentPage = 1;
    //http request
    [self loadVideos];
}


- (void)addAllNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tapIntoUserDetail:) name:@"VideoCircle_TapUserIcon_Other" object:nil];
}



- (void)dealloc {
    self.tableView.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



- (void)addPullToRefresh {
    //下拉刷新
    __weak typeof(self) _weak_SELF = self;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _currentPage = 1;
        [_weak_SELF loadVideos];
    }];

    //上拉加载
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        _currentPage = _currentPage + 1;
        [_weak_SELF loadVideos];
    }];
}



- (UIView *)statusBarBGView {
    if (!_statusBarBGView) {
        _statusBarBGView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 20)];
        _statusBarBGView.backgroundColor = [UIColor colorWithRed:29/255.0 green:189/255.0 blue:159/255.0 alpha:1];
    }
    return _statusBarBGView;
}


- (UIView *)navigationView {
    if (!_navigationView) {
        _navigationView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, kMainScreenWidth, 44)];
        _navigationView.backgroundColor = [UIColor colorWithRed:29/255.0 green:189/255.0 blue:159/255.0 alpha:1];
        //返回按钮
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [backBtn setFrame:CGRectMake(20, 0, 44, 44)];
        UIImageView *backIcon = [[UIImageView alloc] initWithFrame:CGRectMake(10, 11, 15, 22)];
        backIcon.image = [UIImage imageNamed:@"back"];
        [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        [backBtn addSubview:backIcon];
        [_navigationView addSubview:backBtn];
        //标题
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(_navigationView.center.x - 80, 0, 160, 44)];
        title.textAlignment = NSTextAlignmentCenter;
        title.textColor = [UIColor whiteColor];
        title.font = kFontBold17;
        title.text = self.navTitle;
        [_navigationView addSubview:title];
        //边界线
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 43, kMainScreenWidth, 1)];
        [line setBackgroundColor:RGBACOLOR(233, 233, 233, 1.0)];
        [_navigationView addSubview:line];
    }
    return _navigationView;
}


- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}


- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, kMainScreenWidth, kMainScreenHeight - 64) style:UITableViewStyleGrouped];
        _tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.showsVerticalScrollIndicator = NO;
    }
    return _tableView;
}


- (MPMoviePlayerViewController *)player {
    if (!_player) {
        _player = [[MPMoviePlayerViewController alloc] initWithContentURL:_currentVideoURL];
        _player.moviePlayer.shouldAutoplay = YES;
        [self addVideoNotifications];
    }
    return _player;
}


//添加视频监听通知
- (void)addVideoNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoDidFinishLaunch:) name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification object:_player.moviePlayer];
}



#pragma mark - HTTP
//请求视频列表
- (void)loadVideos {
    [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
    [MBProgressHUD showMessage:nil toView:self.view];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/video/userList",REQUESTHEADER] andParameter:@{@"pageNum":[NSString stringWithFormat:@"%ld",(long)_currentPage],@"user_id":self.userID} success:^(id successResponse) {
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            MLOG(@"TA 的 视频列表 : %@",successResponse);
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSArray *videos = successResponse[@"data"][@"data"];
            if (videos.count == 0) {
                _currentPage --;
                if (self.videoArray.count == 0) {
                    if ([self.userID isEqualToString:[LYUserService sharedInstance].userID]) {
                        [MBProgressHUD showError:@"您还没有上传视频，赶紧去上传吧"];
                    }
                    else{
                        [MBProgressHUD showError:@"TA还没有上传视频，去邀请TA吧"];
                    }
                }else {
                    [MBProgressHUD showError:@"已经到底咯~"];
                }
            }
            if (!self.tableView.mj_footer.isRefreshing) {
                [self.videoArray removeAllObjects];
            }
            for (NSDictionary *dict in videos) {
                VideoDetail *model = [[VideoDetail alloc] initWithDict:dict];
                [self.videoArray addObject:model];
            }
            [self.tableView reloadData];
            if (self.tableView.mj_header.isRefreshing) {
                [self.tableView.mj_header endRefreshing];
            }
            if (self.tableView.mj_footer.isRefreshing) {
                [self.tableView.mj_footer endRefreshing];
            }
        } else {
            if (self.tableView.mj_header.isRefreshing) {
                [self.tableView.mj_header endRefreshing];
            }
            if (self.tableView.mj_footer.isRefreshing) {
                [self.tableView.mj_footer endRefreshing];
            }
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [MBProgressHUD showError:@"视频加载失败"];
        }
    } andFailure:^(id failureResponse) {
        if (self.tableView.mj_header.isRefreshing) {
            [self.tableView.mj_header endRefreshing];
        }
        if (self.tableView.mj_footer.isRefreshing) {
            [self.tableView.mj_footer endRefreshing];
        }
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [MBProgressHUD showError:@"服务器繁忙,请稍后再试"];
    }];
}



#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.videoArray.count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OtherVideoPlayerCell *cell = [OtherVideoPlayerCell otherVideoPlayerCellWithTableView:tableView indexPath:indexPath];
    [cell fillDataWithModel:self.videoArray[indexPath.section]];
    //播放按钮
    [cell.playBtn addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
    cell.playBtn.tag = 100 + indexPath.section;
    //删除按钮(仅"我的视频"内可见)
    [cell.deleteBtn addTarget:self action:@selector(deleteVideo:) forControlEvents:UIControlEventTouchUpInside];
    cell.deleteBtn.tag = 100 + indexPath.section;
    //分享
    [cell.shareBtn addTarget:self action:@selector(shareVideo:) forControlEvents:UIControlEventTouchUpInside];
    cell.shareBtn.tag = 100 + indexPath.section;
    return cell;
}


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.videoArray.count) {
        VideoDetail *model = self.videoArray[indexPath.section];
        return [model getCellHeight];
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10.0f;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 10.0)];
    [header setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    return header;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat y = scrollView.contentOffset.y;
    if (y >= scrollView.contentSize.height - kMainScreenHeight) {
        return;
    }
    CGFloat offSet_Y = y - _startY;
    if (offSet_Y > 0) {
        [UIView animateWithDuration:kNavigationHiddenAnimationDuration animations:^{
            //TOP
            self.navigationView.alpha = 0.0;
            self.navigationView.frame = CGRectMake(0, -44, kMainScreenWidth, 44);
            self.tableView.frame = CGRectMake(0, 0, kMainScreenWidth - 0, kMainScreenHeight);
            _statusBarHidden = YES;
            [self setNeedsStatusBarAppearanceUpdate];
        }];
    } else {
        [UIView animateWithDuration:kNavigationHiddenAnimationDuration animations:^{
            //TOP
            self.navigationView.alpha = 1.0;
            self.navigationView.frame = CGRectMake(0, 20, kMainScreenWidth, 44);
            self.tableView.frame = CGRectMake(0, 64, kMainScreenWidth, kMainScreenHeight - 64);
            _statusBarHidden = NO;
            [self setNeedsStatusBarAppearanceUpdate];
        }];
    }
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _startY = scrollView.contentOffset.y;
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    _endY = scrollView.contentOffset.y;
}



#pragma mark - StateBar
- (BOOL)prefersStatusBarHidden {
    return _statusBarHidden;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}


#pragma mark - Private
//点击播放按钮
- (void)playVideo:(UIButton *)sender {
    NSInteger index = sender.tag - 100;
    VideoDetail *model = self.videoArray[index];
    _currentVideoURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",model.url]];
    _player = nil;
    [self presentMoviePlayerViewControllerAnimated:self.player];
}


//点击删除按钮时
- (void)deleteVideo:(UIButton *)sender {
    NSInteger index = sender.tag - 100;
    VideoDetail *model = self.videoArray[index];
    [MBProgressHUD showMessage:nil toView:self.view];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/video/delete",REQUESTHEADER] andParameter:@{@"user_id":[LYUserService sharedInstance].userID,@"id":model.videoID} success:^(id successResponse) {
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self.videoArray removeObject:model];
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:UITableViewRowAnimationRight];
            [self.tableView reloadData];
        } else {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [MBProgressHUD showError:@"删除失败"];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [MBProgressHUD showError:@"服务器异常，请稍后再试"];
    }];
}


//分享视频
- (void)shareVideo:(UIButton *)sender {
    if ([[LYUserService sharedInstance] canPlayVideo]) { //如果没有权限约束
        NSInteger index = sender.tag - 100;
        VideoDetail *model = self.videoArray[index];
        NSString *videoID = model.videoID;
        [self shareWithVideoID:videoID];
    } else { //如果有权限约束
        if ([[LYUserService sharedInstance].userDetail.isVip isEqualToString:@"1"]) {
            NSInteger index = sender.tag - 100;
            VideoDetail *model = self.videoArray[index];
            NSString *videoID = model.videoID;
            [self shareWithVideoID:videoID];
        } else {
            [[[UIAlertView alloc] initWithTitle:nil message:@"您还不是会员，将无法享受分享功能" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"成为会员", nil] show];
        }
    }
}


- (void)shareWithVideoID:(NSString *)videoID {
    //设置微信
    [UMSocialData defaultData].extConfig.wechatSessionData.title = @"我分享了一段视频";
    [UMSocialData defaultData].extConfig.wechatTimelineData.title = @"我分享了一段视频";
    [UMSocialData defaultData].extConfig.wechatSessionData.url = [NSString stringWithFormat:@"%@/assets/video_code?videoID=%@",REQUESTHEADER,videoID];
    [UMSocialData defaultData].extConfig.wechatTimelineData.url = [NSString stringWithFormat:@"%@/assets/video_code?videoID=%@",REQUESTHEADER,videoID];
    
    //设置新浪微博
    [[UMSocialData defaultData].urlResource setResourceType:UMSocialUrlResourceTypeImage url:[NSString stringWithFormat:@"%@/assets/video_code?videoID=%@",REQUESTHEADER,videoID]];
    
    
    //设置QQ
    [UMSocialData defaultData].extConfig.qqData.title = @"我分享了一段视频";
    [UMSocialData defaultData].extConfig.qzoneData.title = @"我分享了一段视频";
    [UMSocialData defaultData].extConfig.qqData.url = [NSString stringWithFormat:@"%@/assets/video_code?videoID=%@",REQUESTHEADER,videoID];
    [UMSocialData defaultData].extConfig.qzoneData.url = [NSString stringWithFormat:@"%@/assets/video_code?videoID=%@",REQUESTHEADER,videoID];
    
    //分享
    [UMSocialSnsService presentSnsIconSheetView:self appKey:@"55f3983c67e58e502a00167d" shareText:@"我分享了一段视频，快来看看吧~\n\n——尽在\"豆客\"APP" shareImage:[UIImage imageNamed:@"logo108"] shareToSnsNames:[NSArray arrayWithObjects:UMShareToWechatTimeline,UMShareToWechatSession,UMShareToSina,UMShareToQQ,UMShareToQzone,nil] delegate:self];
}



#pragma mark - 通知中心处理
//当视频做好准备时
- (void)videoDidFinishLaunch:(NSNotification *)aNotification {
    MLOG(@"视频准备好了");
}


//点击用户头像时
- (void)tapIntoUserDetail:(NSNotification *)aNotification {
    NSIndexPath *indexPath = [aNotification userInfo][@"indexPath"];
    VideoDetail *model = self.videoArray[indexPath.section];
    NSInteger userID = [model.owner.userID integerValue];
    DetailDataViewController *dest = [[DetailDataViewController alloc] init];
    dest.friendId = userID;
    [self.navigationController pushViewController:dest animated:YES];
}



#pragma mark - UMSocialUIDelegate
//弹出列表方法presentSnsIconSheetView需要设置delegate为self
//点击每个平台后默认会进入内容编辑页面，若想点击后直接分享内容，可以实现下面的回调方法,return YES
- (BOOL)isDirectShareInIconActionSheet {
    
    //NO为不会直接分享
    return NO;
}


//分享成功回调方法
- (void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response {
    
    //根据responseCode得到发送结果,如果分享成功
    if (response.responseCode == UMSResponseCodeSuccess) {
        
        [MBProgressHUD showSuccess:@"分享成功"];
    } else {
        //以下代码能帮助在控制器台看到错误码
        [UMSocialData openLog:YES];
        
        [MBProgressHUD showError:@"分享失败"];
    }
}


@end
