//
//  SystemMessageViewController.m
//  LvYue
//
//  Created by apple on 15/10/27.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import "SystemMessageViewController.h"
#import "SystemMessageCell.h"
#import "SystemMessageModel.h"
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "MBProgressHUD+NJ.h"
#import "NSString+DeleteLastWord.h"

@interface SystemMessageViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>

@property (nonatomic,strong) SystemMessageModel *model;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *modelArray; //存放系统消息模型

@end

@implementation SystemMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.modelArray = [[NSMutableArray alloc] init];
    self.title = @"系统消息";
    self.navigationController.navigationBarHidden = NO;
    
    UIButton *trashBtn = [self setRightButton:[UIImage imageNamed:@"delete"] title:nil target:self action:@selector(deleteAll:) rect:CGRectMake(0, 0, 44, 44)];
    for (UIView *subView in trashBtn.subviews) {
        if ([subView isKindOfClass:[UIImageView class]]) {
            UIImageView *trash = (UIImageView *)subView;
            [trash setBounds:CGRectMake(0, 0, 20, 22)];
        }
    }
    
    [self setLeftButton:[UIImage imageNamed:@"back"] title:nil target:self action:@selector(back)];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight) style:UITableViewStyleGrouped];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    
    [self getDataFromWeb];
}

#pragma mark 删除全部消息

- (void)deleteAll:(UIButton *)btn{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"确定删除全部消息吗?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
    
}

#pragma mark 网络请求

- (void)getDataFromWeb{
    [MBProgressHUD showMessage:nil toView:self.view];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/messageSystem/list",REQUESTHEADER] andParameter:@{@"user_id":[LYUserService sharedInstance].userID,@"status":@"-1"} success:^(id successResponse) {
        MLOG(@"系统消息列表:%@",successResponse);
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            NSArray *array = successResponse[@"data"][@"list"];
            [self.modelArray removeAllObjects];
            for (NSDictionary *dict in array) {
                self.model = [[SystemMessageModel alloc] initWithDict:dict];
                [self.modelArray addObject:self.model];
            }
            [self.tableView reloadData];
            if (self.modelArray.count) {
                [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/messageSystem/updateAll",REQUESTHEADER] andParameter:@{@"user_id":[LYUserService sharedInstance].userID} success:^(id successResponse) {
                    MLOG(@"标记已读结果:%@",successResponse);
                    if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
                        //清空对话tabbar的提醒数字
                        UINavigationController *nav = kAppDelegate.rootTabC.viewControllers[1];
                        NSInteger num = [nav.tabBarItem.badgeValue integerValue];
                        NSInteger startNum = num - kAppDelegate.unReadSystemMessageNum;
                        kAppDelegate.unReadSystemMessageNum = 0;
                        if (startNum) {
                            if (startNum > 99) {
                                nav.tabBarItem.badgeValue = @"99";
                            } else {
                                nav.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld",startNum];
                            }
                        } else {
                            nav.tabBarItem.badgeValue = nil;
                        }
                        //更新会话中的UI
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
        } else {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
    
    //发通知让消息界面消除掉系统消息后的点
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LY_CleanSystemMessagePoint" object:nil];
}


- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.modelArray.count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SystemMessageCell *cell = [SystemMessageCell systemMessageCellWithTableView:tableView andIndexPath:indexPath];
    cell.navi = self.navigationController;
    if (self.modelArray.count) {
        self.model = self.modelArray[indexPath.section];
        [cell fillDataWithModel:self.model];
    }
    return cell;
}


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0f;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20.0f;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    self.model = self.modelArray[indexPath.section];
    [MBProgressHUD showMessage:nil toView:self.view];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/messageSystem/deletes",REQUESTHEADER] andParameter:@{@"ids":self.model.messageID} success:^(id successResponse) {
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            
            [self.modelArray removeObjectAtIndex:indexPath.section];//bookInfo为当前table中显示的array
            
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationLeft];
            
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

#pragma mark uialertview

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        
        if (!self.modelArray.count) {
            [MBProgressHUD showError:@"没有可以删除的消息"];
            return;
        }
        
        NSMutableString *str = [[NSMutableString alloc] init];
        
        for (int i = 0; i < self.modelArray.count; i++) {
            self.model = self.modelArray[i];
            [str appendString:[NSString stringWithFormat:@"%@,",self.model.messageID]];
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
