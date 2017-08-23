//
//  WithdrawalRecordVC.m
//  LvYue
//
//  Created by X@Han on 17/4/11.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "WithdrawalRecordVC.h"
#import "WithdrawalRecordTableViewCell.h"
#import "WithdrawalRecordModel.h"
#import "LYHttpPoster.h"
@interface WithdrawalRecordVC ()<UITableViewDelegate,UITableViewDataSource>{
    UITableView *table;
    NSMutableArray *withdrawalRecordArr;
    
    NSInteger currentPage2;
}

@end

@implementation WithdrawalRecordVC


- (void)viewDidLoad {
    [super viewDidLoad];
    withdrawalRecordArr = [[NSMutableArray alloc]init];
    [self setTable];
    [self setNav];
    currentPage2 = 1;
    [self getData];
    [self addRefresh];
}

- (void)getData{
    currentPage2 = 1;
    NSDictionary *dic = @{@"userId":[CommonTool getUserID],@"pageNum":[NSString stringWithFormat:@"%ld",(long)currentPage2]};
    [LYHttpPoster requestWithdrawalRcordWithParameters:dic block:^(NSMutableArray *arr) {
        [withdrawalRecordArr removeAllObjects];
        [withdrawalRecordArr addObjectsFromArray:arr];
        
        
        [table reloadData];
        
    }];
    
}
- (void)addRefresh{
    currentPage2 = 1;
    // 1.下拉刷新(进入刷新状态就会调用self的headerRereshing)
    table.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefreshing)];
    
    // 2.上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    table.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRefreshing)];
    
}

#pragma mark   --下拉刷新
- (void)headerRefreshing{
    
    
    
    MJRefreshStateHeader *header = (MJRefreshStateHeader *) table.mj_header;
    [header setTitle:@"下拉可以刷新" forState:MJRefreshStateIdle];
    [header setTitle:@"松开马上刷新" forState:MJRefreshStatePulling];
    [header setTitle:@"刷新中" forState:MJRefreshStateRefreshing];
    currentPage2 = 1;
    [self  getData];
    [table.mj_header endRefreshing];
}





#pragma mark   ---上拉刷新
- (void)footerRefreshing{
    
    
    currentPage2++;
    
    
    
    
    NSDictionary *dic = @{@"userId":[CommonTool getUserID],@"pageNum":[NSString stringWithFormat:@"%ld",(long)currentPage2]};
    [ LYHttpPoster requestWithdrawalRcordWithParameters:dic block:^(NSMutableArray *arr) {
        [withdrawalRecordArr addObjectsFromArray:arr];
        
        
        [table reloadData];
        
        
        
        if (arr.count == 0) {
            [MBProgressHUD showSuccess:@"已经到底啦"];
            currentPage2 --;
        }
        
        
    }];
    
    
    [table.mj_footer endRefreshing];
}




- (void)setTable{
    
    table = [[UITableView alloc]initWithFrame:CGRectMake(0, 16, SCREEN_WIDTH, SCREEN_HEIGHT-16) style:UITableViewStylePlain];
    table.rowHeight = 77;
    table.dataSource = self;
    table.delegate = self;
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:table];
    
    
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return withdrawalRecordArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WithdrawalRecordTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[WithdrawalRecordTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    if (withdrawalRecordArr.count >0) {
        
       WithdrawalRecordModel *model = withdrawalRecordArr[indexPath.row];
        
        cell.withRecordModel = model;
    }
    
    return cell;
}


#pragma mark   -------配置导航栏
- (void)setNav{
    self.title = @"提现记录";
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
