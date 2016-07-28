//
//  SkillDetailViewController.m
//  LvYue
//
//  Created by 郑洲 on 16/4/7.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "SkillDetailViewController.h"
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "MBProgressHUD+NJ.h"
#import "DetailDataViewController.h"

@interface SkillDetailViewController ()<UITableViewDelegate, UITableViewDataSource> {
    NSArray *detailArray;
    NSMutableArray *dataArray;
    
    NSString *imageName;
    
    UITableView *_tableView;
}

@end

@implementation SkillDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"技能详情";
    self.view.backgroundColor = RGBACOLOR(243, 244, 245, 1);
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    UIButton *deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
    [deleteBtn setImage:[UIImage imageNamed:@"删除"] forState:UIControlStateNormal];
    [deleteBtn addTarget:self action:@selector(deleteSkill) forControlEvents:UIControlEventTouchUpInside];
    if ([LYUserService sharedInstance].userID == self.skillUserId) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:deleteBtn];
    }
    
    detailArray = @[
//                    @"线上服务",@"线下服务",
                    @"活动地址",@"活动时间",@"特长介绍",@"专业优势",@"学      历"];
    
    [self getData];
}

- (void)getData {
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/need/skillDetail",REQUESTHEADER] andParameter:@{@"skill_id":self.skillId} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            imageName = successResponse[@"data"][@"data"][@"bigName"];
            dataArray = [NSMutableArray array];
            [dataArray addObject:successResponse[@"data"][@"data"][@"skill"][@"name"]];
//            if (![successResponse[@"data"][@"data"][@"skill"][@"onlinePrice"] isKindOfClass:[NSNull class]]) {
//                [dataArray addObject:[NSString stringWithFormat:@"%@元/分钟",successResponse[@"data"][@"data"][@"skill"][@"onlinePrice"]]];
//            }else {
//                [dataArray addObject:@""];
//            }
//            if (![successResponse[@"data"][@"data"][@"skill"][@"price"] isKindOfClass:[NSNull class]]) {
//                [dataArray addObject:[NSString stringWithFormat:@"%@元/小时",successResponse[@"data"][@"data"][@"skill"][@"price"]]];
//            }else {
//                [dataArray addObject:@""];
//            }
            [dataArray addObject:successResponse[@"data"][@"data"][@"skill"][@"address"]];
            [dataArray addObject:successResponse[@"data"][@"data"][@"skill"][@"time"]];
            [dataArray addObject:successResponse[@"data"][@"data"][@"skill"][@"detail"]];
            [dataArray addObject:successResponse[@"data"][@"data"][@"skill"][@"advantage"]];
            [dataArray addObject:successResponse[@"data"][@"data"][@"skill"][@"edu"]];
            
            _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64)];
            _tableView.delegate = self;
            _tableView.dataSource = self;
            _tableView.backgroundColor = [UIColor clearColor];
            _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            [self.view addSubview:_tableView];
        } else {
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
}

- (void)deleteSkill {
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/need/delSkill",REQUESTHEADER] andParameter:@{@"skill_id":self.skillId} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]]
             isEqualToString:@"200"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshSkillList" object:nil];
            [self.navigationController popViewControllerAnimated:YES];
             } else {
                 [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
             }
        } andFailure:^(id failureResponse) {
             [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        static NSString *cellId = @"typeCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 60) / 2, 15, 60, 60)];
            imageView.image = [UIImage imageNamed:imageName];
            [cell addSubview:imageView];
            
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 60) / 2, 15, 60, 60)];
            button.backgroundColor = [UIColor clearColor];
            [button addTarget:self action:@selector(turnToDetail) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:button];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 77, SCREEN_WIDTH, 20)];
            label.text = dataArray[indexPath.row];
            label.font = [UIFont systemFontOfSize:14];
            label.textAlignment = NSTextAlignmentCenter;
            [cell addSubview:label];
            
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(10, 109, SCREEN_WIDTH - 20, 1)];
            line.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
            [cell addSubview:line];
        }
        cell.backgroundColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else {
        static NSString *cellId = @"detailCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
            
            UILabel *noteLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, 100, 20)];
            noteLabel.text = detailArray[indexPath.row - 1];
            noteLabel.font = [UIFont systemFontOfSize:17];
            [cell addSubview:noteLabel];
            
            UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 5, SCREEN_WIDTH - 120, 40)];
            detailLabel.text = dataArray[indexPath.row];
            detailLabel.font = [UIFont systemFontOfSize:16];
            detailLabel.textColor = [UIColor grayColor];
            detailLabel.numberOfLines = 0;
            [cell addSubview:detailLabel];
            
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(10, 49, SCREEN_WIDTH - 20, 1)];
            line.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
            [cell addSubview:line];
        }
        cell.backgroundColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 110;
    }
    return 50;
}

- (void)turnToDetail {
    DetailDataViewController *deta = [[DetailDataViewController alloc] init];
    deta.friendId = [_skillUserId integerValue];
    [self.navigationController pushViewController:deta animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
