//
//  OrderDetailsViewController.h
//  豆客项目
//
//  Created by Xia Wei on 15/10/13.
//  Copyright © 2015年 Xia Wei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderModel.h"
#import "BaseViewController.h"

@interface OrderDetailsViewController : BaseViewController

@property (nonatomic,strong) NSString *orderStatus;
@property (nonatomic,strong) OrderModel *model;

@end
