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
    UITableViewDelegate,UITextFieldDelegate> {

    UITextView *markView;
    UIButton *_addBtn;
    UILabel *placeholder;

    IQMediaPickerControllerMediaType mediaType;
    NSMutableArray *_imgArray;
        NSString * token;
        
        UITextField * goldTF;
        
        UIImagePickerController *picker;
        IQMediaPickerController *IQMediaPickerVC;
}

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation LYEssenceImageUploadViewController
-(void)viewWillAppear:(BOOL)animated{
    picker.delegate = nil;
    IQMediaPickerVC.delegate = nil;
}
- (void)viewDidLoad {
    [super viewDidLoad];

    [self setNav];
//    self.view.backgroundColor = [UIColor colorWithRed:244 / 255.0 green:245 / 255.0 blue:246 / 255.0 alpha:1];
    self.view.backgroundColor = [UIColor whiteColor];
    _imgArray                 = [NSMutableArray array];
    [self setUI];
}

- (void)setNav{
    self.title = @"上传到相册";
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithHexString:@"#424242"],UITextAttributeTextColor, [UIFont fontWithName:@"PingFangSC-Medium" size:18],UITextAttributeFont, nil]];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:@"#ffffff"];
    //导航栏返回按钮
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(16, 38, 28, 14)];
    [button setTitleColor:[UIColor colorWithHexString:@"#424242"] forState:UIControlStateNormal];
    [button setTitle:@"返回" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [button addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = back;
    
    //导航栏充值记录按钮
    UIButton *edit = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-16-28, 38, 56, 14)];
    [edit setTitleColor:[UIColor colorWithHexString:@"#ff5252"] forState:UIControlStateNormal];
   
    [edit setTitle:@"确定上传" forState:UIControlStateNormal];
    
    
    edit.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [edit addTarget:self action:@selector(uploadPhoto) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *edited = [[UIBarButtonItem alloc]initWithCustomView:edit];
    self.navigationItem.rightBarButtonItem = edited;
    
    
}

- (void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark   ----确定上传
- (void)uploadPhoto {
    if (_imgArray.count == 0) {
        [MBProgressHUD showError:@"请您添加一张图片" toView:self.view];
        return;
    }else{
        [self updata];
    }

//    UIAlertView *alert   = [[UIAlertView alloc] init];
//    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
//    alert.title          = @"趣陪";
//    alert.message        = @"请输入查看该相片最低打赏金币数";
//    [alert addButtonWithTitle:@"取消"];
//    [alert addButtonWithTitle:@"确定"];
//    UITextField *textField = [alert textFieldAtIndex:0];
//    textField.keyboardType = UIKeyboardTypeNumberPad;
//    alert.delegate         = self;
//    [alert show];
}


- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setUI {
    goldTF  = [[UITextField alloc]init];
    goldTF.backgroundColor = [UIColor whiteColor];
    goldTF.placeholder = @"打赏金币(1至100范围内)，不填则为普通照片";
    goldTF.delegate = self;
    [goldTF addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    goldTF.font = [UIFont systemFontOfSize:13];
    goldTF.frame = CGRectMake(15, 10, SCREEN_WIDTH-30, 40);
    goldTF.keyboardType = UIKeyboardTypeNumberPad;;
    [self.view addSubview:goldTF];
    
    
    markView               = [[UITextView alloc] initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH - 20, 150)];
    markView.delegate      = self;
    markView.font          = [UIFont systemFontOfSize:15];
    markView.returnKeyType = UIReturnKeyDone;

    placeholder               = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, SCREEN_WIDTH, 20)];
    placeholder.text          = @"添加照片说明(限30字)";
    placeholder.textColor     = [UIColor lightGrayColor];
    placeholder.font          = [UIFont systemFontOfSize:15];
    placeholder.textAlignment = NSTextAlignmentLeft;
    [markView addSubview:placeholder];

    _tableView           = [[UITableView alloc] initWithFrame:CGRectMake(0, 50, self.view.frame.size.width, self.view.frame.size.height-50) style:UITableViewStylePlain];
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

//        if (_imgArray.count == 1) {
//            [MBProgressHUD showError:@"需要打赏的照片每次只能上传一张哦"];
//            return;
//        }

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
        return 160;
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
              picker              = [[UIImagePickerController alloc] init];
                picker.delegate                              = self;
                //设置拍照后的图片可被编辑
                picker.allowsEditing = YES;
                picker.sourceType    = sourceType;
                [self presentModalViewController:picker animated:YES];
            } else {
                [EageProgressHUD eage_showUserNotification:UserNotificationStateFailure message:@"照片超过9张"];
            }
        }

      IQMediaPickerVC = [[IQMediaPickerController alloc] init];
        IQMediaPickerVC.delegate                 = self;
        [IQMediaPickerVC setMediaType:mediaType];
        //限制选取照片最多数量
        IQMediaPickerVC.maxPhotoCount              = 9 - _imgArray.count;
        IQMediaPickerVC.allowsPickingMultipleItems = YES;
        [self presentViewController:IQMediaPickerVC animated:YES completion:nil];
    }
}

- (void)mediaPickerControllerDidCancel:(IQMediaPickerController *)controller;
{
    _tableView.frame = CGRectMake(0, 50, SCREEN_WIDTH, SCREEN_HEIGHT-50-64);
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

    _tableView.frame = CGRectMake(0, 50, SCREEN_WIDTH, SCREEN_HEIGHT-50-64);

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

#pragma mark - UITextfieldDelegate
- (void)textFieldDidChange:(UITextField *)textField{
    if ([goldTF.text integerValue] >100) {
        textField.text = [textField.text substringToIndex:goldTF.text.length-1];
        [MBProgressHUD showSuccess:@"金币数不能大于100哦"];
    }
}


#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
 
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    } else {
        return YES;
    }
}

- (void)textViewDidChange:(UITextView *)textView {
  
    placeholder.hidden = YES;
    //取消按钮点击权限，并显示提示文字
    if (textView.text.length == 0) {
        
        placeholder.hidden = NO;
    }
    //字数限制操作
    if (textView.text.length >= 30) {
        
        textView.text = [textView.text substringToIndex:30];
        [MBProgressHUD showSuccess:@"字数不能超过30字哦～～"];
        
    }

}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [textView resignFirstResponder];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - UIAlertViewDelegate

//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex NS_DEPRECATED_IOS(2_0, 9_0) {
-(void)updata{
   

        [MBProgressHUD showMessage:@"正在上传，请稍后..."];
        
        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/config/getQiniuToken",REQUESTHEADER] andParameter:@{} success:^(id successResponse) {
            
            if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
                
                token = successResponse[@"data"];
                
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
               
                //2.将图片传给七牛服务器,并保存图片名
                for (int i = 0; i < _imgArray.count; i++) {
//                    NSString *photoStrng1 ;
                    //            NSString *afer;
                    NSData *photoData ;
                    UIImage *beSendImage = _imgArray[i];
                    photoData = UIImageJPEGRepresentation(beSendImage, 0.3);
                    // NSLog(@"压缩Size of Image(bytes):%d",[photoData length]);
                    UIImage *image       = [UIImage imageWithData:photoData];
                    CGSize size          = CGSizeFromString(NSStringFromCGSize(image.size));
                    CGFloat percent      = size.width / size.height;
                    NSString  *photoStr   = [NSString stringWithFormat:@"iosLvYueFriendCircle%d%d%d%d%d%d(%d)%.2f", year, month, day, hour, minute, second, i, percent];
                    
//                    if (!photoStrng1) {
//                        photoStrng1 = [NSString stringWithFormat:@"%@",photoStr];
//                    }else {
//                        photoStrng1  = [photoStrng1 stringByAppendingString:[NSString stringWithFormat:@",%@", photoStr]];
//                    }
                    
//                    NSLog(@"555555555555555555555555555%@",photoStrng1);
                    //                        afer = [photoStrng1 substringFromIndex:1];
                    //                        NSLog(@"555555555555%@",afer);
                    
                    
                    //七牛上传图片
                    
                    QNUploadManager *upManager = [[QNUploadManager alloc] init];
                    [upManager putData:photoData key:photoStr token:token
                              complete: ^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                                  NSLog(@"info－－－%@", info);
                                  NSLog(@"resp－－－%@", resp);
                                  if (resp == nil) {
                                      [MBProgressHUD hideHUD];
                                      [MBProgressHUD showError:@"上传失败"];
                                      return ;
                                  }else{
                                      [self  fuwuqiGetPhotos:goldTF.text photoStr:photoStr];
                                  }
                              }option:nil];
                    
                    
                   

                    
                }
                
                
                
                
                
            } else {
                [MBProgressHUD hideHUD];
                [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
            }
        } andFailure:^(id failureResponse) {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"服务器繁忙,请重试"];
        }];

//        //1. 获得七牛token
//        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//
//        NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/config/getQiniuToken", REQUESTHEADER];
//        [manager POST:urlStr parameters:@{} success:^(AFHTTPRequestOperation *operation, id responseObject) {
//            NSLog(@"获得七牛TOKEN:%@", responseObject);
//
//            if ([[NSString stringWithFormat:@"%@", responseObject[@"code"]] isEqualToString:@"200"]) {
//                [MBProgressHUD hideHUD];
//                NSString *token = responseObject[@"data"];
//
//                //获取当前时间
//                NSDate *now = [NSDate date];
//                NSLog(@"now date is: %@", now);
//                NSCalendar *calendar            = [NSCalendar currentCalendar];
//                NSUInteger unitFlags            = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
//                NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
//                int year                        = (int) [dateComponent year];
//                int month                       = (int) [dateComponent month];
//                int day                         = (int) [dateComponent day];
//                int hour                        = (int) [dateComponent hour];
//                int minute                      = (int) [dateComponent minute];
//                int second                      = (int) [dateComponent second];
//
//                NSString *photoString1 = @"";
//                //2.将图片传给七牛服务器,并保存图片名
//                for (int i = 0; i < _imgArray.count; i++) {
//                    UIImage *beSendImage = _imgArray[i];
//                    NSData *photoData    = UIImageJPEGRepresentation(beSendImage, 0.3);
//                    UIImage *image       = [UIImage imageWithData:photoData];
//                    CGSize size          = CGSizeFromString(NSStringFromCGSize(image.size));
//                    CGFloat percent      = size.width / size.height;
//                    NSString *photoStr   = [NSString stringWithFormat:@"iosLvYueFriendCircle%d%d%d%d%d%d(%d)%.2f", year, month, day, hour, minute, second, i, percent];
////                    photoString1          = [photoString1 stringByAppendingString:[NSString stringWithFormat:@",%@", photoStr]];
//                    if (!photoString1) {
//                        photoString1 = [NSString stringWithFormat:@"%@",photoStr];
//                    }else {
//                        photoString1  = [photoString1 stringByAppendingString:[NSString stringWithFormat:@",%@", photoStr]];
//                    }
//                    QNUploadManager *upManager = [[QNUploadManager alloc] init];
//                    [upManager putData:photoData key:photoString1 token:token
//                              complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
//                                  NSLog(@"%@", info);
//                                  NSLog(@"%@", resp);
//                                  if (resp == nil) {
//                                      [MBProgressHUD hideHUD];
//                                      [MBProgressHUD showError:@"上传失败"];
//                                      return;
//                                  }
//                              }
//                                option:nil];
//                
//
//                    //3.向后台请求
//                    NSLog(@"4444444444444444444444499999%@",photoString1);
//                    
//                    
//                    NSString *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userId"];
//                    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/addUserPhoto", REQUESTHEADER]
//                        andParameter:@{
//                            @"userId":userId,
//                            @"photoUrl": photoString1,
//                            @"PhotoSignature": markView.text,
//                            @"photopPrice": textField.text
//                        }
//                        success:^(id successResponse) {
//                            MLOG(@"发送精华相册图:%@", successResponse);
//                            if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
//                                [MBProgressHUD hideHUD];
//                                [MBProgressHUD showSuccess:@"提交成功"];
//                                [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadDisposition" object:nil];
//
//                            } else {
//                                [MBProgressHUD hideHUD];
//                                [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"msg"]]];
//                            }
//                        }
//                        andFailure:^(id failureResponse) {
//                            [MBProgressHUD hideHUD];
//                            [MBProgressHUD showError:@"服务器繁忙,请重试"];
//                        }];
//                }
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    [self.navigationController popViewControllerAnimated:YES];
//
//                });
//            } else {
//
//                [MBProgressHUD hideHUD];
//                [MBProgressHUD showError:responseObject[@"errorMsg"]];
//            }
//        }
//            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                NSLog(@"%@", error);
//                [MBProgressHUD hideHUD];
//                [MBProgressHUD showError:@"请检查您的网络"];
//            }];
  
}

-(void)fuwuqiGetPhotos:(NSString *)text photoStr:(NSString *)photoStr{
    NSString *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userId"];
    if (![photoStr isEqualToString:@""]) {
        //服务器获取图片
        NSLog(@"66666666666666666666666666666666660");
        NSLog(@"%@",photoStr);
        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/addUserPhoto",REQUESTHEADER] andParameter:@{
                                                                                                                                    @"userId":userId,
                                                                                                                                    @"photoUrl": photoStr,
                                                                                                                                    @"photoSignature": markView.text,
                                                                                                                                @"photoPrice": text
                                                                                                                                    } success:^(id successResponse) {
                                                                                                                                        
                                                                                                                                        NSLog(@"发布约会:%@",successResponse);
                                                                                                                                        
                                                                                                                                        MLOG(@"结果:%@",successResponse[@"errorMsg"]);
                                                                                                                                        [MBProgressHUD hideHUD];
                                                                                                                                        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
                                                                                                                                            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadDisposition" object:nil userInfo:@{@"push":@"otherHome"}];
                                                                                                                                            
//                                                                                                                                            [MBProgressHUD showSuccess:@"上传成功"];
                                                                                                                                            [self.navigationController popViewControllerAnimated:YES];
                                                                                                                                            
                                                                                                                                        } else {
                                                                                                                                            [MBProgressHUD hideHUD];
                                                                                                                                            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
                                                                                                                                        }
                                                                                                                                    } andFailure:^(id failureResponse) {
                                                                                                                                        [MBProgressHUD hideHUD];
                                                                                                                                        [MBProgressHUD showError:@"服务器繁忙,请重试"];
                                                                                                                                    }];
    }
    
}
@end
