//
//  SkillListViewController.m
//  LvYue
//
//  Created by 郑洲 on 16/4/9.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "SkillListViewController.h"
#import "LYHttpPoster.h"
#import "MBProgressHUD+NJ.h"
#import "SkillTableViewCell.h"
#import "SkillDetailViewController.h"
#import "SkillModel.h"
#import "LYUserService.h"

@interface SkillListViewController ()<UITableViewDelegate, UITableViewDataSource>{
    UITableView *_tableView;
    NSMutableArray *dataArray;
}

@end

@implementation SkillListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"技能列表";
    self.view.backgroundColor = RGBACOLOR(243, 244, 245, 1);
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_tableView];
    
    [_tableView registerClass:[SkillTableViewCell class] forCellReuseIdentifier:@"SkillCell"];
    
    [self getData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getData) name:@"refreshSkillList" object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)getData {
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/need/mySkillList",REQUESTHEADER] andParameter:@{@"user_id":_userId} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            dataArray = [NSMutableArray array];
            NSArray *array = successResponse[@"data"][@"mySkills"];
            for (NSDictionary *dic in array) {
                SkillModel *model = [[SkillModel alloc] initWithDict:dic];
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
    static NSString *cellId = @"SkillCell";
    SkillTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[SkillTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor whiteColor];
    
    SkillModel *model = dataArray[indexPath.row];
    [cell createWithModel:model];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    SkillModel *model = dataArray[indexPath.row];
    NSString *string = model.skillDetail;
    CGRect rect = [string boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 60, 20) options:NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil];
    
    return 95 + rect.size.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SkillModel *model = dataArray[indexPath.row];
    SkillDetailViewController *sdVC = [[SkillDetailViewController alloc] init];
    sdVC.skillId = model.skillId;
    sdVC.skillUserId = _userId;
    [self.navigationController pushViewController:sdVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
