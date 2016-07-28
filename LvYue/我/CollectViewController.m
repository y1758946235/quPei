//
//  CollectViewController.m
//  购买会员
//
//  Created by 刘丽锋 on 15/10/5.
//  Copyright © 2015年 刘丽锋. All rights reserved.
//

#import "CollectViewController.h"
#import "MBProgressHUD+NJ.h"
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "MyCollectionModel.h"
#import "UIImageView+WebCache.h"
#import "CollectWebViewController.h"

@interface CollectViewController ()

@property(nonatomic,retain) UITableView* collectTableView;
@property (nonatomic,strong) NSMutableArray *collectArray;
@property (nonatomic,strong) MyCollectionModel *myCollectionModel;

@end

@implementation CollectViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getDataFromWeb];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:NO];
    
    //添加标题
    self.title=@"我的收藏";
    
    self.collectArray = [[NSMutableArray alloc] init];
    
    //设置UITableView
    _collectTableView =[[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    _collectTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    
    //设置headerView
    UIView* headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 10)];
    _collectTableView.tableHeaderView=headView;
    //设置数据源方法
    _collectTableView.dataSource=self;
    //设置代理方法
    _collectTableView.delegate=self;
    
    //设置假数据
    _imgArray =[[NSMutableArray alloc] initWithObjects:[UIImage imageNamed:@"img"],[UIImage imageNamed:@"img"],[UIImage imageNamed:@"img"],[UIImage imageNamed:@"img"], nil];
    _titleArray=[[NSMutableArray alloc] initWithObjects:@"Korea,初见便爱上",@"Korea,初见便爱上",@"Korea,初见便爱上",@"Korea,初见便爱上", nil];
    _webArray=[[NSMutableArray alloc] initWithObjects:@"www.baidu.com",@"www.baidu.com",@"www.baidu.com",@"www.baidu.com", nil];
    _dateArray=[[NSMutableArray alloc] initWithObjects:@"2015-10-5",@"2015-10-5",@"2015-10-5",@"2015-10-5", nil];
//    _dataArray = @[@[]]
    
    [self.view addSubview:_collectTableView];
}

#pragma mark 网络请求

- (void)getDataFromWeb{
    
    [MBProgressHUD showMessage:nil toView:self.view];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/collect/list",REQUESTHEADER] andParameter:@{@"user_id":[NSString stringWithFormat:@"%@",[LYUserService sharedInstance].userID]} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            NSArray *array = successResponse[@"data"][@"list"];
            [self.collectArray removeAllObjects];
            for (NSDictionary *dict in array) {
                self.myCollectionModel = [[MyCollectionModel alloc] initWithDict:dict];
                [self.collectArray addObject:self.myCollectionModel];
            }
            [self.collectTableView reloadData];
            
        } else {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
}

#pragma mark--UITableView DataSource---

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

#pragma mark---row的数量----
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.collectArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* cellIdentifier = @"cell";
    CollectTableViewCell* cell= [_collectTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == Nil) {
        cell =[[CollectTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    self.myCollectionModel = self.collectArray[indexPath.row];
    [cell.icon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,self.myCollectionModel.photo]]];
    cell.title.text = self.myCollectionModel.title;
    cell.webText.text = self.myCollectionModel.content;
    cell.date.text = self.myCollectionModel.create_time;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark---UITableView Delegate---
//设置row高度，统一

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 81;
}

//编辑cell 样式
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

#pragma mark---Edit  UITableDatasource----

//当前编辑状态
- (void)setEditing:(BOOL)editing animated:(BOOL)animated{
    if (self.collectTableView.editing) {
        [self.collectTableView setEditing:NO animated:YES];
    }else{
        [self.collectTableView setEditing:YES animated:YES];
    }
}

//当前cell是否可以编辑 
- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    //1.先从数据源里删 2.再从table里删
    if (editingStyle==UITableViewCellEditingStyleDelete) {
        
        self.myCollectionModel = self.collectArray[indexPath.row];
        
        [MBProgressHUD showMessage:nil toView:self.view];
        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/collect/delete",REQUESTHEADER] andParameter:@{@"user_id":[NSString stringWithFormat:@"%@",[LYUserService sharedInstance].userID],@"id":self.myCollectionModel.collId} success:^(id successResponse) {
            MLOG(@"结果:%@",successResponse);
            if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
                [MBProgressHUD hideHUD];
                [self.collectArray removeObjectAtIndex:indexPath.row];
                [tableView reloadData];
                [MBProgressHUD showSuccess:@"删除成功"];
                
            } else {
                [MBProgressHUD hideHUD];
                [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
            }
        } andFailure:^(id failureResponse) {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"服务器繁忙,请重试"];
        }];
    }else if (editingStyle==UITableViewCellEditingStyleInsert){
        
    }
}

//修改删除按钮的文字
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.myCollectionModel = self.collectArray[indexPath.row];
    CollectWebViewController *coll = [[CollectWebViewController alloc] init];
    coll.url = self.myCollectionModel.url;
    [self.navigationController pushViewController:coll animated:YES];
}

@end
