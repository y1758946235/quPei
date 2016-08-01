//
//  DateListViewController.m
//  澜庭
//
//  Created by 广有射怪鸟事 on 15/9/24.
//  Copyright (c) 2015年 刘瀚韬. All rights reserved.
//

#import "AllWordViewController.h"
#import "DateDetailViewController.h"
#import "DateListModel.h"
#import "DateListTableViewCell.h"
#import "DateListViewController.h"
#import "LYDetailDataViewController.h"
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "MBProgressHUD+NJ.h"
#import "MyInfoModel.h"
#import <CoreLocation/CoreLocation.h>

@interface DateListViewController () <UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) DateListModel *dateModel;
@property (nonatomic, strong) MyInfoModel *infoModel;
@property (nonatomic, strong) NSMutableArray *modelArray; //模型数组
@property (nonatomic, strong) NSMutableArray *userArray;  //用户数组
@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) DateListTableViewCell *cell;

@property (nonatomic, strong) NSString *rowHeight;

//定位信息管理者
@property (nonatomic, strong) CLLocationManager *clManager;

//地理编码对象
@property (nonatomic, strong) CLGeocoder *geocoder;

@property (nonatomic, strong) NSString *latitude;
@property (nonatomic, strong) NSString *longitude;

@property (nonatomic, strong) NSMutableArray *selectArray;

@end

@implementation DateListViewController

#pragma mark - 定位管理者
- (CLLocationManager *)clManager {

    if (!_clManager) {
        _clManager = [[CLLocationManager alloc] init];
        //设置定位硬件的精准度
        _clManager.desiredAccuracy = kCLLocationAccuracyBest;
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

    self.rowHeight = @"212";

    self.modelArray  = [[NSMutableArray alloc] init];
    self.userArray   = [[NSMutableArray alloc] init];
    self.selectArray = [[NSMutableArray alloc] init];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goGet:) name:@"goGet" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DateReportJumpToLogin) name:@"DateReportJumpToLogin" object:nil]; //cell中的举报通知

    [self createBackBtn];
    [self createTableView];

    self.latitude  = @"";
    self.longitude = @"";

    [MBProgressHUD showMessage:nil toView:self.view];
    self.clManager.delegate = self;
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 8.0) {
        //前台和后台都允许请求用户是否允许开启定位 IOS8.0以上版本需要设置环境参数
        [_clManager requestAlwaysAuthorization];
        [_clManager startUpdatingLocation];
    } else {
        //如果是IOS8.0以下的版本，则可直接开启定位
        [_clManager startUpdatingLocation];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)goGet:(NSNotification *)aNotification {
    [self getDataFromWeb];
}

- (void)DateReportJumpToLogin {
    [[LYUserService sharedInstance] jumpToLoginWithController:self];
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {

    CLLocation *currentLocation = [locations lastObject];
    self.latitude               = [NSString stringWithFormat:@"%f", currentLocation.coordinate.latitude];
    self.longitude              = [NSString stringWithFormat:@"%f", currentLocation.coordinate.longitude];

    //停止定位
    [_clManager stopUpdatingLocation];
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

- (void)getDataFromWeb {

    [[LYUserService sharedInstance] fetchLoginStateWithCompeletionBlock:^(UserLoginStateType type) {
        if (type == UserLoginStateTypeWaitToLogin) {
            [MBProgressHUD showMessage:nil toView:self.view];
            [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/dating/list", REQUESTHEADER] andParameter:@{ @"type": self.dateType,
                                                                                                                                    @"latitude": self.latitude,
                                                                                                                                    @"longitude": self.longitude,
                                                                                                                                    @"isToristEnter": @"1" }
                success:^(id successResponse) {
                    MLOG(@"结果:%@", successResponse);
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
                        [self.modelArray removeAllObjects];
                        [self.userArray removeAllObjects];
                        NSArray *array = successResponse[@"data"][@"list"];
                        for (NSDictionary *dict in array) {
                            self.dateModel = [[DateListModel alloc] initWithDict:dict];
                            [self.modelArray addObject:self.dateModel];
                            NSDictionary *dic = self.dateModel.user;
                            self.infoModel    = [[MyInfoModel alloc] initWithDict:dic];
                            [self.userArray addObject:self.infoModel];
                        }
                        if (self.modelArray.count == 0) {
                            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                        }
                        [self.table reloadData];
                    } else {
                        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                        [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"msg"]]];
                    }
                }
                andFailure:^(id failureResponse) {
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    [MBProgressHUD showError:@"服务器繁忙,请重试"];
                }];
        } else if (type == UserLoginStateTypeAlreadyLogin) {
            [MBProgressHUD showMessage:nil toView:self.view];
            [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/dating/list", REQUESTHEADER] andParameter:@{ @"user_id": [LYUserService sharedInstance].userID,
                                                                                                                                    @"type": self.dateType,
                                                                                                                                    @"latitude": self.latitude,
                                                                                                                                    @"longitude": self.longitude }
                success:^(id successResponse) {
                    MLOG(@"结果:%@", successResponse);
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
                        [self.modelArray removeAllObjects];
                        [self.userArray removeAllObjects];
                        NSArray *array = successResponse[@"data"][@"list"];
                        for (NSDictionary *dict in array) {
                            self.dateModel = [[DateListModel alloc] initWithDict:dict];
                            [self.modelArray addObject:self.dateModel];
                            NSDictionary *dic = self.dateModel.user;
                            self.infoModel    = [[MyInfoModel alloc] initWithDict:dic];
                            [self.userArray addObject:self.infoModel];
                            [self.selectArray addObject:@"0"];
                        }
                        if (self.modelArray.count == 0) {
                            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                        }
                        [self.table reloadData];
                    } else {
                        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                        [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"msg"]]];
                    }
                }
                andFailure:^(id failureResponse) {
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    [MBProgressHUD showError:@"服务器繁忙,请重试"];
                }];
        }
    }];
}

//创建tableview
- (void)createTableView {
    self.table                 = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight) style:UITableViewStyleGrouped];
    self.table.delegate        = self;
    self.table.dataSource      = self;
    self.table.backgroundColor = RGBACOLOR(250, 250, 250, 1);
    self.table.separatorStyle  = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.table];
}

//back按钮创建
- (void)createBackBtn {

    [self setRightButton:[UIImage imageNamed:@"添加"] title:@"" target:self action:@selector(StartDate) rect:CGRectMake(0, 0, 20, 20)];
}

//发起豆客事件
- (void)StartDate {

    [[LYUserService sharedInstance] fetchLoginStateWithCompeletionBlock:^(UserLoginStateType type) {
        if (type == UserLoginStateTypeWaitToLogin) {
            [[LYUserService sharedInstance] jumpToLoginWithController:self];
        } else if (type == UserLoginStateTypeAlreadyLogin) {
            DateDetailViewController *detail = [[DateDetailViewController alloc] init];
            detail.type                      = self.dateType;
            [self.navigationController pushViewController:detail animated:YES];
        }
    }];
}


#pragma mark tableview代理事件

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.modelArray.count) {
        return self.modelArray.count;
    } else {
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    self.dateModel        = self.modelArray[indexPath.section];
    NSArray *csarray      = [self.dateModel.photos componentsSeparatedByString:@";"];
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:csarray];

    if ([[NSString stringWithFormat:@"%@", array.lastObject] isEqualToString:@""]) {
        [array removeLastObject];
    }

    if (array.count <= 3 && array.count > 0) {
        return 230;
    } else if (array.count >= 3 && array.count <= 6) {
        return 319;
    } else if (array.count > 6) {
        return 392;
    } else {
        return 170;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    self.cell      = [DateListTableViewCell myCellWithTableView:tableView indexPath:indexPath];
    self.cell.last = @"all";
    if (self.modelArray.count > 0 && self.userArray.count > 0) {
        self.dateModel           = self.modelArray[indexPath.section];
        self.infoModel           = self.userArray[indexPath.section];
        self.cell.currentSection = indexPath.section;
        self.cell.selectArray    = self.selectArray;
        [self.cell fillDataWithModel:self.dateModel andInfoModel:self.infoModel];
        self.cell.applyBtn.tag = 300 + indexPath.section;
        [self.cell.applyBtn addTarget:self action:@selector(applyBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.cell.checkBtn addTarget:self action:@selector(checkAction:) forControlEvents:UIControlEventTouchUpInside];
        self.cell.navi = self.navigationController;
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    return self.cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AllWordViewController *all = [[AllWordViewController alloc] init];
    self.dateModel             = self.modelArray[indexPath.section];
    all.detail                 = self.dateModel.content;
    [self.navigationController pushViewController:all animated:YES];
}

#pragma mark 查看详细资料事件

- (void)checkAction:(UIButton *)sender {

    UITableViewCell *cell  = (UITableViewCell *) [[sender superview] superview];
    NSIndexPath *indexPath = [self.table indexPathForCell:cell];
    NSInteger section      = indexPath.section;

    self.infoModel                   = self.userArray[section];
    LYDetailDataViewController *deta = [[LYDetailDataViewController alloc] init];
    deta.userId                      = [NSString stringWithFormat:@"%ld", (long) self.infoModel.id];
    [self.navigationController pushViewController:deta animated:YES];
}

#pragma mark 应邀事件

- (void)applyBtnClick:(UIButton *)sender {
    [[LYUserService sharedInstance] fetchLoginStateWithCompeletionBlock:^(UserLoginStateType type) {
        if (type == UserLoginStateTypeWaitToLogin) {
            [[LYUserService sharedInstance] jumpToLoginWithController:self];
        } else if (type == UserLoginStateTypeAlreadyLogin) {
            [MBProgressHUD showMessage:nil toView:self.view];
            self.dateModel = self.modelArray[sender.tag - 300];
            [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/group/enterRequest", REQUESTHEADER] andParameter:@{ @"user_id": [NSString stringWithFormat:@"%@", [LYUserService sharedInstance].userID],
                                                                                                                                           @"group_id": self.dateModel.group_id,
                                                                                                                                           @"type": @"123" }
                success:^(id successResponse) {
                    MLOG(@"结果:%@", successResponse);
                    if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
                        [MBProgressHUD hideHUDForView:self.view];
                        [MBProgressHUD showSuccess:@"已申请"];
                        [sender setTitle:@"已申请" forState:UIControlStateNormal];
                        [sender setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
                        [sender setBackgroundColor:[UIColor whiteColor]];
                        sender.layer.borderColor = [UIColor lightGrayColor].CGColor;
                        sender.enabled           = NO;
                    } else {
                        [MBProgressHUD hideHUDForView:self.view];
                        [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"msg"]]];
                    }
                }
                andFailure:^(id failureResponse) {
                    [MBProgressHUD hideHUDForView:self.view];
                    [MBProgressHUD showError:@"服务器繁忙,请重试"];
                }];
        }
    }];
}

@end
