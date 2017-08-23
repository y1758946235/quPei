//
//  DyVideoPlayDetailTableViewCell.m
//  LvYue
//
//  Created by X@Han on 17/8/3.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "DyVideoPlayDetailTableViewCell.h"
#import "DyVideoPlayerDetailModel.h"
#import "DyVideoPlayerDetailModel.h"
#import "MyInfoVC.h"
#import "otherZhuYeVC.h"

@interface DyVideoPlayDetailTableViewCell ()
{
    DyVideoPlayerDetailModel *_model;
}
@end
@implementation DyVideoPlayDetailTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self creatUI];
    }
    return self;
}


-(void)creatUI{
    UIImageView *headImagV = [[UIImageView alloc]init];
    headImagV.frame = CGRectMake(18, 24, 40, 40);
    headImagV.layer.cornerRadius = 20;
    headImagV.clipsToBounds = YES;
    headImagV.userInteractionEnabled  = YES;
    [self.contentView addSubview:headImagV];
    self.headImageV = headImagV;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(goOtherHome)];
    [self.headImageV addGestureRecognizer:tap];
    
    UILabel *nickLabel = [[UILabel alloc]init];
    nickLabel.text = @"nick";
    nickLabel.frame = CGRectMake(74, 26, 170, 16);
    nickLabel.font = [UIFont systemFontOfSize:13];
    nickLabel.textColor = [UIColor colorWithHexString:@"#424242"];
    [self.contentView addSubview:nickLabel];
    self.nickLabel  = nickLabel;
    
        //性别图片
         UIImageView *sexImage = [[UIImageView alloc]initWithFrame:CGRectMake(74, 48, 10, 10)];
        [self.contentView addSubview:sexImage];
        self.sexImage = sexImage;
    
    
        //年龄
        UILabel *ageLabel = [[UILabel alloc]initWithFrame:CGRectMake(94, 42, 40, 22)];
    
        ageLabel.textColor = [UIColor colorWithHexString:@"#424242"];
        ageLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
        [self.contentView addSubview:ageLabel];
       self.ageLabel = ageLabel;
    
    
    UILabel *contLabel = [[UILabel alloc]init];
    contLabel.text = @"qwudhqwiudkbqgwdv";
    contLabel.font = [UIFont systemFontOfSize:14];
    contLabel.numberOfLines = 0;
    contLabel.textColor = [UIColor colorWithHexString:@"#424242"];
    [self.contentView addSubview:contLabel];
    self.contLabel  = contLabel;
}

-(void)creatModel:(DyVideoPlayerDetailModel*)model{
    _model = model;
    NSURL *headUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,model.userIcon]];
    
    [self.headImageV sd_setImageWithURL:headUrl];
    
    self.nickLabel.text = model.userNickname;
    self.contLabel.text = model.videoComment;
    self.contLabel.frame = CGRectMake(74, 74, SCREEN_WIDTH-92, model.contLabelHeight);
    
    if ([[NSString stringWithFormat:@"%@",model.userSex] isEqualToString:@"0"]) {
        self.sexImage.image = [UIImage imageNamed:@"male"];
    }else{
         self.sexImage.image = [UIImage imageNamed:@"female"];
    }
    
    self.ageLabel.text = [NSString stringWithFormat:@"%@",model.userAge];
}
#pragma mark  --进入别人主页
- (void)goOtherHome{
    //    appointModel *model = self.dateTypeArr[sender.tag-1000];
    if ([[CommonTool getUserID]  isEqualToString:[NSString stringWithFormat:@"%@",_model.userId]]) {
        MyInfoVC *inVC = [[MyInfoVC alloc]init];
        
        [self.viewController.navigationController pushViewController:inVC animated:YES];
    }else{
        
        
        otherZhuYeVC *other = [[otherZhuYeVC alloc]init];
        other.userNickName = _model.userNickname;
        other.userId = [NSString stringWithFormat:@"%@",_model.userId];    //别人ID
        
        [self.viewController.navigationController pushViewController:other animated:YES];}
    
    
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
