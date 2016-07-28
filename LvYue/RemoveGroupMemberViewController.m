//
//  RemoveGroupMemberViewController.m
//  LvYue
//
//  Created by apple on 15/10/22.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import "RemoveGroupMemberViewController.h"
#import "MBProgressHUD+NJ.h"
#import "UIView+RSAdditions.h"
#import "BuddySelectionCell.h"
#import "EaseChineseToPinyin.h"
#import "UIView+SZYOperation.h"
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "GroupMemberModel.h"
#import "UIImageView+WebCache.h"

@interface RemoveGroupMemberViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UIButton *finishBtn;

@property (nonatomic, strong) UIScrollView *reviewSrc;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *sortedContractArray;

@property (nonatomic, strong) NSMutableArray *sectionTitles;

@property (nonatomic, strong) NSMutableArray *cellArray; //保存cell,确保不会创建新的cell

@property (nonatomic, strong) NSMutableArray *selectCellArray; //被选中的cell数组

@property (nonatomic, strong) NSMutableArray *selectModelArray; //被选中的model数组

@end

@implementation RemoveGroupMemberViewController


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = @"管理群成员";
    _finishBtn = [self setRightButton:nil title:@"踢除" target:self action:@selector(finishCreate:) rect:CGRectMake(0, 0, 70, 44)];
    [_finishBtn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    _finishBtn.titleLabel.textAlignment = NSTextAlignmentRight;
    _finishBtn.enabled = NO;
    
    /****关闭屏幕边缘化****/
    self.modalPresentationCapturesStatusBarAppearance = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //初始化cellArray
    _cellArray = [NSMutableArray array];
    for (int i = 0; i < 27; i ++) {
        NSMutableArray *array = [NSMutableArray array];
        [_cellArray addObject:array];
    }
    
    _sectionTitles = [NSMutableArray array];
    _selectCellArray = [NSMutableArray array];
    _selectModelArray = [NSMutableArray array];
    _sortedContractArray = [self sortDataArray:_members];
    
    UIView *review = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 60)];
    review.backgroundColor = [UIColor clearColor];
    [self.view addSubview:review];
    _reviewSrc = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 60)];
    _reviewSrc.alwaysBounceVertical = NO;
    _reviewSrc.alwaysBounceHorizontal = NO;
    _reviewSrc.directionalLockEnabled = YES;
    _reviewSrc.showsHorizontalScrollIndicator = YES;
    _reviewSrc.showsVerticalScrollIndicator = YES;
    _reviewSrc.backgroundColor = [UIColor whiteColor];
    [review addSubview:_reviewSrc];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, review.bottom, kMainScreenWidth, kMainScreenHeight - _reviewSrc.bottom - 64) style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
}


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return _sortedContractArray.count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [_sortedContractArray[section] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BuddySelectionCell *cell;
    if ([_cellArray[indexPath.section] count] > indexPath.row) {
        cell = (BuddySelectionCell *)_cellArray[indexPath.section][indexPath.row];
    } else {
        cell = [BuddySelectionCell buddySelectionCellWithTableView:tableView];
        [_cellArray[indexPath.section] addObject:cell];
        GroupMemberModel *model = _sortedContractArray[indexPath.section][indexPath.row];
        [cell.iconView sd_setImageWithURL:[NSURL URLWithString:model.icon]];
        cell.nameLabel.text = model.name;
    }
    return cell;
}


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_sortedContractArray[indexPath.section] count] == 0) {
        return 0;
    } else {
        return 60;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([[_sortedContractArray objectAtIndex:section] count] == 0)
    {
        return 0;
    }
    else{
        return 22;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ([[_sortedContractArray objectAtIndex:section] count] == 0)
    {
        return nil;
    }
    
    UIView *contentView = [[UIView alloc] init];
    [contentView setBackgroundColor:[UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:1.0]];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 22)];
    label.backgroundColor = [UIColor clearColor];
    [label setText:[self.sectionTitles objectAtIndex:(section)]];
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BuddySelectionCell *cell = _cellArray[indexPath.section][indexPath.row];
    GroupMemberModel *model = _sortedContractArray[indexPath.section][indexPath.row];
    if (cell.selectView.image) {
        cell.selectView.image = nil;
        [_selectCellArray removeObject:cell];
        [_selectModelArray removeObject:model];
        [self layoutIcons];
        if (_selectCellArray.count == 0) {
            [_finishBtn setTitle:[NSString stringWithFormat:@"踢除"] forState:UIControlStateNormal];
            _finishBtn.enabled = NO;
        } else {
            [_finishBtn setTitle:[NSString stringWithFormat:@"踢除(%lu)",(unsigned long)_selectCellArray.count] forState:UIControlStateNormal];
            _finishBtn.enabled = YES;
        }
    } else {
        cell.selectView.image = [UIImage imageNamed:@"Selected"];
        [_selectCellArray addObject:cell];
        [_selectModelArray addObject:model];
        [self layoutIcons];
        [_finishBtn setTitle:[NSString stringWithFormat:@"踢除(%lu)",(unsigned long)_selectCellArray.count] forState:UIControlStateNormal];
        _finishBtn.enabled = YES;
    }
}


#pragma mark - private
//拼音排序
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
    for (GroupMemberModel *model in dataArray) {
        NSString *firstLetter = [EaseChineseToPinyin pinyinFromChineseString:model.name];
        NSInteger section = [indexCollation sectionForObject:[firstLetter substringToIndex:1] collationStringSelector:@selector(uppercaseString)];
        
        NSMutableArray *array = [sortedArray objectAtIndex:section];
        [array addObject:model];
    }
    
    //每个section内的数组排序
    for (int i = 0; i < [sortedArray count]; i++) {
        NSArray *array = [[sortedArray objectAtIndex:i] sortedArrayUsingComparator:^NSComparisonResult(GroupMemberModel *obj1, GroupMemberModel *obj2) {
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


//排列成员的预览头像
- (void)layoutIcons {
    //先清除所有子控件
    [_reviewSrc removeAllSubViews];
    
    int count = (int)_selectCellArray.count;
    CGFloat size = 44.0;
    CGFloat margin = 15.0;
    for (int i = 0; i < count; i ++) {
        BuddySelectionCell *cell = _selectCellArray[i];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:cell.iconView.image];
        imageView.frame = CGRectMake((i+1)*margin + i*size, 8, size, size);
        imageView.layer.cornerRadius = 22.0;
        imageView.clipsToBounds = YES;
        [_reviewSrc addSubview:imageView];
    }
    _reviewSrc.contentSize = CGSizeMake((count+1)*margin + count*size, 0);
}


#pragma mark - 监听点击"踢除"按钮
- (void)finishCreate:(UIButton *)sender {
    
    //拼凑多个踢除对象的id_string
    NSMutableString *idString = [NSMutableString string];
    for (GroupMemberModel *model in _selectModelArray) {
        [idString appendString:[NSString stringWithFormat:@"%@,",model.memberID]];
    }
    NSString *finalString = [idString substringToIndex:[idString length] - 1];
    
    //发送踢除成员请求
    [MBProgressHUD showMessage:@"踢除中.."];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/group/deleteMember",REQUESTHEADER] andParameter:@{@"group_id":_groupID,@"user_id":finalString} success:^(id successResponse) {
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showSuccess:@"踢除成功"];
            [self.navigationController popToRootViewControllerAnimated:YES];
        } else {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
}


@end
