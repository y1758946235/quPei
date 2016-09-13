//
//  LYEssenceImageUploadViewController.m
//  LvYue
//
//  Created by KentonYu on 16/7/30.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"
#import "LYEssenceImageUploadViewController.h"
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "MBProgressHUD+NJ.h"
#import "PhotoDetailViewController.h"
#import "QNUploadManager.h"
#import "UIImage+fixOrientation.h"
#import "UploadImageCell.h"

#import "IQFileManager.h"
#import "IQMediaPickerController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
@interface LYEssenceImageUploadViewController () <
    IQMediaPickerControllerDelegate,
    UITextViewDelegate,
    UIActionSheetDelegate,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate,
    UITableViewDataSource,
    UITableViewDelegate> {

    UITextView *markView;
    UIButton *_addBtn;
    UILabel *placeholder;

    IQMediaPickerControllerMediaType mediaType;
    NSMutableArray *_imgArray;
}

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation LYEssenceImageUploadViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"上传到精华相册";
    [self setLeftButton:nil title:@"取消" target:self action:@selector(back)];
    [self setRightButton:[UIImage imageNamed:@"发送"] title:nil target:self action:@selector(sendClick)];
    self.view.backgroundColor = [UIColor colorWithRed:244 / 255.0 green:245 / 255.0 blue:246 / 255.0 alpha:1];
    _imgArray                 = [NSMutableArray array];
    [self setUI];
}

- (void)sendClick {
    if (_imgArray.count == 0) {
        [MBProgressHUD showError:@"请您添加一张图片" toView:self.view];
        return;
    }

    UIAlertView *alert   = [[UIAlertView alloc] init];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.title          = @"豆客";
    alert.message        = @"请输入查看该精华相片最低打赏金币数";
    [alert addButtonWithTitle:@"取消"];
    [alert addButtonWithTitle:@"确定"];
    UITextField *textField = [alert textFieldAtIndex:0];
    textField.keyboardType = UIKeyboardTypeNumberPad;
    alert.delegate         = self;
    [alert show];
}


- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setUI {

    markView               = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, SCREEN_WIDTH - 20, 200)];
    markView.delegate      = self;
    markView.font          = [UIFont systemFontOfSize:15];
    markView.returnKeyType = UIReturnKeyDone;

    placeholder               = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, SCREEN_WIDTH, 20)];
    placeholder.text          = @"添加气质标签(限30字)";
    placeholder.textColor     = [UIColor lightGrayColor];
    placeholder.font          = [UIFont systemFontOfSize:15];
    placeholder.textAlignment = NSTextAlignmentLeft;
    [markView addSubview:placeholder];

    _tableView                = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    _tableView.delegate       = self;
    _tableView.dataSource     = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick)];
    [_tableView addGestureRecognizer:tap];
}

- (void)tapClick {

    [markView resignFirstResponder];
}

//多选
- (void)uploadImg:(UIButton *)sender {

    //让之前的第一响应者TextField放弃第一响应者
    [markView resignFirstResponder];

    if (sender.tag == _addBtn.tag) {

        if (_imgArray.count == 1) {
            [MBProgressHUD showError:@"每次只能上传一张精华相片"];
            return;
        }

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

#pragma mark - UITableViewDataSource & Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.row == 0) {

        static NSString *cellID = @"textViewCell";
        UITableViewCell *cell   = [_tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];

            [cell addSubview:markView];
        }

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
        return 210;
    } else {
        UITableViewCell *cell = [self tableView:_tableView cellForRowAtIndexPath:indexPath];
        return cell.frame.size.height;
    }
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

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (range.location > 30) {
        [MBProgressHUD showError:@"字数超过限制，限输30字" toView:self.view];
        return NO;
    }
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    } else {
        return YES;
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    if (textView.text.length > 0) {
        placeholder.hidden = YES;
    } else {
        placeholder.hidden = NO;
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [textView resignFirstResponder];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex NS_DEPRECATED_IOS(2_0, 9_0) {
    if (buttonIndex == 1) {
        UITextField *textField = [alertView textFieldAtIndex:0];
        if (!textField.text || [textField.text integerValue] == 0) {
            [MBProgressHUD showError:@"请输入最低打赏金币数"];
            return;
        }

        [MBProgressHUD showMessage:@"正在上传，请稍后..."];
        //1. 获得七牛token
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

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
                for (int i = 0; i < _imgArray.count; i++) {
                    UIImage *beSendImage = _imgArray[i];
                    NSData *photoData    = UIImageJPEGRepresentation(beSendImage, 0.3);
                    UIImage *image       = [UIImage imageWithData:photoData];
                    CGSize size          = CGSizeFromString(NSStringFromCGSize(image.size));
                    CGFloat percent      = size.width / size.height;
                    NSString *photoStr   = [NSString stringWithFormat:@"iosLvYueFriendCircle%d%d%d%d%d%d(%d)%.2f", year, month, day, hour, minute, second, i, percent];
                    photoString          = [photoString stringByAppendingString:[NSString stringWithFormat:@"%@;", photoStr]];

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

                    //3.向后台请求
                    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/addUserImg", REQUESTHEADER]
                        andParameter:@{
                            @"user_id": [LYUserService sharedInstance].userID,
                            @"img_name": photoStr,
                            @"intro": markView.text,
                            @"isEssence": @1,
                            @"bounty": textField.text
                        }
                        success:^(id successResponse) {
                            MLOG(@"发送精华相册图:%@", successResponse);
                            if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
                                [MBProgressHUD hideHUD];
                                [MBProgressHUD showSuccess:@"提交成功"];
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadDisposition" object:nil];

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
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];

                });
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
}


@end
