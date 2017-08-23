//
//  UserPoolCollectionViewCell.m
//  LvYue
//
//  Created by X@Han on 17/4/11.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "UserPoolCollectionViewCell.h"

@implementation UserPoolCollectionViewCell
- (id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        [self initWithSubViews];
    }
    return self;
}
- (void)initWithSubViews{
    
    self.photoImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, (SCREEN_WIDTH-32)/3, (SCREEN_WIDTH-32)/3)];
    self.photoImage.userInteractionEnabled = YES;
    [self addSubview:self.photoImage];
    
    
    UILabel *contLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, (SCREEN_WIDTH-32)/3-24, (SCREEN_WIDTH-32)/3, 24)];
    contLabel.backgroundColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:0.75];
    self.contLabel = contLabel;
    [self.photoImage addSubview:contLabel];
    
    self.nickLabel = [[UILabel alloc]initWithFrame:CGRectMake(4, 6, (SCREEN_WIDTH-32)/3 -40, 12)];
    UIColor *nickColor = [UIColor colorWithHexString:@"#424242"];
    self.nickLabel.textColor = [nickColor colorWithAlphaComponent:1];
    self.nickLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    [self.contLabel addSubview:self.nickLabel];
  
    
//    self.heartImageBtn = [[UIButton alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-32)/3 -20, 0, 20 , 20)];
     self.heartImageBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, (SCREEN_WIDTH-32)/3, (SCREEN_WIDTH-32)/3)];
    self.heartImageBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    self.heartImageBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    self.heartImageBtn.imageEdgeInsets = UIEdgeInsetsMake(0, (SCREEN_WIDTH-32)/3 -20, (SCREEN_WIDTH-32)/3 -20, 0);
    
    [self.heartImageBtn setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
    [self.heartImageBtn setImage:[UIImage imageNamed:@"nolike"] forState:UIControlStateSelected];
    
    [self.photoImage addSubview:self.heartImageBtn];
    
    UILabel *ageLabel = [[UILabel alloc]init];
    ageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    ageLabel.textColor = [UIColor colorWithHexString:@"#424242"];
    ageLabel.textAlignment = NSTextAlignmentLeft;
    ageLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    self.ageLabel = ageLabel;
    [contLabel addSubview:ageLabel];
    [contLabel addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[ageLabel(==27)]-4-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(ageLabel)]];
    [contLabel addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-6-[ageLabel(==12)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(ageLabel)]];
}


@end
