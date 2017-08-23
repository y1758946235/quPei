//
//  RequirementManagerViewController.m
//  LvYue
//
//  Created by 郑洲 on 16/4/8.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "RequirementManagerViewController.h"
#import "RequirementDetailViewController.h"
#import "RequirementManegerCell.h"
#import "RequirementModel.h"
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "MBProgressHUD+NJ.h"

@interface RequirementManagerViewController ()<UITableViewDelegate, UITableViewDataSource>{
    UITableView *_tableView;
    NSMutableArray *dataArray;
}

@end

@implementation RequirementManagerViewController

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"需求管理";
    self.view.backgroundColor = RGBCOLOR(243, 244, 245);
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
    [_tableView registerClass:[RequirementManegerCell class] forCellReuseIdentifier:@"managerCell"];
    
    [self getData];
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    if ([[user objectForKey:kHaveInvite] isEqualToString:@"1"]) {
        [user setObject:@"0" forKey:kHaveInvite];
        [user synchronize];
        //发送关闭好友列表的提醒器的通知
        [[NSNotificationCenter defaultCenter] postNotificationName:@"closeOrShowCheckRequireListVcPushPrompt" object:nil];
    }
    //更新会话中的UI
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LY_ReloadSystemMessage" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getData) name:@"refreshRequirementList" object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)getData {
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/need/myNeedList",REQUESTHEADER] andParameter:@{@"user_id":[LYUserService sharedInstance].userID} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            dataArray = [NSMutableArray array];
            for (NSDictionary *dic in successResponse[@"data"][@"data"]) {
                RequirementModel *model = [[RequirementModel alloc] initWithDict:dic[@"needInfo"]];
                model.smallName = dic[@"smallName"];
                model.fUsers = dic[@"fUsers"];
                [dataArray addObject:model];
            }
            dataArray = (NSMutableArray *)[[dataArray reverseObjectEnumerator] allObjects];
            [_tableView reloadData];
        } else {
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"managerCell";
    RequirementManegerCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[RequirementManegerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    RequirementModel *model = dataArray[indexPath.section];
    [cell createWithModel:model];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    RequirementModel *model = dataArray[indexPath.section];
    if (model.fUsers.count == 0) {
        return 105;
    }
    return 170;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RequirementModel *model = dataArray[indexPath.section];
    RequirementDetailViewController *sdVC = [[RequirementDetailViewController alloc] init];
    sdVC.needId = model.needId;
    sdVC.isMyself = YES;
    sdVC.needName = model.smallName;
    [self.navigationController pushViewController:sdVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
