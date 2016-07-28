//
//  MessageViewController.m
//  LvYue
//
//  Created by apple on 15/10/6.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import "MessageViewController.h"
#import "MessageCell.h"
#import "NSDate+Category.h"
#import "ChatViewController.h"
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "ConvertToCommonEmoticonsHelper.h"
#import "RobotManager.h"
#import "ChatViewController.h"
#import "MBProgressHUD+NJ.h"

#define kMessageCellHeight 70.0f

@interface MessageViewController ()<UITableViewDataSource,UITableViewDelegate,IChatManagerDelegate> {
    UILabel *promptLabel;
    UILabel *promptLabel0;
    UILabel *promptLabel1;
    UILabel *promptLabel2;//消息提醒

}

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) UIView *networkStateView;

@property (nonatomic,copy) NSString *bageNum;//角标数量
@property (nonatomic,copy) NSString *lastText;//最新一条内容
@property (nonatomic,assign) NSInteger systemMessagePoint;//系统消息的点


@end

@implementation MessageViewController

#pragma mark - circle
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self refreshDataSource];
    [self registerNotifications];

    //更新系统消息
    [self getData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self unregisterNotifications];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[EaseMob sharedInstance].chatManager loadAllConversationsFromDatabaseWithAppend2Chat:NO];
    [self removeEmptyConversationsFromDB];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight - 109) style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    //注册通知
    [self rigisterAllNotifications];
    
    [self refreshDataSource];
    [self registerNotifications];
    
    self.bageNum = @"";
    self.lastText = @"";
    
    //更新系统消息
    [self getData];
}

//更新系统消息
- (void)getData {

    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/messageSystem/numLast",REQUESTHEADER] andParameter:@{@"user_id":[LYUserService sharedInstance].userID} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            self.bageNum = [NSString stringWithFormat:@"%@",successResponse[@"data"][@"length"]];
            self.lastText = successResponse[@"data"][@"message"][@"content"];
            //更新对话tabbar的提示数字
            UINavigationController *nav = kAppDelegate.rootTabC.viewControllers[1];

            NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
            NSString *str = [user objectForKey:kHavePrompt];
            NSString *skillStr = [user objectForKey:kHaveInvite];
            NSString *requireStr  = [user objectForKey:kHaveRequire];
            if ([[EaseMob sharedInstance].chatManager loadTotalUnreadMessagesCountFromDatabase] == 0 && kAppDelegate.unReadSystemMessageNum == 0 && [str integerValue] == 0 && [skillStr integerValue] == 0 && [requireStr integerValue] == 0) {
                nav.tabBarItem.badgeValue = nil;
            }
            else if ([[EaseMob sharedInstance].chatManager loadTotalUnreadMessagesCountFromDatabase] == 0 && kAppDelegate.unReadSystemMessageNum != 0 && [str integerValue] == 0 && [skillStr integerValue] == 0 && [requireStr integerValue] == 0) {
                nav.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld",(long)kAppDelegate.unReadSystemMessageNum];
            }
            else if ([[EaseMob sharedInstance].chatManager loadTotalUnreadMessagesCountFromDatabase] == 0 && kAppDelegate.unReadSystemMessageNum == 0 && [str integerValue] != 0 && [skillStr integerValue] == 0 && [requireStr integerValue] == 0) {
                nav.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld",(long)[str integerValue]];
            }
            else if ([[EaseMob sharedInstance].chatManager loadTotalUnreadMessagesCountFromDatabase] == 0 && kAppDelegate.unReadSystemMessageNum == 0 && [skillStr integerValue] != 0 && [str integerValue] == 0 && [requireStr integerValue] == 0) {
                nav.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld",(long)[skillStr integerValue]];
            }
            else if ([[EaseMob sharedInstance].chatManager loadTotalUnreadMessagesCountFromDatabase] == 0 && kAppDelegate.unReadSystemMessageNum == 0 && [requireStr integerValue] != 0 && [str integerValue] == 0 && [skillStr integerValue] == 0) {
                nav.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld",(long)[requireStr integerValue]];
            }
            else {
                if (([[EaseMob sharedInstance].chatManager loadTotalUnreadMessagesCountFromDatabase] + kAppDelegate.unReadSystemMessageNum) > 99) {
                    nav.tabBarItem.badgeValue = @"99";
                } else {
                    nav.tabBarItem.badgeValue = [NSString stringWithFormat:@"%lu",((unsigned long)[[EaseMob sharedInstance].chatManager loadTotalUnreadMessagesCountFromDatabase] + kAppDelegate.unReadSystemMessageNum) + [str integerValue] + [skillStr integerValue] + [requireStr integerValue]];
                }
            }
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:3 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        } else {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
}


//注册通知
- (void)rigisterAllNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStateDidChange:) name:@"LY_NetworkConnectionStateDidChange" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadConversationList:) name:@"LY_ReloadConversationList" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadSystemMessage:) name:@"LY_ReloadSystemMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeCheckMessageListVcPushPrompt:) name:@"closeOrShowCheckMessageListVcPushPrompt" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeCheckMessageListVcPushPrompt:) name:@"closeOrShowCheckSkillListVcPushPrompt" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeCheckMessageListVcPushPrompt:) name:@"closeOrShowCheckRequireListVcPushPrompt" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadSystemMessagePoint:) name:@"LY_ReloadSystemMessagePoint" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cleanSystemMessagePoint:) name:@"LY_CleanSystemMessagePoint" object:nil];
}



//删除聊天室会话和不是最新的会话
- (void)removeEmptyConversationsFromDB
{
    NSArray *conversations = [[EaseMob sharedInstance].chatManager conversations];
    //创建一个可变的需要删除的会话数组
    NSMutableArray *needRemoveConversations;
    for (EMConversation *conversation in conversations) {
        if (!conversation.latestMessage || (conversation.conversationType == eConversationTypeChatRoom)) {
            if (!needRemoveConversations) {
                needRemoveConversations = [[NSMutableArray alloc] initWithCapacity:0];
            }
            
            [needRemoveConversations addObject:conversation.chatter];
        }
    }
    
    if (needRemoveConversations && needRemoveConversations.count > 0) {
        [[EaseMob sharedInstance].chatManager removeConversationsByChatters:needRemoveConversations
                                                             deleteMessages:YES
                                                                append2Chat:NO];
    }
}

//删除聊天室会话
- (void)removeChatroomConversationsFromDB
{
    NSArray *conversations = [[EaseMob sharedInstance].chatManager conversations];
    NSMutableArray *needRemoveConversations;
    for (EMConversation *conversation in conversations) {
        if (conversation.conversationType == eConversationTypeChatRoom) {
            if (!needRemoveConversations) {
                needRemoveConversations = [[NSMutableArray alloc] initWithCapacity:0];
            }
            
            [needRemoveConversations addObject:conversation.chatter];
        }
    }
    
    if (needRemoveConversations && needRemoveConversations.count > 0) {
        [[EaseMob sharedInstance].chatManager removeConversationsByChatters:needRemoveConversations
                                                             deleteMessages:YES
                                                                append2Chat:NO];
    }
}


//网络连接检测提醒View - getter
- (UIView *)networkStateView
{
    if (_networkStateView == nil) {
        _networkStateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
        _networkStateView.backgroundColor = [UIColor colorWithRed:255 / 255.0 green:199 / 255.0 blue:199 / 255.0 alpha:0.5];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, (_networkStateView.frame.size.height - 20) / 2, 20, 20)];
        imageView.image = [UIImage imageNamed:@"messageSendFail"];
        [_networkStateView addSubview:imageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + 10, 0, _networkStateView.frame.size.width - (CGRectGetMaxX(imageView.frame) + 10), _networkStateView.frame.size.height)];
        label.font = [UIFont systemFontOfSize:15.0];
        label.textColor = [UIColor grayColor];
        label.backgroundColor = [UIColor clearColor];
        label.text = @"目前网络不可用 , 请检查网络连接😊";
        [_networkStateView addSubview:label];
    }
    
    return _networkStateView;
}


#pragma mark - private

- (NSMutableArray *)loadDataSource
{
    NSMutableArray *ret = nil;
    NSArray *conversations = [[EaseMob sharedInstance].chatManager conversations];
    
    NSArray* sorte = [conversations sortedArrayUsingComparator:
                      ^(EMConversation *obj1, EMConversation* obj2){
                          EMMessage *message1 = [obj1 latestMessage];
                          EMMessage *message2 = [obj2 latestMessage];
                          if(message1.timestamp > message2.timestamp) {
                              return(NSComparisonResult)NSOrderedAscending;
                          }else {
                              return(NSComparisonResult)NSOrderedDescending;
                          }
                      }];
    
    ret = [[NSMutableArray alloc] initWithArray:sorte];
    return ret;
}

// 得到最后消息时间
-(NSString *)lastMessageTimeByConversation:(EMConversation *)conversation
{
    NSString *ret = @"";
    EMMessage *lastMessage = [conversation latestMessage];;
    if (lastMessage) {
        ret = [NSDate formattedTimeFromTimeInterval:lastMessage.timestamp];
    }
    
    return ret;
}

// 得到未读消息条数
- (NSInteger)unreadMessageCountByConversation:(EMConversation *)conversation
{
    NSInteger ret = 0;
    ret = conversation.unreadMessagesCount;
    
    return  ret;
}

// 得到最后消息文字或者类型
-(NSString *)subTitleMessageByConversation:(EMConversation *)conversation withTextLabel:(UILabel *)label
{
    NSString *ret = @"";
    EMMessage *lastMessage = [conversation latestMessage];
    if (lastMessage) {
        id<IEMMessageBody> messageBody = lastMessage.messageBodies.lastObject;
        switch (messageBody.messageBodyType) {
            case eMessageBodyType_Image:{
                if (conversation.unreadMessagesCount > 0) {
                    label.textColor = [UIColor colorWithRed:0.107 green:0.589 blue:0.037 alpha:1.000];
                } else {
                    label.textColor = [UIColor lightGrayColor];
                }
                ret = @"[图片]";
            } break;
            case eMessageBodyType_Text:{
                label.textColor = [UIColor lightGrayColor];
                // 表情映射
                NSString *didReceiveText = [ConvertToCommonEmoticonsHelper
                                            convertToSystemEmoticons:((EMTextMessageBody *)messageBody).text];
                if ([[RobotManager sharedInstance] isRobotMenuMessage:lastMessage]) {
                    ret = [[RobotManager sharedInstance] getRobotMenuMessageDigest:lastMessage];
                } else {
                    ret = didReceiveText;
                }
            } break;
            case eMessageBodyType_Voice:{
                if (conversation.unreadMessagesCount > 0) {
                    label.textColor = [UIColor colorWithRed:1.000 green:0.201 blue:0.209 alpha:1.000];
                } else {
                    label.textColor = [UIColor lightGrayColor];
                }
                ret = @"[语音]";
            } break;
            case eMessageBodyType_Location: {
                if (conversation.unreadMessagesCount > 0) {
                    label.textColor = [UIColor colorWithRed:0.066 green:0.415 blue:1.000 alpha:1.000];
                } else {
                    label.textColor = [UIColor lightGrayColor];
                }
                ret = @"[位置]";
            } break;
            case eMessageBodyType_Video: {
                if (conversation.unreadMessagesCount > 0) {
                    label.textColor = [UIColor orangeColor];
                } else {
                    label.textColor = [UIColor lightGrayColor];
                }
                ret = @"[视频]";
            } break;
            default: {
            } break;
        }
    }
    
    return ret;
    
}


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _dataSource.count + 4;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        cell.imageView.image = [UIImage imageNamed:@"系统消息"];
        cell.textLabel.text = @"系统消息";
        
        if (!promptLabel0) {
            promptLabel0 = [[UILabel alloc] initWithFrame:CGRectMake(kMainScreenWidth - 80, 25, 14, 14)];
            promptLabel0.backgroundColor = RGBACOLOR(29, 189, 159, 1.0);
            promptLabel0.layer.cornerRadius = 7.0;
            promptLabel0.clipsToBounds = YES;
        }
        [cell addSubview:promptLabel0];
        
        if (self.systemMessagePoint) {
            promptLabel0.hidden = NO;
        }
        else {
            promptLabel0.hidden = YES;
        }
        
        return cell;
    }
    else if (indexPath.row == 1) {
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        cell.imageView.image = [UIImage imageNamed:@"验证消息"];
        cell.textLabel.text = @"验证消息";
        
        if (!promptLabel) {
            promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(kMainScreenWidth - 80, 25, 14, 14)];
            promptLabel.backgroundColor = RGBACOLOR(29, 189, 159, 1.0);
            promptLabel.layer.cornerRadius = 7.0;
            promptLabel.clipsToBounds = YES;
            promptLabel.hidden = YES;
        }
        [cell addSubview:promptLabel];
        
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        if ([[user objectForKey:kHavePrompt] isEqualToString:@"1"]) {
            promptLabel.hidden = NO;
        } else {
            promptLabel.hidden = YES;
        }
        cell.hidden = YES;
        return cell;
    }
    else if (indexPath.row == 2) {
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(14, 24, 22, 22)];
        imageView.image = [UIImage imageNamed:@"需求"];
        [cell addSubview:imageView];
        
        cell.textLabel.text = @"        需求管理";
        
        if (!promptLabel1) {
            promptLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(kMainScreenWidth - 80, 25, 14, 14)];
            promptLabel1.backgroundColor = RGBACOLOR(29, 189, 159, 1.0);
            promptLabel1.layer.cornerRadius = 7.0;
            promptLabel1.clipsToBounds = YES;
            promptLabel1.hidden = YES;
        }
        [cell addSubview:promptLabel1];
        
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        if ([[user objectForKey:kHaveInvite] isEqualToString:@"1"]) {
            promptLabel1.hidden = NO;
            [cell addSubview:promptLabel1];
        } else {
            promptLabel1.hidden = YES;
            [cell addSubview:promptLabel1];
        }
        cell.hidden = YES;
        return cell;
    }
    else if (indexPath.row == 3) {
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(14, 24, 22, 22)];
        imageView.image = [UIImage imageNamed:@"技能"];
        [cell addSubview:imageView];

        cell.textLabel.text = @"        技能管理";
        
        if (!promptLabel2) {
            promptLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(kMainScreenWidth - 80, 25, 14, 14)];
            promptLabel2.backgroundColor = RGBACOLOR(29, 189, 159, 1.0);
            promptLabel2.layer.cornerRadius = 7.0;
            promptLabel2.clipsToBounds = YES;
            promptLabel2.hidden = YES;
        }
        [cell addSubview:promptLabel2];
        
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        if ([[user objectForKey:kHaveRequire] isEqualToString:@"1"]) {
            promptLabel2.hidden = NO;
            [cell addSubview:promptLabel2];
        } else {
            promptLabel2.hidden = YES;
            [cell addSubview:promptLabel2];
        }
        cell.hidden = YES;
        return cell;
    }
    else {
        MessageCell *cell = [MessageCell messageCellWithTableView:tableView andIndexPath:indexPath];
        EMConversation *conversation = [self.dataSource objectAtIndex:indexPath.row-4];
        //填充数据
        [cell fillDataWithConversation:conversation]; //填充名字和头像
        //填充最新一条消息体内容
        cell.lastMessageLabel.text = [self subTitleMessageByConversation:conversation withTextLabel:cell.lastMessageLabel];
        if ([self unreadMessageCountByConversation:conversation] > 0) {
            cell.unReadCountBtn.hidden = NO;
            [cell.unReadCountBtn setTitle:[NSString stringWithFormat:@"%ld",(long)[self unreadMessageCountByConversation:conversation]] forState:UIControlStateNormal];
        } else {
            cell.unReadCountBtn.hidden = YES;
        }
        return cell;
    }
}


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
#warning 隐藏需求，技能
    if (indexPath.row == 1||indexPath.row == 2 ||indexPath.row == 3) {
        return 0.00000000000000000000001;
    }
    return kMessageCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MessageCell *cell = (MessageCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.row == 0) { //系统消息
        //通知主控制器push到系统消息界面
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MessageViewController2SystemMessage" object:nil];
    } else if (indexPath.row == 1) { //系统消息
        //发送通知,通知主控制器push到新的朋友界面
        [[NSNotificationCenter defaultCenter] postNotificationName:@"pushToNewFriendController" object:nil];
    } else if (indexPath.row == 2) { //需求消息
        //发送通知,通知主控制器push到需求列表界面
        [[NSNotificationCenter defaultCenter] postNotificationName:@"pushToRequirementListController" object:nil];
    }else if (indexPath.row == 3) { //技能消息
        //发送通知,通知主控制器push到技能列表界面
        [[NSNotificationCenter defaultCenter] postNotificationName:@"pushToSkillListController" object:nil];
    }else { //聊天会话
        EMConversation *conversation = self.dataSource[indexPath.row - 4];
        if (conversation.conversationType == eConversationTypeGroupChat) { //如果是群聊
            [kAppDelegate.dataBaseQueue inDatabase:^(FMDatabase *db) {
                if ([kAppDelegate.dataBase open]) {
                    NSString *groupID = @"";
                    NSString *groupName = @"";
                    NSString *findSql = [NSString stringWithFormat:@"SELECT * FROM '%@' WHERE easemob_id = '%@'",@"Group",conversation.chatter];
                    FMResultSet *result = [kAppDelegate.dataBase executeQuery:findSql];
                    while ([result next]) {
                        groupID = [result stringForColumn:@"groupID"];
                        groupName = [result stringForColumn:@"name"];
                    }
                    //通知主控制器push到聊天界面
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"MessageViewController2Chat" object:nil userInfo:@{@"conversation":conversation,@"groupID":groupID,@"groupName":groupName}];
                    //刷新未读消息数
                    [self refreshDataSource];
                    [kAppDelegate.dataBase close];
                }
            }];
        } else if (conversation.conversationType == eConversationTypeChat) { //如果是单聊
            //通知主控制器push到聊天界面
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MessageViewController2Chat" object:nil userInfo:@{@"conversation":conversation,@"userName":cell.nameLabel.text}];
            //刷新未读消息数
            [self refreshDataSource];
        }
    }
}


-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return (indexPath.row == 0 || indexPath.row == 1)?NO:YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        EMConversation *converation = [self.dataSource objectAtIndex:indexPath.row - 4];
        [[EaseMob sharedInstance].chatManager removeConversationByChatter:converation.chatter deleteMessages:YES append2Chat:YES];
        [self.dataSource removeObjectAtIndex:indexPath.row - 4];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}


#pragma mark - IChatMangerDelegate

-(void)didUnreadMessagesCountChanged
{
    [self refreshDataSource];
}

- (void)didUpdateGroupList:(NSArray *)allGroups error:(EMError *)error
{
    [self refreshDataSource];
}


#pragma mark - registerNotifications
-(void)registerNotifications{
    [self unregisterNotifications];
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
}

-(void)unregisterNotifications{
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self unregisterNotifications];
}

#pragma mark - public
-(void)refreshDataSource
{
    self.dataSource = [self loadDataSource];
    [_tableView reloadData];
    [self hideHud];
}

- (void)isConnect:(BOOL)isConnect{
    if (!isConnect) {
        _tableView.tableHeaderView = self.networkStateView;
    }
    else{
        _tableView.tableHeaderView = nil;
    }
    
}

- (void)networkChanged:(EMConnectionState)connectionState
{
    if (connectionState == eEMConnectionDisconnected) {
        _tableView.tableHeaderView = self.networkStateView;
    }
    else{
        _tableView.tableHeaderView = nil;
    }
}

- (void)willReceiveOfflineMessages{
    NSLog(NSLocalizedString(@"message.beginReceiveOffine", @"Begin to receive offline messages"));
}

- (void)didReceiveOfflineMessages:(NSArray *)offlineMessages
{
    [self refreshDataSource];
}

- (void)didFinishedReceiveOfflineMessages{
    NSLog(NSLocalizedString(@"message.endReceiveOffine", @"End to receive offline messages"));
}


#pragma mark - 通知中心
//网络变化时显示提示UI
- (void)networkStateDidChange:(NSNotification *)aNotification {
    
    NSDictionary *stateDict = [aNotification userInfo];
    EMConnectionState connectState = [stateDict[@"connectionState"] integerValue];
    [self networkChanged:connectState];
}


//更新会话列表
- (void)reloadConversationList:(NSNotification *)aNotification {
    [self refreshDataSource];
}


//更新系统消息
- (void)reloadSystemMessage:(NSNotification *)aNotification {
    [self getData];
}

//更新系统消息的点
- (void)reloadSystemMessagePoint:(NSNotification *)aNotification{
    self.systemMessagePoint = 1;
    [self.tableView reloadData];
}

//消掉系统消息的点
- (void)cleanSystemMessagePoint:(NSNotification *)aNotification{
    self.systemMessagePoint = 0;
    [self.tableView reloadData];
}

#pragma mark - 关闭推送提醒器
- (void)closeCheckMessageListVcPushPrompt:(id)sender {
    //刷新
    [self.tableView reloadData];
}

@end
