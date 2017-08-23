//
//  SendDyVideoViewController.m
//  LvYue
//
//  Created by X@Han on 17/5/23.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "SendDyVideoViewController.h"
#import "QiniuSDK.h"
//多媒体拾取器框架
#import "IQMediaPickerController.h"

#import "TZImagePickerController.h"
#import "UIView+Layout.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "TZImageManager.h"
#import "TZVideoPlayerController.h"
#import "TZPhotoPreviewController.h"
#import "TZGifPhotoPreviewController.h"
#import "VideoRecordingVC.h"
@interface SendDyVideoViewController ()<UITextViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,IQMediaPickerControllerDelegate,UIAlertViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,TZImagePickerControllerDelegate>{
    
    UITextView *_textView;
    UILabel *numLabel; //剩余字数的label；
    UILabel *placeholder;
    
    NSString *locationString;//视频上传到服务器的地址
    NSString  *showVideoStr;//视频图片上传到服务器的地址
    
    NSString *photoString;//相片上传到服务器的地址
    IQMediaPickerController *IQMediaPickerVC;
    
    NSMutableArray *_selectedPhotos;
    NSMutableArray *_selectedAssets;
    BOOL _isSelectOriginalPhoto;
    
    
}
@property (nonatomic,strong) NSMutableArray *imageArray;   //上传图片的数组
@property (nonatomic, assign) IQMediaPickerControllerMediaType mediaType;
@property (nonatomic, strong) MPMoviePlayerController *moviePlayer;
@property (nonatomic, strong) UIView *videoAndPhotoView;
@property (nonatomic, strong) UIButton * deleteBtn;
@property (nonatomic, strong) UIView *bootmView;
@property (nonatomic,strong) NSString *token;
@end

@implementation SendDyVideoViewController
-(UIView*)videoAndPhotoView{
    if (!_videoAndPhotoView) {
        
        
        
        _videoAndPhotoView = [[UIView alloc] init];
        _videoAndPhotoView.frame = CGRectMake(16,175 ,SCREEN_WIDTH-32 , 165);
        
        
    }
    return _videoAndPhotoView;
}
-(UIView*)bootmView{
    if (!_bootmView) {
        
        
        
        _bootmView = [[UIView alloc] init];
       
        _bootmView.frame = CGRectMake(0,SCREEN_HEIGHT-64-20-30 ,SCREEN_WIDTH , 50);
        _bootmView.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];
        
    }
    return _bootmView;
}
-(NSMutableArray*)imageArray{
    if (!_imageArray) {
        
        
        
        _imageArray = [[NSMutableArray alloc] init];
        
        
    }
    return _imageArray;
}

-(void)viewWillAppear:(BOOL)animated{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"发布视频";
    if ([CommonTool dx_isNullOrNilWithObject:self.shareTopicId]) {
        self.shareTopicId = @"";
    }
    [self setLeftButton:nil title:@"返回" target:self action:@selector(backClick)];
    [self setRightButton:nil title:@"发布" target:self action:@selector(sendClick)];
    [self creatUI];
    
    [self setTextVi];
    

    
    _selectedPhotos = [NSMutableArray array];
    _selectedAssets = [NSMutableArray array];
   
}
-(void)creatUI{
    [self.view addSubview:self.videoAndPhotoView];
    [self.view addSubview:self.bootmView];
    
   
  
    
    if ([CommonTool dx_isNullOrNilWithObject:self.urlPath] == NO) {
        self.moviePlayer              = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:self.urlPath]];
        self.moviePlayer.controlStyle = MPMovieControlStyleEmbedded;
        self.moviePlayer.scalingMode  = MPMovieScalingModeAspectFit;
        [self.moviePlayer.view setFrame:CGRectMake(0, 15, 150, 150)];
        [self.moviePlayer play];
        [self.videoAndPhotoView addSubview:self.moviePlayer.view];
        
        self.deleteBtn = [[UIButton alloc]init];
        self.deleteBtn.frame = CGRectMake(135, 0, 30, 30);
        [self.deleteBtn setImage:[UIImage imageNamed:@"取消叉叉"] forState:UIControlStateNormal];
        [self.deleteBtn addTarget:self action:@selector(deleteVideo:) forControlEvents:UIControlEventTouchUpInside];
        [self.videoAndPhotoView addSubview:self.deleteBtn];
    }
    
//    UIButton *phtoImageBtn = [[UIButton alloc]init];
//    phtoImageBtn.frame = CGRectMake(16, 10, 30, 30);
////    phtoImageBtn.backgroundColor = [UIColor cyanColor];
//    [phtoImageBtn setImage:[UIImage imageNamed:@"上传照片-1"] forState:UIControlStateNormal];
//    [phtoImageBtn addTarget:self action:@selector(selectImageClick) forControlEvents:UIControlEventTouchUpInside];
//    [self.bootmView addSubview:phtoImageBtn];
    
    UIButton *videoBtn = [[UIButton alloc]init];
//    videoBtn.backgroundColor = [UIColor cyanColor];
    videoBtn.frame = CGRectMake(16, 10, 30, 30);
    [videoBtn setImage:[UIImage imageNamed:@"上传视频icon"] forState:UIControlStateNormal];
    [videoBtn addTarget:self action:@selector(selectVideoClick) forControlEvents:UIControlEventTouchUpInside];
    [self.bootmView addSubview:videoBtn];
    
    
    
}

-(void)selectImageClick{
    
    if (self.imageArray.count >= 3) {
        [MBProgressHUD showError:@"最多只能上传三张"] ;
        return;
    }
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"选择上传方式" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从相册上传", nil];
    action.tag = 1000;
    [action showInView:self.view];
}
-(void)selectVideoClick{
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"选择视频" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"录制",@"本地视频", nil];
    action.tag = 1001;
    [action showInView:self.view];
}
#pragma mark uiactionsheet 代理

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (actionSheet.tag == 1000) {
    
    switch (buttonIndex) {
           
        case 0:
        {
            _mediaType = IQMediaPickerControllerMediaTypePhoto;
            IQMediaPickerVC = [[IQMediaPickerController alloc] init];
            IQMediaPickerVC.delegate = self;
            [IQMediaPickerVC setMediaType:_mediaType];
            [IQMediaPickerVC setModalPresentationStyle:UIModalPresentationPopover];
            IQMediaPickerVC.allowsPickingMultipleItems = YES;
            IQMediaPickerVC.maxPhotoCount = 3;//设置选取照片最大数量为2，并减去已有的照片数量
            [self presentViewController:IQMediaPickerVC animated:YES completion:nil];
        }
            break;
            
        case 1:
        {
            _mediaType = IQMediaPickerControllerMediaTypePhotoLibrary;
            IQMediaPickerVC = [[IQMediaPickerController alloc] init];
            IQMediaPickerVC.delegate = self;
            [IQMediaPickerVC setMediaType:_mediaType];
            [IQMediaPickerVC setModalPresentationStyle:UIModalPresentationPopover];
            IQMediaPickerVC.allowsPickingMultipleItems = YES;
            IQMediaPickerVC.maxPhotoCount = 3-self.imageArray.count;//设置选取照片最大数量为2，并减去已有的照片数量
            
            [self presentViewController:IQMediaPickerVC animated:YES completion:nil];
        }
            break;
            
        default:
            break;
    }}else if (actionSheet.tag == 1001){
        switch (buttonIndex) {
                
            case 0:
            {
                VideoRecordingVC *vc =[[VideoRecordingVC alloc]init];
                [self.navigationController pushViewController:vc animated:NO];
            }
                break;
                
            case 1:
            {
                [self selectLocationVideo];
            }
                break;
                
            default:
                break;
        }
    }
}


#pragma mark - IQMediaPickerControllerDelegate
- (void)mediaPickerController:(IQMediaPickerController*)controller didFinishMediaWithInfo:(NSDictionary *)info;
{
    self.urlPath = @"";
    //先清除photoView上部分的子控件
    for (UIView *subView in self.videoAndPhotoView.subviews) {
        
        [subView removeFromSuperview];
    }
    if ([info[@"IQMediaTypeImage"] count] <= 3) {
        NSLog(@"Info: %@",info);
        NSArray *dictArray = info[@"IQMediaTypeImage"];
        NSMutableArray *tempArray = [NSMutableArray array];
        [tempArray removeAllObjects];
        for (NSDictionary *dict in dictArray) {
            UIImage *image = dict[IQMediaImage];
            [tempArray addObject:image];
        }
        
        for (UIImage *addedImage in tempArray) {
            NSData*     photoData = UIImageJPEGRepresentation(addedImage, 1.0);
            if ([photoData length]/1024 >300) {
                
                UIImage*    image=  [CommonTool scaleImage:addedImage toKb:300];
                
                [self.imageArray addObject:image];
            }else{
                UIImage*  image       = [UIImage imageWithData:photoData];
                [self.imageArray addObject:image];
                
            }
            
        }
        
        
        //刷新界面,重设frame
        for (NSInteger i=0; i< self.imageArray.count; i++) {
            UIImageView *photoImagV = [[UIImageView alloc]initWithFrame:CGRectMake(100*i, 20, 80, 80)];
            photoImagV.userInteractionEnabled = YES;
            
            photoImagV.image = self.imageArray[i];
            [self.videoAndPhotoView addSubview:photoImagV];
            
            UIButton *xBtn = [[UIButton alloc]init];
            xBtn.frame = CGRectMake(60+100*i, 0, 40, 40);
            
//            [xBtn setTitle:@"x" forState:UIControlStateNormal];
//            [xBtn setTitleColor:[UIColor colorWithHexString:@"#424242"] forState:UIControlStateNormal];
            
            [xBtn setImage:[UIImage  imageNamed:@"取消叉叉"] forState:UIControlStateNormal];
            xBtn.tag = 1000+i;
            [xBtn addTarget:self action:@selector(deleteImage:) forControlEvents:UIControlEventTouchUpInside];
            [self.videoAndPhotoView addSubview:xBtn];
        }
        

        
        
    }
}
-(void)deleteImage:(UIButton *)sender{
    [self.imageArray removeObjectAtIndex:sender.tag-1000];
    //先清除photoView上部分的子控件
    for (UIView *subView in self.videoAndPhotoView.subviews) {
        
        [subView removeFromSuperview];
    }
    //刷新界面,重设frame
    for (NSInteger i=0; i< self.imageArray.count; i++) {
        UIImageView *photoImagV = [[UIImageView alloc]initWithFrame:CGRectMake(100*i, 20, 80, 80)];
        photoImagV.userInteractionEnabled = YES;
        
        photoImagV.image = self.imageArray[i];
        [self.videoAndPhotoView addSubview:photoImagV];
        
        UIButton *xBtn = [[UIButton alloc]init];
      xBtn.frame = CGRectMake(60+100*i, 0, 40, 40);
        
         [xBtn setImage:[UIImage  imageNamed:@"取消叉叉"] forState:UIControlStateNormal];
        xBtn.tag = 1000+i;
        [xBtn addTarget:self action:@selector(deleteImage:) forControlEvents:UIControlEventTouchUpInside];
        [self.videoAndPhotoView addSubview:xBtn];
    }
    

}
-(void)selectLocationVideo{
    
#pragma mark - TZImagePickerController
    
  
//        if (self.maxCountTF.text.integerValue <= 0) {
//            return;
//        }
        TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:3 columnNumber:3 delegate:self pushPhotoPickerVc:YES];
        
        
//#pragma mark - 四类个性化设置，这些参数都可以不传，此时会走默认设置
//        imagePickerVc.isSelectOriginalPhoto = _isSelectOriginalPhoto;
//        
//        if (self.maxCountTF.text.integerValue > 1) {
//            // 1.设置目前已经选中的图片数组
//            imagePickerVc.selectedAssets = _selectedAssets; // 目前已经选中的图片数组
////        }
//        imagePickerVc.allowTakePicture = self.showTakePhotoBtnSwitch.isOn; // 在内部显示拍照按钮
//        
//        // 2. Set the appearance
//        // 2. 在这里设置imagePickerVc的外观
//        // imagePickerVc.navigationBar.barTintColor = [UIColor greenColor];
//        // imagePickerVc.oKButtonTitleColorDisabled = [UIColor lightGrayColor];
//        // imagePickerVc.oKButtonTitleColorNormal = [UIColor greenColor];
//        // imagePickerVc.navigationBar.translucent = NO;
//        
//        // 3. Set allow picking video & photo & originalPhoto or not
//        // 3. 设置是否可以选择视频/图片/原图
        imagePickerVc.allowPickingVideo = YES;
        imagePickerVc.allowPickingImage = NO;
//        imagePickerVc.allowPickingOriginalPhoto = self.allowPickingOriginalPhotoSwitch.isOn;
//        imagePickerVc.allowPickingGif = self.allowPickingGifSwitch.isOn;
//        
//        // 4. 照片排列按修改时间升序
//        imagePickerVc.sortAscendingByModificationDate = self.sortAscendingSwitch.isOn;
//        
//        // imagePickerVc.minImagesCount = 3;
//        // imagePickerVc.alwaysEnableDoneBtn = YES;
//        
//        // imagePickerVc.minPhotoWidthSelectable = 3000;
//        // imagePickerVc.minPhotoHeightSelectable = 2000;
//        
//        /// 5. Single selection mode, valid when maxImagesCount = 1
//        /// 5. 单选模式,maxImagesCount为1时才生效
//        imagePickerVc.showSelectBtn = NO;
//        imagePickerVc.allowCrop = self.allowCropSwitch.isOn;
//        imagePickerVc.needCircleCrop = self.needCircleCropSwitch.isOn;
//        imagePickerVc.circleCropRadius = 100;
//        /*
//         [imagePickerVc setCropViewSettingBlock:^(UIView *cropView) {
//         cropView.layer.borderColor = [UIColor redColor].CGColor;
//         cropView.layer.borderWidth = 2.0;
//         }];*/
//        
//        //imagePickerVc.allowPreview = NO;
#pragma mark - 到这里为止
        
        // You can get the photos by block, the same as by delegate.
        // 你可以通过block或者代理，来得到用户选择的照片.
        [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
            
        }];
        
        [self presentViewController:imagePickerVc animated:YES completion:nil];
   

}
#pragma mark - TZImagePickerControllerDelegate

/// User click cancel button
/// 用户点击了取消
- (void)tz_imagePickerControllerDidCancel:(TZImagePickerController *)picker {
    // NSLog(@"cancel");
}

// The picker should dismiss itself; when it dismissed these handle will be called.
// If isOriginalPhoto is YES, user picked the original photo.
// You can get original photo with asset, by the method [[TZImageManager manager] getOriginalPhotoWithAsset:completion:].
// The UIImage Object in photos default width is 828px, you can set it by photoWidth property.
// 这个照片选择器会自己dismiss，当选择器dismiss的时候，会执行下面的代理方法
// 如果isSelectOriginalPhoto为YES，表明用户选择了原图
// 你可以通过一个asset获得原图，通过这个方法：[[TZImageManager manager] getOriginalPhotoWithAsset:completion:]
// photos数组里的UIImage对象，默认是828像素宽，你可以通过设置photoWidth属性的值来改变它
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    _selectedPhotos = [NSMutableArray arrayWithArray:photos];
    _selectedAssets = [NSMutableArray arrayWithArray:assets];
    _isSelectOriginalPhoto = isSelectOriginalPhoto;
//    [_collectionView reloadData];
    // _collectionView.contentSize = CGSizeMake(0, ((_selectedPhotos.count + 2) / 3 ) * (_margin + _itemWH));
    
    // 1.打印图片名字
    [self printAssetsName:assets];
}

// If user picking a video, this callback will be called.
// If system version > iOS8,asset is kind of PHAsset class, else is ALAsset class.
// 如果用户选择了一个视频，下面的handle会被执行
// 如果系统版本大于iOS8，asset是PHAsset类的对象，否则是ALAsset类的对象
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(id)asset {
    _selectedPhotos = [NSMutableArray arrayWithArray:@[coverImage]];
    _selectedAssets = [NSMutableArray arrayWithArray:@[asset]];
    // open this code to send video / 打开这段代码发送视频
     [[TZImageManager manager] getVideoOutputPathWithAsset:asset completion:^(NSString *outputPath) {
         
//     NSLog(@"视频导出到本地完成,沙盒路径为:%@",outputPath);
//     Export completed, send video here, send by outputPath or NSData
//     导出完成，在这里写上传代码，通过路径或者通过NSData上传
         
     
         
         AVURLAsset *avUrl = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:outputPath]];
         CMTime time = [avUrl duration];
         int seconds = ceil(time.value/time.timescale);
         if ( seconds > 30) {
             [MBProgressHUD  showError:@"上传的视频不能多于30秒哦～"];
         }else{
         self.urlPath = outputPath;
         
         [self.imageArray removeAllObjects];
         //先清除photoView上部分的子控件
         for (UIView *subView in self.videoAndPhotoView.subviews) {
             
             [subView removeFromSuperview];
         }
         self.moviePlayer.contentURL = [NSURL URLWithString:self.urlPath];
         
         self.moviePlayer              = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:self.urlPath]];
         self.moviePlayer.controlStyle = MPMovieControlStyleEmbedded;
         self.moviePlayer.scalingMode  = MPMovieScalingModeAspectFit;
         [self.moviePlayer.view setFrame:CGRectMake(0, 15, 150, 150)];
         [self.moviePlayer play];
         
         
         self.deleteBtn = [[UIButton alloc]init];
         self.deleteBtn.frame = CGRectMake(135, 0, 30, 30);
         [self.deleteBtn setImage:[UIImage imageNamed:@"取消叉叉"] forState:UIControlStateNormal];
         [self.deleteBtn addTarget:self action:@selector(deleteVideo:) forControlEvents:UIControlEventTouchUpInside];
         
         [self.videoAndPhotoView addSubview:self.moviePlayer.view];
             [self.videoAndPhotoView addSubview:self.deleteBtn];
    }
    
         }];

}
// If user picking a gif image, this callback will be called.
// 如果用户选择了一个gif图片，下面的handle会被执行
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingGifImage:(UIImage *)animatedImage sourceAssets:(id)asset {
    _selectedPhotos = [NSMutableArray arrayWithArray:@[animatedImage]];
    _selectedAssets = [NSMutableArray arrayWithArray:@[asset]];
//    [_collectionView reloadData];
}

#pragma mark - Private

/// 打印图片名字
- (void)printAssetsName:(NSArray *)assets {
    NSString *fileName;
    for (id asset in assets) {
        if ([asset isKindOfClass:[PHAsset class]]) {
            PHAsset *phAsset = (PHAsset *)asset;
            fileName = [phAsset valueForKey:@"filename"];
        } else if ([asset isKindOfClass:[ALAsset class]]) {
            ALAsset *alAsset = (ALAsset *)asset;
            fileName = alAsset.defaultRepresentation.filename;;
        }
        //NSLog(@"图片名字:%@",fileName);
    }
}
- (void)setTextVi{
    
    _textView = [[UITextView alloc]initWithFrame:CGRectMake(16, 16, SCREEN_WIDTH-32, 150)];
     _textView.tintColor =[UIColor colorWithHexString:@"#ff5252"];
    _textView.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];
    _textView.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
    _textView.delegate = self;
    _textView.text = @"";
    
    _textView.textColor = [UIColor colorWithHexString:@"#424242"];
    _textView.returnKeyType = UIReturnKeyDone;
    //_textView.returnKeyType = UIReturnKeyDone;
    _textView.keyboardType = UIKeyboardTypeDefault;
    _textView.scrollEnabled = NO;
    
    _textView.autoresizingMask = UIViewAutoresizingFlexibleHeight; //自适应高度
    _textView.dataDetectorTypes = UIDataDetectorTypeAll; //电话号码  网址 地址等都可以显示
    //textView.editable = NO;  //禁止编辑
    [self.view addSubview:_textView];
    
    placeholder               = [[UILabel alloc] init];
//    placeholder.translatesAutoresizingMaskIntoConstraints = NO;
    placeholder.text          = @"我想说...(限140字)\n请勿发布黄赌毒等低俗和违法的视频、图片";
    placeholder.textColor = [UIColor colorWithHexString:@"#bdbdbd"];
    placeholder.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
    placeholder.textAlignment = NSTextAlignmentLeft;
    [_textView addSubview:placeholder];
    
    placeholder.numberOfLines = 0;//根据最大行数需求来设置
    placeholder.lineBreakMode = NSLineBreakByTruncatingTail;
    CGSize maximumLabelSize = CGSizeMake(SCREEN_WIDTH-32, 60);//labelsize的最大值
    //关键语句
    CGSize expectSize = [placeholder sizeThatFits:maximumLabelSize];
    //别忘了把frame给回label，如果用xib加了约束的话可以只改一个约束的值
     placeholder.frame = CGRectMake(0, 6, SCREEN_WIDTH-32, expectSize.height);
//    //    placeholder.frame = CGRectMake(0*AutoSizeScaleX, 10*AutoSizeScaleY, 288*AutoSizeScaleX, 21*AutoSizeScaleY);
//    [_textView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-6-[placeholder]-16-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(placeholder)]];
//    [_textView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-16-[placeholder(==12)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(placeholder)]];
    
    
    numLabel = [[UILabel alloc]init];
    numLabel.translatesAutoresizingMaskIntoConstraints = NO;
    numLabel.textColor = [UIColor colorWithHexString:@"#9e9e9e"];
    numLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
    numLabel.text = @"0/140";
    [self.view addSubview:numLabel];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[numLabel(==40)]-22-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(numLabel)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_textView]-8-[numLabel(==12)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_textView,numLabel)]];
    
}


- (void)textViewDidBeginEditing:(UITextView *)textView{
     placeholder.text = @"";
    [UIView animateWithDuration:0.4 animations:^{
        self.bootmView.frame = CGRectMake(0,SCREEN_HEIGHT-64-20-30-236-20 ,SCREEN_WIDTH , 60);
    }];
}
- (void)textViewDidEndEditing:(UITextView *)textView{
    
    if (_textView.text.length == 0) {
        placeholder.text          = @"我想说...(限140字)\n请勿发布黄赌毒等低俗和违法的视频、图片";
    }else{
        placeholder.text = @"";
    }
    [UIView animateWithDuration:0.2 animations:^{
    self.bootmView.frame = CGRectMake(0,SCREEN_HEIGHT-64-20-30 ,SCREEN_WIDTH , 50);
    }];

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

//正在改变
- (void)textViewDidChange:(UITextView *)textView
{
    NSLog(@"%@", textView.text);
    
    placeholder.hidden = YES;
    //实时显示字数
    numLabel.text = [NSString stringWithFormat:@"%lu/140", (unsigned long)textView.text.length];
    
    //字数限制操作
    if (textView.text.length >= 140) {
        
        textView.text = [textView.text substringToIndex:140];
        numLabel.text = @"140/140";
        [MBProgressHUD showSuccess:@"字数不能超过140字哦～～"];
        
    }
    //取消按钮点击权限，并显示提示文字
    if (textView.text.length == 0) {
        
        placeholder.hidden = NO;
    }
    
}




-(void)deleteVideo:(UIButton *)sender{
    [sender removeFromSuperview];
    [self.moviePlayer.view removeFromSuperview];
}
-(void)backClick{
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}
-(void)sendClick{
    if ([CommonTool dx_isNullOrNilWithObject:_textView.text]) {
        [MBProgressHUD showError:@"请填写内容"];
        return;
    }
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/config/getQiniuToken", REQUESTHEADER] andParameter:@{} success:^(id successResponse) {
        MLOG(@"结果:%@", successResponse);
        if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
            self.token = successResponse[@"data"];
            
            if ([CommonTool dx_isNullOrNilWithObject:self.urlPath] == NO) {
                [self updataVideoUrlToQiNiu];
            }else{
                [self updataPhotoUrlToQiNiu];
            }
        } else {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"msg"]]];
        }
    }
                             andFailure:^(id failureResponse) {
                                 [MBProgressHUD hideHUD];
                                 [MBProgressHUD showError:@"服务器繁忙,请重试"];
}];

    
//    NSInteger time = self.moviePlayer.duration;
//    if (time < 5 || time > 15) {
//        [[[UIAlertView alloc] initWithTitle:@"" message:@"视频时长必须为5-15秒" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil] show];
//        return;
//    }
//    
//    [self.moviePlayer stop];
    
//    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/config/getQiniuToken",REQUESTHEADER] andParameter:@{} success:^(id successResponse) {
//        
//        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
//            
//            self.token = successResponse[@"data"];
//            
//            //获取当前时间
//            NSDate *now = [NSDate date];
//            NSLog(@"now date is: %@", now);
//            NSCalendar *calendar = [NSCalendar currentCalendar];
//            NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
//            NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
//            NSInteger year = [dateComponent year];
//            NSInteger month = [dateComponent month];
//            NSInteger day = [dateComponent day];
//            NSInteger hour = [dateComponent hour];
//            NSInteger minute = [dateComponent minute];
//            NSInteger second = [dateComponent second];
//            NSString *photoStrng1 ;
//            
//            NSData *photoData ;
//            //2.将图片传给七牛服务器,并保存图片名
//            for (int i = 0; i < _imageArray.count; i++) {
//                UIImage *beSendImage = _imageArray[i];
//                photoData = UIImageJPEGRepresentation(beSendImage, 1.0);
//                // NSLog(@"压缩Size of Image(bytes):%d",[photoData length]);
//                UIImage *image ;
//                //                NSMutableArray *imageArr;
//                if ([photoData length]/1024 >300) {
//                    
//                    image=  [CommonTool scaleImage:beSendImage toKb:300];
//                    //                [self compressedImageFiles:beSendImage imageKB:150 imageBlock:^(UIImage *image) {
//                    //
//                    //                    [self.imageArray addObject:image];
//                    //                }];
//                    //                     [imageArr addObject:image];
//                    
//                }else{
//                    image       = [UIImage imageWithData:photoData];
//                    //                                     [imageArr addObject:image];
//                    
//                }
//                
//                //                UIImage *image       = [UIImage imageWithData:photoData];
//                CGSize size          = CGSizeFromString(NSStringFromCGSize(image.size));
//                CGFloat percent      = size.width / size.height;
//                NSString  *photoStr   = [NSString stringWithFormat:@"iosLvYueFriendCircle%d%d%d%d%d%d(%d)%.2f", year, month, day, hour, minute, second, i, percent];
//                
//                if (!photoStrng1) {
//                    photoStrng1 = [NSString stringWithFormat:@"%@",photoStr];
//                }else {
//                    photoStrng1  = [photoStrng1 stringByAppendingString:[NSString stringWithFormat:@",%@", photoStr]];
//                }
//                
//                NSLog(@"555555555555555555555555555%@",photoStrng1);
//                
//                
//                
//                //七牛上传图片
//                
//                QNUploadManager *upManager = [[QNUploadManager alloc] init];
//                [upManager putData:photoData key:photoStr token:self.token
//                          complete: ^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
//                              NSLog(@"%@", info);
//                              NSLog(@"%@", resp);
//                              if (resp == nil) {
//                                  [MBProgressHUD hideHUD];
//                                  [MBProgressHUD showError:@"上传失败"];
//                                  return ;
//                              }
//                          }option:nil];
//                
//            }

    

 
    

}

// 获取视频第一帧
- (UIImage*) thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time {

    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    NSParameterAssert(asset);
    AVAssetImageGenerator *assetImageGenerator =[[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;

    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = time;
    NSError *thumbnailImageGenerationError = nil;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60)actualTime:NULL error:&thumbnailImageGenerationError];

    if(!thumbnailImageRef)
        NSLog(@"thumbnailImageGenerationError %@",thumbnailImageGenerationError);

    UIImage*thumbnailImage = thumbnailImageRef ? [[UIImage alloc]initWithCGImage: thumbnailImageRef] : nil;

    return thumbnailImage;
}
-(void)updataVideoUrlToQiNiu{
    
    [MBProgressHUD showMessage:@"正在上传，请稍后..."];
    
    
            
            NSData *videoData = [[NSData alloc] initWithContentsOfFile:self.urlPath];
            
           
            
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
            
            
            locationString = [NSString stringWithFormat:@"iosLvYueVideo%d%d%d%d%d%d.mp4", year, month, day, hour, minute, second];
            NSLog(@"时间:%@", locationString);
            
            //七牛上传视频
            QNUploadManager *upManager = [[QNUploadManager alloc] init];
            [upManager putData:videoData key:locationString token:self.token
                      complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                          NSLog(@"%@", info);
                          NSLog(@"%@", resp);
                          
                          if (resp == nil) {
                              [MBProgressHUD showError:@"上传失败"];
                          } else {
                             
                              
                              
                              
                              UIImage *beSendImage = [self thumbnailImageForVideo:[NSURL fileURLWithPath:self.urlPath] atTime:600];
                              NSData *showData = UIImageJPEGRepresentation(beSendImage, 0.5);
                              CGSize size          = CGSizeFromString(NSStringFromCGSize(beSendImage.size));
                              CGFloat percent      = size.width / size.height;
                              showVideoStr   = [NSString stringWithFormat:@"iosLvYueFriendCircle%d%d%d%d%d%d%.2f", year, month, day, hour, minute, second, percent];
                              //七牛上传视频图片
                              [upManager putData:showData key:showVideoStr token:self.token
                                        complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                                            NSLog(@"%@", info);
                                            NSLog(@"%@", resp);
                                            
                                            if (resp == nil) {
                                                [MBProgressHUD showError:@"上传失败"];
                                            } else {
                                                
                                                [self updataVideoTheServer];
   
                                            }
                                        }
                                          option:nil];
                              
                          }
                      }
                        option:nil];
            
    
            
            
    
            
    
}
-(void)updataVideoTheServer{
    
    
    
    

    NSString *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userId"];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/video/addUserVideo",REQUESTHEADER] andParameter:@{@"userId":userId,@"videoUrl":locationString,@"showUrl":showVideoStr,@"videoSignature":_textView.text,@"videoTopicId":[NSString  stringWithFormat:@"%@",self.shareTopicId]} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        [MBProgressHUD hideHUD];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            
            [self.navigationController popToRootViewControllerAnimated:YES];
            [MBProgressHUD showSuccess:@"发布成功"];
        } else {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
}


-(void)updataPhotoUrlToQiNiu{
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
   
    
    NSData *photoData ;
    //2.将图片传给七牛服务器,并保存图片名
    for (int i = 0; i < _imageArray.count; i++) {
        UIImage *beSendImage = _imageArray[i];
        photoData = UIImageJPEGRepresentation(beSendImage, 1.0);
        // NSLog(@"压缩Size of Image(bytes):%d",[photoData length]);
        UIImage *image ;
        //                NSMutableArray *imageArr;
        if ([photoData length]/1024 >300) {
            
            image=  [CommonTool scaleImage:beSendImage toKb:300];
            
        }else{
            image       = [UIImage imageWithData:photoData];
            
        }
        
             CGSize size          = CGSizeFromString(NSStringFromCGSize(image.size));
        CGFloat percent      = size.width / size.height;
        NSString  *photoStr   = [NSString stringWithFormat:@"iosLvYueFriendCircle%d%d%d%d%d%d%d%.2f", year, month, day, hour, minute, second, i, percent];
        
        if (!photoString) {
            photoString = [NSString stringWithFormat:@"%@",photoStr];
        }else {
            photoString  = [photoString stringByAppendingString:[NSString stringWithFormat:@",%@", photoStr]];
        }
        
        NSLog(@"555555555555555555555555555%@",photoString);
        
        
        
        //七牛上传图片
        
        QNUploadManager *upManager = [[QNUploadManager alloc] init];
        [upManager putData:photoData key:photoStr token:self.token
                  complete: ^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                      NSLog(@"%@", info);
                      NSLog(@"%@", resp);
                      if (resp == nil) {
                          [MBProgressHUD hideHUD];
                          [MBProgressHUD showError:@"上传失败"];
                          return ;
                      }
                  }option:nil];
        
    }
    

    [self updataPhotoUrlTheServer];
    
}

-(void)updataPhotoUrlTheServer{
    
    
    
    
    if ([CommonTool dx_isNullOrNilWithObject:photoString]) {
        photoString = @"";
    }
    if ([CommonTool dx_isNullOrNilWithObject:showVideoStr]) {
        showVideoStr = @"";
    }
    NSString *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userId"];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/share/addUserShare",REQUESTHEADER] andParameter:@{@"userId":userId,@"shareUrl":photoString,@"showUrl":showVideoStr,@"shareSignature":_textView.text,@"shareType":@"1",@"shareTopicId":[NSString  stringWithFormat:@"%@",self.shareTopicId],@"shareLongitude":@"0",@"shareLatitude":@"0"} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        [MBProgressHUD hideHUD];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            
            [self.navigationController popToRootViewControllerAnimated:YES];
            [MBProgressHUD showSuccess:@"发布成功"];
        } else {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
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
