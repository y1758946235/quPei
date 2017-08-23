//
//  AcctDetailCollectionViewCell.m
//  LvYue
//
//  Created by X@Han on 17/4/29.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "AcctDetailCollectionViewCell.h"

@implementation AcctDetailCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        
        UIImageView *imag = [[UIImageView alloc]initWithFrame:CGRectMake(37*AutoSizeScaleX, 20*AutoSizeScaleX, 32*AutoSizeScaleX, 32*AutoSizeScaleX)];
        self.imag = imag;
        [self.contentView addSubview:imag];
        
        UILabel *myNumLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 70*AutoSizeScaleX, SCREEN_WIDTH/3, 16*AutoSizeScaleX)];
        myNumLabel.textAlignment = NSTextAlignmentCenter;
        myNumLabel.textColor = [UIColor colorWithHexString:@"#424242"] ;
        myNumLabel.layer.cornerRadius = 8*AutoSizeScaleX;
        myNumLabel.clipsToBounds = YES;
        myNumLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16.0f];
        self.myNumLabel = myNumLabel;
        [self.contentView addSubview:myNumLabel];

    }
    return self;
}
@end
