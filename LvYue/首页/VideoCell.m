//
//  VideoCell.m
//  LvYue
//
//  Created by KFallen on 16/7/8.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "VideoCell.h"
@interface VideoCell()
@property (weak, nonatomic) IBOutlet UIButton *all;
@property (weak, nonatomic) IBOutlet UIButton *male;
@property (weak, nonatomic) IBOutlet UIButton *female;
@property (nonatomic,strong) NSArray *btnArray;

@end
@implementation VideoCell

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
   // _switchBar.onTintColor = UIColorWithRGBA(29, 189, 159, 1);
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

@end
