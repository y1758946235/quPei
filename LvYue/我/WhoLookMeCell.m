//
//  WhoLookMeCell.m
//  LvYue
//
//  Created by X@Han on 16/12/19.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "WhoLookMeCell.h"
#import "WhoLookMeModel.h"
@implementation WhoLookMeCell



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
    
    self.vipImageBtn = [[UIButton alloc]initWithFrame:CGRectMake(48, 20, 32, 12)];
//    self.vipImageBtn.image = [UIImage imageNamed:@"vip"];
    [self addSubview:self.vipImageBtn];
     self.vipImageBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
             self.vipImageBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 16, 0, 0);
     self.vipImageBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 16);
    [self.vipImageBtn setImage:[UIImage imageNamed:@"vip"] forState:UIControlStateNormal];
    self.vipImageBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
    [self.vipImageBtn setTitleColor:[UIColor colorWithHexString:@"#ff5252"] forState:UIControlStateNormal];
    
    self.nickLabel = [[UILabel alloc]initWithFrame:CGRectMake(72, 18, 98, 16)];
    self.nickLabel.textColor = [UIColor colorWithHexString:@"#424242"];
    self.nickLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:16];
    [self addSubview:self.nickLabel];
 
    self.ageLabel = [[UILabel alloc]initWithFrame:CGRectMake(72, 44, 28, 12)];
    self.ageLabel.textColor = [UIColor colorWithHexString:@"#9e9e9e"];
    self.ageLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
    [self addSubview:self.ageLabel];
    
    self.heightLabel = [[UILabel alloc]initWithFrame:CGRectMake(116, 44, 36, 12)];
    self.heightLabel.textColor = [UIColor colorWithHexString:@"#9e9e9e"];
    self.heightLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
    [self addSubview:self.heightLabel];
    
    self.colleanLabel = [[UILabel alloc]initWithFrame:CGRectMake(168, 44, 36, 12)];
    self.colleanLabel.textColor = [UIColor colorWithHexString:@"#9e9e9e"];
    self.colleanLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
    [self addSubview:self.colleanLabel];
    
   self.timeLabe = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-98-16, 16, 98, 12)];
//    self.timeLabe = [[UILabel alloc]init];
//    self.timeLabe.translatesAutoresizingMaskIntoConstraints = NO;
    self.timeLabe.textAlignment = NSTextAlignmentRight;
    self.timeLabe.textColor = [UIColor colorWithHexString:@"#9e9e9e"];
    self.timeLabe.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
    [self addSubview:self.timeLabe];
    
//    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[self.timeLabe(==48)]-16-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(self.timeLabe)]];
//    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-16-[self.timeLabe(==12)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(self.timeLabe)]];
//    

}

-(void)creatModel:(WhoLookMeModel *)model{
    _model = model;
    self.nickLabel.text = _model.peopleName;
    NSURL *headUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,model.imageName]];
    [self.headImage sd_setImageWithURL:headUrl];
    self.timeLabe.text =[CommonTool timestampSwitchTime:[_model.Time doubleValue]/1000 andFormatter:@"YYYY-MM-dd"] ;
    self.ageLabel.text = [NSString stringWithFormat:@"%@岁",_model.age];
    self.heightLabel.text =[NSString stringWithFormat:@"%@",_model.height] ;
    self.colleanLabel.text = [NSString stringWithFormat:@"%@",_model.collean] ;
    
    if ([CommonTool dx_isNullOrNilWithObject:_model.vipLevel] ||[[NSString stringWithFormat:@"%@",_model.vipLevel] isEqualToString:@"0"]) {
        self.vipImageBtn.hidden = YES;
    }else{
        [self.vipImageBtn setTitle:[NSString stringWithFormat:@"%@",_model.vipLevel] forState:UIControlStateNormal];
    }
 
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
