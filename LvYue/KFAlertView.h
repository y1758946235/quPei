//
//  KFAlertView.h
//  LvYue
//
//  Created by KFallen on 16/6/27.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KFAlertView;
@protocol KFAlertViewDelegte <NSObject>
@optional
- (void)alertView:(KFAlertView *)alertView didClickKFButtonIndex:(NSInteger)buttonIndex;

@end


@interface KFAlertView : UIView

/**
 *  内容，未实现
 */
@property (nonatomic, strong) UIView* contentView;

/**
 *  文字内容
 */
@property (nonatomic, strong) UILabel* textLabel;

@property (nonatomic, weak) id<KFAlertViewDelegte> delegate;


/**
 *  创建AlertView
 */
+ (instancetype)alertView;

/**
 *  显示AlertView
 */
- (void)show;

/**
 *  隐藏AlertView
 */
- (void)dismiss;

/**
 *  初始化两个按钮，无需设置frame；点击使用代理
 */
- (void)initWithCancleBtnTitle:(NSString *)cancleStr cancleColor:(UIColor *)cancleColor confirmBtnTitle:(NSString *)confirmStr confirmColor:(UIColor *)confirmColor;

@end
