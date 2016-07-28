//
//  RootTabBarController.h
//  LvYue
//
//  Created by apple on 15/9/28.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RootNavigationController;

@interface RootTabBarController : UITabBarController

@property (nonatomic, strong) RootNavigationController *homeNav;
@property (nonatomic, strong) RootNavigationController *dialogueNav;
@property (nonatomic, strong) RootNavigationController *searchNav;
@property (nonatomic, strong) RootNavigationController *meNav;

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController;

@end
