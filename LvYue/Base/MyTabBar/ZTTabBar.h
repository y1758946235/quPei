//
//  ZTTabBar.h
//  FuNongChang
//
//  Created by whkj on 16/4/1.
//  Copyright © 2016年 whkj. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZTTabBar;

#warning ZTTabBar继承自UITabBar，所以ZTTabBar的代理必须遵循UITabBar的代理协议！
@protocol ZTTabBarDelegate <UITabBarDelegate>

@optional

- (void)tabBarDidClickPlusButton:(ZTTabBar *)tabBar;

@end

@interface ZTTabBar : UITabBar

@property (nonatomic, weak) id<ZTTabBarDelegate> delegate;

@end
