//
//  DateDetailViewController.m
//  澜庭
//
//  Created by 广有射怪鸟事 on 15/9/24.
//  Copyright (c) 2015年 刘瀚韬. All rights reserved.
//

#import "DateDetailViewController.h"
#import "MBProgressHUD+NJ.h"
//多媒体拾取器框架
#import "IQMediaPickerController.h"
#import "IQFileManager.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <MediaPlayer/MediaPlayer.h>
#import "CCLocationManager.h"
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "QiniuSDK.h"
#import <CoreLocation/CoreLocation.h>
#import "VipInfoViewController.h"
#import "BMapKit.h"

#define kMaxRequiredCount 9

@interface DateDetailViewController ()<IQMediaPickerControllerDelegate,UINavigationControllerDelegate,CLLocationManagerDelegate,UIAlertViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,BMKGeoCodeSearchDelegate>
{
    //保存当前选择的城市
    NSString *currentCity;
}

@property (nonatomic,strong) UITextView *textView;
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) NSMutableArray *imageArray;
@property (nonatomic,strong) UIButton *upBtn;
@property (nonatomic,strong) UILabel *upLabel;
@property (nonatomic,strong) UILabel *locatioLabel;
@property (nonatomic,strong) NSString *latitude;
@property (nonatomic,strong) NSString *longitude;

@property (assign,nonatomic) int isVideo;//是否录制视频，如果为1表示录制视频，0代表拍照
@property (strong,nonatomic) UIImagePickerController *imagePicker;

//定位信息管理者
@property (nonatomic, strong) CLLocationManager *clManager;

@property (nonatomic,strong) BMKGeoCodeSearch *searcher;

//地理编码对象
@property (nonatomic, strong) CLGeocoder *geocoder;

//保存媒体拾取类型
@property (nonatomic, assign) IQMediaPickerControllerMediaType mediaType;

@end

@implementation DateDetailViewController

#pragma mark - 定位管理者
- (CLLocationManager *)clManager {
    
    if (!_clManager) {
        _clManager = [[CLLocationManager alloc] init];
        //设置定位硬件的精准度
        _clManager.desiredAccuracy = kCLLocationAccuracyBest;
        //设置定位硬件的刷新频率
        _clManager.distanceFilter = kCLLocationAccuracyKilometer;
    }
    return _clManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight)];
    self.scrollView.contentSize = CGSizeMake(0, kMainScreenHeight + 100);
    [self.view addSubview:self.scrollView];
    
    self.imageArray = [[NSMutableArray alloc] init];
    
    [self hideBtn];
    [self createBackBtn];
    [self createView];
    
    self.latitude = @"";
    self.longitude = @"";
    currentCity = @"";
    
    //通过这里设置当前程序是拍照还是录制视频
    _isVideo=YES;
    
}

//收起键盘按钮
- (void)hideBtn{
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:self.view.frame];
    [btn addTarget:self action:@selector(hideKey) forControlEvents:UIControlEventTouchUpInside];
    btn.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:btn];
}

- (void)hideKey{
    [self.textView resignFirstResponder];
}

- (void)doneEdit{
    [self.textView resignFirstResponder];
}

//创建界面
- (void)createView{
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(20, 20, kMainScreenWidth - 40, 250)];
    self.textView.backgroundColor = RGBACOLOR(245, 245, 245, 1.0);
    self.textView.font = [UIFont systemFontOfSize:14.0];
    self.textView.textAlignment = NSTextAlignmentLeft;
    self.textView.returnKeyType = UIReturnKeyDone;
    [self.scrollView addSubview:self.textView];
    
    //键盘工具栏
    UIToolbar *topView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 30)];
    [topView setBarStyle:UIBarStyleDefault];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(doneEdit)];
    NSArray *btnArray = [NSArray arrayWithObjects:space,done, nil];
    [topView setItems:btnArray];
    [self.textView setInputAccessoryView:topView];
    
    UIButton *locationImageView = [[UIButton alloc] initWithFrame:CGRectMake(20, self.textView.frame.origin.y + self.textView.frame.size.height + 10, 12, 16)];
    [locationImageView setBackgroundImage:[UIImage imageNamed:@"定位"] forState:UIControlStateNormal];
    [self.scrollView addSubview:locationImageView];
    
    self.locatioLabel = [[UILabel alloc] initWithFrame:CGRectMake(locationImageView.frame.origin.x + 17, locationImageView.frame.origin.y - 5, 100, 30)];
    self.locatioLabel.text = @"显示所在位置";
    self.locatioLabel.font = [UIFont systemFontOfSize:14.0];
    [self.scrollView addSubview:self.locatioLabel];
    
    UISwitch *locationSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(kMainScreenWidth - 64, locationImageView.frame.origin.y, 22, 15)];
    locationSwitch.onTintColor = [UIColor redColor];
    [locationSwitch addTarget:self action:@selector(changeLocation:) forControlEvents:UIControlEventValueChanged];
    [self.scrollView addSubview:locationSwitch];
    
    self.upBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.upBtn setFrame:CGRectMake(locationImageView.frame.origin.x, locationImageView.frame.origin.y + 26, 57, 57)];
    [self.upBtn setImage:[UIImage imageNamed:@"button"] forState:UIControlStateNormal];
    [self.upBtn addTarget:self action:@selector(addImage) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.upBtn];
    
    self.upLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.upBtn.frame.origin.x - 5, self.upBtn.frame.origin.y + self.upBtn.frame.size.height + 10, 80, 30)];
    self.upLabel.text = @"点击上传图片";
    self.upLabel.font = [UIFont systemFontOfSize:12.0];
    self.upLabel.textColor = [UIColor grayColor];
    [self.scrollView addSubview:self.upLabel];
}

//定位开关事件

- (void)changeLocation:(UISwitch *)locationSwitch{
    if (locationSwitch.on) {
        
        if (![currentCity isEqualToString:@""]) {
            self.locatioLabel.text = currentCity;
        }
        else{
            self.clManager.delegate = self;
            
            self.locatioLabel.text = @"正在定位";
            
            if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 8.0) {
                //前台和后台都允许请求用户是否允许开启定位 IOS8.0以上版本需要设置环境参数
                [_clManager requestAlwaysAuthorization];
                [_clManager startUpdatingLocation];
            }
            else {
                //如果是IOS8.0以下的版本，则可直接开启定位
                [_clManager startUpdatingLocation];
            }
        }
        
    }
    else{
        self.locatioLabel.text = @"显示所在位置";
        self.latitude = @"";
        self.longitude = @"";
    }
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation *currentLocation = [locations lastObject];
    self.latitude = [NSString stringWithFormat:@"%f",currentLocation.coordinate.latitude];
    self.longitude = [NSString stringWithFormat:@"%f",currentLocation.coordinate.longitude];
    
    //初始化检索对象
    self.searcher =[[BMKGeoCodeSearch alloc] init];
    self.searcher.delegate = self;
    
    //发起反向地理编码检索
    CLLocationCoordinate2D pt = (CLLocationCoordinate2D){[self.latitude floatValue], [self.longitude floatValue]};
    BMKReverseGeoCodeOption *reverseGeoCodeSearchOption = [[BMKReverseGeoCodeOption alloc] init];
    reverseGeoCodeSearchOption.reverseGeoPoint = pt;
    [self.searcher reverseGeoCode:reverseGeoCodeSearchOption];
    BOOL flag = [self.searcher reverseGeoCode:reverseGeoCodeSearchOption];
    if(flag)
    {
        NSLog(@"反geo检索发送成功");
    }
    else
    {
        NSLog(@"反geo检索发送失败");
    }
    
}



- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        //用户允许授权,开启定位
        [_clManager startUpdatingLocation];
    } else {
        [MBProgressHUD showError:@"用户拒绝授权,请在设置中开启"];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [MBProgressHUD showError:@"定位失败,请重试"];
}

#pragma mark 代理方法返回反地理编码结果
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error{
    if (result) {
        currentCity = [NSString stringWithFormat:@"%@", result.addressDetail.city];
        self.locatioLabel.text = currentCity;
        NSLog(@"%@ - %@", result.address, result.addressDetail.streetNumber);
    }else{
        self.locatioLabel.text = @"定位失败";
    }
}

//添加图片事件

- (void)addImage{
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
            controller.maxPhotoCount = 9;//设置选取照片最大数量为2，并减去已有的照片数量
            
            [self presentViewController:controller animated:YES completion:nil];
        }
            break;
            
        default:
            break;
    }
}

//back按钮创建
- (void)createBackBtn{
    [self setRightButton:nil title:@"发送" target:self action:@selector(sendDate) rect:CGRectMake(0, 0, 40, 40)];
}


//发送按钮事件
- (void)sendDate{
    if (self.textView.text.length == 0 || [self isBlankString:self.textView.text]) {
        [MBProgressHUD showError:@"内容不能为空"];
        return;
    }
    
    [MBProgressHUD showMessage:@"正在提交，请稍后..." toView:self.view];
    
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/getQiniuToken",REQUESTHEADER] andParameter:@{} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            
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
            
            NSMutableString *allString = [[NSMutableString alloc] initWithString:@""];
            
            if (self.imageArray.count) {
                for (int i = 0; i< self.imageArray.count; i++) {
                    UIImage *img = self.imageArray[i];
                    NSData *photoData = UIImageJPEGRepresentation(img, 0.3);
                    NSString *photoString = [NSString stringWithFormat:@"iosLvYueCreateDate%d%d%d%d%d%d(%d)",year,month,day,hour,minute,second,i];
                    allString = [allString stringByAppendingString:[NSString stringWithFormat:@"%@;",photoString]];
                    QNUploadManager *upManager = [[QNUploadManager alloc] init];
                    [upManager putData:photoData key:photoString token:token
                              complete: ^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                                  NSLog(@"%@", info);
                                  NSLog(@"%@", resp);
                                  if (resp == nil) {
                                      [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                      [MBProgressHUD showError:@"上传失败"];
                                      return ;
                                  }
                                  
                                  if (i == self.imageArray.count - 1) {
                                      [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/dating/create",REQUESTHEADER] andParameter:@{@"create_user_id":[NSString stringWithFormat:@"%@",[LYUserService sharedInstance].userID],@"type":self.type,@"content":self.textView.text,@"photos":allString,@"longitude":self.longitude,@"latitude":self.latitude,@"title":[NSString stringWithFormat:@"【%@发起的豆客群】%@",[LYUserService sharedInstance].userDetail.userName,self.textView.text]} success:^(id successResponse) {
                                          MLOG(@"结果:%@",successResponse);
                                          if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
                                              [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                              [MBProgressHUD showSuccess:@"提交成功"];
                                              [[NSNotificationCenter defaultCenter] postNotificationName:@"goGet" object:nil];
                                              [self.navigationController popViewControllerAnimated:YES];
                                              
                                          } else {
                                              
                                              [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"非会员无法发布豆客" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:@"去开通", nil];
                                              [alert show];
                                          }
                                      } andFailure:^(id failureResponse) {
                                          [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                          [MBProgressHUD showError:@"服务器繁忙,请重试"];
                                      }];
                                  }
                                  
                              } option:nil];
                }
            }else{
                [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/dating/create",REQUESTHEADER] andParameter:@{@"create_user_id":[NSString stringWithFormat:@"%@",[LYUserService sharedInstance].userID],@"type":self.type,@"content":self.textView.text,@"photos":allString,@"longitude":self.longitude,@"latitude":self.latitude,@"title":[NSString stringWithFormat:@"【%@发起的豆客群】%@",[LYUserService sharedInstance].userDetail.userName,self.textView.text]} success:^(id successResponse) {
                    MLOG(@"结果:%@",successResponse);
                    if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
                        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                        [MBProgressHUD showSuccess:@"提交成功"];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"goGet" object:nil];
                        [self.navigationController popViewControllerAnimated:YES];
                        
                    } else {
                        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"非会员无法发布豆客" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:@"去开通", nil];
                        [alert show];
                    }
                } andFailure:^(id failureResponse) {
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    [MBProgressHUD showError:@"服务器繁忙,请重试"];
                }];
            }
        } else {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
    
    
}

- (void)updateView{
    
    //先清除scrollView上部分的子控件
    for (UIView *subView in self.scrollView.subviews) {
        if ([subView isKindOfClass:[UIImageView class]]) {
            [subView removeFromSuperview];
        }
    }
    
    if (self.imageArray > 0) {
        float imgY = self.textView.frame.origin.y + self.textView.frame.size.height + 60;
        for (int i = 0; i < self.imageArray.count; i++) {
            // 计算每次新 view 的位置
            // 每个view 的宽度和高度
            CGFloat viewW = 70;
            CGFloat viewH = 70;
            // 列数，控制显示的列数，可以修改其他值
            NSInteger col = 3;
            // 计算间隔
            CGFloat margin = 20;
            // 计算xy坐标值
            CGFloat viewX = (i % col ) * (viewW + margin) + 30;
            CGFloat viewY = (i / col ) * (viewH + 10) + imgY;
            UIImageView *imgView = [[UIImageView alloc] initWithImage:self.imageArray[i]];
            imgView.frame = CGRectMake(viewX, viewY, viewW, viewH);
            imgView.image = self.imageArray[i];
            [self.scrollView addSubview:imgView];
            imgView.userInteractionEnabled = YES;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addImage)];
            [imgView addGestureRecognizer:tap];
            self.upBtn.frame = CGRectMake(imgView.frame.origin.x + 77, imgView.frame.origin.y, viewW, viewH);
            self.upLabel.frame = CGRectMake(self.upBtn.frame.origin.x - 5, self.upBtn.frame.origin.y + self.upBtn.frame.size.height + 10, 80, 30);
            if (i == 8) {
                [self.upBtn removeFromSuperview];
                [self.upLabel removeFromSuperview];
            }
        }
    }
    else{
        return;
    }
}

#pragma mark - IQMediaPickerControllerDelegate
- (void)mediaPickerController:(IQMediaPickerController*)controller didFinishMediaWithInfo:(NSDictionary *)info{
    if ([info[@"IQMediaTypeImage"] count] <= kMaxRequiredCount) {
        [self.imageArray removeAllObjects];
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
        
        [self updateView];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [MBProgressHUD showError:@"最多添加九张图片"];
    }
}

- (void)mediaPickerControllerDidCancel:(IQMediaPickerController *)controller;
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark uialertview代理

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        
        VipInfoViewController *info = [[VipInfoViewController alloc] init];
        
        [self.navigationController pushViewController:info animated:YES];
        
    }
}

#pragma mark 摄像头
#pragma mark - UI事件

#pragma mark - UIImagePickerController代理方法
//完成
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSString *mediaType=[info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {//如果是拍照
        UIImage *image;
        //如果允许编辑则获得编辑后的照片，否则获取原始照片
        if (self.imagePicker.allowsEditing) {
            image=[info objectForKey:UIImagePickerControllerEditedImage];//获取编辑后的照片
        }else{
            image=[info objectForKey:UIImagePickerControllerOriginalImage];//获取原始照片
        }
        if (_imageArray.count >= 9) {
            [[[UIAlertView alloc] initWithTitle:nil message:@"最多九张照片" delegate:self cancelButtonTitle:@"好的" otherButtonTitles: nil] show];
        }
        else{
            [_imageArray addObject:image];
        }
        [self updateView];
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

#pragma mark 判断字符串只有空格或者为空

- (BOOL)isBlankString:(NSString *)string{
    
    if (string == nil) {
        return YES;
    }
    
    if (string == NULL) {
        return YES;
    }
    
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}

@end
