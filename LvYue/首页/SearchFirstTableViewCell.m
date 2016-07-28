//
//  SearchFirstTableViewCell.m
//  豆客项目
//
//  Created by Xia Wei on 15/10/6.
//  Copyright © 2015年 Xia Wei. All rights reserved.
//

#import "SearchFirstTableViewCell.h"

@interface SearchFirstTableViewCell()

@property (weak, nonatomic) IBOutlet UIButton *all;
@property (weak, nonatomic) IBOutlet UIButton *male;
@property (weak, nonatomic) IBOutlet UIButton *female;
@property (weak, nonatomic) IBOutlet UISwitch *switchBar;

@property (nonatomic,strong) NSArray *btnArray;
@end

@implementation SearchFirstTableViewCell

- (void)awakeFromNib {
    
    _btnArray = @[_all,_male,_female];
    _all.tag = 1;
    _male.tag = 2;
    _female.tag = 3;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //设置全部按钮的样式
    [_all setTintColor:[UIColor whiteColor]];
    [_all setBackgroundColor:UIColorWithRGBA(29, 189, 159, 1)];
    _all.layer.cornerRadius = 2;
    [_all addTarget:self action:@selector(btnChanged:) forControlEvents:UIControlEventTouchUpInside];
    
    //男按钮的样式
    [_male setTintColor:[UIColor blackColor]];
    [_male.layer setBorderWidth:1];
    [_male.layer setBorderColor:UIColorWithRGBA(221, 221, 221, 1).CGColor];
    _male.layer.cornerRadius = 2;
    [_male addTarget:self action:@selector(btnChanged:) forControlEvents:UIControlEventTouchUpInside];
    
    //女按钮的样式
    [_female setTintColor:[UIColor blackColor]];
    [_female.layer setBorderWidth:1];
    [_female.layer setBorderColor:UIColorWithRGBA(221, 221, 221, 1).CGColor];
    _female.layer.cornerRadius = 2;
    [_female addTarget:self action:@selector(btnChanged:) forControlEvents:UIControlEventTouchUpInside];
    
    //switchBar
    _switchBar.onTintColor = UIColorWithRGBA(29, 189, 159, 1);
}

- (void)btnChanged:(UIButton *)doBtn{
    for (UIButton *tempBtn in _btnArray) {
        if (tempBtn.tag == doBtn.tag) {
            [tempBtn setTintColor:[UIColor whiteColor]];
            [tempBtn.layer setBorderWidth:0];
            [tempBtn setBackgroundColor:UIColorWithRGBA(29, 189, 159, 1)];
        }
        else{
            [tempBtn.layer setBorderWidth:1];
            [tempBtn.layer setBorderColor:
                                UIColorWithRGBA(221, 221, 221, 1).CGColor];
            [tempBtn setTintColor:[UIColor blackColor]];
            [tempBtn setBackgroundColor:[UIColor whiteColor]];
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
