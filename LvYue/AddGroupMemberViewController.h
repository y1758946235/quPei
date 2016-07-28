//
//  AddGroupMemberViewController.h
//  LvYue
//
//  Created by apple on 15/10/22.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import "BaseViewController.h"

@interface AddGroupMemberViewController : BaseViewController

@property (nonatomic, copy) NSString *groupID;

@property (nonatomic, strong) NSArray *alreadMembers; //已经在群组中的人的userID数组

@end
