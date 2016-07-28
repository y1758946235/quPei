//
//  RequirementDetailTopCell.m
//  LvYue
//
//  Created by 郑洲 on 16/4/15.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "RequirementDetailTopCell.h"


@interface RequirementDetailTopCell(){
    NSMutableArray *labelArray;
}

@end

@implementation RequirementDetailTopCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _headImage = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 60) / 2, 15, 60, 60)];
        _headImage.image = [UIImage imageNamed:@""];
        _headImage.clipsToBounds = YES;
        _headImage.layer.cornerRadius = 30;
        [self addSubview:_headImage];
        
        _imageBtn = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 60) / 2, 15, 60, 60)];
        _imageBtn.backgroundColor = [UIColor clearColor];
        [self addSubview:_imageBtn];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 77, SCREEN_WIDTH, 20)];
        _nameLabel.font = [UIFont systemFontOfSize:14];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_nameLabel];
        
        _nlabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, SCREEN_WIDTH, 15)];
        _nlabel.text = @"2天后过期";
        _nlabel.textColor = [UIColor grayColor];
        _nlabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_nlabel];
        
        NSArray *detailArray = @[@"有效时间",@"性别要求",@"活动方式",@"活动地址",@"年龄要求",@"需求详情"];
        labelArray = [NSMutableArray array];
        
        for (int i = 0; i < 6; i++) {
            UILabel *noteLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 145 + i * 50, 100, 20)];
            noteLabel.text = detailArray[i];
            noteLabel.font = [UIFont systemFontOfSize:17];
            [self addSubview:noteLabel];
            
            UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 135 + i * 50, SCREEN_WIDTH - 120, 40)];
            detailLabel.text = @"";
            detailLabel.font = [UIFont systemFontOfSize:16];
            detailLabel.textColor = [UIColor grayColor];
            detailLabel.numberOfLines = 0;
            [self addSubview:detailLabel];
            
            [labelArray addObject:detailLabel];
        }
    }
    return self;
}

- (void)createWithDic:(NSDictionary *)dic {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    
    NSInteger appointmentTime = [[dateFormatter dateFromString:[NSString stringWithFormat:@"%@",dic[@"appointmentTime"]]] timeIntervalSince1970];
    NSInteger deadTime = [[dateFormatter dateFromString:[NSString stringWithFormat:@"%@",dic[@"deadTime"]]] timeIntervalSince1970];
    
    NSDate *datenow = [NSDate date];
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];
    
    UILabel *timeLabel = labelArray[0];
    NSString *createTime = [NSString stringWithFormat:@"%@",dic[@"createTime"]];
    
    if (appointmentTime > deadTime) {
        NSInteger day = (deadTime - [timeSp integerValue]) / (60 * 60 * 24);
        if (day >= 0) {
            if (day == 0) {
                _nlabel.text = [NSString stringWithFormat:@"1天后过期"];
            }else {
                _nlabel.text = [NSString stringWithFormat:@"%ld天后过期",(long)day];
            }
        }else {
            _nlabel.text = @"已过期";
        }
        if (createTime.length > 10) {
            timeLabel.text = [NSString stringWithFormat:@"%@ 至 %@",[createTime substringToIndex:10],dic[@"deadTime"]];
        }
    }else {
        NSInteger day = (appointmentTime - [timeSp integerValue]) / (60 * 60 * 24);
        if (day >= 0) {
            if (day == 0) {
                _nlabel.text = [NSString stringWithFormat:@"1天后过期"];
            }else {
                _nlabel.text = [NSString stringWithFormat:@"%ld天后过期",(long)day];
            }

        }else {
            _nlabel.text = @"已过期";
        }
        if (createTime.length > 10) {
            timeLabel.text = [NSString stringWithFormat:@"%@ 至 %@",[createTime substringToIndex:10],dic[@"appointmentTime"]];
        }
    }
    
    UILabel *sexLabel = labelArray[1];
    if ([dic[@"sex"] integerValue] == 0) {
        sexLabel.text = @"不限";
    }else if ([dic[@"sex"] integerValue] == 1) {
        sexLabel.text = @"男";
    }else {
        sexLabel.text = @"女";
    }
    
    UILabel *typeLabel = labelArray[2];
    NSString *serviceType = [NSString stringWithFormat:@"%@",dic[@"serviceType"]];
    NSArray *array = [serviceType componentsSeparatedByString:@","];
    NSMutableString *type = [NSMutableString stringWithString:@""];
    for (NSString *subString in array) {
        if ([subString isEqualToString:@"0"]) {
            [type appendString:@"TA来找我  "];
        }else if ([subString isEqualToString:@"1"]) {
            [type appendString:@"我去找TA  "];
        }else if ([subString isEqualToString:@"2"]) {
            [type appendString:@"电话咨询或网上服务  "];
        }
    }
    typeLabel.text = type;
    
    UILabel *addressLabel = labelArray[3];
    addressLabel.text = dic[@"address"];
    
    UILabel *ageLabel = labelArray[4];
    NSString *ageType = [NSString stringWithFormat:@"%@",dic[@"age"]];
    NSArray *ageArray = [ageType componentsSeparatedByString:@","];
    NSMutableString *age = [NSMutableString stringWithString:@""];
    for (NSString *subString in ageArray) {
        if ([subString isEqualToString:@"0"]) {
            [age appendString:@"18岁-25岁  "];
        }else if ([subString isEqualToString:@"1"]) {
            [age appendString:@"26岁-30岁  "];
        }else if ([subString isEqualToString:@"2"]) {
            [age appendString:@"30岁以上  "];
        }
    }
    ageLabel.text = age;
    
    UILabel *detailLabel = labelArray[5];
    detailLabel.text = dic[@"detail"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
