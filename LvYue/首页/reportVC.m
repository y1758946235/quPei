//
//  reportVC.m
//  LvYue
//
//  Created by X@Han on 17/1/7.
//  Copyright © 2017年 OLFT. All rights reserved.
//


#import "reportVC.h"
#import "MBProgressHUD+NJ.h"
//多媒体拾取器框架
#import "IQMediaPickerController.h"
#import "IQFileManager.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "LYUserService.h"
#import "LYHttpPoster.h"
#import "QiniuSDK.h"

@interface reportVC ()<IQMediaPickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic,strong) UIButton *cutBtn;
@property (nonatomic,strong) NSMutableArray *imageArray;
@property (nonatomic,strong) UITextField *feedText;

//保存媒体拾取类型
@property (nonatomic, assign) IQMediaPickerControllerMediaType mediaType;

@end

@implementation reportVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.imageArray = [[NSMutableArray alloc] init];
    
    [self.navigationController setNavigationBarHidden:NO];
    
    self.title = @"举报原因";
    [self setNav];
    
    [self createView];
}

- (void)setNav{
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(16, 38, 28, 14)];
    [button setTitleColor:[UIColor colorWithHexString:@"#424242"] forState:UIControlStateNormal];
    [button setTitle:@"返回" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [button addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = back;
}

- (void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)createView{
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:self.view.frame];
    scroll.backgroundColor = RGBACOLOR(238, 238, 238, 1);
    scroll.contentSize = CGSizeMake(0, kMainScreenHeight);
    [self.view addSubview:scroll];
    
    UIView *imgView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, kMainScreenWidth, 150)];
    imgView.backgroundColor = [UIColor whiteColor];
    [scroll addSubview:imgView];
    
    UILabel *imgLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 100, 20)];
    imgLabel.text = @"相关截图";
    imgLabel.font = [UIFont systemFontOfSize:14.0];
    imgLabel.textColor = RGBACOLOR(158, 158, 158, 1);
    [imgView addSubview:imgLabel];
    
    self.cutBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 40, 80, 80)];
    [self.cutBtn setBackgroundImage:[UIImage imageNamed:@"button"] forState:UIControlStateNormal];
    [self.cutBtn addTarget:self action:@selector(addCutImage) forControlEvents:UIControlEventTouchUpInside];
    [imgView addSubview:self.cutBtn];
    
    UIView *detailView = [[UIView alloc] initWithFrame:CGRectMake(0, 190, kMainScreenWidth, 180)];
    detailView.backgroundColor = [UIColor whiteColor];
    [scroll addSubview:detailView];
    
    self.feedText = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, kMainScreenWidth - 20, 170)];
    self.feedText.placeholder = @"请尽可能详细地描述举报原因，我们将认真做出处理";
    [self.feedText addTarget:self action:@selector(resignFirstResponder) forControlEvents:UIControlEventEditingDidEndOnExit];
    self.feedText.font = [UIFont systemFontOfSize:14.0];
    self.feedText.textAlignment = NSTextAlignmentLeft;
    self.feedText.returnKeyType = UIReturnKeyDone;
    self.feedText.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    [detailView addSubview:self.feedText];
    
    
    UIButton *applyBtn = [[UIButton alloc] init];
    [applyBtn setCenter:CGPointMake(kMainScreenWidth / 2, detailView.frame.origin.y + 250)];
    [applyBtn setBounds:CGRectMake(0, 0, kMainScreenWidth - 40, 40)];
    [applyBtn setTitle:@"提交" forState:UIControlStateNormal];
    [applyBtn setBackgroundColor:[UIColor colorWithHexString:@"#ff5252"]];
    [applyBtn addTarget:self action:@selector(applyFeedBack) forControlEvents:UIControlEventTouchUpInside];
    [applyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [applyBtn.layer setCornerRadius:4];
    [scroll addSubview:applyBtn];
}

- (void)applyFeedBack{
    
    if (self.feedText.text.length == 0) {
        [MBProgressHUD showError:@"内容不能为空"];
        return;
    }
    
    [MBProgressHUD showMessage:@"正在提交，请稍后..." toView:self.view];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/config/getQiniuToken",REQUESTHEADER] andParameter:@{} success:^(id successResponse) {
        MLOG(@"七牛结果:%@",successResponse);
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            
            //七牛上传图片
            if (self.imageArray.count) {
                
                UIImage *image = self.imageArray[0];
                NSData *photoData = UIImageJPEGRepresentation(image, 0.3);
                
                NSString *token = successResponse[@"data"];
                
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
                
                NSString *locationString = [NSString stringWithFormat:@"iosLvYueFeedBack%d%d%d%d%d%d",year,month,day,hour,minute,second];
                
                NSLog(@"时间:%@",locationString);
                
                QNUploadManager *upManager = [[QNUploadManager alloc] init];
                [upManager putData:photoData key:locationString token:token
                          complete: ^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                              NSLog(@"%@", info);
                              NSLog(@"%@", resp);
                              
                              if (resp == nil) {
                                  [MBProgressHUD showError:@"上传失败"];
                              }
                              else{
                                  
                                  
  //**********************************************************把这个接口改成举报接口
//                                  NSString *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userId"];
                                  
                                  
                                  // DLK 修改内存泄漏
                                  
                                  //服务器获取图片
                                  [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/circle/addUserReport",REQUESTHEADER] andParameter:@{@"userId":[CommonTool getUserID],@"reportPhoto":locationString,@"reportContent":self.feedText.text,@"otherUserId":self.otherUserId} success:^(id successResponse) {
                                      MLOG(@"提交举报原因反馈结果:%@",successResponse);
                                      if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
                                          [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                          [[[UIAlertView alloc] initWithTitle:@"" message:@"已经提交反馈，我们将尽快为您处理" delegate:self cancelButtonTitle:@"好的" otherButtonTitles: nil] show];
                                          [self.navigationController popViewControllerAnimated:YES];
                                          
                                      } else {
                                          [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                          [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
                                      }
                                  } andFailure:^(id failureResponse) {
                                      [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                      [MBProgressHUD showError:@"服务器繁忙,请重试"];
                                  }];
                              }
                          } option: nil];
            }
            else if (!self.imageArray.count){
                NSString *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userId"];
                [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/circle/addUserReport",REQUESTHEADER] andParameter:@{@"userId":[CommonTool getUserID],@"reportPhoto":@"",@"reportContent":self.feedText.text,@"otherUserId":self.otherUserId} success:^(id successResponse) {
                    MLOG(@"结果:%@",successResponse);
                    if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
                        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                        [[[UIAlertView alloc] initWithTitle:@"" message:@"已经提交反馈，我们将尽快为您处理" delegate:self cancelButtonTitle:@"好的" otherButtonTitles: nil] show];
                        [self.navigationController popViewControllerAnimated:YES];
                        
                    } else {
                        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                        [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
                    }
                } andFailure:^(id failureResponse) {
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    [MBProgressHUD showError:@"服务器繁忙,请重试"];
                }];
            }
            
        } else {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
}

- (void)addCutImage{
    _mediaType = IQMediaPickerControllerMediaTypePhotoLibrary;
    IQMediaPickerController *controller = [[IQMediaPickerController alloc] init];
    controller.delegate = self;
    [controller setMediaType:_mediaType];
    [controller setModalPresentationStyle:UIModalPresentationPopover];
    controller.allowsPickingMultipleItems = YES;
    controller.maxPhotoCount = 1;
    
    [self presentViewController:controller animated:YES completion:nil];
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
        [self.cutBtn setBackgroundImage:self.imageArray[0] forState:UIControlStateNormal];
    } else {
        [MBProgressHUD showError:@"最多两张图片"];
    }
}

- (void)mediaPickerControllerDidCancel:(IQMediaPickerController *)controller;
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
