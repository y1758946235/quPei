
//
//  LYFocusOnAndFansViewController.m
//  LvYue
//
//  Created by KentonYu on 16/8/1.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "LYDetailDataViewController.h"
#import "LYFocusOnAndFansTableViewCell.h"
#import "LYFocusOnAndFansViewController.h"
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "MBProgressHUD+NJ.h"


static NSString *const LYFocusOnAndFansTableViewCellIdentity = @"LYFocusOnAndFansTableViewCellIdentity";

@interface LYFocusOnAndFansViewController () <
    UITableViewDelegate,
    UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<NSDictionary *> *tableViewArray;

@end

@implementation LYFocusOnAndFansViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    switch (self.type) {
        case LYFocusOnAndFansViewControllerTypeFocusOn: {
            self.title = @"我的关注";
            break;
        }
        case LYFocusOnAndFansViewControllerFans: {
            self.title = @"我的粉丝";
            break;
        }
    }

    [self p_loadData];
}

#pragma mark TableView DataSource & Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableViewArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100.f;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LYFocusOnAndFansTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LYFocusOnAndFansTableViewCellIdentity forIndexPath:indexPath];
    [cell configData:self.tableViewArray[indexPath.row]];
    cell.tapFocusOnImageViewBlock = ^(id sender) {
        [self p_processFocusOn:indexPath];
    };
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    LYDetailDataViewController *vc = [LYDetailDataViewController new];
    vc.userId                      = self.tableViewArray[indexPath.row][@"id"];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Pravite

- (void)p_loadData {

    NSString *requestURL;
    switch (self.type) {
        case LYFocusOnAndFansViewControllerTypeFocusOn: {
            requestURL = @"/mobile/userFriend/getMyFoucsList";
            break;
        }
        case LYFocusOnAndFansViewControllerFans: {
            requestURL = @"/mobile/userFriend/getFansList";
            break;
        }
    }

    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@%@", REQUESTHEADER, requestURL]
        andParameter:@{
            @"user_id": [LYUserService sharedInstance].userID
        }
        success:^(id successResponse) {
            if ([successResponse[@"code"] integerValue] == 200) {
                self.tableViewArray = successResponse[@"data"][@"users"];
                [self.tableView reloadData];
            } else {
                [MBProgressHUD showError:@"加载失败，请重试"];
            }
        }
        andFailure:^(id failureResponse) {
            [MBProgressHUD showError:@"服务器繁忙,请重试"];
        }];
}

- (void)p_processFocusOn:(NSIndexPath *)indexPath {
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/userFriend/focusOther", REQUESTHEADER]
        andParameter:@{
            @"user_id": [LYUserService sharedInstance].userID,
            @"other_user_id": self.tableViewArray[indexPath.row][@"id"]
        }
        success:^(id successResponse) {
            if ([successResponse[@"code"] integerValue] == 200) {
                NSMutableArray *array    = [self.tableViewArray mutableCopy];
                NSMutableDictionary *dic = [array[indexPath.row] mutableCopy];
                [dic setObject:([dic[@"isgz"] integerValue] == 1 ? @2 : @1) forKey:@"isgz"];
                [array replaceObjectAtIndex:indexPath.row withObject:[dic copy]];
                self.tableViewArray = [array copy];
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];

                if ([dic[@"isgz"] integerValue] == 1) {
                    [MBProgressHUD showSuccess:@"关注成功"];
                    
                }
                else {
                    [MBProgressHUD showSuccess:@"取消关注成功"];
                }

            } else {
                [MBProgressHUD showError:@"处理失败，请重试"];
            }
        }
        andFailure:^(id failureResponse) {
            [MBProgressHUD showError:@"服务器繁忙,请重试"];
        }];
}

#pragma mark - Getter

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStylePlain];
        [_tableView registerNib:[UINib nibWithNibName:@"LYFocusOnAndFansTableViewCell" bundle:nil] forCellReuseIdentifier:LYFocusOnAndFansTableViewCellIdentity];
        _tableView.separatorInset  = UIEdgeInsetsMake(0, 100, 0, 0);
        _tableView.delegate        = self;
        _tableView.dataSource      = self;
        _tableView.tableHeaderView = [[UIView alloc] init];
        _tableView.tableFooterView = [[UIView alloc] init];
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

@end
