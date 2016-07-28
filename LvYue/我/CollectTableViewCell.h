//
//  CollectTableViewCell.h
//  购买会员
//
//  Created by 刘丽锋 on 15/10/5.
//  Copyright © 2015年 刘丽锋. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectTableViewCell : UITableViewCell
//设置图标
@property(nonatomic,retain) UIImageView* icon;
//设置标题
@property(nonatomic,retain) UILabel* title;
//显示网址
@property(nonatomic,retain) UILabel* webText;
//显示时间
@property(nonatomic,retain) UILabel* date;
@end
