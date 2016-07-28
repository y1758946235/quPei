//
//  LoginViewController.h
//  LvYue
//
//  Created by apple on 15/9/28.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *phoneField;

@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

- (IBAction)rigister:(UIButton *)sender;

- (IBAction)forgetPassword:(UIButton *)sender;

- (IBAction)login:(UIButton *)sender;

- (IBAction)ThirdLogin:(UIButton *)sender;

- (IBAction)visitorEnter:(UIButton *)sender;

@end
