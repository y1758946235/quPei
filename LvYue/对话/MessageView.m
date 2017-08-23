//
//  MyContactView.m
//  LvYue
//
//  Created by X@Han on 16/12/15.
//  Copyright © 2016年 OLFT. All rights reserved.

#define WIDTH self.frame.size.width
#define HEIGHT self.frame.size.height

#import "MessageView.h"
#import "MessageCell.h"
#import "NSDate+Category.h"
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "ConvertToCommonEmoticonsHelper.h"
#import "RobotManager.h"
#import "ChatViewController.h"
#import "MBProgressHUD+NJ.h"
#import "SystemMessageViewController.h"
#import "InvitaViewController.h"
@interface MessageView ()<UITableViewDelegate,UITableViewDataSource,IChatManagerDelegate>{
    
    UILabel *promptLabel;
    UILabel *promptLabel0;
    UILabel *promptLabel1;
    UILabel *promptLabel2;//消息提醒
    
    NSArray *data;
   
}


@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *sysOneDataArr;
@property (nonatomic, strong) NSMutableArray *invitaDataArr;
@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) UIView *networkStateView;

@property (nonatomic,copy) NSString *bageNum;//角标数量
@property (nonatomic,copy) NSString *lastText;//最新一条内容
@property (nonatomic,copy) NSString *lastInviteText;//最新邀请一条内容
@property(nonatomic,assign)NSInteger systemMessagePoint;//系统消息的点

@end

@implementation MessageView


- (NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc]init];
    }
    
    return _dataSource;
    
}
- (NSMutableArray *)sysOneDataArr{
    if (!_sysOneDataArr) {
        _sysOneDataArr = [[NSMutableArray alloc]init];
    }
    
    return _sysOneDataArr;
    
}
- (NSMutableArray *)invitaDataArr{
    if (!_invitaDataArr) {
        _invitaDataArr = [[NSMutableArray alloc]init];
    }
    
    return _invitaDataArr;
    
}
- (instancetype)initWithFrame:(CGRect)frame{
    
    
    self = [super initWithFrame:frame];
    if (self) {
        [self refreshDataSource];
        
        [self rigisterAllNotifications];
         [self registerNotifications];
        [[EaseMob sharedInstance].chatManager loadAllConversationsFromDatabaseWithAppend2Chat:NO];
        [self removeEmptyConversationsFromDB];
        
        [self setTable];
        [self refreshDataSource];
        self.bageNum = @"";
        self.lastText = @"";
       self.lastInviteText = @"";
        
        //重载系统跟邀请类的消息
        [self reloadSystomAndInviteMessage]   ;
    }
    return self;
    
}
-(void)reloadSystomAndInviteMessage{
    [self.sysOneDataArr removeAllObjects];
    [self.invitaDataArr removeAllObjects];
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    self.lastText = [user objectForKey:@"lastText"];
  
    self.lastInviteText = [user objectForKey:@"lastInviteText"];
    
    if (self.lastText.length > 0) {
          [self.sysOneDataArr addObject:self.lastText];
    }
    if (self.lastInviteText.length > 0) {
        [self.invitaDataArr addObject:self.lastInviteText];
    }
    self.systemMessagePoint = 0;
    [self.tableView reloadData];
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadInvitaMessage:) name:@"LY_reloadInvitaMessage" object:nil];
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



- (void)setTable{
    
    
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT) style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerClass:[MessageCell class] forCellReuseIdentifier:@"cell"];
    [self addSubview:_tableView];
    
   }





#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (section == 0) {
        return self.sysOneDataArr.count;
    }
    if (section == 1) {
        return self.invitaDataArr.count;
    }
     return self.dataSource.count;
    
   
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section== 0) {
        MessageCell *cell = [MessageCell messageCellWithTableView:tableView andIndexPath:indexPath];
        cell.nameLabel.text = @"系统消息";
        cell.lastMessageLabel.text = self.lastText;
        cell.iconView.image = [UIImage imageNamed:@"systom_head"];
        cell.unReadCountBtn.hidden = YES;
        return cell;
    }else if (indexPath.section== 1) {
        MessageCell *cell = [MessageCell messageCellWithTableView:tableView andIndexPath:indexPath];
        cell.nameLabel.text = @"邀请消息";
        cell.lastMessageLabel.text = self.lastInviteText;
        cell.iconView.image = [UIImage imageNamed:@"invite_head"];
        cell.unReadCountBtn.hidden = YES;
        return cell;
    }else{
    //MessageCell *cell = [MessageCell messageCellWithTableView:tableView andIndexPath:indexPath];
  
    MessageCell *cell = [MessageCell messageCellWithTableView:tableView andIndexPath:indexPath];
    EMConversation *conversation = [self.dataSource objectAtIndex:indexPath.row];
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
    
    return nil;
   
}





#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return 72;
}


#pragma mark   - ----点击进入聊天页面------    有数据再写
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        SystemMessageViewController * vc = [[SystemMessageViewController alloc]init];
        [self.viewController.navigationController pushViewController:vc animated:YES];
        //刷新未读消息数
        [self refreshDataSource];
    }else if (indexPath.section == 1) {
        
       InvitaViewController  * vc = [[InvitaViewController alloc]init];
        [self.viewController.navigationController pushViewController:vc animated:YES];
        //刷新未读消息数
        [self refreshDataSource];
    }else{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

     MessageCell *cell = (MessageCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    EMConversation *conversation = self.dataSource[indexPath.row];
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
    } else if(conversation.conversationType == eConversationTypeChat) { //如果是单聊
        //通知主控制器push到聊天界面
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MessageViewController2Chat" object:nil userInfo:@{@"conversation":conversation,@"userName":cell.nameLabel.text}];
//        //刷新未读消息数
        [self refreshDataSource];
    }
    }
   
}


-(void)refreshDataSource
{
    self.dataSource = [self loadDataSource];
    [_tableView reloadData];
   // [self hideHud];
}

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
//    [self getData];
    NSDictionary *dic = aNotification.userInfo;
    [self.sysOneDataArr removeAllObjects];
    [self.sysOneDataArr addObject:dic[@"aps"][@"alert"]];
    self.lastText = dic[@"aps"][@"alert"];
    [self.tableView reloadData];
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setObject:[NSString stringWithFormat:@"%@",self.lastText] forKey:@"lastText"];
}
//更新邀请类消息
- (void)reloadInvitaMessage:(NSNotification *)aNotification {
    //    [self getData];
    NSDictionary *dic = aNotification.userInfo;
    [self.invitaDataArr removeAllObjects];
    [self.invitaDataArr addObject:dic[@"aps"][@"alert"]];
     self.lastInviteText = dic[@"aps"][@"alert"];
    [self.tableView reloadData];
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setObject:[NSString stringWithFormat:@"%@",self.lastInviteText] forKey:@"lastInviteText"];
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



-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
   
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
       
        
        [self.sysOneDataArr removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    if (indexPath.section == 1) {
        
       
        [self.invitaDataArr removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    if (indexPath.section == 2) {
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            EMConversation *converation = [self.dataSource objectAtIndex:indexPath.row];
            [[EaseMob sharedInstance].chatManager removeConversationByChatter:converation.chatter deleteMessages:YES append2Chat:YES];
            [self.dataSource removeObjectAtIndex:indexPath.row];
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    
}



@end
