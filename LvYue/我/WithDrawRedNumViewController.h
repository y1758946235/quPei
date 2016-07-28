//
//  WithDrawRedNumViewController.h
//  LvYue
//
//  Created by 広有射怪鸟事 on 15/12/15.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import "BaseViewController.h"

@interface WithDrawRedNumViewController : BaseViewController

@property (nonatomic,strong) NSString *payType;//提现方式，1为支付宝，2为微信支付
@property (nonatomic,strong) NSString *alipay;//支付宝账号
@property (nonatomic,strong) NSString *weixin;//微信号
@property (nonatomic,strong) NSString *hongdou;

@end
