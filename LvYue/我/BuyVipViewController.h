//
//  BuyVipViewController.h
//  LvYue
//
//  Created by 广有射怪鸟事 on 15/10/7.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import "BaseViewController.h"

@interface BuyVipViewController : BaseViewController

@property (nonatomic,strong) NSString *vip_price;
@property (nonatomic,strong) NSString *vip_year_price;
@property (nonatomic,assign) BOOL isShow;

@property (nonatomic, copy) NSString *coinNum;  //金币数

@end
