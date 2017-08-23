//
//  SystemMessageViewController.m
//  LvYue
//
//  Created by apple on 15/10/27.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import "SystemMessageViewController.h"
#import "SystemMessageTableViewCell.h"
#import "SystemMessageModel.h"
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "MBProgressHUD+NJ.h"
#import "NSString+DeleteLastWord.h"

@interface SystemMessageViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>{
     NSInteger currentPage;
    
    SystemMessageTableViewCell *cell;
}



@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *modelArray; //存放系统消息模型

@end

@implementation SystemMessageViewController
-(UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64) style:UITableViewStyleGrouped];
        [_tableView registerClass:[SystemMessageTableViewCell class] forCellReuseIdentifier:@"SystemMessageTableViewCell"];
        _tableView.delegate = self;
        _tableView.dataSource = self;
//        _tableView.rowHeight = 65;
        _tableView.backgroundColor = RGBA(246, 246, 247, 1);
        _tableView.decelerationRate = 0.1f;
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    }
    return _tableView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.modelArray = [[NSMutableArray alloc] init];
    self.title = @"系统消息";
    
    //导航栏返回按钮
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(16, 38, 28, 14)];
    [button setTitleColor:[UIColor colorWithHexString:@"#424242"] forState:UIControlStateNormal];
    [button setTitle:@"返回" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [button addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = back;
   
    self.navigationController.navigationBarHidden = NO;
    

    

    [self.view addSubview:self.tableView];
    
     [self addRefresh];
    [self getDataFromWeb];
    
    //发通知让消息界面消除掉系统消息后的点
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LY_CleanSystemMessagePoint" object:nil];
   
}


-(void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark 删除全部消息

- (void)deleteAll:(UIButton *)btn{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"确定删除全部消息吗?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
    
}

#pragma mark 网络请求

- (void)getDataFromWeb{
    currentPage = 1;
    [MBProgressHUD showMessage:nil toView:self.view];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/circle/getSystemMessage",REQUESTHEADER] andParameter:@{@"userId":[CommonTool getUserID],@"pageNum":[NSString stringWithFormat:@"%ld",(long)currentPage]} success:^(id successResponse) {
        MLOG(@"系统消息列表:%@",successResponse);
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            NSArray *array = successResponse[@"data"][@"list"];
            [self.modelArray removeAllObjects];
            for (NSDictionary *dict in array) {
                SystemMessageModel *model = [[SystemMessageModel alloc] initWithDict:dict];
                [self.modelArray addObject:model];
            }
            [self.tableView reloadData];
        } else {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
    
  
}



#pragma mark   -----加载更多的数据
- (void)addRefresh{
    
    //下拉刷新
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefreshing)];

    
        //上拉加载更多
    
        _tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRefreshing)];
    
}

#pragma mark   ----下拉刷新
- (void)headerRefreshing{
    MJRefreshStateHeader *header = (MJRefreshStateHeader *) _tableView.mj_header;
    [header setTitle:@"下拉可以刷新" forState:MJRefreshStateIdle];
    [header setTitle:@"松开马上刷新" forState:MJRefreshStatePulling];
    [header setTitle:@"刷新中" forState:MJRefreshStateRefreshing];
    
    
    currentPage = 1;
    
  
    [self getDataFromWeb];
    
    [_tableView.mj_header endRefreshing];
}


#pragma mark   ----上拉加载更多
- (void)footerRefreshing{
   
    [self getMoreDataNsdic];
    [_tableView.mj_footer endRefreshing];
    
}
//获上啦加载数据
-(void)getMoreDataNsdic{
    currentPage ++;
   
  
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/circle/getSystemMessage",REQUESTHEADER] andParameter:@{@"userId":[CommonTool getUserID],@"pageNum":[NSString stringWithFormat:@"%ld",(long)currentPage]} success:^(id successResponse) {
        MLOG(@"系统消息列表:%@",successResponse);
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            NSArray *array = successResponse[@"data"][@"list"];
//            [self.modelArray removeAllObjects];
            if (array && array.count > 0) {
                for (NSDictionary *dict in array) {
                    SystemMessageModel*model = [[SystemMessageModel alloc] initWithDict:dict];
                    [self.modelArray addObject:model];
                }
                [self.tableView reloadData];
            }else{
                 [MBProgressHUD showSuccess:@"已经到底啦"];
                currentPage --;
            }
           
        } else {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
            currentPage --;
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
        currentPage --;
    }];
}



#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.modelArray.count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  cell =  [tableView dequeueReusableCellWithIdentifier:@"SystemMessageTableViewCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.navi = self.navigationController;
    if (self.modelArray.count) {
     SystemMessageModel*  model = self.modelArray[indexPath.section];
        [cell fillDataWithModel:model];
    }
    
    return cell;
}


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
       SystemMessageModel *model = [self.modelArray objectAtIndex:indexPath.row];
  
    return   cell.cellHeight;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01f;
}
//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//    return YES;
//}
//
//
//-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
//    
//    self.model = self.modelArray[indexPath.section];
//    [MBProgressHUD showMessage:nil toView:self.view];
//    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/messageSystem/deletes",REQUESTHEADER] andParameter:@{@"ids":self.model.messageID} success:^(id successResponse) {
//        
//        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//        
//        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
//            
//            [self.modelArray removeObjectAtIndex:indexPath.section];//bookInfo为当前table中显示的array
//            
//            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationLeft];
//            
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"LY_ReloadSystemMessage" object:nil];
//            
//        } else {
//            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
//        }
//    } andFailure:^(id failureResponse) {
//        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//        [MBProgressHUD showError:@"服务器繁忙,请重试"];
//    }];
//}

#pragma mark uialertview

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        
        if (!self.modelArray.count) {
            [MBProgressHUD showError:@"没有可以删除的消息"];
            return;
        }
        
        NSMutableString *str = [[NSMutableString alloc] init];
        
        for (int i = 0; i < self.modelArray.count; i++) {
           SystemMessageModel*  model = self.modelArray[i];
            [str appendString:[NSString stringWithFormat:@"%@,",model.messageID]];
        }
        
        [MBProgressHUD showMessage:nil toView:self.view];
        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/messageSystem/deletes",REQUESTHEADER] andParameter:@{@"ids":str} success:^(id successResponse) {
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            
            if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
                
                [MBProgressHUD showSuccess:@"删除成功"];
                
                [self getDataFromWeb];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LY_ReloadSystemMessage" object:nil];
                
            } else {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
            }
        } andFailure:^(id failureResponse) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [MBProgressHUD showError:@"服务器繁忙,请重试"];
        }];
    }
}

@end
