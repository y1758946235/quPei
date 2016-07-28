//
//  SearchNewFriendController.m
//  LvYue
//
//  Created by apple on 15/10/8.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import "SearchNewGroupController.h"
#import "MBProgressHUD+NJ.h"
#import "SearchNewGroupResultCell.h"
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "SearchResultGroup.h"

@interface SearchNewGroupController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UIAlertViewDelegate>

@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *modelArray;

@end

@implementation SearchNewGroupController


- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    self.title = @"添加新的群组";
    self.navigationController.navigationBarHidden = NO;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //注册通知
    [self registerAllNotifications];
    
    //初始化
    _modelArray = [NSMutableArray array];
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
}


- (void)registerAllNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applyJoinGroup:) name:@"applyToJoinGroup" object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _modelArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchNewGroupResultCell *cell = [SearchNewGroupResultCell searchNewGroupResultCellWithTableView:tableView andIndexPath:indexPath];
    if (_modelArray.count) {
        [cell fillDataWithModel:_modelArray[indexPath.row]];
    }
    return cell;
}


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44.0f;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 44)];
    headerView.backgroundColor = [UIColor whiteColor];
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(10, 0, kMainScreenWidth-70, 44)];
    _searchBar.searchBarStyle = UISearchBarStyleMinimal;
    _searchBar.placeholder = @"输入群组昵称进行搜索";
    _searchBar.delegate = self;
    [headerView addSubview:_searchBar];
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    searchBtn.frame = CGRectMake(kMainScreenWidth-60, 0, 44, 44);
    [searchBtn setTitle:@"搜索" forState:UIControlStateNormal];
    [searchBtn setBackgroundColor:[UIColor clearColor]];
    [searchBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    searchBtn.titleLabel.font = kFont16;
    [searchBtn addTarget:self action:@selector(searchNewGroup:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:searchBtn];
    return headerView;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [_searchBar resignFirstResponder];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - 点击搜索
- (void)searchNewGroup:(UIButton *)sender {
    
    [_modelArray removeAllObjects];
    
    [_searchBar resignFirstResponder];
    if ([_searchBar.text isEqualToString:@""]) {
        [_tableView reloadData];
        return;
    }
    [MBProgressHUD showMessage:@"搜索中.."];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/group/findGounp",REQUESTHEADER] andParameter:@{@"name":_searchBar.text} success:^(id successResponse) {
        MLOG(@"搜索结果:%@",successResponse);
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            [MBProgressHUD hideHUD];
            NSArray *array = successResponse[@"data"][@"group"];
            for (NSDictionary *dict in array) {
                SearchResultGroup *group = [[SearchResultGroup alloc] initWithDict:dict];
                [_modelArray addObject:group];
            }
            [_tableView reloadData];
        } else {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"查询失败!"];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"服务器繁忙,请重试!"];
    }];
}


#pragma mark - UISearchBarDelegate
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [_modelArray removeAllObjects];
    
    [_searchBar resignFirstResponder];
    if ([_searchBar.text isEqualToString:@""]) {
        [_tableView reloadData];
        return;
    }
    [MBProgressHUD showMessage:@"搜索中.."];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/group/findGounp",REQUESTHEADER] andParameter:@{@"name":_searchBar.text} success:^(id successResponse) {
        MLOG(@"搜索结果:%@",successResponse);
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            [MBProgressHUD hideHUD];
            NSArray *array = successResponse[@"data"][@"group"];
            for (NSDictionary *dict in array) {
                SearchResultGroup *group = [[SearchResultGroup alloc] initWithDict:dict];
                [_modelArray addObject:group];
            }
            [_tableView reloadData];
        } else {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"查询失败!"];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"服务器繁忙,请重试!"];
    }];
}


#pragma mark - 通知中心
- (void)applyJoinGroup:(NSNotification *)aNotification {
    NSIndexPath *indexPath = [aNotification userInfo][@"indexPath"];
    NSString *groupID = [self.modelArray[indexPath.row] groupID];
    
    if (kSystemVersion >= 8.0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"申请入群" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"请输入验证信息";
        }];
        UIAlertAction *applyAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [MBProgressHUD showMessage:@"发送申请中.." toView:self.view];
            UITextField *textField = alertController.textFields[0];
            [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/group/enterRequest",REQUESTHEADER] andParameter:@{@"user_id":[LYUserService sharedInstance].userID,@"group_id":groupID,@"request_info":textField.text} success:^(id successResponse) {
                if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    [MBProgressHUD showSuccess:@"发送成功"];
                } else {
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
                }
            } andFailure:^(id failureResponse) {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [MBProgressHUD showError:@"服务器繁忙,请重试"];
            }];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:applyAction];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"申请入群" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        UITextField *textField = [alertView textFieldAtIndex:0];
        textField.placeholder = @"请输入验证信息";
        [alertView show];
    }
}


#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [MBProgressHUD showMessage:@"发送申请中.." toView:self.view];
        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/group/enterRequest",REQUESTHEADER] andParameter:@{@"user_id":[LYUserService sharedInstance].userID,@"group_id":alertView.message,@"request_info":[[alertView textFieldAtIndex:0] text]} success:^(id successResponse) {
            if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [MBProgressHUD showSuccess:@"发送成功"];
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


@end
