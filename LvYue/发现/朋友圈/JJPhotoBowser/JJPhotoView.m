//
//  JJPhotoView.m
//  点击全屏看大图
//
//  Created by 蒋俊 on 15/9/17.
//  Copyright (c) 2015年 vison. All rights reserved.
//

#import "JJPhotoView.h"

@interface JJPhotoView()

@end

@implementation JJPhotoView

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
        
    }
    return self;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    
    return _imageView;
}
@end
