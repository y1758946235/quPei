//
//  CollectTableViewCell.m
//  购买会员
//
//  Created by 刘丽锋 on 15/10/5.
//  Copyright © 2015年 刘丽锋. All rights reserved.
//

#import "CollectTableViewCell.h"
#import "BaseViewController.h"

@implementation CollectTableViewCell

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        //初始化图标
        _icon= [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 61, 61)];
//        _icon.backgroundColor =[UIColor cyanColor];
        
        //初始化标题文字
        _title = [[UILabel alloc] initWithFrame:CGRectMake(71, 2, 200, 25)];
        _title.font = [UIFont systemFontOfSize:14.0];
//        _title.backgroundColor= [UIColor redColor];
        
        //网址的显示
        _webText=[[UILabel alloc] initWithFrame:CGRectMake(71,61-25, 200, 20)];
        _webText.font=[UIFont systemFontOfSize:12.0];
        _webText.textColor=UIColorWithRGBA(144, 144, 144, 1);
//        _webText.backgroundColor= [UIColor purpleColor];
        
        //显示时间
        _date=[[UILabel alloc] initWithFrame:CGRectMake(kMainScreenWidth-30-200, 5, 200, 20)];
        _date.font=[UIFont systemFontOfSize:12.0];
        _date.textAlignment = NSTextAlignmentRight;
        _date.textColor=UIColorWithRGBA(144, 144, 144, 1);
//        _date.backgroundColor=[UIColor yellowColor];
        
        UIView* backView =[[UIView alloc] initWithFrame:CGRectMake(15, 5, kMainScreenWidth-30, 61)];
        backView.backgroundColor=UIColorWithRGBA(242, 242, 242, 1);
//        backView.backgroundColor=[UIColor blueColor];
        [backView addSubview:_icon];
        [backView addSubview:_title];
        [backView addSubview:_webText];
        [backView addSubview:_date];
        
        [self.contentView addSubview:backView];
    }
    return self;
}

- (void)awakeFromNib {
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
