//
//  AllOrderViewController.m
//  豆客项目
//
//  Created by Xia Wei on 15/10/12.
//  Copyright © 2015年 Xia Wei. All rights reserved.
//

#import "AllOrderViewController.h"
#import "AllOrderChangeButtonView.h"
#import "AllOrderScrollView.h"
#import "MBProgressHUD+NJ.h"
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "OrderModel.h"
#import "MJRefresh.h"

@interface AllOrderViewController ()<UIScrollViewDelegate>{
    int currentPage;//当前页面号0，1，2
}

@property(nonatomic,strong)AllOrderChangeButtonView *changeBtnView;
@property(nonatomic,strong)UIView *scrollLine;
@property(nonatomic,strong)UILabel *titleView;
@property(nonatomic,strong)NSArray *btnArr;
@property (nonatomic,strong) AllOrderScrollView *scrollV;

@property (nonatomic,strong) OrderModel *orderModel;
@property (nonatomic,strong) NSMutableArray *allOrderArray;
@property (nonatomic,strong) NSMutableArray *touristOrderArray;
@property (nonatomic,strong) NSMutableArray *guideOrderArray;

@end

@implementation AllOrderViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //加载数据
    [self getDataFromWeb];
    [self getSendOrderData];
    [self getReceiveData];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.allOrderArray = [[NSMutableArray alloc]init];
    self.touristOrderArray = [[NSMutableArray alloc]init];
    self.guideOrderArray = [[NSMutableArray alloc] init];
    [self.view setBackgroundColor:UIColorWithRGBA(234, 234, 234, 1)];
    [self changeBtnViewCreated];
    [self scrollViewCreated];
    [self setNaviegationBar];
    [self.navigationController setNavigationBarHidden:NO];
    self.tabBarController.tabBar.hidden = YES;;
    currentPage = 0;
    
    //给tableView加下拉刷新事件
    self.scrollV.allTableV.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(allTableViewRefresh)];
    self.scrollV.sendTableV.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(sendTableViewRefresh)];
    self.scrollV.receiveTableV.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(receiveTableViewRefresh)];
   // [MBProgressHUD hideHUD];
}

//重新加载全部订单界面数据
- (void)allTableViewRefresh{
    [self getDataFromWeb];
}

//重新加载发送订单界面的数据
- (void)sendTableViewRefresh{
    [self getSendOrderData];
}

//重新加载接受订单界面的数据
- (void)receiveTableViewRefresh{
    [self getReceiveData];
}

- (void)setNaviegationBar{
    //设置标题，把标题设置成全局是为了点击按钮时方便标题的改变
    _titleView = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 50)];
    _titleView.text = @"全部订单";
    _titleView.textColor = [UIColor whiteColor];
    _titleView.textAlignment = NSTextAlignmentCenter;
    _titleView.font = [UIFont systemFontOfSize:16];
    self.navigationItem.titleView = _titleView;
    
    //---------------添加右边的item------------
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [rightBtn setFrame:CGRectMake(0, 0, 30, 17)];
    [rightBtn addTarget:self action:@selector(refreshCurrentPage) forControlEvents:UIControlEventTouchUpInside];
    
    //添加转圈的图片
    UIImageView *andMoreImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,30, rightBtn.frame.size.height)];
    andMoreImg.image = [UIImage imageNamed:@"刷新"];
    andMoreImg.contentMode = UIViewContentModeScaleAspectFit;
    [rightBtn addSubview:andMoreImg];
    //[rightBtn addTarget:self action:@selector(moreFunctionShow) forControlEvents: UIControlEventTouchUpInside];
    
    //添加一个button调节rightBtn的位置
    UIBarButtonItem *fixBar = [[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixBar.width = -3;
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:fixBar, right, nil];
}

//点击右上角按钮刷新当前页面
- (void)refreshCurrentPage{
    if (currentPage == 0) {
        [self.scrollV.allTableV.mj_header beginRefreshing];
    }
    else if(currentPage == 1){
        [self.scrollV.sendTableV.mj_header beginRefreshing];
    }
    else{
        [self.scrollV.receiveTableV.mj_header beginRefreshing];
    }
}

- (void)backToFront{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)changeBtnViewCreated{
    //创建三个点击切换button
    self.changeBtnView = [[AllOrderChangeButtonView alloc] initWithFrame:CGRectMake(0,65, kMainScreenWidth, 44)];
    
    self.scrollLine = self.changeBtnView.scrollLine;
    
    //给button添加点击事件
    [self.changeBtnView.firstBtn addTarget:self action:@selector(changeView:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.changeBtnView.secondBtn addTarget:self action:@selector(changeView:) forControlEvents:UIControlEventTouchUpInside];
    [self.changeBtnView.thirdBtn addTarget:self action:@selector(changeView:) forControlEvents:UIControlEventTouchUpInside];
    
    //用数组管理三个button
    _btnArr = @[self.changeBtnView.firstBtn,self.changeBtnView.secondBtn,self.changeBtnView.thirdBtn];
    
    [self.view addSubview:self.changeBtnView];
}

//点击按钮下面的红线滑动事件
- (void)changeView:(UIButton *)btn{
    
    [UIView animateWithDuration:0.5 animations:^{
        [self.changeBtnView.scrollLine setFrame:
                    CGRectMake((btn.tag - 100) * kMainScreenWidth / 3.0,(44 - 2), kMainScreenWidth / 3.0, 2)];
    }];
    NSArray *subViews = [self.view subviews];
    AllOrderScrollView *scrollV;
    
    for (UIView *subView in subViews) {
        if ([subView isKindOfClass:[AllOrderScrollView class]]){
            scrollV = (AllOrderScrollView *)subView;
        }
    }
    CGPoint point = CGPointMake((btn.tag - 100) * kMainScreenWidth, 0);
    [UIView animateWithDuration:0.5 animations:^{
        scrollV.contentOffset =  point;
    }];
    
    //Buttion的颜色也要变
    [btn setTintColor:UIColorWithRGBA(29, 189, 159, 1)];
    
    for (UIButton *tempBtn in _btnArr) {
        if (tempBtn.tag != btn.tag) {
            [tempBtn setTintColor:UIColorWithRGBA(101, 101, 101, 1)];
        }
    }

   if (btn.tag == 100) {
        _titleView.text = @"全部订单";
       currentPage = 0;
    }
    else if(btn.tag == 101){
        _titleView.text = @"发送订单";
        currentPage = 1;
    }
    else{
        _titleView.text = @"接收订单";
        currentPage = 2;
    }
//    [self getDataFromWeb];
//    [self getSendOrderData];
//    [self getReceiveData];
    
}

#pragma mark 网络请求
- (void)getDataFromWeb{
  //  [MBProgressHUD showMessage:nil];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/order/orderList",REQUESTHEADER] andParameter:@{@"userId":[LYUserService sharedInstance].userID,@"roleType":@"2",@"pageNum":@"1"} success:^(id successResponse) {
        MLOG(@"全部订单结果:%@",successResponse);
        [MBProgressHUD hideHUD];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            [self.allOrderArray removeAllObjects];
            NSArray *array = successResponse[@"data"][@"orderList"];
            for (NSDictionary *dict in array) {
                self.orderModel = [[OrderModel alloc] initWithDict:dict];
                [self.allOrderArray addObject:self.orderModel];
            }
            self.scrollV.allOrderArray = self.allOrderArray;
            [self.scrollV.allTableV reloadData];
            [self.scrollV.allTableV.mj_header endRefreshing];

        } else {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
}

//在scrollView中创建下面的三个tableView
- (void)scrollViewCreated{
    self.scrollV = [[AllOrderScrollView alloc]initWithFrame:CGRectMake(0, 109, kMainScreenWidth, kMainScreenHeight - 109)];
    self.scrollV.navi = self.navigationController;
    self.scrollV.delegate = self;
    self.scrollV.tag = 1000;
    [self.view addSubview:self.scrollV];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    float current = scrollView.contentOffset.x / kMainScreenWidth;
    [self.scrollLine setFrame:CGRectMake(current * (kMainScreenWidth / 3.0), 44 - 2, kMainScreenWidth / 3.0, 2)];
}
# pragma mark ---修改
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    float current = scrollView.contentOffset.x / kMainScreenWidth;
    currentPage = current;
    NSInteger num = current;
   switch (num) {
        case 0:
        {
            [self changeView:self.changeBtnView.firstBtn];
            //[self getDataFromWeb];
        }
            break;
        case 1:
        {
            [self changeView:self.changeBtnView.secondBtn];
            //[self getSendOrderData];
        }
            break;
        case 2:
        {
            [self changeView:self.changeBtnView.thirdBtn];
            //[self getReceiveData];
        }
            break;
        default:
            break;
    }
}

- (void)getSendOrderData{
    [MBProgressHUD showMessage:nil];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/order/orderList",REQUESTHEADER] andParameter:@{@"userId":[LYUserService sharedInstance].userID,@"roleType":@"0",@"pageNum":@"1"} success:^(id successResponse) {
        [MBProgressHUD hideHUD];
       // MLOG(@"xw结果:%@",successResponse);
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            NSArray *array = successResponse[@"data"][@"orderList"];
            [self.touristOrderArray removeAllObjects];
            for (NSDictionary *dict in array) {
                self.orderModel = [[OrderModel alloc] initWithDict:dict];
                [self.touristOrderArray addObject:self.orderModel];
            }
            self.scrollV.touristOrderArray = self.touristOrderArray;
            [self.scrollV.sendTableV reloadData];
            [self.scrollV.sendTableV.mj_header endRefreshing];

        } else {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
}

- (void)getReceiveData{
    
    [MBProgressHUD showMessage:nil];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/order/orderList",REQUESTHEADER] andParameter:@{@"userId":[LYUserService sharedInstance].userID,@"roleType":@"1",@"pageNum":@"1"} success:^(id successResponse) {
        MLOG(@"receiveDate:%@",successResponse);
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            [MBProgressHUD hideHUD];
            NSArray *array = successResponse[@"data"][@"orderList"];
            [self.guideOrderArray removeAllObjects];
            for (NSDictionary *dict in array) {
                self.orderModel = [[OrderModel alloc] initWithDict:dict];
                [self.guideOrderArray addObject:self.orderModel];
            }
            self.scrollV.guideOrderArray = self.guideOrderArray;
            [self.scrollV.receiveTableV reloadData];
            [self.scrollV.receiveTableV.mj_header endRefreshing];

        } else {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
}

@end
