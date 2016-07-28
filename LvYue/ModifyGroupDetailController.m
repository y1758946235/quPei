//
//  ModifyGroupDetailController.m
//  LvYue
//
//  Created by apple on 15/10/21.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import "ModifyGroupDetailController.h"
#import "MBProgressHUD+NJ.h"
#import "LYHttpPoster.h"

@interface ModifyGroupDetailController ()<UITextViewDelegate>

@property (nonatomic, strong) UITextField *modifyNameField;

@property (nonatomic, strong) UITextView *modifyDescField;

@end

@implementation ModifyGroupDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //关闭全屏化
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.view.backgroundColor = RGBACOLOR(244, 244, 244, 1.0);
    
    [self setLeftButton:nil title:@"取消" target:self action:@selector(cancelModify:) rect:CGRectMake(0, 0, 40, 44)];
    [self setRightButton:nil title:@"保存" target:self action:@selector(saveModify:) rect:CGRectMake(0, 0, 40, 44)];
    
    if (_modifyType == 0) {
        self.title = @"群组名称";
        [self getModifyGroupNameView];
    } else {
        self.title = @"群组描述";
        [self getModifyGroupDescView];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

//修改群组名字的View
- (void)getModifyGroupNameView {
    _modifyNameField = [[UITextField alloc] initWithFrame:CGRectMake(0, 20, kMainScreenWidth, 44)];
    _modifyNameField.backgroundColor = [UIColor whiteColor];
    _modifyNameField.borderStyle = UITextBorderStyleNone;
    _modifyNameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _modifyNameField.font = kFont15;
    _modifyNameField.textAlignment = NSTextAlignmentLeft;
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 44)];
    _modifyNameField.leftView = paddingView;
    _modifyNameField.leftViewMode = UITextFieldViewModeAlways;
    _modifyNameField.text = _receiveSender;
    [self.view addSubview:_modifyNameField];
}


//修改群组描述的View
- (void)getModifyGroupDescView {
    _modifyDescField = [[UITextView alloc] initWithFrame:CGRectMake(0, 20, kMainScreenWidth, 300)];
    _modifyDescField.backgroundColor = [UIColor whiteColor];
    _modifyDescField.font = kFont15;
    _modifyDescField.textAlignment = NSTextAlignmentLeft;
    _modifyDescField.text = _receiveSender;
    _modifyDescField.returnKeyType = UIReturnKeyDone;
    _modifyDescField.delegate = self;
    [self.view addSubview:_modifyDescField];
}


- (void)cancelModify:(UIButton *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)saveModify:(UIButton *)sender {
    
    NSDictionary *requestDict;
    if (_modifyType == 0) {
        if (_modifyNameField.text.length == 0 || ([_modifyNameField.text rangeOfString:@" "].location != NSNotFound)) {
            [MBProgressHUD showError:@"群组名称不符合规范"];
            return;
        }
        requestDict = @{@"id":_groupID,@"name":_modifyNameField.text};
    } else {
        requestDict = @{@"id":_groupID,@"desc":_modifyDescField.text};
    }
    [MBProgressHUD showMessage:@"修改中.."];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/group/update",REQUESTHEADER] andParameter:requestDict success:^(id successResponse) {
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            [MBProgressHUD hideHUD];
            if (requestDict[@"name"]) { //如果是修改群组主题,则添加一个标识
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadGroupDetail" object:nil userInfo:@{@"name":_modifyNameField.text}];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadGroupDetail" object:nil];
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
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


@end
