//
//  JJPhotoBowserViewController.m
//  点击全屏看大图
//
//  Created by 蒋俊 on 15/9/17.
//  Copyright (c) 2015年 vison. All rights reserved.
//

#import "JJPhotoBowserViewController.h"
#import "UIImageView+WebCache.h"
#import "JJPhotoView.h"
#import "MBProgressHUD+NJ.h"

#define SCREENWIDTH [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT [UIScreen mainScreen].bounds.size.height

@interface JJPhotoBowserViewController ()<UIActionSheetDelegate>
{
    JJPhotoView *_leftPhotoView;
    JJPhotoView *_centerPhotoView;
    JJPhotoView *_rightPhotoView;
    
    JJPhotoView *photoView;
    
    NSInteger _index;

    BOOL _isDouble;//是否双击
    
    UIActionSheet *action;
}
@property (nonatomic,strong) UIButton *saveBtn;
@end

@implementation JJPhotoBowserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //假数据 初始化
    
    [self addScrollView];

    if (_isCircle) {
        //轮播
        [self addThreePhotoView];
    }else{
        //不循环
        [self addPhotoViews];
    }
}

//添加scrollView大背景
- (void)addScrollView{
    
    //添加背景
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    _scrollView.backgroundColor = [UIColor blackColor];
    _scrollView.delegate = self;
    if (_isCircle) {
        _scrollView.contentSize = CGSizeMake(SCREENWIDTH*3, SCREENHEIGHT);
        //设置当前显示的位置为中间图片
        _scrollView.contentOffset = CGPointMake(SCREENWIDTH, 0);
    }else{
        _scrollView.contentSize = CGSizeMake(SCREENWIDTH*_imageData.count, SCREENHEIGHT);
    }
    //隐藏滚动条
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;

    _scrollView.pagingEnabled = YES;
    [self.view addSubview:_scrollView];
}

//添加分页控制器
- (void)addPageControllerWithIndex:(NSInteger)index andCount:(NSInteger)count{
    
    _pageController = [[UIPageControl alloc]initWithFrame:CGRectMake((SCREENWIDTH-200)/2, SCREENHEIGHT-50, 200, 20)];
    //所有页数
    _pageController.numberOfPages = count;
    //当前页数
    _pageController.currentPage = index;
    [self.view addSubview:_pageController];
    
    //加载当前图片
    [self loadImageWithIndex:index];
}

//在scrollView中添加3个图片
- (void)addThreePhotoView{
    
    _leftPhotoView = [[JJPhotoView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
    _leftPhotoView.contentMode = UIViewContentModeScaleAspectFit;
    [_scrollView addSubview:_leftPhotoView];
    
    _centerPhotoView = [[JJPhotoView alloc]initWithFrame:CGRectMake(SCREENWIDTH, 0, SCREENWIDTH, SCREENHEIGHT)];
    _centerPhotoView.contentMode = UIViewContentModeScaleAspectFit;
    [_scrollView addSubview:_centerPhotoView];
    
    _rightPhotoView = [[JJPhotoView alloc]initWithFrame:CGRectMake(SCREENWIDTH*2, 0, SCREENWIDTH, SCREENHEIGHT)];
    _rightPhotoView.contentMode = UIViewContentModeScaleAspectFit;
    [_scrollView addSubview:_rightPhotoView];
    
    //添加保存按钮
    _saveBtn = [[UIButton alloc]initWithFrame:CGRectMake(20, self.view.frame.size.height-60, 60, 44)];
    [_saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    [_saveBtn addTarget:self action:@selector(saveImage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_saveBtn];
    
    //退出大图，单击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTap:)];
    [_centerPhotoView addGestureRecognizer:tap];
    
    //放大缩小，形变 双击手势
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTap:)];
    [doubleTap setNumberOfTapsRequired:2];
    [_centerPhotoView addGestureRecognizer:doubleTap];
    
    //放大缩小，形变 捏合手势
//    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panChange:)];
//    [_centerPhotoView addGestureRecognizer:pan];
}

//捏合手势
- (void)panChange:(UIPanGestureRecognizer *)pan{

    CGPoint point = [pan translationInView:self.view];
    NSLog(@"%f,%f",point.x,point.y);
    pan.view.center = CGPointMake(pan.view.center.x + point.x, pan.view.center.y + point.y);
    [pan setTranslation:CGPointMake(0, 0) inView:self.view];
}

//单击手势 退出大图
- (void)singleTap:(UITapGestureRecognizer *)tap{
    
    _isDouble = NO;
    //通过延时来让系统判断是否为双击
    [self performSelector:@selector(hidden) withObject:nil afterDelay:0.3f];
}

//隐藏图片
- (void)hidden{
    
    if (_isDouble) {
        return;
    }
    self.view.backgroundColor = [UIColor clearColor];
    [UIView animateWithDuration:0.5 animations:^{
        
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        
        //1）清除根视图
        [self.view removeFromSuperview];
        //2) 清除子视图控制器
        [self removeFromParentViewController];
    }];

    NSLog(@"单击");
}

//单击手势 退出大图
- (void)doubleTap:(UITapGestureRecognizer *)tap{
    
    _isDouble = YES;
    NSLog(@"双击");
    
    //如果图片已放大到最大
    if (_isCircle) {
        
        //轮播
        if (_centerPhotoView.zoomScale == _centerPhotoView.maximumZoomScale) {
            
            [_centerPhotoView setZoomScale:1.0f animated:YES];
        }else{
            
            //否则从手势触摸点开始放大1.1倍
            CGPoint location = [tap locationInView:_centerPhotoView];
            [UIView animateWithDuration:0.3f animations:^{
                //从某点开始放大
                [_centerPhotoView zoomToRect:CGRectMake(location.x, location.y, 1, 1) animated:YES];
            }];
        }
    }else{
        
        //不轮播
        photoView = (JJPhotoView *)tap.view;
        if (photoView.zoomScale == photoView.maximumZoomScale) {
            
            [photoView setZoomScale:1.0f animated:YES];
        }else{
            
            //否则从手势触摸点开始放大1.1倍
            CGPoint location = [tap locationInView:photoView];
            [UIView animateWithDuration:0.3f animations:^{
                //从某点开始放大
                [photoView zoomToRect:CGRectMake(location.x, location.y, 1, 1) animated:YES];
            }];
        }
    }
}

/**
 *  展示照片
 *
 *  @param index 当前点击的照片索引
 *  @param count 所有照片数量
 */
- (void)showImageWithIndex:(NSInteger)index andCount:(NSInteger)count{
    
    _index = index;
    [self addPageControllerWithIndex:index andCount:count];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self.view];
    //记录住视图控制器
    [window.rootViewController addChildViewController:self];
}

/**
 *  加载图片
 *
 *  @param index 当前图片索引
 */
- (void)loadImageWithIndex:(NSInteger)index{

    if (_isCircle){
        
        //轮播
//        [_leftPhotoView.imageView sd_setImageWithURL:[NSURL URLWithString:_imageData[(index-1)%_imageData.count]] placeholderImage:[UIImage imageNamed:@"加载失败" ] completed:nil];
//        [_rightPhotoView.imageView sd_setImageWithURL:[NSURL URLWithString:_imageData[(index+1)%_imageData.count]] placeholderImage:[UIImage imageNamed:@"加载失败" ] completed:nil];
//        [_centerPhotoView.imageView sd_setImageWithURL:[NSURL URLWithString:_imageData[index%_imageData.count]] placeholderImage:[UIImage imageNamed:@"加载失败" ] completed:nil];
        [_leftPhotoView.imageView sd_setImageWithURL:_imageData[(index-1)%_imageData.count] placeholderImage:[UIImage imageNamed:@"加载失败" ] completed:nil];
        [_rightPhotoView.imageView sd_setImageWithURL:_imageData[(index+1)%_imageData.count] placeholderImage:[UIImage imageNamed:@"加载失败" ] completed:nil];
        [_centerPhotoView.imageView sd_setImageWithURL:_imageData[index%_imageData.count] placeholderImage:[UIImage imageNamed:@"加载失败" ] completed:nil];
    }else{
    
        //不轮播
        photoView = [_scrollView viewWithTag:(100 + index)];
        __block UIActivityIndicatorView *activityIndicator;
        
        [photoView.imageView sd_setImageWithURL:_imageData[index] placeholderImage:[UIImage imageNamed:@"加载失败" ] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            if (!activityIndicator)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [photoView.imageView addSubview:activityIndicator = [UIActivityIndicatorView.alloc initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge]];
                    activityIndicator.frame = CGRectMake(0, 0, 100, 100);
                    activityIndicator.layer.cornerRadius = 15.0;
                    activityIndicator.center = photoView.imageView.center;
                    [activityIndicator setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.7]];
                    [activityIndicator startAnimating];
                });
            }
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [activityIndicator removeFromSuperview];
            activityIndicator = nil;
        }];
        
        [_scrollView setContentOffset:CGPointMake(SCREEN_WIDTH*index, 0)];
    }
}

//保存照片
- (void)saveImage{
    
    UIImage *image = _centerPhotoView.imageView.image;
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

#pragma mark - 不循环
//有几张图片就在scrollView中添加几个图片
- (void)addPhotoViews{
    
    for (int i = 0; i < _imageData.count; i++) {
        
        photoView = [[JJPhotoView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH*i, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        photoView.tag = i+100;
        UILongPressGestureRecognizer *save = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(saveImagef:)];
        photoView.userInteractionEnabled = YES;
        [photoView addGestureRecognizer:save];
        [_scrollView addSubview:photoView];
        
        //退出大图，单击手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTap:)];
        [photoView addGestureRecognizer:tap];
        
        //放大缩小，形变 双击手势
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTap:)];
        [doubleTap setNumberOfTapsRequired:2];
        [photoView addGestureRecognizer:doubleTap];
    }
}

//根据按钮的tag来获取照片
- (void)saveImagef:(UITapGestureRecognizer *)sender {
    
    [photoView removeGestureRecognizer:sender];
    if (!action) {
        action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"保存图片", nil];
    }
   
    
    [action showInView:self.view];
    
    [photoView addGestureRecognizer:sender];
}

// 指定回调方法
- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo{

    if(error != NULL){
        [MBProgressHUD showError:@"保存失败"];
    }else{
        [MBProgressHUD showSuccess:@"保存成功"];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        photoView = [_scrollView viewWithTag:(100 + _index)];
        UIImage *image = photoView.imageView.image;
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
        
        [actionSheet removeFromSuperview];
    }
    
    
}

#pragma mark - UIScrollViewDelegate
//滚动停止事件
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{

    if (scrollView == _scrollView) {
        CGPoint offset = [_scrollView contentOffset];
        if (_isCircle) {
            if (offset.x < SCREENWIDTH) {
                //左移
                //还原形变倍数
                [_centerPhotoView setZoomScale:1.0f animated:NO];
                _index -= 1;
            }else if (offset.x > SCREENWIDTH){
                //右移
                //还原形变倍数
                [_centerPhotoView setZoomScale:1.0f animated:NO];
                _index += 1;
            }
            
            [self loadImageWithIndex:_index];
            [_scrollView setContentOffset:CGPointMake(SCREENWIDTH, 0) animated:NO];
            //设置当前页
            _pageController.currentPage = _index%_imageData.count;
        }else{
        
            _index = offset.x / SCREEN_WIDTH;
            [self loadImageWithIndex:_index];
            //设置当前页
            _pageController.currentPage = _index;
        }
    }
}

@end
