//
//  ScrollView.h
//  LvYue
//
//  Created by 郑洲 on 16/4/8.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScrollView : UIView
@property (retain, nonatomic) UILabel *titleLabel;
@property (retain, nonatomic) UIButton *newsButton;

-(void)setViewWithTitle:(NSString *)title;

@end
