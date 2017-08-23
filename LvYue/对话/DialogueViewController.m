//
//  DialogueViewController.m
//  LvYue
//
//  Created by apple on 15/9/28.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//


#import "DialogueViewController.h"

#import "UIView+RSAdditions.h"
#import "MessageView.h"
#import "MyContactView.h"
#import "otherZhuYeVC.h"
#define kMenuViewHeight 80.0f
#import "FriendModel.h"
@interface DialogueViewController (){
    //记录上一个按下的按钮
    UIButton *_lastBtn;
    
    UILabel * redDotLabel;
    
    NSString*  FriendTag;
      NSString*  AttentionTag;
}

@property (nonatomic,strong) UIView *showArea;
@property (nonatomic, strong) UIView *selectView;

@property (nonatomic, strong) UIButton *messageBtn;

@property (nonatomic, strong) UIButton *contactListBtn;

@property (nonatomic, strong) UIButton *menuBtn;

@property (nonatomic, strong) UIView *menuView;


@end

@implementation DialogueViewController



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
     redDotLabel.hidden = YES;
    [self  getFriendTag];
    [self getAttentionTag];
}
-(void)getFriendTag{
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/circle/getFriendTag",REQUESTHEADER] andParameter:@{@"userId":[CommonTool  getUserID]} success:^(id successResponse) {
      
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            FriendTag = successResponse[@"data"];
            if ([[NSString  stringWithFormat:@"%@",FriendTag] isEqualToString:@"1"] ) {
                redDotLabel.hidden = NO;
               
            _contactView.redDotFriendsLabel.hidden = NO;
               
                
             

            }else{
              
                    _contactView.redDotFriendsLabel.hidden = YES;
               
            }
        }else{
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
        }
    } andFailure:^(id failureResponse) {
        
    }];

}

-(void)getAttentionTag{
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/circle/getAttentionTag",REQUESTHEADER] andParameter:@{@"userId":[CommonTool  getUserID]} success:^(id successResponse) {
      
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            AttentionTag = successResponse[@"data"];
            
            if ([[NSString  stringWithFormat:@"%@",AttentionTag] isEqualToString:@"1"] ) {
                redDotLabel.hidden = NO;
                _contactView.redDotFansLabel.hidden = NO;
               
            }else{
                _contactView.redDotFansLabel.hidden = YES;
            }
            
        }else{
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
        }
    } andFailure:^(id failureResponse) {
        
    }];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerAllNotifications];
    UIView *headView         = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 64)];
    headView.backgroundColor = [UIColor colorWithHexString:@"#ffffff"];
    [self.view addSubview:headView];
    


    _mesView = [[MessageView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT-109)];
     _contactView = [[MyContactView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT-109)];
    
    
    _selectView  = [[UIView alloc] initWithFrame:CGRectMake(84, 31, SCREEN_WIDTH-168, 24)];
    _selectView.layer.borderColor  = [UIColor colorWithHexString:@"#ff5252"].CGColor;
    _selectView.layer.borderWidth  = 1;
    _selectView.layer.cornerRadius = 4.0;
    _selectView.clipsToBounds      = YES;
    [headView addSubview:_selectView];
    
  

    _messageBtn   = [UIButton buttonWithType:UIButtonTypeCustom];
    _messageBtn.frame = CGRectMake(0, 0, (SCREEN_WIDTH-168)/2, 24);
    [_messageBtn setBackgroundColor:[UIColor colorWithHexString:@"#ff5252"]];
    [_messageBtn setTitleColor:[UIColor colorWithHexString:@"ffffff"] forState:UIControlStateNormal];
    [_messageBtn setTitle:@"消息" forState:UIControlStateNormal];
    _messageBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    [_messageBtn addTarget:self action:@selector(transformToMessageView:) forControlEvents:UIControlEventTouchUpInside];
    [_selectView addSubview:_messageBtn];
    
    _contactListBtn       = [UIButton buttonWithType:UIButtonTypeCustom];
    _contactListBtn.frame = CGRectMake((SCREEN_WIDTH-168)/2, 0, (SCREEN_WIDTH-168)/2, 24);
    [_contactListBtn setBackgroundColor:[UIColor colorWithHexString:@"#ffffff"]];
    [_contactListBtn setTitleColor:[UIColor colorWithHexString:@"#ff5252"] forState:UIControlStateNormal];
    [_contactListBtn setTitle:@"好友" forState:UIControlStateNormal];
    _contactListBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    [_contactListBtn addTarget:self action:@selector(transformToContactList:) forControlEvents:UIControlEventTouchUpInside];
    [_selectView addSubview:_contactListBtn];

    [self.view addSubview:_mesView];
    
      _lastBtn = _messageBtn;
    

    redDotLabel = [[UILabel alloc]init];
    redDotLabel.frame = CGRectMake((_contactListBtn.frame.size.width *2/3) +5, 6, 6, 6);
    redDotLabel.layer.cornerRadius = 3;
    redDotLabel.clipsToBounds= YES;
    redDotLabel.backgroundColor = [UIColor  colorWithHexString:@"#ff5252"];
    redDotLabel.hidden = YES;
    [_contactListBtn addSubview:redDotLabel];
}


    

#pragma mark - 进入主页
-(void)pushToOtherZhuYeVC:(NSNotification *)aNotification {
    otherZhuYeVC *other = [[otherZhuYeVC alloc]init];
    other.userNickName = [aNotification userInfo][@"userNickName"];
    other.userId = [aNotification userInfo][@"userID"];  //别人ID
    [self.navigationController pushViewController:other animated:YES];
}
- (void)registerAllNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushToChatViewController:) name:@"MessageViewController2Chat" object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushToOtherZhuYeVC:) name:@"pushToOtherZhuYeVC2" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updataRedDotLabel:) name:@"updataRedDotLabel" object:nil];
}
-(void)updataRedDotLabel:(NSNotification *)aNotification{
    redDotLabel.hidden = YES;
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)pushToChatViewController:(NSNotification *)aNotification {
    
    EMConversation *conversation = [aNotification userInfo][@"conversation"];
    ChatViewController *chatVc   = [[ChatViewController alloc] initWithChatter:conversation.chatter conversationType:conversation.conversationType];
    if (conversation.conversationType == eConversationTypeChat) { //如果是单聊
        NSString *userName = [aNotification userInfo][@"userName"];
        chatVc.title       = userName;
    } else { //如果是群聊
        NSString *groupName = [aNotification userInfo][@"groupName"];
        MLOG(@"群组名字：%@", groupName);
        chatVc.title      = groupName;
        NSString *groupID = [aNotification userInfo][@"groupID"];
        chatVc.groupID    = groupID;
    }
    chatVc.isChatList2Chat = YES;
    [self.navigationController pushViewController:chatVc animated:YES];
}
#pragma - 内容转换      消息
- (void)transformToMessageView:(UIButton *)sender {
    
    if (_lastBtn == sender) {
        return;
    }
   
    [sender setTitleColor:[UIColor colorWithHexString:@"#ffffff"] forState:UIControlStateNormal];
    sender.backgroundColor =[UIColor colorWithHexString:@"#ff5252"];
    [_lastBtn setTitleColor:[UIColor colorWithHexString:@"#ff5252"] forState:UIControlStateNormal];
    _lastBtn.backgroundColor = [UIColor colorWithHexString:@"#ffffff"];
  
   [_mesView removeFromSuperview];
    [_contactView removeFromSuperview];
    [self.view addSubview:_mesView];
  
     _lastBtn = sender;
}

#pragma mark   -好友
- (void)transformToContactList:(UIButton *)sender {
    redDotLabel.hidden = YES;
    
   
    if (_lastBtn == sender) {
        return;
    }

    [sender setTitleColor:[UIColor colorWithHexString:@"#ffffff"] forState:UIControlStateNormal];
    sender.backgroundColor =[UIColor colorWithHexString:@"#ff5252"];
    [_lastBtn setTitleColor:[UIColor colorWithHexString:@"#ff5252"] forState:UIControlStateNormal];
    _lastBtn.backgroundColor =[UIColor colorWithHexString:@"#ffffff"];
  
    [_mesView removeFromSuperview];
   [_contactView removeFromSuperview];
    
    [self.view addSubview:_contactView];
    
    
    _lastBtn = sender;
    
    
    [self  getFriendTag];
    [self getAttentionTag];
    
   }














@end
