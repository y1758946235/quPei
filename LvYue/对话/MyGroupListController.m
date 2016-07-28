//
//  MyGroupListController.m
//  LvYue
//
//  Created by apple on 15/10/9.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import "MyGroupListController.h"
#import "EaseChineseToPinyin.h"
#import "MyGroupCell.h"
#import "CreateGroupViewController.h"
#import "SearchNewGroupController.h"
#import "MBProgressHUD+NJ.h"
#import "LYUserService.h"
#import "LYHttpPoster.h"
#import "GroupModel.h"
#import "ChatViewController.h"

@interface MyGroupListController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *modelArray;

@property (nonatomic, strong) NSMutableArray *sortedGroupArray;

@property (nonatomic, strong) NSMutableArray *sectionTitles;

@end

@implementation MyGroupListController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = @"我的群组";
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _modelArray = [NSMutableArray array];
    _sectionTitles = [NSMutableArray array];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight) style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    
    [self postRequest];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadMyGroupList:) name:@"reloadMyGroupList" object:nil];
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)postRequest {
    [_modelArray removeAllObjects];
    [_sortedGroupArray removeAllObjects];
    
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/group/list",REQUESTHEADER] andParameter:@{@"user_id":[LYUserService sharedInstance].userID} success:^(id successResponse) {
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            MLOG(@"我的群组列表:%@",successResponse);
            NSArray *list = successResponse[@"data"][@"list"];
            for (NSDictionary *dict in list) {
                GroupModel *model = [[GroupModel alloc] initWithDict:dict];
                [_modelArray addObject:model];
                [kAppDelegate.dataBaseQueue inDatabase:^(FMDatabase *db) {
                    //校正本地数据库
                    if ([kAppDelegate.dataBase open]) {
                        NSString *findSql = [NSString stringWithFormat:@"SELECT * FROM '%@' WHERE easemob_id = '%@'",@"Group",model.easeMob_id];
                        FMResultSet *result = [kAppDelegate.dataBase executeQuery:findSql];
                        if ([result resultCount]) { //如果查询结果有数据
                            //更新对应数据
                            NSString *updateSql = [NSString stringWithFormat:@"UPDATE '%@' SET groupID = '%@',name = '%@',desc = '%@',icon = '%@' WHERE easemob_id = '%@'",@"Group",model.groupID,model.name,model.desc,model.icon,model.easeMob_id];
                            BOOL isSuccess = [kAppDelegate.dataBase executeUpdate:updateSql];
                            if (isSuccess) {
                                MLOG(@"更新数据成功!");
                            } else {
                                MLOG(@"更新数据失败!");
                            }
                        } else { //如果查询结果没有数据
                            //插入相应数据
                            NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO '%@'('%@','%@','%@','%@','%@') VALUES('%@','%@','%@','%@','%@')",@"Group",@"groupID",@"easemob_id",@"name",@"desc",@"icon",model.groupID,model.easeMob_id,model.name,model.desc,model.icon];
                            BOOL isSuccess = [kAppDelegate.dataBase executeUpdate:insertSql];
                            if (isSuccess) {
                                MLOG(@"插入数据成功!");
                            } else {
                                MLOG(@"插入数据失败!");
                            }
                        }
                        [kAppDelegate.dataBase close];
                    }
                }];
            }
            _sortedGroupArray = [self sortDataArray:_modelArray];
            [_tableView reloadData];
        } else {
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
}


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return _sortedGroupArray.count + 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return 2;
    } else {
        return [_sortedGroupArray[section - 1] count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MyGroupCell *cell = [MyGroupCell myGroupCellWithTableView:tableView andIndexPath:indexPath];
    if (indexPath.section != 0) {
        if (_modelArray.count) {
            GroupModel *model = _sortedGroupArray[indexPath.section - 1][indexPath.row];
            [cell fillDataWithModel:model];
        }
    }
    return cell;
}


#pragma mark - UITableViewDelegatex
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 60;
    } else {
        if ([_sortedGroupArray[indexPath.section - 1] count] == 0) {
            return 0;
        } else {
            return 60;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0 || [[_sortedGroupArray objectAtIndex:section - 1] count] == 0)
    {
        return 0;
    }
    else{
        return 22;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0 || [[_sortedGroupArray objectAtIndex:section - 1] count] == 0)
    {
        return nil;
    }
    
    UIView *contentView = [[UIView alloc] init];
    [contentView setBackgroundColor:[UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:1.0]];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 22)];
    label.backgroundColor = [UIColor clearColor];
    [label setText:[self.sectionTitles objectAtIndex:(section - 1)]];
    [contentView addSubview:label];
    return contentView;
}


- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    NSMutableArray * existTitles = [NSMutableArray array];
    //section数组为空的title过滤掉，不显示
    for (int i = 0; i < [self.sectionTitles count]; i++) {
        if ([[_sortedGroupArray objectAtIndex:i] count] > 0) {
            [existTitles addObject:[self.sectionTitles objectAtIndex:i]];
        }
    }
    return existTitles;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            //push到搜索群组界面
            [self.navigationController pushViewController:[[SearchNewGroupController alloc] init] animated:YES];
        } else {
            //push到创建群组界面
            [self.navigationController pushViewController:[[CreateGroupViewController alloc] init] animated:YES];
        }
    } else {
        GroupModel *model = _sortedGroupArray[indexPath.section - 1][indexPath.row];
        ChatViewController *chatVc = [[ChatViewController alloc] initWithChatter:model.easeMob_id isGroup:YES];
        MLOG(@"\n\n\n%@\n\n\n",model.groupID);
        chatVc.groupID = model.groupID;
        chatVc.title = model.name;
        [self.navigationController pushViewController:chatVc animated:YES];
    }
}


#pragma mark - private
- (NSMutableArray *)sortDataArray:(NSArray *)dataArray
{
    //建立索引的核心
    UILocalizedIndexedCollation *indexCollation = [UILocalizedIndexedCollation currentCollation];
    
    [self.sectionTitles removeAllObjects];
    [self.sectionTitles addObjectsFromArray:[indexCollation sectionTitles]];
    
    //返回27，是a－z和＃
    NSInteger highSection = [self.sectionTitles count];
    //tableView 会被分成27个section
    NSMutableArray *sortedArray = [NSMutableArray arrayWithCapacity:highSection];
    for (int i = 0; i <= highSection; i++) {
        NSMutableArray *sectionArray = [NSMutableArray arrayWithCapacity:1];
        [sortedArray addObject:sectionArray];
    }
    
    //名字分section
    for (GroupModel *model in dataArray) {
        NSString *firstLetter = [EaseChineseToPinyin pinyinFromChineseString:model.name];
        NSInteger section = [indexCollation sectionForObject:[firstLetter substringToIndex:1] collationStringSelector:@selector(uppercaseString)];
        
        NSMutableArray *array = [sortedArray objectAtIndex:section];
        [array addObject:model];
    }
    
    //每个section内的数组排序
    for (int i = 0; i < [sortedArray count]; i++) {
        NSArray *array = [[sortedArray objectAtIndex:i] sortedArrayUsingComparator:^NSComparisonResult(GroupModel *obj1, GroupModel *obj2) {
            NSString *firstLetter1 = [EaseChineseToPinyin pinyinFromChineseString:obj1.name];
            firstLetter1 = [[firstLetter1 substringToIndex:1] uppercaseString];
            
            NSString *firstLetter2 = [EaseChineseToPinyin pinyinFromChineseString:obj2.name];
            firstLetter2 = [[firstLetter2 substringToIndex:1] uppercaseString];
            
            return [firstLetter1 caseInsensitiveCompare:firstLetter2];
        }];
        
        [sortedArray replaceObjectAtIndex:i withObject:[NSMutableArray arrayWithArray:array]];
    }
    
    return sortedArray;

}


#pragma mark - 重载群组列表
- (void)reloadMyGroupList:(NSNotification *)aNotification {
    [self postRequest];
}


@end
