//
//  CreateGroupViewController.m
//  LvYue
//
//  Created by apple on 15/10/8.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import "CreateGroupViewController.h"
#import "MBProgressHUD+NJ.h"
#import "UIView+RSAdditions.h"
#import "BuddySelectionViewController.h"

@interface CreateGroupViewController ()<UITextViewDelegate,UITextFieldDelegate>

@property (nonatomic, strong) UITextField *groupNameField;

@property (nonatomic, strong) UITextView *groupDescField;

@end

@implementation CreateGroupViewController

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    self.title = @"创建群组";
    self.navigationController.navigationBarHidden = NO;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = RGBACOLOR(233, 233, 233, 1.0);
    
    _groupNameField = [[UITextField alloc] initWithFrame:CGRectMake(0, 100, kMainScreenWidth, 44)];
    _groupNameField.borderStyle = UITextBorderStyleNone;
    _groupNameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _groupNameField.backgroundColor = [UIColor whiteColor];
    _groupNameField.placeholder = @"填写群名称(必填)";
    _groupNameField.textAlignment = NSTextAlignmentCenter;
    _groupNameField.textColor = RGBACOLOR(44, 44, 44, 1.0);
    _groupNameField.font = kFont16;
    _groupNameField.returnKeyType = UIReturnKeyDone;
    _groupNameField.delegate = self;
    [self.view addSubview:_groupNameField];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, _groupNameField.bottom + 15, 120, 20)];
    titleLabel.textColor = [UIColor grayColor];
    titleLabel.text = @"填写群描述(必填)";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = kFont14;
    titleLabel.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:titleLabel];
    
    _groupDescField = [[UITextView alloc] initWithFrame:CGRectMake(0, titleLabel.bottom, kMainScreenWidth, 200) textContainer:nil];
    _groupDescField.scrollEnabled = YES;
    _groupDescField.textColor = RGBACOLOR(44, 44, 44, 1.0);
    _groupDescField.font = kFont15;
    _groupDescField.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10);
    _groupDescField.returnKeyType = UIReturnKeyDone;
    _groupDescField.delegate = self;
    [self.view addSubview:_groupDescField];
    
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    nextBtn.frame = CGRectMake(20, _groupDescField.bottom + 30, kMainScreenWidth - 40, 44);
    nextBtn.layer.cornerRadius = 5.0;
    nextBtn.clipsToBounds = YES;
    nextBtn.backgroundColor = [UIColor colorWithRed:29/255.0 green:189/255.0 blue:159/255.0 alpha:1];
    [nextBtn setTitle:@"下一步" forState:UIControlStateNormal];
    [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    nextBtn.titleLabel.font = kFont18;
    [nextBtn addTarget:self action:@selector(continueToCreateGroup:) forControlEvents:UIControlEventTouchUpInside];
    [self. view addSubview:nextBtn];
}



#pragma mark - 监听点击"下一步"
- (void)continueToCreateGroup:(UIButton *)sender {
    
    if (_groupNameField.text.length == 0 || ([_groupNameField.text rangeOfString:@" "].location != NSNotFound)) {
        [MBProgressHUD showError:@"群名称不能为空且不含空格!"];
        return;
    }
    if (_groupNameField.text.length > 20) {
        [MBProgressHUD showError:@"群名称不能超过20个字符!"];
        return;
    }
    if (_groupDescField.text.length > 200) {
        [MBProgressHUD showError:@"群描述不能超过200个字符!"];
        return;
    }
    BuddySelectionViewController *dest = [[BuddySelectionViewController alloc] init];
    dest.groupName = _groupNameField.text;
    dest.groupDesc = _groupDescField.text;
    [self.navigationController pushViewController:dest animated:YES];
}


#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [self.view endEditing:YES];
        return NO;
    } else {
        return YES;
    }
}


#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    return YES;
}


@end
