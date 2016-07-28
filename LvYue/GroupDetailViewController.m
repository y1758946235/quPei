//
//  GroupDetailViewController.m
//  LvYue
//
//  Created by apple on 15/10/19.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import "GroupDetailViewController.h"
#import "DetailDataViewController.h"
#import "GroupMemberView.h"
#import "UIView+RSAdditions.h"
#import "MemberButton.h"
#import "LYUserService.h"
#import "LYHttpPoster.h"
#import "MBProgressHUD+NJ.h"
#import "GroupMemberModel.h"
#import "AFNetworking.h"
#import "ModifyGroupDetailController.h"
#import "AddGroupMemberViewController.h"
#import "RemoveGroupMemberViewController.h"

@interface GroupDetailViewController ()<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate> {
    BOOL _isHolder; //是否是群主
    BOOL _isFull; //该群是否满员
    NSString *_easemob_id; //群组环信id
    NSString *_groupName; //群组名称
    NSString *_groupDesc; //群组描述
    NSString *_currentCount; //当前群组成员数
    NSString *_maxCount; //群组最大成员数
}

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) GroupMemberView *memberView; //群成员View

@property (nonatomic, strong) NSMutableArray *modelArray; //群成员模型数组

@property (nonatomic, strong) UISwitch *messageSwitch; //消息免打扰开关

@property (nonatomic, strong) UIButton *revokeBtn; //解散/退出按钮

@end

@implementation GroupDetailViewController


#pragma mark - lazy
- (GroupMemberView *)memberView {
    if (!_memberView) {
        _memberView = [[GroupMemberView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) memberModelArray:_modelArray isHolder:_isHolder isFull:_isFull];
    }
    return _memberView;
}


#pragma mark - circle
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = @"群信息";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //初始化
    _modelArray = [NSMutableArray array];
    _groupName = @"";
    _groupDesc = @"";
    _currentCount = @"";
    _maxCount = @"";
    
    [self rigisiterAllNotifications];
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    _tableView.backgroundColor = RGBACOLOR(250, 250, 250, 1.0);
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 120)];
    footView.backgroundColor = RGBACOLOR(250, 250, 250, 1.0);
    UIButton *revokeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    revokeBtn.frame = CGRectMake(20, 38, kMainScreenWidth - 40, 44);
    revokeBtn.layer.cornerRadius = 5.0;
    revokeBtn.clipsToBounds = YES;
    revokeBtn.backgroundColor = RGBACOLOR(29, 189, 159, 1.0);
    [revokeBtn setTitle:@"退出该群" forState:UIControlStateNormal];
    revokeBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    revokeBtn.titleLabel.font = kFont18;
    [revokeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [revokeBtn addTarget:self action:@selector(quitGroup:) forControlEvents:UIControlEventTouchUpInside];
    _revokeBtn = revokeBtn;
    [footView addSubview:revokeBtn];
    _tableView.tableFooterView = footView;
    
    [self.view addSubview:_tableView];
    
    //    [self getGroupMembersInfo];
    [self getGroupDetailInfo];
}


//获得群组成员
- (void)getGroupMembersInfo {
    
    [MBProgressHUD showMessage:@"获取群成员中.."];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/group/getMembers",REQUESTHEADER] andParameter:@{@"group_id":_groupID} success:^(id successResponse) {
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            [MBProgressHUD hideHUD];
            MLOG(@"%@",successResponse);
            NSArray *array = successResponse[@"data"][@"list"];
            for (NSDictionary *dict in array) {
                GroupMemberModel *model = [[GroupMemberModel alloc] initWithDict:dict];
                [_modelArray addObject:model];
            }
            [_tableView reloadData];
        } else {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
}

//获得群组信息
- (void)getGroupDetailInfo {
    
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/group/getInfo",REQUESTHEADER] andParameter:@{@"group_id":_groupID} success:^(id successResponse) {
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            MLOG(@"%@",successResponse);
            NSDictionary *info = successResponse[@"data"][@"group"];
            NSDictionary *userInfo = successResponse[@"data"][@"user"];
            NSString *icon = [NSString stringWithFormat:@"%@%@",IMAGEHEADER,info[@"icon"]];
            _easemob_id = [NSString stringWithFormat:@"%@",info[@"easemob_id"]];
            _groupName = [NSString stringWithFormat:@"%@",info[@"name"]];
            _groupDesc = [NSString stringWithFormat:@"%@",info[@"desc"]];
            _currentCount = [NSString stringWithFormat:@"%@",info[@"member_count"]];
            _maxCount = [NSString stringWithFormat:@"%@",info[@"max_users"]];
            _isFull = ([_maxCount integerValue] > [_currentCount integerValue]?NO:YES);
            _isHolder = ([[NSString stringWithFormat:@"%@",userInfo[@"id"]] isEqualToString:[LYUserService sharedInstance].userID]?YES:NO);
            if (_isHolder) {
                [_revokeBtn setTitle:@"解散该群" forState:UIControlStateNormal];
            } else {
                [_revokeBtn setTitle:@"退出该群" forState:UIControlStateNormal];
            }
            [self getGroupMembersInfo];
            
            [kAppDelegate.dataBaseQueue inDatabase:^(FMDatabase *db) {
                //矫正本地数据库
                //如果数据库打开成功
                if ([kAppDelegate.dataBase open]) {
                    //如果群组模型在本地数据库表中没有，则插入，否则更新
                    NSString *findSql = [NSString stringWithFormat:@"SELECT * FROM '%@' WHERE easemob_id = '%@'",@"Group",_easemob_id];
                    FMResultSet *result = [kAppDelegate.dataBase executeQuery:findSql];
                    if ([result resultCount]) { //如果查询结果有数据
                        //更新对应数据
                        NSString *updateSql = [NSString stringWithFormat:@"UPDATE '%@' SET groupID = '%@',name = '%@',desc = '%@',icon = '%@' WHERE easemob_id = '%@'",@"Group",_groupID,_groupName,_groupDesc,icon,_easemob_id];
                        BOOL isSuccess = [kAppDelegate.dataBase executeUpdate:updateSql];
                        if (isSuccess) {
                            MLOG(@"更新数据成功!");
                        } else {
                            MLOG(@"更新数据失败!");
                        }
                    } else { //如果查询结果没有数据
                        //插入相应数据
                        NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO '%@'('%@','%@','%@','%@','%@') VALUES('%@','%@','%@','%@','%@')",@"Group",@"groupID",@"easemob_id",@"name",@"desc",@"icon",_groupID,_easemob_id,_groupName,_groupDesc,icon];
                        BOOL isSuccess = [kAppDelegate.dataBase executeUpdate:insertSql];
                        if (isSuccess) {
                            MLOG(@"插入数据成功!");
                        } else {
                            MLOG(@"插入数据失败!");
                        }
                    }
                    [kAppDelegate.dataBase close];
                }
            }];
        } else {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
}

//注册通知
- (void)rigisiterAllNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushToGroupMemberDetailViewController:) name:@"clickToGroupMemberDetail" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadGroupDetail:) name:@"reloadGroupDetail" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addGroupMembers:) name:@"addGroupMembers" object:nil];
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        if (_isHolder) {
            return 4;
        } else {
            return 3;
        }
    } else {
        return 2;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.backgroundColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.section == 0) {
        if (_modelArray.count) {
            [cell addSubview:self.memberView];
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 100, 50)];
            titleLabel.textAlignment = NSTextAlignmentLeft;
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.font = kFont17;
            titleLabel.textColor = [UIColor grayColor];
            titleLabel.text = @"当前成员数";
            [cell addSubview:titleLabel];
            UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabel.right + 5, 0, kMainScreenWidth - titleLabel.right - 20, 50)];
            contentLabel.textAlignment = NSTextAlignmentLeft;
            contentLabel.backgroundColor = [UIColor clearColor];
            contentLabel.font = kFont17;
            contentLabel.textColor = [UIColor blackColor];
            if (![_currentCount isEqualToString:@""] && ![_maxCount isEqualToString:@""]) {
                contentLabel.text = [NSString stringWithFormat:@"%@ / %@",_currentCount,_maxCount];
            } else {
                contentLabel.text = @"";
            }
            [cell addSubview:contentLabel];
        } else if (indexPath.row == 1) {
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 100, 50)];
            titleLabel.textAlignment = NSTextAlignmentLeft;
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.font = kFont17;
            titleLabel.textColor = [UIColor grayColor];
            titleLabel.text = @"群主题";
            [cell addSubview:titleLabel];
            UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabel.right, 0, kMainScreenWidth - titleLabel.right - 40, 50)];
            contentLabel.textAlignment = NSTextAlignmentLeft;
            contentLabel.backgroundColor = [UIColor clearColor];
            contentLabel.font = kFont17;
            contentLabel.textColor = [UIColor blackColor];
            contentLabel.text = _groupName;
            [cell addSubview:contentLabel];
            if (_isHolder) {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
        } else if (indexPath.row == 2) {
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 100, 50)];
            titleLabel.textAlignment = NSTextAlignmentLeft;
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.font = kFont17;
            titleLabel.textColor = [UIColor grayColor];
            titleLabel.text = @"群描述";
            [cell addSubview:titleLabel];
            UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabel.right, 0, kMainScreenWidth - titleLabel.right - 40, 50)];
            contentLabel.textAlignment = NSTextAlignmentLeft;
            contentLabel.backgroundColor = [UIColor clearColor];
            contentLabel.font = kFont17;
            contentLabel.textColor = [UIColor blackColor];
            contentLabel.text = _groupDesc;
            [cell addSubview:contentLabel];
            if (_isHolder) {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
        } else if (indexPath.row == 3) {
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 100, 50)];
            titleLabel.textAlignment = NSTextAlignmentLeft;
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.font = kFont17;
            titleLabel.textColor = [UIColor grayColor];
            titleLabel.text = @"群成员管理";
            [cell addSubview:titleLabel];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    } else { //section == 2
        if (indexPath.row == 0) {
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 160, 50)];
            titleLabel.textAlignment = NSTextAlignmentLeft;
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.font = kFont17;
            titleLabel.textColor = [UIColor grayColor];
            titleLabel.text = @"消息免打扰";
            [cell addSubview:titleLabel];
            //消息免打扰开关
            _messageSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(kMainScreenWidth - 70, 10, 51, 31)];
            _messageSwitch.onTintColor = RGBACOLOR(250, 82, 74, 1.0);
            [_messageSwitch addTarget:self action:@selector(messageSwitchValueChange:) forControlEvents:UIControlEventValueChanged];
            [cell addSubview:_messageSwitch];
        } else if (indexPath.row == 1) {
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 160, 50)];
            titleLabel.textAlignment = NSTextAlignmentLeft;
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.font = kFont17;
            titleLabel.textColor = [UIColor grayColor];
            titleLabel.text = @"清空聊天记录";
            [cell addSubview:titleLabel];
        }
    }
    return cell;
}


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (_modelArray.count) {
            return self.memberView.height;
        } else {
            return 0;
        }
    } else {
        return 50.0f;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0.0;
    } else {
        return 10.0;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.section == 2) {
        if (indexPath.row == 1) { //点击了清空聊天记录
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"确定要删除聊天记录吗" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"清空聊天记录" otherButtonTitles:nil];
            [actionSheet showInView:self.view];
        }
    }
    if (indexPath.section == 1) {
        if (indexPath.row == 1 && (_isHolder == YES)) { //点击修改群组主题
            ModifyGroupDetailController *modifyVc = [[ModifyGroupDetailController alloc] init];
            modifyVc.groupID = _groupID;
            modifyVc.receiveSender = _groupName;
            [self presentViewController:[[UINavigationController alloc] initWithRootViewController:modifyVc] animated:YES completion:nil];
        } else if (indexPath.row == 2 && (_isHolder == YES)) { //点击修改群组描述
            ModifyGroupDetailController *modifyVc = [[ModifyGroupDetailController alloc] init];
            modifyVc.groupID = _groupID;
            modifyVc.receiveSender = _groupDesc;
            modifyVc.modifyType = 1;
            [self presentViewController:[[UINavigationController alloc] initWithRootViewController:modifyVc] animated:YES completion:nil];
        } else if (indexPath.row == 3) { //点击进入踢人界面
            RemoveGroupMemberViewController *dest = [[RemoveGroupMemberViewController alloc] init];
            dest.groupID = _groupID;
            NSMutableArray *array = [NSMutableArray array];
            for (GroupMemberModel *model in _modelArray) {
                if (![model.memberID isEqualToString:[LYUserService sharedInstance].userID]) {
                    [array addObject:model];
                }
            }
            dest.members = array;
            [self.navigationController pushViewController:dest animated:YES];
        }
    }
}


#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        //发送清空聊天记录的通知
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveAllMessages" object:nil];
    }
}


#pragma mark - 监听切换免打扰开关
- (void)messageSwitchValueChange:(UISwitch *)sender {
    
    //切换监听
    [[EaseMob sharedInstance].chatManager asyncIgnoreGroupPushNotification:_groupID isIgnore:sender.isOn];
}

#pragma mark - 监听点击"退出该群"
- (void)quitGroup:(UIButton *)sender {
    
    if (_isHolder) {
        [MBProgressHUD showMessage:@"解散中.."];
        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/group/delete",REQUESTHEADER] andParameter:@{@"id":_groupID} success:^(id successResponse) {
            if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
                [MBProgressHUD hideHUD];
                //删除之前的群组对话
                [[EaseMob sharedInstance].chatManager removeConversationByChatter:_easemob_id deleteMessages:YES append2Chat:YES];
                //发送更新会话列表的通知
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LY_ReloadConversationList" object:nil];
                [self.navigationController popToRootViewControllerAnimated:YES];
                [MBProgressHUD showSuccess:@"解散成功"];
            } else {
                [MBProgressHUD hideHUD];
                [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
            }
        } andFailure:^(id failureResponse) {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"服务器繁忙,请重试"];
        }];
    } else {
        [MBProgressHUD showMessage:@"退出中.."];
        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/group/exit",REQUESTHEADER] andParameter:@{@"group_id":_groupID,@"user_id":[LYUserService sharedInstance].userID} success:^(id successResponse) {
            if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
                [MBProgressHUD hideHUD];
                //删除之前的群组对话
                [[EaseMob sharedInstance].chatManager removeConversationByChatter:_easemob_id deleteMessages:YES append2Chat:YES];
                //发送更新会话列表的通知
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LY_ReloadConversationList" object:nil];
                [self.navigationController popToRootViewControllerAnimated:YES];
                [MBProgressHUD showSuccess:@"已退出"];
            } else {
                [MBProgressHUD hideHUD];
                [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
            }
        } andFailure:^(id failureResponse) {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"服务器繁忙,请重试"];
        }];
    }
}

#pragma mark - 通知中心
//接收push到个人详情的通知
- (void)pushToGroupMemberDetailViewController:(NSNotification *)aNotification {
    MemberButton *sender = [aNotification object];
    if ([sender.memberID isEqualToString:[LYUserService sharedInstance].userID]) {
        return;
    }
    DetailDataViewController *dest = [[DetailDataViewController alloc] init];
    dest.friendId = [sender.memberID integerValue];
    [self.navigationController pushViewController:dest animated:YES];
}

//重载群组详情
- (void)reloadGroupDetail:(NSNotification *)aNotification {
    [self getGroupDetailInfo];
    if ([aNotification userInfo]) { //有userInfo说明是修改了群组主题
        //通知聊天界面修改title
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadGroupChatVcTitle" object:nil userInfo:@{@"name":[aNotification userInfo][@"name"]}];
    }
}

- (void)addGroupMembers:(NSNotification *)aNotification {
    AddGroupMemberViewController *dest = [[AddGroupMemberViewController alloc] init];
    dest.groupID = _groupID;
    NSMutableArray *members = [NSMutableArray array];
    for (GroupMemberModel *model in _modelArray) {
        [members addObject:model.memberID];
    }
    dest.alreadMembers = members;
    [self.navigationController pushViewController:dest animated:YES];
}

@end
