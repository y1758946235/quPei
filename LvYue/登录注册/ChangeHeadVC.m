//
//  ChangeHeadVC.m
//  LvYue
//
//  Created by X@Han on 16/12/29.
//  Copyright © 2016年 OLFT. All rights reserved.
//


#import "ChangeHeadVC.h"
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
#import "perfactInfoVC.h"

#define kMaxRequiredCount 1

@interface ChangeHeadVC ()<IQMediaPickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate>{
    UILabel *backgroundLabel;
}

@property (nonatomic,strong) UIScrollView *rootScroll;
@property (nonatomic,strong) UIImageView *headImg;
@property (nonatomic,strong) NSMutableArray *imageArray;
@property (nonatomic,strong) NSData *photoData;
@property (nonatomic,strong) NSString *token;


@property (nonatomic,strong) NSOperationQueue *queue;

//保存媒体拾取类型
@property (nonatomic, assign) IQMediaPickerControllerMediaType mediaType;

@end

@implementation ChangeHeadVC

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
    UILabel *titleLable = [[UILabel alloc]init];
    titleLable.frame = CGRectMake(40, 40, SCREEN_WIDTH-80, 80);
    titleLable.lineBreakMode = NSLineBreakByWordWrapping;
    titleLable.numberOfLines = 0;
    titleLable.textAlignment = NSTextAlignmentCenter;
    titleLable.font = [UIFont fontWithName:@"PingFangSC-Light" size:15];
    titleLable.text = @"在这里，没有真实头像的人是交不到朋友的";
    [self.view addSubview:titleLable];
    NSRange range1 = [titleLable.text rangeOfString:@"真实头像"];
    [self setTextColor:titleLable FontNumber:[UIFont fontWithName:@"PingFangSC-Light" size:17]AndRange:range1 AndColor:[UIColor colorWithHexString:@"#ff5252"]];
    
   
    
    UILabel *detailLable = [[UILabel alloc]init];
    detailLable.backgroundColor = [UIColor colorWithHexString:@"#f2f2f2"];
    detailLable.frame = CGRectMake(SCREEN_WIDTH/2 -30, 150*AutoSizeScaleX, SCREEN_WIDTH/2, 100);
    detailLable.textColor = [UIColor colorWithHexString:@"#424242"];
    detailLable.font = [UIFont fontWithName:@"PingFangSC-Light" size:13];
    detailLable.lineBreakMode = NSLineBreakByWordWrapping;
    detailLable.numberOfLines = 0;
    detailLable.textAlignment = NSTextAlignmentLeft;
    detailLable.text = @"不被展示、无人访问\n\n搭讪没人理睬\n\n头像不规范，立马被删除";
    [self.view addSubview:detailLable];
    
    self.headImg = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 -140, 150*AutoSizeScaleX, 100, 100)];
   
    if (self.headImage) {
         self.headImg.image = self.headImage;
    }else{
        self.headImg.image = [UIImage imageNamed:@"默认头像"];
    }
    self.headImg.backgroundColor = [UIColor colorWithHexString:@"ffffff"];
    self.headImg.userInteractionEnabled = YES;
    self.headImg.layer.cornerRadius = 50;
    self.headImg.clipsToBounds = YES;
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeImage)];
//    [self.headImg addGestureRecognizer:tap];
    [self.rootScroll addSubview:self.headImg];
    
 
    
    //上传头像
    UIButton *upBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    upBtn.center =  CGPointMake(kMainScreenWidth / 2, self.headImg.frame.origin.y + self.headImg.frame.size.height + 100);
    upBtn.bounds = CGRectMake(0, 0, 220, 40);
    upBtn.layer.cornerRadius =20;
    upBtn.clipsToBounds = YES;
    [upBtn.layer setBorderWidth:1];
    [upBtn.layer setBorderColor:[UIColor colorWithHexString:@"#ff5252"].CGColor];

    [upBtn addTarget:self action:@selector(changeImage) forControlEvents:UIControlEventTouchUpInside];
    [upBtn setTitle:@"获取图片" forState:UIControlStateNormal];
    [upBtn setTitleColor:[UIColor colorWithHexString:@"#ff5252"] forState:UIControlStateNormal];
    [self.rootScroll addSubview:upBtn];
    
    //保存头像
    UIButton *changeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    changeBtn.layer.cornerRadius =20;
    changeBtn.clipsToBounds = YES;
    changeBtn.center = CGPointMake(kMainScreenWidth / 2, upBtn.frame.origin.y + upBtn.frame.size.height + 50);
    changeBtn.bounds = CGRectMake(0, 0, 220, 40);

    [changeBtn.layer setBorderWidth:1];
    [changeBtn.layer setBorderColor:[UIColor colorWithHexString:@"#ff5252"].CGColor];
    
  
    [changeBtn addTarget:self action:@selector(changeHead) forControlEvents:UIControlEventTouchUpInside];
    [changeBtn setTitle:@"保存" forState:UIControlStateNormal];
    [changeBtn setTitleColor:[UIColor colorWithHexString:@"#ff5252"] forState:UIControlStateNormal];
    [self.rootScroll addSubview:changeBtn];
    
    
    //取消
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    saveBtn.layer.cornerRadius =20;
    saveBtn.clipsToBounds = YES;
    saveBtn.center = CGPointMake(kMainScreenWidth / 2, changeBtn.frame.origin.y + changeBtn.frame.size.height + 50);
    saveBtn.bounds = CGRectMake(0, 0, 220, 40);
    [saveBtn addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [saveBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    saveBtn.layer.borderWidth = 1;
    saveBtn.layer.borderColor = [UIColor colorWithHexString:@"#ff5252"].CGColor;
    [saveBtn setTitle:@"取消" forState:UIControlStateNormal];
    [saveBtn setTitleColor:[UIColor colorWithHexString:@"#ff5252"] forState:UIControlStateNormal];
    [self.rootScroll addSubview:saveBtn];
    
//    NSString *messageStr = @"只有审核通过的真实头像才能展示在照片墙上哦～\n在这里，没有真实头像的人是交不到朋友的 \n不被展示、无人访问\n搭讪没人理睬\n头像涉及黄赌毒等我们会立即删除";
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:messageStr preferredStyle:UIAlertControllerStyleAlert];
//    
//    
//    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
//   
//            [alertController addAction:ok];
//    [self presentViewController:alertController animated:YES completion:nil];
    
}



//设置不同字体颜色
-(void)setTextColor:(UILabel *)label FontNumber:(id)font AndRange:(NSRange)range AndColor:(UIColor *)vaColor
{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:label.text];
    //设置字号
    [str addAttribute:NSFontAttributeName value:font range:range];
    //设置文字颜色
    [str addAttribute:NSForegroundColorAttributeName value:vaColor range:range];
    
    label.attributedText = str;
}
- (void)changeImage{
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从相册选取", nil];
    [action showInView:self.view];
}



- (void)returnText:(ReturnTextBlock)block {
    self.returnTextBlock = block;
}


//保存头像  把头像传到上一页
- (void)changeHead{
    if ([CommonTool dx_isNullOrNilWithObject:self.imageArray] || self.imageArray.count == 0) {
        [MBProgressHUD showSuccess:@"请选择头像"];
        return;
    }
    
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/config/getQiniuToken",REQUESTHEADER] andParameter:@{} success:^(id successResponse) {
        
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            
            UIImage *image = self.imageArray[0];
            //压缩头像
            self.photoData = UIImageJPEGRepresentation(image, 0.3);
            
            self.token = successResponse[@"data"];
            
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
            
            self.locationString = [NSString stringWithFormat:@"iosLvYueIcon%ld%ld%ld%ld%ld%ld%.2f",(long)year,(long)month,(long)day,(long)hour,(long)minute,(long)second,percent];
            
            //七牛上传图片
            
            QNUploadManager *upManager = [[QNUploadManager alloc] init];
            [upManager putData:self.photoData key:self.locationString token:self.token
                      complete: ^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                          NSLog(@"%@", info);
                          NSLog(@"%@", resp);
                          if (resp == nil) {
                              [MBProgressHUD hideHUD];
                              [MBProgressHUD showError:@"上传失败"];
//                              return ;
                          }else{
                              
                              
                                [self performSelector:@selector(lockDiao) withObject:self afterDelay:2];
                          }
                      }option:nil];
            
        
        

           // NSLog(@"999999999999999999999999%@",self.locationString);
        
    }
     } andFailure:^(id failureResponse) {
         
    [MBProgressHUD hideHUD];
    [MBProgressHUD showError:@"服务器繁忙,请重试"];
}];
    
  

}


- (void)lockDiao{
    
    if (self.returnTextBlock != nil) {
        
        if (self.imageArray.count!=0) {
         self.returnTextBlock(self.locationString,(UIImage *)self.imageArray[0]);
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
    
}
//取消保存头像
- (void)cancel{
    
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
        backgroundLabel.hidden = YES;
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
