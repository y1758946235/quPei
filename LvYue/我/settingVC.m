//
//  settingVC.m
//  LvYue
//
//  Created by X@Han on 16/12/21.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "settingVC.h"
#import "notificationVC.h"
#import "CleanCacheViewController.h"
#import "MBProgressHUD+NJ.h"
#import "SDImageCache.h"
#import "AFNetworking.h"
#import "FeedBackViewController.h"
#import "LYHttpPoster.h"
#import "NewLoginViewController.h"
#import "AboutUsViewController.h"
#import "NoticeViewController.h"
@interface settingVC ()<UITableViewDelegate,UITableViewDataSource>{
    UITableView *table;
    NSArray *titleArr;
    NewLoginViewController *vc;
}

@end

@implementation settingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    titleArr = @[@"通知设置",@"清除缓存",@"用户反馈",@"关于我们"];
    [self setUI];
    
    [self setNav];
}


- (void)setUI{
    table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStylePlain];
    table.dataSource = self;
    table.delegate = self;
    table.rowHeight = 48;
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:table];
    
    //退出登录
    UIButton *loginBtn = [[UIButton alloc]init];
    loginBtn.translatesAutoresizingMaskIntoConstraints = NO;
    loginBtn.backgroundColor = [UIColor colorWithHexString:@"#ff5252"];
    loginBtn.layer.cornerRadius = 18;
    loginBtn.clipsToBounds = YES;
    loginBtn.layer.shadowOffset = CGSizeMake(2, 4);
    loginBtn.layer.shadowColor = [UIColor colorWithRed:32 green:32 blue:32 alpha:0.12].CGColor;
    [loginBtn setTitle:@"退出登录" forState:UIControlStateNormal];
    [loginBtn setTitleColor:[UIColor colorWithHexString:@"#ffffff"] forState:UIControlStateNormal];
    loginBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [loginBtn addTarget:self action:@selector(quite) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginBtn];
    
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-100-[loginBtn]-100-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(loginBtn)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-240-[loginBtn(==36)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(loginBtn)]];
}

#pragma mark   ----退出登录
- (void)quite{
    WS(weakSelf)
    NSString *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userId"];
//    [self dismissViewControllerAnimated:YES completion:nil];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/login/loginOut",REQUESTHEADER] andParameter:@{@"userId":userId} success:^(id successResponse) {
        NSLog(@"退出登录:%@",successResponse);
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
//            [MBProgressHUD showSuccess:@"退出登录成功，欢迎回来哦"];
            
            [weakSelf performSelector:@selector(gotoLogin) withObject:self afterDelay:1];
        }
    } andFailure:^(id failureResponse) {
        
    }];
  
    
}
-(void)gotoLogin{
   
    //清除单例数据
    LYUserService *service = [LYUserService sharedInstance];
    NewLoginViewController *loginVC = [[NewLoginViewController alloc]init];
    [service  loginOutWithController:loginVC compeletionBlock:^{
         
//        for (UIViewController *vcHome in weakSelf.navigationController.viewControllers) {
        
//            if ([vcHome isKindOfClass:[NewLoginViewController class]]) {
//                [weakSelf.navigationController popToViewController:vcHome animated:YES];
//            }
//        }
    }];
     

    
    }
     
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
   
          return 4;
   
}
#pragma mark tableview代理方法

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
   
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.selectionStyle = UITableViewCellAccessoryNone;
        cell.textLabel.text = titleArr[indexPath.row];
        cell.textLabel.textColor = [UIColor colorWithHexString:@"#424242"];
        cell.textLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
   }

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   
    
    if (indexPath.row==0) {
        //通知设置
        notificationVC *noti = [[notificationVC alloc]init];
        [self.navigationController pushViewController:noti animated:YES];
    }
    
    if (indexPath.row==1) {
        [MBProgressHUD  showMessage:nil toView:self.view];
        [self performSelector:@selector(cleand) withObject:self afterDelay:0.5];
        
    }
    
    if (indexPath.row==2) {
        //用户反馈
        FeedBackViewController *feedBack = [[FeedBackViewController alloc]init];
        [self.navigationController pushViewController:feedBack animated:YES];
    }
    
    if (indexPath.row==3) {
        //关于我们
        AboutUsViewController *vc = [[AboutUsViewController alloc ]init];
        [self.navigationController pushViewController:vc animated:YES];
    }
        
    
  
}

-(void)cleand{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    //清理缓存
    [[SDImageCache sharedImageCache] clearDisk];
    [[SDImageCache sharedImageCache] clearMemory];
    [MBProgressHUD showSuccess:@"清理成功"];
}
#pragma mark   -------配置导航栏
- (void)setNav{
    self.title = @"常见问题";
    //导航栏title的颜色
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithHexString:@"#424242"],UITextAttributeTextColor, [UIFont fontWithName:@"PingFangSC-Medium" size:18],UITextAttributeFont, nil]];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:@"#ffffff"];
    //导航栏返回按钮
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(16, 38, 28, 14)];
    [button setTitleColor:[UIColor colorWithHexString:@"#424242"] forState:UIControlStateNormal];
    [button setTitle:@"返回" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [button addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = back;
    
    
}

- (void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
}


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
