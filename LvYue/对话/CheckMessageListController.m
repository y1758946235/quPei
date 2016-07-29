//
//  CheckMessageListController.m
//  LvYue
//
//  Created by apple on 15/10/7.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import "ChatSendHelper.h"
#import "CheckMessageCell.h"
#import "CheckMessageListController.h"
#import "CheckMessageModel.h"
#import "DialogueViewController.h"
#import "LYDetailDataViewController.h"
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "MBProgressHUD+NJ.h"
#import "SearchNewFriendController.h"

@interface CheckMessageListController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *modelArray;

@end

@implementation CheckMessageListController

#pragma mark - lazy
- (NSMutableArray *)modelArray {
    if (!_modelArray) {
        _modelArray = [NSMutableArray array];
    }
    return _modelArray;
}


#pragma mark - circle
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setRightButton:nil title:@"添加朋友" target:self action:@selector(addNewFriend:) rect:CGRectMake(0, 0, 64, 44)];
    self.title                                    = @"新的朋友";
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _tableView                 = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
    _tableView.dataSource      = self;
    _tableView.delegate        = self;

    UIView *headerView         = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 25.0f)];
    headerView.backgroundColor = RGBACOLOR(243, 243, 243, 1.0);
    UILabel *titleLabel        = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 120, 25)];
    titleLabel.textAlignment   = NSTextAlignmentLeft;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font            = kFont16;
    titleLabel.text            = @"验证消息列表";
    titleLabel.textColor       = [UIColor grayColor];
    [headerView addSubview:titleLabel];
    _tableView.tableHeaderView = headerView;

    [self.view addSubview:_tableView];

    [self postRequest];
}


- (void)postRequest {

    [self.modelArray removeAllObjects];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/messageVerify/list", REQUESTHEADER] andParameter:@{ @"pageNum": @"1",
                                                                                                                                   @"user_id": [LYUserService sharedInstance].userID,
                                                                                                                                   @"status": @"-1" }
        success:^(id successResponse) {
            if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
                //看到了验证信息列表,因此关闭推送提醒器
                NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
                if ([[user objectForKey:kHavePrompt] isEqualToString:@"1"]) {
                    [user setObject:@"0" forKey:kHavePrompt];
                    [user synchronize];
                    //发送关闭"对话"的提醒器的通知
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"closeOrShowMyBuddyListVcPushPrompt" object:nil];
                    //发送关闭好友列表的提醒器的通知
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"closeOrShowCheckMessageListVcPushPrompt" object:nil];
                }

                NSArray *array = successResponse[@"data"][@"list"];
                for (NSDictionary *dict in array) {
                    CheckMessageModel *model = [[CheckMessageModel alloc] initWithDict:dict];
                    [self.modelArray addObject:model];
                }
                [_tableView reloadData];
            } else {
                [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"msg"]]];
            }
        }
        andFailure:^(id failureResponse) {
            [MBProgressHUD showError:@"服务器繁忙,请重试"];
        }];
}


#pragma mark - 监听点击添加朋友
- (void)addNewFriend:(UIButton *)sender {
    [self.navigationController pushViewController:[[SearchNewFriendController alloc] init] animated:YES];
}


#pragma mark - UITableViewDataSouce
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.modelArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CheckMessageCell *cell = [CheckMessageCell checkMessageCellWithTableView:tableView];
    if (self.modelArray.count) {
        CheckMessageModel *model = self.modelArray[indexPath.row];
        [cell fillDataWithModel:model];
        [cell.handleBtn addTarget:self action:@selector(passCheck:) forControlEvents:UIControlEventTouchUpInside];
        cell.handleBtn.tag = 100 + indexPath.row;
    }
    return cell;
}

#pragma mark - UITableViewDeleagte
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CheckMessageModel *model         = self.modelArray[indexPath.row];
    LYDetailDataViewController *dest = [[LYDetailDataViewController alloc] init];
    dest.userId                      = model.senderID;
    [self.navigationController pushViewController:dest animated:YES];
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    //删除某一条验证信息
    CheckMessageModel *model = self.modelArray[indexPath.row];
    if (model.messageID) {
        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/messageVerify/deletes", REQUESTHEADER] andParameter:@{ @"ids": model.messageID } success:^(id successResponse) {
            if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
                [self.modelArray removeObject:model];
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
            } else {
                [MBProgressHUD showError:@"删除失败"];
            }
        }
            andFailure:^(id failureResponse) {
                [MBProgressHUD showError:@"删除失败"];
            }];
    }
}


#pragma mark - 监听cell的"接受"
- (void)passCheck:(UIButton *)sender {

    CheckMessageModel *model = self.modelArray[sender.tag - 100];
    NSDictionary *requestDict;
    if ([model.type isEqualToString:@"1"]) {
        requestDict = @{ @"user_id": [LYUserService sharedInstance].userID,
                         @"friend_id": model.senderID,
                         @"status": @"2" };
        [MBProgressHUD showMessage:@"正在通过验证.."];
        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/messageVerify/updateIosStatus", REQUESTHEADER] andParameter:requestDict success:^(id successResponse) {
            if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
                if ([model.type isEqualToString:@"1"]) {
                    //手动调用环信的"通过验证"方法
                    EMError *error = nil;
                    BOOL isSuccess = [[EaseMob sharedInstance].chatManager acceptBuddyRequest:model.senderID error:&error];
                    if (isSuccess && !error) {
                        [MBProgressHUD hideHUD];
                        [MBProgressHUD showSuccess:@"接受成功"];
                        EMConversation *conversation = [[EaseMob sharedInstance].chatManager conversationForChatter:model.senderID conversationType:eConversationTypeChat];
                        //通过了XX用户的验证信息(同意加好友)
                        [ChatSendHelper sendTextMessageWithString:@"我已通过了你的好友验证请求"
                                                       toUsername:conversation.chatter
                                                      messageType:eMessageTypeChat
                                                requireEncryption:NO
                                                              ext:nil];
                        [self postRequest];
                        //手动更新好友列表
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMyBuddyList" object:nil];
                    }
                }
            } else {
                [MBProgressHUD hideHUD];
                [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"msg"]]];
            }
        }
            andFailure:^(id failureResponse) {
                [MBProgressHUD hideHUD];
                [MBProgressHUD showError:@"服务器繁忙,请重试"];
            }];
    } else {
        requestDict = @{ @"user_id": [LYUserService sharedInstance].userID,
                         @"friend_id": model.senderID,
                         @"group_id": model.groupID,
                         @"status": @"2" };
        [MBProgressHUD showMessage:@"正在通过验证.."];
        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/messageVerify/updateStatus", REQUESTHEADER] andParameter:requestDict success:^(id successResponse) {
            if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
                [MBProgressHUD hideHUD];
                [MBProgressHUD showSuccess:@"接受成功"];

                //同意加入申请后发送通知
                if ([model.type isEqualToString:@"2"] || [model.type isEqualToString:@"4"]) {
                    EMConversation *conversation = [[EaseMob sharedInstance].chatManager conversationForChatter:model.easemob_id conversationType:eConversationTypeGroupChat];
                    [ChatSendHelper sendTextMessageWithString:[NSString stringWithFormat:@"【公告】%@加入了群", model.name]
                                                   toUsername:conversation.chatter
                                                  messageType:eMessageTypeGroupChat
                                            requireEncryption:NO
                                                          ext:nil];
                }

                [self postRequest];
            } else {
                [MBProgressHUD hideHUD];
                [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"msg"]]];
            }
        }
            andFailure:^(id failureResponse) {
                [MBProgressHUD hideHUD];
                [MBProgressHUD showError:@"服务器繁忙,请重试"];
            }];
    }
}


@end
