//
//  RequirementListViewController.m
//  LvYue
//
//  Created by 郑洲 on 16/4/11.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "RequirementListViewController.h"
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "MBProgressHUD+NJ.h"
#import "RequirementListCell.h"
#import "RequirementDetailViewController.h"
#import "RequirementModel.h"

@interface RequirementListViewController ()<UITableViewDelegate, UITableViewDataSource>{
    UITableView *_tableView;
    NSMutableArray *dataArray;
}


@end

@implementation RequirementListViewController

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"需求列表";
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    [_tableView registerClass:[RequirementListCell class] forCellReuseIdentifier:@"RequirementCell"];
    
    [self getData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getData) name:@"refreshRequirementList" object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)getData {
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/need/matches",REQUESTHEADER] andParameter:@{@"user_id":[LYUserService sharedInstance].userID} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            dataArray = [NSMutableArray array];
            NSArray *array = successResponse[@"data"][@"data"];
            for (NSDictionary *dic in array) {
                RequirementModel *model = [[RequirementModel alloc] initWithDict:dic[@"need"]];
                model.requirementName = dic[@"name"];
                [dataArray addObject:model];
            }
            [_tableView reloadData];
        } else {
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"RequirementCell";
    RequirementListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[RequirementListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    RequirementModel *model = dataArray[indexPath.row];
    [cell createWithModel:model];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    RequirementModel *model = dataArray[indexPath.row];
    NSString *string = model.requirementDetail;
    CGRect rect = [string boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 60, 20) options:NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil];
    
    return 130 + rect.size.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RequirementModel *model = dataArray[indexPath.row];
    RequirementDetailViewController *rdVC = [[RequirementDetailViewController alloc] init];
    rdVC.needId = model.needId;
    rdVC.needName = model.requirementName;
    [self.navigationController pushViewController:rdVC animated:YES];
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
