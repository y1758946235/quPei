//
//  MyMoneyVC.h
//  LvYue
//
//  Created by X@Han on 16/12/16.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "BaseViewController.h"
#import <StoreKit/StoreKit.h>  
@interface MyMoneyVC : BaseViewController<SKPaymentTransactionObserver,SKProductsRequestDelegate>
//@property(copy,nonatomic)NSString *money;  //金币
//@property(copy,nonatomic)NSString *userKey;  //钥匙
//@property(copy,nonatomic)NSString *gift;  //礼物


@end
