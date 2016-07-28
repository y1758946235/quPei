//
//  BlockListViewController.m
//  LvYue
//
//  Created by 広有射怪鸟事 on 16/1/19.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "BlockListViewController.h"
#import "LYUserService.h"
#import "LYHttpPoster.h"
#import "MBProgressHUD+NJ.h"
#import "DetailDataViewController.h"
#import "UIImageView+WebCache.h"
#import "BlockListModel.h"
#import "BlockListTableViewCell.h"

@interface BlockListViewController()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableView;

@property (nonatomic,strong) NSMutableArray *blockUserArray;

@property (nonatomic,strong) BlockListModel *listModel;

@end

@implementation BlockListViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getDataFromWeb];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.blockUserArray = [[NSMutableArray alloc] init];
    
    self.title = @"屏蔽列表";
    
    [self createView];
    
}

- (void)createView{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
}

#pragma mark 网络请求

- (void)getDataFromWeb{
    
    [MBProgressHUD showMessage:nil toView:self.view];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/userFriend/blacklist",REQUESTHEADER] andParameter:@{@"user_id":[NSString stringWithFormat:@"%@",[LYUserService sharedInstance].userID]} success:^(id successResponse) {
        MLOG(@"用户屏蔽列表结果:%@",successResponse);
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            [self.blockUserArray removeAllObjects];
            for (NSDictionary *dict in successResponse[@"data"][@"list"]) {
                self.listModel = [[BlockListModel alloc] initWithDict:dict];
                [self.blockUserArray addObject:self.listModel];
            }
            [self.tableView reloadData];
        } else {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
}

#pragma mark uitableview代理委托

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.blockUserArray.count) {
        return self.blockUserArray.count;
    }
    else{
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.blockUserArray.count) {
        self.listModel = self.blockUserArray[indexPath.row];
    }
    BlockListTableViewCell *cell = [BlockListTableViewCell cellWithTableView:tableView andIndexPath:indexPath];
    [cell fillWithDate:self.listModel];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.listModel = self.blockUserArray[indexPath.row];
    DetailDataViewController *detail = [[DetailDataViewController alloc] init];
    detail.friendId = [self.listModel.userId integerValue];
    [self.navigationController pushViewController:detail animated:YES];
}

@end
