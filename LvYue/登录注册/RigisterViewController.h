//
//  RigisterViewController.h
//  LvYue
//
//  Created by apple on 15/9/30.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RigisterViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *phoneField;

@property (weak, nonatomic) IBOutlet UITextField *checkField;

@property (weak, nonatomic) IBOutlet UIButton *getCheckNumBtn;

@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@property (weak, nonatomic) IBOutlet UITextField *passwordField2;

@property (weak, nonatomic) IBOutlet UIButton *rigisterBtn;
@property (strong, nonatomic) IBOutlet UIButton *selectBtn;

- (IBAction)back:(UIButton *)sender;

- (IBAction)getCheckNum:(UIButton *)sender;

- (IBAction)userRigister:(UIButton *)sender;
- (IBAction)checkPrivate:(UIButton *)sender;
- (IBAction)didSelect:(UIButton *)sender;

@end
