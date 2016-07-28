//
//  JumpAnimationView.h
//  LvYue
//
//  Created by Olive on 15/12/30.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  跳跃动画View
 */

@interface JumpAnimationView : UIView

/**
 *  开始动画
 *
 *  @param from 起点Y
 *  @param to   终点Y
 */
- (void)startAnimationFrom:(CGFloat)from to:(CGFloat)to;

/**
 *  停止动画
 */
- (void)completeAnimation;

@end
