//
//  EditSignViewController.m
//  澜庭
//
//  Created by 广有射怪鸟事 on 15/9/25.
//  Copyright (c) 2015年 刘瀚韬. All rights reserved.
//

#import "EditSignViewController.h"
#import "MBProgressHUD+NJ.h"

@interface EditSignViewController ()

@property (nonatomic,strong) UITextView *introduceText;

@end

@implementation EditSignViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"编辑个人签名";
    
    [self setRightButton:nil title:@"完成" target:self action:@selector(editOverAction)];
    
    [self createView];
}

- (void)createView{
    self.introduceText = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, kMainScreenWidth - 20, kMainScreenHeight)];
    self.introduceText.text = self.introduceString;
    [self.introduceText becomeFirstResponder];
    self.introduceText.font = [UIFont systemFontOfSize:14.0];
    self.introduceText.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:self.introduceText];
}

- (void)editOverAction{
    NSDictionary *dict = @{@"introduceString":self.introduceText.text};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeIntroduce" object:nil userInfo:dict];
    [self.navigationController popViewControllerAnimated:YES];
}


@end
