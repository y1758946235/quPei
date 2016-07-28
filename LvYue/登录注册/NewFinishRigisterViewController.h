//
//  NewFinishRigisterViewController.h
//  LvYue
//
//  Created by 郑洲 on 16/3/15.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "BaseViewController.h"

@interface NewFinishRigisterViewController : BaseViewController

/**
 *  传递过来的信息,用于注册(手机号注册)
 */
@property (nonatomic, copy) NSString *mobile;

@property (nonatomic, copy) NSString *checkNum;

@property (nonatomic, copy) NSString *password;

/**
 *  传递过来的信息,用于注册(第三方注册)
 */
@property (nonatomic, copy) NSString *umeng_id; //友盟id
@property (nonatomic, copy) NSString* accessToken;  //access_token
@property (nonatomic, copy) NSString *userName; //微信、qq、微博传递过来的默认用户昵称
@property (nonatomic, copy) NSString* icon;  //头像
@property (nonatomic, copy) NSString* nickName; //昵称
@property (nonatomic, copy) NSString* age; //年龄
@property (nonatomic, copy) NSString* sex; 

@property (nonatomic,copy)   NSString *longitude;//经纬度
@property (nonatomic,copy)   NSString *latitude;

@end
