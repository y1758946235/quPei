//
//  AppDelegate+UMeng.h
//  LvYue
//
//  Created by apple on 15/10/26.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate (UMeng)<WXApiDelegate>

- (void)addUMengApplication:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

@end
