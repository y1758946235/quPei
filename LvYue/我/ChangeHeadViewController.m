//
//  ChangeHeadViewController.m
//  澜庭
//
//  Created by 广有射怪鸟事 on 15/9/25.
//  Copyright (c) 2015年 刘瀚韬. All rights reserved.
//

#import "ChangeHeadViewController.h"
#import "MBProgressHUD+NJ.h"
//多媒体拾取器框架
#import "IQMediaPickerController.h"
#import "IQFileManager.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "QiniuSDK.h"
#import "UIImagePickerController+CheckCanTakePicture.h"

#define kMaxRequiredCount 1

@interface ChangeHeadViewController ()<IQMediaPickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate>

@property (nonatomic,strong) UIScrollView *rootScroll;
@property (nonatomic,strong) UIImageView *headImg;
@property (nonatomic,strong) NSMutableArray *imageArray;
@property (nonatomic,strong) NSData *photoData;
@property (nonatomic,strong) NSString *token;
@property (nonatomic,strong) NSString *locationString;

@property (nonatomic,strong) NSOperationQueue *queue;

//保存媒体拾取类型
@property (nonatomic, assign) IQMediaPickerControllerMediaType mediaType;

@end

@implementation ChangeHeadViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.imageArray = [[NSMutableArray alloc] init];
    
    self.view.backgroundColor = RGBACOLOR(238, 238, 238, 1);
    self.rootScroll.backgroundColor = RGBACOLOR(238, 238, 238, 1);
    
    self.rootScroll = [[UIScrollView alloc] initWithFrame:self.view.frame];
    self.rootScroll.contentSize = CGSizeMake(0, kMainScreenHeight);
    [self.view addSubview:self.rootScroll];
    [self createView];
}

- (void)createView{
    self.headImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, -20, kMainScreenWidth, kMainScreenHeight / 2 + 50)];
    self.headImg.image = self.headImage;
    self.headImg.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeImage)];
    [self.headImg addGestureRecognizer:tap];
    [self.rootScroll addSubview:self.headImg];
    
    //名字
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.center = CGPointMake(kMainScreenWidth / 2, self.headImg.frame.origin.y + self.headImg.frame.size.height + 50);
    nameLabel.bounds = CGRectMake(0, 0, 200, 30);
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.text = self.name;
    [self.rootScroll addSubview:nameLabel];
    
    //更换头像btn
    UIButton *changeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    changeBtn.center = CGPointMake(kMainScreenWidth / 2, nameLabel.frame.origin.y + nameLabel.frame.size.height + 50);
    changeBtn.bounds = CGRectMake(0, 0, 220, 40);
    changeBtn.backgroundColor = RGBACOLOR(29, 189, 159, 1);
    changeBtn.titleLabel.textColor = [UIColor whiteColor];
    [changeBtn addTarget:self action:@selector(changeHead) forControlEvents:UIControlEventTouchUpInside];
    [changeBtn setTitle:@"保存" forState:UIControlStateNormal];
    [self.rootScroll addSubview:changeBtn];
    
    //保存按钮
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    saveBtn.center = CGPointMake(kMainScreenWidth / 2, changeBtn.frame.origin.y + changeBtn.frame.size.height + 25);
    saveBtn.bounds = CGRectMake(0, 0, 220, 40);
    [saveBtn addTarget:self action:@selector(saveChange) forControlEvents:UIControlEventTouchUpInside];
    [saveBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    saveBtn.layer.borderWidth = 1;
    saveBtn.layer.borderColor = RGBACOLOR(238, 238, 238, 1).CGColor;
    [saveBtn setBackgroundColor:[UIColor whiteColor]];
    [saveBtn setTitle:@"取消" forState:UIControlStateNormal];
    [self.rootScroll addSubview:saveBtn];
    
}

- (void)changeImage{
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从相册选取", nil];
    [action showInView:self.view];
}

//保存头像
- (void)changeHead{
    if (self.imageArray.count == 0) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        return;
    }
    
    [MBProgressHUD showMessage:@"正在上传，请稍后..." toView:self.view];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/getQiniuToken",REQUESTHEADER] andParameter:@{} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            
            UIImage *image = self.imageArray[0];
            self.photoData = UIImageJPEGRepresentation(image, 0.3);
            
            self.token = successResponse[@"data"][@"qiniuToken"];
            
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
            
            UIImage *dataImage = [UIImage imageWithData:self.photoData];
            CGSize size = CGSizeFromString(NSStringFromCGSize(dataImage.size));
            CGFloat percent = size.width / size.height;
            
            self.locationString = [NSString stringWithFormat:@"iosLvYueIcon%d%d%d%d%d%d%.2f",year,month,day,hour,minute,second,percent];
            
            //七牛上传图片
            QNUploadManager *upManager = [[QNUploadManager alloc] init];
            [upManager putData:self.photoData key:self.locationString token:self.token
                      complete: ^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                          NSLog(@"%@", info);
                          NSLog(@"%@", resp);
                          if (resp == nil) {
                              [MBProgressHUD hideHUD];
                              [MBProgressHUD showError:@"上传失败"];
                          }
                          else{
                              
                              if (![self.locationString isEqualToString:@""]) {
                                  //服务器获取图片
                                  [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/update",REQUESTHEADER] andParameter:@{@"id":[NSString stringWithFormat:@"%@",[LYUserService sharedInstance].userID],@"icon":self.locationString} success:^(id successResponse) {
                                      MLOG(@"结果:%@",successResponse);
                                      [MBProgressHUD hideHUD];
                                      if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
                                          [self.navigationController popToRootViewControllerAnimated:YES];
                                          [MBProgressHUD showSuccess:@"上传成功"];
                                      } else {
                                          [MBProgressHUD hideHUD];
                                          [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
                                      }
                                  } andFailure:^(id failureResponse) {
                                      [MBProgressHUD hideHUD];
                                      [MBProgressHUD showError:@"服务器繁忙,请重试"];
                                  }];
                              }
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

//保存头像
- (void)saveChange{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - IQMediaPickerControllerDelegate
- (void)mediaPickerController:(IQMediaPickerController*)controller didFinishMediaWithInfo:(NSDictionary *)info;
{
    [self.imageArray removeAllObjects];
    if ([info[@"IQMediaTypeImage"] count] <= kMaxRequiredCount) {
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
        self.headImg.image = self.imageArray[0];
    } else {
        [MBProgressHUD showError:@"最多一张图片"];
    }
}

- (void)mediaPickerControllerDidCancel:(IQMediaPickerController *)controller;
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark uiactionsheet委托

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        if ([UIImagePickerController canTakePicture]) {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            picker.allowsEditing = YES;
            picker.delegate = self;
            [self presentViewController:picker animated:YES completion:nil];
        }
    }
    else if (buttonIndex == 1){
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.allowsEditing = YES;
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
    }
}

#pragma mark uiimagepicker代理

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    [self.imageArray removeAllObjects];
    UIImage *editImage = info[UIImagePickerControllerEditedImage];
    self.headImg.image = editImage;
    [self.imageArray addObject:editImage];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
