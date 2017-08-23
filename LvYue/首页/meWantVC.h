//
//  meWantVC.h
//  LvYue
//
//  Created by X@Han on 16/12/8.
//  Copyright © 2016年 OLFT. All rights reserved.
//

typedef void (^ReturnTextBlock)(NSString *dateTypeName,NSString *dateTypeId,NSString *selectImageName);


#import <UIKit/UIKit.h>
#import "BaseViewController.h"


@interface meWantVC : BaseViewController


@property (nonatomic, copy) ReturnTextBlock returnTextBlock;

- (void)returnText:(ReturnTextBlock)block;


@end

