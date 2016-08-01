//
//  VideoListViewController.m
//  LvYue
//
//  Created by Olive on 15/12/24.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import "JumpAnimationView.h"
#import "LYDetailDataViewController.h"
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "MBProgressHUD+NJ.h"
#import "MJRefresh.h"
#import "NSDate+Extension.h"
#import "PublishVideoViewController.h"
#import "UMSocial.h"
#import "VideoCategoryBar.h"
#import "VideoDetail.h"
#import "VideoListViewController.h"
#import "VideoPlayerCell.h"
#import "VipInfoViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>

#define kNavigationHiddenAnimationDuration 0.25f

@interface VideoListViewController () <VideoCategoryBarDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UMSocialUIDelegate, UIAlertViewDelegate> {
    CGFloat _startY;         //记录本次拖拽开始滑动的焦点的Y值
    CGFloat _endY;           //记录本次拖拽结束滑动的焦点的Y值
    BOOL _statusBarHidden;   //状态栏是否隐藏
    NSURL *_currentVideoURL; //当前准备要播放的视频的URL

    //分页
    NSInteger _currentPage; //当前页
}

/**** UI ****/
@property (nonatomic, strong) UIView *statusBarBGView;
@property (nonatomic, strong) UIView *navigationView;        //自定义导航栏
@property (nonatomic, strong) VideoCategoryBar *categoryBar; //分类栏
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *publishBtn;                 //发布视频按钮
@property (nonatomic, strong) JumpAnimationView *animationView;     //动画容器View
@property (nonatomic, strong) MPMoviePlayerViewController *player;  //视频播放器
@property (nonatomic, strong) UIImagePickerController *imagePicker; //摄像控制器

/** property **/
@property (nonatomic, strong) NSArray *categoryArray;     //视频分类 @{@"id",@"value"}
@property (nonatomic, copy) NSString *currentCategoryID;  //当前分类ID
@property (nonatomic, strong) NSMutableArray *videoArray; //视频模型数组

@end

@implementation VideoListViewController


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //self.navigationController.navigationBarHidden = YES;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = GRAYBG_COLOR;
    self.title                = @"视频圈";
    [self.view addSubview:self.statusBarBGView];
    [self.view addSubview:self.navigationView];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.animationView];
    [self addPullToRefresh];
    [self addAllNotifications];
    //init property
    self.videoArray = [NSMutableArray array];
    _currentPage    = 1;
    //http request
    [self loadCategorys];
}


- (void)addAllNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tapIntoUserDetail:) name:@"VideoCircle_TapUserIcon" object:nil];
}


- (void)addPullToRefresh {
    //下拉刷新
    __weak typeof(self) _weak_SELF = self;
    self.tableView.mj_header       = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _currentPage = 1;
        [_weak_SELF loadVideosWithType:nil showMB:YES];
    }];

    //上拉加载
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        _currentPage = _currentPage + 1;
        [_weak_SELF loadVideosWithType:nil showMB:YES];
    }];
}


- (UIView *)statusBarBGView {
    if (!_statusBarBGView) {
        _statusBarBGView                 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 20)];
        _statusBarBGView.backgroundColor = [UIColor colorWithRed:29 / 255.0 green:189 / 255.0 blue:159 / 255.0 alpha:1];
    }
    return _statusBarBGView;
}


- (UIView *)navigationView {
    if (!_navigationView) {
        //_navigationView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, kMainScreenWidth, 79)];
        _navigationView                 = [[UIView alloc] initWithFrame:CGRectMake(0, 20, kMainScreenWidth, 43)];
        _navigationView.backgroundColor = [UIColor colorWithRed:29 / 255.0 green:189 / 255.0 blue:159 / 255.0 alpha:1];
        //返回按钮
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [backBtn setFrame:CGRectMake(20, 0, 44, 44)];
        UIImageView *backIcon = [[UIImageView alloc] initWithFrame:CGRectMake(4, 14, 13, 20)];
        backIcon.image        = [UIImage imageNamed:@"back"];
        [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        [backBtn addSubview:backIcon];
        [_navigationView addSubview:backBtn];
        //标题
        UILabel *title      = [[UILabel alloc] initWithFrame:CGRectMake(_navigationView.center.x - 30, 0, 60, 44)];
        title.textAlignment = NSTextAlignmentCenter;
        title.text          = @"广场";
        title.textColor     = [UIColor whiteColor];
        title.font          = kFontBold18;
        [_navigationView addSubview:title];
        //边界线
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 43, kMainScreenWidth, 1)];
        [line setBackgroundColor:RGBACOLOR(233, 233, 233, 1.0)];
        [_navigationView addSubview:line];
        //分类栏

        [_navigationView addSubview:self.categoryBar];
    }
    return _navigationView;
}


- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}


- (VideoCategoryBar *)categoryBar {
    if (!_categoryBar) {
        _categoryBar          = [[VideoCategoryBar alloc] initWithItemTitles:@[@"平安夜", @"圣诞节", @"情人节", @"广场舞", @"莲花街"] andFrame:CGRectMake(0, 44, kMainScreenWidth, 35) unSelectedTitleColor:[UIColor blackColor] selectedTitleColor:RGBACOLOR(29, 189, 159, 1) lineColor:RGBACOLOR(29, 189, 159, 1)];
        _categoryBar.delegate = self;
        /**
         *  @author KF, 16-07-14 12:07:12
         *
         *  @brief 隐藏
         */
        _categoryBar.hidden = YES;
    }
    return _categoryBar;
}


- (UITableView *)tableView {
    if (!_tableView) {
        _tableView                                = [[UITableView alloc] initWithFrame:CGRectMake(0, 99, kMainScreenWidth, kMainScreenHeight - 99) style:UITableViewStyleGrouped];
        _tableView.backgroundColor                = [UIColor groupTableViewBackgroundColor];
        _tableView.delegate                       = self;
        _tableView.dataSource                     = self;
        _tableView.separatorStyle                 = UITableViewCellSeparatorStyleNone;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.showsVerticalScrollIndicator   = NO;
        UIView *bottomView                        = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 25)];
        [bottomView setBackgroundColor:[UIColor clearColor]];
        _tableView.tableFooterView = bottomView;
    }
    return _tableView;
}


- (JumpAnimationView *)animationView {
    if (!_animationView) {
        _animationView = [[JumpAnimationView alloc] init];
        [_animationView setCenter:CGPointMake(kMainScreenWidth / 2, kMainScreenHeight - 80)];
        [_animationView setBounds:CGRectMake(0, -25, 72, 75)];
        _animationView.layer.masksToBounds = YES;
        _animationView.backgroundColor     = [UIColor clearColor];
        //[_animationView addSubview:self.publishBtn];
    }
    return _animationView;
}


- (UIButton *)publishBtn {
    if (!_publishBtn) {
        _publishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_publishBtn setBackgroundImage:[UIImage imageNamed:@"拍"] forState:UIControlStateNormal];
        _publishBtn.frame                         = CGRectMake(0, -25, _animationView.bounds.size.width, _animationView.bounds.size.height);
        _publishBtn.imageView.contentMode         = UIViewContentModeScaleAspectFit;
        _publishBtn.imageView.layer.masksToBounds = YES;
        _publishBtn.alpha                         = 0.90;
        [_publishBtn addTarget:self action:@selector(publishVideo:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _publishBtn;
}


- (MPMoviePlayerViewController *)player {
    if (!_player) {
        _player                            = [[MPMoviePlayerViewController alloc] initWithContentURL:_currentVideoURL];
        _player.moviePlayer.shouldAutoplay = YES;
        [self addVideoNotifications];
    }
    return _player;
}


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


//添加视频监听通知
- (void)addVideoNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoDidFinishLaunch:) name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification object:_player.moviePlayer];
}


- (void)dealloc {
    _categoryBar.delegate   = nil;
    self.tableView.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - HTTP
- (void)loadCategorys {
    [MBProgressHUD showMessage:nil toView:self.view];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/video/videoType", REQUESTHEADER] andParameter:@{} success:^(id successResponse) {
        MLOG(@"全部视频分类 : %@", successResponse);
        if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            self.categoryArray     = successResponse[@"data"][@"data"];
            NSMutableArray *titles = [NSMutableArray array];
            for (NSDictionary *dict in self.categoryArray) {
                NSString *title = dict[@"value"];
                [titles addObject:title];
            }
            [self.categoryBar reloadItemTitles:titles];
            //默认刷新第一个分类的视频
            [self loadVideosWithType:self.categoryArray[0][@"id"] showMB:YES];
            _currentCategoryID = self.categoryArray[0][@"id"];
        } else {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [MBProgressHUD showError:@"视频加载失败"];
        }
    }
        andFailure:^(id failureResponse) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [MBProgressHUD showError:@"服务器繁忙,请稍后再试"];
        }];
}


//请求视频列表
- (void)loadVideosWithType:(NSString *)categoryID showMB:(BOOL)isShowMB {
    if (!categoryID) {
        categoryID = _currentCategoryID;
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:NO];
    if (isShowMB) {
        [MBProgressHUD showMessage:nil toView:self.view];
    }

    /**
     *  @author KF, 16-07-14 12:07:53
     *
     *  @brief 隐藏 @"type":categoryID,@"user_id":[LYUserService sharedInstance].userID
     */
    /*
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/video/list",REQUESTHEADER] andParameter:@{@"pageNum":[NSString stringWithFormat:@"%ld",(long)_currentPage],@"type":categoryID,@"user_id":[LYUserService sharedInstance].userID} success:^(id successResponse) {
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            MLOG(@"视频列表 : %@",successResponse);
            if (isShowMB) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            }
            NSArray *videos = successResponse[@"data"][@"data"][@"data"];
            NSArray *isPraiseByMeArray = successResponse[@"data"][@"data"][@"list"];
            if (videos.count == 0) {
                _currentPage --;
                [MBProgressHUD showError:@"已经到底咯~"];
            }
            if (!self.tableView.mj_footer.isRefreshing) {
                [self.videoArray removeAllObjects];
            }
            for (int i = 0;i < videos.count;i ++) {
                NSDictionary *videoDict = videos[i];
                NSDictionary *ispraiseDict = isPraiseByMeArray[i];
                NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:videoDict];
                [dict setObject:ispraiseDict[@"ispraise"] forKey:@"ispraise"];
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
            if (isShowMB) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [MBProgressHUD showError:@"视频加载失败"];
            }
        }
    } andFailure:^(id failureResponse) {
        if (self.tableView.mj_header.isRefreshing) {
            [self.tableView.mj_header endRefreshing];
        }
        if (self.tableView.mj_footer.isRefreshing) {
            [self.tableView.mj_footer endRefreshing];
        }
        if (isShowMB) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [MBProgressHUD showError:@"服务器繁忙,请稍后再试"];
        }
    }];*/

    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/auth_video_list", REQUESTHEADER] andParameter:@{ @"pageNum": [NSString stringWithFormat:@"%ld", (long) _currentPage],
    }
        success:^(id successResponse) {
            if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
                MLOG(@"视频列表 : %@", successResponse);
                if (isShowMB) {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                }
                NSArray *videos = successResponse[@"data"][@"data"][@"data"];
                for (NSDictionary *dict in videos) {
                    VideoDetail *video = [[VideoDetail alloc] initWithDict:dict];
                    [self.videoArray addObject:video];
                }

                //NSArray *isPraiseByMeArray = successResponse[@"data"][@"data"][@"list"];
                if (videos.count == 0) {
                    _currentPage--;
                    [MBProgressHUD showError:@"已经到底咯~"];
                }

                //            if (!self.tableView.mj_footer.isRefreshing) {
                //                [self.videoArray removeAllObjects];
                //            }
                /**
             *  @author KF, 16-07-14 15:07:21
             *
             *  @brief 点赞
             *
             *  @return <#return value description#>
             */
                //            for (int i = 0;i < videos.count;i ++) {
                //                NSDictionary *videoDict = videos[i];
                //                NSDictionary *ispraiseDict = isPraiseByMeArray[i];
                //                NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:videoDict];
                //                [dict setObject:ispraiseDict[@"ispraise"] forKey:@"ispraise"];
                //                VideoDetail *model = [[VideoDetail alloc] initWithDict:dict];
                //                [self.videoArray addObject:model];
                //            }
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
                if (isShowMB) {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    [MBProgressHUD showError:@"视频加载失败"];
                }
            }
        }
        andFailure:^(id failureResponse) {
            if (self.tableView.mj_header.isRefreshing) {
                [self.tableView.mj_header endRefreshing];
            }
            if (self.tableView.mj_footer.isRefreshing) {
                [self.tableView.mj_footer endRefreshing];
            }
            if (isShowMB) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [MBProgressHUD showError:@"服务器繁忙,请稍后再试"];
            }
        }];
}


#pragma mark - VideoCategoryBarDelegate
- (void)videoCategoryBar:(VideoCategoryBar *)categoryBar menuItemDidSelect:(UIButton *)item {
    //记录当前请求的视频类型
    _currentPage       = 1;
    _currentCategoryID = self.categoryArray[item.tag - 100][@"id"];
    [self loadVideosWithType:self.categoryArray[item.tag - 100][@"id"] showMB:YES];
}


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.videoArray.count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    VideoPlayerCell *cell = [VideoPlayerCell videoPlayerCellWithTableView:tableView indexPath:indexPath];
    [cell fillDataWithModel:self.videoArray[indexPath.section]];
    [cell.playBtn addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
    cell.playBtn.tag = 100 + indexPath.section;
    /**
     *  @author KF, 16-07-14 16:07:55
     *
     *  @brief 认证视频去掉点赞与分享
     */
    [cell.praiseBtn addTarget:self action:@selector(praiseOperation:) forControlEvents:UIControlEventTouchUpInside];
    cell.praiseBtn.tag = 100 + indexPath.section;
    [cell.shareBtn addTarget:self action:@selector(shareVideo:) forControlEvents:UIControlEventTouchUpInside];
    cell.shareBtn.tag = 100 + indexPath.section;
    return cell;
}


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.videoArray.count) {
        VideoDetail *model = self.videoArray[indexPath.section];
        CGFloat cellH      = [model getCellHeight];
        cellH              = cellH - 25;
        return cellH;
    } else {
        return 0.0;
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
            //            self.navigationView.frame = CGRectMake(0, -79, kMainScreenWidth, 79);
            self.navigationView.frame = CGRectMake(0, 20, kMainScreenWidth, 43);
            self.tableView.frame      = CGRectMake(0, 0, kMainScreenWidth - 0, kMainScreenHeight);
            _statusBarHidden          = YES;
            [self setNeedsStatusBarAppearanceUpdate];
        }];
        [UIView animateWithDuration:kNavigationHiddenAnimationDuration * 3 delay:0.0 usingSpringWithDamping:0.35 initialSpringVelocity:50 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
            //BOTTOM
            self.publishBtn.alpha    = 0.35;
            self.animationView.frame = CGRectMake(kMainScreenWidth / 2 - 18, kMainScreenHeight - 20, 36, 36);
            self.publishBtn.frame    = CGRectMake(0, 0, 36, 36);
        }
                         completion:nil];
    } else {
        [UIView animateWithDuration:kNavigationHiddenAnimationDuration animations:^{
            //TOP

            self.navigationView.alpha = 1.0;
            //self.navigationView.frame = CGRectMake(0, 20, kMainScreenWidth, 79);
            self.navigationView.frame = CGRectMake(0, 20, kMainScreenWidth, 43);
            self.tableView.frame      = CGRectMake(0, 99, kMainScreenWidth, kMainScreenHeight - 99);
            _statusBarHidden          = NO;
            [self setNeedsStatusBarAppearanceUpdate];
        }];
        [UIView animateWithDuration:kNavigationHiddenAnimationDuration * 3 delay:0.0 usingSpringWithDamping:0.35 initialSpringVelocity:50 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
            //BOTTOM
            self.publishBtn.alpha    = 0.90;
            self.animationView.frame = CGRectMake(kMainScreenWidth / 2 - 36, kMainScreenHeight - 88, 72, 75);
            self.publishBtn.frame    = CGRectMake(0, 0, 72, 75);
        }
                         completion:nil];
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
//点击发布视频按钮
- (void)publishVideo:(UIButton *)sender {
    if ([[LYUserService sharedInstance] canPublishVideo]) { //如果没有权限约束
        [self presentViewController:self.imagePicker animated:YES completion:nil];
        [[[UIAlertView alloc] initWithTitle:nil message:@"视频录制最长时间不能超过5分钟\n超过5分钟将自动结束录制" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil] show];
    } else { //如果有权限约束
        if ([[LYUserService sharedInstance].userDetail.isVip isEqualToString:@"1"]) {
            [self presentViewController:self.imagePicker animated:YES completion:nil];
            [[[UIAlertView alloc] initWithTitle:nil message:@"视频录制最长时间不能超过5分钟\n超过5分钟将自动结束录制" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil] show];
        } else {
            [[[UIAlertView alloc] initWithTitle:nil message:@"您还不是会员，将无法享受发布功能" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"成为会员", nil] show];
        }
    }
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
        VideoDetail *model = self.videoArray[index];
        _currentVideoURL   = [NSURL URLWithString:[NSString stringWithFormat:@"%@", model.url]];
        _player            = nil;
        [self presentMoviePlayerViewControllerAnimated:self.player];
    } else { //如果有权限约束
        if ([[LYUserService sharedInstance].userDetail.isVip isEqualToString:@"1"]) {
            NSInteger index    = sender.tag - 100;
            VideoDetail *model = self.videoArray[index];
            _currentVideoURL   = [NSURL URLWithString:[NSString stringWithFormat:@"%@", model.url]];
            _player            = nil;
            [self presentMoviePlayerViewControllerAnimated:self.player];
        } else {
            [[[UIAlertView alloc] initWithTitle:nil message:@"您还不是会员，将无法享受播放功能" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"成为会员", nil] show];
        }
    }
}

//点赞按钮
- (void)praiseOperation:(UIButton *)sender {
    NSInteger index    = sender.tag - 100;
    VideoDetail *model = self.videoArray[index];
    if ([model.owner.userID isEqualToString:[LYUserService sharedInstance].userID]) {
        [MBProgressHUD showError:@"不能对自己点赞"];
        return;
    }
    sender.enabled = NO;
    if ([model.isPraiseByMe isEqualToString:@"1"]) {
        //取消赞
        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/video/cancelPraise", REQUESTHEADER] andParameter:@{ @"videoId": model.videoID,@"praiseId": [LYUserService sharedInstance].userID }
            success:^(id successResponse) {
                MLOG(@"取消点赞结果 : %@", successResponse);
                sender.enabled = YES;
                if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
                    [self loadVideosWithType:_currentCategoryID showMB:NO];
                } else {
                    [MBProgressHUD showError:successResponse[@"msg"]];
                }
            }
            andFailure:^(id failureResponse) {
            sender.enabled = YES;
            [MBProgressHUD showError:@"服务器繁忙,请稍候重试"];
        }];
    }
    else {
        //点赞
        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/video/praise", REQUESTHEADER] andParameter:@{ @"videoId": model.videoID,
                                                                                                                                 @"praiser": [LYUserService sharedInstance].userID }
            success:^(id successResponse) {
                MLOG(@"点赞结果 : %@", successResponse);
                sender.enabled = YES;
                if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
                    [self loadVideosWithType:_currentCategoryID showMB:NO];
                } else {
                    [MBProgressHUD showError:successResponse[@"msg"]];
                }
            }
            andFailure:^(id failureResponse) {
                sender.enabled = YES;
                [MBProgressHUD showError:@"服务器繁忙,请稍候重试"];
            }];
    }
}


//分享视频
- (void)shareVideo:(UIButton *)sender {
    if ([[LYUserService sharedInstance] canPlayVideo]) { //如果没有权限约束
        NSInteger index    = sender.tag - 100;
        VideoDetail *model = self.videoArray[index];
        NSString *videoID  = model.videoID;
        [self shareWithVideoID:videoID];
    } else { //如果有权限约束
        if ([[LYUserService sharedInstance].userDetail.isVip isEqualToString:@"1"]) {
            NSInteger index    = sender.tag - 100;
            VideoDetail *model = self.videoArray[index];
            NSString *videoID  = model.videoID;
            [self shareWithVideoID:videoID];
        } else {
            [[[UIAlertView alloc] initWithTitle:nil message:@"您还不是会员，将无法享受分享功能" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"成为会员", nil] show];
        }
    }
}


- (void)shareWithVideoID:(NSString *)videoID {
    //设置微信
    [UMSocialData defaultData].extConfig.wechatSessionData.title  = @"我分享了一段视频";
    [UMSocialData defaultData].extConfig.wechatTimelineData.title = @"我分享了一段视频";
    [UMSocialData defaultData].extConfig.wechatSessionData.url    = [NSString stringWithFormat:@"%@/assets/shared?videoID=%@", REQUESTHEADER, videoID];
    [UMSocialData defaultData].extConfig.wechatTimelineData.url   = [NSString stringWithFormat:@"%@/assets/shared?videoID=%@", REQUESTHEADER, videoID];

    //设置新浪微博
    [[UMSocialData defaultData].urlResource setResourceType:UMSocialUrlResourceTypeImage url:[NSString stringWithFormat:@"%@/assets/shared?videoID=%@", REQUESTHEADER, videoID]];


    //设置QQ
    [UMSocialData defaultData].extConfig.qqData.title    = @"我分享了一段视频";
    [UMSocialData defaultData].extConfig.qzoneData.title = @"我分享了一段视频";
    [UMSocialData defaultData].extConfig.qqData.url      = [NSString stringWithFormat:@"%@/assets/shared?videoID=%@", REQUESTHEADER, videoID];
    [UMSocialData defaultData].extConfig.qzoneData.url   = [NSString stringWithFormat:@"%@/assets/shared?videoID=%@", REQUESTHEADER, videoID];

    //分享
    [UMSocialSnsService presentSnsIconSheetView:self appKey:@"55f3983c67e58e502a00167d" shareText:@"我分享了一段视频，快来看看吧~\n\n——尽在\"豆客\"APP" shareImage:[UIImage imageNamed:@"logo108"] shareToSnsNames:[NSArray arrayWithObjects:UMShareToWechatTimeline, UMShareToWechatSession, UMShareToSina, UMShareToQQ, UMShareToQzone, nil] delegate:self];
}


#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *, id> *)info {
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


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}


//视频保存后的回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        NSLog(@"保存视频过程中发生错误，错误信息:%@", error.localizedDescription);
    } else {
        NSLog(@"视频保存成功.");
        //跳转到发布界面
        PublishVideoViewController *dest = [[PublishVideoViewController alloc] init];
        dest.videoPath                   = videoPath;
        [self.navigationController pushViewController:dest animated:YES];
    }
}


#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        //跳转到成为会员界面
        VipInfoViewController *dest = [[VipInfoViewController alloc] init];
        [self.navigationController pushViewController:dest animated:YES];
    }
}


#pragma mark - 通知中心处理
//当视频做好准备时
- (void)videoDidFinishLaunch:(NSNotification *)aNotification {
    MLOG(@"视频准备好了");
}


//点击用户头像
- (void)tapIntoUserDetail:(NSNotification *)aNotification {
    NSIndexPath *indexPath           = [aNotification userInfo][@"indexPath"];
    VideoDetail *model               = self.videoArray[indexPath.section];
    LYDetailDataViewController *dest = [[LYDetailDataViewController alloc] init];
    dest.userId                      = model.owner.userID;
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
