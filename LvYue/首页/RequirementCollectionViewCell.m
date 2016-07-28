//
//  RequirementCollectionViewCell.m
//  LvYue
//
//  Created by 郑洲 on 16/4/6.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "RequirementCollectionViewCell.h"

@implementation RequirementCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _label.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.font = [UIFont systemFontOfSize:10];
        _label.layer.cornerRadius = 5.0;
        _label.clipsToBounds = YES;
        [self addSubview:_label];
    }
    return self;
}

@end
