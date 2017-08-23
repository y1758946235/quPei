//
//  myDataVC.m
//  LvYue
//
//  Created by X@Han on 16/12/22.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "myDataVC.h"
#import "myDataCell.h"
//#import "AppointTableCell.h"
#import "LYHttpPoster.h"
#import "MBProgressHUD+NJ.h"
//#import "myDataModel.h"
#import "appointModel.h"
@interface myDataVC ()<UITableViewDelegate,UITableViewDataSource,CLLocationManagerDelegate,BMKGeoCodeSearchDelegate>{

    NSInteger currentPage2;
    NSInteger selectIndex;
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
@property (nonatomic, strong) UITableView *myTableView;
@property(nonatomic,retain)NSMutableArray *dateArr;

@end




@implementation myDataVC

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
//        [MBProgressHUD showError:@"用户拒绝定位授权,请在设置中开启"];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//    [MBProgressHUD showError:@"定位失败,请重试"];
}

#pragma mark 代理方法返回反地理编码结果
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error{
    
    currentPage2 = 1;
    [self getAppointData];
    
    if (result) {
        currentCity = [NSString stringWithFormat:@"%@", result.addressDetail.city];
        currentProvince = [NSString stringWithFormat:@"%@", result.addressDetail.province];
        currentDistrict = [NSString stringWithFormat:@"%@", result.addressDetail.district];
        NSLog(@"%@ - %@", result.address, result.addressDetail.streetNumber);
    }else{
        currentCity = @"定位失败";
    }
    
}
-(UITableView *)myTableView {
    if (!_myTableView) {
        _myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,0, SCREEN_WIDTH, SCREEN_HEIGHT-64) style:UITableViewStyleGrouped];
        [_myTableView registerClass:[myDataCell class] forCellReuseIdentifier:@"myDataCell"];
        

        
    }
    _myTableView.delegate = self;
    _myTableView.dataSource = self;
    _myTableView.backgroundColor = RGBA(246, 246, 247, 1);
    _myTableView.decelerationRate = 0.1f;
    return _myTableView;
}
-(void)getAppointData{
    
 
    
    NSDictionary *dic = @{@"userId":[CommonTool getUserID],@"pageNum":[NSString stringWithFormat:@"%ld",(long)currentPage2]};
    [ LYHttpPoster requestPersonAppointContentDataWithParameters:dic Block:^(NSArray *arr) {
        [self.dateArr removeAllObjects];
        [self.dateArr addObjectsFromArray:arr];
        
        
        [_myTableView reloadData];
       
        
        
    }];
    

    
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
    
    [self.view addSubview:self.myTableView];
    currentPage2 = 1;
    [self getAppointData];
    
    [self setNav];
    self.dateArr = [[NSMutableArray alloc]init];
    
    [self addRefresh];
}
- (void)addRefresh{
    currentPage2 = 1;
    // 1.下拉刷新(进入刷新状态就会调用self的headerRereshing)
    _myTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefreshing)];
    
    // 2.上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    _myTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRefreshing)];
    
}

#pragma mark   --下拉刷新
- (void)headerRefreshing{
    
    
    
    MJRefreshStateHeader *header = (MJRefreshStateHeader *) _myTableView.mj_header;
    [header setTitle:@"下拉可以刷新" forState:MJRefreshStateIdle];
    [header setTitle:@"松开马上刷新" forState:MJRefreshStatePulling];
    [header setTitle:@"刷新中" forState:MJRefreshStateRefreshing];
    currentPage2 = 1;
    [self  getAppointData];
    [_myTableView.mj_header endRefreshing];
}





#pragma mark   ---上拉刷新
- (void)footerRefreshing{
    
    
    currentPage2++;
  
    
    
    
    NSDictionary *dic = @{@"userId":[CommonTool getUserID],@"pageNum":[NSString stringWithFormat:@"%ld",(long)currentPage2]};
    [ LYHttpPoster requestPersonAppointContentDataWithParameters:dic Block:^(NSArray *arr) {
        [self.dateArr addObjectsFromArray:arr];
        
        
        [_myTableView reloadData];
        
        
        
        if (arr.count == 0) {
            [MBProgressHUD showSuccess:@"已经到底啦"];
            currentPage2 --;
        }
        

    }];
     
     
      [_myTableView.mj_footer endRefreshing];
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dateArr.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    appointModel *model  = self.dateArr[indexPath.row];
////    return 117+174;
//    return model.datePhotHeight +model.dataDescriptionHeight +154+31;
    appointModel *model = [self.dateArr objectAtIndex:indexPath.row];
    return model.chatBtnTopY-60;
}
//修改约会
- (void)change:(UIButton *)sender{
    
    
    
}
-(void)sure:(UIButton *)sender{
    appointModel *model = self.dateArr[sender.tag-1000];

    [self inviteMyAppoint:model.dateActivityId];
}

//删除约会
- (void)delete:(UIButton *)sender{
    appointModel *model = self.dateArr[sender.tag-1000];
  
  
    
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/date/deletePersonalDate",REQUESTHEADER] andParameter:@{@"dateActivityId":model.dateActivityId} success:^(id successResponse) {
       
       // NSLog(@"删除约会：%@",successResponse);
    if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
     
      [MBProgressHUD showSuccess:@"删除成功"];
        [self getAppointData];
       
     
  }
     
        
        
    } andFailure:^(id failureResponse) {

        [MBProgressHUD showError:@"服务器繁忙，请重试"];
        
    }];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    
    myDataCell* cell = [tableView dequeueReusableCellWithIdentifier:@"myDataCell" forIndexPath:indexPath];

    cell.selectionStyle = UITableViewCellAccessoryNone;
    
    cell.contentView.userInteractionEnabled = YES;
   
    
   appointModel*  dataModel = self.dateArr[indexPath.row];
     if (dataModel) {
        for (UIView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
            }
         
        [cell createCell:dataModel placeName:[NSString stringWithFormat:@"%@%@%@",currentProvince,currentCity,currentDistrict]];
         cell.deleteBtn.tag = 1000 +indexPath.row;
         if ([self.otherZhuYeVC isEqualToString:@"otherZhuYeVC"]) {
             [cell.deleteBtn setTitle:@"确认" forState:UIControlStateNormal];
             [cell.deleteBtn addTarget:self action:@selector(sure:) forControlEvents:UIControlEventTouchUpInside];
         }else{
              [cell.deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
             [cell.deleteBtn addTarget:self action:@selector(delete:) forControlEvents:UIControlEventTouchUpInside];
         }
         

        
    }
    return cell;
}


//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    
//   
//   
//   
//    
//}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    WS(weakSelf)
    if (1 == buttonIndex) {
        if ([self.otherZhuYeVC isEqualToString:@"otherZhuYeVC"]) {
         
        }
        
        
    }
}
-(void)inviteMyAppoint:(NSString*)dateId{
    NSDictionary *dic = @{@"userId":[CommonTool getUserID],@"otherUserId":self.otherUserId,@"flag":@"4",@"dateActivityId":dateId};
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/circle/doInvitePush",REQUESTHEADER]  andParameter:dic success:^(id successResponse) {
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            
            [MBProgressHUD showSuccess:@"邀请已发出"];
            [self.navigationController popViewControllerAnimated:YES];
            
            
        }
        
    } andFailure:^(id FailureResponseObject) {
        [MBProgressHUD showError:@"服务器繁忙，请重试"];
    }];
}

- (void)setNav{
    self.title = @"我的约会";
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
