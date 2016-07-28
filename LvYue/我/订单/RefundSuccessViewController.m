//
//  RefundSuccessViewController.m
//  豆客项目
//
//  Created by Xia Wei on 15/10/12.
//  Copyright © 2015年 Xia Wei. All rights reserved.
//

#import "RefundSuccessViewController.h"
#import "RefundTableViewCell.h"

@interface RefundSuccessViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation RefundSuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self tableViewCreated];
    [self setNavigationBar];
    self.tabBarController.tabBar.hidden = YES;
   // [self.view setBackgroundColor:UIColorWithRGBA(234, 234, 234, 1)];
    // Do any additional setup after loading the view.
}

- (void)setNavigationBar{
    UILabel *titleView = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 50)];
    titleView.text = @"全部订单";
    titleView.textAlignment = NSTextAlignmentCenter;
    titleView.font = [UIFont systemFontOfSize:16];
    self.navigationItem.titleView = titleView;
}

- (void)tableViewCreated{
    UITableView *tableV = [[UITableView alloc]initWithFrame:CGRectMake(0,0, kMainScreenWidth, kMainScreenHeight)];
    tableV.delegate = self;
    tableV.dataSource = self;
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 15)];
    [view setBackgroundColor:UIColorWithRGBA(234, 234, 234, 1)];
    tableV.tableHeaderView = view;
    tableV.showsVerticalScrollIndicator = NO;
    [tableV setBackgroundColor:UIColorWithRGBA(234, 234, 234, 1)];
    tableV.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableV];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kMainScreenHeight - 150;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //订单号12位
    RefundTableViewCell *myCell = [[RefundTableViewCell alloc]initWithFrame:CGRectMake(0, 75, kMainScreenWidth, kMainScreenHeight - 150) orderID:self.orderID date:self.date];
    return myCell;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
