//
//  OrderDetailsFourthTableViewCell.m
//  豆客项目
//
//  Created by Xia Wei on 15/10/13.
//  Copyright © 2015年 Xia Wei. All rights reserved.
//

#import "OrderDetailsFourthTableViewCell.h"

@implementation OrderDetailsFourthTableViewCell

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *imageV = [[UIImageView alloc]initWithFrame:CGRectMake(15, 15, 15, 15)];
        imageV.image = [UIImage imageNamed:@"拍"];
        [self addSubview:imageV];
        
        UILabel *serviceContent = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(imageV.frame) + 15, CGRectGetMinY(imageV.frame),200,imageV.frame.size.height)];
        serviceContent.font = [UIFont systemFontOfSize:14];
        serviceContent.text = @"服务内容";
        [self addSubview:serviceContent];
        
        _content = [[UITextView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(imageV.frame) + 15, CGRectGetMaxY(serviceContent.frame) + 15,frame.size.width - CGRectGetMaxX(imageV.frame) - 15 - 30,70)];
        _content.font = [UIFont systemFontOfSize:13];
        [_content setTextColor:UIColorWithRGBA(164, 164, 164, 1)];
        [_content setBackgroundColor:UIColorWithRGBA(242, 242, 242, 1)];
        _content.editable = NO;
        [self addSubview:_content];
    }
    return self;
}

- (void)fillDataWithData:(NSString *)str{
    self.content.text = str;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
