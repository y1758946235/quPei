//
//  PublishMessageViewController.m
//  LvYueDemo
//
//  Created by 蒋俊 on 15/10/10.
//  Copyright (c) 2015年 vison. All rights reserved.
//

#import "AFNetworking.h"
#import "FriendsCircleLocalCell.h"
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "MBProgressHUD+NJ.h"
#import "PhotoDetailViewController.h"
#import "PublishMessageViewController.h"
#import "UploadImageCell.h"

#import "IQFileManager.h"
#import "IQMediaPickerController.h"
#import "QiniuSDK.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

#import "UIImage+fixOrientation.h"

@interface PublishMessageViewController () <IQMediaPickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UIImagePickerControllerDelegate> {
    IQMediaPickerControllerMediaType mediaType;
    UITextView *_textView;
    NSMutableArray *_imgArray;
    UIButton *_addBtn; //当前触发添加照片的按钮
    UILabel *_placeHolder;
}
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation PublishMessageViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:29 / 255.0 green:189 / 255.0 blue:159 / 255.0 alpha:1];
    UIButton *btn                                        = [self setRightButton:nil title:@"发送" target:self action:@selector(sendClick)];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化
    _imgArray = [NSMutableArray array];

    _placeHolder           = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 200, 20)];
    _placeHolder.font      = [UIFont systemFontOfSize:13];
    _placeHolder.textColor = UIColorWithRGBA(169, 169, 169, 1);
    _placeHolder.text      = @"小伙伴们一起发表评论吧!";

    _tableView                = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    _tableView.delegate       = self;
    _tableView.dataSource     = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick)];
    [_tableView addGestureRecognizer:tap];
}

- (void)tapClick {

    [_textView resignFirstResponder];
}

- (void)sendClick {

    //1. 获得七牛token
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [MBProgressHUD showMessage:@"正在上传，请稍后..."];
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/getQiniuToken", REQUESTHEADER];
    [manager POST:urlStr parameters:@{} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"获得七牛TOKEN:%@", responseObject);

        if ([[NSString stringWithFormat:@"%@", responseObject[@"code"]] isEqualToString:@"200"]) {
            [MBProgressHUD hideHUD];
            NSString *token = responseObject[@"data"][@"qiniuToken"];

            //获取当前时间
            NSDate *now = [NSDate date];
            NSLog(@"now date is: %@", now);
            NSCalendar *calendar            = [NSCalendar currentCalendar];
            NSUInteger unitFlags            = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
            NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
            int year                        = (int) [dateComponent year];
            int month                       = (int) [dateComponent month];
            int day                         = (int) [dateComponent day];
            int hour                        = (int) [dateComponent hour];
            int minute                      = (int) [dateComponent minute];
            int second                      = (int) [dateComponent second];

            NSString *photoString = @"";
            //2.将图片传给七牛服务器,并保存图片名
            if (_imgArray.count) {

                for (int i = 0; i < _imgArray.count; i++) {
                    UIImage *img       = _imgArray[i];
                    NSData *photoData  = UIImageJPEGRepresentation(img, 0.3);
                    NSString *photoStr = [NSString stringWithFormat:@"iosLvYueFriendCircle%d%d%d%d%d%d(%d)", year, month, day, hour, minute, second, i];
                    photoString        = [photoString stringByAppendingString:[NSString stringWithFormat:@"%@;", photoStr]];

                    QNUploadManager *upManager = [[QNUploadManager alloc] init];
                    [upManager putData:photoData key:photoStr token:token
                              complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                                  NSLog(@"%@", info);
                                  NSLog(@"%@", resp);
                                  if (resp == nil) {
                                      [MBProgressHUD hideHUD];
                                      [MBProgressHUD showError:@"上传失败"];
                                      return;
                                  }
                              }
                                option:nil];
                }
            }

            //3.向后台请求
            [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/notice/publish", REQUESTHEADER] andParameter:@{
                                                @"publisher": [NSString stringWithFormat:@"%@", [LYUserService sharedInstance].userID],
                                                @"noticeDetail": _textView.text,
                                                @"photos": photoString,
                                                @"noticeType":@"0",
                                                @"hotId":@"0",
                                                @"nType":@"1",
                                                @"videoUrl":@""
                                                }
                success:^(id successResponse) {
                    MLOG(@"发送朋友圈:%@", successResponse);
                    if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
                        [MBProgressHUD hideHUD];
                        [MBProgressHUD showSuccess:@"提交成功"];

                        //Block返回，让其reloadData
                        //                    self.isPublishBlock(@"");
                        [self.navigationController popViewControllerAnimated:YES];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadFriendCircleVC" object:nil];
                    } else {
                        [MBProgressHUD hideHUD];
                        [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"msg"]]];
                    }
                }
                andFailure:^(id failureResponse) {
                    [MBProgressHUD hideHUD];
                    [MBProgressHUD showError:@"服务器繁忙,请重试"];
                }];

        } else {

            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:responseObject[@"msg"]];
        }
    }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error);
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"请检查您的网络"];
        }];
}

//多选
- (void)uploadImg:(UIButton *)sender {

    //让之前的第一响应者TextField放弃第一响应者
    [_textView resignFirstResponder];

    if (sender.tag == _addBtn.tag) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"提示" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从手机相册中选取", @"拍照", nil];
        [actionSheet showInView:self.view];
    } else {
        //查看大图
        PhotoDetailViewController *photoDetailViewController = [[PhotoDetailViewController alloc] init];
        photoDetailViewController.image                      = sender.currentBackgroundImage;

        NSInteger index = sender.tag - 100;
        [photoDetailViewController returnPhoto:^(BOOL isDelete) {

            [_imgArray removeObjectAtIndex:index];
            [_tableView reloadData];
        }];
        [self.navigationController pushViewController:photoDetailViewController animated:YES];
    }
}

//- (void)ReturnIsPublish:(ReturnIsPublish)block{
//
//    self.isPublishBlock = block;
//}

#pragma mark - UITableViewDataSource & Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.row == 0) {

        static NSString *cellID = @"textViewCell";
        UITableViewCell *cell   = [_tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];

            _textView                 = [[UITextView alloc] initWithFrame:CGRectMake(Kinterval, Kinterval, SCREEN_WIDTH - 2 * Kinterval, 150 - 2 * Kinterval)];
            _textView.delegate        = self;
            _textView.backgroundColor = UIColorWithRGBA(242, 242, 242, 1);
            [cell addSubview:_textView];
            [_textView addSubview:_placeHolder];
        }

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else if (indexPath.row == 1) {

        //显示所在位置
        static NSString *cellID      = @"localCell";
        FriendsCircleLocalCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [[FriendsCircleLocalCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //隐藏
        cell.hidden = YES;
        return cell;
    } else {

        //上传图片
        static NSString *cellID = @"uploadImg";
        UploadImageCell *cell   = [_tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [[UploadImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }
        [cell.btn1 addTarget:self action:@selector(uploadImg:) forControlEvents:UIControlEventTouchUpInside];

        for (int i = 0; i < _imgArray.count; i++) {
            UIButton *btn = (UIButton *) [cell viewWithTag:(100 + i)];
            btn.hidden    = NO;
            [btn setBackgroundImage:_imgArray[i] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(uploadImg:) forControlEvents:UIControlEventTouchUpInside];
        }

        //给按钮赋 + 图片
        if (_imgArray.count != 9) {
            UIButton *btn = (UIButton *) [cell viewWithTag:(100 + _imgArray.count)];
            btn.hidden    = NO;
            [btn setBackgroundImage:[UIImage imageNamed:@"button"] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(uploadImg:) forControlEvents:UIControlEventTouchUpInside];

            _addBtn = btn;
            //给Cell设置高度
            CGRect rect      = cell.frame;
            rect.size.height = (_imgArray.count / 3 + 1) * 80 + 20;
            cell.frame       = rect;
        } else {
            //给Cell设置高度
            CGRect rect      = cell.frame;
            rect.size.height = (_imgArray.count / 3) * 80 + 20;
            cell.frame       = rect;
        }

        if (_imgArray.count) {
            //隐藏lable
            cell.reminderLabel.hidden = YES;
        } else {
            _addBtn                   = cell.btn1;
            cell.reminderLabel.hidden = NO;
        }

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.row == 0) {
        return 150;
    }
    else if (indexPath.row == 1) {
        return  0.01;
    }
    else if (indexPath.row == 2) {
        UITableViewCell *cell = [self tableView:_tableView cellForRowAtIndexPath:indexPath];
        return cell.frame.size.height;
    }
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {

    return 0.1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - 照相
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        if (buttonIndex == 0) {
            mediaType = IQMediaPickerControllerMediaTypePhotoLibrary;
        } else if (buttonIndex == 1) {
            if (_imgArray.count < 9) {
                UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
                UIImagePickerController *picker              = [[UIImagePickerController alloc] init];
                picker.delegate                              = self;
                //设置拍照后的图片可被编辑
                picker.allowsEditing = YES;
                picker.sourceType    = sourceType;
                [self presentModalViewController:picker animated:YES];
            } else {
                [EageProgressHUD eage_showUserNotification:UserNotificationStateFailure message:@"照片超过9张"];
            }
        }

        IQMediaPickerController *controller = [[IQMediaPickerController alloc] init];
        controller.delegate                 = self;
        [controller setMediaType:mediaType];
        //限制选取照片最多数量
        controller.maxPhotoCount              = 9 - _imgArray.count;
        controller.allowsPickingMultipleItems = YES;
        [self presentViewController:controller animated:YES completion:nil];
    }
}

- (void)mediaPickerControllerDidCancel:(IQMediaPickerController *)controller;
{
    _tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    NSLog(@"取消");
}
- (void)mediaPickerController:(IQMediaPickerController *)controller didFinishMediaWithInfo:(NSDictionary *)info;
{
    NSLog(@"Info: %@", info);

    //    UploadImageCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"uploadImg"];

    for (int i = 0; i < [[info objectForKey:@"IQMediaTypeImage"] count]; i++) {
        UIImage *image = [info objectForKey:@"IQMediaTypeImage"][i][@"IQMediaImage"];
        [_imgArray addObject:[image normalizedImage]];
    }

    //    if (controller == _controller1){
    //
    //        if (!_licenseImage) {
    //            _licenseImage = [[UIImage alloc]init];
    //        }
    //        _licenseImage = [info objectForKey:@"IQMediaTypeImage"][0][@"IQMediaImage"];
    //
    //    }else if (controller == _controller2){
    //
    //        for (NSDictionary *dict in [info objectForKey:@"IQMediaTypeImage"]) {
    //            [_mainPhotoArray addObject:dict[@"IQMediaImage"]];
    //        }
    //    }else{
    //
    //        for (NSDictionary *dict in [info objectForKey:@"IQMediaTypeImage"]) {
    //            [_innerPhotoArray addObject:dict[@"IQMediaImage"]];
    //        }
    //    }

    _tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);

    [_tableView reloadData];
}

#pragma mark - UIImagePickerControllerDelegate  图片处理
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

    NSLog(@"Picker returned successfully.");
    //    将选择的图片在imageView上显示
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [_imgArray addObject:[image normalizedImage]];
    //处理完毕，回到个人信息页面
    [picker dismissViewControllerAnimated:YES completion:nil];
    //    [self layoutPhotosAndOthers];
    [_tableView reloadData];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {

    NSLog(@"Picker was cancelled");
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    if (textView.text.length) {
        [_placeHolder removeFromSuperview];
    } else {
        [_textView addSubview:_placeHolder];
    }
}
@end
