//
//  CarKnowViewController.m
//  LvYue
//
//  Created by 广有射怪鸟事 on 15/9/30.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import "CarKnowViewController.h"
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

@interface CarKnowViewController ()<IQMediaPickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate>

@property (nonatomic,strong) UIScrollView *scroll;
@property (nonatomic,strong) UIButton *imgBtn;
//保存媒体拾取类型
@property (nonatomic, assign) IQMediaPickerControllerMediaType mediaType;
@property (nonatomic,strong) NSMutableArray *imageArray;

@property (assign,nonatomic) int isVideo;//是否录制视频，如果为1表示录制视频，0代表拍照
@property (strong,nonatomic) UIImagePickerController *imagePicker;

@end

@implementation CarKnowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.imageArray = [[NSMutableArray alloc] init];
    
    self.scroll = [[UIScrollView alloc] initWithFrame:self.view.frame];
    self.scroll.contentSize = CGSizeMake(0, kMainScreenHeight);
    [self.view addSubview:self.scroll];
    
    self.title = @"车辆认证";
    [self createView];
    
    //通过这里设置当前程序是拍照还是录制视频
    _isVideo=YES;
}

- (void)createView{
    UIImageView *logeImg = [[UIImageView alloc] init];
    logeImg.center = CGPointMake(kMainScreenWidth / 2, 50);
    logeImg.bounds = CGRectMake(0, 0, 88, 55);
    logeImg.image = [UIImage imageNamed:@"bg"];
    [self.scroll addSubview:logeImg];
    
    UILabel *carLabel = [[UILabel alloc] init];
    carLabel.center = CGPointMake(kMainScreenWidth / 2, logeImg.frame.origin.y + 100);
    carLabel.bounds = CGRectMake(0, 0, kMainScreenWidth, 30);
    carLabel.text = @"车是您身份的象征";
    carLabel.textAlignment = NSTextAlignmentCenter;
    [self.scroll addSubview:carLabel];
    
    self.imgBtn = [[UIButton alloc] init];
    [self.imgBtn setCenter:CGPointMake(kMainScreenWidth / 2, carLabel.frame.origin.y + 150)];
    [self.imgBtn setBounds:CGRectMake(0, 0, 200, 150)];
    [self.imgBtn setBackgroundImage:[UIImage imageNamed:@"button"] forState:UIControlStateNormal];
    [self.imgBtn addTarget:self action:@selector(changeImg) forControlEvents:UIControlEventTouchUpInside];
    [self.scroll addSubview:self.imgBtn];
    
    UILabel *kLabel = [[UILabel alloc] init];
    kLabel.center = CGPointMake(kMainScreenWidth / 2, self.imgBtn.frame.origin.y + 200);
    kLabel.bounds = CGRectMake(0, 0, kMainScreenWidth, 30);
    kLabel.textAlignment = NSTextAlignmentCenter;
    kLabel.text = @"请上传您的行驶证，我们将尽快为您核实。";
    kLabel.font = [UIFont systemFontOfSize:14.0];
    kLabel.textColor = [UIColor grayColor];
    [self.scroll addSubview:kLabel];
    
    UIButton *sureBtn = [[UIButton alloc] init];
    [sureBtn setCenter:CGPointMake(kMainScreenWidth / 2, kLabel.frame.origin.y + 90)];
    [sureBtn setBounds:CGRectMake(0, 0, kMainScreenWidth - 60,35)];
    [sureBtn setBackgroundColor:RGBACOLOR(29, 189, 159, 1)];
    [sureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sureBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [sureBtn.layer setCornerRadius:4];
    [sureBtn setTitle:@"提交" forState:UIControlStateNormal];
    [sureBtn addTarget:self action:@selector(upCarAction) forControlEvents:UIControlEventTouchUpInside];
    [self.scroll addSubview:sureBtn];
}

//提交事件

- (void)upCarAction{
    if (self.imageArray.count == 0) {
        [MBProgressHUD showError:@"图片不能为空"];
        return;
    }
    [MBProgressHUD showMessage:@"正在上传，请稍后..." toView:self.view];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/getQiniuToken",REQUESTHEADER] andParameter:@{} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            
            UIImage *image = self.imageArray[0];
            NSData *photoData = UIImageJPEGRepresentation(image, 0.3);
            
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
            
            NSString *locationString = [NSString stringWithFormat:@"iosLvYueCar%d%d%d%d%d%d",year,month,day,hour,minute,second];
            
            NSLog(@"时间:%@",locationString);
            
            //七牛上传图片
            QNUploadManager *upManager = [[QNUploadManager alloc] init];
            [upManager putData:photoData key:locationString token:token
                      complete: ^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                          NSLog(@"%@", info);
                          NSLog(@"%@", resp);
                          
                          if (resp == nil) {
                              [MBProgressHUD showError:@"上传失败"];
                          }
                          else{
                              //服务器获取图片
                              [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/certify",REQUESTHEADER] andParameter:@{@"token":token,@"userId":[LYUserService sharedInstance].userID,@"certifyType":@"3",@"photos":locationString} success:^(id successResponse) {
                                  MLOG(@"结果:%@",successResponse);
                                  if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
                                      
                                      [MBProgressHUD hideHUD];
                                      [MBProgressHUD showSuccess:@"上传成功"];
                                      FinishKnowViewController *fin = [[FinishKnowViewController alloc] init];
                                      fin.car = @"1";
                                      [self.navigationController pushViewController:fin animated:YES];
                                      
                                  } else {
                                      [MBProgressHUD hideHUD];
                                      [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
                                  }
                              } andFailure:^(id failureResponse) {
                                  [MBProgressHUD hideHUD];
                                  [MBProgressHUD showError:@"服务器繁忙,请重试"];
                              }];
                          }
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

- (void)changeImg{
    
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


#pragma mark - IQMediaPickerControllerDelegate
- (void)mediaPickerController:(IQMediaPickerController*)controller didFinishMediaWithInfo:(NSDictionary *)info;
{
    [self.imageArray removeAllObjects];
    if ([info[@"IQMediaTypeImage"] count] <= 1) {
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
        [self.imgBtn setBackgroundImage:self.imageArray[0] forState:UIControlStateNormal];
    } else {
        [MBProgressHUD showError:@"最多一张图片"];
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
        [self.imgBtn setBackgroundImage:self.imageArray[0] forState:UIControlStateNormal];
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
