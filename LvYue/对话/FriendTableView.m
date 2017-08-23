//
//  FriendTableView.m
//  LvYue
//
//  Created by leo on 2016/11/22.
//  Copyright © 2016年 OLFT. All rights reserved.
//
#define WIDTH self.frame.size.width
#define HEIGHT self.frame.size.height
#import "FriendTableView.h"        //好友列表
#import "EaseChineseToPinyin.h"
#import "BuddyCell.h"
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "MyBuddyModel.h"
#import "MBProgressHUD+NJ.h"
#import "FriendModel.h"
#import "friendTableCell.h"
@interface FriendTableView()<UITableViewDelegate,UITableViewDataSource> {
   
    UILabel *promptLabel;  //验证消息的提示消息
    UILabel *promptLabel0;
}
@property (nonatomic, strong) NSMutableArray *sortedContractArray;

@property (nonatomic, strong) NSMutableArray *sectionTitles;    //每个区的名字

@property (nonatomic, strong) NSMutableArray *modelArray; //保存原始的Model数组

@property (retain,nonatomic)  UITableView *tableView;

@end

@implementation FriendTableView



- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
       [self setTable];
        [self addRefresh];
    }
    return self;
}

- (void)setTable {
    _sectionTitles = [NSMutableArray array];
    _modelArray = [NSMutableArray array];
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT) style:UITableViewStylePlain];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
   
    [self addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
}
#pragma mark   -----加载更多的数据
- (void)addRefresh{
    //下拉刷新
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefreshing)];
}
#pragma mark   ----下拉刷新
- (void)headerRefreshing{
     [[NSNotificationCenter defaultCenter] postNotificationName:@"LY_friend" object:nil];
    
    [_tableView.mj_header endRefreshing];
}

- (void)postRequest {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updataRedDotLabel" object:nil];//更新好友两个字边上的红点
    [_modelArray removeAllObjects];
    [_sortedContractArray removeAllObjects];
    
      NSString *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userId"];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/circle/getFriend",REQUESTHEADER] andParameter:@{@"userId":userId} success:^(id successResponse) {
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            MLOG(@"我的好友列表:%@",successResponse);
            NSArray *list = successResponse[@"data"];
            for (NSDictionary *dict in list) {
               FriendModel *model = [[FriendModel alloc]initWithModelDic:dict];
                [_modelArray addObject:model];
                
                [kAppDelegate.dataBaseQueue inDatabase:^(FMDatabase *db) {
                    //如果数据库打开成功
                    if ([kAppDelegate.dataBase open]) {
                       
                        NSString *huanxinUserId = [NSString stringWithFormat:@"qp%@",model.userId];
                        //如果用户模型在本地数据库表中没有，则插入，否则更新
                        NSString *findSql = [NSString stringWithFormat:@"SELECT * FROM '%@' WHERE userID = '%@'",@"Firends",huanxinUserId];
                        FMResultSet *result = [kAppDelegate.dataBase executeQuery:findSql];
                        if ([result resultCount]) { //如果查询结果有数据
                            //更新对应数据
                            NSString *updateSql = [NSString stringWithFormat:@"UPDATE '%@' SET name = '%@',remark = '%@',icon = '%@' WHERE userID = '%@'",@"User",model.userName,model.remark,[NSString stringWithFormat:@"%@%@",IMAGEHEADER,model.userIcon],huanxinUserId];
                            BOOL isSuccess = [kAppDelegate.dataBase executeUpdate:updateSql];
                            if (isSuccess) {
                                MLOG(@"更新数据成功!");
                            } else {
                                MLOG(@"更新数据失败!");
                            }
                        } else { //如果查询结果没有数据
                            //插入相应数据
                            NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO '%@'('%@','%@','%@','%@') VALUES('%@','%@','%@','%@')",@"User",@"userID",@"name",@"remark",@"icon",huanxinUserId,model.userName,model.remark,[NSString stringWithFormat:@"%@%@",IMAGEHEADER,model.userIcon]];
                            BOOL isSuccess = [kAppDelegate.dataBase executeUpdate:insertSql];
                            if (isSuccess) {
                                MLOG(@"插入数据成功!");
                            } else {
                                MLOG(@"插入数据失败!");
                            }
                        }
                        //            }
                        [kAppDelegate.dataBase close];
                    } else {
                        MLOG(@"\n本地数据库更新失败\n");
                    }
                }];

           }
            _sortedContractArray = [self sortDataArray:_modelArray];
            MLOG(@"排好序的model : %@",_sortedContractArray);
            [_tableView reloadData];
        } else {
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
    
    
    
   
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   
     return [_sortedContractArray[section] count];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return  _sortedContractArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    friendTableCell *cell = [friendTableCell buddyCellWithTableView:tableView andIndexPath:indexPath];
    
    if (indexPath.section!=0) {
        if (_sortedContractArray.count) {
            [cell fillDataWithModel:_sortedContractArray[indexPath.section][indexPath.row]];
        }
    }

    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    if ([_sortedContractArray[indexPath.section] count] == 0) {
        return 0;
    } else {
        return 56;
    }
   
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([[_sortedContractArray objectAtIndex:section] count] == 0)
    {
        return 0;
    }
    else{
        return 32;
    }
  
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ([[_sortedContractArray objectAtIndex:section] count] == 0)
    {
        return nil;
    }
    UIView *contentView = [[UIView alloc] init];
    [contentView setBackgroundColor:[UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.0]];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(12, 2, 100, 22)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor colorWithHexString:@"#757575"];
    label.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [label setText:[self.sectionTitles objectAtIndex:(section)]];
    [contentView addSubview:label];
    return contentView;
}


#pragma mark   ----去掉空的section
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    NSMutableArray * existTitles = [NSMutableArray array];
   
    for (int i = 0; i < [self.sectionTitles count]; i++) {
        if ([[_sortedContractArray objectAtIndex:i] count] > 0) {
            [existTitles addObject:[self.sectionTitles objectAtIndex:i]];
        }
    }
    return existTitles;
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
    for (FriendModel *model in dataArray) {
        
        //NSLog(@"88888888888888888model:%@",model.userName);
        
        if (model) {
             NSString *firstLetter = [EaseChineseToPinyin pinyinFromChineseString:model.userName];
            if (firstLetter.length) {
                NSInteger section = [indexCollation sectionForObject:[firstLetter substringToIndex:1] collationStringSelector:@selector(uppercaseString)];
                
                NSMutableArray *array = [sortedArray objectAtIndex:section];
                [array addObject:model];
            }
          
        }
   
    }
  
    //每个section内的数组排序
    for (int i = 0; i < [sortedArray count]; i++) {
        NSArray *array = [[sortedArray objectAtIndex:i] sortedArrayUsingComparator:^NSComparisonResult(FriendModel *obj1, FriendModel *obj2) {
           // NSLog(@"7777777777777777777%@",obj1.userName);
            NSString *firstLetter1 = [EaseChineseToPinyin pinyinFromChineseString:obj1.userName];
            firstLetter1 = [[firstLetter1 substringToIndex:1] uppercaseString];
            
            NSString *firstLetter2 = [EaseChineseToPinyin pinyinFromChineseString:obj2.userName];
            firstLetter2 = [[firstLetter2 substringToIndex:1] uppercaseString];
            
            return [firstLetter1 caseInsensitiveCompare:firstLetter2];
        }];
        
          [sortedArray replaceObjectAtIndex:i withObject:[NSMutableArray arrayWithArray:array]];
    }
 
       return sortedArray;
}






-(void)setModel:(FriendModel *)model{
    _model = model;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    FriendModel *model = _sortedContractArray[indexPath.section][indexPath.row];
    
    //push通知
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"pushToOtherZhuYeVC2" object:nil userInfo:@{@"userID":model.userId,@"userNickName":model.userName}];
    
}

@end
