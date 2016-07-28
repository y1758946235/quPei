//
//  ModifyGroupDetailController.h
//  LvYue
//
//  Created by apple on 15/10/21.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import "BaseViewController.h"

/**
 *  修改群属性(群组名称、群组描述)
 */

@interface ModifyGroupDetailController : BaseViewController

@property (nonatomic, assign) int modifyType; //修改类型 0=名字 1=描述

@property (nonatomic, copy) NSString *groupID; //传递过来的群组id

@property (nonatomic, copy) NSString *receiveSender; //传递过来的参数

@end
