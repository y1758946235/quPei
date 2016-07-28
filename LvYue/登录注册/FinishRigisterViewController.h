//
//  FinishRigisterViewController.h
//  LvYue
//
//  Created by apple on 15/9/30.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FinishRigisterViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *userNameField;
@property (strong, nonatomic) IBOutlet UITextField *inviteCodeTextField;

@property (weak, nonatomic) IBOutlet UIButton *boyBtn;

@property (weak, nonatomic) IBOutlet UIButton *girlBtn;

@property (weak, nonatomic) IBOutlet UIButton *finishRigister;

- (IBAction)selectBoy:(UIButton *)sender;

- (IBAction)selectGirl:(UIButton *)sender;

- (IBAction)finishRigister:(UIButton *)sender;

- (IBAction)back:(UIButton *)sender;

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

@property (nonatomic, copy) NSString *userName; //微信、qq、微博传递过来的默认用户昵称

@end
