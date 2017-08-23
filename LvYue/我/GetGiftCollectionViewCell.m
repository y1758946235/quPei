//
//  GetGiftCollectionViewCell.m
//  LvYue
//
//  Created by X@Han on 17/3/21.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "GetGiftCollectionViewCell.h"

@implementation GetGiftCollectionViewCell
-(void)removeAllSubviews{
    for (UIView *view in self.contentView.subviews) {
        [view removeFromSuperview];
    }
}
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self removeAllSubviews];
        self.frame = CGRectMake(0, 0, 97*AutoSizeScaleX, 97*AutoSizeScaleX);
        self.getGiftImageV= [[UIImageView alloc]init];
        self.getGiftImageV.frame = CGRectMake(28*AutoSizeScaleX, 8*AutoSizeScaleX, 40*AutoSizeScaleX, 40*AutoSizeScaleX);
        self.getGiftImageV.image = [UIImage imageNamed:@"shop_money"];
        [self.contentView addSubview:self.getGiftImageV];
        
        self.getGiftNameLabel= [[UILabel alloc]initWithFrame:CGRectMake(20*AutoSizeScaleX, 56*AutoSizeScaleX, 56*AutoSizeScaleX, 12*AutoSizeScaleX)];
        self.getGiftNameLabel.textColor = [UIColor colorWithHexString:@"#424242"];
        self.getGiftNameLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
        self.getGiftNameLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.getGiftNameLabel];
        
        self.getEquipmentLabel = [[UILabel alloc]initWithFrame:CGRectMake(14*AutoSizeScaleX, 76*AutoSizeScaleX, 68*AutoSizeScaleX, 12*AutoSizeScaleX)];
        self.getEquipmentLabel.textColor = [UIColor colorWithHexString:@"#9e9e9e"];
        self.getEquipmentLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
        self.getEquipmentLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.getEquipmentLabel];
    }
    return self;
}
@end
