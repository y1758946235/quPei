//
//  RootNavigationController.m
//  LvYue
//
//  Created by apple on 15/9/28.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import "RootNavigationController.h"
#import "SearchViewController.h"
#import "MeController.h"
#import "DialogueViewController.h"
#import "NewHomeViewController.h"
#import "LYHomeViewController.h"
#import "LYMeViewController.h"

//朋友圈
#import "FriendsCirleViewController.h"
#import "VideoListViewController.h"

@interface RootNavigationController ()

@end

@implementation RootNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


//重写push方法
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
//    if (([viewController isMemberOfClass:[LYHomeViewController class]]) || [viewController isMemberOfClass:[DialogueViewController class]] || [viewController isMemberOfClass:[SearchViewController class]] || [viewController isMemberOfClass:[MeController class]]||[viewController isMemberOfClass:[VideoListViewController class]]) {
//        
//        //调用父类的push
//        [super pushViewController:viewController animated:animated];
//        
//    } else {
//        
//        //在跳转时自动隐藏tabBar
//        [viewController setHidesBottomBarWhenPushed:YES];
//        
//        //调用父类的push
//        [super pushViewController:viewController animated:animated];
//    }
    if (([viewController isMemberOfClass:[LYHomeViewController class]]) || [viewController isMemberOfClass:[DialogueViewController class]] || [viewController isMemberOfClass:[FriendsCirleViewController class]] || [viewController isMemberOfClass:[MeController class]]|| [viewController isMemberOfClass:[LYMeViewController class]] ||[viewController isMemberOfClass:[VideoListViewController class]]) {
        
        //调用父类的push
        [super pushViewController:viewController animated:animated];
        
    } else {
        
        //在跳转时自动隐藏tabBar
        [viewController setHidesBottomBarWhenPushed:YES];
        
        //调用父类的push
        [super pushViewController:viewController animated:animated];
    }

    
}


+ (void)initialize {
    
    /***-----------------------标题文字风格样式的设置--------------------***/
    
    NSMutableDictionary * style = [NSMutableDictionary dictionary];

    style[NSFontAttributeName] = kFontBold18;
    style[NSForegroundColorAttributeName] = [UIColor whiteColor];
    
    [[UINavigationBar appearance] setTitleTextAttributes:style];
    
//    [UINavigationBar appearance].barTintColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"test"]];
    [UINavigationBar appearance].barTintColor = [UIColor colorWithRed:29/255.0 green:189/255.0 blue:159/255.0 alpha:1];
}


@end
