//
//  ThirdRegisterViewController.h
//  LvYue
//
//  Created by KFallen on 16/7/7.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "BaseViewController.h"

@interface ThirdRegisterViewController : BaseViewController
@property (nonatomic, copy) NSString* isForgetPassword;

@property (nonatomic,copy)   NSString *longitude;//经纬度
@property (nonatomic,copy)   NSString *latitude;

//友盟信息
@property (nonatomic, copy) NSString* umeng_id;    //友盟ID
@property (nonatomic, copy) NSString* nickName;     //昵称
@property (nonatomic, copy) NSString* sex;          //性别
@property (nonatomic, copy) NSString* icon;         //头像
@property (nonatomic, copy) NSString* age;          //年龄




@end
