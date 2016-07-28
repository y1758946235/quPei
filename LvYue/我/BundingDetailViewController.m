//
//  BundingDetailViewController.m
//  
//
//  Created by 广有射怪鸟事 on 15/10/3.
//
//

#import "BundingDetailViewController.h"
#import "MBProgressHUD+NJ.h"
#import "LYHttpPoster.h"
#import "LYUserService.h"

@interface BundingDetailViewController ()<UIAlertViewDelegate>

@property (nonatomic,strong) UITextField *numText;

@end

@implementation BundingDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = [NSString stringWithFormat:@"%@",self.titleString];
    
    [self createView];
}

- (void)createView{
    UIImageView *typeImg = [[UIImageView alloc] init];
    typeImg.center = CGPointMake(kMainScreenWidth / 2, 150);
    typeImg.bounds = CGRectMake(0, 0, 170, 130);
    typeImg.image = [UIImage imageNamed:self.typeString];
    [self.view addSubview:typeImg];
    
    self.numText = [[UITextField alloc] init];
    self.numText.center = CGPointMake(kMainScreenWidth / 2, typeImg.frame.origin.y + 200);
    self.numText.bounds = CGRectMake(0, 0, kMainScreenWidth - 60, 40);
    self.numText.returnKeyType = UIReturnKeyDone;
    [self.numText addTarget:self action:@selector(resignFirstResponder) forControlEvents:UIControlEventEditingDidEndOnExit];
    self.numText.keyboardType = UIKeyboardTypeEmailAddress;
    self.numText.layer.borderWidth = 0.5;
    self.numText.layer.borderColor = RGBACOLOR(238, 238, 238, 1).CGColor;
    if ([self.titleString isEqualToString:@"支付宝填写"]) {
        self.numText.placeholder = @"请输入您的支付宝账号";
        if (![self.alipay_id  isEqual: @""]) {
            self.numText.placeholder = [NSString stringWithFormat:@"已填写账号%@",self.alipay_id];
        }
    }
    else{
        self.numText.placeholder = @"请输入您的微信账号";
        if (![self.weixin_id  isEqual: @""]) {
            self.numText.placeholder = [NSString stringWithFormat:@"已填写账号%@",self.weixin_id];
        }
    }
    [self.view addSubview:self.numText];
    
    UIButton *bundingBtn = [[UIButton alloc] init];
    [bundingBtn setCenter:CGPointMake(kMainScreenWidth / 2, typeImg.frame.origin.y + 250)];
    [bundingBtn setBounds:CGRectMake(0, 0, kMainScreenWidth - 60, 40)];
    [bundingBtn setBackgroundColor:RGBACOLOR(28, 198, 158, 1)];
    [bundingBtn setTitle:[NSString stringWithFormat:@"%@",self.statusString] forState:UIControlStateNormal];
    [bundingBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [bundingBtn addTarget:self action:@selector(bunding) forControlEvents:UIControlEventTouchUpInside];
    [bundingBtn.layer setCornerRadius:4];
    [self.view addSubview:bundingBtn];
}

- (void)bunding{
    if (self.numText.text.length == 0 || [self isBlankString:self.numText.text]) {
        [MBProgressHUD showError:@"账号不能为空"];
        return;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"该账号保存后将成为收款账号，请认真核对，确认吗?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        if ([self.titleString isEqualToString:@"支付宝填写"]) {
            [MBProgressHUD showMessage:nil toView:self.view];
            [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/update",REQUESTHEADER] andParameter:@{@"id":[LYUserService sharedInstance].userID,@"alipay_id":self.numText.text} success:^(id successResponse) {
                MLOG(@"结果:%@",successResponse);
                if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    [MBProgressHUD showSuccess:@"保存成功"];
                    NSDictionary *dict = @{@"alipay_id":self.numText.text};
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"changealipay_id" object:nil userInfo:dict];
                    [self.navigationController popViewControllerAnimated:YES];
                } else {
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
                }
            } andFailure:^(id failureResponse) {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [MBProgressHUD showError:@"服务器繁忙,请重试"];
            }];
        }
        else{
            [MBProgressHUD showMessage:nil toView:self.view];
            [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/update",REQUESTHEADER] andParameter:@{@"id":[LYUserService sharedInstance].userID,@"weixin_id":self.numText.text} success:^(id successResponse) {
                MLOG(@"结果:%@",successResponse);
                if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    [MBProgressHUD showSuccess:@"保存成功"];
                    NSDictionary *dict = @{@"weixin_id":self.numText.text};
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeweixin_id" object:nil userInfo:dict];
                    [self.navigationController popViewControllerAnimated:YES];
                } else {
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
                }
            } andFailure:^(id failureResponse) {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [MBProgressHUD showError:@"服务器繁忙,请重试"];
            }];
        }
    }
}

#pragma mark 判断是否为空或只有空格

- (BOOL)isBlankString:(NSString *)string{
    
    if (string == nil) {
        return YES;
    }
    
    if (string == NULL) {
        return YES;
    }
    
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}

@end
