//
//  BlackListTableView.m
//  LvYue
//
//  Created by leo on 2016/11/22.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#define WIDTH self.frame.size.width
#define HEIGHT self.frame.size.height

#import "BlackListTableView.h"
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "MBProgressHUD+NJ.h"
#import "focusCell.h"
#import "focusModel.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"


@interface BlackListTableView ()<UITableViewDelegate,UITableViewDataSource>{
    NSMutableArray *dataArr;
}

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation BlackListTableView     //黑名单



- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        dataArr = [[NSMutableArray alloc]init];
        [self setTable];
//        [self getData];
    }
    return self;
    
}

- (void)getData{
    
      NSString *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userId"];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/circle/getBlacklist",REQUESTHEADER] andParameter:@{@"userId":userId} success:^(id successResponse) {
        NSLog(@"黑名单:%@",successResponse);
        [dataArr removeAllObjects];
        NSArray *arr = successResponse[@"data"];
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
    cell.focuBtn.tag = 1000+indexPath.row;
    [cell.focuBtn setTitle:@"取消拉黑" forState:UIControlStateNormal];
    [cell.focuBtn addTarget:self action:@selector(cancelFocus:) forControlEvents:UIControlEventTouchUpInside];
    cell.userName.text = model.userName;
    cell.userAge.text = [NSString stringWithFormat:@"%@岁",model.userAge];
    cell.userheight.text = [NSString stringWithFormat:@"%@cm",model.userheight];
    cell.conStella.text = model.conStella;
    
    return cell;
    
}

#pragma mark   ---黑名单操作
- (void)cancelFocus:(UIButton *)sender{
    
    focusModel *model = dataArr[sender.tag-1000];
    //取消拉黑
    
    NSString *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userId"];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/circle/deleteBlacklist",REQUESTHEADER] andParameter:@{@"userId":userId,@"otherUserId":model.userId} success:^(id successResponse) {
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            [MBProgressHUD showSuccess:@"已取消拉黑"];
            
            [dataArr removeObjectAtIndex:sender.tag-1000];
            [_tableView reloadData];
        }
        
        
    } andFailure:^(id failureResponse) {
        
    }];
    

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
