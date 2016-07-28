//
//  VideoCategoryBar.m
//  LvYue
//
//  Created by Olive on 15/12/24.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import "VideoCategoryBar.h"

#define kMenuItemWidth 60.0f
#define kMenuItemMargin 20.0f
#define kLineChangeAnimationDuration 0.25f

@interface VideoCategoryBar () {
    CGRect _frame;
    UIButton *_lastBtn;
    UIColor *_unSelectedColor;
    UIColor *_selectedColor;
    UIColor *_lineColor;
}

@property (nonatomic, copy) NSArray<NSString *> *titles;

@property (nonatomic, strong) UIScrollView *bgScrollView;

@property (nonatomic, strong) UIView *line;

@end

@implementation VideoCategoryBar


- (UIScrollView *)bgScrollView {
    if (!_bgScrollView) {
        _bgScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, _frame.size.width, _frame.size.height)];
        _bgScrollView.backgroundColor = [UIColor clearColor];
        _bgScrollView.contentSize = CGSizeMake(self.titles.count * kMenuItemWidth + (self.titles.count+1) * kMenuItemMargin, 0);
        _bgScrollView.showsHorizontalScrollIndicator = NO;
        _bgScrollView.showsVerticalScrollIndicator = NO;
        _bgScrollView.bounces = NO;
        [self setItems:self.titles withMenuView:_bgScrollView];
    }
    return _bgScrollView;
}


- (UIView *)line {
    if (!_line) {
        _line = [[UIView alloc] initWithFrame:CGRectMake(kMenuItemMargin, _frame.size.height - 2, kMenuItemWidth, 2.0)];
        _line.backgroundColor = _lineColor;
    }
    return _line;
}


- (instancetype)initWithItemTitles:(NSArray<NSString *> *)titles andFrame:(CGRect)frame unSelectedTitleColor:(UIColor *)unSelectedTitleColor selectedTitleColor:(UIColor *)selectedTitleColor lineColor:(UIColor *)lineColor {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.titles = titles;
        _frame = frame;
        _unSelectedColor = unSelectedTitleColor;
        _selectedColor = selectedTitleColor;
        _lineColor = lineColor;
        [self addSubview:self.bgScrollView];
    }
    return self;
}


//外部刷新UI
- (void)reloadItemTitles:(NSArray<NSString *> *)titles {
    self.titles = titles;
    [_bgScrollView removeFromSuperview];
    _bgScrollView = nil;
    [self addSubview:self.bgScrollView];
}


#pragma mark - Private
- (void)setItems:(NSArray<NSString *> *)titles withMenuView:(UIScrollView *)src {
    for (int i = 0;i < self.titles.count;i ++) {
        UIButton *item = [UIButton buttonWithType:UIButtonTypeCustom];
        item.frame = CGRectMake(i * kMenuItemWidth + (i+1) * kMenuItemMargin, 0, kMenuItemWidth, src.frame.size.height);
        [item setBackgroundColor:[UIColor clearColor]];
        [item setTitle:titles[i] forState:UIControlStateNormal];
        if (i) {
            [item setTitleColor:_unSelectedColor forState:UIControlStateNormal];
            item.titleLabel.font = [UIFont systemFontOfSize:14.0];
        } else {
            [item setTitleColor:_selectedColor forState:UIControlStateNormal];
            item.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
            _lastBtn = item;
        }
        [item addTarget:self action:@selector(menuItemDidSelect:) forControlEvents:UIControlEventTouchUpInside];
        [item setTag:100+i];
        [src addSubview:item];
    }
    [src addSubview:self.line];
}


- (void)menuItemDidSelect:(UIButton *)item {
    if (item == _lastBtn) {
        return;
    }
    [_lastBtn setTitleColor:_unSelectedColor forState:UIControlStateNormal];
    _lastBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [item setTitleColor:_selectedColor forState:UIControlStateNormal];
    item.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
    _lastBtn = item;
    CGRect frame = item.frame;
    [UIView animateWithDuration:kLineChangeAnimationDuration animations:^{
        [self.line setFrame:CGRectMake(frame.origin.x, frame.size.height - 2, frame.size.width, 2)];
    }];
    //通知代理
    if ([self.delegate respondsToSelector:@selector(videoCategoryBar:menuItemDidSelect:)]) {
        [self.delegate videoCategoryBar:self menuItemDidSelect:item];
    }
}


@end
