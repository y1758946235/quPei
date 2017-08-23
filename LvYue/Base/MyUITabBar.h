//
//  MyUITabBar.h
//  LvYue
//
//  Created by X@Han on 17/6/13.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <UIKit/UIKit.h>

@protocol RoundButtonDelegate <NSObject>

- (void)RoundButtonClicked;

@end

@interface MyUITabBar : UITabBar<RoundButtonDelegate>

@property (nonatomic, weak) id <RoundButtonDelegate>myDelegate;

@property (nonatomic, strong)UIButton *roundButton;

@end
