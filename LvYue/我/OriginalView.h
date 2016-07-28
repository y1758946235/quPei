//
//  OriginalView.h
//  LvYue
//
//  Created by 郑洲 on 16/3/16.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OriginalView : UIScrollView<UIScrollViewDelegate>
@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) UILabel *timeLabel;
@property (nonatomic,strong) UILabel *markLabel;
@property (nonatomic,strong) UIView  *blackView;
@end
