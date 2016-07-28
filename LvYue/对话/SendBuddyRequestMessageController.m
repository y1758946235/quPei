//
//  SendBuddyRequestMessageController.m
//  LvYue
//
//  Created by apple on 15/10/10.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import "SendBuddyRequestMessageController.h"
#import "UIView+RSAdditions.h"
#import "LYUserService.h"
#import "LYHttpPoster.h"
#import "MBProgressHUD+NJ.h"

@interface SendBuddyRequestMessageController ()<UITextViewDelegate>

@property (nonatomic, strong) UITextView *messageView;

@end

@implementation SendBuddyRequestMessageController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = @"朋友验证";
    [self setRightButton:nil title:@"发送" target:self action:@selector(sendRequestMessage:) rect:CGRectMake(0, 0, 40, 44)];
    self.view.backgroundColor = RGBACOLOR(234, 234, 234, 1.0);
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //提示信息
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 64, kMainScreenWidth - 20, 44)];
    titleLabel.text = @"您需要发送验证信息,等待对方通过:";
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.font = kFont14;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor grayColor];
    [self.view addSubview:titleLabel];
    
    //验证信息
    UITextView *messageView = [[UITextView alloc] initWithFrame:CGRectMake(20, titleLabel.bottom, kMainScreenWidth - 40, 150) textContainer:nil];
    messageView.layer.cornerRadius = 10.0;
    messageView.clipsToBounds = YES;
    messageView.backgroundColor = [UIColor whiteColor];
    messageView.textColor = [UIColor grayColor];
    messageView.font = kFont14;
    messageView.scrollEnabled = NO;
    //辅助视图
    UIView *kbTopView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 30)];
    kbTopView.backgroundColor = [UIColor whiteColor];
    kbTopView.alpha = 0.6;
    UIButton *finishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    finishBtn.frame = CGRectMake(kMainScreenWidth - 60, 0, 50, 30);
    finishBtn.backgroundColor = [UIColor clearColor];
    [finishBtn setTitle:@"完成" forState:UIControlStateNormal];
    [finishBtn setTitleColor:RGBACOLOR(23, 101, 210, 1.0) forState:UIControlStateNormal];
    finishBtn.titleLabel.font = kFont16;
    [finishBtn addTarget:self action:@selector(finishEdit:) forControlEvents:UIControlEventTouchUpInside];
    messageView.inputAccessoryView = kbTopView;
    [kbTopView addSubview:finishBtn];
    _messageView = messageView;
    
    [self.view addSubview:_messageView];
}


#pragma mark - 键盘辅助视图的"完成"
- (void)finishEdit:(UIButton *)sender {
    
    [_messageView resignFirstResponder];
}


#pragma mark - 监听点击"发送"
- (void)sendRequestMessage:(UIButton *)sender {
    
    [MBProgressHUD showMessage:@"好友请求发送中.."];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/userFriend/addRequest",REQUESTHEADER] andParameter:@{@"user_id":[LYUserService sharedInstance].userID,@"other_user_id":_buddyID,@"request_info":_messageView.text} success:^(id successResponse) {
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showSuccess:@"请求发送成功"];
            [self.navigationController popToRootViewControllerAnimated:YES];
        } else {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
}


@end
