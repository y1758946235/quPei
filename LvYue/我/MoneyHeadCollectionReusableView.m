//
//  MoneyHeadCollectionReusableView.m
//  LvYue
//
//  Created by X@Han on 17/3/20.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "MoneyHeadCollectionReusableView.h"

@implementation MoneyHeadCollectionReusableView
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _stateLabel      = [[UILabel alloc] initWithFrame:CGRectMake(16, 23, 98, 14)];
//        _stateLabel.text          = headTitleArr[indexPath.section];
        _stateLabel.textColor     = [UIColor colorWithHexString:@"#424242"];
        _stateLabel.font          = [UIFont fontWithName:@"PingFangSC-Light" size:14];
        _stateLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_stateLabel];
        
        
        
        _rightBtn = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-100, 23, 84, 14)];
        [_rightBtn setTitleColor:[UIColor colorWithHexString:@"#ff5252"] forState:UIControlStateNormal];
       // _rightLabel.textColor     = [UIColor colorWithHexString:@"#ff5252"];
        _rightBtn.titleLabel.font          = [UIFont fontWithName:@"PingFangSC-Light" size:14];
        _rightBtn.titleLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:_rightBtn];
        

    }
    return  self;
}
@end
