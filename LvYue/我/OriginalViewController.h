//
//  OriginalViewController.h
//  LvYue
//
//  Created by 郑洲 on 16/3/16.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "BaseViewController.h"

@interface OriginalViewController : BaseViewController <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageController;
@property (nonatomic, strong) NSArray *imageData;
@property (nonatomic, strong) NSArray *smallImage;
@property (nonatomic, strong) NSString *userId;
@property(nonatomic,assign) BOOL isBuyed;
@property (nonatomic, copy) void (^dismissBlock)(void);

- (void)showImageWithIndex:(NSInteger)index andCount:(NSInteger)count;

@end
