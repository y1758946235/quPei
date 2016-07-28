//
//  ScrollView.m
//  LvYue
//
//  Created by 郑洲 on 16/4/8.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "ScrollView.h"

@implementation ScrollView
@synthesize titleLabel;
@synthesize newsButton;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 20)];
        titleLabel.textColor=[UIColor whiteColor];
        titleLabel.backgroundColor=[UIColor clearColor];
        titleLabel.font=[UIFont boldSystemFontOfSize:15.0];
        titleLabel.numberOfLines = 1;
        [self addSubview:titleLabel];

        newsButton=[UIButton buttonWithType:UIButtonTypeCustom];
        [newsButton setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addSubview:newsButton];
    }
    return self;
}

-(void)setViewWithTitle:(NSString *)title{
    [titleLabel setText:title];
}

@end
