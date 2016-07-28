//
//  BuddySelectionViewController.h
//  LvYue
//
//  Created by apple on 15/10/8.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import "BaseViewController.h"

@interface BuddySelectionViewController : BaseViewController

/**
 *  接收上一个控制器传递过来的建群基本信息
 */
@property (nonatomic, copy) NSString *groupName;

@property (nonatomic, copy) NSString *groupDesc;

@end
