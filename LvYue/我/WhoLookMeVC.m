//
//  WhoLookMeVC.m
//  LvYue
//
//  Created by X@Han on 16/12/19.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "WhoLookMeVC.h"
#import "WhoLookMeCell.h"
#import "LYHttpPoster.h"
#import "WhoLookMeModel.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "otherZhuYeVC.h"
@interface WhoLookMeVC ()<UITableViewDelegate,UITableViewDataSource>{
    NSInteger currentPage;
}

@property(nonatomic,retain)NSMutableArray *dataArr;
@property (nonatomic, strong) UITableView *myTableView;
@end

@implementation WhoLookMeVC



-(UITableView *)myTableView {
    if (!_myTableView) {
        _myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64) style:UITableViewStyleGrouped];
        [_myTableView registerClass:[WhoLookMeCell class] forCellReuseIdentifier:@"WhoLookMeCell"];
        _myTableView.delegate = self;
        _myTableView.dataSource = self;
        _myTableView.rowHeight = 72;
        _myTableView.backgroundColor = RGBA(246, 246, 247, 1);
        _myTableView.decelerationRate = 0.1f;
    }
    return _myTableView;
}
- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [[NSMutableArray alloc]init];
    }
    
    return _dataArr;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    currentPage = 1;
    NSDictionary*dic = @{@"userId":[CommonTool getUserID],@"pageNum":[NSString stringWithFormat:@"%d",currentPage]};
   
    [self setNav];
    
    [self.view addSubview:self.myTableView];
    [self addRefresh];
     [self getData:dic];

    [self updataWhoSeeMe];
}

-(void)updataWhoSeeMe{
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/updateSeeMe",REQUESTHEADER] andParameter:@{@"userId":[CommonTool getUserID]} success:^(id successResponse) {
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadDisposition" object:nil];
        } else {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
}
#pragma mark   -----加载更多的数据
- (void)addRefresh{
    
    //下拉刷新
    self.myTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefreshing)];
    
    
    //上拉加载更多
    
    self.myTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRefreshing)];
    
}

#pragma mark   ----下拉刷新
- (void)headerRefreshing{
    MJRefreshStateHeader *header = (MJRefreshStateHeader *) self.myTableView.mj_header;
    [header setTitle:@"下拉可以刷新" forState:MJRefreshStateIdle];
    [header setTitle:@"松开马上刷新" forState:MJRefreshStatePulling];
    [header setTitle:@"刷新中" forState:MJRefreshStateRefreshing];
    
    
    currentPage = 1;
    
    NSDictionary*dic = @{@"userId":[CommonTool getUserID],@"pageNum":[NSString stringWithFormat:@"%d",currentPage]};
    [self getData:dic];
    
    [self.myTableView.mj_header endRefreshing];
}



- (void)getData:(NSDictionary*)dic {
   
    [LYHttpPoster requestGetSeeMeDataWithParameters:dic Block:^(NSArray *arr) {
        [self.dataArr removeAllObjects];
         [self.dataArr addObjectsFromArray:arr];
        [self.myTableView reloadData];
    }];

}


#pragma mark   ----上拉加载更多
- (void)footerRefreshing{
    currentPage ++;
    NSDictionary*dic = @{@"userId":[CommonTool getUserID],@"pageNum":[NSString stringWithFormat:@"%d",currentPage]};
    [self getMoreDataNsdic:dic];
    [self.myTableView.mj_footer endRefreshing];
    
}
//获上啦加载数据
-(void)getMoreDataNsdic:(NSDictionary*)Dic{
    
  [LYHttpPoster requestGetSeeMeDataWithParameters:Dic Block:^(NSArray *arr) {
        [self.dataArr addObjectsFromArray:arr];
        if (arr.count == 0) {
            currentPage --;
            [MBProgressHUD showSuccess:@"已经到底啦"];
        }
        [self.myTableView reloadData];
    }];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    WhoLookMeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WhoLookMeCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    WhoLookMeModel *lookModel = self.dataArr[indexPath.row];
    if (lookModel) {
        [cell creatModel:lookModel];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    WhoLookMeModel *model = self.dataArr[indexPath.row];
    otherZhuYeVC *vc = [[otherZhuYeVC alloc]init];
    vc.userId = model.userId;
    vc.userNickName = model.peopleName;
    
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)setNav{
   self.title = @"谁看过我";
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



#pragma mark  ----时间转化
- (NSString *)transformTime:(NSString *)time{
    
    
    
    NSInteger num = [time integerValue]/1000;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd-mm"];
    
    NSDate *contime = [NSDate dateWithTimeIntervalSince1970:num];
    NSString *conTimeStr = [formatter stringFromDate:contime];
    
    return conTimeStr;
    
}



- (void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    

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
