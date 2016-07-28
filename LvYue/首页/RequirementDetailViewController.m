//
//  RequirementDetailViewController.m
//  LvYue
//
//  Created by 郑洲 on 16/4/7.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "RequirementDetailViewController.h"
#import "InvitedPeopleTableViewCell.h"
#import "RequirementDetailTopCell.h"
#import "LYUserService.h"
#import "LYHttpPoster.h"
#import "MBProgressHUD+NJ.h"
#import "LYUserService.h"
#import "PeopleModel.h"
#import "ChatViewController.h"
#import "RequirementPayViewController.h"
#import "DetailDataViewController.h"
#import "UIImageView+WebCache.h"

@interface RequirementDetailViewController ()<UITableViewDelegate, UITableViewDataSource> {
    NSDictionary *dataDic;
    NSString *imageName;
    NSString *userId;
    UITableView *_tableView;
    NSMutableArray *peopleArray;
    NSString *headImage;
}

@end

@implementation RequirementDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"需求详情";
    
    UIButton *deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
    [deleteBtn setImage:[UIImage imageNamed:@"删除"] forState:UIControlStateNormal];
    [deleteBtn addTarget:self action:@selector(delete) forControlEvents:UIControlEventTouchUpInside];
    UIButton *inviteBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 20)];
    [inviteBtn addTarget:self action:@selector(match) forControlEvents:UIControlEventTouchUpInside];
    [inviteBtn setTitle:@"应邀" forState:UIControlStateNormal];
    
    if (!_isMyself) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:inviteBtn];
    }else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:deleteBtn];
    }
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor  = RGBCOLOR(243, 244, 245);
    [self.view addSubview:_tableView];
    
    [_tableView registerClass:[InvitedPeopleTableViewCell class] forCellReuseIdentifier:@"invitedCell"];
    [_tableView registerClass:[RequirementDetailTopCell class] forCellReuseIdentifier:@"topCell"];
    
    [self getData];
}

- (void)getData {
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/need/needDetail",REQUESTHEADER] andParameter:@{@"need_id":self.needId} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            peopleArray = [NSMutableArray array];
            for (NSDictionary *dic in successResponse[@"data"][@"data"][@"fUsers"]) {
                PeopleModel *model = [[PeopleModel alloc] initWithDict:dic];
                [peopleArray addObject:model];
            }
            headImage = successResponse[@"data"][@"data"][@"user"][@"icon"];
            dataDic = successResponse[@"data"][@"data"][@"need"];
            imageName = successResponse[@"data"][@"data"][@"bigName"];
            userId = [NSString stringWithFormat:@"%@",successResponse[@"data"][@"data"][@"user"][@"id"]];
            [_tableView reloadData];
        } else {
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
}

- (void)match {
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    if ([[userDefaults objectForKey:@"alipay_Id"] isEqualToString:@""] && [[userDefaults objectForKey:@"weixin_Id"] isEqualToString:@""]) {
//        [MBProgressHUD showError:@"请到资料认证处先完善收款账号信息"];
//        return;
//    }

    RequirementDetailTopCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if ([cell.nlabel.text isEqualToString:@"已过期"]) {
        [MBProgressHUD showError:@"需求已过期" toView:self.view];
        return;
    }
    if ([userId isEqualToString:[LYUserService sharedInstance].userID]) {
        [MBProgressHUD showError:@"不能应邀自己的需求" toView:self.view];
        return;
    }
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/need/canMatch2",REQUESTHEADER] andParameter:@{@"need_id":self.needId,@"user_id":[LYUserService sharedInstance].userID,@"publishId":userId} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            [MBProgressHUD showSuccess:@"应邀成功" toView:self.view];
            [self getData];
        } else {
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];

}

- (void)delete {
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/need/delNeed",REQUESTHEADER] andParameter:@{@"need_id":self.needId} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshRequirementList" object:nil];
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1 + peopleArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 0) {
        UILabel *noteLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 45)];
        noteLabel.text = [NSString stringWithFormat:@"———— 已有%lu位伙伴应邀 ————",(unsigned long)peopleArray.count];
        noteLabel.textAlignment = NSTextAlignmentCenter;
        noteLabel.textColor = [UIColor darkGrayColor];
        noteLabel.font = [UIFont systemFontOfSize:15];
        noteLabel.backgroundColor = [UIColor clearColor];
        return noteLabel;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return 45;
    }
    return 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        static NSString *cellId = @"topCell";
        RequirementDetailTopCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (cell == nil) {
            cell = [[RequirementDetailTopCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.nameLabel.text = _needName;
        cell.imageName = imageName;
        cell.imageBtn.tag = 101;
        [cell.headImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,headImage]] placeholderImage:nil options:SDWebImageRetryFailed];
        [cell.imageBtn addTarget:self action:@selector(turnToDetail:) forControlEvents:UIControlEventTouchUpInside];
        [cell createWithDic:dataDic];
        return cell;
    }else {
        static NSString *cellId = @"invitedCell";
        InvitedPeopleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (cell == nil) {
            cell = [[InvitedPeopleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        }
        cell.isMyself = _isMyself;
        cell.peopleBtn.tag = indexPath.section - 1;
        [cell.peopleBtn addTarget:self action:@selector(turnToDetail:) forControlEvents:UIControlEventTouchUpInside];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        PeopleModel *model = peopleArray[indexPath.section - 1];
        [cell createWithModel:model];
        
        UIButton *chatBtn = cell.btnArr[0];
        chatBtn.tag = indexPath.section - 1;
        [chatBtn addTarget:self action:@selector(chatMessage:) forControlEvents:UIControlEventTouchUpInside];
        
//        UIButton *payBtn = cell.btnArr[1];
//        payBtn.tag = indexPath.section - 1;
//        [payBtn addTarget:self action:@selector(payRequirement:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 430;
    }
    if (!_isMyself) {
        return 215;
    }
    return 255;
}

- (void)chatMessage:(UIButton *)button {
    PeopleModel *model = peopleArray[button.tag];
    ChatViewController *chatVc = [[ChatViewController alloc] initWithChatter:[NSString stringWithFormat:@"%@",model.peopleId] isGroup:NO];
    chatVc.title = model.peopleName;
    [self.navigationController pushViewController:chatVc animated:YES];
}

- (void)payRequirement:(UIButton *)button {
    PeopleModel *model = peopleArray[button.tag];
    RequirementPayViewController *payVC = [[RequirementPayViewController alloc] init];
    payVC.sellId = model.peopleId;
    payVC.alipayId = model.alipayId;
    payVC.weixinId = model.weixinId;
    [self.navigationController pushViewController:payVC animated:YES];
}

- (void)turnToDetail:(UIButton *)btn {
    
    DetailDataViewController *deta = [[DetailDataViewController alloc] init];
    if (btn.tag == 101) {
        deta.friendId = [userId integerValue];
    }else {
        PeopleModel *model = peopleArray[btn.tag];
        deta.friendId = [model.peopleId integerValue];
    }
    [self.navigationController pushViewController:deta animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
