//
//  AddLiveViewController.m
//  澜庭
//
//  Created by 广有射怪鸟事 on 15/9/24.
//  Copyright (c) 2015年 刘瀚韬. All rights reserved.
//

#import "AddLiveViewController.h"
#import "MBProgressHUD+NJ.h"
//多媒体拾取器框架
#import "IQMediaPickerController.h"
#import "IQFileManager.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "CCLocationManager.h"
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "QiniuSDK.h"
#import <CoreLocation/CoreLocation.h>
#import "VipInfoViewController.h"
#import "LocalCountryViewController.h"

#define kMaxRequiredCount 9

@interface AddLiveViewController ()<UIScrollViewDelegate,IQMediaPickerControllerDelegate,UINavigationControllerDelegate,CLLocationManagerDelegate,UIAlertViewDelegate,UIActionSheetDelegate>
{
    //保存当前选择的城市
    NSString *currentCity;
}

@property (nonatomic,strong ) UITextView                       *textView;
@property (nonatomic,strong ) UIScrollView                     *scrollView;
@property (nonatomic,strong ) NSMutableArray                   *imageArray;
@property (nonatomic,strong ) UIButton                         *upBtn;
@property (nonatomic,strong ) UILabel                          *upLabel;
@property (nonatomic,strong ) UILabel                          *locatioLabel;
@property (nonatomic,strong ) NSString                         *latitude;
@property (nonatomic,strong ) NSString                         *longitude;
@property (nonatomic,strong ) UITextField                      *priceText;
@property (nonatomic,strong ) UILabel                          *cityLabel;
@property (nonatomic,strong ) NSString                         *cityId;

@property (nonatomic,strong ) NSString                         *isLive;//判断是否可以发布民宿，1为可以

//定位信息管理者
@property (nonatomic, strong) CLLocationManager                *clManager;

//地理编码对象
@property (nonatomic, strong) CLGeocoder                       *geocoder;

//保存媒体拾取类型
@property (nonatomic, assign) IQMediaPickerControllerMediaType mediaType;

@end

@implementation AddLiveViewController

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

#pragma mark - 地理编码对象
- (CLGeocoder *)geocoder {
    
    if (_geocoder == nil) {
        _geocoder = [[CLGeocoder alloc] init];
    }
    return _geocoder;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight)];
    self.scrollView.contentSize = CGSizeMake(0, kMainScreenHeight + 100);
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
    
    self.imageArray = [[NSMutableArray alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCity:) name:@"addLive" object:nil];
    
    [self hideBtn];
    [self createBackBtn];
    [self createView];
    
    self.latitude = @"";
    self.longitude = @"";
    currentCity = @"";
    self.cityId = @"";
    self.isLive = @"";
    
    [self checkLive];
    
}

- (void)changeCity:(NSNotification *)aNotification{
    if (aNotification.userInfo[@"searchCity"]) {
        currentCity = aNotification.userInfo[@"cityName"];
        self.cityId = aNotification.userInfo[@"searchCity"];
    }
    else if (aNotification.userInfo[@"searchPro"]){
        currentCity = aNotification.userInfo[@"proName"];
        self.cityId = aNotification.userInfo[@"searchPro"];
    }
    else{
        currentCity = aNotification.userInfo[@"countryName"];
        self.cityId = aNotification.userInfo[@"searchCountry"];
    }
    self.cityLabel.text = currentCity;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark 判断是否可以发布豆客

- (void)checkLive{
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/getDetailInfo",REQUESTHEADER] andParameter:@{@"id":[NSString stringWithFormat:@"%@",[LYUserService sharedInstance].userID]} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            self.isLive = [NSString stringWithFormat:@"%@",successResponse[@"data"][@"user"][@"provide_stay"]];
        } else {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
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
    
    UILabel *p = [[UILabel alloc] initWithFrame:CGRectMake(self.textView.frame.origin.x, CGRectGetMaxY(self.textView.frame) + 10, 70, 20)];
    p.text = @"参考价格";
    p.font = [UIFont systemFontOfSize:14.0];
    [self.scrollView addSubview:p];
    
    self.priceText = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(p.frame), p.frame.origin.y, 100, 20)];
    self.priceText.textAlignment = NSTextAlignmentCenter;
    self.priceText.placeholder = @"请填写参考价格";
    self.priceText.font = [UIFont systemFontOfSize:14.0];
    self.priceText.keyboardType = UIKeyboardTypeNumberPad;
    self.priceText.backgroundColor = RGBACOLOR(238, 238, 238, 1);
    self.priceText.layer.cornerRadius = 4;
    [self.scrollView addSubview:self.priceText];
    
    UILabel *y = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.priceText.frame) + 10, p.frame.origin.y, 70, 20)];
    y.text = @"元/天";
    y.font = [UIFont systemFontOfSize:14.0];
    [self.scrollView addSubview:y];
    
    UIButton *selectCity = [[UIButton alloc] initWithFrame:CGRectMake(p.frame.origin.x, CGRectGetMaxY(p.frame) + 10, 70, 20)];
    [selectCity setTitle:@"选择地区" forState:UIControlStateNormal];
    [selectCity.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
    [selectCity.layer setBorderWidth:0.5];
    [selectCity.layer setBorderColor:RGBACOLOR(29, 189, 159, 1).CGColor];
    [selectCity.layer setCornerRadius:4.0];
    [selectCity setTitleColor:RGBACOLOR(29, 189, 159, 1) forState:UIControlStateNormal];
    [selectCity addTarget:self action:@selector(selectCity) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:selectCity];
    
    self.cityLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(selectCity.frame) + 10, selectCity.frame.origin.y, 200, 20)];
    self.cityLabel.font = [UIFont systemFontOfSize:14.0];
    self.cityLabel.text = @"";
    [self.scrollView addSubview:self.cityLabel];
    
    self.upBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.upBtn setFrame:CGRectMake(selectCity.frame.origin.x, CGRectGetMaxY(selectCity.frame) + 10, 57, 57)];
    [self.upBtn setImage:[UIImage imageNamed:@"button"] forState:UIControlStateNormal];
    [self.upBtn addTarget:self action:@selector(addImage) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.upBtn];
    
    self.upLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.upBtn.frame.origin.x - 5, self.upBtn.frame.origin.y + self.upBtn.frame.size.height + 10, 80, 30)];
    self.upLabel.text = @"点击上传图片";
    self.upLabel.font = [UIFont systemFontOfSize:12.0];
    self.upLabel.textColor = [UIColor grayColor];
    [self.scrollView addSubview:self.upLabel];
}

#pragma mark 选择城市

- (void)selectCity{
    LocalCountryViewController *local = [[LocalCountryViewController alloc] init];
    //local.preView = @"addLive";
    [self.navigationController pushViewController:local animated:YES];
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation *currentLocation = [locations lastObject];
    self.latitude = [NSString stringWithFormat:@"%f",currentLocation.coordinate.latitude];
    self.longitude = [NSString stringWithFormat:@"%f",currentLocation.coordinate.longitude];
    
    
    [self.geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = [placemarks firstObject];
        NSString *currentCityName = placemark.locality;
        
        
        if (!currentCityName) {
            
        } else {
            //保存定位到的城市
            currentCity = currentCityName;
        }
        self.locatioLabel.text = currentCity;
        //停止定位
        [_clManager stopUpdatingLocation];
    }];
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
            _mediaType = IQMediaPickerControllerMediaTypePhoto;
            IQMediaPickerController *controller = [[IQMediaPickerController alloc] init];
            controller.delegate = self;
            [controller setMediaType:_mediaType];
            [controller setModalPresentationStyle:UIModalPresentationPopover];
            controller.allowsPickingMultipleItems = YES;
            controller.maxPhotoCount = 9;//设置选取照片最大数量为2，并减去已有的照片数量
            
            [self presentViewController:controller animated:YES completion:nil];
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
    if (self.textView.text.length == 0 || self.priceText.text.length == 0 || [self.cityId integerValue] == 0) {
        [MBProgressHUD showError:@"内容不完整"];
        return;
    }
    
    if ([self.isLive isEqualToString:@"1"]) {
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
                        NSString *photoString = [NSString stringWithFormat:@"iosLvYueCreateLive%d%d%d%d%d%d(%d)",year,month,day,hour,minute,second,i];
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
                                          [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/hostel/add",REQUESTHEADER] andParameter:@{@"create_userID":[NSString stringWithFormat:@"%@",[LYUserService sharedInstance].userID],@"content":self.textView.text,@"photos":allString,@"price":self.priceText.text,@"city":self.cityId} success:^(id successResponse) {
                                              MLOG(@"结果:%@",successResponse);
                                              if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
                                                  [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                                  [MBProgressHUD showSuccess:@"提交成功"];
                                                  [self.navigationController popViewControllerAnimated:YES];
                                                  [[NSNotificationCenter defaultCenter] postNotificationName:@"okAdd" object:nil];
                                                  
                                              } else {
                                                  [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                                  [MBProgressHUD showError:successResponse[@"msg"] toView:self.view];
                                              }
                                          } andFailure:^(id failureResponse) {
                                              [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                              [MBProgressHUD showError:@"服务器繁忙,请重试"];
                                          }];
                                      }
                                      
                                  } option:nil];
                    }
                }else{
                    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/hostel/add",REQUESTHEADER] andParameter:@{@"create_userID":[NSString stringWithFormat:@"%@",[LYUserService sharedInstance].userID],@"content":self.textView.text,@"photos":allString,@"price":self.priceText.text,@"city":self.cityId} success:^(id successResponse) {
                        MLOG(@"结果:%@",successResponse);
                        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
                            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                            [MBProgressHUD showSuccess:@"提交成功"];
                            [self.navigationController popToRootViewControllerAnimated:YES];
                            
                        } else {
                            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                            [MBProgressHUD showError:successResponse[@"msg"] toView:self.view];
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
    else{
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [MBProgressHUD showError:@"请先申请民宿"];
    }
    
}

- (void)updateView{
    
    //先清除scrollView上部分的子控件
    for (UIView *subView in self.scrollView.subviews) {
        if ([subView isKindOfClass:[UIImageView class]]) {
            [subView removeFromSuperview];
        }
    }
    
    if (self.imageArray > 0) {
        [self.scrollView addSubview:self.upBtn];
        [self.scrollView addSubview:self.upLabel];
        float imgY = CGRectGetMaxY(self.cityLabel.frame) + 10;
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
            self.upBtn.frame = CGRectMake(CGRectGetMaxX(imgView.frame) + margin, imgView.frame.origin.y, viewW, viewH);
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
- (void)mediaPickerController:(IQMediaPickerController*)controller didFinishMediaWithInfo:(NSDictionary *)info;
{
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

#pragma mark uiscrollerview 代理

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.priceText resignFirstResponder];
}

@end
