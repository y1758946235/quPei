//
//  SearchTogetherTableViewCell.h
//  豆客项目
//
//  Created by Xia Wei on 15/10/8.
//  Copyright © 2015年 Xia Wei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchTogetherTableViewCell : UITableViewCell

@property (nonatomic,strong) UITextField *serText;
@property(nonatomic,strong)NSMutableArray *service_content;
- (id) initWithFrame:(CGRect)frame;

- (void)setWithNameArr:(NSArray *)nameArr;

@end
