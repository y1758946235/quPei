//
//  SearchNewFriendController.m
//  LvYue
//
//  Created by apple on 15/10/8.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import "LYDetailDataViewController.h"
#import "LYHttpPoster.h"
#import "MBProgressHUD+NJ.h"
#import "SearchNewFriendController.h"
#import "SearchNewFriendResultCell.h"
#import "SearchResultPerson.h"

@interface SearchNewFriendController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *modelArray;

@end

@implementation SearchNewFriendController


- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    self.title                                    = @"添加新的朋友";
    self.navigationController.navigationBarHidden = NO;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    //初始化
    _modelArray = [NSMutableArray array];

    _tableView                 = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    _tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.dataSource      = self;
    _tableView.delegate        = self;
    [self.view addSubview:_tableView];
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
    SearchNewFriendResultCell *cell = [SearchNewFriendResultCell searchNewFriendResultCellWithTableView:tableView];
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

    UIView *headerView         = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 44)];
    headerView.backgroundColor = [UIColor whiteColor];
    _searchBar                 = [[UISearchBar alloc] initWithFrame:CGRectMake(10, 0, kMainScreenWidth - 70, 44)];
    _searchBar.searchBarStyle  = UISearchBarStyleMinimal;
    _searchBar.placeholder     = @"输入用户昵称进行搜索";
    _searchBar.delegate        = self;
    [headerView addSubview:_searchBar];
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    searchBtn.frame     = CGRectMake(kMainScreenWidth - 60, 0, 44, 44);
    [searchBtn setTitle:@"搜索" forState:UIControlStateNormal];
    [searchBtn setBackgroundColor:[UIColor clearColor]];
    [searchBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    searchBtn.titleLabel.font = kFont16;
    [searchBtn addTarget:self action:@selector(searchNewFriend:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:searchBtn];
    return headerView;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [_searchBar resignFirstResponder];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    SearchResultPerson *model              = _modelArray[indexPath.row];
    LYDetailDataViewController *detailDest = [[LYDetailDataViewController alloc] init];
    MLOG(@"%@", model.userID);
    detailDest.userId = model.userID;
    [self.navigationController pushViewController:detailDest animated:YES];
}


#pragma mark - 点击搜索
- (void)searchNewFriend:(UIButton *)sender {

    [_searchBar resignFirstResponder];
    if ([_searchBar.text isEqualToString:@""]) {
        [_modelArray removeAllObjects];
        [_tableView reloadData];
        return;
    }
    [_modelArray removeAllObjects];
    [MBProgressHUD showMessage:@"搜索中.."];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/findPeople", REQUESTHEADER] andParameter:@{ @"name": _searchBar.text } success:^(id successResponse) {
        MLOG(@"搜索结果:%@", successResponse);
        if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
            [MBProgressHUD hideHUD];
            NSArray *array = successResponse[@"data"][@"user"];
            for (NSDictionary *dict in array) {
                SearchResultPerson *model = [[SearchResultPerson alloc] initWithDict:dict];
                [_modelArray addObject:model];
            }
            [_tableView reloadData];
        } else {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"查询失败!"];
        }
    }
        andFailure:^(id failureResponse) {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"服务器繁忙,请重试!"];
        }];
}


#pragma mark - UISearchBarDelegate
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {

    [_searchBar resignFirstResponder];
    if ([_searchBar.text isEqualToString:@""]) {
        [_modelArray removeAllObjects];
        [_tableView reloadData];
        return;
    }
    [_modelArray removeAllObjects];
    [MBProgressHUD showMessage:@"搜索中.."];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/findPeople", REQUESTHEADER] andParameter:@{ @"name": _searchBar.text } success:^(id successResponse) {
        MLOG(@"搜索结果:%@", successResponse);
        if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
            [MBProgressHUD hideHUD];
            NSArray *array = successResponse[@"data"][@"user"];
            for (NSDictionary *dict in array) {
                SearchResultPerson *model = [[SearchResultPerson alloc] initWithDict:dict];
                [_modelArray addObject:model];
            }
            [_tableView reloadData];
        } else {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"查询失败!"];
        }
    }
        andFailure:^(id failureResponse) {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"服务器繁忙,请重试!"];
        }];
}


@end
