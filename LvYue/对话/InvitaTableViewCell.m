//
//  InvitaTableViewCell.m
//  LvYue
//
//  Created by X@Han on 17/4/20.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "InvitaTableViewCell.h"
#import "InvitaModel.h"
#import "otherZhuYeVC.h"
@implementation InvitaTableViewCell{
    InvitaModel * _model;
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle: style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self creatCell];
    }
    
    return self;
}


- (void)creatCell{
    
    
    self.headImage = [[UIImageView alloc]initWithFrame:CGRectMake(16, 16, 40, 40)];
    self.headImage.layer.cornerRadius = 20;
    self.headImage.clipsToBounds = YES;
    [self addSubview:self.headImage];
    self.headImage.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(goOtherVC)];
    [self.headImage addGestureRecognizer:tap];
    
    
    self.nickLabel = [[UILabel alloc]initWithFrame:CGRectMake(72, 14, 98, 20)];
    self.nickLabel.textColor = [UIColor colorWithHexString:@"#424242"];
    self.nickLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:16];
    [self addSubview:self.nickLabel];
    
   
    
    self.contetLabel = [[UILabel alloc]initWithFrame:CGRectMake(72, 44, SCREEN_WIDTH-96, 12)];
    self.contetLabel.textColor = [UIColor colorWithHexString:@"#9e9e9e"];
    self.contetLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
    [self addSubview:self.contetLabel];
    
    self.timeLabe = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-98-16, 16, 98, 12)];
    self.timeLabe.textAlignment = NSTextAlignmentRight;
    self.timeLabe.textColor = [UIColor colorWithHexString:@"#9e9e9e"];
    self.timeLabe.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
    [self addSubview:self.timeLabe];
}

-(void)goOtherVC{
    otherZhuYeVC *VC = [[otherZhuYeVC alloc]init];
    VC.userNickName = _model.userNickname;
    VC.userId = _model.userId;
    [self.viewController.navigationController pushViewController:VC animated:YES];
}
- (void)fillDataWithModel:(InvitaModel *)model{
    
    _model = model;
    self.contetLabel.text = [NSString stringWithFormat:@"%@邀请你去参加ta的%@约会",model.userNickname,model.dateTypeName] ;
//    self.timeLabe.text = [CommonTool timestampSwitchTime:[model.createTime integerValue] andFormatter:@"YYYY-MM-dd hh:mm:ss"];
    self.timeLabe.text = [CommonTool updateTimeForRow:model.createTime];
    self.nickLabel.text = model.userNickname;
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,model.userIcon]];
    [self.headImage sd_setImageWithURL:url];
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
