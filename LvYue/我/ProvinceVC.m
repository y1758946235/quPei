//
//  ProvinceVC.m
//  LvYue
//
//  Created by X@Han on 16/12/29.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "ProvinceVC.h"
#import "MBProgressHUD+NJ.h"
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "LocationModel.h"
#import "EndLocationViewController.h"

@interface ProvinceVC ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)NSMutableArray *dataArr;
@property (nonatomic,strong) NSMutableArray *locationArray;
@property (nonatomic,strong) LocationModel *model;
@property (nonatomic,strong) UITableView *tableV;
@property (nonatomic,strong) NSString *countryNum;



@end

@implementation ProvinceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNav];
    
    [self tableViewCreated];
    
    _dataArr = [[NSMutableArray alloc]init];
    self.locationArray = [[NSMutableArray alloc] init];
    [self getDataFromWeb];
    
}


- (void)getDataFromWeb{
    [MBProgressHUD showMessage:nil toView:self.view];
    
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/cache/getProvince",REQUESTHEADER] andParameter:@{} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            [self.locationArray removeAllObjects];
            for (NSDictionary *dict in successResponse[@"data"]) {
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
    self.tableV = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight-48)];
    self.tableV.delegate = self;
    self.tableV.dataSource = self;
    self.tableV.rowHeight = 48;
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
    
//    if (_isProvince == YES) {
//        if (indexPath.row > 2) {
//            EndLocationViewController *next = [[EndLocationViewController alloc]init];
//            self.model = self.locationArray[indexPath.row - 3];
//            if ([self.model.status integerValue]) {
//                next.preLoc = self.model.name;
//                next.proId = self.model.id;
//                next.countryId = self.countryId;
//                next.preView = self.preView;
//                next.proName = self.model.name;
//                next.countryName = self.countryName;
//                [self.navigationController pushViewController:next animated:YES];
//            }
//            else{
//                if ([self.preView isEqualToString:@"search"]) {
//                    NSDictionary *dict = @{@"searchCountry":self.countryId,@"countryName":self.countryName,@"searchPro":self.model.id,@"proName":self.model.name};
//                    [[NSNotificationCenter defaultCenter] postNotificationName:@"searchPro" object:nil userInfo:dict];
//                    NSArray *array = [self.navigationController viewControllers];
//                    [self.navigationController popToViewController:array[1] animated:YES];
//                }
//                else if ([self.preView isEqualToString:@"live"]){
//                    NSDictionary *dict = @{@"searchCountry":self.countryId,@"countryName":self.countryName,@"searchPro":self.model.id,@"proName":self.model.name};
//                    [[NSNotificationCenter defaultCenter] postNotificationName:@"liveSelect" object:nil userInfo:dict];
//                    NSArray *array = [self.navigationController viewControllers];
//                    [self.navigationController popToViewController:array[1] animated:YES];
//                }
//                else if ([self.preView isEqualToString:@"addLive"]){
//                    NSDictionary *dict = @{@"searchCountry":self.countryId,@"countryName":self.countryName,@"searchPro":self.model.id,@"proName":self.model.name};
//                    [[NSNotificationCenter defaultCenter] postNotificationName:@"addLive" object:nil userInfo:dict];
//                    NSArray *array = [self.navigationController viewControllers];
//                    [self.navigationController popToViewController:array[2] animated:YES];
//                }
//                else{
//                    [MBProgressHUD showMessage:nil toView:self.view];
//                    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/update",REQUESTHEADER] andParameter:@{@"id":[NSString stringWithFormat:@"%@",[LYUserService sharedInstance].userID],@"country":self.countryId,@"province":self.model.id,@"city":self.model.id} success:^(id successResponse) {
//                        MLOG(@"结果:%@",successResponse);
//                        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//                        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
//                            NSDictionary *dict = @{@"countryName":self.countryName,@"proName":self.model.name};
//                            [[NSNotificationCenter defaultCenter] postNotificationName:@"changeLocation" object:nil userInfo:dict];
//                            NSArray *array = [self.navigationController viewControllers];
//                            [self.navigationController popToViewController:array[1] animated:YES];
//                            
//                        } else {
//                            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//                            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
//                        }
//                    } andFailure:^(id failureResponse) {
//                        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//                        [MBProgressHUD showError:@"服务器繁忙,请重试"];
//                    }];
//                }
//            }
//        }
//        
//    }
//    else{
//        //设置通知返回选中的城市给首页
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadLocation_XW" object:nil userInfo:@{@"city":_dataArr[indexPath.row - 3]}];
//        [self.navigationController popToRootViewControllerAnimated:YES];
//    }
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



#pragma mark   -------配置导航栏
- (void)setNav{
    self.title = @"选择省份";
    //导航栏title的颜色
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithHexString:@"#424242"],UITextAttributeTextColor, [UIFont fontWithName:@"PingFangSC-Medium" size:18],UITextAttributeFont, nil]];
    
    //导航栏返回按钮
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(16, 38, 28, 14)];
    [button setTitleColor:[UIColor colorWithHexString:@"#424242"] forState:UIControlStateNormal];
    [button setTitle:@"返回" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [button addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = back;
    
    
    
}


- (void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
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
