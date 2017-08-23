//
//  ChangeHeadViewController.h
//  澜庭
//
//  Created by 广有射怪鸟事 on 15/9/25.
//  Copyright (c) 2015年 刘瀚韬. All rights reserved.
//


typedef void (^ReturnTextBlock)(UIImage *image);

#import "BaseViewController.h"

@interface ChangeHeadViewController : BaseViewController

@property (nonatomic,strong) NSString *locationString;
@property (nonatomic,strong) UIImage *headImage;
@property (nonatomic,strong) NSString *name;

@property (nonatomic, copy) ReturnTextBlock returnTextBlock;

- (void)returnText:(ReturnTextBlock)block;

@end
