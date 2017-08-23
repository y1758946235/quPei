//
//  ChangeHeadVC.h
//  LvYue
//
//  Created by X@Han on 16/12/29.
//  Copyright © 2016年 OLFT. All rights reserved.
//
typedef void (^ReturnTextBlock)(NSString *headIcon,UIImage *image);

#import "BaseViewController.h"

@interface ChangeHeadVC : BaseViewController

@property (nonatomic,strong) NSString *locationString;
@property (nonatomic,strong) UIImage *headImage;
@property (nonatomic,strong) NSString *name;

@property (nonatomic, copy) ReturnTextBlock returnTextBlock;

- (void)returnText:(ReturnTextBlock)block;

@end
