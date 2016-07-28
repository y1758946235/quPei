//
//  GroupMemberView.h
//  LvYue
//
//  Created by apple on 15/10/19.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
  群成员显示View
 */

@interface GroupMemberView : UIView

/**
 *  创建方法
 *
 *  @param modelArray 成员用户模型数组(第一个必须是群主的model,且数组的模型事先按照加群的事件排序)
 *  @param isHolder   是否是群主视角
 *  @param isFull     是否已经满员
 *
 *  @return 实例
 */

- (instancetype)initWithFrame:(CGRect)frame memberModelArray:(NSArray *)modelArray isHolder:(BOOL)isHolder isFull:(BOOL)isFull;

@end
