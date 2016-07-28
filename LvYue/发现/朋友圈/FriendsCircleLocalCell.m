//
//  FriendsCircleLocalCell.m
//  LvYueDemo
//
//  Created by 蒋俊 on 15/10/10.
//  Copyright (c) 2015年 vison. All rights reserved.
//

#import "FriendsCircleLocalCell.h"

@implementation FriendsCircleLocalCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UIImageView *localIcon = [[UIImageView alloc]initWithFrame:CGRectMake(Kinterval,(44-20)/2, 20, 20)];
        localIcon.contentMode = UIViewContentModeScaleAspectFit;
        [localIcon setImage:[UIImage imageNamed:@"所在位置"]];
        [self addSubview:localIcon];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(localIcon.frame)+Kinterval/2, 0, 200, 44)];
        label.text = @"显示所在位置";
        [self addSubview:label];
        
        _switchBtn = [[UISwitch alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-70,10, 50,44)];
        _switchBtn.on = NO;
        _switchBtn.onTintColor = UIColorWithRGBA(249, 82, 74, 1);
        [self addSubview:_switchBtn];
    }
    return self;
}

@end
