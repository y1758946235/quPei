//
//  InvitedPeopleTableViewCell.m
//  LvYue
//
//  Created by 郑洲 on 16/4/11.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "InvitedPeopleTableViewCell.h"
#import "UIImageView+EMWebCache.h"

@interface InvitedPeopleTableViewCell(){
    UIImageView *imageView;
    UILabel *nameLabel;
    UILabel *ageLabel;
    UIImageView *sexView;
    NSMutableArray *dataLabelArr;
    UILabel *disLabel;
}

@end

@implementation InvitedPeopleTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 30, 10, 60, 60)];
        imageView.image = [UIImage imageNamed:@"button"];
        imageView.clipsToBounds = YES;
        imageView.layer.cornerRadius = 30;
        [self addSubview:imageView];
        
        _peopleBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 30, 10, 60, 60)];
        _peopleBtn.backgroundColor = [UIColor clearColor];
        [self addSubview:_peopleBtn];
        
        NSString *str = @"Shmily";
        CGRect rect = [str boundingRectWithSize:CGSizeMake(SCREEN_WIDTH, 20) options:NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20]} context:nil];
        
        nameLabel  = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - rect.size.width) / 2, 75, rect.size.width, 20)];
        nameLabel.font = [UIFont systemFontOfSize:20];
        nameLabel.text = str;
        [self addSubview:nameLabel];
        
        ageLabel = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH + rect.size.width) / 2 + 5, 80, 40, 15)];
        ageLabel.text = @"25岁";
        ageLabel.font = [UIFont systemFontOfSize:16];
        ageLabel.textColor = [UIColor grayColor];
        [self addSubview:ageLabel];
        
        sexView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH + rect.size.width) / 2 + 45, 80, 11, 13)];
        sexView.image = [UIImage imageNamed:@"女"];
        [self addSubview:sexView];
        
        NSArray *array = @[
//                           @"线下服务",@"电话咨询",
                           @"TA的优势",@"应邀时间"];
        dataLabelArr = [NSMutableArray array];
        _btnArr = [NSMutableArray array];
        NSArray *arr = @[@"发送消息"
//                         ,@"支付全额"
                         ];
        CGFloat btnWidth = (SCREEN_WIDTH - 30);
        
        for (int i = 0; i < 2; i++) {
            UILabel *noteLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 130 + i * 50, 100, 20)];
            noteLabel.text = array[i];
            noteLabel.font = [UIFont systemFontOfSize:17];
            [self addSubview:noteLabel];
            
            UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 120 + i * 50, SCREEN_WIDTH - 120, 40)];
            detailLabel.tag = i;
            detailLabel.font = [UIFont systemFontOfSize:16];
            detailLabel.textColor = [UIColor grayColor];
            detailLabel.numberOfLines = 0;
            [self addSubview:detailLabel];
            [dataLabelArr addObject:detailLabel];
        }
        
//        for (int i = 0; i < 2; i++) {
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(10 + 0 * (btnWidth + 10), 215, btnWidth, 30)];
            btn.backgroundColor = RGBACOLOR(29, 189, 159, 1);
            btn.layer.cornerRadius = 10;
            btn.hidden = YES;
            btn.titleLabel.font = [UIFont systemFontOfSize:14];
            [btn setTitle:arr[0] forState:UIControlStateNormal];
            [self addSubview:btn];
            [_btnArr addObject:btn];
//        }
        
        UIImageView *disImage = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 77, 183, 10, 14)];
        disImage.image = [UIImage imageNamed:@"map-4"];
        [self addSubview:disImage];
        
        disLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 65, 170, 70, 40)];
        disLabel.font = [UIFont systemFontOfSize:16];
        disLabel.textColor = [UIColor grayColor];
        [self addSubview:disLabel];
    }
    return self;
}

- (void)createWithModel:(PeopleModel *)model {
    [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,model.imageName]] placeholderImage:nil];
    nameLabel.text = model.peopleName;
    CGRect rect = [nameLabel.text boundingRectWithSize:CGSizeMake(SCREEN_WIDTH, 20) options:NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName:nameLabel.font} context:nil];
    nameLabel.frame = CGRectMake((SCREEN_WIDTH - rect.size.width) / 2, 75, rect.size.width, 20);
    ageLabel.frame = CGRectMake((SCREEN_WIDTH + rect.size.width) / 2 + 5, 80, 40, 15);
    ageLabel.text = [NSString stringWithFormat:@"%@岁",model.age];
    sexView.frame = CGRectMake((SCREEN_WIDTH + rect.size.width) / 2 + 45, 80, 11, 13);
    if ([model.sex isEqualToString:@"0"]) {
        sexView.image = [UIImage imageNamed:@"男"];
    }else {
        sexView.image = [UIImage imageNamed:@"女"];
    }
//    UILabel *priceLabel = dataLabelArr[0];
//    if (![model.price isEqualToString:@"<null>"]) {
//        priceLabel.text = [NSString stringWithFormat:@"%@元/小时",model.price];
//    }
//    
//    UILabel *onlinePriceLabel = dataLabelArr[1];
//    if (![model.onLinePrice isEqualToString:@"<null>"]) {
//        onlinePriceLabel.text = [NSString stringWithFormat:@"%@元/分钟",model.onLinePrice];
//    }
    
    UILabel *advantageLabel = dataLabelArr[0];
    advantageLabel.text = model.advantage;
    
    UILabel *timeLabel = dataLabelArr[1];
    timeLabel.text = [model.invitedTime substringToIndex:model.invitedTime.length - 3];
    
    disLabel.text = [NSString stringWithFormat:@"%.1fkm",[model.distance floatValue] / 1000];
    
    if (_isMyself) {
//        for (int i = 0; i < 2; i++) {
            UIButton *btn = _btnArr[0];
            btn.hidden = NO;
//        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
