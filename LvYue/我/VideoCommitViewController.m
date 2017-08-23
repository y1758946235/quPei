//
//  VideoCommitViewController.m
//  LvYue
//
//  Created by 广有射怪鸟事 on 15/10/6.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import "FinishKnowViewController.h"
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "MBProgressHUD+NJ.h"
#import "QiniuSDK.h"
#import "VideoCommitViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface VideoCommitViewController ()

@property (nonatomic, strong) MPMoviePlayerController *moviePlayer;

@end

@implementation VideoCommitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.title = @"视频提交";

    [self createView];

    [MBProgressHUD hideHUD];
}

- (void)createView {
    self.moviePlayer              = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:self.urlPath]];
    self.moviePlayer.controlStyle = MPMovieControlStyleEmbedded;
    self.moviePlayer.scalingMode  = MPMovieScalingModeAspectFit;
    [self.moviePlayer.view setFrame:CGRectMake(30, 100, kMainScreenWidth - 60, 200)];
    [self.moviePlayer play];
    [self.view addSubview:self.moviePlayer.view];

    UIButton *lookBtn = [[UIButton alloc] init];
    [lookBtn setFrame:CGRectMake(30, 320, self.moviePlayer.view.frame.size.width / 2 - 10, 40)];
    [lookBtn setTitle:@"预览" forState:UIControlStateNormal];
    [lookBtn.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
    [lookBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [lookBtn.layer setCornerRadius:4];
    [lookBtn.layer setBorderWidth:0.5];
    [lookBtn.layer setBorderColor:[UIColor grayColor].CGColor];
    [lookBtn addTarget:self action:@selector(lookVideo) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:lookBtn];

    UIButton *sureBtn = [[UIButton alloc] init];
    [sureBtn setFrame:CGRectMake(kMainScreenWidth / 2 + 10, 320, self.moviePlayer.view.frame.size.width / 2 - 10, 40)];
    [sureBtn setTitle:@"确定" forState:UIControlStateNormal];
    [sureBtn.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
    [sureBtn setTitleColor:RGBACOLOR(29, 189, 159, 1) forState:UIControlStateNormal];
    [sureBtn.layer setCornerRadius:4];
    [sureBtn.layer setBorderWidth:0.5];
    [sureBtn.layer setBorderColor:[UIColor grayColor].CGColor];
    [sureBtn addTarget:self action:@selector(sureVideo) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sureBtn];
}

- (void)lookVideo {
    [self.moviePlayer play];
}

- (void)sureVideo {
    NSInteger time = self.moviePlayer.duration;
    if (time < 5 || time > 15) {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"视频时长必须为5-15秒" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil] show];
        return;
    }

    [self.moviePlayer stop];

    [MBProgressHUD showMessage:@"正在上传，请稍后..."];

    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/config/getQiniuToken", REQUESTHEADER] andParameter:@{} success:^(id successResponse) {
        MLOG(@"结果:%@", successResponse);
        if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {

            NSData *videoData = [[NSData alloc] initWithContentsOfFile:self.urlPath];

             NSString *token = successResponse[@"data"];

            //获取当前时间
            NSDate *now = [NSDate date];
            NSLog(@"now date is: %@", now);
            NSCalendar *calendar            = [NSCalendar currentCalendar];
            NSUInteger unitFlags            = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
            NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
            NSInteger year                  = [dateComponent year];
            NSInteger month                 = [dateComponent month];
            NSInteger day                   = [dateComponent day];
            NSInteger hour                  = [dateComponent hour];
            NSInteger minute                = [dateComponent minute];
            NSInteger second                = [dateComponent second];

//            NSString *locationString = [NSString stringWithFormat:@"iosLvYueVideo%d%d%d%d%d%d/形象视频.mp4", year, month, day, hour, minute, second];
 NSString *locationString = [NSString stringWithFormat:@"iosLvYueVideo%d%d%d%d%d%d.mp4", year, month, day, hour, minute, second];
            NSLog(@"时间:%@", locationString);

            //七牛上传视频
            QNUploadManager *upManager = [[QNUploadManager alloc] init];
            [upManager putData:videoData key:locationString token:token
                      complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                          NSLog(@"%@", info);
                          NSLog(@"%@", resp);

                          if (resp == nil) {
                              [MBProgressHUD showError:@"上传失败"];
                          } else {
                              //服务器获取图片
                              [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/updateUserVideo", REQUESTHEADER] andParameter:@{ 
                                                                                                                                                       @"userId": [CommonTool getUserID],
                                                                                                                                                       @"userVideo": locationString }
                                  success:^(id successResponse) {
                                      MLOG(@"结果:%@", successResponse);
                                      if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {

                                          [MBProgressHUD hideHUD];
                                          [MBProgressHUD showSuccess:@"上传成功"];
                                          FinishKnowViewController *fin = [[FinishKnowViewController alloc] init];
                                          fin.video                     = @"1";
                                          [self.navigationController pushViewController:fin animated:YES];

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
                      }
                        option:nil];

        } else {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"msg"]]];
        }
    }
        andFailure:^(id failureResponse) {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"服务器繁忙,请重试"];
        }];
}

@end
