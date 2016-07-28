//
//  RemoveGroupMemberViewController.h
//  LvYue
//
//  Created by apple on 15/10/22.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import "BaseViewController.h"

/**
 *  管理(删除)群组成员 - 仅群主可用
 */

@interface RemoveGroupMemberViewController : BaseViewController

@property (nonatomic, copy) NSString *groupID;

@property (nonatomic, strong) NSMutableArray *members; //除群主之外的成员模型数组

@end
