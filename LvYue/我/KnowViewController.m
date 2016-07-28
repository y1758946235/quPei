//
//  KnowViewController.m
//  LvYue
//
//  Created by 广有射怪鸟事 on 15/9/30.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import "KnowViewController.h"
#import "StudyKnowViewController.h"
#import "IdKnowViewController.h"
#import "CarKnowViewController.h"
#import "VideoKnowViewController.h"
#import "FinishKnowViewController.h"
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "MBProgressHUD+NJ.h"
#import "BundingViewController.h"

@interface KnowViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>

@property (nonatomic,strong)NSArray *array;

@end

@implementation KnowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
#ifdef kEasyVersion
    
    self.array = @[@"身份认证",@"收款账号",@"学历认证"];

#else
    
    self.array = @[@"视频认证",@"身份认证",@"收款账号",@"学历认证",@"车辆认证"];
    
#endif
    
    self.title = @"资料认证";
    self.view.backgroundColor = RGBACOLOR(238, 238, 238, 1);
    
    [self createTableView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(knowChange:) name:@"knowChange" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changealipay_id:) name:@"changealipay_id" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeweixin_id:) name:@"changeweixin_id" object:nil];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)createTableView{
    UITableView *table = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    table.dataSource = self;
    table.delegate = self;
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:table];
}

- (void)knowChange:(NSNotification *)aNotification{
    NSDictionary *dict = aNotification.userInfo;
    if (dict[@"video"]) {
        self.video = 1;
    }
    if (dict[@"iden"]) {
        self.identity = 1;
    }
    if (dict[@"edu"]) {
        self.edu = 1;
    }
    if (dict[@"car"]) {
        self.car = 1;
    }
}

- (void)changealipay_id:(NSNotification *)aNotification{
    NSDictionary *dict = aNotification.userInfo;
    self.alipay = dict[@"alipay_id"];
}

- (void)changeweixin_id:(NSNotification *)aNotification{
    NSDictionary *dict = aNotification.userInfo;
    self.weixin = dict[@"weixin_id"];
}


//申请成为向导点击事件
- (void)becomeGuide{
    
#ifdef kEasyVersion
    
    if (self.identity != 2 && self.identity != 1) {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"您必须通过身份认证才能申请验证" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
        return;
    }else if ([self.alipay isEqualToString:@""] || [self.weixin isEqualToString:@""]){
        [MBProgressHUD showError:@"请先填写支付宝账号和微信账号"];
    }
    else{
        [MBProgressHUD showMessage:nil];
        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/addGuide",REQUESTHEADER] andParameter:@{@"user_id":[LYUserService sharedInstance].userID} success:^(id successResponse) {
            MLOG(@"结果:%@",successResponse);
            if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
                [MBProgressHUD hideHUD];
                [MBProgressHUD showSuccess:@"提交成功"];
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
    
#endif
    
    if (self.video == 0 || self.identity == 0) {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"您必须通过视频认证和身份认证才能申请向导" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
        return;
    }else if (self.video == 1 || self.identity == 1) {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"身份正在审核中..." delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
        return;
    }
    else if ([self.alipay isEqualToString:@""] || [self.weixin isEqualToString:@""]){
        [MBProgressHUD showError:@"请先填写支付宝账号和微信账号"];
    }
    else{
        [MBProgressHUD showMessage:nil];
        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/addGuide",REQUESTHEADER] andParameter:@{@"user_id":[LYUserService sharedInstance].userID} success:^(id successResponse) {
            MLOG(@"结果:%@",successResponse);
            if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
                [MBProgressHUD hideHUD];
                [MBProgressHUD showSuccess:@"提交成功"];
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
}

#pragma mark 申请成为名宿

- (void)becomeLive{
    if (self.identity != 2) {
        [[[UIAlertView alloc] initWithTitle:@""
                                    message:@"您必须通过身份认证才能申请民宿"
                                   delegate:self
                          cancelButtonTitle:@"确定"
                          otherButtonTitles: nil] show];
        return;
    }
    else if ([self.alipay isEqualToString:@""] || [self.weixin isEqualToString:@""]){
        [MBProgressHUD showError:@"请先填写支付宝账号和微信账号"];
    }
    else{
        [MBProgressHUD showMessage:nil];
        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/addHostel",REQUESTHEADER] andParameter:@{@"user_id":[LYUserService sharedInstance].userID} success:^(id successResponse) {
            MLOG(@"结果:%@",successResponse);
            if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
                [MBProgressHUD hideHUD];
                [MBProgressHUD showSuccess:@"提交成功"];
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
}

#pragma mark tableview代理

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

#ifdef kEasyVersion
    if (section == 0) {
        return 2;
    }
    else{
        return 1;
    }
#else
    if (section == 0) {
        return 3;
    }
    else{
        return 2;
    }
#endif
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 20;
    }
    else{
        return 0.1;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 200)];
    UIButton *btn = [[UIButton alloc] init];
    btn.center = CGPointMake(kMainScreenWidth / 2, 80);
    btn.bounds = CGRectMake(0, 0, kMainScreenWidth - 40, 40);
    if (self.userType == 0) {
        if ([self.status integerValue] == 0) {
            [btn setTitle:@"申请身份验证" forState:UIControlStateNormal];
        }
        else if ([self.status integerValue] == 1){
            [btn setTitle:@"申请正在审核" forState:UIControlStateNormal];
            btn.enabled = NO;
        }
    }
    else{
        [btn setTitle:@"您已申请验证" forState:UIControlStateNormal];
        btn.enabled = NO;
    }
    [btn.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
    [btn setBackgroundColor:[UIColor colorWithRed:29/255.0 green:189/255.0 blue:159/255.0 alpha:1]];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn.layer setCornerRadius:4];
    [btn addTarget:self action:@selector(becomeGuide) forControlEvents:UIControlEventTouchUpInside];
//    [view addSubview:btn];
    
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(btn.frame.origin.x, btn.frame.origin.y - 80, btn.frame.size.width, 100)];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.font = [UIFont systemFontOfSize:12.0];
    tipLabel.numberOfLines = 0;
    tipLabel.text = @"形象视频认证、身份认证、学历认证、车辆认证，每通过一个认证都会给您显示相应的认证标志，让您的形象满满滴！可以同时提交所有认证，我们会尽快给您审核！";
    tipLabel.textColor = [UIColor grayColor];
    [view addSubview:tipLabel];
    
    
#ifdef kEasyVersion
    
    UIButton *msbtn = [[UIButton alloc] init];
    msbtn.center = CGPointMake(kMainScreenWidth / 2, 140);
    msbtn.bounds = CGRectMake(0, 0, kMainScreenWidth - 40, 40);
    if ([self.provide_stay isEqualToString:@"0"]) {
        [msbtn setTitle:@"民宿认证申请" forState:UIControlStateNormal];
    }
    else{
        [msbtn setTitle:@"民宿申请中" forState:UIControlStateNormal];
        msbtn.enabled = NO;
    }
    if ([self.provide_stay integerValue] == 1) {
        [msbtn setTitle:@"您已申请民宿" forState:UIControlStateNormal];
        msbtn.enabled = NO;
    }
    [msbtn.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
    [msbtn setBackgroundColor:[UIColor whiteColor]];
    [msbtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [msbtn.layer setCornerRadius:4];
    [msbtn addTarget:self action:@selector(becomeLive) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:msbtn];
    
#endif
    
    if (section == 0) {
        return nil;
    }
    else{
        return view;
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *myId = @"myId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:myId];
    }
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = self.array[indexPath.row];
    if (indexPath.section == 1) {
        
#ifdef kEasyVersion
        
        cell.textLabel.text = self.array[indexPath.row + 2];
        
#else
        
        cell.textLabel.text = self.array[indexPath.row + 3];
        
#endif
        
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        
        switch (indexPath.row) {
            case 0:
            {
#ifdef kEasyVersion
                if (self.identity == 1){
                    [[[UIAlertView alloc] initWithTitle:@"" message:@"您的身份认证正在审核，请耐心等待" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil] show];
                }
                else if (self.identity == 2){
                    [[[UIAlertView alloc] initWithTitle:@"" message:@"您已通过身份认证，不能修改" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil] show];
                }
                else{
                    IdKnowViewController *idKnow = [[IdKnowViewController alloc] init];
                    [self.navigationController pushViewController:idKnow animated:YES];
                }
#else
                if (self.video == 1) {
                    [[[UIAlertView alloc] initWithTitle:@"" message:@"您的视频认证正在审核，请耐心等待" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil] show];
                }
                else if (self.video == 2){
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"您已经通过视频认证，确定要修改吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                    alert.tag = 501;
                    [alert show];
                }
                else{
                    VideoKnowViewController *video = [[VideoKnowViewController alloc] init];
                    [self.navigationController pushViewController:video animated:YES];
                }
#endif
            }
                break;
            case 1:
            {
#ifdef kEasyVersion
                
                BundingViewController *bun = [[BundingViewController alloc] init];
                bun.alipay_id = self.alipay;
                bun.weixin_id = self.weixin;
                [self.navigationController pushViewController:bun animated:YES];
                
#else
                if (self.video == 0) {
                    [[[UIAlertView alloc] initWithTitle:@"" message:@"请先视频验证" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
                }
                else if (self.identity == 1){
                    [[[UIAlertView alloc] initWithTitle:@"" message:@"您的身份认证正在审核，请耐心等待" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil] show];
                }
                else if (self.identity == 2){
                    [[[UIAlertView alloc] initWithTitle:@"" message:@"您已通过身份认证，不能修改" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil] show];
                }
                else{
                    IdKnowViewController *idKnow = [[IdKnowViewController alloc] init];
                    [self.navigationController pushViewController:idKnow animated:YES];
                }
#endif
                
            }
                break;
            case 2:
            {
                BundingViewController *bun = [[BundingViewController alloc] init];
                bun.alipay_id = self.alipay;
                bun.weixin_id = self.weixin;
                [self.navigationController pushViewController:bun animated:YES];
            }
                break;
            default:
                break;
        }
        
    }
    else{
        switch (indexPath.row) {
            case 0:
            {
                if (self.edu == 1) {
                    [[[UIAlertView alloc] initWithTitle:@"" message:@"您的学历认证正在审核，请耐心等待" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil] show];
                }
                else if (self.edu == 2){
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"您已经通过学历认证，确定要修改吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                    alert.tag = 503;
                    [alert show];
                }
                else{
                    StudyKnowViewController *study = [[StudyKnowViewController alloc] init];
                    [self.navigationController pushViewController:study animated:YES];
                }
            }
                break;
            case 1:
            {
                if (self.car == 1) {
                    [[[UIAlertView alloc] initWithTitle:@"" message:@"您的车辆认证正在审核，请耐心等待" delegate:self cancelButtonTitle:@"好的" otherButtonTitles: nil] show];
                }
                else if (self.car == 2){
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"您已经通过车辆认证，确定要修改吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                    alert.tag = 504;
                    [alert show];
                }
                else{
                    CarKnowViewController *car = [[CarKnowViewController alloc] init];
                    [self.navigationController pushViewController:car animated:YES];
                }
            }
                break;
            default:
                break;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 1) {
        return 200;
    }
    else{
        return 20;
    }
}

#pragma mark uialertview代理

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (alertView.tag) {
        case 501:
        {
            if (buttonIndex == 1) {
                VideoKnowViewController *video = [[VideoKnowViewController alloc] init];
                [self.navigationController pushViewController:video animated:YES];
            }
        }
            break;
        case 503:
        {
            if (buttonIndex == 1) {
                StudyKnowViewController *study = [[StudyKnowViewController alloc] init];
                [self.navigationController pushViewController:study animated:YES];
            }
        }
            break;
        case 504:
        {
            if (buttonIndex == 1) {
                CarKnowViewController *car = [[CarKnowViewController alloc] init];
                [self.navigationController pushViewController:car animated:YES];
            }
            
        }
            break;
            
        default:
            break;
    }
}

@end
