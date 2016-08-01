//
//  OriginalViewController.m
//  LvYue
//
//  Created by 郑洲 on 16/3/16.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "MBProgressHUD+NJ.h"
#import "OriginalView.h"
#import "OriginalViewController.h"
#import "UIImageView+WebCache.h"

@interface OriginalViewController () <UIActionSheetDelegate> {
    OriginalView *_leftView;
    OriginalView *_centerView;
    OriginalView *_rightView;

    NSInteger _index;
    BOOL _isDouble; //是否双击

    UIButton *backBtn;
    UIActionSheet *actionSheet;
}

@end

@implementation OriginalViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self addScrollView];

    backBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 30, 25, 27)];
    [backBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];

    //    [self addThreePhotoView];
    [self addPhotoViews];
}

//添加scrollView大背景
- (void)addScrollView {

    //添加背景
    _scrollView                 = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    _scrollView.backgroundColor = [UIColor blackColor];
    _scrollView.delegate        = self;
    //    _scrollView.contentSize = CGSizeMake(SCREEN_WIDTH * 3, SCREEN_HEIGHT);
    //    //设置当前显示的位置为中间图片
    //    _scrollView.contentOffset = CGPointMake(SCREEN_WIDTH, 0);
    _scrollView.contentSize = CGSizeMake(SCREEN_WIDTH * _imageData.count, SCREEN_HEIGHT);
    //隐藏滚动条
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator   = NO;

    _scrollView.pagingEnabled = YES;
    [self.view addSubview:_scrollView];
}

//在scrollView中添加3个图片
- (void)addThreePhotoView {

    _leftView             = [[OriginalView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    _leftView.contentMode = UIViewContentModeScaleAspectFit;
    [_scrollView addSubview:_leftView];

    _centerView             = [[OriginalView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    _centerView.contentMode = UIViewContentModeScaleAspectFit;
    [_scrollView addSubview:_centerView];

    _rightView             = [[OriginalView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH * 2, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    _rightView.contentMode = UIViewContentModeScaleAspectFit;
    [_scrollView addSubview:_rightView];


    //退出大图，单击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    [_centerView addGestureRecognizer:tap];

    //放大缩小，形变 双击手势
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    [doubleTap setNumberOfTapsRequired:2];
    [_centerView addGestureRecognizer:doubleTap];

    //长按手势
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [_centerView addGestureRecognizer:longPress];
}

- (void)addPhotoViews {

    for (int i = 0; i < _imageData.count; i++) {

        OriginalView *photoView = [[OriginalView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH * i, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        photoView.tag           = i + 100;
        [_scrollView addSubview:photoView];

        //退出大图，单击手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        [photoView addGestureRecognizer:tap];

        //放大缩小，形变 双击手势
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        [doubleTap setNumberOfTapsRequired:2];
        [photoView addGestureRecognizer:doubleTap];

        //长按手势
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        [photoView addGestureRecognizer:longPress];
    }
}


- (void)longPress:(UILongPressGestureRecognizer *)longPress {
    if (!actionSheet) {
        if ([_userId isEqualToString:[LYUserService sharedInstance].userID]) {
            actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"保存", @"设为封面", @"删除", nil];
        } else {
            actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"保存", nil];
        }

        [actionSheet showFromTabBar:self.tabBarController.tabBar];
    }
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

//单击手势 退出大图
- (void)singleTap:(UITapGestureRecognizer *)tap {

    _isDouble = NO;
    //通过延时来让系统判断是否为双击
    OriginalView *photoView = [_scrollView viewWithTag:(100 + _index)];
    if (photoView.zoomScale == photoView.maximumZoomScale) {

    } else {
        [self performSelector:@selector(hidden) withObject:nil afterDelay:0.3f];
    }
}

//双击手势 缩放大图
- (void)doubleTap:(UITapGestureRecognizer *)tap {

    _isDouble = YES;
    NSLog(@"双击");

    for (int i = 0; i < _imageData.count; i++) {
        OriginalView *photoView = [_scrollView viewWithTag:(100 + i)];
        if (photoView.timeLabel.alpha == 1) {
            photoView.timeLabel.alpha = 0.0;
            photoView.markLabel.alpha = 0.0;
            photoView.blackView.alpha = 0.0;
            backBtn.alpha             = photoView.blackView.alpha;
        }
    }

    //    if (_centerView.zoomScale == _centerView.maximumZoomScale) {
    //
    //        [_centerView setZoomScale:1.0f animated:YES];
    //    }else{
    //        //否则从手势触摸点开始放大1倍
    //        CGPoint location = [tap locationInView:_centerView];
    //        [UIView animateWithDuration:0.3f animations:^{
    //            //从某点开始放大
    //            [_centerView zoomToRect:CGRectMake(location.x, location.y, 1, 1) animated:YES];
    //        }];
    //    }
    OriginalView *photoView = (OriginalView *) tap.view;
    if (photoView.zoomScale == photoView.maximumZoomScale) {

        [photoView setZoomScale:1.0f animated:YES];
    } else {

        //否则从手势触摸点开始放大1倍
        CGPoint location = [tap locationInView:photoView];
        [UIView animateWithDuration:0.3f animations:^{
            //从某点开始放大
            [photoView zoomToRect:CGRectMake(location.x, location.y, 1, 1) animated:YES];
        }];
    }
}


//隐藏图片
- (void)hidden {

    if (_isDouble) {
        return;
    }
    for (int i = 0; i < _imageData.count; i++) {
        OriginalView *photoView = [_scrollView viewWithTag:(100 + i)];
        if (photoView.timeLabel.alpha == 0) {
            [UIView animateWithDuration:0.3 animations:^{
                photoView.timeLabel.alpha = 1.0;
                photoView.markLabel.alpha = 1.0;
                photoView.blackView.alpha = 1.0;
                backBtn.alpha             = photoView.blackView.alpha;
            }];
        } else {
            [UIView animateWithDuration:0.3 animations:^{
                photoView.timeLabel.alpha = 0.0;
                photoView.markLabel.alpha = 0.0;
                photoView.blackView.alpha = 0.0;
                backBtn.alpha             = photoView.blackView.alpha;
            }];
        }
    }
    NSLog(@"单击");
}

- (void)back {
    self.view.backgroundColor = [UIColor clearColor];
    [UIView animateWithDuration:0.5 animations:^{

        self.view.alpha = 0;
    }
        completion:^(BOOL finished) {

            //1）清除根视图
            [self.view removeFromSuperview];
            //2) 清除子视图控制器
            [self removeFromParentViewController];
        }];
}

/**
 *  展示照片
 *
 *  @param index 当前点击的照片索引
 *  @param count 所有照片数量
 */
- (void)showImageWithIndex:(NSInteger)index andCount:(NSInteger)count {

    _index = index;
    [self addPageControllerWithIndex:index andCount:count];
    //    [self loadImageWithIndex:index];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self.view];
    //记录住视图控制器
    [window.rootViewController addChildViewController:self];
}

//添加分页控制器
- (void)addPageControllerWithIndex:(NSInteger)index andCount:(NSInteger)count {

    _pageController = [[UIPageControl alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 200) / 2, SCREEN_HEIGHT - 50, 200, 20)];
    //所有页数
    _pageController.numberOfPages = count;
    //当前页数
    _pageController.currentPage = index;
    _pageController.hidden      = YES;
    [self.view addSubview:_pageController];

    //加载当前图片
    [self loadImageWithIndex:index];
}

/**
 *  加载图片
 *
 *  @param index 当前图片索引
 */
- (void)loadImageWithIndex:(NSInteger)index {

    OriginalView *photoView = [_scrollView viewWithTag:(100 + index)];
    if ([NSURL URLWithString:[NSString stringWithFormat:@"%@%@", IMAGEHEADER, _imageData[index % _imageData.count][@"img_name"]]]) {
        __block UIActivityIndicatorView *activityIndicator;

        [photoView.imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", IMAGEHEADER, _imageData[index % _imageData.count][@"img_name"]]] placeholderImage:_smallImage[index % _smallImage.count] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            if (!activityIndicator) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [photoView.imageView addSubview:activityIndicator = [UIActivityIndicatorView.alloc initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge]];
                    activityIndicator.frame              = CGRectMake(0, 0, 100, 100);
                    activityIndicator.layer.cornerRadius = 15.0;
                    activityIndicator.center             = photoView.imageView.center;
                    [activityIndicator setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.7]];
                    [activityIndicator startAnimating];
                });
            }
        }
            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                [activityIndicator removeFromSuperview];
                activityIndicator = nil;
            }];
    }

    photoView.timeLabel.text = [NSString stringWithFormat:@"%@", _imageData[index % _imageData.count][@"createtime"]];

    if (_imageData[index % _imageData.count][@"intro"] && [_imageData[index % _imageData.count][@"intro"] length] > 0) {
        photoView.markLabel.text = [NSString stringWithFormat:@" %@", _imageData[index % _imageData.count][@"intro"]];
    }

    [_scrollView setContentOffset:CGPointMake(SCREEN_WIDTH * index, 0)];

    //    [_leftView.imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,_imageData[(index-1)%_imageData.count][@"img_name"]]] placeholderImage:[UIImage imageNamed:@"加载失败" ] options:SDWebImageRetryFailed];
    //    _leftView.timeLabel.text = _imageData[(index-1)%_imageData.count][@"createtime"];
    //    _leftView.markLabel.text = _imageData[(index-1)%_imageData.count][@"intro"];
    //
    //    [_rightView.imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,_imageData[(index+1)%_imageData.count][@"img_name"]]] placeholderImage:[UIImage imageNamed:@"加载失败" ] options:SDWebImageRetryFailed];
    //    _rightView.timeLabel.text = _imageData[(index+1)%_imageData.count][@"createtime"];
    //    _rightView.markLabel.text = _imageData[(index+1)%_imageData.count][@"intro"];
    //
    //    [_centerView.imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,_imageData[index%_imageData.count][@"img_name"]]] placeholderImage:[UIImage imageNamed:@"加载失败" ] options:SDWebImageRetryFailed];
    //    _centerView.timeLabel.text = _imageData[index%_imageData.count][@"createtime"];
    //    _centerView.markLabel.text = _imageData[index%_imageData.count][@"intro"];
}


#pragma mark - UIScrollViewDelegate
//滚动停止事件
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {

    if (scrollView == _scrollView) {
        CGPoint offset = [_scrollView contentOffset];
        //        if (offset.x < SCREEN_WIDTH) {
        //            //左移
        //            //还原形变倍数
        //            [_centerView setZoomScale:1.0f animated:NO];
        //            _index -= 1;
        //        }else if (offset.x > SCREEN_WIDTH){
        //            //右移
        //            //还原形变倍数
        //            [_centerView setZoomScale:1.0f animated:NO];
        //            _index += 1;
        //        }
        //
        //        [self loadImageWithIndex:_index];
        //        [_scrollView setContentOffset:CGPointMake(SCREEN_WIDTH, 0) animated:NO];
        //        //设置当前页
        //        _pageController.currentPage = _index%_imageData.count;
        _index = offset.x / SCREEN_WIDTH;
        [self loadImageWithIndex:_index];
        //设置当前页
        _pageController.currentPage = _index;
        OriginalView *photoView     = [_scrollView viewWithTag:(100 + _index)];
        backBtn.alpha               = photoView.blackView.alpha;
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        OriginalView *photoView = [_scrollView viewWithTag:(100 + _index)];
        UIImage *image          = photoView.imageView.image;
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    } else if (buttonIndex == 1 && [_userId isEqualToString:[LYUserService sharedInstance].userID]) {
        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/setCover", REQUESTHEADER] andParameter:@{ @"id": [NSString stringWithFormat:@"%@", _imageData[_index][@"id"]],
                                                                                                                                  @"user_id": [LYUserService sharedInstance].userID }
            success:^(id successResponse) {
                MLOG(@"设置封面图:%@", successResponse);
                if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
                    [MBProgressHUD hideHUD];
                    [MBProgressHUD showSuccess:@"设置成功" toView:self.view];
                } else {
                    [MBProgressHUD hideHUD];
                    [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"msg"]]];
                }
            }
            andFailure:^(id failureResponse) {
                [MBProgressHUD hideHUD];
                [MBProgressHUD showError:@"服务器繁忙,请重试"];
            }];
    } else if (buttonIndex == 2 && [_userId isEqualToString:[LYUserService sharedInstance].userID]) {
        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/deleteImg", REQUESTHEADER] andParameter:@{ @"img_id": [NSString stringWithFormat:@"%@", _imageData[_index][@"id"]] } success:^(id successResponse) {
            MLOG(@"删除气质图:%@", successResponse);
            if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
                [MBProgressHUD hideHUD];
                [MBProgressHUD showSuccess:@"删除成功" toView:self.view];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadDisposition" object:nil];

                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self back];
                });
            } else {
                [MBProgressHUD hideHUD];
                [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"msg"]]];
            }
        }
            andFailure:^(id failureResponse) {
                [MBProgressHUD hideHUD];
                [MBProgressHUD showError:@"服务器繁忙,请重试"];
            }];
    }
}

// 指定回调方法
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {

    NSString *msg = nil;

    if (error != NULL) {
        msg = @"保存图片失败";
    } else {
        msg = @"保存图片成功";
    }

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:self
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
