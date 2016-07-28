//
//  UploadImageCell.m
//  LvYueDemo
//
//  Created by 蒋俊 on 15/10/12.
//  Copyright (c) 2015年 vison. All rights reserved.
//

#import "UploadImageCell.h"

@implementation UploadImageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _btn1 = [[UIButton alloc]initWithFrame:CGRectMake(Kinterval,5, 75, 75)];
        [_btn1 setBackgroundImage:[UIImage imageNamed:@"button"] forState:UIControlStateNormal];
        _btn1.tag = 100;
        [self addSubview:_btn1];
        
        _btn2 = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_btn1.frame)+5,5, 75, 75)];
        _btn2.hidden = YES;
        _btn2.tag = 101;
        [self addSubview:_btn2];

        _btn3 = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_btn2.frame)+5,5, 75, 75)];
        _btn3.hidden = YES;
        _btn3.tag = 102;
        [self addSubview:_btn3];

        _btn4 = [[UIButton alloc]initWithFrame:CGRectMake(Kinterval,CGRectGetMaxY(_btn1.frame)+5, 75, 75)];
        _btn4.hidden = YES;
        _btn4.tag = 103;
        [self addSubview:_btn4];

        _btn5 = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_btn4.frame)+5,CGRectGetMaxY(_btn1.frame)+5, 75, 75)];
        _btn5.hidden = YES;
        _btn5.tag = 104;
        [self addSubview:_btn5];

        _btn6 = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_btn5.frame)+5,CGRectGetMaxY(_btn1.frame)+5, 75, 75)];
        _btn6.hidden = YES;
        _btn6.tag = 105;
        [self addSubview:_btn6];

        _btn7 = [[UIButton alloc]initWithFrame:CGRectMake(Kinterval,CGRectGetMaxY(_btn6.frame)+5, 75, 75)];
        _btn7.hidden = YES;
        _btn7.tag = 106;
        [self addSubview:_btn7];

        _btn8 = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_btn7.frame)+5,CGRectGetMaxY(_btn6.frame)+5, 75, 75)];
        _btn8.hidden = YES;
        _btn8.tag = 107;
        [self addSubview:_btn8];

        _btn9 = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_btn8.frame)+5,CGRectGetMaxY(_btn6.frame)+5, 75, 75)];
        _btn9.hidden = YES;
        _btn9.tag = 108;
        [self addSubview:_btn9];

        _reminderLabel = [[UILabel alloc]initWithFrame:CGRectMake(Kinterval, CGRectGetMaxY(_btn1.frame)+5, 200, 20)];
        _reminderLabel.textColor = UIColorWithRGBA(191, 191, 191, 1);
        _reminderLabel.font = [UIFont systemFontOfSize:13];
        _reminderLabel.text = @"点击上传图片";
        [self addSubview:_reminderLabel];
    }
    return self;
}


@end
