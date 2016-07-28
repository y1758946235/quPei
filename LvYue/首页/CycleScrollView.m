//
//  CycleScrollView.m
//  豆客项目
//
//  Created by Xia Wei on 15/9/25.
//  Copyright © 2015年 Xia Wei. All rights reserved.
//

#import "CycleScrollView.h"
#import "LYHttpPoster.h"
#import "UIImageView+WebCache.h"
#import "UIImage+WebP.h"

#define selfWidth self.frame.size.width
#define selfHeight self.frame.size.height

@interface CycleScrollView (){
    int imgNum;
}

@property(nonatomic,assign)CGPoint originPoint;//每次滚动好后回到中间的那个页面
@property(nonatomic,strong)NSMutableArray *images;//存放显示的三张图片的数组
@property(nonatomic,strong)NSMutableArray *scrollImageArray;//存放所有照片的数组
@property(nonatomic,strong)NSTimer *timer;
@property(nonatomic,assign)CGPoint nextPoint;//下一张的起点
//@property(nonatomic,assign)int currentPage;//当前的页码数
    
@end

@implementation CycleScrollView

- (id) initWithFrame:(CGRect)frame animationDuration:(NSTimeInterval)animationDuration{
    self = [super initWithFrame:frame];
    if (self) {
        
        //设置scrollView每次回到的 中间位置
        _originPoint.x = self.frame.size.width;
        _originPoint.y = 0;
        
        _nextPoint.x = 2 * _originPoint.x;
        _nextPoint.y = 0;
        
        //创建存放显示三张照片的数组
        self.images = [[NSMutableArray alloc] initWithCapacity:3];
        
        //创建scrollView
        [self scrollViewCreated];
        
        //初始化定时器
        self.timer = [NSTimer scheduledTimerWithTimeInterval:animationDuration target:self selector:@selector(scrollTimer) userInfo:nil repeats:YES];
    }
    return self;
}

//定时器2秒一次调用这个方法
- (void)scrollTimer{
    [_scrollView setContentOffset:_nextPoint animated:YES];
}

- (void)scrollViewCreated{
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, selfWidth, selfHeight)];
    _scrollView.contentSize = CGSizeMake(3 * selfWidth, selfHeight);
    _scrollView.pagingEnabled = YES;
    [_scrollView setBackgroundColor:[UIColor whiteColor]];
    //滑动到边界立即停止
    _scrollView.bounces = NO;
    // 水平滚动条不显示
    _scrollView.showsHorizontalScrollIndicator = NO;
    [self loadImage];
    [self addSubview:_scrollView];
}

//加载scrollView的图片
- (void)loadImage{
    self.scrollImageArray = [[NSMutableArray alloc] init];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/assets/homeImg",REQUESTHEADER] andParameter:@{} success:^(id successResponse) {
        MLOG(@"轮播图结果:%@",successResponse);
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            
            NSArray *array = successResponse[@"data"][@"imgs"];
            for (NSDictionary *dict in array) {
                NSString *imgStr = dict[@"img"];
                [self.scrollImageArray addObject:imgStr];
                NSLog(@"轮播图:%@",imgStr);
            }
            
            imgNum = (int)self.scrollImageArray.count;
            //创建pageController
            [self pageControllerCreated];
            
            //初始化当前的scrollView
            for (int i = 0;i < 3; i ++) {
                UIImageView *tempView = [[UIImageView alloc] initWithFrame:
                                         CGRectMake(i * selfWidth,0, selfWidth, selfHeight)];
                [tempView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,self.scrollImageArray[i]]]];
                [self.images addObject:tempView];
                [self.scrollView addSubview:[self.images objectAtIndex:i]];
            }
            _currentPage = 1;
            self.scrollView.contentOffset = self.originPoint;
        } else {
            
    }
    } andFailure:^(id failureResponse) {
        
    }];
}

//改变图片
- (void)changeImages:(int)currentPage{
    currentPage %= imgNum;
    
    int nextPage,prePage;
    int arrLength = imgNum;
    if (currentPage == arrLength - 1) {
        prePage = currentPage - 1;
        nextPage = 0;
    }
    else if (currentPage == 0){
        nextPage = currentPage + 1;
        prePage = arrLength - 1;
    }
    else{
        nextPage = currentPage + 1;
        prePage = currentPage - 1;
    }
    
    if (self.images.count) {
        //改变当前显示的三张图片
        UIImageView *tempView = [[UIImageView alloc]init];
        tempView = [self.images objectAtIndex:0];
        [tempView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,self.scrollImageArray[prePage]]]];
        
        tempView = [self.images objectAtIndex:1];
        [tempView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,self.scrollImageArray[currentPage]]]];
        //((UIImageView *)[self.images objectAtIndex:1]).image = [UIImage imageNamed:_scrollImageArray[currentPage]];
        tempView = [self.images objectAtIndex:2];
        [tempView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,self.scrollImageArray[nextPage]]]];
        // ((UIImageView *)[self.images objectAtIndex:2]).image = [UIImage imageNamed:_scrollImageArray[nextPage]];
    }
    
    self.scrollView.contentOffset = _originPoint;
    
    //改变pageControl的当前页面
    if (currentPage == 0) {
        _page.currentPage = imgNum;
    }
    else{
        _page.currentPage = currentPage - 1;
    }
}

- (void) pageControllerCreated{
    _page = [[UIPageControl alloc] initWithFrame:CGRectMake(0, selfHeight - 40, selfWidth, 30)];
    _page.currentPage = 0;
    _page.numberOfPages = imgNum;
    [self addSubview:_page];
    [self bringSubviewToFront:_page];
}

@end