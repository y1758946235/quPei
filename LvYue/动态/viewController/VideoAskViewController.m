//
//  VideoAskViewController.m
//  LvYue
//
//  Created by X@Han on 17/7/26.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "VideoAskViewController.h"
#import "AlterSendGiftView.h"
#define maxNum 30
@interface VideoAskViewController ()<UITextViewDelegate>{
    
    UITextView *_textView;
    UILabel *numLabel; //剩余字数的label；
    UILabel *placeholder;
    
    UIButton * sendGiftAskBtn;
    
    NSString *_giftName;
    NSURL *_giftUrl;
    NSInteger _giftId;
     NSInteger _giftGoldsNum;
    
}
@property (strong, nonatomic) AlterSendGiftView *alterSendGiftView;
@property (nonatomic, strong) UIButton *alterSendGiftScrBtn;
@end

@implementation VideoAskViewController

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
        _alterSendGiftView.frame = CGRectMake(0, SCREEN_HEIGHT-64-_alterSendGiftView.collectionView.frame.size.height-50, SCREEN_WIDTH, _alterSendGiftView.collectionView.frame.size.height);
        
    }
    return _alterSendGiftView;
}
-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"视频问答";
    
    //右上角筛选按钮
    UIButton*  backBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 25)];
    
        [backBtn setTitle:@"返回" forState:UIControlStateNormal];
        [backBtn setTitleColor:[UIColor colorWithHexString:@"#424242"] forState:UIControlStateNormal];
//    [backBtn setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
        backBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    backBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [backBtn addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    [self creatUI];
}

-(void)backClick{
//     [[NSNotificationCenter defaultCenter] postNotificationName:@"dismissToVideoChat" object:nil userInfo:@{@"dismissToVideoChat":@"1"}];
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)creatUI{
    UILabel *askWhatLabel = [[UILabel alloc]init];
    askWhatLabel.frame = CGRectMake(16, 0, SCREEN_WIDTH/2, 40);
    askWhatLabel.text = @"想问TA什么";
    askWhatLabel.font = kFont18;
    askWhatLabel.textColor = [UIColor blackColor];
    [self.view addSubview:askWhatLabel];
    
    

    
    _textView = [[UITextView alloc]initWithFrame:CGRectMake(16, 16+40, SCREEN_WIDTH-32, 200)];
   // _textView.backgroundColor = [UIColor cyanColor];
    _textView.backgroundColor = [UIColor colorWithHexString:@"#ffffff"];
    _textView.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
    _textView.delegate = self;
    _textView.text = @"";
    
    _textView.textColor = [UIColor colorWithHexString:@"#424242"];
    _textView.returnKeyType = UIReturnKeyDone;
    //_textView.returnKeyType = UIReturnKeyDone;
    _textView.keyboardType = UIKeyboardTypeDefault;
    _textView.scrollEnabled = NO;
    
    _textView.autoresizingMask = UIViewAutoresizingFlexibleHeight; //自适应高度
    _textView.dataDetectorTypes = UIDataDetectorTypeAll; //电话号码  网址 地址等都可以显示
    //textView.editable = NO;  //禁止编辑
    [self.view addSubview:_textView];
    
    placeholder               = [[UILabel alloc] init];
    placeholder.translatesAutoresizingMaskIntoConstraints = NO;
    placeholder.text          = @"想聊就去问TA，你们的故事就从这个问题开始";
    placeholder.textAlignment= NSTextAlignmentCenter;
    placeholder.textColor = [UIColor colorWithHexString:@"#bdbdbd"];
    placeholder.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
    placeholder.textAlignment = NSTextAlignmentLeft;
    [_textView addSubview:placeholder];
    //    placeholder.frame = CGRectMake(0*AutoSizeScaleX, 10*AutoSizeScaleY, 288*AutoSizeScaleX, 21*AutoSizeScaleY);
    [_textView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-6-[placeholder]-16-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(placeholder)]];
    [_textView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-16-[placeholder(==12)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(placeholder)]];
    
    
    numLabel = [[UILabel alloc]init];
    numLabel.translatesAutoresizingMaskIntoConstraints = NO;
    numLabel.textColor = [UIColor colorWithHexString:@"#9e9e9e"];
    numLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:13];
    numLabel.text = @"0/30";
    [self.view addSubview:numLabel];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[numLabel(==40)]-22-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(numLabel)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_textView]-18-[numLabel(==12)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_textView,numLabel)]];
    
    UIButton *randomQuestionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    randomQuestionBtn.frame = CGRectMake(16, 200, 120, 30);
    randomQuestionBtn.layer.cornerRadius = 13;
    randomQuestionBtn.clipsToBounds =YES;
    randomQuestionBtn.layer.borderColor =[UIColor colorWithHexString:@"#ff5252"].CGColor;
    randomQuestionBtn.layer.borderWidth = 1;
    [randomQuestionBtn setTitle:@"随机选问题" forState:UIControlStateNormal];
    [randomQuestionBtn setTitleColor:[UIColor colorWithHexString:@"#ff5252"] forState:UIControlStateNormal];
    [randomQuestionBtn addTarget:self action:@selector(getRandomQuestion) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:randomQuestionBtn];
  
    
    
    UILabel *promptLabel = [[UILabel alloc]init];
    promptLabel.frame = CGRectMake(0, SCREEN_HEIGHT-64-50-85, SCREEN_WIDTH, 80);
    promptLabel.numberOfLines = 0;
    promptLabel.text = @"对方录制视频回答即可领取礼物 \n \n如果48小时内未回答，金币将退回你的账户";
    promptLabel.textAlignment = NSTextAlignmentCenter;
    promptLabel.font = kFont14;
    promptLabel.textColor= [UIColor colorWithHexString:@"#424242"];
    [self.view addSubview:promptLabel];
    
    sendGiftAskBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sendGiftAskBtn.frame = CGRectMake(0, SCREEN_HEIGHT-64-50, SCREEN_WIDTH, 50);
    [sendGiftAskBtn setTitle:@"送礼提问" forState:UIControlStateNormal];
    [sendGiftAskBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [sendGiftAskBtn addTarget:self action:@selector(sendGiftAskClick) forControlEvents:UIControlEventTouchUpInside];
    sendGiftAskBtn.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];
     sendGiftAskBtn.userInteractionEnabled = NO;
    [self.view addSubview:sendGiftAskBtn];
    
     UIView *bootView = [[UIView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT-64-50, SCREEN_WIDTH, 50)];
    bootView.backgroundColor = [UIColor whiteColor];
     [self.alterSendGiftScrBtn addSubview:bootView];
    
    UIButton * askAndSendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    askAndSendBtn.frame = CGRectMake(30, 10, SCREEN_WIDTH-60, 30);
    [askAndSendBtn setTitle:@"提问并赠送" forState:UIControlStateNormal];
    [askAndSendBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [askAndSendBtn addTarget:self action:@selector(askAndSender) forControlEvents:UIControlEventTouchUpInside];
//    askAndSendBtn.backgroundColor = RGBA(185, 185, 189, 1);
    askAndSendBtn.layer.cornerRadius = 15;
    askAndSendBtn.clipsToBounds = YES;
    askAndSendBtn.layer.borderColor = [UIColor colorWithHexString:@"#ff5252"].CGColor;
    askAndSendBtn.layer.borderWidth = 1;
    [bootView addSubview:askAndSendBtn];


    [self.view addSubview:self.alterSendGiftScrBtn];
    [self.view bringSubviewToFront:self.alterSendGiftScrBtn];
}

-(void)askAndSender{
    
    if ([CommonTool dx_isNullOrNilWithObject:[NSString stringWithFormat:@"%ld",(long)_giftId]]) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode =MBProgressHUDModeText;//显示的模式
        hud.labelText = @"请选择礼物";
        hud.removeFromSuperViewOnHide =YES;
        [hud hide:YES afterDelay:1];
        return ;
    }
        NSDictionary *dic= @{@"userId":[CommonTool getUserID],@"otherUserId":self.otherId,@"problemContent":_textView.text,@"giftId":[NSString stringWithFormat:@"%ld",(long)_giftId]};
        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/order/addOrderProblem",REQUESTHEADER] andParameter:dic success:^(id successResponse) {
            MLOG(@"结果:%@",successResponse);
            [MBProgressHUD hideHUD];
            if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
    
                 NSNumber *isExistedSendGiftAskNotification = [NSNumber numberWithBool:self.isExistedSendGiftAskNotification];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"senderGiftAsk" object:nil userInfo:@{@"giftImageUrl":[_giftUrl absoluteString],@"giftName":_giftName,@"goldsNum":[NSString stringWithFormat:@"%ld",(long)_giftGoldsNum],@"senderGiftQuestion":_textView.text,@"problemId":[NSString stringWithFormat:@"%@",successResponse[@"data"][@"problemId"]],@"isExistedSendGiftAskNotification":isExistedSendGiftAskNotification}];
                self.alterSendGiftScrBtn.hidden = YES;
                [self.alterSendGiftView removeFromSuperview];
                
                if (self.isFromDyVideoPlayerViewController == YES) {
                    ChatViewController *vc = [[ChatViewController alloc]initWithChatter:[NSString stringWithFormat:@"qp%@",self.otherId]  isGroup:NO] ;
                    vc.title = self.nameStr;
                    [self.navigationController pushViewController:vc animated:YES];
                    
                }else{
//                    [self.navigationController popViewControllerAnimated:YES];
                    [self dismissViewControllerAnimated:YES completion:nil];
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
-(void)getRandomQuestion{
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/cache/getProblemTopic",REQUESTHEADER] andParameter:nil success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        [MBProgressHUD hideHUD];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
           
            _textView.text = [NSString stringWithFormat:@"%@",successResponse[@"data"]];
            //实时显示字数
            numLabel.text = [NSString stringWithFormat:@"%lu/%d", (unsigned long)_textView.text.length,maxNum];
              placeholder.hidden = YES;
            sendGiftAskBtn.userInteractionEnabled = YES;
            sendGiftAskBtn.backgroundColor= [UIColor colorWithHexString:@"#ff5252"];
            [sendGiftAskBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        } else {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];

}

-(void)sendGiftAskClick{
    self.alterSendGiftView.friendID = self.otherId;
    self.alterSendGiftView.userName = self.nameStr;
    self.alterSendGiftView.isSendGiftAsk = YES;
    [self.alterSendGiftView p_loadAccountAmount];
    [self.alterSendGiftView p_loadGift];
    self.alterSendGiftScrBtn.hidden = NO;
    [self.alterSendGiftScrBtn addSubview:self.alterSendGiftView];
    [self.alterSendGiftView senderGiftAskBlock:^(NSString *giftName, NSURL *giftUrl, NSInteger giftId,NSInteger giftGoldsNum) {
        _giftName = giftName;
        _giftUrl = giftUrl;
        _giftId = giftId;
        _giftGoldsNum = giftGoldsNum;
    }];

}
#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    } else {
        return YES;
    }
}

//正在改变
- (void)textViewDidChange:(UITextView *)textView
{
    NSLog(@"%@", textView.text);
    
    placeholder.hidden = YES;
    //实时显示字数
    numLabel.text = [NSString stringWithFormat:@"%lu/%d", (unsigned long)textView.text.length,maxNum];
    
    //字数限制操作
    if (textView.text.length >= maxNum) {
        
        textView.text = [textView.text substringToIndex:maxNum];
        numLabel.text = [NSString stringWithFormat:@"%d/%d", maxNum,maxNum];
        [MBProgressHUD showSuccess:[NSString stringWithFormat:@"字数不能超过%d字哦～～",maxNum]];
        
    }
    //取消按钮点击权限，并显示提示文字
    if (textView.text.length == 0) {
        
        placeholder.hidden = NO;
        
         sendGiftAskBtn.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];;
        sendGiftAskBtn.userInteractionEnabled = NO;
        [sendGiftAskBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }else{
         sendGiftAskBtn.backgroundColor = [UIColor colorWithHexString:@"#ff5252"];
        [sendGiftAskBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        sendGiftAskBtn.userInteractionEnabled = YES;
    }
    
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
