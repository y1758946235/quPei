//
//  myInrestedVC.m
//  LvYue
//
//  Created by X@Han on 17/1/16.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "myInrestedVC.h"
#import "LYHttpPoster.h"
#import "MBProgressHUD+NJ.h"
#import "myIntrsdeCell.h"
#import "appointModel.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "otherZhuYeVC.h"
#import "MJRefresh.h"

@interface myInrestedVC ()<UITableViewDataSource,UITableViewDelegate,CLLocationManagerDelegate,BMKGeoCodeSearchDelegate>{
    
     UITableView *appointTable;
    NSInteger currentPage2;
    
    //保存当前选择的省份
    NSString *currentProvince;
    //保存当前选择的城市
    
    NSString *currentCity;
    //保存当前选择的区县
    NSString *currentDistrict;
}

@property (nonatomic,strong) NSString *latitude;
@property (nonatomic,strong) NSString *longitude;

@property (nonatomic,strong) BMKGeoCodeSearch *searcher;

//定位信息管理者
@property (nonatomic, strong) CLLocationManager *clManager;

//地理编码对象
@property (nonatomic, strong) CLGeocoder *geocoder;
@property(nonatomic,strong)NSMutableArray  *dateTypeArr;

@end

@implementation myInrestedVC


- (NSMutableArray *)dateTypeArr{
    if (!_dateTypeArr) {
        _dateTypeArr = [[NSMutableArray alloc]init];
    }
    return _dateTypeArr;
}
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

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation *currentLocation = [locations lastObject];
    
    self.latitude = [NSString stringWithFormat:@"%f",currentLocation.coordinate.latitude];
    self.longitude = [NSString stringWithFormat:@"%f",currentLocation.coordinate.longitude];
    
    //停止定位
    [_clManager stopUpdatingLocation];
    
    //初始化检索对象
    self.searcher =[[BMKGeoCodeSearch alloc] init];
    self.searcher.delegate = self;
    
    //发起反向地理编码检索
    CLLocationCoordinate2D pt = (CLLocationCoordinate2D){[self.latitude floatValue], [self.longitude floatValue]};
    BMKReverseGeoCodeOption *reverseGeoCodeSearchOption = [[BMKReverseGeoCodeOption alloc] init];
    reverseGeoCodeSearchOption.reverseGeoPoint = pt;
    [self.searcher reverseGeoCode:reverseGeoCodeSearchOption];
    BOOL flag = [self.searcher reverseGeoCode:reverseGeoCodeSearchOption];
    if(flag)
    {
        NSLog(@"反geo检索发送成功");
    }
    else
    {
        NSLog(@"反geo检索发送失败");
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        //用户允许授权,开启定位
        [_clManager startUpdatingLocation];
    } else {
//        [MBProgressHUD showError:@"用户拒绝授权,请在设置中开启"];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//    [MBProgressHUD showError:@"定位失败,请重试"];
}

#pragma mark 代理方法返回反地理编码结果
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error{
    
    [self getData];
    
    if (result) {
        currentCity = [NSString stringWithFormat:@"%@", result.addressDetail.city];
        currentProvince = [NSString stringWithFormat:@"%@", result.addressDetail.province];
        currentDistrict = [NSString stringWithFormat:@"%@", result.addressDetail.district];
        NSLog(@"%@ - %@", result.address, result.addressDetail.streetNumber);
    }else{
        currentCity = @"定位失败";
    }
   
}



- (void)viewDidLoad {
    
    [super viewDidLoad];
    currentProvince = @"";
    currentCity = @"";
    currentDistrict = @"";
    self.clManager.delegate = self;
    
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 8.0) {
        //前台和后台都允许请求用户是否允许开启定位 IOS8.0以上版本需要设置环境参数
        [_clManager requestAlwaysAuthorization];
        [_clManager startUpdatingLocation];
    }
    else {
        //如果是IOS8.0以下的版本，则可直接开启定位
        [_clManager startUpdatingLocation];
    }
    currentPage2 = 1;
    [self getData];
    [self setNav];
   
    [self appointContent];
    
  [self addRefresh];
}

- (void)addRefresh{
    currentPage2 = 1;
    // 1.下拉刷新(进入刷新状态就会调用self的headerRereshing)
    appointTable.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefreshing)];
    
    // 2.上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    appointTable.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRefreshing)];
    
}

#pragma mark   --下拉刷新
- (void)headerRefreshing{
    
    
    currentPage2 = 1;
    MJRefreshStateHeader *header = (MJRefreshStateHeader *) appointTable.mj_header;
    [header setTitle:@"下拉可以刷新" forState:MJRefreshStateIdle];
    [header setTitle:@"松开马上刷新" forState:MJRefreshStatePulling];
    [header setTitle:@"刷新中" forState:MJRefreshStateRefreshing];
  
    [self  getData];
    [appointTable.mj_header endRefreshing];
}
#pragma mark   ---上拉刷新
- (void)footerRefreshing{
    
    //[MBProgressHUD showMessage:@"加载中" toView:self];
    
    //    NSInteger page = 1;
    currentPage2++;

    
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/date/getInterestDate",REQUESTHEADER] andParameter:@{@"userId":self.userId,@"pageNum":[NSString stringWithFormat:@"%ld",(long)currentPage2]}  success:^(id successResponse) {
        NSLog(@"我感兴趣的约会:%@",successResponse);
        
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            NSArray *listArr = successResponse[@"data"][@"list"];
            for (NSDictionary *dic in listArr) {
                appointModel *model = [[appointModel alloc]initWithModelDic:dic];
                [self.dateTypeArr addObject:model];
                [appointTable reloadData];
            
            }
            if (listArr.count == 0) {
                currentPage2 --;
                [MBProgressHUD showSuccess:@"已经到底啦"];
            }
        }
        
        
    } andFailure:^(id failureResponse) {
        
        
    }];

    [appointTable.mj_footer endRefreshing];
}


- (void)getData{
    currentPage2 = 1;
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/date/getInterestDate",REQUESTHEADER] andParameter:@{@"userId":self.userId,@"pageNum":[NSString stringWithFormat:@"%ld",(long)currentPage2]}  success:^(id successResponse) {
        NSLog(@"我感兴趣的约会:%@",successResponse);
        
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            [self.dateTypeArr removeAllObjects];
            NSArray *listArr = successResponse[@"data"][@"list"];
            for (NSDictionary *dic in listArr) {
                appointModel *model = [[appointModel alloc]initWithModelDic:dic];
                [self.dateTypeArr addObject:model];
                [appointTable reloadData];
            }
        }
        
        
            } andFailure:^(id failureResponse) {
                
                
                    }];
    
}

- (void)appointContent{
    
    appointTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-56) style:UITableViewStylePlain];
    appointTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    appointTable.rowHeight = 607;
    appointTable.delegate = self;
    appointTable.dataSource = self;
     [appointTable registerClass:[AppointTableCell class] forCellReuseIdentifier:@"AppointTableCell"];
   [self.view addSubview:appointTable];
    
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dateTypeArr.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
//    myIntrsdeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
//    if (!cell) {
//        cell = [[myIntrsdeCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
//    }
//    
//    
//    
//    
//    myIntrsedModel *aModel = self.dateTypeArr[indexPath.row];
//    if (aModel) {
//        
//        
//        for (UIView *view in cell.contentView.subviews) {
//            [view removeFromSuperview];
//            
//        }
//        
//        [cell createCell:aModel];
//        [cell.otherHomeBtn addTarget:self action:@selector(goOtherHome:) forControlEvents:UIControlEventTouchUpInside];
//        //对约会感兴趣
//        [cell.intreBtn addTarget:self action:@selector(instred:) forControlEvents:UIControlEventTouchUpInside];
//        //聊天
//        [cell.chatBtn addTarget:self action:@selector(chat:) forControlEvents:UIControlEventTouchUpInside];
//        
//    }
    AppointTableCell* cell = [tableView dequeueReusableCellWithIdentifier:@"AppointTableCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
   
    cell.preservesSuperviewLayoutMargins = NO;
    cell.separatorInset = UIEdgeInsetsZero;
    cell.layoutMargins = UIEdgeInsetsZero;
    
   
    if (self.dateTypeArr && self.dateTypeArr.count > 0) {
        
         appointModel *aModel = self.dateTypeArr[indexPath.row];
        for (UIView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
            
        }
        
        [cell createCell:aModel placeName:[NSString stringWithFormat:@"%@%@%@",currentProvince,currentCity,currentDistrict]];
        cell.instLabel.text = @"已感兴趣";
        cell.intreBtn.userInteractionEnabled = NO;
        
        cell.otherHomeBtn.tag = 1000+indexPath.row;
        [cell.otherHomeBtn addTarget:self action:@selector(goOtherHome:) forControlEvents:UIControlEventTouchUpInside];
        //聊天
        cell.chatBtn.tag = 1000+indexPath.row;
        [cell.chatBtn addTarget:self action:@selector(chat:) forControlEvents:UIControlEventTouchUpInside];
    }
    return cell;
}
//设置cell的高度
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    appointModel *model = [self.dateTypeArr objectAtIndex:indexPath.row];
    return model.cellHeight;
}

#pragma mark  ---对约会感兴趣
- (void)instred:(UIButton *)sender{
    
    //  NSString *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userId"];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/date/addInterestDate",REQUESTHEADER] andParameter:@{@"userId":@"1000006",@"dateActivityId":@"1",@"otherUserId":@"1000001"} success:^(id successResponse) {
        
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            [MBProgressHUD showSuccess:@"感兴趣成功"];
        }
        
    } andFailure:^(id failureResponse) {
        
    }];
    
    
    
}

#pragma mark  --聊天
- (void)chat:(UIButton *)sender{
    
    appointModel *aModel = self.dateTypeArr[sender.tag-1000];
    if ([[NSString stringWithFormat:@"%@",aModel.otherId]  isEqualToString:[CommonTool getUserID]]) {
        [MBProgressHUD showError:@"不能跟自己聊天哦～"];
        
        return;
    }else{
        ChatViewController *chatController = [[ChatViewController alloc] initWithChatter:[NSString stringWithFormat:@"qp%@",aModel.otherId]  isGroup:NO] ;
        chatController.isContactsList2Chat = NO;
        chatController.title = aModel.nickName;
        [self.navigationController pushViewController:chatController animated:YES];
    }

    
}
#pragma mark  --进入别人主页
- (void)goOtherHome:(UIButton *)sender{
    appointModel *model = self.dateTypeArr[sender.tag-1000];
    otherZhuYeVC *other = [[otherZhuYeVC alloc]init];
    other.userNickName = model.nickName;
    other.userId = [NSString stringWithFormat:@"%@",model.otherId];    //别人ID
    [self.navigationController pushViewController:other animated:YES];
//        [[NSNotificationCenter defaultCenter]postNotificationName:@"push" object:nil userInfo:@{@"push":@"otherZhuYeVC",@"userNickName":model.nickName,@"userId":[NSString stringWithFormat:@"%@",model.otherId]}];
    
}





- (void)setNav{
    if ([self.gotoVCIdentifier isEqualToString:@"LYMeViewController"]) {
        self.title = @"我感兴趣的约会";
    }else{
        if ([CommonTool dx_isNullOrNilWithObject:self.userNike]) {
            self.userNike = @"";
        }
        self.title = [NSString stringWithFormat:@"%@感兴趣的约会",self.userNike] ;
    }
    
    //导航栏title的颜色
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithHexString:@"#424242"],UITextAttributeTextColor, [UIFont fontWithName:@"PingFangSC-Medium" size:18],UITextAttributeFont, nil]];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:@"#ffffff"];
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
   
}


@end
