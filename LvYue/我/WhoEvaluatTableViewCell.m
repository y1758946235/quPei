//
//  WhoEvaluatTableViewCell.m
//  LvYue
//
//  Created by X@Han on 17/4/26.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "WhoEvaluatTableViewCell.h"
#import "WhoEvaluationModel.h"
@implementation WhoEvaluatTableViewCell{
    WhoEvaluationModel * _model;
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
    
    
    self.nickLabel = [[UILabel alloc]initWithFrame:CGRectMake(72, 18, 98, 16)];
    self.nickLabel.textColor = [UIColor colorWithHexString:@"#424242"];
    self.nickLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:16];
    [self addSubview:self.nickLabel];
    
    self.gradeContentLabel = [[UILabel alloc]initWithFrame:CGRectMake(72, 39, SCREEN_WIDTH- 72-16, 22)];
    self.gradeContentLabel.textColor = [UIColor colorWithHexString:@"#9e9e9e"];
    self.gradeContentLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
    [self addSubview:self.gradeContentLabel];
    
    
    self.timeLabe = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-98-16, 16, 98, 12)];
    //    self.timeLabe = [[UILabel alloc]init];
    //    self.timeLabe.translatesAutoresizingMaskIntoConstraints = NO;
    self.timeLabe.textAlignment = NSTextAlignmentRight;
    self.timeLabe.textColor = [UIColor colorWithHexString:@"#9e9e9e"];
    self.timeLabe.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
    [self addSubview:self.timeLabe];
    

    
}

-(void)creatModel:(WhoEvaluationModel *)model{
    _model = model;
    self.nickLabel.text = _model.userNickname;
    NSURL *headUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,model.userIcon]];
    [self.headImage sd_setImageWithURL:headUrl];
    self.timeLabe.text =[CommonTool timestampSwitchTime:[_model.createTime doubleValue]/1000 andFormatter:@"YYYY-MM-dd"] ;
    self.gradeContentLabel.text = [NSString stringWithFormat:@"%@",_model.gradeContent];

    
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
