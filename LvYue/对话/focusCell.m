//
//  focusCell.m
//  LvYue
//
//  Created by X@Han on 16/12/29.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "focusCell.h"

@implementation focusCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self createCell];
    }
    return self;
}


- (void)createCell{
    //头像
    self.userIcon = [[UIImageView alloc]initWithFrame:CGRectMake(16, 16, 40, 40)];
    self.userIcon.layer.cornerRadius = 20;
    self.userIcon.userInteractionEnabled = NO;
    self.userIcon.clipsToBounds = YES;
    [self addSubview:self.userIcon];
    
    UIButton *headBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    headBtn.backgroundColor = [UIColor clearColor];
    [headBtn addTarget:self action:@selector(otherHome:) forControlEvents:UIControlEventTouchUpInside];
    [self.userIcon addSubview:headBtn];
    
    //vip图片
    self.vip = [[UIImageView alloc]initWithFrame:CGRectMake(48, 16, 16, 16)];
    self.vip.image = [UIImage imageNamed:@"VIP"];
    [self addSubview:self.vip];
    
    
    //昵称
    self.userName= [[UILabel alloc]initWithFrame:CGRectMake(72, 18, 110, 16)];
    self.userName.textAlignment = NSTextAlignmentLeft;
    self.userName.textColor = [UIColor colorWithHexString:@"#424242"];
    self.userName.font = [UIFont fontWithName:@"PingFangSC-Light" size:16];
    [self addSubview:self.userName];
    
    
    //年龄
    self.userAge = [[UILabel alloc]initWithFrame:CGRectMake(72, 42, 28, 12)];
    self.userAge.textColor = [UIColor colorWithHexString:@"#9e9e9e"];
    self.userAge.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    self.userAge.textAlignment = NSTextAlignmentLeft;
    [self addSubview:self.userAge];
    //身高
    self.userheight = [[UILabel alloc]initWithFrame:CGRectMake(114, 42, 36, 12)];
    self.userheight.textColor = [UIColor colorWithHexString:@"#9e9e9e"];
    self.userheight.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
    self.userheight.textAlignment = NSTextAlignmentLeft;
    [self addSubview:self.userheight];
    
    
    //星座
    self.conStella = [[UILabel alloc]initWithFrame:CGRectMake(166, 42, 36, 12)];
    self.conStella.textColor = [UIColor colorWithHexString:@"#9e9e9e"];
    self.conStella.textAlignment = NSTextAlignmentLeft;
    self.conStella.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    [self addSubview:self.conStella];
    
    UIButton *focus = [[UIButton alloc]init];
    focus.translatesAutoresizingMaskIntoConstraints = NO;
    [focus setTitleColor:[UIColor colorWithHexString:@"#424242"] forState:UIControlStateNormal];
    focus.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    focus.titleLabel.textAlignment = NSTextAlignmentCenter;
    focus.backgroundColor = [UIColor colorWithHexString:@"#ffffff"];
    focus.layer.borderColor = [UIColor colorWithHexString:@"#bdbdbd"].CGColor;
    focus.layer.borderWidth = 1;
    focus.layer.cornerRadius = 2;
    focus.clipsToBounds = YES;
    [self addSubview:focus];
    self.focuBtn = focus;
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[focus(==64)]-14-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(focus)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-24-[focus(==24)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(focus)]];
    
}


#pragma mark   ---点头像进入他人主页
- (void)otherHome:(UIButton *)sender{
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
