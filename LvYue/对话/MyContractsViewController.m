//
//  MyContractsViewController.m
//  LvYue
//
//  Created by apple on 15/10/1.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import "MyContractsViewController.h"
#import "EaseChineseToPinyin.h"
#import "BuddyCell.h"
#import "SearchNewFriendController.h"
#import "DetailDataViewController.h"
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "MBProgressHUD+NJ.h"
#import "MyBuddyModel.h"

@interface MyContractsViewController ()<UITableViewDataSource,UITableViewDelegate>{
    UILabel *promptLabel;//验证消息的提示消息
    UILabel *promptLabel0;
}

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *sortedContractArray;

@property (nonatomic, strong) NSMutableArray *sectionTitles;

@property (nonatomic, strong) NSMutableArray *modelArray; //保存原始的Model数组

@end

@implementation MyContractsViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _sectionTitles = [NSMutableArray array];
    _modelArray = [NSMutableArray array];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight - 109) style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    
    [self postRequest];
    [self registerAllNotifications];
}


- (void)registerAllNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshBuddyList:) name:@"refreshMyBuddyList" object:nil];
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)postRequest {
    
    [_modelArray removeAllObjects];
    [_sortedContractArray removeAllObjects];
    
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/userFriend/list",REQUESTHEADER] andParameter:@{@"user_id":[LYUserService sharedInstance].userID} success:^(id successResponse) {
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            MLOG(@"我的好友列表:%@",successResponse);
            NSArray *list = successResponse[@"data"][@"list"];
            for (NSDictionary *dict in list) {
                MyBuddyModel *model = [[MyBuddyModel alloc] initWithDict:dict];
                [_modelArray addObject:model];
                [kAppDelegate.dataBaseQueue inDatabase:^(FMDatabase *db) {
                    //矫正本地数据库
                    if ([kAppDelegate.dataBase open]) {
                        //如果用户模型在本地数据库表中没有，则插入，否则更新
                        NSString *findSql = [NSString stringWithFormat:@"SELECT * FROM '%@' WHERE userID = '%@'",@"User",model.buddyID];
                        FMResultSet *result = [kAppDelegate.dataBase executeQuery:findSql];
                        if ([result resultCount]) { //如果查询结果有数据
                            //更新对应数据
                            NSString *updateSql = [NSString stringWithFormat:@"UPDATE '%@' SET name = '%@',remark = '%@',icon = '%@' WHERE userID = '%@'",@"User",model.name,model.remark,model.icon,model.buddyID];
                            BOOL isSuccess = [kAppDelegate.dataBase executeUpdate:updateSql];
                            if (isSuccess) {
                                MLOG(@"更新数据成功!");
                            } else {
                                MLOG(@"更新数据失败!");
                            }
                        } else { //如果查询结果没有数据
                            //插入相应数据
                            NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO '%@'('%@','%@','%@','%@') VALUES('%@','%@','%@','%@')",@"User",@"userID",@"name",@"remark",@"icon",model.buddyID,model.name,model.remark,model.icon];
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
            _sortedContractArray = [self sortDataArray:_modelArray];
            MLOG(@"排好序的model : %@",_sortedContractArray);
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
    
    return _sortedContractArray.count + 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return 2;
    } else {
        return [_sortedContractArray[section - 1] count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BuddyCell *cell = [BuddyCell buddyCellWithTableView:tableView andIndexPath:indexPath];
//    if (indexPath.section == 0 && indexPath.row == 0) {
//        if (!promptLabel) {
//            promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(kMainScreenWidth - 80, 25, 14, 14)];
//            promptLabel.backgroundColor = RGBACOLOR(29, 189, 159, 1.0);
//            promptLabel.layer.cornerRadius = 7.0;
//            promptLabel.clipsToBounds = YES;
//            promptLabel.hidden = YES;
//        }
//        [cell addSubview:promptLabel];
//        
//        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
//        if ([[user objectForKey:kHavePrompt] isEqualToString:@"1"]) {
//            promptLabel.hidden = NO;
//        } else {
//            promptLabel.hidden = YES;
//        }
//        
//        return cell;
//
//    }
    
    if (indexPath.section != 0) {
        if (_sortedContractArray.count) {
            [cell fillDataWithModel:_sortedContractArray[indexPath.section - 1][indexPath.row]];
        }
    }
    
    [cell createPromptLabelWithIndexPath:indexPath];
    //cell.promptLabel.hidden = YES;
    return cell;
}


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 60;
    } else {
        if ([_sortedContractArray[indexPath.section - 1] count] == 0) {
            return 0;
        } else {
            return 60;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0 || [[_sortedContractArray objectAtIndex:section - 1] count] == 0)
    {
        return 0;
    }
    else{
        return 22;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0 || [[_sortedContractArray objectAtIndex:section - 1] count] == 0)
    {
        return nil;
    }
    
    UIView *contentView = [[UIView alloc] init];
    [contentView setBackgroundColor:[UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.0]];
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
        if ([[_sortedContractArray objectAtIndex:i] count] > 0) {
            [existTitles addObject:[self.sectionTitles objectAtIndex:i]];
        }
    }
    return existTitles;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            //发送通知,通知主控制器push到新的朋友界面
            [[NSNotificationCenter defaultCenter] postNotificationName:@"pushToNewFriendController" object:nil];
        } else {
            //发送通知,通知主控制器push到我的群组界面
            [[NSNotificationCenter defaultCenter] postNotificationName:@"pushToMyGroupListController" object:nil];
        }
    } else {
        MyBuddyModel *model = _sortedContractArray[indexPath.section - 1][indexPath.row];
        NSDictionary *infoDict = @{@"userID":model.buddyID};
        //发送通知,通知主控制器push到好友详情界面
        [[NSNotificationCenter defaultCenter] postNotificationName:@"pushToBuddyDetailController" object:nil userInfo:infoDict];
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
    for (MyBuddyModel *model in dataArray) {
        NSString *firstLetter = [EaseChineseToPinyin pinyinFromChineseString:model.remark];
        if (!firstLetter) {
            firstLetter = [EaseChineseToPinyin pinyinFromChineseString:model.name];
        }
        if (firstLetter.length) {
            NSInteger section = [indexCollation sectionForObject:[firstLetter substringToIndex:1] collationStringSelector:@selector(uppercaseString)];
            
            NSMutableArray *array = [sortedArray objectAtIndex:section];
            [array addObject:model];
        }
    }
    
    //每个section内的数组排序
    for (int i = 0; i < [sortedArray count]; i++) {
        NSArray *array = [[sortedArray objectAtIndex:i] sortedArrayUsingComparator:^NSComparisonResult(MyBuddyModel *obj1, MyBuddyModel *obj2) {
            NSString *firstLetter1 = [EaseChineseToPinyin pinyinFromChineseString:obj1.remark];
            firstLetter1 = [[firstLetter1 substringToIndex:1] uppercaseString];
            
            NSString *firstLetter2 = [EaseChineseToPinyin pinyinFromChineseString:obj2.remark];
            firstLetter2 = [[firstLetter2 substringToIndex:1] uppercaseString];
            
            return [firstLetter1 caseInsensitiveCompare:firstLetter2];
        }];
        
        
        [sortedArray replaceObjectAtIndex:i withObject:[NSMutableArray arrayWithArray:array]];
    }
    
    return sortedArray;
}


#pragma mark - 接收外界刷新的通知
- (void)refreshBuddyList:(NSNotification *)aNotification {
    //重新请求
    [self postRequest];
}

@end
