//
//  selectVC.h
//  LvYue
//
//  Created by X@Han on 16/12/28.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "BaseViewController.h"
typedef void (^ShaiXuanTextBlock)(NSString *userSex,NSString *beginUserAge,NSString *endUserAge);
@interface selectVC : BaseViewController

@property (nonatomic, copy) ShaiXuanTextBlock shaiXuanTextBlock;

- (void)shaiXuanText:(ShaiXuanTextBlock)block;
@end
