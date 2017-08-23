//
//  CallRecordsViewController.m
//  LvYue
//
//  Created by X@Han on 17/7/22.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "CallRecordsViewController.h"
#import "GoldsRecordTableViewCell.h"
#import "GoldsRecordModel.h"
@interface CallRecordsViewController ()<UITableViewDelegate,UITableViewDataSource>{
    NSInteger currentPage2;
}
@property (nonatomic, strong) UITableView *myTableView;
@property(nonatomic,retain)NSMutableArray *dateArr;
@end

@implementation CallRecordsViewController
-(UITableView *)myTableView {
    if (!_myTableView) {
        _myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,0, SCREEN_WIDTH, SCREEN_HEIGHT-64) style:UITableViewStyleGrouped];
        [_myTableView registerClass:[GoldsRecordTableViewCell class] forCellReuseIdentifier:@"GoldsRecordTableViewCell"];
        
        
        
    }
    _myTableView.delegate = self;
    _myTableView.dataSource = self;
    _myTableView.backgroundColor = RGBA(246, 246, 247, 1);
    _myTableView.decelerationRate = 0.1f;
    return _myTableView;
}
-(void)getAppointData{
    
    
    
    NSDictionary *dic = @{@"userId":[CommonTool getUserID],@"type":@"3"};
    [ LYHttpPoster requestGetUserGoldOrPointDetailDataWithParameters:dic Block:^(NSArray *arr) {
        [self.dateArr removeAllObjects];
        [self.dateArr addObjectsFromArray:arr];
        
        
        [_myTableView reloadData];
        
        
        
    }];
    
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNav];
    [self.view addSubview:self.myTableView];
    currentPage2 = 1;
    [self getAppointData];
    
    
    self.dateArr = [[NSMutableArray alloc]init];
    
    //    [self addRefresh];
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
    [ LYHttpPoster requestGetUserGoldOrPointDetailDataWithParameters:dic Block:^(NSArray *arr) {
        [self.dateArr addObjectsFromArray:arr];
        
        
        [_myTableView reloadData];
        
        
        
        if (arr.count == 0) {
            [MBProgressHUD showSuccess:@"已经到底啦"];
            currentPage2 --;
        }
        
        
    }];
    
    
    [_myTableView.mj_footer endRefreshing];
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 0.01;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 0.01;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dateArr.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 100;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    GoldsRecordTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"GoldsRecordTableViewCell" forIndexPath:indexPath];
    
    cell.selectionStyle = UITableViewCellAccessoryNone;
    
    cell.contentView.userInteractionEnabled = YES;
    
    
    GoldsRecordModel*  dataModel = self.dateArr[indexPath.row];
    if (dataModel) {
        
        
        [cell createCallRecordModel:dataModel];
        
    }
    return cell;
}

- (void)setNav{
    self.title = @"我的通话记录";
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
