//
//  RequirementManegerCell.m
//  LvYue
//
//  Created by 郑洲 on 16/4/11.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "RequirementManegerCell.h"
#import "UIImageView+WebCache.h"

@interface RequirementManegerCell(){
    UILabel *typeLabel;
    UILabel *timeLabel;
    UILabel *noteLabel;
    UILabel *numLabel;
    UIView *imageBg;
    NSMutableArray *imageArr;
}

@end

@implementation RequirementManegerCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIImageView *typeImage = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 18, 20)];
        typeImage.image = [UIImage imageNamed:@"名称"];
        [self addSubview:typeImage];
        
        typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 10, 100, 20)];
        typeLabel.text = @"练唱歌";
        [self addSubview:typeLabel];
        
        UIImageView *timeImage = [[UIImageView alloc] initWithFrame:CGRectMake(15, 40, 17, 20)];
        timeImage.image = [UIImage imageNamed:@"时效"];
        [self addSubview:timeImage];
        
        timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 40, 200, 20)];
        timeLabel.text = @"";
        timeLabel.textColor = [UIColor grayColor];
        [self addSubview:timeLabel];
        
        noteLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 75, 25, 60, 20)];
        noteLabel.text = @"未成交";
        noteLabel.textColor = [UIColor grayColor];
        [self addSubview:noteLabel];
        
        numLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 70, SCREEN_WIDTH, 20)];
        numLabel.text = @"—————已有1位伙伴应邀—————";
        numLabel.textColor = [UIColor grayColor];
        numLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:numLabel];
        
        imageBg = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 50 * 5 - (5 + 1) * 10) / 2, 105, 50 * 5 + (5 + 1) * 10, 50)];
        [self addSubview:imageBg];
        
        imageArr = [NSMutableArray array];
        
        for (int i = 0; i < 5; i++) {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10 + i * 60, 0, 50, 50)];
            imageView.clipsToBounds = YES;
            imageView.layer.cornerRadius = 25;
            [imageBg addSubview:imageView];
            [imageArr addObject:imageView];
        }
    }
    return self;
}

- (void)createWithModel:(RequirementModel *)model {
    typeLabel.text = model.smallName;
    
    NSDate *datenow = [NSDate date];
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];
    
    if ([model.appointmentTime integerValue] > [model.deadTime integerValue]) {
        NSInteger day = ([model.deadTime integerValue] - [timeSp integerValue]) / (60 * 60 * 24);
        if (day >= 0) {
            if (day == 0) {
                timeLabel.text = [NSString stringWithFormat:@"1天后过期"];
            }else {
                timeLabel.text = [NSString stringWithFormat:@"%ld天后过期",(long)day];
            }
        }else {
            timeLabel.text = @"已过期";
        }
    }else {
        NSInteger day = ([model.appointmentTime integerValue] - [timeSp integerValue]) / (60 * 60 * 24);
        if (day >= 0) {
            if (day == 0) {
                timeLabel.text = [NSString stringWithFormat:@"1天后过期"];
            }else {
                timeLabel.text = [NSString stringWithFormat:@"%ld天后过期",(long)day];
            }
        }else {
            timeLabel.text = @"已过期";
        }
    }
    
    
    if ([model.status isEqualToString:@"0"]) {
        noteLabel.text = @"未成交";
    }else {
        noteLabel.text = @"已成交";
    }
    numLabel.text = [NSString stringWithFormat:@"—————已有%lu位伙伴应邀—————",(unsigned long)model.fUsers.count];
    
    NSInteger count = model.fUsers.count > 5 ? 5 : model.fUsers.count;
    imageBg.frame = CGRectMake((SCREEN_WIDTH - 50 * count - (count + 1) * 10) / 2, 105, 50 * count + (count + 1) * 10, 50);
    
    for (int i = 0; i < count; i++) {
        NSDictionary *dic = model.fUsers[i];
        UIImageView *imageView = imageArr[i];
        [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,dic[@"icon"]]] placeholderImage:nil options:SDWebImageRetryFailed];
    }
    
    if (model.fUsers.count == 0) {
        imageBg.hidden = YES;
    }else {
        imageBg.hidden = NO;
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
