//
//  LocationViewController.m
//  豆客项目
//
//  Created by Xia Wei on 15/10/9.
//  Copyright © 2015年 Xia Wei. All rights reserved.
//


//城市
#import "XWLocationViewController.h"
#import "CityModel.h"
#import "MBProgressHUD+NJ.h"
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "EndLocationViewController.h"
#import "changeInfoVC.h"
#import "pchFile.pch"
@interface XWLocationViewController ()<UITableViewDataSource,UITableViewDelegate>{
    changeInfoVC *revise;
    SearchNearbyViewController *searVC;
    perfactInfoVC *perinfoVC;
}

@property(nonatomic,strong)NSMutableArray *dataArr;
@property (nonatomic,strong) NSMutableArray *locationArray;
@property (nonatomic,strong) CityModel *model;
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
    
    self.title = @"选择城市";
    [self setNav];
    [self getDataFromWeb];
}


- (void)setNav{
 
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

- (void)getDataFromWeb{
    [MBProgressHUD showMessage:nil toView:self.view];
    __block XWLocationViewController *weakSelf = self;
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/cache/getCity",REQUESTHEADER] andParameter:@{} success:^(id successResponse) {

        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
              [_locationArray removeAllObjects];
            for (NSDictionary *dic in successResponse[@"data"]) {
                
                CityModel *model = [[CityModel alloc]initWithDict:dic];
              
                if ([model.parent_id integerValue]==[_countryId integerValue]) {
                   [_locationArray addObject:model];
                }

                
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableV reloadData];
            });
            
        }
        }andFailure:^(id failureResponse) {
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
}

//创建tableView
- (void) tableViewCreated{
    self.tableV = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight-48)];
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
        return 20;
    }
    return 48;
}

//设置cell的数目
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.locationArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
   
      
    if ([self.model.parent_id integerValue] == 20 || [self.model.parent_id integerValue] == 3 || [self.model.parent_id integerValue] == 793 ||[self.model.parent_id integerValue] == 2242||[self.model.parent_id integerValue] == 3250||[self.model.parent_id integerValue] == 3269||[self.model.parent_id integerValue] == 3226) {
        if (indexPath.row>2) {
        self.model = self.locationArray[indexPath.row-3];
        for (UIViewController *controller in self.navigationController.viewControllers) {
            if ([controller isKindOfClass:[changeInfoVC class]]) {
                revise =(changeInfoVC *)controller;
                revise.placee = [NSString stringWithFormat:@"%@%@",self.preLoc,self.model.name];
                revise.placeId = [NSString stringWithFormat:@"%@,%@",self.countryId,self.model.level];
                [self postRequest:@"changeInfoVC"];
                //[self.navigationController popToViewController:revise animated:YES];
            }
            if ([controller isKindOfClass:[SearchNearbyViewController class]]) {
                searVC =(SearchNearbyViewController *)controller;
                searVC.placee = [NSString stringWithFormat:@"%@%@",self.preLoc,self.model.name];
                searVC.placeId = [NSString stringWithFormat:@"%@,%@",self.countryId,self.model.level];
                [[NSNotificationCenter defaultCenter]postNotificationName:@"currentSearchNearbyViewControllerplace" object:nil userInfo:nil];
                [self.navigationController popToViewController:searVC animated:YES];
            }
            if ([controller isKindOfClass:[perfactInfoVC class]]) {
                perinfoVC =(perfactInfoVC *)controller;
                perinfoVC.placee = [NSString stringWithFormat:@"%@%@",self.preLoc,self.model.name];
                perinfoVC.placeId = [NSString stringWithFormat:@"%@,%@",self.countryId,self.model.level];
           [[NSNotificationCenter defaultCenter]postNotificationName:@"currentPerfactInfoVCplace" object:nil userInfo:nil];
                [self.navigationController popToViewController:perinfoVC animated:YES];
            }
            
            }
        }
       
    }else{
        if (indexPath.row>2) {
            
      
        EndLocationViewController *next = [[EndLocationViewController alloc]init];
        self.model = self.locationArray[indexPath.row - 3];
        
        next.preLoc = self.model.name;
        
        next.countryId = self.model.level;
        next.placeId = [NSString stringWithFormat:@"%@",self.countryId];
        next.place = [NSString stringWithFormat:@"%@ %@",self.preLoc,self.model.name];
        [self.navigationController pushViewController:next animated:YES];
            
        }
    }
    
}

#pragma mark  ----发送修改地址的请求
- (void)postRequest:(NSString *)VCName{
    NSString *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userId"];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/updatePersonalInfo",REQUESTHEADER] andParameter:@{@"userId":userId,@"userProvince":self.countryId,@"userCity":self.model.level,@"userDistrict":@"0"} success:^(id successResponse) {
       // MLOG(@"结果:%@",successResponse);
        [MBProgressHUD hideHUD];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            
            [MBProgressHUD showSuccess:@"地址修改成功"];
            if ([VCName isEqualToString:@"changeInfoVC"]) {
                [self performSelector:@selector(popToVRevise) withObject:self afterDelay:1];

            }
//            else  if ([VCName isEqualToString:@"SearchNearbyViewController"]){
//                 [self performSelector:@selector(popTosSearVC) withObject:self afterDelay:1];
//            }else{
//                 [self performSelector:@selector(popToPerinfoVC) withObject:self afterDelay:1];
//            }
                   } else {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
    
    
    
}

- (void)popToVRevise{
    [self.navigationController popToViewController:revise animated:YES];
}

- (void)popTosSearVC{
    [self.navigationController popToViewController:searVC animated:YES];
}
- (void)popToPerinfoVC{
    [self.navigationController popToViewController:perinfoVC animated:YES];
}
//创建每个cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cellIdentifier";
    //分割用的cell
    if (indexPath.row == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        [cell setBackgroundColor:UIColorWithRGBA(234, 234, 234, 1)];
        cell.textLabel.text = @"当前省/市";
        cell.textLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        cell.textLabel.textColor = [UIColor colorWithHexString:@"#424242"];
       
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.userInteractionEnabled = NO;
        return cell;
    }
    //已选中的地区
    else if(indexPath.row == 1) {
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        cell.textLabel.text = self.preLoc;
        cell.textLabel.textColor = [UIColor colorWithHexString:@"#757575"];
        cell.textLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
       
        //设置已选地区label
        UILabel *selectedLabel = [[UILabel alloc]initWithFrame:CGRectMake(kMainScreenWidth - 100, 0, 80, 48)];
        selectedLabel.textColor = UIColorWithRGBA(158, 158, 158, 1);
        selectedLabel.textAlignment = NSTextAlignmentRight;
        selectedLabel.text = @"已选地区";
        
        selectedLabel.font = [UIFont systemFontOfSize:15];
        [cell addSubview:selectedLabel];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if (indexPath.row == 2){
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        [cell setBackgroundColor:UIColorWithRGBA(234, 234, 234, 1)];
        cell.textLabel.text = @"所有地区";
        cell.textLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
        cell.textLabel.textColor = [UIColor colorWithHexString:@"#424242"];
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
            cell.textLabel.textColor = [UIColor colorWithHexString:@"#757575"];
            cell.textLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
        }
        
        return cell;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
