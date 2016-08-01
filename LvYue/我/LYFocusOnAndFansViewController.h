//
//  LYFocusOnAndFansViewController.h
//  LvYue
//
//  Created by KentonYu on 16/8/1.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "BaseViewController.h"

typedef NS_ENUM(NSUInteger, LYFocusOnAndFansViewControllerType) {
    LYFocusOnAndFansViewControllerTypeFocusOn = 0,
    LYFocusOnAndFansViewControllerFans        = 1
};

@interface LYFocusOnAndFansViewController : BaseViewController

@property (nonatomic, assign) LYFocusOnAndFansViewControllerType type;

@end
