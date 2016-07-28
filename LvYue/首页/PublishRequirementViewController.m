//
//  PublishRequirementViewController.m
//  LvYue
//
//  Created by 郑洲 on 16/4/6.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "PublishRequirementViewController.h"
#import "RequirementTableViewCell.h"
#import "PublishDetailRequirementViewController.h"
#import "SkillListViewController.h"
#import "RequirementManagerViewController.h"
#import "PublishDetailSkillViewController.h"
#import "LYHttpPoster.h"
#import "MBProgressHUD+NJ.h"
#import "LYUserService.h"

@interface PublishRequirementViewController ()<UITableViewDelegate, UITableViewDataSource> {
    NSArray *typeArray;
    NSArray *imageArray;
    NSMutableArray *dataArray;

    UITableView *_tableView;
}

@end

@implementation PublishRequirementViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (_isPushSkill) {
        self.title = @"发布技能";
    }else {
        self.title = @"发布需求";
    }
    
    UIButton *requirementManagerBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
    [requirementManagerBtn setImage:[UIImage imageNamed:@"需求管理"] forState:UIControlStateNormal];
    [requirementManagerBtn addTarget:self action:@selector(turnToManager) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:requirementManagerBtn];
    
    typeArray = @[@"休闲娱乐",@"运动健康",@"咨询服务",@"技术服务",@"文房墨玩",@"丽人时尚",@"手工艺品"];
    imageArray = @[@"娱乐",@"运动",@"咨询",@"技术",@"文玩",@"时尚",@"手工"];

    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
    [_tableView registerClass:[RequirementTableViewCell class] forCellReuseIdentifier:@"tableCell"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(turnToDetail:) name:@"turnToDetail" object:nil];
    
    [self getData];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)getData {
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/need/skillTypeList",REQUESTHEADER] andParameter:@{} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            dataArray = [NSMutableArray array];
            NSDictionary *dic = successResponse[@"data"][@"data"];
            for (int i = 1; i <= [dic allValues].count; i++) {
                NSArray *arr = [dic valueForKey:[NSString stringWithFormat:@"type_%d",i]];
                [dataArray addObject:arr];
            }

            [_tableView reloadData];
        } else {
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
}

- (void)turnToManager {
    if (_isPushSkill) {
        SkillListViewController *pdrVC = [[SkillListViewController alloc] init];
        pdrVC.userId = [LYUserService sharedInstance].userID;
        [self.navigationController pushViewController:pdrVC animated:YES];
    }else {
        RequirementManagerViewController *sdVC = [[RequirementManagerViewController alloc] init];
        [self.navigationController pushViewController:sdVC animated:YES];
    }
}

- (void)turnToDetail:(NSNotification*)notification {
    if (_isPushSkill) {
        PublishDetailSkillViewController *pdrVC = [[PublishDetailSkillViewController alloc] init];
        pdrVC.skillName = [[notification userInfo] objectForKey:@"type"];
        pdrVC.num = [[[notification userInfo] objectForKey:@"number"] integerValue];
        [self.navigationController pushViewController:pdrVC animated:YES];
    }else {
        if (_isFromDetail) {
            NSArray *array = [_skills componentsSeparatedByString:@","];
            int i = array.count;
            for (NSString *skill in array) {
                if ([[[notification userInfo] objectForKey:@"type"] isEqualToString:skill]) {
                    PublishDetailRequirementViewController *sdVC = [[PublishDetailRequirementViewController alloc] init];
                    sdVC.num = [[[notification userInfo] objectForKey:@"number"] integerValue];
                    [self.navigationController pushViewController:sdVC animated:YES];
                    break;
                }else {
                    i--;
                }
            }
            if (i == 0) {
                [MBProgressHUD showError:@"该人无此技能"];
            }
        }else {
            PublishDetailRequirementViewController *sdVC = [[PublishDetailRequirementViewController alloc] init];
            sdVC.num = [[[notification userInfo] objectForKey:@"number"] integerValue];
            [self.navigationController pushViewController:sdVC animated:YES];
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return dataArray.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
    headView.backgroundColor = [UIColor whiteColor];
    
    UILabel *noteLabel = [[UILabel alloc] initWithFrame:CGRectMake(38, 10, 200, 20)];
    noteLabel.text = typeArray[section];
    noteLabel.font = [UIFont systemFontOfSize:14];
    [headView addSubview:noteLabel];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 12, 16, 16)];
    imageView.image = [UIImage imageNamed:imageArray[section]];
    [headView addSubview:imageView];
    
    return headView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RequirementTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tableCell" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[RequirementTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableCell"];
    }
    if (dataArray) {
        [cell createWithData:dataArray[indexPath.section]];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 35;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (dataArray) {
        NSArray *array = dataArray[indexPath.section];
        return (array.count / 4 + (array.count % 4 == 0 ? 0 : 1)) * 35;
    }
    return 0.01;
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
