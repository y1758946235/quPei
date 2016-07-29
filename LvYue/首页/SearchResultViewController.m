//
//  SearchResultViewController.m
//  LvYue
//
//  Created by 郑洲 on 16/3/18.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "HomeModel.h"
#import "HomeModel.h"
#import "LYDetailDataViewController.h"
#import "LYHttpPoster.h"
#import "MBProgressHUD+NJ.h"
#import "MJRefresh.h"
#import "SearchResultTableViewCell.h"
#import "SearchResultViewController.h"

@interface SearchResultViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, assign) NSInteger pageIndex;

@property (nonatomic, strong) HomeModel *homeModel;

@end

@implementation SearchResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title     = @"搜索结果";
    self.pageIndex = 1;

    _tableView                 = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    _tableView.delegate        = self;
    _tableView.dataSource      = self;
    _tableView.backgroundColor = RGBACOLOR(244, 245, 246, 1);
    _tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
    _tableView.mj_footer       = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(getNextPage)];
    [self.view addSubview:_tableView];
}

- (void)getNextPage {
    self.pageIndex++;
    [MBProgressHUD showMessage:nil toView:self.view];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/need/search", REQUESTHEADER] andParameter:@{ @"sex": self.sex,
                                                                                                                            @"city": self.city,
                                                                                                                            @"province": @"0",
                                                                                                                            @"country": @"0",
                                                                                                                            @"ages": self.age,
                                                                                                                            @"searchs": self.searchs,
                                                                                                                            @"longitude": self.longitude,
                                                                                                                            @"latitude": self.latitude,
                                                                                                                            @"pageNum": [NSString stringWithFormat:@"%ld", (long) self.pageIndex] }
        success:^(id successResponse) {
            MLOG(@"结果:%@", successResponse);
            if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                for (NSDictionary *dict in successResponse[@"data"][@"data"]) {
                    self.homeModel    = [[HomeModel alloc] initWithDict:dict];
                    NSString *isExist = @"0";
                    for (HomeModel *model in self.resultData) {
                        if ([self.homeModel.id isEqualToString:model.id]) {
                            isExist = @"1";
                            break;
                        }
                    }
                    if ([isExist isEqualToString:@"0"]) {
                        [self.resultData addObject:self.homeModel];
                    }
                }
                if (!self.resultData.count) {
                    [MBProgressHUD showError:@"未找到符合条件的用户"];
                }
                [self.tableView reloadData];
            } else {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"msg"]]];
            }
        }
        andFailure:^(id failureResponse) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [MBProgressHUD showError:@"没有相关城市信息"];
        }];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headView         = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
    headView.backgroundColor = RGBACOLOR(244, 245, 246, 1);

    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 7, 16, 16)];
    imageView.image        = [UIImage imageNamed:@"用户"];
    [headView addSubview:imageView];

    UILabel *label  = [[UILabel alloc] initWithFrame:CGRectMake(30, 7, SCREEN_WIDTH - 30, 16)];
    label.text      = @"用户";
    label.textColor = RGBACOLOR(29, 189, 159, 1);
    label.font      = [UIFont systemFontOfSize:16];
    [headView addSubview:label];

    return headView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _resultData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    SearchResultTableViewCell *cell = [SearchResultTableViewCell cellWithTableView:tableView andIndexPath:indexPath];
    HomeModel *homeModel            = self.resultData[indexPath.row];
    [cell fillData:homeModel];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row == _resultData.count - 1) {
        cell.line.hidden = YES;
    } else {
        cell.line.hidden = NO;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    HomeModel *model                 = _resultData[indexPath.row];
    LYDetailDataViewController *deta = [[LYDetailDataViewController alloc] init];
    deta.userId                      = model.id;
    [self.navigationController pushViewController:deta animated:YES];
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
