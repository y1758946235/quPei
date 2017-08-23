//
//  AlterGivingView.m
//  LvYue
//
//  Created by X@Han on 17/4/27.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "AlterGivingView.h"

@implementation AlterGivingView{
    UIView * tansuoView;
    UILabel *detailLabel;
    UIImageView *huliImagV ;
}
- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        
       
        //高斯模糊
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
        effectView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        [self addSubview:effectView];
        [self beginTansuo];
        
        
    }
    return self;
    
}
-(void)beginTansuo{
    
    tansuoView = [[UIView alloc]init];
    tansuoView.frame = CGRectMake(SCREEN_WIDTH/2 -140, 110+64, 280, 220);
    tansuoView.backgroundColor = [UIColor colorWithHexString:@"#ffffff"];
    [self addSubview:tansuoView];
    
    huliImagV = [[UIImageView alloc]init];
    huliImagV.frame = CGRectMake(SCREEN_WIDTH/2 -140 +12, 52+64, 180, 80);
    huliImagV.image =[UIImage imageNamed:@"title_fox"];
    [self addSubview:huliImagV];
    
    
    UILabel *titLabel = [[UILabel alloc]init];
    titLabel.frame = CGRectMake(16, 24, 248, 40);
    titLabel.numberOfLines = 2;
    titLabel.text = @"发现一个有趣的人\n就是发现一个新世界";
    titLabel.textAlignment = NSTextAlignmentCenter;
    titLabel.textColor = [UIColor colorWithHexString:@"#757575"];
    titLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
    [tansuoView addSubview:titLabel];
    
    detailLabel = [[UILabel alloc]init];
    detailLabel.frame = CGRectMake(0, 102, 169, 36);
    
    detailLabel.textAlignment = NSTextAlignmentRight;
    detailLabel.textColor = [UIColor colorWithHexString:@"#757575"];
    detailLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
    [tansuoView addSubview:detailLabel];
    
    
    
    
    
    UILabel *rightDetailLabel = [[UILabel alloc]init];
    rightDetailLabel.frame = CGRectMake(169, 102, 280-169, 36);
    rightDetailLabel.text = @"3朵玫瑰花";
    rightDetailLabel.textAlignment = NSTextAlignmentLeft;
    rightDetailLabel.textColor = [UIColor colorWithHexString:@"#757575"];
    rightDetailLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
    [tansuoView addSubview:rightDetailLabel];
    NSRange range2 = [rightDetailLabel.text rangeOfString:@"3"];
    [self setTextColor:rightDetailLabel FontNumber:[UIFont fontWithName:@"PingFangSC-Light" size:36]AndRange:range2 AndColor:[UIColor colorWithHexString:@"#ff5252"]];
    
    UIButton *tansuoBtn = [[UIButton alloc]init];
    tansuoBtn.frame = CGRectMake(80, 160, 120, 36);
    [tansuoBtn setTitle:@"开始探索" forState:UIControlStateNormal];
    [tansuoBtn setTitleColor:[UIColor colorWithHexString:@"#ffffff"] forState:UIControlStateNormal];
    tansuoBtn.backgroundColor = [UIColor colorWithHexString:@"#ff5252"];
    tansuoBtn.layer.cornerRadius = 18;
    tansuoBtn.clipsToBounds = YES;
    tansuoBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
    [tansuoView addSubview:tansuoBtn];
    
    [tansuoBtn addTarget:self action:@selector(searchClick) forControlEvents:UIControlEventTouchUpInside];
    
}
//设置不同字体颜色
-(void)setTextColor:(UILabel *)label FontNumber:(id)font AndRange:(NSRange)range AndColor:(UIColor *)vaColor
{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:label.text];
    //设置字号
    [str addAttribute:NSFontAttributeName value:font range:range];
    //设置文字颜色
    [str addAttribute:NSForegroundColorAttributeName value:vaColor range:range];
    
    label.attributedText = str;
}
-(void)searchClick{
    [huliImagV removeFromSuperview];
    [tansuoView removeFromSuperview];

    
    
    [self removeFromSuperview];
  
}
-(void)creatTypeUser:(NSString *)typeUser{
 
    if ([[NSString stringWithFormat:@"%@",typeUser] isEqualToString:@"0"]) {
        detailLabel.text = @"赠送你3把钥匙，";
        NSRange range1 = [detailLabel.text rangeOfString:@"3"];
        [self setTextColor:detailLabel FontNumber:[UIFont fontWithName:@"PingFangSC-Light" size:36]AndRange:range1 AndColor:[UIColor colorWithHexString:@"#ff5252"]];
    }
    if ([[NSString stringWithFormat:@"%@",typeUser] isEqualToString:@"1"]) {
        detailLabel.text = @"赠送你3把钥匙，";
        NSRange range3 = [detailLabel.text rangeOfString:@"3"];
        [self setTextColor:detailLabel FontNumber:[UIFont fontWithName:@"PingFangSC-Light" size:36]AndRange:range3 AndColor:[UIColor colorWithHexString:@"#ff5252"]];
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
