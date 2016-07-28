//
//  OriginalView.m
//  LvYue
//
//  Created by 郑洲 on 16/3/16.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "OriginalView.h"

@implementation OriginalView

- (id)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        
        
        
        _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0,0,self.frame.size.width, self.frame.size.height)];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_imageView];
        
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.delegate = self;
        self.backgroundColor = [UIColor blackColor];
        self.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
        self.maximumZoomScale = 2.0f;
        self.minimumZoomScale = 1.0f;
        
        _blackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
        _blackView.backgroundColor = [UIColor blackColor];
        [self addSubview:_blackView];
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, SCREEN_WIDTH, 44)];
        _timeLabel.font = [UIFont systemFontOfSize:18];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.backgroundColor = [UIColor blackColor];
        [self addSubview:_timeLabel];

        
        _markLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 40, SCREEN_WIDTH, 40)];
        _markLabel.font = [UIFont systemFontOfSize:18];
        _markLabel.textColor = [UIColor whiteColor];
        _markLabel.textAlignment = NSTextAlignmentLeft;
        _markLabel.backgroundColor = [UIColor blackColor];
        [self addSubview:_markLabel];
    }
    return self;
}

@end
