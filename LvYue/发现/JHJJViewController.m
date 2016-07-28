//
//  JHJJViewController.m
//  LvYueDemo
//
//  Created by 蒋俊 on 15/10/6.
//  Copyright (c) 2015年 vison. All rights reserved.
//

#import "JHJJViewController.h"
#import "JiangHuCell.h"
#import "UILabel+StringFrame.h"
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUD+NJ.h"
#import "JJLModel.h"
#import <CoreLocation/CoreLocation.h>
#import "DetailDataViewController.h"

@interface JHJJViewController ()<CLLocationManagerDelegate>

{
    //保存当前选择的城市
    NSString *currentCity;
}

@property (nonatomic,strong) NSMutableArray *modelArray;
@property (nonatomic,strong) JJLModel *model;
@property (nonatomic,strong) UIButton *helpBtn;

@property (nonatomic,strong) UILabel *numLabel;
@property (nonatomic,strong) UIView *headerView;

@property (nonatomic,strong) NSString *latitude;
@property (nonatomic,strong) NSString *longitude;

@property (nonatomic,assign) float longitudeF;
@property (nonatomic,assign) float latitudeF;

@property (nonatomic,strong) UITextField *contentTextR;

//定位信息管理者
@property (nonatomic, strong) CLLocationManager *clManager;

//地理编码对象
@property (nonatomic, strong) CLGeocoder *geocoder;

@end

@implementation JHJJViewController

#pragma mark - 定位管理者
- (CLLocationManager *)clManager {
    
    if (!_clManager) {
        _clManager = [[CLLocationManager alloc] init];
        //设置定位硬件的精准度
        _clManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        //设置定位硬件的刷新频率
        _clManager.distanceFilter = kCLLocationAccuracyKilometer;
    }
    return _clManager;
}

#pragma mark - 地理编码对象
- (CLGeocoder *)geocoder {
    
    if (_geocoder == nil) {
        _geocoder = [[CLGeocoder alloc] init];
    }
    return _geocoder;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.modelArray = [[NSMutableArray alloc]init];
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = UIColorWithRGBA(245, 245, 245, 1);
    
    [self.view addSubview:_tableView];
    self.title = @"江湖救急令";
    
    self.latitude = @"";
    self.longitude = @"";
    
    self.clManager.delegate = self;
    [MBProgressHUD showMessage:nil toView:self.view];
    
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 8.0) {
        //前台和后台都允许请求用户是否允许开启定位 IOS8.0以上版本需要设置环境参数
        [_clManager requestAlwaysAuthorization];
        [_clManager startUpdatingLocation];
    }
    else {
        //如果是IOS8.0以下的版本，则可直接开启定位
        [_clManager startUpdatingLocation];
    }
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {

    CLLocation *currentLocation = [locations lastObject];
    self.latitude = [NSString stringWithFormat:@"%f",currentLocation.coordinate.latitude];
    self.longitude = [NSString stringWithFormat:@"%f",currentLocation.coordinate.longitude];
    
    //停止定位
    [_clManager stopUpdatingLocation];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self getDataFromWeb];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        //用户允许授权,开启定位
        [_clManager startUpdatingLocation];
    } else {
        [MBProgressHUD showError:@"用户拒绝授权,请在设置中开启"];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [MBProgressHUD showError:@"定位失败,请重试"];
}

#pragma mark 网络请求

- (void)getDataFromWeb{
    
    [MBProgressHUD showMessage:nil toView:self.view];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/notice/iosNoticeList",REQUESTHEADER] andParameter:@{@"userId":[LYUserService sharedInstance].userID,@"noticeType":@"1",@"pageNum":@"1",@"longitude":self.longitude,@"latitude":self.latitude} success:^(id successResponse) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        MLOG(@"结果:%@",successResponse);
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            NSArray *array = successResponse[@"data"][@"noticeList"];
            [self.modelArray removeAllObjects];
            for (NSDictionary *dict in array) {
                self.model = [[JJLModel alloc] initWithDict:dict];
                [self.modelArray addObject:self.model];
            }
            [self.tableView reloadData];
        } else {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
}

- (UIView *)createHeadView{
    UIView *headerView;
    headerView.backgroundColor = UIColorWithRGBA(245, 245, 245, 1);

    headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 70)];
    
    UIView *contentText = [[UIView alloc] initWithFrame:CGRectMake(10, 10, kMainScreenWidth - 100, 50)];
    contentText.backgroundColor = [UIColor whiteColor];
    contentText.layer.cornerRadius = 4;
    [headerView addSubview:contentText];
    
    self.contentTextR = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, contentText.frame.size.width - 50, 50)];
    self.contentTextR.placeholder = @"向附近的人求助（显示30分钟)";
    [self.contentTextR addTarget:self  action:@selector(valueChanged:)  forControlEvents:UIControlEventAllEditingEvents];
    self.contentTextR.font = [UIFont systemFontOfSize:14.0];
    self.contentTextR.backgroundColor = [UIColor whiteColor];
    self.contentTextR.layer.cornerRadius = 4;
    self.contentTextR.textInputView.frame = CGRectMake(10, 0, contentText.frame.size.width - 20, contentText.frame.size.height);
    [self.contentTextR addTarget:self action:@selector(resignFirstResponder) forControlEvents:UIControlEventEditingDidEndOnExit];
    self.contentTextR.returnKeyType = UIReturnKeyDone;
    [contentText addSubview:self.contentTextR];
    
    self.helpBtn = [[UIButton alloc] initWithFrame:CGRectMake(contentText.frame.origin.x + contentText.frame.size.width + 10, 10, kMainScreenWidth - contentText.frame.size.width - 30, 50)];
    if (self.contentTextR.text.length) {
        self.helpBtn.enabled = YES;
        [self.helpBtn setBackgroundColor:[UIColor colorWithRed:29/255.0 green:189/255.0 blue:159/255.0 alpha:1]];
    }
    else{
        self.helpBtn.enabled = NO;
        [self.helpBtn setBackgroundColor:RGBACOLOR(238, 238, 238, 1)];
    }
    [self.helpBtn setTitle:@"求救" forState:UIControlStateNormal];
    [self.helpBtn addTarget:self action:@selector(helpClick) forControlEvents:UIControlEventTouchUpInside];
    [self.helpBtn.layer setCornerRadius:4];
    
    [self.helpBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [headerView addSubview:self.helpBtn];
    
    self.numLabel = [[UILabel alloc] initWithFrame:CGRectMake(contentText.frame.size.width - 50, 15, 50, 20)];
    self.numLabel.text = @"0/200";
    self.numLabel.font = [UIFont systemFontOfSize:12.0];
    [contentText addSubview:self.numLabel];
    
    return headerView;
}

//点击求助按钮
- (void)helpClick{
    
    if ([self isBlankString:self.contentTextR.text]) {
        [MBProgressHUD showError:@"内容不能为空"];
        return;
    }
    
    [MBProgressHUD showMessage:nil toView:self.view];
    [self.contentTextR resignFirstResponder];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/notice/publish",REQUESTHEADER] andParameter:@{@"publisher":[LYUserService sharedInstance].userID,@"noticeType":@"1",@"noticeDetail":self.contentTextR.text,@"longitude":self.longitude,@"latitude":self.latitude} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            [MBProgressHUD showSuccess:@"发送成功"];
            self.contentTextR.text = @"";
            self.helpBtn.enabled = NO;
            [self.helpBtn setBackgroundColor:RGBACOLOR(238, 238, 238, 1)];
            self.numLabel.text = @"0/200";
            [self getDataFromWeb];
        } else {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
    
}

#pragma mark - UITableViewDataSource & Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellID = @"myCell";
    JIangHuCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[JIangHuCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    
    if (self.modelArray.count) {
        self.model = self.modelArray[indexPath.section];
        
        cell.navi = self.navigationController;
        cell.userId = self.model.userId;
        cell.userName = self.model.notice_user;
        
        [cell fillDateWith:self.model];
        [cell.iconBtn addTarget:self action:@selector(checkAction:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
        
    }
    else{
        
        for(int i = 0;i<[cell.subviews count];i++){
            UIView *subView = [cell.subviews objectAtIndex:i];
            subView.hidden = YES;
        }
        cell.backgroundColor = RGBACOLOR(245, 245, 245, 1);
        return cell;
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    if (self.modelArray.count) {
        return self.modelArray.count;
    }
    else{
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //获得该cell
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    
    return cell.frame.size.height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if (section == 0) {
        return 70;
    }
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 0.1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    
    if (section == 0) {
        self.headerView = [self createHeadView];
        return self.headerView;
    }
    else{
        return nil;
    }
}

- (void)valueChanged:(UITextField *)text{
    if (text.text.length > 200){
        [MBProgressHUD showError:@"最多200个字"];
        NSString *sub = [text.text substringToIndex:200];
        text.text = sub;
        return;
    }
#pragma clang push
    
    self.numLabel.text = [NSString stringWithFormat:@"%lu/200",text.text.length];
    if (text.text.length) {
        self.helpBtn.enabled = YES;
        [self.helpBtn setBackgroundColor:[UIColor colorWithRed:29/255.0 green:189/255.0 blue:159/255.0 alpha:1]];
    }
    else{
        self.helpBtn.enabled = NO;
        [self.helpBtn setBackgroundColor:RGBACOLOR(238, 238, 238, 1)];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark 查看详细资料事件

- (void)checkAction:(UIButton *)sender{
    
    UITableViewCell *cell = (UITableViewCell *)[[sender superview] superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSInteger section = indexPath.section;
    
    self.model = self.modelArray[section];
    DetailDataViewController *deta = [[DetailDataViewController alloc] init];
    deta.friendId = [self.model.userId integerValue];
    [self.navigationController pushViewController:deta animated:YES];
}

#pragma mark 判断是否为空或只有空格

- (BOOL)isBlankString:(NSString *)string{
    
    if (string == nil) {
        return YES;
    }
    
    if (string == NULL) {
        return YES;
    }
    
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}

@end
