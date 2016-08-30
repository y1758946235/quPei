//
//  FriendsMessageViewController.m
//  LvYueDemo
//
//  Created by 蒋俊 on 15/10/12.
//  Copyright (c) 2015年 vison. All rights reserved.
//

#import "FriendsMessageViewController.h"
#import "FriendsMessageCell.h"
#import "AFNetworking.h"
#import "MBProgressHUD+NJ.h"
#import "UIImageView+WebCache.h"
#import "LYUserService.h"
#import "LYHttpPoster.h"
#import "LYDetailDataViewController.h"

@interface FriendsMessageViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSArray *_msgArray;//数据源
}
@property (nonatomic,strong) UITableView *tableView;
@end

@implementation FriendsMessageViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.title = @"消息";

    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //获取网络数据
    [self postRequest];
    [self cleanNewMsg];
    
    
    [self setLeftButton:[UIImage imageNamed:@"返回"] title:nil target:self action:@selector(popClick:)];
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
}

- (void)popClick:(UIButton *)sender {
    
    self.hideMsgViewBlock(YES);
    [self.navigationController popViewControllerAnimated:YES];
}


//清空新消息数量
- (void)cleanNewMsg{
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/notice/iosUpdateNumByUser",REQUESTHEADER] andParameter:@{@"userId":[NSString stringWithFormat:@"%@",[LYUserService sharedInstance].userID]} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            
        } else {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
}

//获取网络数据
- (void)postRequest{

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [MBProgressHUD showMessage:@"正在加载"];
    NSString *urlStr = [NSString stringWithFormat:@"%@/mobile/notice/findMessageByUser",REQUESTHEADER];
    [manager POST:urlStr parameters:@{@"user_id":[NSString stringWithFormat:@"%@",[LYUserService sharedInstance].userID]} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"消息列表:%@",responseObject);
        
        if ( [[NSString stringWithFormat:@"%@",responseObject[@"code"]] isEqualToString:@"200"]){
            
            [MBProgressHUD hideHUD];
            _msgArray = responseObject[@"data"][@"aList"];
            [_tableView reloadData];
        }else{
            
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:responseObject[@"msg"]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"请检查您的网络"];
    }];
}

#pragma mark - UITableViewDataSource & Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _msgArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellID = @"myCell";
    FriendsMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[FriendsMessageCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",IMAGEHEADER,_msgArray[indexPath.row][@"icon"]];
    [cell.headImg sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:nil];
    cell.nameLabel.text = _msgArray[indexPath.row][@"name"];
    if (_msgArray[indexPath.row][@"detail"]) {
        cell.commentLabel.text = _msgArray[indexPath.row][@"detail"];
    }
    else{
        cell.commentLabel.text = @"赞了这条动态";
    }
    cell.timeLabel.text = _msgArray[indexPath.row][@"create_time"];
    
    //如果没有照片 就放文字
    if ([_msgArray[indexPath.row][@"notice"][@"photos"] isKindOfClass:[NSNull class]] || [_msgArray[indexPath.row][@"notice"][@"photos"] isEqualToString:@""]) {
        cell.rightLabel.text = _msgArray[indexPath.row][@"notice"][@"notice_detail"];
        cell.rightImage.hidden = YES;
        cell.rightLabel.hidden = NO;
    }else{
        NSArray *array = [_msgArray[indexPath.row][@"notice"][@"photos"] componentsSeparatedByString:@";"];
        NSString *urlStr = [NSString stringWithFormat:@"%@%@",IMAGEHEADER,array[0]];
        [cell.rightImage sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:nil];
        cell.rightLabel.hidden = YES;
        cell.rightImage.hidden = NO;
    }
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 80;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 0.1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString* userId = _msgArray[indexPath.row][@"comment_user_id"];
    LYDetailDataViewController* vc = [[LYDetailDataViewController alloc] init];
    vc.userId = userId;
    [self.navigationController pushViewController:vc animated:YES];

}

@end
