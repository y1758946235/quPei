//
//  ForgetPasswordController.h
//  LvYue
//
//  Created by apple on 15/9/30.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForgetPasswordController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *phoneField;

@property (weak, nonatomic) IBOutlet UITextField *checkField;

@property (weak, nonatomic) IBOutlet UIButton *getCheckBtn;

@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@property (weak, nonatomic) IBOutlet UITextField *passwordField2;

@property (weak, nonatomic) IBOutlet UIButton *sureBtn;

- (IBAction)back:(UIButton *)sender;

- (IBAction)getCheckNum:(UIButton *)sender;

- (IBAction)sure:(UIButton *)sender;

@end
