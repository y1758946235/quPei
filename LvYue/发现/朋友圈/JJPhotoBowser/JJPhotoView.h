//
//  JJPhotoView.h
//  点击全屏看大图
//
//  Created by 蒋俊 on 15/9/17.
//  Copyright (c) 2015年 vison. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 *  照片视图，可放大缩小
 */
@interface JJPhotoView : UIScrollView<UIScrollViewDelegate>
@property (nonatomic,strong) UIImageView *imageView;
@end
