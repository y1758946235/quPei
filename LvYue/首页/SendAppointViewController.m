//
//  SendAppointViewController.m
//  LvYue
//
//  Created by Mac on 16/11/30.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "SendAppointViewController.h"
#import "sendAppointCell.h"
#import "SZCalendarPicker.h"
#import "meWantVC.h"
#import "LYHomeViewController.h"
#import "selectProvinceVC.h"
#import "LYHttpPoster.h"
#import "MBProgressHUD+NJ.h"
//多媒体拾取器框架
#import "IQMediaPickerController.h"
#import "IQFileManager.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "LYUserService.h"
#import "QiniuSDK.h"
#import "AFHTTPRequestOperationManager.h"
#import "QNUploadManager.h"
#import "LYUserService.h"

@interface SendAppointViewController ()<CLLocationManagerDelegate,UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UITextViewDelegate,IQMediaPickerControllerDelegate,UINavigationControllerDelegate,UIAlertViewDelegate,UIActionSheetDelegate>{
    UITableView *table;
    UIImageView *publishImage;
    NSString *type;  //约的类型
    
    UILabel *tLabel;
    UIImageView *imageView;
     UILabel *cityLabel;
    UILabel *typeLabel;
    UILabel *timeLabel;
    
    sendAppointCell *cellH;
    UIButton *lastSongBtn;
    UIButton *lastBuyBtn;
    
    NSString *buyStr;
    NSString *buyAndSong;
    NSString *songStr;
   
    UITextView *sayView;
    UILabel *placeholder;
    
    NSString *provinceId ;
    NSString *cityId;
    NSString *distriId;
    
    NSString *longitude;
    NSString *latitude;
    
    IQMediaPickerController *IQMediaPickerVC;
    
    
}
@property (nonatomic,strong) NSMutableArray *imageArray;   //上传图片的数组
//@property (nonatomic,strong) NSMutableArray *imageNArr;
//保存媒体拾取类型
@property (nonatomic, assign) IQMediaPickerControllerMediaType mediaType;
@property (nonatomic,strong) NSData *photoData;
@property (nonatomic,strong) NSString *token;
@property (nonatomic,strong) UIView *calendarView;

@property(nonatomic,strong)CLLocationManager *clManager;  //定位信息管理者



@end

@implementation SendAppointViewController
-(NSMutableArray*)imageArray{
    if (!_imageArray) {
        
        
        
        _imageArray = [[NSMutableArray alloc] init];
        
        
    }
    return _imageArray;
}
//-(NSMutableArray*)imageNArr{
//    if (!_imageNArr) {
//        
//        
//        
//        _imageNArr = [[NSMutableArray alloc] init];
//        
//        
//    }
//    return _imageNArr;
//}

-(NSArray*)plaIdArr{
    if (!_plaIdArr) {
        
        
        
        _plaIdArr = [[NSArray alloc] init];
       
        
    }
    return _plaIdArr;
}
-(UIView*)calendarView{
    if (!_calendarView) {
        
       
        
        _calendarView = [[UIView alloc] init];
        _calendarView.hidden = YES;
        
    }
    return _calendarView;
}




#pragma mark - 定位管理者
- (CLLocationManager *)clManager {
    
    if (!_clManager) {
        _clManager = [[CLLocationManager alloc] init];
        //设置定位硬件的精准度
        _clManager.desiredAccuracy = kCLLocationAccuracyBest;
        //设置定位硬件的刷新频率
        _clManager.distanceFilter = kCLLocationAccuracyKilometer;
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9) {
            _clManager.allowsBackgroundLocationUpdates = NO;
        }
    }
    return _clManager;
}

#pragma mark - 获取城市位置

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations{
   
    CLLocation *currentLocation = [locations lastObject];
    
    latitude = [NSString stringWithFormat:@"%f",currentLocation.coordinate.latitude];
    longitude = [NSString stringWithFormat:@"%f",currentLocation.coordinate.longitude];
    
    //停止定位
    [_clManager stopUpdatingLocation];
    
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        //用户允许授权,开启定位
        [_clManager startUpdatingLocation];
    } else {
        //        [MBProgressHUD showError:@"您拒绝了定位授权,若需要请在设置中开启"];
        longitude = @"120.027860";
        latitude = @"30.245586";
    }
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    //    [MBProgressHUD showError:@"定位失败,请重试"];
}

- (void)viewWillAppear:(BOOL)animated{
  
    
   
    IQMediaPickerVC.delegate = nil;
   
    [super viewWillAppear:animated];
   
}
-(void)viewWillDisappear:(BOOL)animated{
   
}

-(void)setUpCalender{
//    // 点击某一天的回调
//    _calendar.didSelectDayHandler = ^(NSInteger year, NSInteger month, NSInteger day) {
//        
//        NSLog(@"年_%d 月__%d 日__%d",year,month,day);
//        
//    };
    self.calendarView.frame = CGRectMake(0, 64+(17+114), SCREEN_WIDTH, SCREEN_HEIGHT-64-49-131);
    self.calendarView.backgroundColor = [UIColor whiteColor];
    self.calendarView.hidden = YES;
    [self.view addSubview:self.calendarView];
    CGFloat width = self.view.bounds.size.width ;
    CGPoint origin = CGPointMake(0, 0);
    
    GFCalendarView * calendar = [[GFCalendarView alloc] initWithFrameOrigin:origin width:width];
    // calendar = [[GFCalendarView alloc] initWithFrame:CGRectMake(0, 64.0 +114.0*AutoSizeScaleY, SCREEN_WIDTH, SCREEN_WIDTH-49-64-114*AutoSizeScaleY)];
    calendar.backgroundColor = [UIColor whiteColor];
   
    self.timesStamp = [CommonTool getNowTimestamp] ;
        // 点击某一天的回调
    calendar.didSelectDayHandler = ^(NSInteger year, NSInteger month, NSInteger day) {
        
      
      
        self.timeStr =[NSString stringWithFormat:@"%d-%d-%d", year, month, day] ;
        self.timesStamp = [CommonTool timeSwitchTimestamp:[NSString stringWithFormat:@"%d-%d-%d", year, month, day] andFormatter:@"YYYY-MM-dd"];
        
        timeLabel.text = self.timeStr;
         NSLog(@"%d－%d－%d-%d", year, month, day,self.timesStamp);
        self.calendarView.hidden = YES;
       

    };
    
    [self.calendarView addSubview:calendar];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    provinceId = [[NSString alloc]init];
    cityId = [[NSString alloc]init];
    distriId = [[NSString alloc]init];
    self.clManager.delegate = self;
    self.clManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 8.0) {
        //前台和后台都允许请求用户是否允许开启定位 IOS8.0以上版本需要设置环境参数
        [_clManager requestWhenInUseAuthorization];
        [_clManager startUpdatingLocation];
    }
    else {
        //如果是IOS8.0以下的版本，则可直接开启定位
        [_clManager startUpdatingLocation];
    }

    
    self.view.userInteractionEnabled = YES;
    [self registNotification];
    
    [self setNav];
    [self setTableBottom];
    [self setUpCalender];
    
   }
-(void)registNotification{
    //发送通知  跳转页面
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(pushNotification:) name:@"push" object:nil];
    //发送通知  定位到当前位置
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(currentplace:) name:@"currentplace" object:nil];
}
//push通知
- (void)pushNotification:(NSNotification *)noti {
    
    if ([[noti.userInfo objectForKey:@"push"] isEqualToString:@"homeVC"]) {
        LYHomeViewController *homeVC = [[LYHomeViewController alloc]init];
        [self.navigationController pushViewController:homeVC animated:YES];
    }
    
   }
//push通知
- (void)currentplace:(NSNotification *)noti {
    self.placee = noti.object;
    cityLabel.text = self.placee;
    
    self.plaIdArr = [self.placeId componentsSeparatedByString:@","];
    
    
    
    if (self.plaIdArr.count==3) {
        provinceId = self.plaIdArr[0];
        cityId = self.plaIdArr[1];
        distriId = self.plaIdArr[2];
    }else if(self.plaIdArr.count==2){
        provinceId = self.plaIdArr[0];
        cityId = self.plaIdArr[1];
        distriId = @"0";
    }
}
- (void)setTableBottom{
    table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStylePlain];
    table.dataSource = self;
    table.delegate = self;
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:table];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return 15;
    }else if(section==1){
        return 15;
    }else{
        
        return 23;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view;
    if (section==0) {
        view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 15)];
    }else if(section==1){
        view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 15)];
    }else{
        view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 23)];
    }
    return view;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section==0) {
        return 3;
    }else if(section == 1){
        return 2;
    }else{
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section==0) {
        return 57;
    }else if(indexPath.section==1){
        return 65;
        }
    
    else if(indexPath.section==2){
            return 214+60*AutoSizeScaleY;
    }else{
        return 0;
    }
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.userInteractionEnabled = YES;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.section==0) {
        if (indexPath.row==0) {
        cell.textLabel.text = @"我要约...";
        UIImageView *typeImage = [[UIImageView alloc]init];
       // typeImage.image = [UIImage imageNamed:@"d_dining"];
        typeImage.translatesAutoresizingMaskIntoConstraints = NO;
        [cell addSubview:typeImage];
        [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[typeImage(==24)]-64-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(typeImage)]];
        [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-16-[typeImage(==24)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(typeImage)]];
            imageView = typeImage;
            
      typeLabel = [[UILabel alloc]init];
    //typeLabel.text = self.dateTypeName;
    typeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    typeLabel.textColor = [UIColor colorWithHexString:@"#757575"];
    typeLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
    typeLabel.textAlignment = NSTextAlignmentRight;
    [cell addSubview:typeLabel];
    [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[typeLabel(==28)]-32-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(typeLabel)]];
     [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[typeLabel(==14)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(typeLabel)]];
            tLabel = typeLabel;
            
    }else if (indexPath.row==1){
      cell.textLabel.text = @"时间是...";
       
        timeLabel = [[UILabel alloc]init];
        if (timeLabel.text.length == 0) {
            timeLabel.text = [CommonTool getNowTime];
        }else{
            
        }
        timeLabel.translatesAutoresizingMaskIntoConstraints = NO;
       timeLabel.textColor = [UIColor colorWithHexString:@"#757575"];
       timeLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
       timeLabel.textAlignment = NSTextAlignmentRight;
        [cell addSubview:timeLabel];
        [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[timeLabel(==98)]-32-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(timeLabel)]];
        [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[timeLabel(==14)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(timeLabel)]];
        
  }else if(indexPath.row==2){
        //地点
        cell.textLabel.text = @"约在...";
        
        cityLabel = [[UILabel alloc]init];
        cityLabel.translatesAutoresizingMaskIntoConstraints = NO;
        cityLabel.textColor = [UIColor colorWithHexString:@"#757575"];
        cityLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
        cityLabel.textAlignment = NSTextAlignmentRight;
        [cell addSubview:cityLabel];
        [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[cityLabel(==158)]-32-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(cityLabel)]];
        [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[cityLabel(==14)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(cityLabel)]];
        
    }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.textColor = [UIColor colorWithHexString:@"#424242"];
        cell.textLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
               
    }else{
       
       
        
        cellH = [[sendAppointCell alloc]initCellWithIndex:indexPath];
        cellH.userInteractionEnabled = YES;
        for (id obj in cellH.subviews) { if ([NSStringFromClass([obj class]) isEqualToString:@"UITableViewCellScrollView"]) { UIScrollView *scroll = (UIScrollView *) obj; scroll.delaysContentTouches = NO; break; } }
        if (indexPath.section==2&&indexPath.row==0) {
            [self setSanView:cellH];
        }
        [cell addSubview:cellH];
       
        [cellH.sendPointBtn addTarget:self action:@selector(sendPoint:) forControlEvents:UIControlEventTouchUpInside];
        [cellH.buyIndefiniteBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [cellH.AABt addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [cellH.youBuyBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [cellH.meBuyBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [cellH.KeSongBtn addTarget:self action:@selector(Click:) forControlEvents:UIControlEventTouchUpInside];
         [cellH.xuSongBtn addTarget:self action:@selector(Click:) forControlEvents:UIControlEventTouchUpInside];
         [cellH.songIndefiniteBtn addTarget:self action:@selector(Click:) forControlEvents:UIControlEventTouchUpInside];
        [cellH.addPhotoBtn addTarget:self action:@selector(addPhoto:) forControlEvents:UIControlEventTouchUpInside];
        
        
        
        }
    
   
    return cell;
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
       //字数限制操作
    if (textView.text.length >= 150) {
        
        textView.text = [textView.text substringToIndex:150];
        
          [MBProgressHUD showSuccess:@"字数不能超过150字哦～～"];
       
        
    }
    //取消按钮点击权限，并显示提示文字
    if (textView.text.length == 0) {
        
        placeholder.hidden = NO;
    }
    
}


- (void)textViewDidBeginEditing:(UITextView *)textView{
    placeholder.text = @"";
    table.centerY = table.centerY -216;
}
- (void)textViewDidEndEditing:(UITextView *)textView{
    table.centerY = table.centerY +216;
    if (sayView.text.length == 0) {
        placeholder.text          = @"内容更详细，约会的成功率更高哦～(限150字)\n请勿发布色情、淫秽或其他令人不适的文字或图片";
    }else{
       placeholder.text = @"";
    }
}
- (void)setSanView:(sendAppointCell *)cell{
    UILabel *andLabel =[[UILabel alloc]initWithFrame:CGRectMake(16, 0, 84,14)];
    andLabel.text = @"我还有要说的";
    andLabel.textColor = [UIColor colorWithHexString:@"#424242"];
    andLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [cell addSubview:andLabel];
    
    
    sayView = [[UITextView alloc]init];
    sayView.delegate = self;
    sayView.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];
    sayView.tintColor =[UIColor colorWithHexString:@"#ff5252"];
    sayView.returnKeyType = UIReturnKeyDone;
    sayView.textColor  = [UIColor colorWithHexString:@"#424242"];
    sayView.font = [UIFont systemFontOfSize:14] ;
    sayView.translatesAutoresizingMaskIntoConstraints = NO;
    cell.savView = sayView;
    [cell addSubview:sayView];
//    sayView.frame = CGRectMake(16*AutoSizeScaleX, 30*AutoSizeScaleY, 288*AutoSizeScaleX, 62*AutoSizeScaleY);
    [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-16-[sayView]-16-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(sayView)]];
    [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[andLabel]-16-[sayView(==72)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(andLabel,sayView)]];
    
    
    placeholder               = [[UILabel alloc] init];
    [placeholder  setLineBreakMode:NSLineBreakByWordWrapping];
    placeholder.textColor = [UIColor colorWithHexString:@"#bdbdbd"];
    placeholder.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
    placeholder.textAlignment = NSTextAlignmentCenter;
    [sayView addSubview:placeholder];
//    placeholder.frame = CGRectMake(0, 6, SCREEN_WIDTH-32, 60);
    placeholder.text          = @"内容更详细，约会的成功率更高哦～(限150字)\n请勿发布色情、淫秽或其他令人不适的文字或图片";
    placeholder.numberOfLines = 0;//根据最大行数需求来设置
    placeholder.lineBreakMode = NSLineBreakByTruncatingTail;
    CGSize maximumLabelSize = CGSizeMake(SCREEN_WIDTH-32, 60);//labelsize的最大值
    //关键语句
    CGSize expectSize = [placeholder sizeThatFits:maximumLabelSize];
    //别忘了把frame给回label，如果用xib加了约束的话可以只改一个约束的值
    placeholder.frame = CGRectMake(0, 6, SCREEN_WIDTH-32, expectSize.height);

    
    cell.photoView = [[UIView alloc]init];
    cell.photoView.userInteractionEnabled = YES;
    
    [cell addSubview:cell.photoView];
//    cell.photoView.backgroundColor = [UIColor  cyanColor];
    [cell.photoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(sayView.mas_bottom).with.offset(16);
        make.left.equalTo(cell.mas_left).with.offset(16);
        make.width.equalTo(@0);
        make.height.mas_equalTo((60*AutoSizeScaleX));
    }];
    
    cell.addPhotoBtn = [[UIButton alloc]init];
    cell.userInteractionEnabled = YES;
   
    //    upimage.translatesAutoresizingMaskIntoConstraints = NO;
    [cell.addPhotoBtn setBackgroundImage:[UIImage imageNamed:@"addPhoto"] forState:UIControlStateNormal];
//    [cell.addPhotoBtn addTarget:self action:@selector(addPhotos:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell addSubview:cell.addPhotoBtn];
        [cell.addPhotoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(cell.photoView.mas_top);
            make.left.equalTo(cell.photoView.mas_right).with.offset(16*AutoSizeScaleX);
            make.height.mas_equalTo(@(60*AutoSizeScaleX));
            make.width.mas_equalTo(@(60*AutoSizeScaleX));
        }];
  
   
    //    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-16-[upimage(==60)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(upimage)]];
    //    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-82-[upimage(==60)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(upimage)]];
    //
    //发布约会
    cell.sendPointBtn = [[UIButton alloc]init];
//    buyBtn.translatesAutoresizingMaskIntoConstraints = NO;
//    [cell.sendPointBtn setTitle:@"发布" forState:UIControlStateNormal];
//    cell.sendPointBtn.layer.cornerRadius = 18;
//    cell.sendPointBtn.clipsToBounds = YES;
//    cell.sendPointBtn.layer.borderWidth = 2;
//    cell.sendPointBtn.layer.borderColor = [UIColor colorWithRed:32 green:32 blue:32 alpha:0.12].CGColor;
//    cell.sendPointBtn.backgroundColor = [UIColor colorWithHexString:@"#ff5252"];
 //   cell.sendPointBtn.backgroundColor = [UIColor cyanColor];
//    cell.sendPointBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
//    [cell.sendPointBtn setTitleColor:[UIColor colorWithHexString:@"#ffffff"] forState:UIControlStateNormal];
   
    [cell addSubview:cellH.sendPointBtn];
     cell.userInteractionEnabled = YES;
    cell.autoresizesSubviews = YES;
//    cell.backgroundColor = [UIColor blueColor];
    [cell.sendPointBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(cell.photoView.mas_bottom).with.offset((16));
        make.left.equalTo(cell.mas_left).with.offset(0);
        make.height.mas_equalTo(@60);
        make.right.equalTo(cell.mas_right).with.offset(0);
    }];
    
    UILabel *sendLabel = [[UILabel alloc]init];
    sendLabel.frame = CGRectMake(SCREEN_WIDTH/2 -60, 0, 120, 36);
    sendLabel.text = @"发布";
    sendLabel.textAlignment = NSTextAlignmentCenter;
    sendLabel.layer.cornerRadius = 18;
    sendLabel.clipsToBounds = YES;
//    sendLabel.layer.borderWidth = 2;
    //    sendLabel.layer.borderColor = [UIColor colorWithRed:32 green:32 blue:32 alpha:0.12].CGColor;
    sendLabel.backgroundColor = [UIColor colorWithHexString:@"#ff5252"];
    sendLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    sendLabel.textColor = [UIColor colorWithHexString:@"#ffffff"] ;
    [cell.sendPointBtn addSubview:sendLabel];
    //    [cell.sendPointBtn setTitleColor:[UIColor colorWithHexString:@"#ffffff"] forState:UIControlStateNormal];
}

#pragma mark  --增加约会图片  最多3张
- (void)addPhoto:(UIButton *)sender{
    if (self.imageArray.count >= 3) {
        [MBProgressHUD showError:@"最多只能上传三张"] ;
        return;
    }
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"选择上传方式" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从相册上传", nil];
    [action showInView:self.view];
}

#pragma mark uiactionsheet 代理

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
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
    }
}


#pragma mark - IQMediaPickerControllerDelegate
- (void)mediaPickerController:(IQMediaPickerController*)controller didFinishMediaWithInfo:(NSDictionary *)info;
{
    
    //先清除photoView上部分的子控件
    for (UIView *subView in cellH.photoView.subviews) {

         [subView removeFromSuperview];
    }
//    //由于会从self.imageNArr添加 所以必须要把self.imageArray移除
//    [self.imageArray removeAllObjects];
    
   
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
        for (int i = 0; i < self.imageArray.count; i++) {

       

        
            
         
            //刷新界面,重设frame
            for (NSInteger i=0; i< self.imageArray.count; i++) {
                UIImageView *photoImagV = [[UIImageView alloc]initWithFrame:CGRectMake(76*AutoSizeScaleX*i, 0, 60*AutoSizeScaleX, 60*AutoSizeScaleX)];
                photoImagV.userInteractionEnabled = YES;
               
                photoImagV.image = self.imageArray[i];
                [cellH.photoView addSubview:photoImagV];
                
                UIButton *xBtn = [[UIButton alloc]init];
                xBtn.frame = CGRectMake(40*AutoSizeScaleX, -20*AutoSizeScaleX, 40*AutoSizeScaleX, 40*AutoSizeScaleX);
                
//                [xBtn setTitle:@"x" forState:UIControlStateNormal];
//                [xBtn setTitleColor:[UIColor colorWithHexString:@"#424242"] forState:UIControlStateNormal];
                 [xBtn setImage:[UIImage imageNamed:@"取消叉叉"] forState:UIControlStateNormal];
                xBtn.tag = 1000+i;
                [xBtn addTarget:self action:@selector(deleteImage:) forControlEvents:UIControlEventTouchUpInside];
                [photoImagV addSubview:xBtn];
            }
            
            
            
            cellH.photoView.width =  76*AutoSizeScaleX*self.imageArray.count;
            cellH.addPhotoBtn.centerX =16+ 76*AutoSizeScaleX*self.imageArray.count+30*AutoSizeScaleX;
        }
       
        [self dismissViewControllerAnimated:YES completion:nil];
      


        
    } else {
        [MBProgressHUD showError:@"最多三张图片"];
    }
}


-(void)deleteImage:(UIButton *)sender{
    
    [self.imageArray removeObjectAtIndex:sender.tag-1000];
//    [self.imageNArr removeObjectAtIndex:sender.tag-1000];
    //先清除scrollView上部分的子控件
    for (UIView *subView in cellH.photoView.subviews) {
     
        [subView removeFromSuperview];
    }
    //刷新界面,重设frame
    for (NSInteger i=0; i< self.imageArray.count; i++) {
        UIImageView *photoImagV = [[UIImageView alloc]initWithFrame:CGRectMake(76*AutoSizeScaleX*i, 0, 60*AutoSizeScaleX, 60*AutoSizeScaleX)];
        
      photoImagV.userInteractionEnabled = YES;
        photoImagV.image = self.imageArray[i];

        [cellH.photoView addSubview:photoImagV];
        
        UIButton *xBtn = [[UIButton alloc]init];
        xBtn.frame = CGRectMake(40*AutoSizeScaleX, -20*AutoSizeScaleX, 40*AutoSizeScaleX, 40*AutoSizeScaleX);
//        [xBtn setTitle:@"x" forState:UIControlStateNormal];
//        [xBtn setTitleColor:[UIColor colorWithHexString:@"#424242"] forState:UIControlStateNormal];
        [xBtn setImage:[UIImage imageNamed:@"取消叉叉"] forState:UIControlStateNormal];
        xBtn.tag = 1000+i;
        [xBtn addTarget:self action:@selector(deleteImage:) forControlEvents:UIControlEventTouchUpInside];
        [photoImagV addSubview:xBtn];
    }
    
    
    cellH.photoView.width =  76*AutoSizeScaleX*self.imageArray.count;
    cellH.addPhotoBtn.centerX =16+ 76*AutoSizeScaleX*self.imageArray.count+30*AutoSizeScaleX;
}

- (void)mediaPickerControllerDidCancel:(IQMediaPickerController *)controller;
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark  ----接送
- (void)Click:(UIButton *)sender{
    if (lastSongBtn == sender) {
        return;
    }

    sender.selected = YES;
    songStr = sender.titleLabel.text;
    UIColor *color = [UIColor colorWithHexString:@"#ff5252"];
    sender.backgroundColor = [color colorWithAlphaComponent:0.1];
    lastSongBtn.selected = NO;
    lastSongBtn.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];
    lastSongBtn = sender;

}


#pragma mark ---买单
- (void)btnClick:(UIButton *)sender{

    if (lastBuyBtn == sender) {
        return;
    }
    
    sender.selected = YES;
    UIColor *color = [UIColor colorWithHexString:@"#ff5252"];
    buyStr = sender.titleLabel.text;
    sender.backgroundColor = [color colorWithAlphaComponent:0.1];
    lastBuyBtn.selected = NO;
    lastBuyBtn.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];
    lastBuyBtn = sender;



}


#pragma mark   --发布约会
- (void)sendPoint:(UIButton *)sender{
    
    MLOG(@"_IMAGEARRAY:%@",_imageArray);
//    MLOG(@"_imageNArr:%@",_imageNArr);
        NSString *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userId"];
  
    buyAndSong = [NSString stringWithFormat:@"%@,%@",buyStr,songStr];
   
    
    // NSLog(@"发布约会   买单  接送%@  内容：%@  id:%@  约会类型:%@",buyAndSong,cellH.savView.text,cityId,typeId);
    
    if ([CommonTool dx_isNullOrNilWithObject:self.dateTypeId]){
        [MBProgressHUD showSuccess:@"请选择约会方式"];
    }else if ([CommonTool dx_isNullOrNilWithObject:timeLabel.text] ) {
        [MBProgressHUD showSuccess:@"请选择约会时间"];
        
    }else if ([CommonTool dx_isNullOrNilWithObject:provinceId]|| [CommonTool dx_isNullOrNilWithObject:cityId] ) {
        [MBProgressHUD showSuccess:@"请选择约会地点"];
        
    }else if ([CommonTool dx_isNullOrNilWithObject:buyStr]){
          [MBProgressHUD showSuccess:@"请选择买单方式"];
    }else if ([CommonTool dx_isNullOrNilWithObject:songStr]) {
        [MBProgressHUD showSuccess:@"请选择接送方式"];
        
    }
    else{
        //@"createTime":[NSString stringWithFormat:@"%ld000",(long)[CommonTool  getNowTimestamp]],
        
    if (self.imageArray.count ==0) {
        NSLog(@"777777777777777777777777777777777");
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/date/addPersonalDate",REQUESTHEADER] andParameter:@{@"userId":userId,@"activityTime":[NSString stringWithFormat:@"%ld000",(long)self.timesStamp],@"dateTypeId":self.dateTypeId,@"dateTagNameArr":buyAndSong,@"dateSignature":cellH.savView.text,@"datePhoto":@"",@"provinceId":provinceId,@"cityId":cityId,@"districtId":distriId,@"dateLongitude":longitude,@"dateLatitude":latitude} success:^(id successResponse) {
                                  
                                NSLog(@"888888888888888888888888888888");
                                if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
                                    [MBProgressHUD showSuccess:@"发布成功"];
                                    [self sendedchuli];
                                }
                            } andFailure:^(id failureResponse) {
        
                            }];
    }
    
    
    
    if (self.imageArray.count!=0) {
        
  
   
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/config/getQiniuToken",REQUESTHEADER] andParameter:@{} success:^(id successResponse) {
        
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            
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
            NSString *photoStrng1 ;

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
                    //                [self compressedImageFiles:beSendImage imageKB:150 imageBlock:^(UIImage *image) {
                    //
                    //                    [self.imageArray addObject:image];
                    //                }];
//                     [imageArr addObject:image];
                    
                                }else{
                                    image       = [UIImage imageWithData:photoData];
//                                     [imageArr addObject:image];
                                   
                                }

//                UIImage *image       = [UIImage imageWithData:photoData];
            CGSize size          = CGSizeFromString(NSStringFromCGSize(image.size));
                CGFloat percent      = size.width / size.height;
              NSString  *photoStr   = [NSString stringWithFormat:@"iosLvYueFriendCircle%d%d%d%d%d%d(%d)%.2f", year, month, day, hour, minute, second, i, percent];
                
                if (!photoStrng1) {
                    photoStrng1 = [NSString stringWithFormat:@"%@",photoStr];
                }else {
                   photoStrng1  = [photoStrng1 stringByAppendingString:[NSString stringWithFormat:@",%@", photoStr]];
                }

            NSLog(@"555555555555555555555555555%@",photoStrng1);

                
                
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
            
          
            
                              NSString *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userId"];
                              if (![photoStrng1 isEqualToString:@""]) {
                                  //服务器获取图片
                                  NSLog(@"66666666666666666666666666666666660");
                                  NSLog(@"%@",photoStrng1);
                                  [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/date/addPersonalDate",REQUESTHEADER] andParameter:@{@"userId":userId,@"activityTime":[NSString stringWithFormat:@"%ld000",(long)self.timesStamp],@"dateTypeId":self.dateTypeId,@"dateTagNameArr":buyAndSong,@"dateSignature":cellH.savView.text,@"datePhoto":photoStrng1,@"provinceId":provinceId,@"cityId":cityId,@"districtId":distriId,@"dateLongitude":@"0",@"dateLatitude":@"0"} success:^(id successResponse) {
                                      
                                      NSLog(@"发布约会:%@",successResponse);
                                      
                                      MLOG(@"结果:%@",successResponse[@"errorMsg"]);
                                      [MBProgressHUD hideHUD];
                                      if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
                                          [MBProgressHUD showSuccess:@"发布成功"];
                                          [self sendedchuli];
                                          
                                      } else {
                                          [MBProgressHUD hideHUD];
                                          [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
                                      }
                                  } andFailure:^(id failureResponse) {
                                      [MBProgressHUD hideHUD];
                                      [MBProgressHUD showError:@"服务器繁忙,请重试"];
                                  }];
                              }
        
                
            
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
}


-(void)upData{
    
}
/**
 *  压缩图片
 *
 *  @param image       需要压缩的图片
 *  @param fImageBytes 希望压缩后的大小(以KB为单位)
 *
 *  @return 压缩后的图片
 */
- (void)compressedImageFiles:(UIImage *)image
                     imageKB:(CGFloat)fImageKBytes
                  imageBlock:(void(^)(UIImage *image))block {
    
    __block UIImage *imageCope = image;
    CGFloat fImageBytes = fImageKBytes * 1024;//需要压缩的字节Byte
    
    __block NSData *uploadImageData = nil;
    
    uploadImageData = UIImagePNGRepresentation(imageCope);
    NSLog(@"图片压前缩成 %fKB",uploadImageData.length/1024.0);
    CGSize size = imageCope.size;
    CGFloat imageWidth = size.width;
    CGFloat imageHeight = size.height;
    
    if (uploadImageData.length > fImageBytes && fImageBytes >0) {
        
        dispatch_async(dispatch_queue_create("CompressedImage", DISPATCH_QUEUE_SERIAL), ^{
            
            /* 宽高的比例 **/
            CGFloat ratioOfWH = imageWidth/imageHeight;
            /* 压缩率 **/
            CGFloat compressionRatio = fImageBytes/uploadImageData.length;
            /* 宽度或者高度的压缩率 **/
            CGFloat widthOrHeightCompressionRatio = sqrt(compressionRatio);
            
            CGFloat dWidth   = imageWidth *widthOrHeightCompressionRatio;
            CGFloat dHeight  = imageHeight*widthOrHeightCompressionRatio;
            if (ratioOfWH >0) { /* 宽 > 高,说明宽度的压缩相对来说更大些 **/
                dHeight = dWidth/ratioOfWH;
            }else {
                dWidth  = dHeight*ratioOfWH;
            }
            
            imageCope = [self drawWithWithImage:imageCope width:dWidth height:dHeight];
            uploadImageData = UIImagePNGRepresentation(imageCope);
            
            NSLog(@"当前的图片已经压缩成 %fKB",uploadImageData.length/1024.0);
            //微调
            NSInteger compressCount = 0;
            /* 控制在 1M 以内**/
            while (fabs(uploadImageData.length - fImageBytes) > 1024) {
                /* 再次压缩的比例**/
                CGFloat nextCompressionRatio = 0.9;
                
                if (uploadImageData.length > fImageBytes) {
                    dWidth = dWidth*nextCompressionRatio;
                    dHeight= dHeight*nextCompressionRatio;
                }else {
                    dWidth = dWidth/nextCompressionRatio;
                    dHeight= dHeight/nextCompressionRatio;
                }
                
                imageCope = [self drawWithWithImage:imageCope width:dWidth height:dHeight];
                uploadImageData = UIImagePNGRepresentation(imageCope);
                
                /*防止进入死循环**/
                compressCount ++;
                if (compressCount == 10) {
                    break;
                }
                
            }
            
            NSLog(@"图片已经压缩成 %fKB",uploadImageData.length/1024.0);
            imageCope = [[UIImage alloc] initWithData:uploadImageData];
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                block(imageCope);
            });
        });
    }
    else
    {
        block(imageCope);
    }
}

/* 根据 dWidth dHeight 返回一个新的image**/
- (UIImage *)drawWithWithImage:(UIImage *)imageCope width:(CGFloat)dWidth height:(CGFloat)dHeight{
    
    UIGraphicsBeginImageContext(CGSizeMake(dWidth, dHeight));
    [imageCope drawInRect:CGRectMake(0, 0, dWidth, dHeight)];
    imageCope = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCope;
}

#pragma mark   -------约会发布成功后需要处理的事情
-(void)sendedchuli{
   self.dateTypeId = @"";
    typeLabel.text = @"";
     imageView.image = [UIImage imageNamed:@""];
    timeLabel.text =@"";
    cityLabel.text = @"";
    provinceId = @"";
    cityId = @"";
    buyStr = @"";
    songStr = @"";
    lastSongBtn.selected = NO;
    lastSongBtn.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];
    lastSongBtn = nil;
    lastBuyBtn.selected = NO;
    lastBuyBtn.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];
    lastBuyBtn = nil;
    //先清除scrollView上部分的子控件
    for (UIView *subView in cellH.photoView.subviews) {
     
        [subView removeFromSuperview];
    }
    
//    [self.imageNArr removeAllObjects];
      [self.imageArray removeAllObjects];
    cellH.addPhotoBtn.centerX =16+ 76*AutoSizeScaleX*self.imageArray.count+30*AutoSizeScaleX;
    sayView.text = @"";
    
//    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    RootTabBarController *tab = (RootTabBarController *)delegate.window.rootViewController;
//    tab.selectedIndex = 0;
    [self.navigationController popViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadUIData" object:nil];
}
#pragma mark   -------点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section==0&&indexPath.row==0) {
        //我要约 。。。。。
        meWantVC *meVC = [[meWantVC alloc]init];
        
        __weak __typeof(self)weakSelf = self;
        [meVC returnText:^(NSString *dateTypeName, NSString *dateTypeId, NSString *selectImageName) {
       
            tLabel.text = dateTypeName;
            weakSelf.dateTypeId = dateTypeId;
            imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:selectImageName]];

        }];
//        [meVC returnText:^(NSString *showText, NSString *imageName) {
//            tLabel.text = showText;
//            imageView.image = [UIImage imageNamed:imageName];
//        }];
        [self.navigationController pushViewController:meVC animated:YES];
    }
    
    
    if (indexPath.section==0&&indexPath.row==1) {
        //弹出日历
//        SZCalendarPicker *calendar = [SZCalendarPicker showOnView:self.view];
//        calendar.today = [NSDate date];
//        calendar.date = calendar.today;
//        calendar.frame = CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT-200);
//        calendar.calendarBlock =  ^(NSInteger day, NSInteger month, NSInteger year){
//           
//            NSLog(@"%d++%d+%d",day,month,year);
//        };
        self.calendarView.hidden = !self.calendarView.hidden;
        
        
    }
    
    if (indexPath.section==0&&indexPath.row ==2) {
        //地点
        selectProvinceVC *province = [[selectProvinceVC alloc]init];
      [province currnentLocationBlock:^(NSString *currentProvince, NSString *currentCity, NSString *currentDistrict) {
          cityLabel.text = [NSString stringWithFormat:@"%@%@%@",currentProvince,currentCity,currentDistrict];
         
          
          NSString *a = [currentProvince substringFromIndex:currentProvince.length-1];
         
          if (currentProvince) {
              if ([a isEqualToString:@"省"]) {
                  NSString *str = [currentProvince substringWithRange:NSMakeRange(0, currentProvince.length-1)];
                  [self getProviId:str];
              }else{
                  [self getProviId:currentProvince];}
          }
          
           NSString *b = [currentCity substringFromIndex:currentCity.length-1];
          if (currentCity) {
              if ([b isEqualToString:@"市"]) {
                   NSString *str = [currentCity substringWithRange:NSMakeRange(0, currentCity.length-1)];
                 [self getCityId:str];
              }else{
                  
                  [self getCityId:currentCity];
              }
          }
          
          if (currentDistrict) {
              [self getDisId:currentDistrict];
          }
       
      }];
        [self.navigationController pushViewController:province animated:YES];
    }
    
    
}


-(void)getProviId:(NSString *)proStr{
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/cache/getProvinceByName",REQUESTHEADER] andParameter:@{@"provinceName":proStr} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        [MBProgressHUD hideHUD];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            provinceId= [NSString stringWithFormat:@"%@",successResponse[@"data"][@"provinceId"]];
        } else {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
}

-(void)getCityId:(NSString *)cityByName{
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/cache/getCityByName",REQUESTHEADER] andParameter:@{@"cityName":cityByName} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        [MBProgressHUD hideHUD];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            cityId= [NSString stringWithFormat:@"%@",successResponse[@"data"][@"cityId"]];
        } else {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
}
-(void)getDisId:(NSString *)districtName{
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/cache/getDistrictByName",REQUESTHEADER] andParameter:@{@"districtName":districtName} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        [MBProgressHUD hideHUD];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            distriId= [NSString stringWithFormat:@"%@",successResponse[@"data"][@"districtId"]];
        } else {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
}


#pragma mark  改变传值
- (void)passType:(NSString *)TypeStr{
    
    
   
    //这里面是cell的副标题的值
    type = TypeStr;
    
    
}

- (void)setNav{
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:@"#ffffff"];
    
    //返回按钮
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    backBtn.frame = CGRectMake(16, 38, 40,40);
    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    backBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [backBtn setTitleColor:[UIColor colorWithHexString:@"#424242"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    //中间发布约会
    UILabel *yueLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 35)];
    yueLabel.text = @"发布约会";
    yueLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:18];
    yueLabel.textColor = [UIColor colorWithHexString:@"424242"];
    self.navigationItem.titleView = yueLabel;
    
//    //右上角发布按钮
//    UIButton *selectBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 25)];
//    [selectBtn setTitle:@"发布" forState:UIControlStateNormal];
//    [selectBtn setTitleColor:[UIColor colorWithHexString:@"#ff5252"] forState:UIControlStateNormal];
//    selectBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
//    [selectBtn addTarget:self action:@selector(select) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:selectBtn];
//    self.navigationItem.rightBarButtonItem = rightItem;
    
}




- (void)back{
    
//     self.hidesBottomBarWhenPushed = NO;
    
//       [[NSNotificationCenter defaultCenter]postNotificationName:@"push" object:nil userInfo:@{@"push":@"homeVC"}];
    
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark   ---时间转化成时间戳


//提示消失
- (void)goOut{
    
    [publishImage removeFromSuperview];
    
}



- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"push" object:nil];
   [[NSNotificationCenter defaultCenter] removeObserver:self name:@"currentplace" object:nil];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
    
}






@end
