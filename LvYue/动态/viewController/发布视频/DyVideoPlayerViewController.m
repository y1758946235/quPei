//
//  DyVideoPlayerViewController.m
//  LvYue
//
//  Created by X@Han on 17/6/6.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "DyVideoPlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "SRVideoPlayer.h"
#import "MyInfoVC.h"
#import "otherZhuYeVC.h"
#import "UMSocial.h"
#import "reportVC.h"
#import "UMSocialQQHandler.h"
#import "AlterSendGiftView.h"
#import "CallViewController.h"
#import "EMCDDeviceManager.h"
#import "ChatSendHelper.h"
#import "VideoAskViewController.h"
#import "DyVideoPlayerTableViewCell.h"
#import "DyVideoPlayDetailTableViewCell.h"
#import "DyVideoPlayerDetailModel.h"
#import "DyVideoPlayerFirHeadView.h"
#define SRVideoPlayerImageName(fileName) [@"SRVideoPlayer.bundle" stringByAppendingPathComponent:fileName]

//static NSString *const LYMeViewControllerShareTitle = @"趣陪，出售您的空余时间，向导大家旅行、寻找美食、搭伴健身..除了能带给您经济收入外，互动的过程还能互相深入了解，交到真正、合适的各方朋友，他、她正在趣陪等您..";
//static NSString *const LYMeViewControllerShareText  = @"我分享了一个APP应用，快来看看吧~\n\n——尽在\"趣陪\"App";
@interface DyVideoPlayerViewController ()<UMSocialUIDelegate,UIActionSheetDelegate,EMCallManagerDelegate,EMCDDeviceManagerDelegate,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>{
    NSString *  LYMeViewControllerShareTitle;
     NSString *  LYMeViewControllerShareText;
    
    UIView *playerView;
    
    NSInteger currentPage;  //当前页数
    UITextField *messTF;
    
    UIButton *_commentsBtn;
    UIButton *_PraiseBtn;
    UIButton *_senderGiftBtn;
    UIButton *_askBtn;
    UIButton *_videoChatBtn;
    
    UILabel *_sendMessLabel;
    UILabel *_PraiseNumLabel;
    UILabel *_videoChatLabel;
    
    NSString *  praiseNum;
    
    BOOL isLike;
     BOOL isFreeVideoChat;
    
    
}

@property (nonatomic, strong) SRVideoPlayer *videoPlayer;
@property (nonatomic, strong) UIButton *closeBtn;

@property (nonatomic, strong) UIView *topBarView;
@property (nonatomic, strong) UIButton *focusBtn;

@property (nonatomic, strong) UIView *bottomBarView;
//@property (nonatomic, strong) UIView *sendMessAndPraView;
@property (strong, nonatomic) AlterSendGiftView *alterSendGiftView;
@property (nonatomic, strong) UIButton *alterSendGiftScrBtn;

@property (nonatomic, strong) UIView *alterView;
@property (nonatomic, strong) UIButton *scrBtn;


@property (nonatomic, copy) NSString *accountAmount; // 账户余额
@property (strong, nonatomic) NSString *videoAmount;// 视频聊天需要的金币

@property(nonatomic,copy)NSMutableArray *dataArr;

@property (nonatomic, strong) UITableView *myTableView;
@end

@implementation DyVideoPlayerViewController


//- (UIView *)sendMessAndPraView {
//    
//    if (!_sendMessAndPraView) {
//        _sendMessAndPraView= [[UIView alloc]init];
//        _sendMessAndPraView.frame = CGRectMake(0, SCREEN_HEIGHT-50*AutoSizeScaleX, SCREEN_WIDTH, 50*AutoSizeScaleX);
//        //        _bottomBarView.backgroundColor = [UIColor cyanColor];
//        _sendMessAndPraView.userInteractionEnabled = YES;
//    }
//    return _sendMessAndPraView;
//}

-(UITableView *)myTableView {
    if (!_myTableView) {
        _myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStylePlain ];
        
        [_myTableView registerClass:[DyVideoPlayDetailTableViewCell class] forCellReuseIdentifier:@"DyVideoPlayDetailTableViewCell"];
        [_myTableView registerClass:[DyVideoPlayerTableViewCell class] forCellReuseIdentifier:@"DyVideoPlayerTableViewCell"];
          [_myTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        _myTableView.delegate = self;
        _myTableView.dataSource = self;
        _myTableView.backgroundColor = [UIColor whiteColor];
        
    }
    
    return _myTableView;
}
- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [[NSMutableArray alloc]init];
    }
    
    return _dataArr;
}
- (UIButton *)scrBtn {
    
    if (!_scrBtn) {
        _scrBtn = [[UIButton alloc]init];
        _scrBtn.hidden =YES;
        _scrBtn.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        _scrBtn.frame = CGRectMake(0,0 , SCREEN_WIDTH, SCREEN_HEIGHT);
        [_scrBtn addTarget:self action:@selector(hidAlterView) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _scrBtn;
}
-(void)hidAlterView{
    self.scrBtn.hidden =YES;
}
- (UIView *)alterView {
    
    if (!_alterView) {
        _alterView = [[UIView alloc]init];
        _alterView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 0);
        _alterView.backgroundColor = [UIColor colorWithHexString:@"ffffff"];
     
    }
    return _alterView;
}

- (UIButton *)alterSendGiftScrBtn {
    
    if (!_alterSendGiftScrBtn) {
        _alterSendGiftScrBtn = [[UIButton alloc]init];
        _alterSendGiftScrBtn.hidden =YES;
        _alterSendGiftScrBtn.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        _alterSendGiftScrBtn.frame = CGRectMake(0,0 , SCREEN_WIDTH, SCREEN_HEIGHT);
        [_alterSendGiftScrBtn addTarget:self action:@selector(hidGiftView) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _alterSendGiftScrBtn;
}
-(void)hidGiftView{
    [self.alterSendGiftView removeFromSuperview];
    self.alterSendGiftScrBtn.hidden =YES;
}
- (AlterSendGiftView *)alterSendGiftView {
    if (!_alterSendGiftView) {
        _alterSendGiftView = [[AlterSendGiftView alloc]init];
        _alterSendGiftView.frame = CGRectMake(0, SCREEN_HEIGHT-_alterSendGiftView.collectionView.frame.size.height, SCREEN_WIDTH, _alterSendGiftView.collectionView.frame.size.height);
        
    }
    return _alterSendGiftView;
}
- (UIView *)bottomBarView {
    
    if (!_bottomBarView) {
        _bottomBarView= [[UIView alloc]init];
        _bottomBarView.frame = CGRectMake(0, SCREEN_HEIGHT-70, SCREEN_WIDTH, 70);
//        _bottomBarView.backgroundColor = [UIColor cyanColor];
        _bottomBarView.userInteractionEnabled = YES;
    }
    return _bottomBarView;
}
- (UIView *)topBarView {
    
    if (!_topBarView) {
        _topBarView = [[UIView alloc]init];
        _topBarView.frame = CGRectMake(0, 10, SCREEN_WIDTH, 40);
        _topBarView.userInteractionEnabled = YES;
        _topBarView.backgroundColor = [UIColor clearColor];
    }
    return _topBarView;
}

- (UIButton *)closeBtn {
    
    if (!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeBtn.showsTouchWhenHighlighted = YES;
        _closeBtn.frame = CGRectMake(SCREEN_WIDTH-40, 0, 40, 40);
//        [_closeBtn setImage:[UIImage imageNamed:SRVideoPlayerImageName(@"close")] forState:UIControlStateNormal];
        [_closeBtn setImage:[UIImage imageNamed:@"叉叉"] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(closeBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}
-(void)viewWillAppear:(BOOL)animated{
  
    [self.alterSendGiftView p_loadAccountAmount];
    [self.navigationController setNavigationBarHidden:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
   
    if (_videoPlayer.playerState == SRVideoPlayerStatePaused) {
        [_videoPlayer play];
    }
}


-(void)viewWillDisappear:(BOOL)animated{
 
   
    [self.navigationController setNavigationBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    if (_videoPlayer.playerState == SRVideoPlayerStatePlaying) {
        [_videoPlayer pause];
    }
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (CGFloat)randomValue {
    return arc4random()%255 / 255.0f;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    for (UIView *view in self.view.subviews) {
        [view removeFromSuperview];
    }
  
    
      messTF = [[UITextField alloc]init];
    
    self.view.backgroundColor = [UIColor blackColor];
     self.view.backgroundColor = [UIColor colorWithRed:[self randomValue] green:[self randomValue] blue:[self randomValue] alpha:1];
    [self.view addSubview:self.myTableView];
   
  

    if ([CommonTool dx_isNullOrNilWithObject:self.shareContentStr]) {
        self.shareContentStr = @"    ";
    }
    LYMeViewControllerShareTitle = [NSString  stringWithFormat:@"%@",self.shareContentStr];
    LYMeViewControllerShareText =[NSString stringWithFormat:@"%@的趣陪视频：%@",self.nameStr,self.shareContentStr];
   
   
    
   

    [self showVideoPlayer];
    [self creatTopUI];
   
//    if (![[NSString stringWithFormat:@"%@",self.otherId] isEqualToString:[CommonTool getUserID]]) {
         [self getVideoOption];
        
//    }
//    [self  creatSendmessAndPra];
    [self getFouseData];
    [self getVideoAmount];
    
  [self getdata];
 
        [EMCDDeviceManager sharedInstance].delegate = self;
 
     [[EaseMob sharedInstance].callManager removeDelegate:self];
    [[EaseMob sharedInstance].callManager addDelegate:self delegateQueue:nil];
    
    [self registNotifi];
    
    
    
}


#pragma mark  ---获取视频功能开关
- (void)getVideoOption{
    
    // NSString *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userId"];
    
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/video/getVideoOption1",REQUESTHEADER] andParameter:nil success:^(id successResponse) {
        
        NSLog(@"0000000000000:%@",successResponse);
        
        
        if ([[NSString stringWithFormat:@"%@",successResponse[@"data"]] isEqualToString:@"1"]) {
            //开启
            
            
            NSArray *arr = @[@"评论-2",@"点赞",@"视频-礼物",@"话筒",@"视频111"];
            NSArray *titeArr = @[@"",@"",@"",@"",@""];
            [self creatBottonViewArr:arr titArr:titeArr];
        }else{
            NSArray *arr = @[@"评论-2",@"点赞",@"视频-礼物",@"话筒"];
            NSArray *titeArr = @[@"",@"",@"",@""];
            [self creatBottonViewArr:arr titArr:titeArr];
        }
        
    } andFailure:^(id failureResponse) {
        NSArray *arr = @[@"评论-2",@"点赞",@"视频-礼物",@"话筒",@"视频111"];
        NSArray *titeArr = @[@"",@"",@"",@"",@""];
        [self creatBottonViewArr:arr titArr:titeArr];
    }];
    
}

-(void)creatBottonViewArr:(NSArray *)imageArr titArr:(NSArray *)titleArr{
    [self.alterSendGiftScrBtn removeFromSuperview];
    [self.view addSubview:self.alterSendGiftScrBtn];
    
    for (UIView *view in self.bottomBarView.subviews) {
        [view removeFromSuperview];
    }
    for (int i = 0; i < imageArr.count; i++) {
        UIButton *giftAndVideoChatBtn = [[UIButton alloc]init];
        giftAndVideoChatBtn.frame = CGRectMake((SCREEN_WIDTH-40*imageArr.count)/(imageArr.count +1) +((SCREEN_WIDTH-40*imageArr.count)/(imageArr.count +1) +40)*i, 0, 40, 70);
        //        giftAndVideoChatBtn.backgroundColor = [UIColor cyanColor];
        [giftAndVideoChatBtn setImage:[UIImage imageNamed:imageArr[i]] forState:UIControlStateNormal];
        [giftAndVideoChatBtn setTitle:titleArr[i] forState:UIControlStateNormal];
        [giftAndVideoChatBtn setTitleColor:[UIColor colorWithHexString:@"#ffffff"] forState:UIControlStateNormal];
        giftAndVideoChatBtn.titleLabel.font = kFont12;
        giftAndVideoChatBtn.tag = 1000+i;
        [giftAndVideoChatBtn addTarget:self action:@selector(giftOrChatClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomBarView addSubview:giftAndVideoChatBtn];
        
        
        CGSize imgViewSize,titleSize,btnSize;
        
        UIEdgeInsets imageViewEdge,titleEdge;
        
        CGFloat heightSpace = 10.0f;
        
        
        
        //设置按钮内边距
        
        imgViewSize = giftAndVideoChatBtn.imageView.bounds.size;
        
        titleSize = giftAndVideoChatBtn.titleLabel.bounds.size;
        
        btnSize = giftAndVideoChatBtn.bounds.size;
        
        
        
        imageViewEdge = UIEdgeInsetsMake(heightSpace,0.0, btnSize.height -imgViewSize.height - heightSpace, - titleSize.width);
        
        [giftAndVideoChatBtn setImageEdgeInsets:imageViewEdge];
        
        titleEdge = UIEdgeInsetsMake(imgViewSize.height +heightSpace, - imgViewSize.width-15, 0.0, 0.0);
        
        [giftAndVideoChatBtn setTitleEdgeInsets:titleEdge];
        
        
        if (i == 0) {
            _commentsBtn = giftAndVideoChatBtn;
            _sendMessLabel =[[UILabel alloc]init];
            _sendMessLabel.frame = CGRectMake(0, 34, 40, 30);
            _sendMessLabel.textColor= [UIColor colorWithHexString:@"#ffffff"];
            _sendMessLabel.font = kFont12;
            _sendMessLabel.text = @"评论";
            _sendMessLabel.textAlignment = NSTextAlignmentCenter;
            [_commentsBtn addSubview:_sendMessLabel];
            
        }
        if (i == 1) {
            _PraiseBtn = giftAndVideoChatBtn;
            _PraiseNumLabel =[[UILabel alloc]init];
            _PraiseNumLabel.frame = CGRectMake(0, 34, 40, 30);
            _PraiseNumLabel.textColor= [UIColor colorWithHexString:@"#ffffff"];
            _PraiseNumLabel.font = kFont12;
            _PraiseNumLabel.text = @"点赞";
            _PraiseNumLabel.textAlignment = NSTextAlignmentCenter;
            [_PraiseBtn addSubview:_PraiseNumLabel];
        }
        if (i == 2) {
            _senderGiftBtn = giftAndVideoChatBtn;
            //            _senderGiftBtn.hidden = YES;
            
            UILabel * videoChatLabel =[[UILabel alloc]init];
            videoChatLabel.frame = CGRectMake(0, 34, 40, 30);
            videoChatLabel.text = @"送礼";
            videoChatLabel.textColor= [UIColor colorWithHexString:@"#ffffff"];
            videoChatLabel.font = kFont12;
            videoChatLabel.textAlignment = NSTextAlignmentCenter;
            [_senderGiftBtn addSubview:videoChatLabel];
        }
        if (i == 3) {
            _askBtn = giftAndVideoChatBtn;
            
            UILabel * videoChatLabel =[[UILabel alloc]init];
            videoChatLabel.frame = CGRectMake(0, 34, 40, 30);
            videoChatLabel.text = @"提问";
            videoChatLabel.textColor= [UIColor colorWithHexString:@"#ffffff"];
            videoChatLabel.font = kFont12;
            videoChatLabel.textAlignment = NSTextAlignmentCenter;
            [_askBtn addSubview:videoChatLabel];
            
            
        }
        if (i == 4) {
         
            _videoChatBtn = giftAndVideoChatBtn;
            
            UILabel * videoChatLabel =[[UILabel alloc]init];
            videoChatLabel.frame = CGRectMake(0, 34, 40, 30);
            videoChatLabel.text = @"视频聊";
            videoChatLabel.textColor= [UIColor colorWithHexString:@"#ffffff"];
            videoChatLabel.font = kFont12;
            videoChatLabel.textAlignment = NSTextAlignmentCenter;
            [_videoChatBtn addSubview:videoChatLabel];
        }
    }

    
    
    if ([[NSString stringWithFormat:@"%@",self.otherId] isEqualToString:[CommonTool getUserID]]) {
        _senderGiftBtn.hidden = YES;
        _askBtn.hidden = YES;
        _videoChatBtn.hidden = YES;
    }else{
        _senderGiftBtn.hidden = NO;
        _askBtn.hidden = NO;
        _videoChatBtn.hidden = NO;
    }
    
    
}



-(void)registNotifi{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(senderGiftAsk:) name:@"senderGiftAsk" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callControllerClose:) name:@"callControllerClose" object:nil];
    
    //监听键盘出现和消失
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendMessAndPraViewHide:) name:@"sendMessAndPraViewHide" object:nil];
}

- (void)sendMessAndPraViewHide:(NSNotification *)notification
{
    
    if ([notification.userInfo[@"isHide"] isEqualToString:@"1"]) {
         self.bottomBarView.hidden = YES;
    }else{
         self.bottomBarView.hidden = NO;
    }
   
}
- (void)callControllerClose:(NSNotification *)notification
{
    if (_videoPlayer.playerState == SRVideoPlayerStatePaused) {
        [_videoPlayer play];
    }
}

#pragma mark - 送礼提问
-(void)senderGiftAsk:(NSNotification *)aNotification {
    if ([[aNotification userInfo][@"isExistedSendGiftAskNotification"] boolValue] ==NO) {
        NSString *giftName = [aNotification userInfo][@"giftName"];
        NSLog(@"giftName---%@",giftName);
        NSNumber *is_receive_null_mesasge = [NSNumber numberWithBool:NO];
        
        NSDictionary *dic =  @{@"avatar":[CommonTool getUserIcon],@"nick":[CommonTool getUserNickname],@"senderGiftAskTextMessageType":@"senderGiftAskTextMessageType",@"is_receive_null_mesasge":is_receive_null_mesasge,@"giftImageUrl":[aNotification userInfo][@"giftImageUrl"],@"giftName":[aNotification userInfo][@"giftName"],@"goldsNum":[aNotification userInfo][@"goldsNum"],@"senderGiftQuestion":[aNotification userInfo][@"senderGiftQuestion"],@"problemId":[aNotification userInfo][@"problemId"]};
        //       senderGiftAskExt =  @{@"avatar":[CommonTool getUserIcon],@"nick":[CommonTool getUserNickname],@"senderGiftAskTextMessageType":@"senderGiftAskTextMessageType",@"giftImageUrl":@"giftUrl",@"giftName":@"giftName",@"senderGiftQuestion":@"senderGiftQuestion"};
        [self sendSenderGiftAskTextMessage:[NSString  stringWithFormat:@"收到神秘礼物"] dic:dic];
    }
   
}
//发送 送礼的问题
- (void)sendSenderGiftAskTextMessage:(NSString *)textMessage  dic:(NSDictionary *)dic{
    
    
   
   [ChatSendHelper sendTextMessageWithString:textMessage
                                                            toUsername:[NSString stringWithFormat:@"qp%@",self.otherId]
                                                           messageType:eMessageTypeChat
                                                     requireEncryption:NO
                                                                   ext:dic];
   
}


-(void)clickView{
    if (_videoPlayer.playerState == SRVideoPlayerStatePaused) {
        [_videoPlayer resume];
    }
}
//-(void)creatBottonView{
//    [self.alterSendGiftScrBtn removeFromSuperview];
//  [self.view addSubview:self.alterSendGiftScrBtn];
//    NSArray *arr = @[@"礼物1",@"话筒／麦克风",@"视频咨询"];
//    for (int i = 0; i < 3; i++) {
//        UIButton *giftAndVideoChatBtn = [[UIButton alloc]init];
//        giftAndVideoChatBtn.frame = CGRectMake((SCREEN_WIDTH-210*AutoSizeScaleX)/4 +((SCREEN_WIDTH-210*AutoSizeScaleX)/4 +70*AutoSizeScaleX)*i, 0, 70*AutoSizeScaleX, 70*AutoSizeScaleX);
//        [giftAndVideoChatBtn setImage:[UIImage imageNamed:arr[i]] forState:UIControlStateNormal];
//        [self.bottomBarView addSubview:giftAndVideoChatBtn];
//        giftAndVideoChatBtn.tag = 1000+i;
//        [giftAndVideoChatBtn addTarget:self action:@selector(giftOrChatClick:) forControlEvents:UIControlEventTouchUpInside];
//    }
//    
//    
//    
//   
//}
//-(void)creatBottonView222{
//    [self.alterSendGiftScrBtn removeFromSuperview];
//    [self.view addSubview:self.alterSendGiftScrBtn];
//    NSArray *arr = @[@"礼物1",@"话筒／麦克风"];
//    for (int i = 0; i < arr.count; i++) {
//        UIButton *giftAndVideoChatBtn = [[UIButton alloc]init];
//        giftAndVideoChatBtn.frame = CGRectMake((SCREEN_WIDTH-210*AutoSizeScaleX)/4 +((SCREEN_WIDTH-210*AutoSizeScaleX)/4 +70*AutoSizeScaleX)*i, 0, 70*AutoSizeScaleX, 70*AutoSizeScaleX);
//        [giftAndVideoChatBtn setImage:[UIImage imageNamed:arr[i]] forState:UIControlStateNormal];
//        [self.bottomBarView addSubview:giftAndVideoChatBtn];
//        giftAndVideoChatBtn.tag = 1000+i;
//        [giftAndVideoChatBtn addTarget:self action:@selector(giftOrChatClick:) forControlEvents:UIControlEventTouchUpInside];
//    }
//    
//    
//    
//    
//}

//-(void)creatSendmessAndPra{
//    UIButton *sendMessBtn = [[UIButton alloc]init];
//    sendMessBtn.center = CGPointMake(SCREEN_WIDTH/8 +2*AutoSizeScaleX, 15*AutoSizeScaleX);
//    sendMessBtn.bounds = CGRectMake(0, 0, 15*AutoSizeScaleX, 15*AutoSizeScaleX);
//    //  sendMessBtn.frame = CGRectMake((SCREEN_WIDTH/2  -40*AutoSizeScaleX)/3 , 90*AutoSizeScaleX, 20*AutoSizeScaleX, 20*AutoSizeScaleX);
//    [sendMessBtn setImage:[UIImage imageNamed:@"ic_video_play_send_msg_white"] forState:UIControlStateNormal];
//    [self.sendMessAndPraView addSubview:sendMessBtn];
//    [sendMessBtn addTarget:self action:@selector(messClick:) forControlEvents:UIControlEventTouchUpInside];
//    
//    UIButton *PraiseBtn = [[UIButton alloc]init];
//    //    PraiseBtn.backgroundColor = [UIColor cyanColor];
//    PraiseBtn.center = CGPointMake(SCREEN_WIDTH/4 +SCREEN_WIDTH/8 +2*AutoSizeScaleX, 15*AutoSizeScaleX);
//    PraiseBtn.bounds = CGRectMake(0, 0, 15*AutoSizeScaleX, 15*AutoSizeScaleX);
//    //    PraiseBtn.frame = CGRectMake((SCREEN_WIDTH/2  -40*AutoSizeScaleX)/3 +((SCREEN_WIDTH/2-40*AutoSizeScaleX)/3 +40*AutoSizeScaleX), 90*AutoSizeScaleX, 20*AutoSizeScaleX, 20*AutoSizeScaleX);
//    //ic_video_play_like_white_liked
//    [PraiseBtn setImage:[UIImage imageNamed:@"ic_video_play_like_white"] forState:UIControlStateNormal];
//    [self.sendMessAndPraView addSubview:PraiseBtn];
//    _PraiseBtn = PraiseBtn;
//    [PraiseBtn addTarget:self action:@selector(PraiseClick:) forControlEvents:UIControlEventTouchUpInside];
//    
//    
//    UILabel *sendMessLabel = [[UILabel alloc]init];
//    sendMessLabel.frame = CGRectMake(0, 26*AutoSizeScaleX, SCREEN_WIDTH/4, 20*AutoSizeScaleX);
//    sendMessLabel.font = kFont12;
//    sendMessLabel.textAlignment = NSTextAlignmentCenter;
//    sendMessLabel.textColor = [UIColor colorWithHexString:@"bdbdbd"];
//    [self.sendMessAndPraView addSubview:sendMessLabel];
//    _sendMessLabel = sendMessLabel;
//    
//    UILabel *PraiseNumLabel = [[UILabel alloc]init];
//    //    PraiseNumLabel.backgroundColor = [UIColor cyanColor];
//    PraiseNumLabel.frame = CGRectMake(SCREEN_WIDTH/4, 26*AutoSizeScaleX, SCREEN_WIDTH/4, 20*AutoSizeScaleX);
//    PraiseNumLabel.font = kFont12;
//    PraiseNumLabel.textAlignment = NSTextAlignmentCenter;
//    PraiseNumLabel.textColor = [UIColor colorWithHexString:@"bdbdbd"];
//    [self.sendMessAndPraView addSubview:PraiseNumLabel];
//    _PraiseNumLabel = PraiseNumLabel;
//
//}
-(void)giftOrChatClick:(UIButton *)sender{
    if (sender.tag == 1000) {
        
        [messTF becomeFirstResponder];//弹出键盘
        
        NSIndexPath
        *scrollIndexPath = [NSIndexPath
                            
                            indexPathForRow:0
                            
                            inSection:1];
        [self.myTableView scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
    }else if (sender.tag == 1001) {
        
        if (isLike == YES) {
            [self deleteVideoLike];
        }else{
            [self addVideoLike];
        }
        
        
    }else if (sender.tag == 1002) {
        
//        NSString *NewId = [_conversation.chatter substringFromIndex:2];// 由于是环信的id 所以改成用户ID
        self.alterSendGiftView.friendID = self.otherId;
        self.alterSendGiftView.userName = self.nameStr;
        [self.alterSendGiftView p_loadAccountAmount];
        [self.alterSendGiftView p_loadGift];
        self.alterSendGiftScrBtn.hidden = NO;
        [self.alterSendGiftScrBtn addSubview:self.alterSendGiftView];
        [self.alterSendGiftView giftInfoBlock:^(NSString *giftName, NSURL *giftUrl, NSString *giftGoldsNum) {
            [self.alterSendGiftView removeFromSuperview];
             self.alterSendGiftScrBtn.hidden = YES;
            
            
            NSDictionary *dic =  @{@"avatar":[CommonTool getUserIcon],@"nick":[CommonTool getUserNickname],@"giftTextMessageType":@"giftTextMessageType",@"giftImageUrl":[giftUrl absoluteString],@"giftName":giftName,@"goldsNum":giftGoldsNum};
            [self sendGiftTextMessage:[NSString  stringWithFormat:@"我送给你一个%@，快去礼物列表查看吧",giftName] dic:dic];

        }];
    }else  if (sender.tag == 1003) {
     
        VideoAskViewController*vc = [[VideoAskViewController alloc]init];
        vc.otherId =self.otherId;
        vc.nameStr = self.nameStr;
        vc.isFromDyVideoPlayerViewController = YES;
//        [self.navigationController pushViewController:vc animated:NO];

        RootNavigationController *nav = [[RootNavigationController alloc]initWithRootViewController:vc];
        [self presentViewController:nav animated:YES completion:nil];

        
    }else{
       
    
        
        [self getUserFreeVideo];
        [self addOrderVideoTime];
    }
   

}

//发送礼物
- (void)sendGiftTextMessage:(NSString *)textMessage dic:(NSDictionary *)dic{
    
    [ChatSendHelper sendTextMessageWithString:textMessage
                                   toUsername:[NSString stringWithFormat:@"qp%@",self.otherId]
                                  messageType:eMessageTypeChat
                            requireEncryption:NO
                                          ext:dic];
}
//免费次数
-(void)getUserFreeVideo{
    
    
    //服务器获取图片
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/order/getUserFreeVideo", REQUESTHEADER] andParameter:@{
                                                                                                                                      @"userId": [CommonTool getUserID]}
                                success:^(id successResponse) {
                                    MLOG(@"结果:%@", successResponse);
                                    if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
                                        if ([[NSString stringWithFormat:@"%@", successResponse[@"data"]] isEqualToString:@"1"]) {
                                            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"视频聊天" message:@"您有一次免费视频聊体验 祝您交到有趣的朋友！ " delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                                            isFreeVideoChat = YES;
                                            alertView.tag = 1006;
                                            [alertView show];
                                            
                                        }else{
                                           isFreeVideoChat = NO;
                                            [self getUserIsOpenVideoChat];
                                        }
                                        
                                        
                                        
                                    } else {
                                        [MBProgressHUD hideHUD];
                                        [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"errorMsg"]]];
                                    }
                                }
                             andFailure:^(id failureResponse) {
                                 [MBProgressHUD hideHUD];
                                 [MBProgressHUD showError:@"服务器繁忙,请重试"];
                             }];
    
}


-(void)messClick:(UIButton *)sender{
  
   [messTF becomeFirstResponder];//弹出键盘
    
    
  
   
    
    
        NSIndexPath
        *scrollIndexPath = [NSIndexPath
                            
                            indexPathForRow:0
                            
                            inSection:1];
          [self.myTableView scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
   

    
}
-(void)PraiseClick:(UIButton *)sender{
    
    if (isLike == YES) {
        [self deleteVideoLike];
    }else{
        [self addVideoLike];
    }
   
}
//点赞
-(void)addVideoLike{
    
    
 
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/video/addVideoLike", REQUESTHEADER] andParameter:@{
                                                                                                                                       @"userId": [NSString stringWithFormat:@"%@",[CommonTool getUserID]],@"videoId": [NSString stringWithFormat:@"%@",self.videoId] }
                                success:^(id successResponse) {
                                    
                                    if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
                                         [_PraiseBtn setImage:[UIImage imageNamed:@"点赞-红色"] forState:UIControlStateNormal];
                                        
                                        isLike = YES;
                                        NSInteger num = [praiseNum integerValue] +1;
                                        praiseNum = [NSString stringWithFormat:@"%d",num];
                                        _PraiseNumLabel.text = praiseNum;
                                    }
                                }
                             andFailure:^(id failureResponse) {
                                 [MBProgressHUD hideHUD];
                                 [MBProgressHUD showError:@"服务器繁忙,请重试"];
                             }];
}
//取消点赞
-(void)deleteVideoLike{
    
    
    
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/video/deleteVideoLike", REQUESTHEADER] andParameter:@{
                                                                                                                                  @"userId": [NSString stringWithFormat:@"%@",[CommonTool getUserID]],@"videoId": [NSString stringWithFormat:@"%@",self.videoId] }
                                success:^(id successResponse) {
                                    
                                    if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
                                        [_PraiseBtn setImage:[UIImage imageNamed:@"点赞"] forState:UIControlStateNormal];
                                       isLike = NO;
                                        NSInteger num = [praiseNum integerValue] - 1;
                                        praiseNum = [NSString stringWithFormat:@"%d",num];
                                        _PraiseNumLabel.text = praiseNum;
  
                                    }
                                }
                             andFailure:^(id failureResponse) {
                                 [MBProgressHUD hideHUD];
                                 [MBProgressHUD showError:@"服务器繁忙,请重试"];
                             }];
}

//这里只是为了记录下点击次数
-(void)addOrderVideoTime{
    
    
    //_callSession.type == eCallSessionTypeVideo
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/order/addOrderVideoTime", REQUESTHEADER] andParameter:@{
                                                                                                                                       @"userId": [NSString stringWithFormat:@"%@",[CommonTool getUserID]],@"otherUserId": [NSString stringWithFormat:@"%@",self.otherId],@"videoTime":@"-1" }
                                success:^(id successResponse) {
                                    
                                    if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
                                        
                                    }
                                }
                             andFailure:^(id failureResponse) {
                                 [MBProgressHUD hideHUD];
                                 [MBProgressHUD showError:@"服务器繁忙,请重试"];
                             }];
}




-(void)getUserIsOpenVideoChat{
   
    
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/video/getUserVideoInstall",REQUESTHEADER] andParameter:@{@"userId":self.otherId} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        [MBProgressHUD hideHUD];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            
            NSString * isVideo= successResponse[@"data"][@"isVideo"];
            if ([[NSString  stringWithFormat:@"%@",isVideo] isEqualToString:@"1"]) {
                
                NSString* str =[NSString stringWithFormat:@"温馨提示：视频聊天每分钟消耗%@金币",successResponse[@"data"][@"videoGold"]];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"视频聊天" message:str delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                alertView.tag = 1005;
                [alertView show];
//                [self getUserAccountAmount];
                
            }else{
                [MBProgressHUD  showError:@"对方未开通视频聊服务哦"];
            }
        } else {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
    
}

#pragma mark --获取用户的视频所需要对方的金币
-(void)getVideoAmount{
    
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/video/getUserVideoInstall", REQUESTHEADER] andParameter:@{@"userId":[NSString stringWithFormat:@"%@",self.otherId]}
                                success:^(id successResponse) {
                                    
                                    if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
                                        self.videoAmount =[NSString stringWithFormat:@"%@", successResponse[@"data"][@"videoGold"]] ;
                                    } else {
                                        
                                        [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"errorMsg"]]];
                                    }
                                }
                             andFailure:^(id failureResponse) {
                                 [MBProgressHUD hideHUD];
                                 [MBProgressHUD showError:@"服务器繁忙,请重试"];
                             }];
}
#pragma mark --获取用户的金币余额
#pragma mark - Pravite


- (void)getUserAccountAmount {
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/getUserPower", REQUESTHEADER]
                           andParameter:@{
                                          @"userId": [CommonTool getUserID]
                                          }
                                success:^(id successResponse) {
                                    MLOG(@"结果:%@", successResponse);
                                    if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
                                        self.accountAmount = [NSString stringWithFormat:@"%@", successResponse[@"data"][@"userGold"]];
                                        if ([self.accountAmount integerValue]>= [self.videoAmount integerValue]  && self.videoAmount) {
                                            [self getUserVideoDisturb];
                                        }else{
                                            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"充值金币" message:@"金币不足，无法发起视频聊天" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去充值", nil];
                                            alertView.tag = 1002;
                                            [alertView show];
                                            
                                        }
                                    } else {
                                        [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"errorMsg"]]];
                                    }
                                }
                             andFailure:^(id failureResponse) {
                                 [MBProgressHUD showError:@"查询余额失败，请重试"];
                             }];
}




-(void)getUserVideoDisturb{
//    NSString *NewId = [_conversation.chatter substringFromIndex:2];// 由于是环信的id 所以改成用户ID
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/video/getUserVideoInstall",REQUESTHEADER] andParameter:@{@"userId":self.otherId} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        [MBProgressHUD hideHUD];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            NSString * disturbStr= successResponse[@"data"][@"disturbTime"];
            if (disturbStr.length > 0) {
                
                
                NSArray*    disturbArr = [disturbStr componentsSeparatedByString:@","];
                  if ([CommonTool  isBetweenFromHour:[disturbArr[0] integerValue] FromMinute:0 toHour:[disturbArr[1] integerValue]  toMinute:0] == YES) {
                
                    [MBProgressHUD showError:@"对方设置了视频免打扰时间哦"];
                }else{
                    
                    [self openTheVideo];}
            }else{
                [self openTheVideo];
            }
        } else {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
    
    
}
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1002) {
        if (1 == buttonIndex) {
            MyMoneyVC *myMoney = [[MyMoneyVC alloc] init];
            [self.navigationController pushViewController:myMoney animated:YES];
        }
    }
    
    WS(weakSelf)
    if (alertView.tag == 1005) {
        if (1 == buttonIndex) {
            [weakSelf getUserAccountAmount];
            
        }
    }
    
 
    if (alertView.tag == 1006) {
        if (1 == buttonIndex) {
            [self openTheVideo];
            
        }
    }
}
#pragma mark 打开视频
-(void)openTheVideo{
   
    BOOL isopen = [self canVideo];//判断能否打开摄像头,(太多,详见demo)
    EMError *error = nil;
    EMCallSession *callSession = nil;
    if (!isopen) {
        NSLog(@"不能打开视频");
        return ;
    }
    //这里发送异步视频请求
    callSession = [[EaseMob sharedInstance].callManager asyncMakeVideoCall:[NSString  stringWithFormat:@"qp%@",self.otherId] timeout:50 error:&error];
    //请求完以后,开始做下面的
    if (callSession && !error) {
         [_videoPlayer pause];
          [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"isNoShowCallViewAgain"];
        [[EaseMob sharedInstance].callManager removeDelegate:self];
        CallViewController *callController = [[CallViewController alloc] initWithSession:callSession isIncoming:NO];
        callController.modalPresentationStyle = UIModalPresentationOverFullScreen;
        callController.senderId = [CommonTool getUserID];
        callController.receivId = self.otherId;
        callController.isFreeVideoChat = isFreeVideoChat;
        [self presentViewController:callController animated:NO completion:nil];
    }
    
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", @"error") message:error.description delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
        [alertView show];
        alertView = nil;
    }
}

-(BOOL)canVideo{
    BOOL canvideo = YES;
    NSString *mediaType = AVMediaTypeVideo;// Or AVMediaTypeAudio
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    NSLog(@"---cui--authStatus--------%d",authStatus);
    // This status is normally not visible—the AVCaptureDevice class methods for discovering devices do not return devices the user is restricted from accessing.
    if(authStatus ==AVAuthorizationStatusRestricted){//此应用程序没有被授权访问的照片数据。可能是家长控制权限。
        NSLog(@"Restricted");
        canvideo = NO;
        return canvideo;
    }else if(authStatus == AVAuthorizationStatusDenied){//用户已经明确否认了这一照片数据的应用程序访问.
        // The user has explicitly denied permission for media capture.
        NSLog(@"Denied");     //应该是这个，如果不允许的话
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"请在设备的\"设置-隐私-相机\"中允许访问相机。"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        alert = nil;
        canvideo = NO;
        return canvideo;
    }
    else if(authStatus == AVAuthorizationStatusAuthorized){//允许访问,用户已授权应用访问照片数据.
        // The user has explicitly granted permission for media capture, or explicit user permission is not necessary for the media type in question.
        NSLog(@"Authorized");
        canvideo = YES;
        return canvideo;
    }else if(authStatus == AVAuthorizationStatusNotDetermined){//用户尚未做出了选择这个应用程序的问候
        // Explicit user permission is required for media capture, but the user has not yet granted or denied such permission.
        [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {//请求访问照相功能.
            //应该在打开视频前就访问照相功能,不然下面返回不了值啊.
            if(granted){//点击允许访问时调用
                //用户明确许可与否，媒体需要捕获，但用户尚未授予或拒绝许可。
                NSLog(@"Granted access to %@", mediaType);
                
            }
            else {
                NSLog(@"Not granted access to %@", mediaType);
            }
        }];
    }else {
        NSLog(@"Unknown authorization status");
        canvideo = NO;
    }
    return canvideo;
}

-(void)creatAlterView{
    
//    [self.view addSubview:self.scrBtn];
//    [self.scrBtn addSubview:self.alterView];
    NSArray *arr = @[@"微信好友",@"朋友圈",@"QQ",@"QQ空间",@"微博",@"举报"];
    NSArray *imagrArr =  @[@"微信-1",@"朋友圈-4",@"QQ-2",@"QQ空间",@"sina-2",@"举报"];
    for (int i = 0; i < 6; i ++) {
        UIButton *button = [[UIButton alloc]init];
        button.frame = CGRectMake((SCREEN_WIDTH/3) *(i%3), 100*(i/3), SCREEN_WIDTH/3, 100);
        button.tag = 1000+i;
        [button setTitle:arr[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithHexString:@"#424242"] forState:UIControlStateNormal];
        button.titleLabel.font =[UIFont systemFontOfSize:14];
        [button setImage:[UIImage  imageNamed:imagrArr[i]] forState:UIControlStateNormal];
        [self.alterView addSubview:button];
        [CommonTool initButton:button];
        [button addTarget:self action:@selector(shareClick:) forControlEvents:UIControlEventTouchUpInside];
        
        
    }
    
}
-(void)shareClick:(UIButton *)sender{
     self.scrBtn.hidden = YES;
    

   
    
  
    switch (sender.tag) {
        case 1000:{
          
            [UMSocialData defaultData].extConfig.wechatSessionData.title  = LYMeViewControllerShareTitle;
            [UMSocialData defaultData].extConfig.wechatSessionData.url    = [NSString stringWithFormat:@"%@/mobile/shareVideo.html?videoId=%@", REQUESTHEADER,self.videoId];
            [[UMSocialDataService defaultDataService] postSNSWithTypes:@[UMShareToWechatSession] content:LYMeViewControllerShareText image:[CommonTool  thumbnailImageForVideo:self.videoURL atTime:1] location:nil urlResource:nil presentedController:self completion:^(UMSocialResponseEntity *response) {
                if (response.responseCode == UMSResponseCodeSuccess) {
                    NSLog(@"cheggong");}
            }];

        }
            
            break;
            
        case 1001:{
            [UMSocialData defaultData].extConfig.wechatTimelineData.title  = LYMeViewControllerShareTitle;
            [UMSocialData defaultData].extConfig.wechatTimelineData.url    = [NSString stringWithFormat:@"%@/mobile/shareVideo.html?videoId=%@", REQUESTHEADER,self.videoId];
            
            [[UMSocialDataService defaultDataService] postSNSWithTypes:@[UMShareToWechatTimeline] content:LYMeViewControllerShareText image:[CommonTool  thumbnailImageForVideo:self.videoURL atTime:1] location:nil urlResource:nil presentedController:self completion:^(UMSocialResponseEntity *response) {
                if (response.responseCode == UMSResponseCodeSuccess) {
                    NSLog(@"cheggong");}
            }];

           
        }
            
            break;
            
        case 1002:{
          
            [UMSocialData defaultData].extConfig.qqData.title  =  LYMeViewControllerShareText;
            
            [UMSocialData defaultData].extConfig.qqData.url    = [NSString stringWithFormat:@"%@/mobile/shareVideo.html?videoId=%@", REQUESTHEADER,self.videoId];
            UIImage *image = [CommonTool  thumbnailImageForVideo:self.videoURL atTime:1];
            NSData *data =UIImageJPEGRepresentation(image, 1.0);
            //[[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding]
            
         [[UMSocialData defaultData].urlResource setResourceType:UMSocialUrlResourceTypeVideo url:[[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding]];
//            [[UMSocialData defaultData].urlResource setResourceType:UMSocialUrlResourceTypeImage url:@"some url"];
            [[UMSocialDataService defaultDataService] postSNSWithTypes:@[UMShareToQQ] content:LYMeViewControllerShareTitle image:[CommonTool  thumbnailImageForVideo:self.videoURL atTime:1]location:nil urlResource:nil presentedController:self completion:^(UMSocialResponseEntity *response) {
                if (response.responseCode == UMSResponseCodeSuccess) {
                    NSLog(@"cheggong");}
            }];
           
        }
            
            break;
            
        case 1003:{
            [UMSocialData defaultData].extConfig.qzoneData.title  = LYMeViewControllerShareText;
            [UMSocialData defaultData].extConfig.qzoneData.url    = [NSString stringWithFormat:@"%@/mobile/shareVideo.html?videoId=%@", REQUESTHEADER,self.videoId];
            UIImage *image = [CommonTool  thumbnailImageForVideo:self.videoURL atTime:1];
            NSData *data =UIImageJPEGRepresentation(image, 1.0);
            //[[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding]
            
            [[UMSocialData defaultData].urlResource setResourceType:UMSocialUrlResourceTypeVideo url:[[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding]];
            [[UMSocialDataService defaultDataService] postSNSWithTypes:@[UMShareToQzone] content:LYMeViewControllerShareTitle image:[CommonTool  thumbnailImageForVideo:self.videoURL atTime:1] location:nil urlResource:nil presentedController:self completion:^(UMSocialResponseEntity *response) {
                if (response.responseCode == UMSResponseCodeSuccess) {
                    NSLog(@"cheggong");}
            }];

        }
            
            break;
            
        case 1004:{
           
         
            
            [[UMSocialDataService defaultDataService] postSNSWithTypes:@[UMShareToSina] content:[NSString stringWithFormat:@"%@%@/mobile/shareVideo.html?videoId=%@",LYMeViewControllerShareText,REQUESTHEADER,self.videoId] image:[CommonTool  thumbnailImageForVideo:self.videoURL atTime:1] location:nil urlResource:nil presentedController:self completion:^(UMSocialResponseEntity *response) {
                if (response.responseCode == UMSResponseCodeSuccess) {
                    NSLog(@"cheggong");}
            }];

        }
            
            break;
            
        case 1005:{
            //举报
            reportVC *report = [[reportVC alloc]init];
            report.otherUserId = self.otherId;
            [self.navigationController pushViewController:report animated:YES];
        }
            break;
            
        default:
            break;
    }

}
-(void)creatTopUI{

    for (UIView *view in self.topBarView.subviews) {
        [view removeFromSuperview];
    }
    [self.topBarView addSubview:self.closeBtn];
    
    UIImageView *headImageV = [[UIImageView alloc]init];
    headImageV.frame = CGRectMake(10, 0, 40, 40);
    headImageV.layer.cornerRadius = 20;
    headImageV.layer.masksToBounds = YES;
    headImageV.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoOtherVC)];
    [headImageV addGestureRecognizer:tap];
      [self.topBarView addSubview:headImageV];
    [headImageV sd_setImageWithURL:[NSURL URLWithString:self.headUrlStr] placeholderImage:nil];
    
    UILabel *nameLabel = [[UILabel alloc]init];
    nameLabel.frame = CGRectMake(60, 0, 200, 25);
    nameLabel.font = [UIFont systemFontOfSize:14];
    nameLabel.textColor = [UIColor colorWithHexString:@"#ffffff"];
    nameLabel.text = self.nameStr;
      [self.topBarView addSubview:nameLabel];
    CGSize size = [self.nameStr sizeWithFont:nameLabel.font constrainedToSize:CGSizeMake(120, nameLabel.frame.size.height)];
    nameLabel.frame =CGRectMake(60, 0, size.width, 25);
    
    UIButton *focusBtn  = [[UIButton alloc]init];
    focusBtn.frame = CGRectMake(60+10+size.width, 7.5, 50, 25);
    focusBtn.layer.cornerRadius = 12.5;
    focusBtn.layer.borderWidth = 0.5;
    focusBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    focusBtn.layer.borderColor = [UIColor colorWithHexString:@"#ffffff"].CGColor;
    [focusBtn setTitleColor:[UIColor colorWithHexString:@"#ffffff"] forState:UIControlStateNormal];
    [focusBtn setTitle:@"关 注" forState:UIControlStateNormal];
    [focusBtn addTarget:self action:@selector(focusClick) forControlEvents:UIControlEventTouchUpInside];
    self.focusBtn = focusBtn;
    
    
    //导航栏   删除 按钮
    UIButton *edit = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-56-24-16, 0, 18+32, 40)];
    //    edit.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    edit.imageEdgeInsets = UIEdgeInsetsMake(6, 18, 6, 18);
    [edit setImage:[UIImage imageNamed:@"more-4"] forState:UIControlStateNormal];
    [self.topBarView addSubview:edit];
    [edit addTarget:self  action:@selector(actionClick) forControlEvents:UIControlEventTouchUpInside];
}
-(void)actionClick{
    
//    self.scrBtn.hidden = NO;
//    self.alterView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH,0);
//    [UIView animateWithDuration:0.5 animations:^{
//        self.alterView.frame = CGRectMake(0, SCREEN_HEIGHT-200, SCREEN_WIDTH, 200);
//    }];
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"操作" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"分享",@"举报", nil];
    [action showInView:self.view];
}

#pragma mark uiactionsheet 代理

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
            
        case 0:
        {
           [self shareVideoClick];
          
            
        }
            break;
            
        case 1:
        {
            //举报
            reportVC *report = [[reportVC alloc]init];
            report.otherUserId = self.otherId;
            [self.navigationController pushViewController:report animated:YES];
        }
            break;
            
        default:
            break;
    }
}

-(void)shareVideoClick{
#pragma mark   ------ 分享好友------
    LYMeViewControllerShareTitle = [NSString  stringWithFormat:@"%@",self.shareContentStr];
    LYMeViewControllerShareText =[NSString stringWithFormat:@"%@的趣陪视频：%@",self.nameStr,self.shareContentStr];
    
    
   
        //设置微信
        [UMSocialData defaultData].extConfig.wechatSessionData.title  = LYMeViewControllerShareTitle;
        [UMSocialData defaultData].extConfig.wechatTimelineData.title = LYMeViewControllerShareTitle;
        [UMSocialData defaultData].extConfig.wechatSessionData.url    = [NSString stringWithFormat:@"%@/mobile/shareVideo.html?videoId=%@", REQUESTHEADER,self.videoId];
        [UMSocialData defaultData].extConfig.wechatTimelineData.url   = [NSString stringWithFormat:@"%@/mobile/shareVideo.html?videoId=%@", REQUESTHEADER,self.videoId];
        
        //设置新浪微博
        [[UMSocialData defaultData].urlResource setResourceType:UMSocialUrlResourceTypeImage url:[NSString stringWithFormat:@"%@/mobile/shareVideo.html?videoId=%@", REQUESTHEADER,self.videoId]];
        
        
        //设置QQ
        [UMSocialData defaultData].extConfig.qqData.title    = LYMeViewControllerShareTitle;
        [UMSocialData defaultData].extConfig.qzoneData.title = LYMeViewControllerShareTitle;
        [UMSocialData defaultData].extConfig.qqData.url      = [NSString stringWithFormat:@"%@/mobile/shareVideo.html?videoId=%@", REQUESTHEADER,self.videoId];
        [UMSocialData defaultData].extConfig.qzoneData.url   = [NSString stringWithFormat:@"%@/mobile/shareVideo.html?videoId=%@", REQUESTHEADER,self.videoId];
        
        //分享
        [UMSocialSnsService presentSnsIconSheetView:self appKey:@"55f3983c67e58e502a00167d" shareText:LYMeViewControllerShareText shareImage:[CommonTool  thumbnailImageForVideo:self.videoURL atTime:1] shareToSnsNames:[NSArray arrayWithObjects:UMShareToWechatTimeline, UMShareToWechatSession, UMShareToSina, UMShareToQQ, UMShareToQzone, nil] delegate:self];
    
//    //分享
//    [UMSocialSnsService presentSnsController:self appKey:@"55f3983c67e58e502a00167d" shareText:LYMeViewControllerShareText shareImage:[UIImage imageNamed:@"videoRecord"] shareToSnsNames:[NSArray arrayWithObjects:UMShareToWechatTimeline, UMShareToWechatSession, UMShareToSina, UMShareToQQ, UMShareToQzone, nil] delegate:self];
 
}


-(void)focusClick{
    if ([[NSString stringWithFormat:@"%@",self.otherId] isEqual:[CommonTool getUserID]]) {
        
    }else{
        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/circle/addAttention",REQUESTHEADER] andParameter:@{@"userId":[CommonTool getUserID],@"otherUserId":self.otherId} success:^(id successResponse) {
            
            if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
                [self.focusBtn  removeFromSuperview];
                [MBProgressHUD showSuccess:@"关注成功!"];
               
            }
            
        } andFailure:^(id failureResponse) {
            
        }];}
}


- (void)getFouseData{
    if ([[NSString stringWithFormat:@"%@",self.otherId] isEqual:[CommonTool getUserID]]) {
        
    }else{
    NSString *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userId"];
    
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/circle/getAttention",REQUESTHEADER] andParameter:@{@"userId":userId,@"otherUserId":[NSString stringWithFormat:@"%@",self.otherId]} success:^(id successResponse) {
        NSLog(@"关注:%@",successResponse);
        
        NSArray *arr = successResponse[@"data"];
        
        
        if ( ![CommonTool dx_isNullOrNilWithObject:arr]&& arr.count > 0) {
            
            

        }
        else{
            [self.topBarView addSubview:self.focusBtn];
            
           
        }
        
        
    } andFailure:^(id failureResponse) {
        
    }];}
}

-(void)gotoOtherVC{
    
//    [_videoPlayer pause];
    if ([[NSString stringWithFormat:@"%@",self.otherId] isEqualToString:[CommonTool  getUserID]]) {
        
        MyInfoVC *inVC = [[MyInfoVC alloc]init];
        
        [self.navigationController pushViewController:inVC animated:YES];
    }else{
        
        otherZhuYeVC *other = [[otherZhuYeVC alloc]init];
        other.userId = self.otherId;
        other.userNickName = self.nameStr;
        other.isExistedSendGiftAskNotification = YES;
        [self.navigationController pushViewController:other animated:YES];}
    

}
- (void)closeBtnAction {
    
     [_videoPlayer destroyPlayer];
    [self.navigationController popViewControllerAnimated:YES];
   
}
- (void)showVideoPlayer {
    
  
    
  playerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
   
    playerView.center = self.view.center;
    playerView.superview.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    [self.view addSubview:playerView];
   
   
   
    _videoPlayer = [SRVideoPlayer playerWithVideoURL:_videoURL playerView:playerView playerSuperView:playerView.superview];
    _videoPlayer.videoName = @"Here Is The Video Name";
    _videoPlayer.playerEndAction = SRVideoPlayerEndActionLoop;
    [_videoPlayer play];
    
}





- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
           return 0.01;
    }else{
      return 0;
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    if (section == 0) {
        return 0.01;
    }else{
        return 50;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return 1;
    }else{
       
        return self.dataArr.count +1;
        
       
        
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 ) {
        DyVideoPlayerTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"DyVideoPlayerTableViewCell" forIndexPath:indexPath];
        for (UIView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
        cell.contentView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        [cell.contentView addSubview:playerView];
        [cell.contentView addSubview:self.bottomBarView];
        
       
      
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    }else{
        
        if (indexPath.row == 0) {
            
            UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UILabel *scdTitLabel = [[UILabel alloc]init];
            scdTitLabel.frame = CGRectMake(SCREEN_WIDTH- 24-150, 0, 150, 50);
            scdTitLabel.textAlignment = NSTextAlignmentRight;
            scdTitLabel.text = @"最新评论";
            scdTitLabel.font = kFont15;
            scdTitLabel.textColor = [UIColor colorWithHexString:@"#424242"];
            [cell.contentView addSubview:scdTitLabel];
            return cell;

        }else{
            
            DyVideoPlayDetailTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"DyVideoPlayDetailTableViewCell" forIndexPath:indexPath];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

            if (self.dataArr.count > 0) {
                
                
                DyVideoPlayerDetailModel *aModel = self.dataArr[indexPath.row-1];
                
                [cell creatModel:aModel];
                }
            
            return cell;

        }
       
       
    
        return  nil;
    }
}
//设置cell的高度
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return SCREEN_HEIGHT;
    }else{
        if (indexPath.row == 0) {
             return 50;
        }else{
            DyVideoPlayerDetailModel *model = [self.dataArr objectAtIndex:indexPath.row-1];
            return 90+ model.contLabelHeight;
        }
        
    }
  
   
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        DyVideoPlayerFirHeadView *headView = [[DyVideoPlayerFirHeadView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0)];
        headView.backgroundColor = [UIColor clearColor];
        
        [headView addSubview:self.topBarView];
        return headView;
    }else{
        
        UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0)];
        headView.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];
        
              return headView;

    }
    
}


-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section ==1) {
        UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
        headView.backgroundColor = [UIColor whiteColor];
        
        
      
        messTF.frame = CGRectMake(20, 0, SCREEN_WIDTH-40, 50);
        messTF.delegate = self;
        messTF.placeholder = @"发布评论";
        messTF.font = kFont15;
        messTF.returnKeyType = UIReturnKeySend;
        [headView addSubview:messTF];
        for (int i = 0; i < 2; i ++) {
            UILabel *lineLabel= [[UILabel alloc]init];
            lineLabel.frame = CGRectMake(0, i*49, SCREEN_WIDTH, 0.5);
            lineLabel.backgroundColor = RGBA(211, 213, 214, 1);
            [headView addSubview:lineLabel];
        }
        
        return headView;
    }
    return nil;
}
-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
   [messTF resignFirstResponder];
    return indexPath;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    // 获取开始拖拽时tableview偏移量
    [messTF resignFirstResponder];
}
#pragma mark 键盘出现
-(void)keyboardWillShow:(NSNotification *)note
{
    CGRect keyBoardRect=[note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.myTableView.contentInset = UIEdgeInsetsMake(0, 0, keyBoardRect.size.height, 0);
}
#pragma mark 键盘消失
-(void)keyboardWillHide:(NSNotification *)note
{
    self.myTableView.contentInset = UIEdgeInsetsZero;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];

    if (textField.text.length >0) {
        [self addVideoComment];
    }else{
        [MBProgressHUD showError:@"请填写评论内容"];
    }
    return YES;
}

- (void)addVideoComment {
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/video/addVideoComment", REQUESTHEADER]
                           andParameter:@{
                                          @"userId": [CommonTool getUserID],@"videoId":self.videoId,@"videoComment":messTF.text
                                          }
                                success:^(id successResponse) {
                                    MLOG(@"结果:%@", successResponse);
                                    if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
                                        messTF.text = @"";
                                        [self getdata];
                                } else {
                                    [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"errorMsg"]]];
                                }
     }
                             andFailure:^(id failureResponse) {
                                 [MBProgressHUD showError:@"网络似乎出现了点问题"];
                             }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self.view endEditing:YES];
//    [UIView animateWithDuration:0.3 animations:^{
//        self.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
//    }];
}


-(void)getdata{
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/video/getVideoDetailByVideoId",REQUESTHEADER] andParameter:@{@"userId":[NSString stringWithFormat:@"%@",[CommonTool getUserID]],@"videoId":[NSString stringWithFormat:@"%@",self.videoId],@"type":@""} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        [MBProgressHUD hideHUD];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            
            if ([[NSString stringWithFormat:@"%@",successResponse[@"data"][@"isLike"]] isEqualToString:@"1"]) {
                [_PraiseBtn setImage:[UIImage imageNamed:@"点赞-红色"] forState:UIControlStateNormal];
                isLike = YES;
            }else{
                [_PraiseBtn setImage:[UIImage imageNamed:@"点赞"] forState:UIControlStateNormal];
                isLike = NO;
                
            }
            
           
           
            [self.dataArr removeAllObjects];
            NSArray *arr =successResponse[@"data"][@"videoCommentList"];
            praiseNum =[NSString stringWithFormat:@"%@",successResponse[@"data"][@"likeNumber"]];
            if ([CommonTool dx_isNullOrNilWithObject:[NSString stringWithFormat:@"%@",successResponse[@"data"][@"likeNumber"]] ]) {
                //                [_PraiseBtn setTitle:@"点赞" forState:UIControlStateNormal];
                _PraiseNumLabel.text = @"点赞";
            }else{
                //                [_PraiseBtn setTitle:[NSString stringWithFormat:@"%@",successResponse[@"data"][@"likeNumber"]] forState:UIControlStateNormal];
                _PraiseNumLabel.text = [NSString stringWithFormat:@"%@",successResponse[@"data"][@"likeNumber"]];
            }
            
            if (arr.count == 0) {
                //                  [_commentsBtn setTitle:@"评论" forState:UIControlStateNormal];
                _sendMessLabel.text = @"评论";
            }else{
                //                  [_commentsBtn setTitle:[NSString stringWithFormat:@"%lu",(unsigned long)arr.count] forState:UIControlStateNormal];
                _sendMessLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)arr.count];
            }


            for (NSDictionary * dic in arr) {
                DyVideoPlayerDetailModel *model =[DyVideoPlayerDetailModel createWithModelDic:dic];
                [self.dataArr addObject:model];
            }
            
            // This block code is in child thread.
            // So program have to update UI in ‘main thread’.
            dispatch_async(dispatch_get_main_queue(), ^{
              
                [self.myTableView reloadData];
            });
           
            
        } else {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
    
}
-(void)reloadData{
    
    [_videoPlayer destroyPlayer];
    
    _videoPlayer = [SRVideoPlayer playerWithVideoURL:_videoURL playerView:playerView playerSuperView:playerView.superview];
    [_videoPlayer play];
    [self creatTopUI];
    [self getdata];
    
    if ([CommonTool dx_isNullOrNilWithObject:self.shareContentStr]) {
        self.shareContentStr = @"    ";
    }
    LYMeViewControllerShareTitle = [NSString  stringWithFormat:@"%@",self.shareContentStr];
    LYMeViewControllerShareText =[NSString stringWithFormat:@"%@的趣陪视频：%@",self.nameStr,self.shareContentStr];
 
    [self getFouseData];
    [self getVideoAmount];
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
