//
//  SearchViewController.m
//  筛选
//
//  Created by Xia Wei on 15/10/6.
//  Copyright © 2015年 Xia Wei. All rights reserved.
//

#import "SearchNearbyViewController.h"

#import "LYUserService.h"

#import "UIView+KFFrame.h"
#import "NewLoginViewController.h"
#import "LocalCountryViewController.h"
#import "selectResultVC.h"   //筛选结果
#import "pchFile.pch"
@interface SearchNearbyViewController ()<UIPickerViewDelegate,UIPickerViewDataSource,UITableViewDelegate,UITableViewDataSource>{
  
   
   
    UITableView *selectTable; //筛选下的表
    UIView *view;  //性别View
    NSArray *cellLeftArr;
    
    
    UIButton *lastSexBtn;
    UIButton *lastOrderBtn;
    
    UILabel * placeLabel;
    
    NSMutableArray *btnArr;
    
    NSString * provinceId;
    NSString * cityId;
    NSString * distriId;
    
    
    //保存当前选择的省份
    NSString *_currentProvince;
    //保存当前选择的城市
    
    NSString *_currentCity;
    //保存当前选择的区县
    NSString *_currentDistrict;
   
   
}


 @property (nonatomic,strong) NSArray *plaIdArr;

@end

@implementation SearchNearbyViewController

- (void)viewWillAppear:(BOOL)animated{
    if ([self.arrayType isEqualToString:@"3"] ) {
        self.placeId = @"";
        placeLabel.text = @"不限";
       // 快速显示一个提示信息
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.detailsLabelText = @"选择’离我最近‘就不能选择所在城市了哦～";
        hud.mode = MBProgressHUDModeCustomView;
        [hud hide:YES afterDelay:2];
        // 隐藏时候从父控件中移除
        hud.removeFromSuperViewOnHide = YES;
        
    }
//    else{
//        placeLabel.text = self.placee;
//        
//    
//        
//    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    btnArr = [[NSMutableArray alloc]init];
//    sexArr = @[@"不限",@"女生",@"男生"];
    cellLeftArr = @[@"排列",@"性别",@"",@"",@""];
    self.userSex = @"2";
    self.arrayType = @"1";
//    //注册改变地点的通知
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeLocation:) name:@"changeLocation" object:nil];
    
    [self setNav];
    
    [self selectContent];
    
    
    //发送通知  定位到当前位置
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(currentplace:) name:@"currentSearchNearbyViewControllerplace" object:nil];
    
}


//push通知
- (void)currentplace:(NSNotification *)noti {
    placeLabel.text = self.placee;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}




#pragma mark  --------导航栏配置------
- (void)setNav{
    
    self.title = @"筛选";
  
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#424242"],NSFontAttributeName:[UIFont fontWithName:@"PingFangSC-Medium" size:18]};
    
    //定位按钮
    UIButton *localeBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    localeBtn.frame = CGRectMake(0, 38, 40,40);
    [localeBtn setTitle:@"返回" forState:UIControlStateNormal];
    localeBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [localeBtn setTitleColor:[UIColor colorWithHexString:@"#424242"] forState:UIControlStateNormal];
    [localeBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:localeBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    
    //右上角筛选图片  按钮
    UIButton *selectBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    selectBtn.backgroundColor = [UIColor clearColor];
    [selectBtn setTitle:@"确定" forState:UIControlStateNormal];
    selectBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [selectBtn setTitleColor:[UIColor colorWithHexString:@"#ff5252"] forState:UIControlStateNormal];
    [selectBtn addTarget:self action:@selector(sure:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:selectBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    
}

- (void)sure:(UIButton *)sender{
    
//    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/date/getDate",REQUESTHEADER] andParameter:@{@"userId":@"1000006",@"arrayType":@"1",@"userSex":@"0",@"provinceId":@"",@"cityId":@"",@"districtId":@"",@"dateLongitude":@"",@"dateLatitude":@""} success:^(id successResponse) {
//        
//        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
//            //筛选成功
//        }
//        
//        
//    } andFailure:^(id failureResponse) {
//       
//        
//    }];
    
//    selectResultVC *selet = [[selectResultVC alloc]init];
//    selet.arrayType = self.arrayType;
//    selet.userSex = self.userSex;
//    selet.placeId = self.placeId;
//    [self.navigationController pushViewController:selet animated:YES];
    if (self.shaiXuanTextBlock != nil) {
        //马甲用户过多，真实用户少，这里不做筛选
        self.placeId = @"";
        if ([[NSString stringWithFormat:@"%@",self.arrayType] isEqualToString:@"3"]) {
            self.arrayType = @"1";
        }
        self.shaiXuanTextBlock(self.placeId,self.arrayType,self.userSex);
    }
   [self.navigationController popViewControllerAnimated:YES];
}
- (void)shaiXuanText:(ShaiXuanTextBlock)block {
    self.shaiXuanTextBlock = block;
}
- (void)back:(UIButton *)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

#pragma mark   -------------筛选下面的内容-----
- (void)selectContent{

    
    selectTable = [[UITableView alloc]initWithFrame:CGRectMake(0,0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStyleGrouped];
   
    selectTable.dataSource = self;
    selectTable.delegate = self;
    selectTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    selectTable.rowHeight = 48;
    [self.view addSubview:selectTable];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSArray *firstRowArr = @[@"最新发布",@"近期约会",@"离我最近"];
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    CGFloat width = (SCREEN_WIDTH-16-24-84)/3;
    if (indexPath.row ==0) {
        for (NSInteger i=0; i<3; i++) {
        
            //排列
            
            
        UIButton *otherBtn = [[UIButton alloc]initWithFrame:CGRectMake(84+(8+width)*i, 12, width, 32)];
        otherBtn.tag = 2000+i;
        otherBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
        otherBtn.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];
            otherBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [otherBtn setTitleColor:[UIColor colorWithHexString:@"#757575"] forState:UIControlStateNormal];
        [otherBtn setTitleColor:[UIColor colorWithHexString:@"#ff5252"] forState:UIControlStateSelected];
        [otherBtn addTarget:self action:@selector(order:) forControlEvents:UIControlEventTouchUpInside];
        [otherBtn setTitle:firstRowArr[i] forState:UIControlStateNormal];
        [cell.contentView addSubview:otherBtn];
            [btnArr addObject:otherBtn];
      }
        
    }
    
    NSArray *sencondArr = @[@"男生",@"女生",@"不限",];
    if (indexPath.row ==1) {
        for (NSInteger i=0; i<3; i++) {
            
            //性别
            UIButton *sexBtn = [[UIButton alloc]initWithFrame:CGRectMake(84+(8+width)*i, 12, width, 32)];
            sexBtn.tag = 1000+i;
            sexBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
            sexBtn.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];
            sexBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
            [sexBtn setTitleColor:[UIColor colorWithHexString:@"#757575"] forState:UIControlStateNormal];
            [sexBtn setTitleColor:[UIColor colorWithHexString:@"#ff5252"] forState:UIControlStateSelected];
            [sexBtn addTarget:self action:@selector(sex:) forControlEvents:UIControlEventTouchUpInside];
            [sexBtn setTitle:sencondArr[i] forState:UIControlStateNormal];
            [cell.contentView addSubview:sexBtn];
             [btnArr addObject:sexBtn];
        }
        
    }
    
    //筛选未知的功能先去掉
//    if (indexPath.row ==2) {
//        //地点
//        
//        placeLabel = [[UILabel alloc]init];
//        placeLabel.frame = CGRectMake(SCREEN_WIDTH - 200, 0, 170, 48);
//        placeLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
//       // placeLabel.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];
//        placeLabel.textAlignment = NSTextAlignmentRight;
//        placeLabel.textColor = [UIColor colorWithHexString:@"#757575"];
//        [cell.contentView addSubview:placeLabel];
//        if (self.placee.length == 0 ) {
//            placeLabel.text = @"不限";
//        }
//    }
    
    if (indexPath.row == 4) {
        UIButton *reSetBtn = [[UIButton alloc]init];
        reSetBtn.frame = CGRectMake(SCREEN_WIDTH-width-30, 12, width, 32);
       // reSetBtn.titleLabel.textAlignment = NSTextAlignmentRight;
        reSetBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:16];
//        reSetBtn.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];
//        UIColor *color = [UIColor colorWithHexString:@"#ff5252"];
//        reSetBtn.backgroundColor = [color colorWithAlphaComponent:0.1];
        reSetBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
//        [reSetBtn setTitleColor:[UIColor colorWithHexString:@"#757575"] forState:UIControlStateNormal];
        [reSetBtn setTitleColor:[UIColor colorWithHexString:@"#ff5252"] forState:UIControlStateNormal];
        [reSetBtn setTitle:@"重置" forState:UIControlStateNormal];
        [reSetBtn addTarget:self action:@selector(resetClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:reSetBtn];
    }
    
     cell.textLabel.text = cellLeftArr[indexPath.row];
     cell.textLabel.textColor = [UIColor colorWithHexString:@"#424242"];
     cell.textLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];


     return cell;
    
}
-(void)resetClick:(UIButton*)sender{
  
    self.placeId = @"";
    self.userSex = @"2";
    self.arrayType = @"1";
    placeLabel.text = @"不限";

    for (UIButton *button in btnArr) {
        button.selected = NO;

        button.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];
        
        lastOrderBtn.selected = NO;
        lastOrderBtn.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];
        lastOrderBtn = button;
        
        lastSexBtn.selected = NO;
        lastSexBtn.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];
        lastSexBtn = button;
    }
    
    
    
    
}

#pragma mark --排列
- (void)order:(UIButton *)sender{
     NSLog(@"arrayType----%@",[NSString stringWithFormat:@"%ld",sender.tag-2000+1]);
  
   
          self.arrayType =  [NSString stringWithFormat:@"%d",sender.tag-2000+1];
  
    
    if ([self.arrayType isEqualToString:@"3"] ) {
        self.placeId = @"";
        placeLabel.text = @"不限";
    }
    sender.selected = YES;
    UIColor *color = [UIColor colorWithHexString:@"#ff5252"];
   sender.backgroundColor = [color colorWithAlphaComponent:0.1];
    lastOrderBtn.selected = NO;
    
    lastOrderBtn.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];
    lastOrderBtn = sender;
    
   
    
}




#pragma mark  ---性别
- (void)sex:(UIButton *)sender{
    NSLog(@"sex----%@",[NSString stringWithFormat:@"%ld",sender.tag-1000]);
    self.userSex = [NSString stringWithFormat:@"%ld",sender.tag-1000];
    if (lastSexBtn == sender) {
        return;
    }
    
    sender.selected = YES;
    UIColor *color = [UIColor colorWithHexString:@"#ff5252"];
    sender.backgroundColor = [color colorWithAlphaComponent:0.1];
    lastSexBtn.selected = NO;
    lastSexBtn.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];
    lastSexBtn = sender;
    
}





#pragma mark   -----cell的点击事件  所在城市
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //定位
//    if (indexPath.row==2) {
//        LocalCountryViewController *local = [[LocalCountryViewController alloc]init];
//        [local currnentLocationBlock:^(NSString *currentProvince, NSString *currentCity, NSString *currentDistrict) {
//            placeLabel.text = [NSString stringWithFormat:@"%@%@%@",currentProvince,currentCity,currentDistrict];
//            _currentProvince = currentProvince;
//            _currentCity = currentCity;
//            _currentDistrict = currentDistrict;
//         
//                
//                NSString *a = [currentProvince substringFromIndex:currentProvince.length-1];
//                
//                if (currentProvince) {
//                    if ([a isEqualToString:@"省"]) {
//                        NSString *str = [currentProvince substringWithRange:NSMakeRange(0, currentProvince.length-1)];
//                        [self getProviId:str];
//                    }else{
//                        [self getProviId:currentProvince];}
//                }
//                
//            }];
//        
//        [self.navigationController pushViewController:local animated:YES];
//    }
    
    
}

-(void)getProviId:(NSString *)proStr{
     WS(weakSelf)
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/cache/getProvinceByName",REQUESTHEADER] andParameter:@{@"provinceName":proStr} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        [MBProgressHUD hideHUD];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            provinceId= [NSString stringWithFormat:@"%@",successResponse[@"data"][@"provinceId"]];
            
            NSString *b = [_currentCity substringFromIndex:_currentCity.length-1];
            if (_currentCity) {
                if ([b isEqualToString:@"市"]) {
                    NSString *str = [_currentCity substringWithRange:NSMakeRange(0, _currentCity.length-1)];
                    [weakSelf getCityId:str];
                }else{
                    
                    [weakSelf getCityId:_currentCity];
                }
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

-(void)getCityId:(NSString *)cityByName{
      WS(weakSelf)
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/cache/getCityByName",REQUESTHEADER] andParameter:@{@"cityName":cityByName} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        [MBProgressHUD hideHUD];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            cityId= [NSString stringWithFormat:@"%@",successResponse[@"data"][@"cityId"]];
            
            
            if (_currentDistrict) {
                [weakSelf getDisId:_currentDistrict];
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
-(void)getDisId:(NSString *)districtName{
    
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/cache/getDistrictByName",REQUESTHEADER] andParameter:@{@"districtName":districtName} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        [MBProgressHUD hideHUD];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            distriId= [NSString stringWithFormat:@"%@",successResponse[@"data"][@"districtId"]];
            
            self.placeId =[NSString stringWithFormat:@"%@,%@,%@",provinceId,cityId,distriId] ;
        } else {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
}





@end
