//
//  SkillManagerViewController.m
//  LvYue
//
//  Created by 郑洲 on 16/4/22.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "SkillManagerViewController.h"
#import "SkillTableViewCell.h"
#import "SkillDetailViewController.h"
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "MBProgressHUD+NJ.h"
#import "RequirementListCell.h"
#import "RequirementDetailViewController.h"

@interface SkillManagerViewController ()<UITableViewDelegate, UITableViewDataSource>{
    UIView *_hoLine;
    NSMutableArray *dataArray;
    NSMutableArray *dataArray2;
}

@property (nonatomic, strong) UITableView *mySkillTable;
@property (nonatomic, strong) UITableView *matchTable;

@end

@implementation SkillManagerViewController

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
    [super viewWillAppear:animated];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"技能管理";
    self.view.backgroundColor = RGBCOLOR(243, 244, 245);
    
    UIButton *mySkillBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2, 74, SCREEN_WIDTH / 2, 40)];
    [mySkillBtn setTitle:@"我的技能" forState:UIControlStateNormal];
    [mySkillBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    mySkillBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    mySkillBtn.backgroundColor = [UIColor whiteColor];
    mySkillBtn.tag = 101;
    [mySkillBtn addTarget:self action:@selector(moveLine:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:mySkillBtn];
    
    UIButton *matchRequirementBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 74, SCREEN_WIDTH / 2, 40)];
    [matchRequirementBtn setTitle:@"匹配需求" forState:UIControlStateNormal];
    [matchRequirementBtn setTitleColor:RGBCOLOR(29, 189, 159) forState:UIControlStateNormal];
    matchRequirementBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    matchRequirementBtn.backgroundColor = [UIColor whiteColor];
    matchRequirementBtn.tag = 102;
    [matchRequirementBtn addTarget:self action:@selector(moveLine:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:matchRequirementBtn];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 0.5, 79, 1, 30)];
    line.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    [self.view addSubview:line];
    
    for (int i = 0; i < 2; i++) {
        UIView *hLine = [[UIView alloc] initWithFrame:CGRectMake(0, 74 + i * 40, SCREEN_WIDTH, 1)];
        hLine.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
        [self.view addSubview:hLine];
    }
    
    _hoLine = [[UIView alloc] initWithFrame:CGRectMake(20, 113, SCREEN_WIDTH / 2 - 40, 2)];
    _hoLine.backgroundColor = RGBCOLOR(29, 189, 159);
    [self.view addSubview:_hoLine];
    
    _mySkillTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 124, SCREEN_WIDTH, SCREEN_HEIGHT - 124)];
    _mySkillTable.delegate = self;
    _mySkillTable.dataSource = self;
    _mySkillTable.hidden = YES;
    _mySkillTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    _mySkillTable.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_mySkillTable];
    
    [_mySkillTable registerClass:[SkillTableViewCell class] forCellReuseIdentifier:@"SkillCell"];
    
    [self getData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getData) name:@"refreshSkillList" object:nil];
    
    _matchTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 124, SCREEN_WIDTH, SCREEN_HEIGHT - 124)];
    _matchTable.delegate = self;
    _matchTable.dataSource = self;
    _matchTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    _matchTable.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_matchTable];
    
    [_matchTable registerClass:[RequirementListCell class] forCellReuseIdentifier:@"RequirementCell"];
    
    [self getData1];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getData) name:@"refreshRequirementList" object:nil];
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    if ([[user objectForKey:kHaveRequire] isEqualToString:@"1"]) {
        [user setObject:@"0" forKey:kHaveRequire];
        [user synchronize];
        //发送关闭好友列表的提醒器的通知
        [[NSNotificationCenter defaultCenter] postNotificationName:@"closeOrShowCheckSkillListVcPushPrompt" object:nil];
    }
    //更新会话中的UI
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LY_ReloadSystemMessage" object:nil];
}

- (void)getData {
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/need/mySkillList",REQUESTHEADER] andParameter:@{@"user_id":[LYUserService sharedInstance].userID} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            dataArray = [NSMutableArray array];
            NSArray *array = successResponse[@"data"][@"mySkills"];
            for (NSDictionary *dic in array) {
                SkillModel *model = [[SkillModel alloc] initWithDict:dic];
                [dataArray addObject:model];
            }
            [_mySkillTable reloadData];
        } else {
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)getData1 {
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/need/matches",REQUESTHEADER] andParameter:@{@"user_id":[LYUserService sharedInstance].userID} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            dataArray2 = [NSMutableArray array];
            NSArray *array = successResponse[@"data"][@"data"];
            for (NSDictionary *dic in array) {
                RequirementModel *model = [[RequirementModel alloc] initWithDict:dic[@"need"]];
                model.requirementName = dic[@"name"];
                model.userAge = dic[@"age"];
                model.userSex = dic[@"sex"];
                model.userIcon = dic[@"icon"];
                model.userName = dic[@"userName"];
                [dataArray2 addObject:model];
            }
            [_matchTable reloadData];
        } else {
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
}

- (void)moveLine:(UIButton *)btn {
    if (btn.tag == 101) {
        [btn setTitleColor:RGBCOLOR(29, 189, 159) forState:UIControlStateNormal];
        UIButton *button = [self.view viewWithTag:102];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [UIView animateWithDuration:0.3 animations:^{
             _hoLine.frame = CGRectMake(20 + SCREEN_WIDTH / 2, 113, SCREEN_WIDTH / 2 - 40, 2);
        }];
        
        _mySkillTable.hidden = NO;
        _matchTable.hidden = YES;
    }else {
        [btn setTitleColor:RGBCOLOR(29, 189, 159) forState:UIControlStateNormal];
        UIButton *button = [self.view viewWithTag:101];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [UIView animateWithDuration:0.3 animations:^{
            _hoLine.frame = CGRectMake(20, 113, SCREEN_WIDTH / 2 - 40, 2);
        }];
        if (!dataArray2) {
            [self getData1];
        }
        _mySkillTable.hidden = YES;
        _matchTable.hidden = NO;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == _mySkillTable) {
        return dataArray.count;
    }
    return dataArray2.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _mySkillTable) {
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
    
    static NSString *cellId = @"RequirementCell";
    RequirementListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[RequirementListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    RequirementModel *model = dataArray2[indexPath.row];
    [cell createWithModel:model];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _mySkillTable) {
        SkillModel *model = dataArray[indexPath.row];
        NSString *string = model.skillDetail;
        CGRect rect = [string boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 60, 20) options:NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil];
        
        return 95 + rect.size.height;
    }
    
    RequirementModel *model = dataArray2[indexPath.row];
    NSString *string = model.requirementDetail;
    CGRect rect = [string boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 60, 20) options:NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil];
    
    return 130 + rect.size.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _mySkillTable) {
        SkillModel *model = dataArray[indexPath.row];
        SkillDetailViewController *sdVC = [[SkillDetailViewController alloc] init];
        sdVC.skillId = model.skillId;
        sdVC.skillUserId = [LYUserService sharedInstance].userID;
        [self.navigationController pushViewController:sdVC animated:YES];
    }else {
        RequirementModel *model = dataArray2[indexPath.row];
        RequirementDetailViewController *rdVC = [[RequirementDetailViewController alloc] init];
        rdVC.needId = model.needId;
        rdVC.needName = model.requirementName;
        [self.navigationController pushViewController:rdVC animated:YES];
    }
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
