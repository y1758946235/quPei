//
//  VideoKnowViewController.m
//  LvYue
//
//  Created by 广有射怪鸟事 on 15/9/30.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import "VideoKnowViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "VideoCommitViewController.h"
#import "MBProgressHUD+NJ.h"

@interface VideoKnowViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (assign,nonatomic) int isVideo;//是否录制视频，如果为1表示录制视频，0代表拍照
@property (strong,nonatomic) UIImagePickerController *imagePicker;
@property (strong, nonatomic) UIImageView *photo;//照片展示视图
@property (strong ,nonatomic) AVPlayer *player;//播放器，用于录制完视频后播放视频

@end

@implementation VideoKnowViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"视频认证";
    [self createView];
    [[[UIAlertView alloc] initWithTitle:nil message:@"请确认男女性别是否填写正确，视频认证后不允许修改性别。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
    //通过这里设置当前程序是拍照还是录制视频
    _isVideo=YES;
    [self.imagePicker setVideoMaximumDuration:15.f];
}

- (void)createView{
    UILabel *forLabel = [[UILabel alloc] init];
    forLabel.center = CGPointMake(kMainScreenWidth / 2, 130);
    forLabel.bounds = CGRectMake(0, 0, kMainScreenWidth - 40, 120);
    forLabel.textAlignment = NSTextAlignmentCenter;
    forLabel.font = [UIFont systemFontOfSize:14.0];
    forLabel.numberOfLines = 0;
    forLabel.text = @"为了真实性、安全性，用户通过手机录制并上传一段简短的自拍视频作为形象视频，工作人员会尽快审核认证，并作为更换形象视频的参照。\n我们努力保障用户认证的真实，但不排除误判的可能性，虽然这种可能性被降到极低的概率，因为您是理解这种认证方法的。";
    [self.view addSubview:forLabel];
    
    UIView *bgView = [[UIView alloc] init];
    bgView.frame = CGRectMake(forLabel.frame.origin.x, forLabel.frame.origin.y + 110, forLabel.frame.size.width, 50);
    bgView.backgroundColor = RGBACOLOR(245, 245, 245, 1);
    [self.view addSubview:bgView];
    
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, bgView.frame.size.width, bgView.frame.size.height)];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.font = [UIFont systemFontOfSize:14.0];
    tipLabel.text = @"温馨提示：请保持室内光线充足。";
    tipLabel.textColor = RGBACOLOR(198, 138, 95, 1);
    [bgView addSubview:tipLabel];
    
    UIButton *caImg = [[UIButton alloc] init];
    [caImg setCenter:CGPointMake(kMainScreenWidth / 2, bgView.frame.origin.y + 140)];
    [caImg setBounds:CGRectMake(0, 0, 75, 75) ];
    [caImg setImage:[UIImage imageNamed:@"camera-2"] forState:UIControlStateNormal];
    [caImg addTarget:self action:@selector(videoKnow) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:caImg];
    
    UILabel *startLabel = [[UILabel alloc] init];
    startLabel.center = CGPointMake(kMainScreenWidth / 2, caImg.frame.origin.y + 150);
    startLabel.bounds = CGRectMake(0, 0, 70, 30);
    startLabel.textAlignment = NSTextAlignmentCenter;
    startLabel.font = [UIFont systemFontOfSize:14.0];
    startLabel.text = @"开始认证";
    [self.view addSubview:startLabel];
}


#pragma mark 摄像头
#pragma mark - UI事件
//点击拍照按钮

- (void)videoKnow{
    [[[UIAlertView alloc] initWithTitle:@"" message:@"请将摄像头对准您的脸部，最短5秒，最长15秒，15秒后会自动结束，视频数据仅供审核" delegate:self cancelButtonTitle:@"好的" otherButtonTitles: nil] show];
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}


#pragma mark - UIImagePickerController代理方法
//完成
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [MBProgressHUD showMessage:@"请稍后"];
    NSString *mediaType=[info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {//如果是拍照
        UIImage *image;
        //如果允许编辑则获得编辑后的照片，否则获取原始照片
        if (self.imagePicker.allowsEditing) {
            image=[info objectForKey:UIImagePickerControllerEditedImage];//获取编辑后的照片
        }else{
            image=[info objectForKey:UIImagePickerControllerOriginalImage];//获取原始照片
        }
        [self.photo setImage:image];//显示照片
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);//保存到相簿
    }else if([mediaType isEqualToString:(NSString *)kUTTypeMovie]){//如果是录制视频
        NSURL *url=[info objectForKey:UIImagePickerControllerMediaURL];//视频路径
        NSString *urlStr=[url path];
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(urlStr)) {
            //保存视频到相簿，注意也可以使用ALAssetsLibrary来保存
            UISaveVideoAtPathToSavedPhotosAlbum(urlStr, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);//保存视频到相簿
        }
        
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 私有方法
- (UIImagePickerController *)imagePicker{
    if (!_imagePicker) {
        _imagePicker=[[UIImagePickerController alloc]init];
        _imagePicker.sourceType=UIImagePickerControllerSourceTypeCamera;//设置image picker的来源，这里设置为摄像头
        _imagePicker.cameraDevice=UIImagePickerControllerCameraDeviceRear;//设置使用哪个摄像头，这里设置为后置摄像头
        if (self.isVideo) {
            _imagePicker.mediaTypes=@[(NSString *)kUTTypeMovie];
            _imagePicker.videoQuality=UIImagePickerControllerQualityTypeMedium;
            _imagePicker.cameraCaptureMode=UIImagePickerControllerCameraCaptureModeVideo;//设置摄像头模式（拍照，录制视频）
            
        }else{
            _imagePicker.cameraCaptureMode=UIImagePickerControllerCameraCaptureModePhoto;
        }
        _imagePicker.allowsEditing=YES;//允许编辑
        _imagePicker.delegate=self;//设置代理，检测操作
    }
    return _imagePicker;
}

//视频保存后的回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error) {
        NSLog(@"保存视频过程中发生错误，错误信息:%@",error.localizedDescription);
    }else{
        VideoCommitViewController *commit = [[VideoCommitViewController alloc] init];
        commit.urlPath = videoPath;
        [self.navigationController pushViewController:commit animated:YES];
        //录制完之后自动播放
        NSURL *url=[NSURL fileURLWithPath:videoPath];
        _player=[AVPlayer playerWithURL:url];
        AVPlayerLayer *playerLayer=[AVPlayerLayer playerLayerWithPlayer:_player];
        playerLayer.frame=self.photo.frame;
        [self.photo.layer addSublayer:playerLayer];
    }
}

@end
