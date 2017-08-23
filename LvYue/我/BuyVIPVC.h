//
//  BuyVIPVC.h
//  LvYue
//
//  Created by X@Han on 16/12/27.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "BaseViewController.h"

@interface BuyVIPVC : BaseViewController
@property (nonatomic,strong) NSString *vip_price;
@property (nonatomic,strong) NSString *vip_year_price;
@property (nonatomic,assign) BOOL isShow;

@property (nonatomic, copy) NSString *coinNum;  //金币数
@end
