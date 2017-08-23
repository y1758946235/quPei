//
//  taskViewController.m
//  LvYue
//
//  Created by X@Han on 17/1/18.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "taskViewController.h"
#import "TaskTableViewCell.h"
#import "taskModel.h"
@interface taskViewController ()<UITableViewDelegate,UITableViewDataSource>{
    UITableView *table;
}
@property(nonatomic,retain)NSMutableArray *dataArr;


@end

@implementation taskViewController

- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr =[[NSMutableArray alloc]init];
    }
    return _dataArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.view.backgroundColor = [UIColor colorWithHexString:@"#ff5252"];
    
    
    [self setNav];
    [self setMineTable];
    UIImageView *imagV = [[UIImageView alloc]init];
    imagV.frame = CGRectMake(33, 0, SCREEN_WIDTH-33-110, 88);
    imagV.image = [UIImage imageNamed:@"title_fox"];
    [self.view addSubview:imagV];
    [self getDataFromWeb];
}
#pragma mark 任务列表
- (void)getDataFromWeb{
    //  [MBProgressHUD showMessage:nil];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/task/getTaskList",REQUESTHEADER] andParameter:@{@"userId":[CommonTool getUserID]} success:^(id successResponse) {
        MLOG(@"全部任务结果:%@",successResponse);
        [MBProgressHUD hideHUD];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            [self.dataArr removeAllObjects];
            NSArray *array = successResponse[@"data"];
            for (NSDictionary *dict in array) {
                taskModel *model = [taskModel createWithModelDic:dict];
                [self.dataArr addObject:model];
            }
            [table reloadData];
            
        } else {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
}
#pragma mark ----------- 创建UI  table
- (void)setMineTable{
    
    table = [[UITableView alloc]initWithFrame:CGRectMake(16, 64, SCREEN_WIDTH-31, SCREEN_HEIGHT-64-64-48) style:UITableViewStylePlain];
    table.dataSource = self;
    table.delegate = self;
    table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [table registerClass:[TaskTableViewCell class] forCellReuseIdentifier:@"TaskTableViewCell"];
    [self.view addSubview:table];
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 56;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
   
        return 1;
   
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    TaskTableViewCell *cell = [[TaskTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TaskTableViewCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    taskModel *model = self.dataArr[indexPath.row];
    cell.model = model;
    return cell;
    
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
}



#pragma mark   -------配置导航栏
- (void)setNav{
    self.title = @"任务";
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:@"#ffffff"];
    //导航栏title的颜色
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithHexString:@"#424242"],UITextAttributeTextColor, [UIFont fontWithName:@"PingFangSC-Medium" size:18],UITextAttributeFont, nil]];
    
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
