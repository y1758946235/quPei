//
//  ReceGiftTableViewCell.m
//  LvYue
//
//  Created by X@Han on 17/3/21.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "ReceGiftTableViewCell.h"
#import "ReceiveGiftModel.h"
#import "otherZhuYeVC.h"
@implementation ReceGiftTableViewCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self createCell];
        
    }
    return self;
    
}
-(void)removeAllSubviews{
    for (UIView *view in self.contentView.subviews) {
        [view removeFromSuperview];
    }
}
-(void)createCell{
    [self removeAllSubviews];
    UIImageView *headimageV = [[UIImageView alloc]init];
    headimageV.frame = CGRectMake(SCREEN_WIDTH-62, 16, 38, 38);
    headimageV.layer.cornerRadius = 19;
    headimageV.clipsToBounds = YES;
    headimageV.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(gotToOtherHome)];
    [headimageV addGestureRecognizer:tap];
    [self.contentView addSubview:headimageV];
    self.headImageV = headimageV;
    
    
    UILabel * nickNameLabel = [[UILabel alloc]init];
    nickNameLabel.frame = CGRectMake(SCREEN_WIDTH-86, 70, 86, 20);
    nickNameLabel.text = @"Deborah";
    nickNameLabel.textAlignment = NSTextAlignmentCenter;
    nickNameLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
    nickNameLabel.textColor = [UIColor colorWithHexString:@"#757575"];
    [self.contentView addSubview:nickNameLabel];
    self.nickNameLabel = nickNameLabel;
    
    UILabel *giftPriceLabel = [[UILabel alloc]init];
    giftPriceLabel.frame = CGRectMake(90, 42, 56, 22);
    giftPriceLabel.text = @"礼物价值:";
    giftPriceLabel.textAlignment = NSTextAlignmentLeft;
    giftPriceLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
    giftPriceLabel.textColor = [UIColor colorWithHexString:@"#9e9e9e"];
    [self.contentView addSubview:giftPriceLabel];
    
    UILabel * giftGoldLabel = [[UILabel alloc]init];
    giftGoldLabel.frame = CGRectMake(146, 42, 150, 22);
    giftGoldLabel.textAlignment = NSTextAlignmentLeft;
    giftGoldLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
    giftGoldLabel.textColor = [UIColor colorWithHexString:@"#757575"];
     [self.contentView addSubview:giftGoldLabel];
    self.giftGoldLabel = giftGoldLabel;
    
//    UILabel * spendGoldLabel = [[UILabel alloc]init];
//    spendGoldLabel.frame = CGRectMake(80, 48, SCREEN_WIDTH-160, 12);
//    spendGoldLabel.textAlignment = NSTextAlignmentCenter;
//    spendGoldLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
//    spendGoldLabel.textColor = [UIColor colorWithHexString:@"#757575"];
//    [self.contentView addSubview:spendGoldLabel];
//    self.spendGoldLabel = spendGoldLabel;
    
//    UILabel *giveLabel = [[UILabel alloc]init];
//    giveLabel.frame = CGRectMake(100, 64, SCREEN_WIDTH-200, 20);
//    giveLabel.text = @"送你";
//    giveLabel.textAlignment = NSTextAlignmentCenter;
//    giveLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
//    giveLabel.textColor = [UIColor colorWithHexString:@"#757575"];
//    [self.contentView addSubview:giveLabel];
    
    UILabel * buyTimeLabel = [[UILabel alloc]init];
     buyTimeLabel.frame = CGRectMake(90, 72, SCREEN_WIDTH-200, 22);
     buyTimeLabel.text = @"217-1-6";
     buyTimeLabel.textAlignment = NSTextAlignmentLeft;
     buyTimeLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
     buyTimeLabel.textColor = [UIColor colorWithHexString:@"#bdbdbd"];
    [self.contentView addSubview: buyTimeLabel];
    self.buyTimeLabel = buyTimeLabel;
   
    
    UIImageView *giftImageV = [[UIImageView alloc]init];
    giftImageV.frame = CGRectMake(24, 24, 50, 50);
//    giftImageV.layer.cornerRadius = 24;
//    giftImageV.clipsToBounds = YES;
    [self.contentView addSubview:giftImageV];
    self.giftImageV = giftImageV;
    
    UILabel * giftNameLabel = [[UILabel alloc]init];
    giftNameLabel.frame = CGRectMake(90, 16, 150, 20);
    giftNameLabel.textAlignment = NSTextAlignmentLeft;
    giftNameLabel.text = @"玫瑰花";
    giftNameLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
    giftNameLabel.textColor = [UIColor colorWithHexString:@"#757575"];
    [self.contentView addSubview:giftNameLabel];
    self.giftNameLabel = giftNameLabel;
    
//    UILabel *giftmMoneyLabel = [[UILabel alloc]init];
//    giftmMoneyLabel.frame = CGRectMake(SCREEN_WIDTH-124, 136, 64, 20);
//    giftmMoneyLabel.text = @"可提取现金:";
//    giftmMoneyLabel.textAlignment = NSTextAlignmentCenter;
//    giftmMoneyLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
//    giftmMoneyLabel.textColor = [UIColor colorWithHexString:@"#9e9e9e"];
//    [self.contentView addSubview:giftmMoneyLabel];
//    
//    UILabel * giftMoneyLabel = [[UILabel alloc]init];
//    giftMoneyLabel.frame = CGRectMake(SCREEN_WIDTH-60, 136, 60, 20);
//    giftMoneyLabel.text = @"100元";
//    giftMoneyLabel.textAlignment = NSTextAlignmentRight;
//    giftMoneyLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
//    giftMoneyLabel.textColor = [UIColor colorWithHexString:@"#757575"];
//    [self.contentView addSubview:giftMoneyLabel];
//    self.giftMoneyLabel = giftMoneyLabel;
}

-(void)gotToOtherHome{
    otherZhuYeVC *vc = [[otherZhuYeVC alloc]init];
    vc.userNickName = _model.userNickname;
    vc.userId = _model.userId;
    [self.viewController.navigationController pushViewController:vc animated:YES];
}
- (void)setModel:(ReceiveGiftModel *)model{
    _model = model;
    [self createCell];
    NSURL *headUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,_model.userIcon]];
    [self.headImageV sd_setImageWithURL:headUrl];
    self.nickNameLabel.text = _model.userNickname;
    self.giftGoldLabel.text = [NSString stringWithFormat:@"%@金币",_model.goldPrice];
    self.buyTimeLabel.text = [CommonTool timestampSwitchTime:[_model.createTime doubleValue]/1000 andFormatter:@"YYYY-MM-dd"];
//    self.spendGoldLabel.text = [NSString stringWithFormat:@"花费%@金币",_model.goldPrice];
    
    NSURL *giftImageUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,_model.giftIcon]];
    [self.giftImageV sd_setImageWithURL:giftImageUrl placeholderImage:[UIImage imageNamed:@"logo108"]];
    self.giftNameLabel.text = _model.giftName;
    
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
