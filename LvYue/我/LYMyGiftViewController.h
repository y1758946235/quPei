//
//  LYMyGiftViewController.h
//  LvYue
//
//  Created by KentonYu on 16/8/1.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "BaseViewController.h"

typedef NS_ENUM(NSUInteger, LYMyGiftViewControllerType) {
    LYMyGiftViewControllerTypeFetch = 0,
    LYMyGiftViewControllerTypeSend  = 1
};

@interface LYMyGiftViewController : BaseViewController

@property (nonatomic, copy) NSString *wealth;
@property (nonatomic, copy) NSString *meiLiZhi;

@end
