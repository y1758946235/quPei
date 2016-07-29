//
//  WhoComeViewController.m
//  LvYue
//
//  Created by 広有射怪鸟事 on 15/12/18.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import "LYDetailDataViewController.h"
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "MBProgressHUD+NJ.h"
#import "WhoComeModel.h"
#import "WhoComeTableViewCell.h"
#import "WhoComeViewController.h"

@interface WhoComeViewController () <UITableViewDataSource, UITableViewDelegate> {
    UITableView *tableV;

    NSMutableArray *nearArray;       //最近来访人数组
    NSMutableArray *beforeComeArray; //以前来访人数组

    WhoComeModel *model; //模型
}

@end

@implementation WhoComeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.title = @"最近来访";

    nearArray       = [[NSMutableArray alloc] init];
    beforeComeArray = [[NSMutableArray alloc] init];

    [self createView];

    [self getDataFromWeb];
}

#pragma mark 网络请求

- (void)getDataFromWeb {
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/visitorList", REQUESTHEADER] andParameter:@{ @"user_id": [LYUserService sharedInstance].userID,
                                                                                                                                 @"page": @"1" }
        success:^(id successResponse) {
            MLOG(@"结果:%@", successResponse);
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
                NSArray *array = successResponse[@"data"][@"data"];
                for (NSDictionary *dict in array) {
                    model = [[WhoComeModel alloc] initWithDict:dict];
                    if ([model.timeType isEqualToString:@"1"]) {
                        [nearArray addObject:model];
                    } else if ([model.timeType isEqualToString:@"2"]) {
                        [beforeComeArray addObject:model];
                    }
                }
                [tableV reloadData];
            } else {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"msg"]]];
            }
        }
        andFailure:^(id failureResponse) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [MBProgressHUD showError:@"服务器繁忙,请重试"];
        }];
}

- (void)createView {
    tableV            = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight) style:UITableViewStyleGrouped];
    tableV.delegate   = self;
    tableV.dataSource = self;
    [self.view addSubview:tableV];
}

#pragma mark tableview代理

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return nearArray.count;
    } else {
        return beforeComeArray.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 66;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        if (nearArray.count) {
            return @"最近来访";
        } else {
            return @"暂无最近来访";
        }
    } else {
        if (beforeComeArray.count) {
            return @"过去来访";
        } else {
            return nil;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        NSArray *nArray = [[nearArray reverseObjectEnumerator] allObjects];
        model           = nArray[indexPath.row];
    } else if (indexPath.section == 1) {
        NSArray *bArray = [[beforeComeArray reverseObjectEnumerator] allObjects];
        model           = bArray[indexPath.row];
    }
    WhoComeTableViewCell *cell = [WhoComeTableViewCell cellWithTableView:tableView andIndexPath:indexPath];
    cell.selectionStyle        = UITableViewCellSelectionStyleNone;
    [cell fillDataWithModel:model];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LYDetailDataViewController *detail = [[LYDetailDataViewController alloc] init];
    if (indexPath.section == 0) {
        NSArray *n    = [[nearArray reverseObjectEnumerator] allObjects];
        model         = n[indexPath.row];
        detail.userId = model.userId;
    } else if (indexPath.section == 1) {
        NSArray *b    = [[beforeComeArray reverseObjectEnumerator] allObjects];
        model         = b[indexPath.row];
        detail.userId = model.userId;
    }
    [self.navigationController pushViewController:detail animated:YES];
}

@end
