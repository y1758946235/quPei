//
//  StartDateViewController.m
//  澜庭
//
//  Created by 广有射怪鸟事 on 15/9/24.
//  Copyright (c) 2015年 刘瀚韬. All rights reserved.
//

#import "StartDateViewController.h"
#import "StartDateTableViewCell.h"
#import "DateListViewController.h"

@interface StartDateViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) NSArray *imaArray;
@property (nonatomic,strong) NSArray *titleArray;
@property (nonatomic,strong) NSString *type;//类型，1为深度豆客，2为乡村游，3为出境游，4为本地游

@end

@implementation StartDateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"发起豆客";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.imaArray = @[@"远方.jpg",@"本地.jpg",@"结伴.jpg",@"健身.jpg",@"其他.jpg"];
    
#ifdef kEasyVersion
    
    self.titleArray = @[@"旅行",@"出境搭伴",@"乡村旅行",@"郊游",@"其它"];
    
#else
    
    self.titleArray = @[@"旅行",@"本地活动",@"娱乐搭伴",@"健身搭伴",@"其它"];
    
#endif
    
    [self createTableView];
}

//创建tableview
- (void)createTableView{
    UITableView *table = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    table.delegate = self;
    table.dataSource = self;
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:table];
}

#pragma mark tableview代理方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *myId = @"StartDateTableViewCell";
    StartDateTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myId];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:myId owner:nil options:nil] lastObject];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.dateHeadImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",self.imaArray[indexPath.row]]];
    cell.dateTitleLabel.text = self.titleArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DateListViewController *date = [[DateListViewController alloc] init];
    date.dateType = [NSString stringWithFormat:@"%ld",indexPath.row + 1];
    date.title = self.titleArray[indexPath.row];
    [self.navigationController pushViewController:date animated:YES];
}

@end
