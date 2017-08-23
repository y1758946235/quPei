//
//  changeNickName.m
//  LvYue
//
//  Created by X@Han on 16/12/8.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "changeNickName.h"      //修改我的昵称
#import "LYHttpPoster.h"
#import "MBProgressHUD+NJ.h"

@interface changeNickName ()<UITextViewDelegate>{
    
    UITextView *_textView;
    UILabel *numLabel;
    UILabel *placeholder;
    
    UIButton *edit;
}

@end

@implementation changeNickName

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNav];
    [self setTextVi];
}

- (void)setTextVi{
    
    _textView = [[UITextView alloc]initWithFrame:CGRectMake(16, 16, SCREEN_WIDTH-32, 200)];
    
    _textView.backgroundColor = [UIColor colorWithHexString:@"#ffffff"];
    _textView.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
    _textView.delegate = self;
    _textView.text = @"";
    _textView.textColor = [UIColor colorWithHexString:@"#424242"];
    _textView.returnKeyType = UIReturnKeyDone;
    _textView.keyboardType = UIKeyboardTypeDefault;
    _textView.scrollEnabled = NO;
    
    _textView.autoresizingMask = UIViewAutoresizingFlexibleHeight; //自适应高度
    _textView.dataDetectorTypes = UIDataDetectorTypeAll; //电话号码  网址 地址等都可以显示
    //textView.editable = NO;  //禁止编辑
    [self.view addSubview:_textView];
    
    placeholder               = [[UILabel alloc] init];
    placeholder.translatesAutoresizingMaskIntoConstraints = NO;
    placeholder.text          = @"请输入昵称...";
    placeholder.textColor = [UIColor colorWithHexString:@"#bdbdbd"];
    placeholder.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
    placeholder.textAlignment = NSTextAlignmentLeft;
    [_textView addSubview:placeholder];
    //    placeholder.frame = CGRectMake(0*AutoSizeScaleX, 10*AutoSizeScaleY, 288*AutoSizeScaleX, 21*AutoSizeScaleY);
    [_textView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-6-[placeholder]-16-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(placeholder)]];
    [_textView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-16-[placeholder(==12)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(placeholder)]];
    
    numLabel = [[UILabel alloc]init];
    numLabel.translatesAutoresizingMaskIntoConstraints = NO;
    numLabel.textColor = [UIColor colorWithHexString:@"#9e9e9e"];
    numLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
    numLabel.text = @"0/12";
    [self.view addSubview:numLabel];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[numLabel(==40)]-22-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(numLabel)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_textView]-8-[numLabel(==12)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_textView,numLabel)]];
    
}





#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    } else {
        return YES;
    }
}
//正在改变
- (void)textViewDidChange:(UITextView *)textView
{
    NSLog(@"%@", textView.text);
    
    placeholder.hidden = YES;
//    //允许提交按钮点击操作
//    edit.backgroundColor = FDMainColor;
//   edit.userInteractionEnabled = YES;
    //实时显示字数
    numLabel.text = [NSString stringWithFormat:@"%lu/12", (unsigned long)textView.text.length];
    
    //字数限制操作
    if (textView.text.length >= 12) {
        
        textView.text = [textView.text substringToIndex:12];
        numLabel.text = @"12/12";
         [MBProgressHUD showSuccess:@"字数不能超过12字哦～～"];
        
    }
    //取消按钮点击权限，并显示提示文字
    if (textView.text.length == 0) {
        
        placeholder.hidden = NO;
//        self.commitButton.userInteractionEnabled = NO;
//        self.commitButton.backgroundColor = [UIColor lightGrayColor];
        
    }
    
}
//- (void)textViewDidBeginEditing:(UITextView *)textView{
//    placeholder.text = @"";
//    
//}
//- (void)textViewDidEndEditing:(UITextView *)textView{
//    
//    if (_textView.text.length == 0) {
//        placeholder.text = @"请输入昵称...";
//    }else{
//        placeholder.text = @"";
//    }
//}
#pragma mark   -------配置导航栏
- (void)setNav{
    self.title = @"修改我的昵称";
    //导航栏title的颜色
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithHexString:@"#424242"],UITextAttributeTextColor, [UIFont fontWithName:@"PingFangSC-Medium" size:18],UITextAttributeFont, nil]];
    
    //导航栏返回按钮
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(16, 38, 28, 14)];
    [button setTitleColor:[UIColor colorWithHexString:@"#424242"] forState:UIControlStateNormal];
    [button setTitle:@"返回" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [button addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = back;
    
    //导航栏保存按钮
    edit = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-16-28, 38, 28, 14)];
    [edit setTitleColor:[UIColor colorWithHexString:@"#ff5252"] forState:UIControlStateNormal];
    [edit setTitle:@"保存" forState:UIControlStateNormal];
    edit.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [edit addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *edited = [[UIBarButtonItem alloc]initWithCustomView:edit];
    self.navigationItem.rightBarButtonItem = edited;
    
}

- (void)goBack{
    
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark   保存
- (void)save{
    if (_textView.text.length ==0 || [CommonTool dx_isNullOrNilWithObject:_textView.text]) {
        [MBProgressHUD showError:@"请输入昵称"];
        return;
    }
      NSString *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userId"];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/updatePersonalInfo",REQUESTHEADER] andParameter:@{@"userId":userId,@"userNickname":_textView.text} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        [MBProgressHUD hideHUD];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            [self.navigationController popViewControllerAnimated:YES];
            [MBProgressHUD showSuccess:@"修改成功"];
              NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
            [user setObject:[NSString stringWithFormat:@"%@",_textView.text] forKey:@"userNickname"];

        } else {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
}

//http://192.168.1.108:8080/mobile/user/updatePersonalInfo/userId/userSignature


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
