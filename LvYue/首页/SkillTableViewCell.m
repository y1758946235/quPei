//
//  SkillTableViewCell.m
//  LvYue
//
//  Created by 郑洲 on 16/4/9.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "SkillTableViewCell.h"

@interface SkillTableViewCell(){
    UILabel *skillNameLabel;
    UILabel *underLinePrice;
    UILabel *onLinePrice;
    UILabel *skillDetail;
    UILabel *publishTime;
    UILabel *noteTime;
}

@end

@implementation SkillTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        skillNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, SCREEN_WIDTH - 30, 20)];
        skillNameLabel.text = @"游泳";
        skillNameLabel.font = [UIFont systemFontOfSize:15];
        [self addSubview:skillNameLabel];
        
        UILabel *underLine = [[UILabel alloc] initWithFrame:CGRectMake(15, 45, 80, 20)];
        underLine.text = @"线下服务";
        underLine.font = [UIFont systemFontOfSize:14];
//        [self addSubview:underLine];
        
        underLinePrice = [[UILabel alloc] initWithFrame:CGRectMake(85, 45, 100, 20)];
        underLinePrice.textColor = [UIColor grayColor];
        underLinePrice.text = @"100元/小时";
        underLinePrice.font = [UIFont systemFontOfSize:14];
//        [self addSubview:underLinePrice];
        
        UILabel *onLine = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2, 45, 80, 20)];
        onLine.text = @"电话咨询";
        onLine.font = [UIFont systemFontOfSize:14];
//        [self addSubview:onLine];
        
        onLinePrice = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 + 70, 45, 100, 20)];
        onLinePrice.textColor = [UIColor grayColor];
        onLinePrice.text = @"2元/分钟";
        onLinePrice.font = [UIFont systemFontOfSize:14];
//        [self addSubview:onLinePrice];
        
        skillDetail = [[UILabel alloc] initWithFrame:CGRectMake(15, 80, SCREEN_WIDTH - 60, 100)];
        skillDetail.numberOfLines = 0;
        skillDetail.textColor = [UIColor grayColor];
        skillDetail.font = [UIFont systemFontOfSize:14];
        [self addSubview:skillDetail];
        
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

- (void)createWithModel:(SkillModel *)model {
    skillNameLabel.text = model.skillName;
//    if (![model.underLinePrice isEqualToString:@"<null>"]) {
//        underLinePrice.text = [NSString stringWithFormat:@"%@元/小时",model.underLinePrice];
//    }else {
//        underLinePrice.text = @"";
//    }
//    if (![model.onLinePrice isEqualToString:@"<null>"]) {
//        onLinePrice.text = [NSString stringWithFormat:@"%@元/分钟",model.onLinePrice];
//    }else {
//        onLinePrice.text = @"";
//    }
    publishTime.text = model.publishTime;
    skillDetail.text = model.skillDetail;
    
    CGRect rect = [skillDetail.text boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 60, 20) options:NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName:skillDetail.font} context:nil];
    skillDetail.frame = CGRectMake(15, 45, SCREEN_WIDTH - 60, rect.size.height);
    noteTime.frame = CGRectMake(15, 45 + rect.size.height + 15, 150, 20);
    publishTime.frame = CGRectMake(85, 45 + rect.size.height + 15, 150, 20);
    
    UIView *line  = [[UIView alloc] initWithFrame:CGRectMake(10, 45 + rect.size.height + 49, SCREEN_WIDTH - 20, 1)];
    line.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    [self addSubview:line];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
