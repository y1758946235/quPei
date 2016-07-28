//
//  RequirementListCell.m
//  LvYue
//
//  Created by 郑洲 on 16/4/11.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "RequirementListCell.h"
#import "UIImageView+WebCache.h"

@interface RequirementListCell(){
    UIImageView *headView;
    UILabel *nameLabel;
    UIImageView *sexView;
    UILabel *ageLabel;
    UILabel *requirementNameLabel;
    UILabel *durationLabel;
    UILabel *requirementDetail;
    UILabel *publishTime;
    UILabel *noteTime;
}

@end

@implementation RequirementListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        headView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 50, 50)];
        headView.clipsToBounds = YES;
        headView.layer.cornerRadius = 5.0;
        [self addSubview:headView];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 15, 50, 20)];
        nameLabel.font = [UIFont systemFontOfSize:18];
        [self addSubview:nameLabel];
        
        sexView = [[UIImageView alloc] initWithFrame:CGRectMake(130, 17, 13, 15)];
        sexView.image = [UIImage imageNamed:@"男"];
        [self addSubview:sexView];
        
        ageLabel = [[UILabel alloc] initWithFrame:CGRectMake(155, 15, 50, 20)];
        ageLabel.font = [UIFont systemFontOfSize:15];
        [self addSubview:ageLabel];
        
        requirementNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 100, 15, SCREEN_WIDTH - 30, 20)];
        requirementNameLabel.text = @"游泳";
        requirementNameLabel.font = [UIFont systemFontOfSize:15];
        [self addSubview:requirementNameLabel];
        
        durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 45, 180, 20)];
        durationLabel.text = @"还有2天过期";
        durationLabel.font = [UIFont systemFontOfSize:14];
        [self addSubview:durationLabel];
        
        requirementDetail = [[UILabel alloc] initWithFrame:CGRectMake(15, 80, SCREEN_WIDTH - 60, 100)];
        requirementDetail.numberOfLines = 0;
        requirementDetail.textColor = [UIColor grayColor];
        requirementDetail.font = [UIFont systemFontOfSize:14];
        [self addSubview:requirementDetail];
        
        noteTime = [[UILabel alloc] initWithFrame:CGRectMake(15, 195, 80, 20)];
        noteTime.text = @"发布时间";
        noteTime.font = [UIFont systemFontOfSize:14];
        [self addSubview:noteTime];
        
        publishTime = [[UILabel alloc] initWithFrame:CGRectMake(85, 195, 150, 20)];
        publishTime.font = [UIFont systemFontOfSize:14];
        publishTime.text = @"2016-03-30";
        publishTime.textColor = [UIColor grayColor];
        [self addSubview:publishTime];
        
    }
    return self;
}

- (void)createWithModel:(RequirementModel *)model {
    [headView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,model.userIcon]] placeholderImage:nil];
    nameLabel.text = model.userName;
    if ([model.userSex integerValue] == 1) {
        sexView.image = [UIImage imageNamed:@"女"];
    }else {
        sexView.image = [UIImage imageNamed:@"男"];
    }
    ageLabel.text = [NSString stringWithFormat:@"%@岁",model.userAge];
    CGRect nameRect = [nameLabel.text boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 60, 20) options:NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName:nameLabel.font} context:nil];
    nameLabel.frame = CGRectMake(80, 15, nameRect.size.width, 20);
    sexView.frame = CGRectMake(nameRect.size.width + 85, 17, 13, 15);
    ageLabel.frame = CGRectMake(nameRect.size.width + 103, 15, 50, 20);
    
    requirementNameLabel.text = [NSString stringWithFormat:@"服务:%@",model.requirementName];
    CGRect rRect = [requirementNameLabel.text boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 60, 20) options:NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName:requirementNameLabel.font} context:nil];
    requirementNameLabel.frame = CGRectMake(SCREEN_WIDTH - rRect.size.width - 10, 15, rRect.size.width, 20);
    publishTime.text = model.publishTime;
    requirementDetail.text = model.requirementDetail;
    
    NSDate *datenow = [NSDate date];
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];
    
    if (model.appointmentTime > model.deadTime) {
        NSInteger day = ([model.deadTime integerValue] - [timeSp integerValue]) / (60 * 60 * 24);
        if (day >= 0) {
            if (day == 0) {
                durationLabel.text = [NSString stringWithFormat:@"1天后过期"];
            }else {
                durationLabel.text = [NSString stringWithFormat:@"%ld天后过期",(long)day];
            }
        }else {
            durationLabel.text = @"已过期";
        }
    }else {
        NSInteger day = ([model.appointmentTime integerValue] - [timeSp integerValue]) / (60 * 60 * 24);
        if (day >= 0) {
            if (day == 0) {
                durationLabel.text = [NSString stringWithFormat:@"1天后过期"];
            }else {
                durationLabel.text = [NSString stringWithFormat:@"%ld天后过期",(long)day];
            }
            
        }else {
            durationLabel.text = @"已过期";
        }
    }
    
    CGRect rect = [requirementDetail.text boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 60, 20) options:NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName:requirementDetail.font} context:nil];
    requirementDetail.frame = CGRectMake(15, 80, SCREEN_WIDTH - 60, rect.size.height);
    noteTime.frame = CGRectMake(15, 80 + rect.size.height + 15, 150, 20);
    publishTime.frame = CGRectMake(85, 80 + rect.size.height + 15, 150, 20);
    
    UIView *line  = [[UIView alloc] initWithFrame:CGRectMake(10, 80 + rect.size.height + 49, SCREEN_WIDTH - 20, 1)];
    line.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    [self addSubview:line];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
