//
//  PublishVideoViewController.m
//  LvYue
//
//  Created by apple on 16/1/2.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "MBProgressHUD+NJ.h"
#import "PublishVideoViewController.h"
#import "QiniuSDK.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface PublishVideoViewController () <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIAlertViewDelegate> {
    BOOL _isBeginEditing; //是否开始编辑
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) UIImageView *imageView; //预览图
@property (nonatomic, strong) UITextView *videoDescView;
@property (nonatomic, strong) UILabel *categoryLabel; //分类Label

//分类选择
@property (nonatomic, strong) UIPickerView *pickerView; //分类选择器
@property (nonatomic, strong) UIButton *pickerCover;    //选择器蒙层
@property (nonatomic, strong) UIView *assistentView;    //辅助工具条
@property (nonatomic, strong) NSArray *categoryArray;   //分类数组

@property (nonatomic, strong) MPMoviePlayerViewController *player; //预览播放器

@property (nonatomic, copy) NSString *category;   //分类名字
@property (nonatomic, copy) NSString *categoryID; //分类ID

@end

@implementation PublishVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;
    self.title                                    = @"发布";
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    [self setLeftButton:nil title:@"取消" target:self action:@selector(cancel:)];
    //init property
    self.category   = @"请选择分类";
    self.categoryID = @"";
    //add subview
    [self.view addSubview:self.tableView];
//    [self.view addSubview:self.pickerCover];
//    [self.view addSubview:self.assistentView];
//    [self.view addSubview:self.pickerView];
    //请求预览视频截图
    [self thumbnailImageRequest:0.0f withURL:[NSURL fileURLWithPath:self.videoPath]];
    //add notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resizeKeyboard:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideKeyboard:) name:UIKeyboardWillHideNotification object:nil];
    //加载选择器的内容
    [self loadPickerViewContents];
}


- (void)cancel:(UIButton *)sender {

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确定要放弃发布吗" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (UITableView *)tableView {
    if (!_tableView) {
        _tableView                 = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight - 64) style:UITableViewStyleGrouped];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.dataSource      = self;
        _tableView.delegate        = self;
        _tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
        _tableView.tableHeaderView = self.headerView;
        _tableView.tableFooterView = self.footerView;
    }
    return _tableView;
}


- (UIView *)headerView {
    if (!_headerView) {
        _headerView                 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 250)];
        _headerView.backgroundColor = [UIColor whiteColor];
        //title
        UILabel *titleLabel        = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 70, 30)];
        titleLabel.text            = @"视频预览";
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor       = [UIColor grayColor];
        titleLabel.textAlignment   = NSTextAlignmentLeft;
        titleLabel.font            = kFont14;
        //imageView
        UIView *container              = [[UIView alloc] initWithFrame:CGRectMake(15, 30, kMainScreenWidth - 30, 220)];
        container.backgroundColor      = [UIColor blackColor];
        _imageView                     = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, container.frame.size.width, container.frame.size.height)];
        _imageView.backgroundColor     = [UIColor clearColor];
        _imageView.contentMode         = UIViewContentModeScaleAspectFit;
        _imageView.layer.masksToBounds = YES;
        //playBtn
        UIButton *playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [playBtn setFrame:CGRectMake((kMainScreenWidth - 30) / 2 - 25, 85, 50, 50)];
        [playBtn setBackgroundImage:[UIImage imageNamed:@"多边形-9"] forState:UIControlStateNormal];
        [playBtn addTarget:self action:@selector(playPreviewVideo:) forControlEvents:UIControlEventTouchUpInside];
        //add
        [_headerView addSubview:titleLabel];
        [container addSubview:_imageView];
        [container addSubview:playBtn];
        [_headerView addSubview:container];
    }
    return _headerView;
}


- (UIView *)footerView {
    if (!_footerView) {
        _footerView                 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 50)];
        _footerView.backgroundColor = [UIColor clearColor];
        UIButton *publishBtn        = [UIButton buttonWithType:UIButtonTypeCustom];
        publishBtn.frame            = CGRectMake(10, 0, kMainScreenWidth - 20, 44);
        publishBtn.backgroundColor  = RGBACOLOR(29, 189, 159, 1.0);
        [publishBtn setTitle:@"发   布" forState:UIControlStateNormal];
        [publishBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        publishBtn.titleLabel.font     = kFontBold17;
        publishBtn.layer.cornerRadius  = 5.0;
        publishBtn.layer.masksToBounds = YES;
        [publishBtn addTarget:self action:@selector(publishMyVideo:) forControlEvents:UIControlEventTouchUpInside];
        [_footerView addSubview:publishBtn];
    }
    return _footerView;
}


- (MPMoviePlayerViewController *)player {
    if (!_player) {
        _player                            = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:self.videoPath]];
        _player.moviePlayer.shouldAutoplay = YES;
    }
    return _player;
}


- (UITextView *)videoDescView {
    if (!_videoDescView) {
        _videoDescView                 = [[UITextView alloc] initWithFrame:CGRectMake(10, 30, kMainScreenWidth - 20, 120)];
        _videoDescView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _videoDescView.textColor       = [UIColor grayColor];
        _videoDescView.font            = kFont13;
        _videoDescView.returnKeyType   = UIReturnKeyDone;
        _videoDescView.delegate        = self;
    }
    return _videoDescView;
}


- (UIPickerView *)pickerView {
    if (!_pickerView) {
        _pickerView                 = [[UIPickerView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height + 30, kMainScreenWidth, 162)];
        _pickerView.backgroundColor = [UIColor whiteColor];
        _pickerView.dataSource      = self;
        _pickerView.delegate        = self;
    }
    return _pickerView;
}


- (UIButton *)pickerCover {
    if (!_pickerCover) {
        _pickerCover                 = [UIButton buttonWithType:UIButtonTypeCustom];
        _pickerCover.frame           = self.view.frame;
        _pickerCover.backgroundColor = [UIColor blackColor];
        _pickerCover.alpha           = 0.0;
        [_pickerCover addTarget:self action:@selector(cancelCover:) forControlEvents:UIControlEventTouchDown];
    }
    return _pickerCover;
}


- (UIView *)assistentView {
    if (!_assistentView) {
        _assistentView                 = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, kMainScreenWidth, 30)];
        _assistentView.backgroundColor = [UIColor whiteColor];
        UIButton *finishBtn            = [UIButton buttonWithType:UIButtonTypeCustom];
        finishBtn.frame                = CGRectMake(kMainScreenWidth - 50, 0, 40, 30);
        [finishBtn setTitle:@"完成" forState:UIControlStateNormal];
        [finishBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        finishBtn.titleLabel.font = kFont15;
        [finishBtn addTarget:self action:@selector(finishPicker:) forControlEvents:UIControlEventTouchUpInside];
        [_assistentView addSubview:finishBtn];
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelBtn.frame     = CGRectMake(10, 0, 40, 30);
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [cancelBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        cancelBtn.titleLabel.font = kFont15;
        [cancelBtn addTarget:self action:@selector(cancelPicker:) forControlEvents:UIControlEventTouchUpInside];
        [_assistentView addSubview:cancelBtn];
    }
    return _assistentView;
}


//预览视频
- (void)playPreviewVideo:(UIButton *)sender {
    _player = nil;
    [self presentMoviePlayerViewControllerAnimated:self.player];
}


//加载选择器的内容
- (void)loadPickerViewContents {

    [MBProgressHUD showMessage:nil toView:self.view];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/video/videoType", REQUESTHEADER] andParameter:@{} success:^(id successResponse) {
        MLOG(@"全部视频分类 : %@", successResponse);
        if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            self.categoryArray = successResponse[@"data"][@"data"];
            //更新选择器
            [self.pickerView reloadAllComponents];
        } else {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
    }
        andFailure:^(id failureResponse) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }];
}


#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {

    return self.categoryArray.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    MLOG(@"%@", [NSString stringWithFormat:@"%@", self.categoryArray[row][@"value"]]);
    return [NSString stringWithFormat:@"%@", self.categoryArray[row][@"value"]];
}


#pragma mark - UIPickerViewDelegate
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {

    _category = [NSString stringWithFormat:@"%@", self.categoryArray[row][@"value"]];
}


//调整PickerView文本的格式
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {

    UILabel *pickerLabel = (UILabel *) view;
    if (!pickerLabel) {
        pickerLabel                           = [[UILabel alloc] init];
        pickerLabel.adjustsFontSizeToFitWidth = YES;
        [pickerLabel setTextAlignment:NSTextAlignmentCenter];
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
        [pickerLabel setFont:[UIFont boldSystemFontOfSize:20]];
    }
    pickerLabel.text = [self pickerView:pickerView titleForRow:row forComponent:component];
    return pickerLabel;
}


#pragma mark - UITableViewDataSouce
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    if (indexPath.row == 0) { //选择分类
        UILabel *titleLabel      = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 60, 64)];
        titleLabel.text          = @"视频分类";
        titleLabel.textColor     = [UIColor grayColor];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.font          = kFont14;
        [cell addSubview:titleLabel];
        UILabel *categoryLabel      = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(titleLabel.frame), 0, kMainScreenWidth - CGRectGetMaxX(titleLabel.frame) - 40, 64)];
        categoryLabel.textAlignment = NSTextAlignmentRight;
        categoryLabel.textColor     = [UIColor grayColor];
        categoryLabel.font          = kFont14;
        categoryLabel.text          = self.category;
        [cell addSubview:categoryLabel];
        self.categoryLabel  = categoryLabel;
        cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //隐藏cell
        cell.hidden = YES;
    } else { //视频描述
        UILabel *titleLabel      = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 200, 20)];
        titleLabel.text          = @"视频描述(最多不超过200个字)";
        titleLabel.textColor     = [UIColor grayColor];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.font          = kFont14;
        [cell addSubview:titleLabel];
        [cell addSubview:self.videoDescView];
        cell.accessoryType  = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    if (indexPath.row == 0) { //点击选择分类
//        [_tableView endEditing:YES];
//        //设置默认选中第一行
//        [self pickerView:self.pickerView didSelectRow:0 inComponent:0];
//        [self.pickerView selectRow:0 inComponent:0 animated:NO];
//        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//            self.pickerCover.alpha   = 0.4;
//            self.assistentView.frame = CGRectMake(0, self.view.frame.size.height - self.pickerView.frame.size.height - 30, self.assistentView.frame.size.width, self.assistentView.frame.size.height);
//            self.pickerView.frame    = CGRectMake(0, self.view.frame.size.height - self.pickerView.frame.size.height, self.pickerView.frame.size.width, self.pickerView.frame.size.height);
//        }
//                         completion:nil];
//    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
//        return 64.0;
        return 0.01f;
    } else {
        return 150.0f;
    }
}


#pragma mark - Private
/**
 *  截取指定时间的视频缩略图
 *
 *  @param timeBySecond 时间点
 */
- (void)thumbnailImageRequest:(CGFloat)timeBySecond withURL:(NSURL *)url {
    //异步并发截取
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //根据url创建AVURLAsset
        AVURLAsset *urlAsset = [AVURLAsset assetWithURL:url];
        //根据AVURLAsset创建AVAssetImageGenerator
        AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlAsset];
        /*截图
         * requestTime:缩略图创建时间
         * actualTime:缩略图实际生成的时间
         */
        NSError *error = nil;
        CMTime time    = CMTimeMakeWithSeconds(timeBySecond, 10); //CMTime是表示电影时间信息的结构体，第一个参数表示是视频第几秒，第二个参数表示每秒帧数.(如果要活的某一秒的第几帧可以使用CMTimeMake方法)
        CMTime actualTime;
        CGImageRef cgImage = [imageGenerator copyCGImageAtTime:time actualTime:&actualTime error:&error];
        if (error) {
            NSLog(@"截取视频缩略图时发生错误，错误信息：%@", error.localizedDescription);
            return;
        }
        CMTimeShow(actualTime);
        UIImage *image = [UIImage imageWithCGImage:cgImage]; //转化为UIImage
        //回到主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.imageView setImage:image];
            CGImageRelease(cgImage);
        });
    });
}


/**
 *  获取网络视频的时长
 *
 *  @param videoURL 视频URL
 *
 *  @return 时长
 */
- (NSTimeInterval)fetchVideoDurationWithVideoURL:(NSURL *)videoURL {
    AVURLAsset *audioAsset       = [AVURLAsset URLAssetWithURL:videoURL options:nil];
    CMTime audioDuration         = audioAsset.duration;
    NSTimeInterval videoDuration = CMTimeGetSeconds(audioDuration);
    return videoDuration;
}


//键盘出现时
- (void)resizeKeyboard:(NSNotification *)aNotification {
    CGFloat height           = [self getKeyboardHeight:aNotification].size.height;
    double animationDuration = [aNotification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:animationDuration animations:^{
        self.tableView.frame         = CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight - 64 - height);
        CGPoint point                = self.tableView.contentOffset;
        point.y                      = height + 25;
        self.tableView.contentOffset = point;
    }];
}


//键盘已缩回时
- (void)hideKeyboard:(NSNotification *)aNotification {
    double animationDuration = [aNotification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:animationDuration animations:^{
        self.tableView.frame = CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight - 64);
    }];
}


//获取键盘高度
- (CGRect)getKeyboardHeight:(NSNotification *)aNotification {
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue        = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect    = [aValue CGRectValue];
    return keyboardRect;
}


//点击发布
- (void)publishMyVideo:(UIButton *)sender {
//    if (![self.categoryID isEqualToString:@""] && self.categoryID) {
//        [self loadVideo];
//    } else {
//        [MBProgressHUD showError:@"请选择视频类型"];
//    }
    [self loadVideo];
}


//点击蒙层
- (void)cancelCover:(UIButton *)sender {

    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.pickerCover.alpha   = 0.0;
        self.assistentView.frame = CGRectMake(0, self.view.frame.size.height, self.assistentView.frame.size.width, self.assistentView.frame.size.height);
        self.pickerView.frame    = CGRectMake(0, self.view.frame.size.height + 30, self.pickerView.frame.size.width, self.pickerView.frame.size.height);
    }
                     completion:nil];

    //回到初始值
    _category = self.categoryLabel.text;
}


#pragma mark - 监听点击辅助工具条按钮
//点击完成
- (void)finishPicker:(UIButton *)sender {
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.pickerCover.alpha   = 0.0;
        self.assistentView.frame = CGRectMake(0, self.view.frame.size.height, self.assistentView.frame.size.width, self.assistentView.frame.size.height);
        self.pickerView.frame    = CGRectMake(0, self.view.frame.size.height + 30, self.pickerView.frame.size.width, self.pickerView.frame.size.height);
    }
                     completion:nil];

    self.categoryLabel.text = self.category;
    NSInteger index         = [self.pickerView selectedRowInComponent:0];
    self.categoryID         = [NSString stringWithFormat:@"%@", self.categoryArray[index][@"id"]];
}


- (void)cancelPicker:(UIButton *)sender {
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.pickerCover.alpha   = 0.0;
        self.assistentView.frame = CGRectMake(0, self.view.frame.size.height, self.assistentView.frame.size.width, self.assistentView.frame.size.height);
        self.pickerView.frame    = CGRectMake(0, self.view.frame.size.height + 30, self.pickerView.frame.size.width, self.pickerView.frame.size.height);
    }
                     completion:nil];

    //回到初始值
    _category = self.categoryLabel.text;
}


#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    _isBeginEditing = YES;
    return YES;
}


- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    _isBeginEditing = NO;
    if (textView.text.length > 200) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"描述不能超过200个字符,已自动保留前200个字符" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil] show];
        textView.text = [textView.text substringWithRange:NSMakeRange(0, 200)];
    }
    return YES;
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [self.view endEditing:YES];
        return NO;
    } else {
        return YES;
    }
}


#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (1 == buttonIndex) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


#pragma mark - 七牛上传视频
- (void)loadVideo {
    //判断视频
    NSString* nameStr;
    if (self.isFriendVideo == YES) {
        nameStr = @"朋友圈";
    }
    else {
        nameStr = @"形象";
    }
    //获取视频时长
    NSTimeInterval videoDuration = [self fetchVideoDurationWithVideoURL:[NSURL fileURLWithPath:self.videoPath]];
    MLOG(@"视频时长 : %lf", videoDuration);
    if (videoDuration >= 60.0f) {
        [MBProgressHUD showMessage:@"由于视频略大,请稍等片刻.." toView:self.view];
    } else {
        [MBProgressHUD showMessage:@"正在上传视频,请稍候.." toView:self.view];
    }
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/getQiniuToken", REQUESTHEADER] andParameter:@{} success:^(id successResponse) {
        if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
            NSData *videoData = [[NSData alloc] initWithContentsOfFile:self.videoPath];
            NSString *token   = successResponse[@"data"][@"qiniuToken"];

            //获取当前时间
            NSDate *now                     = [NSDate date];
            NSCalendar *calendar            = [NSCalendar currentCalendar];
            NSUInteger unitFlags            = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
            NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
            NSInteger year                  = [dateComponent year];
            NSInteger month                 = [dateComponent month];
            NSInteger day                   = [dateComponent day];
            NSInteger hour                  = [dateComponent hour];
            NSInteger minute                = [dateComponent minute];
            NSInteger second                = [dateComponent second];
    
            
            NSString *locationString = [NSString stringWithFormat:@"iosLvYueVideoCircle_VideoByLoader%@_%ld%ld%ld%ld%ld%ld/%@视频.mp4", [LYUserService sharedInstance].userID, (long) year, (long) month, (long) day, (long) hour, (long) minute, (long) second, nameStr];

            //七牛上传视频
            QNUploadManager *upManager = [[QNUploadManager alloc] init];
            [upManager putData:videoData key:locationString token:token
                      complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                          NSLog(@"%@", info);
                          NSLog(@"%@", resp);

                          if (resp == nil) {
                              [MBProgressHUD hideHUDForView:self.view animated:YES];
                              [MBProgressHUD showError:@"视频发布失败,请检查网络"];
                          } else {
                              //服务器视频同步备份
//                              [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/video/add", REQUESTHEADER] andParameter:@{ @"token": token,
//                                                                                                                                                    @ sharedInstance].userID,
//                                                                                                                                                    @"type": self.categoryID,
//                                                                                                                                                    @"video": locationString,
//                                                                                                                                                    @"describe": self.videoDescView.text }
//                                  success:^(id successResponse) {
//                                      if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
//                                          [MBProgressHUD hideHUDForView:self.view animated:YES];
//                                          [MBProgressHUD showSuccess:@"上传成功"];
//                                          [self.navigationController popViewControllerAnimated:YES];
//                                      } else {
//                                          [MBProgressHUD hideHUDForView:self.view animated:YES];
//                                          [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"msg"]]];
//                                      }
//                                  }
//                                  andFailure:^(id failureResponse) {
//                                      [MBProgressHUD hideHUDForView:self.view animated:YES];
//                                      [MBProgressHUD showError:@"请检查网络"];
//                                  }];
                              
                              [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/notice/publish", REQUESTHEADER] andParameter:@{
                                                @"publisher": [NSString stringWithFormat:@"%@", [LYUserService sharedInstance].userID],
                                                @"noticeDetail": self.videoDescView.text,
                                                @"photos": @"",
                                                @"noticeType":@"0",
                                                @"hotId":@"0",
                                                @"nType":@"2",
                                                @"videoUrl":locationString
                                                }
                                                          success:^(id successResponse) {
                                                              MLOG(@"发送朋友圈:%@", successResponse);
                                                              
                                                              if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
                                                                  [MBProgressHUD hideHUDForView:self.view];
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
                          }
                      }
                        option:nil];
        } else {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"msg"]]];
        }
    }
        andFailure:^(id failureResponse) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [MBProgressHUD showError:@"服务器繁忙,请重试"];
        }];
}


@end
