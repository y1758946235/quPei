//
//  DateListViewController.m
//  澜庭
//
//  Created by 广有射怪鸟事 on 15/9/24.
//  Copyright (c) 2015年 刘瀚韬. All rights reserved.
//

#import "MyLvyueViewController.h"
#import "DateListTableViewCell.h"
#import "DateDetailViewController.h"
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "MBProgressHUD+NJ.h"
#import "DateListModel.h"
#import "MyInfoModel.h"
#import "DetailDataViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "AllWordViewController.h"

@interface MyLvyueViewController ()<UITableViewDataSource,UITableViewDelegate,CLLocationManagerDelegate>

@property (nonatomic,strong) DateListModel *dateModel;
@property (nonatomic,strong) MyInfoModel *infoModel;
@property (nonatomic,strong) NSMutableArray *modelArray;//模型数组
@property (nonatomic,strong) NSMutableArray *userArray;//用户数组
@property (nonatomic,strong) UITableView *table;
@property (nonatomic,strong) DateListTableViewCell *cell;

@property (nonatomic,strong) NSString *rowHeight;

//定位信息管理者
@property (nonatomic, strong) CLLocationManager *clManager;

//地理编码对象
@property (nonatomic, strong) CLGeocoder *geocoder;

@property (nonatomic,strong) NSString *latitude;
@property (nonatomic,strong) NSString *longitude;

@end

@implementation MyLvyueViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"我的豆客";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteOk) name:@"deleteOk" object:nil];
    
    self.modelArray = [[NSMutableArray alloc] init];
    self.userArray = [[NSMutableArray alloc] init];
    
    [self createTableView];
    
    [self getDataFromWeb];
    
}

- (void)deleteOk{
    [self getDataFromWeb];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark 网络请求

- (void)getDataFromWeb{
    [MBProgressHUD showMessage:nil toView:self.view];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/dating/personList",REQUESTHEADER] andParameter:@{@"user_id":[NSString stringWithFormat:@"%@",[LYUserService sharedInstance].userID]} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            [self.modelArray removeAllObjects];
            [self.userArray removeAllObjects];
            NSArray *array = successResponse[@"data"][@"list"];
            for (NSDictionary *dict in array) {
                self.dateModel = [[DateListModel alloc] initWithDict:dict];
                [self.modelArray addObject:self.dateModel];
                NSDictionary *dic = self.dateModel.user;
                self.infoModel = [[MyInfoModel alloc] initWithDict:dic];
                [self.userArray addObject:self.infoModel];
            }
            if (self.modelArray.count == 0) {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            }
            [self.table reloadData];
        } else {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
}

//创建tableview
- (void)createTableView{
    self.table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight) style:UITableViewStyleGrouped];
    self.table.delegate = self;
    self.table.dataSource = self;
    [self.view addSubview:self.table];
}


#pragma mark tableview代理事件

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.modelArray.count) {
        return self.modelArray.count;
    }
    else{
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *csarray = [self.dateModel.photos componentsSeparatedByString:@";"];
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:csarray];
    
    if ([[array lastObject] isEqualToString:@""]) {
        [array removeLastObject];
    }
    
    if (array.count <= 3 && array.count > 0) {
        return 230;
    }
    else if (array.count >= 3 && array.count <= 6){
        return 319;
    }
    else if (array.count > 6){
        return 392;
    }
    else{
        return 170;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    self.cell = [DateListTableViewCell myCellWithTableView:tableView indexPath:indexPath];
    self.cell.last = @"my";
    if (self.modelArray.count > 0 && self.userArray.count > 0) {
        self.dateModel = self.modelArray[indexPath.section];
        self.infoModel = self.userArray[indexPath.section];
        [self.cell fillDataWithModel:self.dateModel andInfoModel:self.infoModel];
        [self.cell.checkBtn addTarget:self action:@selector(checkAction:) forControlEvents:UIControlEventTouchUpInside];
        self.cell.navi = self.navigationController;
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    return self.cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 20;
    }
    else{
        return 0.1;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    AllWordViewController *all = [[AllWordViewController alloc] init];
    self.dateModel = self.modelArray[indexPath.section];
    all.detail = self.dateModel.content;
    [self.navigationController pushViewController:all animated:YES];
}

#pragma mark 查看详细资料事件

- (void)checkAction:(UIButton *)sender{
    
    UITableViewCell *cell = (UITableViewCell *)[[sender superview] superview];
    NSIndexPath *indexPath = [self.table indexPathForCell:cell];
    NSInteger section = indexPath.section;
    
    self.infoModel = self.userArray[section];
    DetailDataViewController *deta = [[DetailDataViewController alloc] init];
    deta.friendId = self.infoModel.id;
    [self.navigationController pushViewController:deta animated:YES];
}

@end
