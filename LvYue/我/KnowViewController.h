//
//  KnowViewController.h
//  LvYue
//
//  Created by 广有射怪鸟事 on 15/9/30.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import "BaseViewController.h"

@interface KnowViewController : BaseViewController

@property (nonatomic,assign) NSInteger car;//0为没，1为正在，2为成功
@property (nonatomic,assign) NSInteger video;
@property (nonatomic,assign) NSInteger identity;
@property (nonatomic,assign) NSInteger edu;
@property (nonatomic,assign) NSInteger userType;
@property (nonatomic,strong) NSString  *status;//导游申请状态,0为未申请，1为申请中
@property (nonatomic,strong) NSString  *provide_stay;//民宿状态

@property (nonatomic,strong) NSString  *alipay;
@property (nonatomic,strong) NSString  *weixin;

@end
