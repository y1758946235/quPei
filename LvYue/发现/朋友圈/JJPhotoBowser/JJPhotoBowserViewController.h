//
//  JJPhotoBowserViewController.h
//  点击全屏看大图
//
//  Created by 蒋俊 on 15/9/17.
//  Copyright (c) 2015年 vison. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JJPhotoBowserViewController : UIViewController<UIScrollViewDelegate>

@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) UIPageControl *pageController;
@property (nonatomic,strong) NSArray       *imageData;
@property (nonatomic,assign) BOOL           isCircle;//是否循环
- (void)showImageWithIndex:(NSInteger)index andCount:(NSInteger)count;
@end
