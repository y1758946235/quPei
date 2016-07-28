//
//  HotMessageCollectionViewCell.m
//  LvYue
//
//  Created by 郑洲 on 16/3/15.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "HotMessageCollectionViewCell.h"

@implementation HotMessageCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1];
        
        _showImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, frame.size.width - 20, frame.size.height - 100)];
        _showImageView.image = [UIImage imageNamed:@"bg-1"];
        [self addSubview:_showImageView];
        
        _markLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, _showImageView.frame.size.height + 5, frame.size.width - 20, 70)];
        _markLabel.numberOfLines = 0;
        _markLabel.font = [UIFont systemFontOfSize:16];
        _markLabel.text = @"这里是标题";
        [self addSubview:_markLabel];
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, _markLabel.frame.size.height + 5 + _markLabel.frame.origin.y, frame.size.width - 20, 20)];
        _timeLabel.textColor = [UIColor lightGrayColor];
        _timeLabel.text = @"03-05 15:30";
        _timeLabel.font = [UIFont systemFontOfSize:15];
        [self addSubview:_timeLabel];
    }
    return self;
}

- (void)fillData:(HotModel *)model {
    _showImageView.image = model.image;
    _showImageView.frame = CGRectMake(10, 0, SCREEN_WIDTH - 20, model.imageHeight);
    _markLabel.text = model.intro;
    _markLabel.frame = CGRectMake(10, _showImageView.frame.size.height + 5, SCREEN_WIDTH - 20, model.textHeight);
    _timeLabel.text = model.createTime;
    _timeLabel.frame = CGRectMake(10, model.cellHeight - 25, SCREEN_WIDTH - 20, 20);
}
@end
