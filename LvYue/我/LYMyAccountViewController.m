//
//  LYMyAccountViewController.m
//  LvYue
//
//  Created by KentonYu on 16/7/22.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "LYGetCoinViewController.h"
#import "LYHttpPoster.h"
#import "LYMyAccountTableViewCell.h"
#import "LYMyAccountViewController.h"
#import "LYUserService.h"
#import "MBProgressHUD+NJ.h"
#import "VipInfoViewController.h"
#import "WalletDetailViewController.h"
#import "WithDrawRedNumViewController.h"
#import "WithdrawRedViewController.h"

static NSString *const LYMyAccountTableViewCellIdentity = @"LYMyAccountTableViewCellIdentity";

@interface LYMyAccountViewController () <
    UITableViewDataSource,
    UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *tableViewFooterView;

// 账户余额
@property (nonatomic, assign) NSInteger accountAmount;
// 是否显示充值  默认不显示
@property (nonatomic, assign) BOOL showGetCoinButton;

@end

@implementation LYMyAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"我的账户";
    self.view.backgroundColor = RGBCOLOR(247, 247, 247);
    [self setRightButton:[UIImage imageNamed:@"明细"] title:nil target:self action:@selector(p_pushDetail:)];

    self.showGetCoinButton = [[[NSUserDefaults standardUserDefaults] valueForKey:@"ShowGetCoinKey"] boolValue];
    
    [self p_loadAccountAmount];

    [self.tableView reloadData];
}

#pragma mark TableView DataSource & Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LYMyAccountTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LYMyAccountTableViewCellIdentity forIndexPath:indexPath];
    // 金币
    if (indexPath.row == 0) {
        cell.fetchBlock = ^(id sender) {
            LYGetCoinViewController *vc = [LYGetCoinViewController new];
            vc.accountAmount            = self.accountAmount;
            [self.navigationController pushViewController:vc animated:YES];
        };
        [cell configData:LYMyAccountTableViewCellTypeCoin coin:[NSString stringWithFormat:@"%@", @(self.accountAmount)] showGetCoinButton:self.showGetCoinButton];
    }
    // 提现
    if (indexPath.row == 1) {
        [cell configData:LYMyAccountTableViewCellWithDraw coin:@"0" showGetCoinButton:self.showGetCoinButton];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    // 提现
    if (indexPath.row == 1) {
        WithdrawRedViewController *vc = [[WithdrawRedViewController alloc] init];
        vc.hongdou                    = [NSString stringWithFormat:@"%ld", (long)self.accountAmount];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - Pravite

- (void)p_becomeVip:(id)sender {
    VipInfoViewController *vipInfo = [[VipInfoViewController alloc] init];
    vipInfo.coinNum                = [NSString stringWithFormat:@"%@", @(self.accountAmount)];
    [self.navigationController pushViewController:vipInfo animated:YES];
}

// 加载账户余额
- (void)p_loadAccountAmount {

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/need/hongdou", REQUESTHEADER]
        andParameter:@{
            @"user_id": [LYUserService sharedInstance].userID
        }
        success:^(id successResponse) {
            MLOG(@"结果:%@", successResponse);
            [MBProgressHUD hideHUDForView:self.view];
            if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
                self.accountAmount = [successResponse[@"data"][@"data"][@"hongdou"] integerValue];
                [self.tableView reloadData];
            } else {
                [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"msg"]]];
            }
        }
        andFailure:^(id failureResponse) {
            [MBProgressHUD hideHUDForView:self.view];
            [MBProgressHUD showError:@"查询余额失败，请重试"];
        }];
}

- (void)p_pushDetail:(id)sender {
    WalletDetailViewController *vc = [[WalletDetailViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Getter

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = ({
            UITableView *tableView    = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64.f) style:UITableViewStylePlain];
            tableView.backgroundColor = RGBCOLOR(247, 247, 247);
            tableView.delegate        = self;
            tableView.dataSource      = self;
            tableView.tableHeaderView = [[UIView alloc] init];
            tableView.tableFooterView = self.tableViewFooterView;
            [tableView registerNib:[UINib nibWithNibName:@"LYMyAccountTableViewCell" bundle:nil] forCellReuseIdentifier:LYMyAccountTableViewCellIdentity];
            [self.view addSubview:tableView];
            tableView;
        });
    }
    return _tableView;
}

- (UIView *)tableViewFooterView {
    if (!_tableViewFooterView) {
        _tableViewFooterView = ({
            UIView *view           = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 60.f)];
            view.backgroundColor   = RGBCOLOR(247, 247, 247);
            UIButton *button       = [[UIButton alloc] initWithFrame:CGRectMake(15.f, 16.f, SCREEN_WIDTH - 30.f, 44.f)];
            button.backgroundColor = [UIColor whiteColor];
            button.titleLabel.font = [UIFont systemFontOfSize:16.f];
            [button setTitle:@"成为会员" forState:UIControlStateNormal];
            [button setTitleColor:RGBCOLOR(19, 199, 175) forState:UIControlStateNormal];
            [button addTarget:self action:@selector(p_becomeVip:) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:button];
            view;
        });
    }
    return _tableViewFooterView;
}

@end
