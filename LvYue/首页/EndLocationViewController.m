//
//  EndLocationViewController.m
//  LvYue
//
//  Created by 広有射怪鸟事 on 15/10/21.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import "EndLocationViewController.h"
#import "LocationModel.h"
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "MBProgressHUD+NJ.h"

@interface EndLocationViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) NSMutableArray *locationArray;
@property (nonatomic,strong) LocationModel *model;
@property (nonatomic,strong) UITableView *tableV;

@end

@implementation EndLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"定位";
    
    self.tableV = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight)];
    self.tableV.delegate = self;
    self.tableV.dataSource = self;
    self.tableV.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableV];
    self.locationArray = [[NSMutableArray alloc] init];
    
    [self getDataFromWeb];
}

- (void)getDataFromWeb{
    [MBProgressHUD showMessage:nil  toView:self.view];
    
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/area/list",REQUESTHEADER] andParameter:@{@"id":self.proId} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            [self.locationArray removeAllObjects];
            for (NSDictionary *dict in successResponse[@"data"][@"list"]) {
                self.model = [[LocationModel alloc] initWithDict:dict];
                [self.locationArray addObject:self.model];
            }
            [self.tableV reloadData];
        } else {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
}

#pragma mark table代理方法

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return 30;
    }
    else if(indexPath.row == 2){
        return 12;
    }
    return 48;
}

//设置cell的数目
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.locationArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row < 3) {
        return;
    }
    
    self.model = self.locationArray[indexPath.row - 3];
    if ([self.preView isEqualToString:@"search"]) {
        NSDictionary *dict = @{@"searchCountry":self.countryId,@"countryName":self.countryName,@"searchPro":self.proId,@"proName":self.proName,@"searchCity":self.model.id,@"cityName":self.model.name};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"searchCity" object:nil userInfo:dict];
        NSArray *array = [self.navigationController viewControllers];
        [self.navigationController popToViewController:array[1] animated:YES];
    }
    else if ([self.preView isEqualToString:@"live"]){
        NSDictionary *dict = @{@"searchCountry":self.countryId,@"countryName":self.countryName,@"searchPro":self.proId,@"proName":self.proName,@"searchCity":self.model.id,@"cityName":self.model.name};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"liveSelect" object:nil userInfo:dict];
        NSArray *array = [self.navigationController viewControllers];
        [self.navigationController popToViewController:array[1] animated:YES];
    }
    else if ([self.preView isEqualToString:@"addLive"]){
        NSDictionary *dict = @{@"searchCountry":self.countryId,@"countryName":self.countryName,@"searchPro":self.proId,@"proName":self.proName,@"searchCity":self.model.id,@"cityName":self.model.name};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"addLive" object:nil userInfo:dict];
        NSArray *array = [self.navigationController viewControllers];
        [self.navigationController popToViewController:array[2] animated:YES];
    }
    else{
        [MBProgressHUD showMessage:nil toView:self.view];
        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/update",REQUESTHEADER] andParameter:@{@"id":[NSString stringWithFormat:@"%@",[LYUserService sharedInstance].userID],@"country":self.countryId,@"province":self.proId,@"city":self.model.id} success:^(id successResponse) {
            MLOG(@"结果:%@",successResponse);
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
                NSDictionary *dict = @{@"countryName":self.countryName,@"proName":self.proName,@"cityName":self.model.name};
                [[NSNotificationCenter defaultCenter] postNotificationName:@"changeLocation" object:nil userInfo:dict];
                NSArray *array = [self.navigationController viewControllers];
                [self.navigationController popToViewController:array[1] animated:YES];
                
            } else {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
            }
        } andFailure:^(id failureResponse) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [MBProgressHUD showError:@"服务器繁忙,请重试"];
        }];
    }
}

//创建每个cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cellIdentifier";
    //分割用的cell
    if (indexPath.row == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        [cell setBackgroundColor:UIColorWithRGBA(234, 234, 234, 1)];
        cell.textLabel.text = @"全部地区";
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
        int temp = 158;
        cell.textLabel.textColor = UIColorWithRGBA(temp, temp, temp, 1);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    //已选中的地区
    else if(indexPath.row == 1) {
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        cell.textLabel.text = _preLoc;
        //设置已选地区label
        UILabel *selectedLabel = [[UILabel alloc]initWithFrame:CGRectMake(kMainScreenWidth - 100, 0, 100, 48)];
        selectedLabel.textColor = UIColorWithRGBA(158, 158, 158, 1);
        selectedLabel.text = @"已选地区";
        selectedLabel.font = [UIFont systemFontOfSize:15];
        [cell addSubview:selectedLabel];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.userInteractionEnabled = NO;
        return cell;
    }
    else if (indexPath.row == 2){
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        [cell setBackgroundColor:UIColorWithRGBA(234, 234, 234, 1)];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else{
        //所有地区
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (self.locationArray.count) {
            [cell setBackgroundColor:[UIColor redColor]];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] init];
            }
            UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 47, kMainScreenWidth,1)];
            lineView.backgroundColor = UIColorWithRGBA(234, 234, 234, 1);
            [cell addSubview:lineView];
            self.model = self.locationArray[indexPath.row - 3];
            cell.textLabel.text = self.model.name;
        }
        
        return cell;
    }
}

@end
