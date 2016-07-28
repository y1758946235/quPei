//
//  MemberButton.h
//  LvYue
//
//  Created by apple on 15/10/19.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GroupMemberModel;

@interface MemberButton : UIButton

//记录成员的ID,方便push到个人详情页
@property (nonatomic, copy) NSString *memberID;

//创建方法
- (instancetype)initWithFrame:(CGRect)frame groupMemberModel:(GroupMemberModel *)model isGroupHolder:(BOOL)isHolder;

@end
