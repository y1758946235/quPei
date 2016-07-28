//
//  MyRedBeanViewController.m
//  LvYue
//
//  Created by 広有射怪鸟事 on 15/12/15.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import "MyRedBeanViewController.h"
#import "WithdrawRedViewController.h"
#import "GetRedBeanViewController.h"
#import "WhatsRedViewController.h"
#import "WithdrawRedTableViewCell.h"
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "MBProgressHUD+NJ.h"

@interface MyRedBeanViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *tableV;
    NSArray *titleArray;
}

@end

@implementation MyRedBeanViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    
    [self getData];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"我的红豆";
    
    titleArray = @[@"获取红豆",@"什么是红豆"];
    
    [self createView];
    
}

- (void)createView{
    tableV = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight) style:UITableViewStyleGrouped];
    tableV.delegate = self;
    tableV.dataSource = self;
    tableV.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableV];
}

- (void)getData{
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/getDetailInfo",REQUESTHEADER] andParameter:@{@"id":[NSString stringWithFormat:@"%@",[LYUserService sharedInstance].userID]} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            self.hongdou = [NSString stringWithFormat:@"%@",successResponse[@"data"][@"user"][@"hongdou"]];
            [tableV reloadData];
        } else {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
}

#pragma mark tableview代理委托

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    }
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 133;
    }
    else{
        return 44;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    WithdrawRedTableViewCell *cell = [WithdrawRedTableViewCell cellWithTableView:tableView andIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.section == 0) {
        cell.redBeanNumLabel.text = self.hongdou;
        return cell;
    }
    else{
        static NSString *myId = @"myId";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myId];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:myId];
        }
        cell.textLabel.font = [UIFont systemFontOfSize:14.0];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = titleArray[indexPath.row];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    if (indexPath.row == 0) {
//        WithdrawRedViewController *red = [[WithdrawRedViewController alloc] init];
//        red.hongdou = self.hongdou;
//        red.alipay = self.alipay;
//        red.weixin = self.weixin;
//        [self.navigationController pushViewController:red animated:YES];
//    }
    if (indexPath.row == 0){
        GetRedBeanViewController *get = [[GetRedBeanViewController alloc] init];
        [self.navigationController pushViewController:get animated:YES];
    }
    else{
        WhatsRedViewController *what = [[WhatsRedViewController alloc] init];
        [self.navigationController pushViewController:what animated:YES];
    }
    
}

@end
