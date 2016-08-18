//
//  RootTabBarController.m
//  LvYue
//
//  Created by apple on 15/9/28.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import "DialogueViewController.h"
#import "FriendsCirleViewController.h"
#import "LYHomeViewController.h"
#import "LYMeViewController.h"
#import "LYUserService.h"
#import "MeController.h"
#import "MeController.h"
#import "NewHomeViewController.h"
#import "RootNavigationController.h"
#import "RootTabBarController.h"
#import "SearchViewController.h"

@interface RootTabBarController () <UITabBarControllerDelegate, UITabBarDelegate> {
    //记录上一次点击的索引
    NSInteger selectedIndex;
}

@end

@implementation RootTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.delegate = self;

    [self initWithNavs];
}


- (void)initWithNavs {

    NSString *path    = [[NSBundle mainBundle] pathForResource:@"RootTabBarC_Init" ofType:@"plist"];
    NSArray *navInfos = [NSArray arrayWithContentsOfFile:path];

    _homeNav     = [[RootNavigationController alloc] initWithRootViewController:[[LYHomeViewController alloc] init]];
    _dialogueNav = [[RootNavigationController alloc] initWithRootViewController:[[DialogueViewController alloc] init]];

    //朋友圈
    //    _searchNav = [[RootNavigationController alloc] initWithRootViewController:[[SearchViewController alloc] init]];

    FriendsCirleViewController *friendsCirleViewController = [[FriendsCirleViewController alloc] init];
    friendsCirleViewController.isFriendsCircle             = YES;
    _searchNav                                             = [[RootNavigationController alloc] initWithRootViewController:friendsCirleViewController];


    _meNav = [[RootNavigationController alloc] initWithRootViewController:[[LYMeViewController alloc] init]];

    NSArray *navs = @[_homeNav, _dialogueNav, _searchNav, _meNav];

    for (int i = 0; i < navs.count; i++) {
        RootNavigationController *nav = navs[i];
        nav.title                     = navInfos[i][@"title"];
        nav.tabBarItem.selectedImage  = [UIImage imageNamed:navInfos[i][@"selectedImage"]];
        nav.tabBarItem.image          = [UIImage imageNamed:navInfos[i][@"image"]];
        if (i == 3) { //我的页面
           
        }
        [self addChildViewController:nav];
    }
    self.tabBar.selectedImageTintColor = [UIColor colorWithRed:29 / 255.0 green:189 / 255.0 blue:159 / 255.0 alpha:1];

    //统一设置tabBar的背景色
    self.tabBar.barTintColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"test"]];
    
    // 是否显示红点
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"ShowGiftRedBadgeNotification"] boolValue] || [[[NSUserDefaults standardUserDefaults] valueForKey:@"ShowFansRedBadgeNotification"] boolValue]) {
        [self.tabBar showBadgeOnItemIndex:3];
    }
    
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    if ([LYUserService sharedInstance].userID && (![[LYUserService sharedInstance].userID isEqualToString:@""])) { //已登录
        if (viewController == tabBarController.viewControllers[3]) { //我的页面
            
        }
        return YES;
    } else { //未登录
        //如果以游客身份点击了'我'和'对话',直接弹出登陆界面
        if (viewController == tabBarController.viewControllers[1]) {
            [[LYUserService sharedInstance] fetchLoginStateWithCompeletionBlock:^(UserLoginStateType type) {
                if (type == UserLoginStateTypeWaitToLogin) {
                    [[LYUserService sharedInstance] jumpToLoginWithController:tabBarController];
                }
            }];
            return NO;
        } else { //如果以游客身份点击了‘首页’和‘发现’,则不进行操作
            return YES;
        }
    }
}


@end
