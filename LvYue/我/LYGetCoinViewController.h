//
//  LYGetCoinViewController.h
//  LvYue
//
//  Created by KentonYu on 16/8/2.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "BaseViewController.h"

@interface LYGetCoinViewController : BaseViewController

@property (nonatomic, assign) NSInteger accountAmount; // 账户余额
@property (nonatomic, copy) void(^changeAmount)(NSInteger amount);

@end
