//
//  OrderDetailFirstTableViewCell.h
//  豆客项目
//
//  Created by Xia Wei on 15/10/13.
//  Copyright © 2015年 Xia Wei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderDetailFirstTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *price;
@property (strong, nonatomic) IBOutlet UILabel *tradeStatus;

- (void)fillData:(NSString *)price andTrade:(NSString *)status;

@end
