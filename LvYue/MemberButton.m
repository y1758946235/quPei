//
//  MemberButton.m
//  LvYue
//
//  Created by apple on 15/10/19.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import "MemberButton.h"
#import "GroupMemberModel.h"
#import "UIImageView+WebCache.h"

@implementation MemberButton

- (instancetype)initWithFrame:(CGRect)frame groupMemberModel:(GroupMemberModel *)model isGroupHolder:(BOOL)isHolder {
    if (self = [super initWithFrame:frame]) {
        //保存成员ID
        self.memberID = model.memberID;
        //成员头像
        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.width)];
        iconView.layer.cornerRadius = frame.size.width / 2;
        iconView.clipsToBounds = YES;
        [iconView sd_setImageWithURL:[NSURL URLWithString:model.icon]];
        [self addSubview:iconView];
        //成员名字
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.width, frame.size.width, frame.size.height - frame.size.width)];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = kFont13;
        if (isHolder) {
            label.textColor = [UIColor brownColor];
        } else {
            label.textColor = [UIColor blackColor];
        }
        label.text = model.name;
        [self addSubview:label];
    }
    return self;
}

@end
