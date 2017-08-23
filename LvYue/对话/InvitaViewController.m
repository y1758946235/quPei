//
//  InvitaViewController.m
//  LvYue
//
//  Created by X@Han on 17/4/20.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "InvitaViewController.h"
#import "InvitaTableViewCell.h"
#import "InvitaModel.h"
@interface InvitaViewController ()<UITableViewDelegate,UITableViewDataSource>{
    NSInteger currentPage;
}

@property(nonatomic,retain)NSMutableArray *dataArr;
@property (nonatomic, strong) UITableView *myTableView;

@end

@implementation InvitaViewController


-(UITableView *)myTableView {
    if (!_myTableView) {
        _myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64) style:UITableViewStyleGrouped];
        [_myTableView registerClass:[InvitaTableViewCell class] forCellReuseIdentifier:@"InvitaTableViewCell"];
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
    
     self.title = @"收到的邀请";
    
    //导航栏返回按钮
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(16, 38, 28, 14)];
    [button setTitleColor:[UIColor colorWithHexString:@"#424242"] forState:UIControlStateNormal];
    [button setTitle:@"返回" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [button addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = back;
    
    [self.view addSubview:self.myTableView];
    [self addRefresh];
    [self getData:dic];
    
   
}
-(void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark   -----加载更多的数据
- (void)addRefresh{
    
    //下拉刷新
    self.myTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefreshing)];
    #pragma mark   -----上拉加载更多先不写
//    
//    //上拉加载更多
//    
//    self.myTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRefreshing)];
    
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
    
    [LYHttpPoster requestGtSystemInviteDataWithParameters:dic Block:^(NSArray *arr) {
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
    
    [LYHttpPoster requestGtSystemInviteDataWithParameters:Dic Block:^(NSArray *arr) {
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
    
    InvitaTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InvitaTableViewCell"];
     cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (self.dataArr) {
        InvitaModel *model = self.dataArr[indexPath.row];
        [cell fillDataWithModel:model];
       
        
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
 
    
    
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
