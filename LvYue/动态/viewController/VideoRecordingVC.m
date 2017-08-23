//
//  VideoRecordingVC.m
//  LvYue
//
//  Created by X@Han on 17/5/22.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "VideoRecordingVC.h"
#import "WCLRecordEngine.h"
#import "WCLRecordProgressView.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <MediaPlayer/MediaPlayer.h>
#import "SendDyVideoViewController.h"
#import "DXPopover.h"
#import "TopicTagModel.h"
#import "ChatViewController.h"
typedef NS_ENUM(NSUInteger, UploadVieoStyle) {
    VideoRecord = 0,
    VideoLocation,
};
@interface VideoRecordingVC ()<WCLRecordEngineDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITableViewDataSource, UITableViewDelegate>{
    CGFloat _popoverWidth;
    CGFloat _tablewViewHeight;
}
@property (strong, nonatomic)  UIButton *flashLightBT;
@property (strong, nonatomic)  UIButton *changeCameraBT;
@property (strong, nonatomic)  UIButton *recordNextBT;
@property (strong, nonatomic)  UIButton *recordBt;
@property (strong, nonatomic)  UIButton *locationVideoBT;
@property (strong, nonatomic)  UIButton *titleLb;
@property (strong, nonatomic) NSLayoutConstraint *topViewTop;
@property (strong, nonatomic) WCLRecordProgressView *progressView;
@property (strong, nonatomic) WCLRecordEngine         *recordEngine;
@property (assign, nonatomic) BOOL                    allowRecord;//允许录制
@property (assign, nonatomic) UploadVieoStyle         videoStyle;//视频的类型
@property (strong, nonatomic) UIImagePickerController *moviePicker;//视频选择器
@property (strong, nonatomic) MPMoviePlayerViewController *playerVC;
//弹出标签
@property (nonatomic, strong) DXPopover *popover;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *configs;


@end

@implementation VideoRecordingVC

- (void)dealloc {
    _recordEngine = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:[_playerVC moviePlayer]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
//    if (_recordEngine == nil) {
//        [self.recordEngine previewLayer].frame = self.view.bounds;
//        [self.view.layer insertSublayer:[self.recordEngine previewLayer] atIndex:0];
//    }
//    self.recordEngine.maxRecordTime = 30;
//  [self.recordEngine startUp];
    
}



- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.recordEngine shutdown];
     [[UIApplication sharedApplication] setStatusBarHidden:NO];
     [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (_recordEngine == nil) {
       
        
        [self.recordEngine previewLayer].frame = self.view.bounds;
        [self.view.layer insertSublayer:[self.recordEngine previewLayer] atIndex:0];
    }
 
    
    if (_isSenderGiftAsk == NO) {
         self.recordEngine.maxRecordTime = 30;
    }
   
   
    [self.recordEngine startUp];
    
 self.changeCameraBT.selected = YES;
//    self.flashLightBT.selected = YES;
//    [self.recordEngine changeCameraInputDeviceisFront:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    // 博客地址：http://blog.csdn.net/wang631106979/article/details/51498009
    self.view.backgroundColor = [UIColor blackColor];
    self.configs = [[NSMutableArray alloc]init];
    
   
    if ([CommonTool dx_isNullOrNilWithObject:self.selectShareTopicId]) {
         self.selectShareTopicId = @"";
    }
   
    self.allowRecord = YES;
    [self creatUI ];
    if (_isSenderGiftAsk == NO) {
        [self getdata];
    }
   
    [self canVideo];
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
//根据状态调整view的展示情况
- (void)adjustViewFrame {
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        if (self.recordBt.selected) {
            self.topViewTop.constant = -64;
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        }else {
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
            self.topViewTop.constant = 0;
        }
        if (self.videoStyle == VideoRecord) {
            self.locationVideoBT.alpha = 0;
        }
        [self.view layoutIfNeeded];
    } completion:nil];
}

#pragma mark - set、get方法
- (WCLRecordEngine *)recordEngine {
    if (_recordEngine == nil) {
        _recordEngine = [[WCLRecordEngine alloc] init];
        _recordEngine.delegate = self;
        
    }
    return _recordEngine;
}

- (UIImagePickerController *)moviePicker {
    if (_moviePicker == nil) {
        _moviePicker = [[UIImagePickerController alloc] init];
        _moviePicker.delegate = self;
        _moviePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        _moviePicker.mediaTypes = @[(NSString *)kUTTypeMovie];
    }
    return _moviePicker;
}

-(WCLRecordProgressView *)progressView{
    if (_progressView == nil) {
        _progressView = [[WCLRecordProgressView alloc] init];
        _progressView.progressColor = RGBA(202, 141, 141, 1);
        _progressView.progressBgColor = [UIColor whiteColor];
        _progressView.backgroundColor = [UIColor clearColor];
        _progressView.hidden = YES;
    }
    return _progressView;
}

#pragma mark - Apple相册选择代理
//选择了某个照片的回调函数/代理回调
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString*)kUTTypeMovie]) {
        //获取视频的名称
        NSString * videoPath=[NSString stringWithFormat:@"%@",[info objectForKey:UIImagePickerControllerMediaURL]];
        NSRange range =[videoPath rangeOfString:@"trim."];//匹配得到的下标
        NSString *content=[videoPath substringFromIndex:range.location+5];
        //视频的后缀
        NSRange rangeSuffix=[content rangeOfString:@"."];
        NSString * suffixName=[content substringFromIndex:rangeSuffix.location+1];
        //如果视频是mov格式的则转为MP4的
        if ([suffixName isEqualToString:@"MOV"]) {
            NSURL *videoUrl = [info objectForKey:UIImagePickerControllerMediaURL];
            
        
            __weak typeof(self) weakSelf = self;
            [self.recordEngine changeMovToMp4:videoUrl dataBlock:^(UIImage *movieImage) {
                             [weakSelf.moviePicker dismissViewControllerAnimated:YES completion:^{
                                 AVURLAsset *avUrl = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:_recordEngine.videoPath]];
                                 CMTime time = [avUrl duration];
                                 int seconds = ceil(time.value/time.timescale);
                                 if ( seconds > 30) {
                                     [MBProgressHUD  showError:@"上传的视频不能多于30秒哦～"];
                                     _recordEngine.videoPath = @"";
                                     return ;
                                 }
                                 SendDyVideoViewController * vc = [[SendDyVideoViewController alloc]init];
                                 vc.urlPath =  _recordEngine.videoPath ;
                                 [self.navigationController pushViewController:vc animated:YES];

//                    weakSelf.playerVC = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:weakSelf.recordEngine.videoPath]];
//                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playVideoFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:[weakSelf.playerVC moviePlayer]];
//                    [[weakSelf.playerVC moviePlayer] prepareToPlay];
//                    
//                    [weakSelf presentMoviePlayerViewControllerAnimated:weakSelf.playerVC];
//                    [[weakSelf.playerVC moviePlayer] play];
                }];
            }];
        }
    }
}

#pragma mark - WCLRecordEngineDelegate
- (void)recordProgress:(CGFloat)progress {
    if (progress >= 1) {
        [self recordAction:self.recordBt];
        self.allowRecord = NO;
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode =MBProgressHUDModeText;//显示的模式
        hud.labelText = @"只能录制30秒哦～";
        [hud hide:YES afterDelay:1];
        //设置隐藏的时候是否从父视图中移除，默认是NO
        hud.removeFromSuperViewOnHide = YES;
    }
    self.progressView.progress = progress;
}




-(void)creatUI{
         
    UIButton * cacleBtn = [[UIButton alloc]init];
    cacleBtn.frame = CGRectMake(10, 20, 40, 40);
    [cacleBtn setImage:[UIImage imageNamed: @"返回"] forState:UIControlStateNormal];
    [cacleBtn addTarget:self action:@selector(dismissAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cacleBtn];
    
    if (_isSenderGiftAsk == NO) {
        UIButton *titleLb = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2  -50, 20, 100, 40)];
        if ([CommonTool dx_isNullOrNilWithObject:self.selectShareTopicTitle]) {
             [titleLb setTitle:@"#视频标签" forState:UIControlStateNormal];
        }else{
             [titleLb setTitle:self.selectShareTopicTitle forState:UIControlStateNormal];
        }
       
        titleLb.titleLabel.font =  [UIFont systemFontOfSize:15];
        [titleLb setTitleColor:[UIColor colorWithHexString:@"#ffffff"] forState:UIControlStateNormal];
        [titleLb addTarget:self
                    action:@selector(titleShowPopover:)
          forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:titleLb];
        self.titleLb = titleLb;
    }
   
    
    UITableView *blueView = [[UITableView alloc] init];
    blueView.frame = CGRectMake(0,60, _popoverWidth, 350);
    blueView.dataSource = self;
    blueView.delegate = self;
     blueView.backgroundColor = [UIColor clearColor];
    blueView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView = blueView;
    
    [self resetPopover];
    
    
    self.recordBt = [[UIButton alloc]init];
//    self.recordBt.backgroundColor = [UIColor cyanColor];
    self.recordBt.frame = CGRectMake(SCREEN_WIDTH/2  -50, SCREEN_HEIGHT-80-100, 100 , 100);
    //  imageNamed: videoRecord  videoPause
    [self.recordBt setImage:[UIImage imageNamed: @"拍摄按钮"] forState:UIControlStateNormal];
    [self.recordBt setImage:[UIImage imageNamed: @"拍照2icon"] forState:UIControlStateSelected];
    [self.recordBt addTarget:self action:@selector(recordAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.recordBt];
    
    self.recordNextBT = [[UIButton alloc]init];
//    self.recordNextBT.backgroundColor = [UIColor cyanColor];
    self.recordNextBT.frame = CGRectMake(SCREEN_WIDTH  -50, 20, 40 , 40);
    [self.recordNextBT setImage:[UIImage imageNamed: @"videoNext"] forState:UIControlStateNormal];
//    [self.recordNextBT setImage:[UIImage imageNamed: @"videoNext#"] forState:UIControlStateSelected];
    [self.recordNextBT addTarget:self action:@selector(recordNextAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.recordNextBT];
    
    self.changeCameraBT = [[UIButton alloc]init];
//    self.changeCameraBT.backgroundColor = [UIColor cyanColor];
    self.changeCameraBT.frame = CGRectMake(20, SCREEN_HEIGHT-80 , 40 , 80);
    [self.changeCameraBT setImage:[UIImage imageNamed: @"changeCamera"] forState:UIControlStateNormal];
    [self.changeCameraBT addTarget:self action:@selector(changeCameraAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.changeCameraBT];
    
    
    self.flashLightBT = [[UIButton alloc]init];
//    self.flashLightBT.backgroundColor = [UIColor cyanColor];
    self.flashLightBT.frame = CGRectMake(SCREEN_WIDTH-40-20, SCREEN_HEIGHT-80 , 40 , 80);
    [self.flashLightBT setImage:[UIImage imageNamed: @"flashlightOff"] forState:UIControlStateNormal];
    [self.flashLightBT setImage:[UIImage imageNamed: @"flashlightOn"] forState:UIControlStateSelected];
    [self.flashLightBT addTarget:self action:@selector(flashLightAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.flashLightBT];
    
    if (_isSenderGiftAsk == NO) {
        
        self.locationVideoBT = [[UIButton alloc]init];
        //    self.locationVideoBT.backgroundColor = [UIColor cyanColor];
        self.locationVideoBT.frame = CGRectMake(SCREEN_WIDTH/2 -20, SCREEN_HEIGHT-60 , 40 , 40);
        [self.locationVideoBT setImage:[UIImage imageNamed: @"locationVideo"] forState:UIControlStateNormal];
        [self.locationVideoBT addTarget:self action:@selector(locationVideoAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.locationVideoBT];
        
        
    }
    self.progressView.frame = CGRectMake(0, 10, SCREEN_WIDTH, 5);
    [self.view addSubview:self.progressView];
    
}
- (void)resetPopover {
    self.popover = [DXPopover new];
    _popoverWidth = 280.0;
}
- (void)titleShowPopover:(UIButton *)sender {
    [self updateTableViewFrame];
    
    CGPoint startPoint =
    CGPointMake(CGRectGetMidX(sender.frame), CGRectGetMaxY(sender.frame) + 5);
    [self.popover showAtPoint:startPoint
               popoverPostion:DXPopoverPositionDown
              withContentView:self.tableView
                       inView:self.tabBarController.view];
    
    __weak typeof(self) weakSelf = self;
    self.popover.didDismissHandler = ^{
        [weakSelf bounceTargetView:sender];
    };
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.configs.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 0.01;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 0.01;
}
//设置cell的高度
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
        return 50;
}
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    UILabel *textLabel;
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellId];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        textLabel = [[UILabel alloc]init];
        textLabel.font = [UIFont systemFontOfSize:14];
        textLabel.backgroundColor = RGBA(150, 144, 144, 0.3);
        textLabel.layer.cornerRadius = 15;
        textLabel.clipsToBounds = YES;
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.textColor = [UIColor colorWithHexString:@"#ffffff"];
        [cell.contentView addSubview:textLabel];
    }
    cell.backgroundColor = [UIColor clearColor];
    TopicTagModel *model =  self.configs[indexPath.row];
    textLabel.text =[NSString stringWithFormat:@"#%@",model.shareTopicName];
    CGRect size = [textLabel.text boundingRectWithSize:CGSizeMake(_popoverWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil];
    textLabel.frame  = CGRectMake((_popoverWidth-size.size.width)/2 -10, 10, size.size.width+20, 30);
  
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  TopicTagModel *model =  self.configs[indexPath.row];
    self.selectShareTopicId = model.shareTopicId;
     [self.titleLb setTitle:[NSString stringWithFormat:@"#%@",model.shareTopicName] forState:UIControlStateNormal];
    [self.popover dismiss];
}
- (void)updateTableViewFrame {
    CGRect tableViewFrame = self.tableView.frame;
    tableViewFrame.size.width = _popoverWidth;
    self.tableView.frame = tableViewFrame;
    self.popover.contentInset = UIEdgeInsetsZero;
    self.popover.backgroundColor = [UIColor clearColor];
//    self.popover.layer.borderColor = [UIColor colorWithHexString:@"#f5f5f5"].CGColor;
//    self.popover.alpha = 0.9;
//    self.popover.layer.borderWidth = 1;
}

- (void)bounceTargetView:(UIView *)targetView {
    targetView.transform = CGAffineTransformMakeScale(0.9, 0.9);
    [UIView animateWithDuration:0.5
                          delay:0.0
         usingSpringWithDamping:0.3
          initialSpringVelocity:5
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         targetView.transform = CGAffineTransformIdentity;
                     }
                     completion:nil];
}
-(void)initButton:(UIButton*)btn{
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;//使图片和文字水平居中显示
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(btn.imageView.frame.size.height ,-btn.imageView.frame.size.width, 0.0,0.0)];//文字距离上边框的距离增加imageView的高度，距离左边框减少imageView的宽度，距离下边框和右边框距离不变
    [btn setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0,0.0, -btn.titleLabel.bounds.size.width)];//图片距离右边框距离减少图片的宽度，其它不边
}

#pragma mark - 各种点击事件
//返回点击事件
- (void)dismissAction:(id)sender {
    
    if (self.isPopToLastVc== YES) {
          [self.navigationController popViewControllerAnimated:YES];
    }else{
      if(self.isSenderGiftAsk){
        [self.navigationController popViewControllerAnimated:YES];
      }else{
        [self.navigationController popToRootViewControllerAnimated:YES];
      }
    }
}

//开关闪光灯
- (void)flashLightAction:(id)sender {
    if (self.changeCameraBT.selected == NO) {
        self.flashLightBT.selected = !self.flashLightBT.selected;
        if (self.flashLightBT.selected == YES) {
            [self.recordEngine openFlashLight];
        }else {
            [self.recordEngine closeFlashLight];
        }
    }
}

//切换前后摄像头
- (void)changeCameraAction:(id)sender {
    self.changeCameraBT.selected = !self.changeCameraBT.selected;
    if (self.changeCameraBT.selected == YES) {
        //前置摄像头
        [self.recordEngine closeFlashLight];
        self.flashLightBT.selected = NO;
        [self.recordEngine changeCameraInputDeviceisFront:YES];
    }else {
        [self.recordEngine changeCameraInputDeviceisFront:NO];
    }
}

//录制下一步点击事件
- (void)recordNextAction:(id)sender {
    
    
    if (_recordEngine.videoPath.length > 0) {
        __weak typeof(self) weakSelf = self;
        [self.recordEngine stopCaptureHandler:^(UIImage *movieImage) {
//            weakSelf.playerVC = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:weakSelf.recordEngine.videoPath]];
//            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playVideoFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:[weakSelf.playerVC moviePlayer]];
//            [[weakSelf.playerVC moviePlayer] prepareToPlay];
//            
//            [weakSelf presentMoviePlayerViewControllerAnimated:weakSelf.playerVC];
//            [[weakSelf.playerVC moviePlayer] play];
//            
            if (_isSenderGiftAsk == YES) {
               
                [self.navigationController popViewControllerAnimated:NO];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"senderVideo" object:nil userInfo:@{@"senderVideoUrlPath":[NSString stringWithFormat:@"%@",_recordEngine.videoPath]}];
            }else{
                SendDyVideoViewController * vc = [[SendDyVideoViewController alloc]init];
                vc.urlPath =  _recordEngine.videoPath ;
                vc.shareTopicId = self.selectShareTopicId;
                [weakSelf.navigationController pushViewController:vc animated:YES];
            }
            
        }];
    }else {
        NSLog(@"请先录制视频~");
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode =MBProgressHUDModeText;//显示的模式
        hud.labelText = @"请先录制视频~";
        [hud hide:YES afterDelay:1];
        //设置隐藏的时候是否从父视图中移除，默认是NO
        hud.removeFromSuperViewOnHide = YES;
    }
}

//当点击Done按键或者播放完毕时调用此函数
- (void) playVideoFinished:(NSNotification *)theNotification {


//    MPMoviePlayerController *player = [theNotification object];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:player];
//    [player stop];
//    [self.playerVC dismissMoviePlayerViewControllerAnimated];
//    self.playerVC = nil;
}

//本地视频点击视频
- (void)locationVideoAction:(id)sender {
    self.videoStyle = VideoLocation;
    [self.recordEngine shutdown];
    [self presentViewController:self.moviePicker animated:YES completion:nil];
}

//开始和暂停录制事件
- (void)recordAction:(UIButton *)sender {
    if (self.allowRecord) {
        self.videoStyle = VideoRecord;
        self.recordBt.selected = !self.recordBt.selected;
        if (self.recordBt.selected) {
              _progressView.hidden = NO;
            if (self.recordEngine.isCapturing) {
                [self.recordEngine resumeCapture];
            }else {
                if ([self canVideo] == YES) {
                    [self.recordEngine startCapture];
                }
                
            }
        }else {
//            _progressView.hidden = YES;
            [self.recordEngine pauseCapture];
        }
        [self adjustViewFrame];
    }else{
        _progressView.hidden = YES;
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode =MBProgressHUDModeText;//显示的模式
        hud.labelText = @"只能录制30秒哦~";
        [hud hide:YES afterDelay:1];
        //设置隐藏的时候是否从父视图中移除，默认是NO
        hud.removeFromSuperViewOnHide = YES;
 
    }
}

-(void)getdata{
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/cache/getVideoTopic",REQUESTHEADER] andParameter:@{} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        [MBProgressHUD hideHUD];
        
        
        NSArray *arr =successResponse[@"data"];
        [self.configs removeAllObjects];
        for (NSDictionary *dic in arr) {
            TopicTagModel *model = [TopicTagModel createWithModelDic:dic];
            [self.configs addObject:model];
        }
        [self.tableView reloadData];
        
       
        if (arr.count <8) {
             _tablewViewHeight = 51*arr.count;
            self.tableView.frame = CGRectMake(0,60, _popoverWidth, _tablewViewHeight);
        }else{
             _tablewViewHeight = 51*9;
            self.tableView.frame = CGRectMake(0,60, _popoverWidth, _tablewViewHeight);
        }
        
       
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
    
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
