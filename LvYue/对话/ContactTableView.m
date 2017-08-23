//
//  ContactTableView.m
//  LvYue
//
//  Created by leo on 2016/11/22.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#define WIDTH self.frame.size.width
#define HEIGHT self.frame.size.height

#import "ContactTableView.h"        //关注
#import "LYDetailDataViewController.h"
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "MBProgressHUD+NJ.h"
#import "focusModel.h"
#import "focusCell.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "otherZhuYeVC.h"

@interface ContactTableView () <
UITableViewDelegate,
UITableViewDataSource>{
    NSMutableArray *dataArr;
}

@property (nonatomic, strong) UITableView *tableView;

@property(nonatomic,strong)UIButton *currentButton;

@end

@implementation ContactTableView      //关注



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
    
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/circle/getAttention",REQUESTHEADER] andParameter:@{@"userId":userId} success:^(id successResponse) {
        NSLog(@"关注:%@",successResponse);
        
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
    cell.focuBtn.tag = 1000+indexPath.row;
    [cell.focuBtn setTitle:@"已关注" forState:UIControlStateNormal];
    [cell.focuBtn addTarget:self action:@selector(cancelFocus:) forControlEvents:UIControlEventTouchUpInside];
    cell.userName.text = model.userName;
    cell.userAge.text = [NSString stringWithFormat:@"%@岁",model.userAge];
    cell.userheight.text = [NSString stringWithFormat:@"%@cm",model.userheight];
    cell.conStella.text = model.conStella;
    
    return cell;
    
}

#pragma mark  ---取消关注
- (void)cancelFocus:(UIButton *)sender{
     focusModel *model = dataArr[sender.tag-1000];
     NSString *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userId"];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/circle/deleteAttention",REQUESTHEADER] andParameter:@{@"userId":userId,@"otherUserId":model.userId} success:^(id successResponse) {
        
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            [MBProgressHUD showSuccess:@"已取消关注"];
           
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

//#pragma mark - Pravite
//
//- (void)p_loadData {
//
//    NSString *requestURL;
//  requestURL = @"/mobile/userFriend/getMyFoucsList";
//
//    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@%@", REQUESTHEADER, requestURL]
//                           andParameter:@{
//                                          @"user_id": [LYUserService sharedInstance].userID
//                                          }
//                                success:^(id successResponse) {
//                                    if ([successResponse[@"code"] integerValue] == 200) {
//                                        self.tableViewArray = successResponse[@"data"][@"users"];
//                                        [self.tableView reloadData];
//                                    } else {
//                                        [MBProgressHUD showError:@"加载失败，请重试"];
//                                    }
//                                }
//                             andFailure:^(id failureResponse) {
//                                 [MBProgressHUD showError:@"服务器繁忙,请重试"];
//                             }];
//}
//
//- (void)p_processFocusOn:(NSIndexPath *)indexPath {
//    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/userFriend/focusOther", REQUESTHEADER]
//                           andParameter:@{
//                                          @"user_id": [LYUserService sharedInstance].userID,
//                                          @"other_user_id": self.tableViewArray[indexPath.row][@"id"]
//                                          }
//                                success:^(id successResponse) {
//                                    if ([successResponse[@"code"] integerValue] == 200) {
//                                        NSMutableArray *array    = [self.tableViewArray mutableCopy];
//                                        NSMutableDictionary *dic = [array[indexPath.row] mutableCopy];
//                                        [dic setObject:([dic[@"isgz"] integerValue] == 1 ? @2 : @1) forKey:@"isgz"];
//                                        [array replaceObjectAtIndex:indexPath.row withObject:[dic copy]];
//                                        self.tableViewArray = [array copy];
//                                        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//
//                                        if ([dic[@"isgz"] integerValue] == 1) {
//                                            [MBProgressHUD showSuccess:@"关注成功"];
//
//                                        }
//                                        else {
//                                            [MBProgressHUD showSuccess:@"取消关注成功"];
//                                        }
//
//                                    } else {
//                                        [MBProgressHUD showError:@"处理失败，请重试"];
//                                    }
//                                }
//                             andFailure:^(id failureResponse) {
//                                 [MBProgressHUD showError:@"服务器繁忙,请重试"];
//                             }];
//}
//
//
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
