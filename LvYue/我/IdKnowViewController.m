//
//  IdKnowViewController.m
//  LvYue
//
//  Created by 广有射怪鸟事 on 15/9/30.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import "IdKnowViewController.h"
#import "MBProgressHUD+NJ.h"
//多媒体拾取器框架
#import "IQMediaPickerController.h"
#import "IQFileManager.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <MediaPlayer/MediaPlayer.h>
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "QiniuSDK.h"
#import "FinishKnowViewController.h"

@interface IdKnowViewController ()<IQMediaPickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate>

@property (nonatomic,strong) NSMutableArray *imageArray;
@property (nonatomic,strong) UIButton *btn;
@property (nonatomic,strong) UIButton *btn2;

//保存媒体拾取类型
@property (nonatomic, assign) IQMediaPickerControllerMediaType mediaType;

@property (assign,nonatomic) int isVideo;//是否录制视频，如果为1表示录制视频，0代表拍照
@property (strong,nonatomic) UIImagePickerController *imagePicker;

@end

@implementation IdKnowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageArray = [[NSMutableArray alloc] init];
    
    self.title = @"身份认证";
    self.view.backgroundColor = [UIColor whiteColor];
    [self createView];
    
    //通过这里设置当前程序是拍照还是录制视频
    _isVideo=YES;
}

- (void)createView{
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:self.view.frame];
    scroll.contentSize = CGSizeMake(0, kMainScreenHeight);
    
    UILabel *whyLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 10, 200, 20)];
    whyLabel.text = @"为什么要身份认证?";
    whyLabel.font = [UIFont systemFontOfSize:14.0];
    whyLabel.textColor = RGBACOLOR(149, 149, 149, 1);
    [scroll addSubview:whyLabel];
    
    UILabel *sbLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, kMainScreenWidth, 20)];
    sbLabel.text = @"彼此信任是成为好友的第一步！";
    sbLabel.font = [UIFont systemFontOfSize:14.0];
    sbLabel.textAlignment = NSTextAlignmentCenter;
    sbLabel.textColor = [UIColor blackColor];
    [scroll addSubview:sbLabel];
    
    UILabel *swearLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 70, kMainScreenWidth, 20)];
    swearLabel.text = @"我们承诺：信息仅用于核实，绝不泄露。";
    swearLabel.textColor = RGBACOLOR(210, 166, 136, 1);
    swearLabel.font = [UIFont systemFontOfSize:14.0];
    [scroll addSubview:swearLabel];
    
    UILabel *egLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 100, 200, 20)];
    egLabel.text = @"身份证证自拍示范:";
    egLabel.textColor = RGBACOLOR(149, 149, 149, 1);
    egLabel.font = [UIFont systemFontOfSize:14.0];
    [scroll addSubview:egLabel];
    
    //相片示范
    UIImageView *image1 = [[UIImageView alloc] init];
    image1.center = CGPointMake(kMainScreenWidth / 2, 170);
    image1.bounds = CGRectMake(0, 0, 80, 80);
    image1.image = [UIImage imageNamed:@"id1"];
    image1.layer.masksToBounds = YES;
    image1.layer.cornerRadius = 4;
    image1.contentMode = UIViewContentModeScaleAspectFit;
    [scroll addSubview:image1];
    
    UILabel *sbLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 220, kMainScreenWidth, 20)];
    sbLabel1.text = @"手持您的身份证";
    sbLabel1.font = [UIFont systemFontOfSize:12.0];
    sbLabel1.textAlignment = NSTextAlignmentCenter;
    [scroll addSubview:sbLabel1];
    
    UILabel *sbLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 240, kMainScreenWidth, 20)];
    sbLabel2.text = @"自拍一张证明你本人";
    sbLabel2.font = [UIFont systemFontOfSize:12.0];
    sbLabel2.textAlignment = NSTextAlignmentCenter;
    [scroll addSubview:sbLabel2];
    
    self.btn = [[UIButton alloc] init];
    [self.btn setFrame:CGRectMake(kMainScreenWidth / 2 - 35, 280, 70, 70)];
    [self.btn setBackgroundImage:[UIImage imageNamed:@"button"] forState:UIControlStateNormal];
    [self.btn addTarget:self action:@selector(selectImg) forControlEvents:UIControlEventTouchUpInside];
    [scroll addSubview:self.btn];
    
    UILabel *upLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.btn.frame.origin.x, 360, 90,20)];
    upLabel.text = @"点击上传图片";
    upLabel.font = [UIFont systemFontOfSize:12.0];
    upLabel.textColor = [UIColor grayColor];
    [scroll addSubview:upLabel];
    
    
    UILabel *pleaseLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 410, kMainScreenWidth, 20)];
    pleaseLabel.text = @"请上传您的证件，我们将尽快为你核实。";
    pleaseLabel.textAlignment = NSTextAlignmentCenter;
    pleaseLabel.font = [UIFont systemFontOfSize:12.0];
    pleaseLabel.textColor = [UIColor grayColor];
    [scroll addSubview:pleaseLabel];
    
    UIButton *sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [sureBtn setFrame:CGRectMake(20, 450, kMainScreenWidth - 40, 40)];
    [sureBtn setTitle:@"提交" forState:UIControlStateNormal];
    sureBtn.layer.cornerRadius = 6;
    [sureBtn setBackgroundColor:RGBACOLOR(28, 198, 158, 1)];
    sureBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [sureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sureBtn addTarget:self action:@selector(sureKnow) forControlEvents:UIControlEventTouchUpInside];
    [scroll addSubview:sureBtn];
    
    [self.view addSubview:scroll];
}

- (void)selectImg{
    
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"选择上传方式" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从相册上传", nil];
    [action showInView:self.view];
}

#pragma mark uiactionsheet 代理

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
            
        case 0:
        {
            [self presentViewController:self.imagePicker animated:YES completion:nil];
        }
            break;
            
        case 1:
        {
            _mediaType = IQMediaPickerControllerMediaTypePhotoLibrary;
            IQMediaPickerController *controller = [[IQMediaPickerController alloc] init];
            controller.delegate = self;
            [controller setMediaType:_mediaType];
            [controller setModalPresentationStyle:UIModalPresentationPopover];
            controller.allowsPickingMultipleItems = YES;
            controller.maxPhotoCount = 1;//设置选取照片最大数量为2，并减去已有的照片数量
            
            [self presentViewController:controller animated:YES completion:nil];
        }
            break;
            
        default:
            break;
    }
}

- (void)sureKnow{
    if (self.imageArray.count == 0) {
        [MBProgressHUD showError:@"图片不能为空"];
        return;
    }
    
    [MBProgressHUD showMessage:@"正在上传，请稍后..."];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/getQiniuToken",REQUESTHEADER] andParameter:@{} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            
            UIImage *selfImage = self.imageArray[0];
//            UIImage *frontImage = self.imageArray[1];
            
            NSData *photoData1 = UIImageJPEGRepresentation(selfImage, 0.3);
//            NSData *photoData2 = UIImageJPEGRepresentation(frontImage, 0.1);
            
            NSString *token = successResponse[@"data"][@"qiniuToken"];
            
            //获取当前时间
            NSDate *now = [NSDate date];
            NSLog(@"now date is: %@", now);
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
            NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
            NSInteger year = [dateComponent year];
            NSInteger month = [dateComponent month];
            NSInteger day = [dateComponent day];
            NSInteger hour = [dateComponent hour];
            NSInteger minute = [dateComponent minute];
            NSInteger second = [dateComponent second];
            
            NSString *locationString1 = [NSString stringWithFormat:@"iosLvYueIdentity%d%d%d%d%d%d(1)",year,month,day,hour,minute,second];
//            NSString *locationString2 = [NSString stringWithFormat:@"iosLvYueIdentity%d%d%d%d%d%d(2)",year,month,day,hour,minute,second];
            
            NSString *twoString = [NSString stringWithFormat:@"%@",locationString1];
            
            //七牛上传图片
            QNUploadManager *upManager = [[QNUploadManager alloc] init];
            [upManager putData:photoData1 key:locationString1 token:token
                      complete: ^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                          NSLog(@"%@", info);
                          NSLog(@"%@", resp);
                          
                          //服务器获取图片
                          [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/certify",REQUESTHEADER] andParameter:@{@"token":token,@"userId":[LYUserService sharedInstance].userID,@"certifyType":@"1",@"photos":twoString} success:^(id successResponse) {
                              MLOG(@"结果:%@",successResponse);
                              if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
                                  
                                  [MBProgressHUD hideHUD];
                                  [MBProgressHUD showSuccess:@"上传成功"];
                                  FinishKnowViewController *fin = [[FinishKnowViewController alloc] init];
                                  fin.iden = @"1";
                                  [self.navigationController pushViewController:fin animated:YES];
                                  
                              } else {
                                  [MBProgressHUD hideHUD];
                                  [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
                              }
                          } andFailure:^(id failureResponse) {
                              [MBProgressHUD hideHUD];
                              [MBProgressHUD showError:@"服务器繁忙,请重试"];
                          }];
                          
                      } option: nil];
        } else {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
}


#pragma mark - IQMediaPickerControllerDelegate
- (void)mediaPickerController:(IQMediaPickerController*)controller didFinishMediaWithInfo:(NSDictionary *)info;
{
    [self.imageArray removeAllObjects];
    if ([info[@"IQMediaTypeImage"] count] == 1) {
        NSLog(@"Info: %@",info);
        NSArray *dictArray = info[@"IQMediaTypeImage"];
        NSMutableArray *tempArray = [NSMutableArray array];
        for (NSDictionary *dict in dictArray) {
            UIImage *image = dict[IQMediaImage];
            [tempArray addObject:image];
        }
        for (UIImage *addedImage in tempArray) {
            [_imageArray addObject:addedImage];
        }
        MLOG(@"_IMAGEARRAY:%@",_imageArray);
        
        [self dismissViewControllerAnimated:YES completion:nil];
        //刷新界面,重设frame
        [self.btn setBackgroundImage:self.imageArray[0] forState:UIControlStateNormal];
//        [self.btn2 setBackgroundImage:self.imageArray[1] forState:UIControlStateNormal];
    } else {
        [MBProgressHUD showError:@"请选择一张图片"];
    }
}

- (void)mediaPickerControllerDidCancel:(IQMediaPickerController *)controller;
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark 摄像头
#pragma mark - UI事件

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
        [self.imageArray addObject:image];
        //刷新界面,重设frame
        [self.btn setBackgroundImage:self.imageArray[0] forState:UIControlStateNormal];
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);//保存到相簿
    }
    
    [MBProgressHUD hideHUD];
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
        
        _imagePicker.cameraCaptureMode=UIImagePickerControllerCameraCaptureModePhoto;
        
        _imagePicker.allowsEditing=YES;//允许编辑
        _imagePicker.delegate=self;//设置代理，检测操作
    }
    return _imagePicker;
}

@end
