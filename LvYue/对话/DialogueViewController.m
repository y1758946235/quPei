//
//  DialogueViewController.m
//  LvYue
//
//  Created by apple on 15/9/28.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import "DialogueViewController.h"
#import "UIView+RSAdditions.h"
#import "UIView+SZYOperation.h"
#import "MessageViewController.h"
#import "MyContractsViewController.h"
#import "SearchNewFriendController.h"
#import "CheckMessageListController.h"
#import "CreateGroupViewController.h"
#import "MyGroupListController.h"
#import "DetailDataViewController.h"
#import "ChatViewController.h"
#import "SystemMessageViewController.h"
#import "RequirementManagerViewController.h"
#import "SkillManagerViewController.h"

#define kMenuViewHeight 80.0f

@interface DialogueViewController (){
    
    //记录上一个按下的按钮
    UIButton *_lastBtn;
}

@property (nonatomic, strong) UIView *selectView;

@property (nonatomic, strong) UIButton *messageBtn;

@property (nonatomic, strong) UIButton *contactListBtn;

@property (nonatomic, strong) UIButton *menuBtn;

@property (nonatomic, strong) UIView *menuView;

@end

@implementation DialogueViewController

#pragma mark - lazy
- (UIView *)menuView {
    if (!_menuView) {
        _menuView = [[UIView alloc] initWithFrame:CGRectMake(kMainScreenWidth - 150, _menuBtn.bottom + 5, 140, 0)];
        [_menuView setBackgroundColor:[UIColor whiteColor]];
        _menuView.layer.cornerRadius = 5.0;
        _menuView.clipsToBounds = YES;
        _menuView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _menuView.layer.borderWidth = 0.5;
        
        UIImageView *addBuddyIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"添加朋友"]];
        addBuddyIcon.frame = CGRectMake(10, 13, 16, 14);
        [_menuView addSubview:addBuddyIcon];
        
        UILabel *title1 = [[UILabel alloc] initWithFrame:CGRectMake(addBuddyIcon.right + 15, 0, _menuView.width - addBuddyIcon.right, 40)];
        [title1 setText:@"添加朋友"];
        title1.font = kFont15;
        title1.textColor = [UIColor blackColor];
        title1.textAlignment = NSTextAlignmentLeft;
        [_menuView addSubview:title1];
        
        UIButton *addBuddyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        addBuddyBtn.frame = CGRectMake(0, 0, 140, 40);
        [addBuddyBtn setBackgroundColor:[UIColor clearColor]];
        [addBuddyBtn addTarget:self action:@selector(addBuddy:) forControlEvents:UIControlEventTouchUpInside];
        [_menuView addSubview:addBuddyBtn];
        
        UIImageView *createGroupIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"建群"]];
        createGroupIcon.frame = CGRectMake(10, 53, 16, 14);
        [_menuView addSubview:createGroupIcon];
        
        UILabel *title2 = [[UILabel alloc] initWithFrame:CGRectMake(createGroupIcon.right + 15, 40, _menuView.width - createGroupIcon.right, 40)];
        [title2 setText:@"建群"];
        title2.font = kFont15;
        title2.textColor = [UIColor blackColor];
        title2.textAlignment = NSTextAlignmentLeft;
        [_menuView addSubview:title2];
        
        UIButton *createGroupBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        createGroupBtn.frame = CGRectMake(0, 40, 140, 40);
        [createGroupBtn setBackgroundColor:[UIColor clearColor]];
        [createGroupBtn addTarget:self action:@selector(createGroup:) forControlEvents:UIControlEventTouchUpInside];
        [_menuView addSubview:createGroupBtn];
        
        _menuView.alpha = 0.0;
        
        [self.view addSubview:_menuView];
    }
    return _menuView;
}


#pragma mark - circle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //注册通知
    [self registerAllNotifications];
    
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 64)];
    headView.backgroundColor = [UIColor colorWithRed:29/255.0 green:189/255.0 blue:159/255.0 alpha:1];
    [self.view addSubview:headView];
    
    _messageVC = [[MessageViewController alloc] init];
    _myContactVC = [[MyContractsViewController alloc] init];
    [_messageVC.view setFrame:CGRectMake(0, 60, kMainScreenWidth, kMainScreenHeight - 109)];
    [_myContactVC.view setFrame:CGRectMake(0, 60, kMainScreenWidth, kMainScreenHeight - 109)];
    
    _selectView = [[UIView alloc] init];
    _selectView.center = CGPointMake(kMainScreenWidth / 2, 40);
    _selectView.bounds = CGRectMake(0, 0, 200, 30);
    _selectView.layer.borderColor = [UIColor whiteColor].CGColor;
    _selectView.layer.borderWidth = 1;
    _selectView.layer.cornerRadius = 15.0;
    _selectView.clipsToBounds = YES;
    [self.view addSubview:_selectView];
    
    _messageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _messageBtn.frame = CGRectMake(0, 0, 100, 30);
    [_messageBtn setBackgroundColor:[UIColor whiteColor]];
    [_messageBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_messageBtn setTitle:@"消息" forState:UIControlStateNormal];
    _messageBtn.titleLabel.font = kFont16;
    [_messageBtn addTarget:self action:@selector(transformToMessageView:) forControlEvents:UIControlEventTouchUpInside];
    [_selectView addSubview:_messageBtn];
    
    _contactListBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _contactListBtn.frame = CGRectMake(100, 0, 100, 30);
    [_contactListBtn setBackgroundColor:[UIColor colorWithRed:29/255.0 green:189/255.0 blue:159/255.0 alpha:1]];
    [_contactListBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_contactListBtn setTitle:@"通讯录" forState:UIControlStateNormal];
    _contactListBtn.titleLabel.font = kFont16;
    [_contactListBtn addTarget:self action:@selector(transformToContactList:) forControlEvents:UIControlEventTouchUpInside];
    [_selectView addSubview:_contactListBtn];
    
    //通讯录消息提醒器
    _unReadLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.selectView.frame) - 10, CGRectGetMinY(self.selectView.frame) - 2, 12, 12)];
    _unReadLabel.backgroundColor = RGBACOLOR(249, 82, 74, 1.0);
    _unReadLabel.layer.cornerRadius = 6.0;
    _unReadLabel.clipsToBounds = YES;
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    if ([[user objectForKey:kHavePrompt] isEqualToString:@"1"]) {
        _unReadLabel.hidden = NO;
    } else {
        _unReadLabel.hidden = YES;
    }
    [self.view addSubview:_unReadLabel];
    
    _menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _menuBtn.frame = CGRectMake(kMainScreenWidth - 51, 21, 43, 44);
    UIImageView *menuImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"更多"]];
    menuImgView.frame = CGRectMake(10, 14, 21.5, 5.5);
    [_menuBtn addSubview:menuImgView];
    [_menuBtn addTarget:self action:@selector(openMenuView:) forControlEvents:UIControlEventTouchUpInside];
    _menuBtn.tag = 0;
    [self.view addSubview:_menuBtn];
    
    [self.view addSubview:_messageVC.view];
    _lastBtn = _messageBtn;
}


- (void)registerAllNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushToNewFriendViewController:) name:@"pushToNewFriendController" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushToMyGroupListController:) name:@"pushToMyGroupListController" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushToBuddyDetailController:) name:@"pushToBuddyDetailController" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushToRequirementListController:) name:@"pushToRequirementListController" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushToSkillListController:) name:@"pushToSkillListController" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushToChatViewController:) name:@"MessageViewController2Chat" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushToSystemMessageViewController:) name:@"MessageViewController2SystemMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeOrShowMyBuddyListVcPushPrompt:) name:@"closeOrShowMyBuddyListVcPushPrompt" object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - 监听右上角的展开菜单按钮
- (void)openMenuView:(UIButton *)sender {
    
    if (sender.tag) {
        sender.tag = 0;
        [self closeMenuView];
    } else {
        sender.tag = 100;
        [self openMenuView];
    }
}


//关闭菜单
- (void)closeMenuView {
    [self.view bringSubviewToFront:self.menuView];
    [UIView animateWithDuration:0.3 animations:^{
        self.menuView.alpha = 0.0;
        self.menuView.frame = CGRectMake(self.menuView.left, self.menuView.top, self.menuView.width, 0);
    }];
}


//展开菜单
- (void)openMenuView {
    [self.view bringSubviewToFront:self.menuView];
    [UIView animateWithDuration:0.3 animations:^{
        self.menuView.alpha = 1.0;
        self.menuView.frame = CGRectMake(self.menuView.left, self.menuView.top, self.menuView.width, kMenuViewHeight);
    }];
}


#pragma mark - 监听添加朋友
- (void)addBuddy:(UIButton *)sender {
    [self closeMenuView];
    [self.navigationController pushViewController:[[SearchNewFriendController alloc] init] animated:YES];
}


#pragma mark - 监听建群
- (void)createGroup:(UIButton *)sender {
    [self closeMenuView];
    [self.navigationController pushViewController:[[CreateGroupViewController alloc] init] animated:YES];
}

#pragma - 内容转换
- (void)transformToMessageView:(UIButton *)sender {
    
    if (_lastBtn == sender) {
        return;
    }
    [self closeMenuView];
    [sender setBackgroundColor:[UIColor whiteColor]];
    [sender setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_lastBtn setBackgroundColor:[UIColor colorWithRed:29/255.0 green:189/255.0 blue:159/255.0 alpha:1]];
    [_lastBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [_messageVC.view removeFromSuperview];
    [_myContactVC.view removeFromSuperview];
    
    [self.view addSubview:_messageVC.view];
    [self.view bringSubviewToFront:self.menuView];
    _lastBtn = sender;
}


- (void)transformToContactList:(UIButton *)sender {
    
    if (_lastBtn == sender) {
        return;
    }
    [self closeMenuView];
    [sender setBackgroundColor:[UIColor whiteColor]];
    [sender setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_lastBtn setBackgroundColor:[UIColor colorWithRed:29/255.0 green:189/255.0 blue:159/255.0 alpha:1]];
    [_lastBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [_messageVC.view removeFromSuperview];
    [_myContactVC.view removeFromSuperview];
    
    [self.view addSubview:_myContactVC.view];
    [self.view bringSubviewToFront:self.menuView];
    _lastBtn = sender;
}


#pragma mark - 通知中心
- (void)pushToNewFriendViewController:(NSNotification *)aNotification {
    [self closeMenuView];
    [self.navigationController pushViewController:[[CheckMessageListController alloc] init] animated:YES];
}

- (void)pushToMyGroupListController:(NSNotification *)aNotification {
    [self closeMenuView];
    [self.navigationController pushViewController:[[MyGroupListController alloc] init] animated:YES];
}

- (void)pushToBuddyDetailController:(NSNotification *)aNotification {
    [self closeMenuView];
    NSString *userID = [aNotification userInfo][@"userID"];
    
    DetailDataViewController *detailDest = [[DetailDataViewController alloc] init];
    detailDest.isContactsList2Detail = YES;
    detailDest.friendId = [userID integerValue];
    [self.navigationController pushViewController:detailDest animated:YES];
}

- (void)pushToRequirementListController:(NSNotification *)aNotification {
    [self closeMenuView];
    
    RequirementManagerViewController *rmVC = [[RequirementManagerViewController alloc] init];
    [self.navigationController pushViewController:rmVC animated:YES];
}

- (void)pushToSkillListController:(NSNotification *)aNotification {
    [self closeMenuView];
    
    SkillManagerViewController *rmVC = [[SkillManagerViewController alloc] init];
    [self.navigationController pushViewController:rmVC animated:YES];
}

- (void)pushToChatViewController:(NSNotification *)aNotification {
    [self closeMenuView];
    EMConversation *conversation = [aNotification userInfo][@"conversation"];
    ChatViewController *chatVc = [[ChatViewController alloc] initWithChatter:conversation.chatter conversationType:conversation.conversationType];
    if (conversation.conversationType == eConversationTypeChat) { //如果是单聊
        NSString *userName = [aNotification userInfo][@"userName"];
        chatVc.title = userName;
    } else { //如果是群聊
        NSString *groupName = [aNotification userInfo][@"groupName"];
        MLOG(@"群组名字：%@",groupName);
        chatVc.title = groupName;
        NSString *groupID = [aNotification userInfo][@"groupID"];
        chatVc.groupID = groupID;
    }
    chatVc.isChatList2Chat = YES;
    [self.navigationController pushViewController:chatVc animated:YES];
}

- (void)pushToSystemMessageViewController:(NSNotification *)aNotification {
    [self closeMenuView];
    SystemMessageViewController *dest = [[SystemMessageViewController alloc] init];
    [self.navigationController pushViewController:dest animated:YES];
}


//显示或隐藏一级推送提示器
- (void)closeOrShowMyBuddyListVcPushPrompt:(NSNotification *)aNotification {
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    if ([[user objectForKey:kHavePrompt] isEqualToString:@"1"]) {
        _unReadLabel.hidden = NO;
    } else {
        _unReadLabel.hidden = YES;
    }
}

@end
