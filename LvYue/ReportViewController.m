//
//  ReportViewController.m
//  LvYue
//
//  Created by 広有射怪鸟事 on 16/1/4.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "MBProgressHUD+NJ.h"
#import "ReportViewController.h"

@interface ReportViewController () {
    UITextView *text;
}

@end

@implementation ReportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.title = @"举报";

    [self setRightButton:nil title:@"提交" target:self action:@selector(completeWrite)];

    UILabel *plzLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 74, 150, 20)];
    plzLabel.font     = [UIFont systemFontOfSize:14.0];
    plzLabel.text     = @"请描述一下举报原因";
    [self.view addSubview:plzLabel];

    text                    = [[UITextView alloc] initWithFrame:CGRectMake(10, 100, kMainScreenWidth - 20, kMainScreenHeight - 150)];
    text.font               = [UIFont systemFontOfSize:14.0];
    text.layer.cornerRadius = 4;
    text.backgroundColor    = RGBACOLOR(238, 238, 238, 1);
    [self.view addSubview:text];
}

- (void)completeWrite {
    if (text.text.length == 0) {
        [MBProgressHUD showError:@"内容不能为空"];
        return;
    }
    [MBProgressHUD showMessage:nil];
    [self performSelector:@selector(delayMethod) withObject:nil afterDelay:1.0f];
}

- (void)delayMethod {
    [MBProgressHUD hideHUD];
    [[[UIAlertView alloc] initWithTitle:nil message:@"提交成功，我们会尽快处理" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil] show];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
