//
//  NewRigisterViewController.h
//  LvYue
//
//  Created by 郑洲 on 16/3/15.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "BaseViewController.h"

@interface NewRigisterViewController : BaseViewController

@property (nonatomic,assign) BOOL isForgetPassword;//忘记密码
@property (nonatomic,copy)   NSString *longitude;//经纬度
@property (nonatomic,copy)   NSString *latitude;

@end
