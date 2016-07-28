//
//  AllOrederTableViewCellTableViewCell.h
//  豆客项目
//
//  Created by Xia Wei on 15/10/12.
//  Copyright © 2015年 Xia Wei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderModel.h"

@interface AllOrederTableViewCell : UITableViewCell

@property (nonatomic,strong) NSMutableArray *allOrderArray;
@property (nonatomic,strong) UILabel *nameLabel;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier frame:(CGRect)cellFrame;

- (void)fillDataWithModel:(OrderModel *)myModel;

@end
