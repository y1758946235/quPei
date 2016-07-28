//
//  OrderDetailsFourthTableViewCell.h
//  豆客项目
//
//  Created by Xia Wei on 15/10/13.
//  Copyright © 2015年 Xia Wei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderDetailsFourthTableViewCell : UITableViewCell

- (id)initWithFrame:(CGRect)frame;
@property(nonatomic,strong)UITextView *content;

- (void)fillDataWithData:(NSString *)str;

@end
