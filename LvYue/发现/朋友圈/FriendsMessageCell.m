//
//  FriendsMessageCell.m
//  LvYueDemo
//
//  Created by 蒋俊 on 15/10/12.
//  Copyright (c) 2015年 vison. All rights reserved.
//

#import "FriendsMessageCell.h"

@implementation FriendsMessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _headImg = [[UIImageView alloc]initWithFrame:CGRectMake(Kinterval/2, Kinterval/2, 50, 50)];
        _headImg.layer.cornerRadius = 5.0;
        [self addSubview:_headImg];

        _rightImage = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-70, Kinterval/2, 60, 60)];
        [self addSubview:_rightImage];
        
        _rightLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-70, Kinterval/2, 60, 60)];
        _rightLabel.textColor = FONTCOLOR_BLACK;
        _rightLabel.font = [UIFont systemFontOfSize:13];
        _rightLabel.numberOfLines = 0;
        [self addSubview:_rightLabel];
        
        _nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_headImg.frame)+Kinterval/2, Kinterval/2, SCREEN_WIDTH-CGRectGetMaxX(_headImg.frame)-Kinterval/2-70, 20)];
        _nameLabel.textColor = FONTCOLOR_BLACK;
        _nameLabel.font = [UIFont systemFontOfSize:13];
        [self addSubview:_nameLabel];
        
        _commentLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_headImg.frame)+Kinterval/2, CGRectGetMaxY(_nameLabel.frame),  SCREEN_WIDTH-CGRectGetMaxX(_headImg.frame)-Kinterval/2-70, 20)];
        _commentLabel.numberOfLines = 0;
        _commentLabel.font = [UIFont systemFontOfSize:13];
        [self addSubview:_commentLabel];
        
        _timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_headImg.frame)+Kinterval/2, CGRectGetMaxY(_commentLabel.frame),200, 20)];
        _timeLabel.textColor = FONTCOLOR_BLACK;
        _timeLabel.font = [UIFont systemFontOfSize:13];
        [self addSubview:_timeLabel];
    }
    return self;
}

@end
