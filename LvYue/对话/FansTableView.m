//
//  FansTableView.m
//  LvYue
//
//  Created by leo on 2016/11/22.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#define WIDTH self.frame.size.width
#define HEIGHT self.frame.size.height

#import "FansTableView.h"  //粉丝
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "MBProgressHUD+NJ.h"
#import "focusCell.h"
#import "focusModel.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"


@interface FansTableView () <UITableViewDelegate,UITableViewDataSource>{
    NSMutableArray *dataArr;
}

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation FansTableView      //关注



- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        dataArr = [[NSMutableArray alloc]init];
        [self setTable];
        [self addRefresh];
    }
    return self;
    
}
#pragma mark   -----加载更多的数据
- (void)addRefresh{
    //下拉刷新
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefreshing)];
}
#pragma mark   ----下拉刷新
- (void)headerRefreshing{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LY_fans" object:nil];
    [_tableView.mj_header endRefreshing];
}
- (void)getData{
      [[NSNotificationCenter defaultCenter] postNotificationName:@"updataRedDotLabel" object:nil];//更新好友两个字边上的红点
      NSString *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userId"];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/circle/getFans",REQUESTHEADER] andParameter:@{@"userId":userId} success:^(id successResponse) {
        NSLog(@"粉丝:%@",successResponse);
        
        NSArray *arr = successResponse[@"data"];
        [dataArr removeAllObjects];
        for (NSDictionary *dic in arr) {
            focusModel *model = [[focusModel alloc]initWithModelDic:dic];
            [dataArr addObject:model];
           
        }
         [_tableView reloadData];
    } andFailure:^(id failureResponse) {
        
    }];
    
}





- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataArr.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    focusCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[focusCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    focusModel *model = dataArr[indexPath.row];
    NSURL *headUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,model.userIcon]];
    [cell.userIcon sd_setImageWithURL:headUrl];
    
    if ([[NSString stringWithFormat:@"%@",model.vip] isEqualToString:@"0"]) {
        cell.vip.hidden = YES;
    }
    if ([[NSString stringWithFormat:@"%@",model.vip] isEqualToString:@"1"]) {
        cell.vip.hidden = NO;
    }
//    [cell.focuBtn setTitle:@"已互粉" forState:UIControlStateNormal];
//    [cell.focuBtn addTarget:self action:@selector(cancelFocus:) forControlEvents:UIControlEventTouchUpInside];
    cell.focuBtn.hidden = YES;
    [cell.focuBtn removeFromSuperview];
    cell.userName.text = model.userName;
    cell.userAge.text = [NSString stringWithFormat:@"%@岁",model.userAge];
    cell.userheight.text = [NSString stringWithFormat:@"%@cm",model.userheight];
    cell.conStella.text = model.conStella;
    
    return cell;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    focusModel *model = dataArr[indexPath.row];
    
    //push通知
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"pushToOtherZhuYeVC2" object:nil userInfo:@{@"userID":model.userId,@"userNickName":model.userName}];
    
}






- (void)setTable{
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 14, WIDTH, HEIGHT-50) style:UITableViewStylePlain];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.rowHeight = 72;
    [self addSubview:_tableView];
    _tableView.separatorInset  = UIEdgeInsetsMake(0, 100, 0, 0);
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
}










@end
