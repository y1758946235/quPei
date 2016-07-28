//
//  PeopleLiveViewController.m
//  LvYue
//
//  Created by LHT on 15/11/12.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import "MyLiveViewController.h"
#import "PeopleLiveTableViewCell.h"
#import "AddLiveViewController.h"
#import "MBProgressHUD+NJ.h"
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "LiveModel.h"
#import <CoreLocation/CoreLocation.h>
#import "DetailDataViewController.h"
#import "AllWordViewController.h"
#import "SelectCityTableViewCell.h"
#import "LocalCountryViewController.h"
#import "UIImageView+WebCache.h"

@interface MyLiveViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    //保存当前选择的城市
    NSString *currentCity;
}

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) LiveModel *liveModel;
@property (nonatomic,strong) NSMutableArray *liveArray;
@property (nonatomic,strong) NSString *cityId;

@end

@implementation MyLiveViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"我的民宿";
    
    self.liveArray = [[NSMutableArray alloc] init];
    
    [self createTableView];
    
    self.cityId = @"";

    [self getDataFromWeb];
    
}

- (void)createTableView{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight) style:UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
}

#pragma mark 网络请求

- (void)getDataFromWeb{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [MBProgressHUD showMessage:nil toView:self.view];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/hostel/hostelList",REQUESTHEADER] andParameter:@{@"id":[LYUserService sharedInstance].userID} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            [self.liveArray removeAllObjects];
            for (NSDictionary *dict in successResponse[@"data"][@"list"]) {
                self.liveModel = [[LiveModel alloc] initWithDict:dict];
                [self.liveArray addObject:self.liveModel];
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

#pragma mark tableview 代理

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.liveArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    self.liveModel = self.liveArray[indexPath.section];
    
    NSArray *csarray = [self.liveModel.photos componentsSeparatedByString:@";"];
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:csarray];
    
    if ([self isBlankString:array.lastObject]) {
        [array removeLastObject];
    }
    if ([self.liveModel.photos isEqualToString:@"<null>"]) {
        [array removeAllObjects];
    }
    
    if (array.count <= 3 && array.count > 0) {
        return 230;
    }
    else if (array.count >= 3 && array.count <= 6){
        return 299;
    }
    else if (array.count > 6){
        return 392;
    }
    else{
        return 150;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.liveArray.count) {
        PeopleLiveTableViewCell *cell = [PeopleLiveTableViewCell myCellWithTableView:tableView indexPath:indexPath];
        self.liveModel = self.liveArray[indexPath.section];
        [cell fillDataWithModel:self.liveModel];
        cell.navi = self.navigationController;
        [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,self.icon]]];
        cell.nameLabel.text = self.name;
        cell.deleteBtn.hidden = NO;
        [cell.checkBtn addTarget:self action:@selector(checkAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.deleteBtn addTarget:self action:@selector(deleteLive:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    else{
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    AllWordViewController *all = [[AllWordViewController alloc] init];
    self.liveModel = self.liveArray[indexPath.section];
    all.detail = self.liveModel.content;
    [self.navigationController pushViewController:all animated:YES];
    
}

#pragma mark 查看详细资料事件

- (void)checkAction:(UIButton *)sender{
    DetailDataViewController *deta = [[DetailDataViewController alloc] init];
    deta.friendId = [[LYUserService sharedInstance].userID integerValue];
    [self.navigationController pushViewController:deta animated:YES];
}

#pragma mark 删除民宿

- (void)deleteLive:(UIButton *)btn{
    
    UITableViewCell *cell = (UITableViewCell *)[[btn superview] superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSInteger section = indexPath.section;
    
    self.liveModel = self.liveArray[section];
    
    [MBProgressHUD showMessage:nil toView:self.view];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/hostel/delete",REQUESTHEADER] andParameter:@{@"id":[NSString stringWithFormat:@"%@",self.liveModel.liveId]} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            [MBProgressHUD showSuccess:@"删除成功"];
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
