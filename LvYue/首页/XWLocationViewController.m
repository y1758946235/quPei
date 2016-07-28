//
//  LocationViewController.m
//  豆客项目
//
//  Created by Xia Wei on 15/10/9.
//  Copyright © 2015年 Xia Wei. All rights reserved.
//

#import "XWLocationViewController.h"
#import "LocationModel.h"
#import "MBProgressHUD+NJ.h"
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "EndLocationViewController.h"

@interface XWLocationViewController ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong)NSMutableArray *dataArr;
@property (nonatomic,strong) NSMutableArray *locationArray;
@property (nonatomic,strong) LocationModel *model;
@property (nonatomic,strong) UITableView *tableV;
@property (nonatomic,strong) NSString *countryNum;

@end

@implementation XWLocationViewController

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self tableViewCreated];
    
    _dataArr = [[NSMutableArray alloc]init];
    self.locationArray = [[NSMutableArray alloc] init];
    
    //如果是选择省份的话
    if (_isProvince == YES) {
        //添加测试数据
        for (int i = 0; i < 100; i ++) {
            NSString *str = [NSString stringWithFormat:@"%d省",i];
            [_dataArr addObject:str];
        }
    }
    //选择城市
    else{
        for (int i = 0; i < 100; i ++) {
            NSString *str = [NSString stringWithFormat:@"%d市",i];
            [_dataArr addObject:str];
        }
    }
    self.title = @"定位";
    
    [self getDataFromWeb];
}

- (void)getDataFromWeb{
    [MBProgressHUD showMessage:nil toView:self.view];
    
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/area/list",REQUESTHEADER] andParameter:@{@"id":self.countryId} success:^(id successResponse) {
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

//创建tableView
- (void) tableViewCreated{
    self.tableV = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight)];
    self.tableV.delegate = self;
    self.tableV.dataSource = self;
    self.tableV.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableV];
}


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
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (_isProvince == YES) {
        if (indexPath.row > 2) {
            EndLocationViewController *next = [[EndLocationViewController alloc]init];
            self.model = self.locationArray[indexPath.row - 3];
            if ([self.model.status integerValue]) {
                next.preLoc = self.model.name;
                next.proId = self.model.id;
                next.countryId = self.countryId;
                next.preView = self.preView;
                next.proName = self.model.name;
                next.countryName = self.countryName;
                [self.navigationController pushViewController:next animated:YES];
            }
            else{
                if ([self.preView isEqualToString:@"search"]) {
                    NSDictionary *dict = @{@"searchCountry":self.countryId,@"countryName":self.countryName,@"searchPro":self.model.id,@"proName":self.model.name};
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"searchPro" object:nil userInfo:dict];
                    NSArray *array = [self.navigationController viewControllers];
                    [self.navigationController popToViewController:array[1] animated:YES];
                }
                else if ([self.preView isEqualToString:@"live"]){
                    NSDictionary *dict = @{@"searchCountry":self.countryId,@"countryName":self.countryName,@"searchPro":self.model.id,@"proName":self.model.name};
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"liveSelect" object:nil userInfo:dict];
                    NSArray *array = [self.navigationController viewControllers];
                    [self.navigationController popToViewController:array[1] animated:YES];
                }
                else if ([self.preView isEqualToString:@"addLive"]){
                    NSDictionary *dict = @{@"searchCountry":self.countryId,@"countryName":self.countryName,@"searchPro":self.model.id,@"proName":self.model.name};
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"addLive" object:nil userInfo:dict];
                    NSArray *array = [self.navigationController viewControllers];
                    [self.navigationController popToViewController:array[2] animated:YES];
                }
                else{
                    [MBProgressHUD showMessage:nil toView:self.view];
                    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/update",REQUESTHEADER] andParameter:@{@"id":[NSString stringWithFormat:@"%@",[LYUserService sharedInstance].userID],@"country":self.countryId,@"province":self.model.id,@"city":self.model.id} success:^(id successResponse) {
                        MLOG(@"结果:%@",successResponse);
                        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
                            NSDictionary *dict = @{@"countryName":self.countryName,@"proName":self.model.name};
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
        }
        
    }
    else{
        //设置通知返回选中的城市给首页
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadLocation_XW" object:nil userInfo:@{@"city":_dataArr[indexPath.row - 3]}];
        [self.navigationController popToRootViewControllerAnimated:YES];
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
        cell.userInteractionEnabled = NO;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
