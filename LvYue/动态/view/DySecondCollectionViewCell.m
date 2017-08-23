//
//  DySecondCollectionViewCell.m
//  LvYue
//
//  Created by X@Han on 17/5/22.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "DySecondCollectionViewCell.h"

#import "DynamicTableViewCell.h"
#import "DynamicListModel.h"
@interface DySecondCollectionViewCell ()<UITableViewDelegate,UITableViewDataSource>{
   
    
    NSInteger currentPage;  //当前页数
    
   
    
}

@property(nonatomic,copy)NSMutableArray *dataArr;

@property (nonatomic, strong) UITableView *myTableView;
@end
@implementation DySecondCollectionViewCell

-(UITableView *)myTableView {
    if (!_myTableView) {
        _myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,0, SCREEN_WIDTH, SCREEN_HEIGHT-50-30-49) style:UITableViewStyleGrouped];
       
        [_myTableView registerClass:[DynamicTableViewCell class] forCellReuseIdentifier:@"DynamicTableViewCell"];
        _myTableView.delegate = self;
        _myTableView.dataSource = self;
        _myTableView.backgroundColor = RGBA(246, 246, 247, 1);
        
    }
    
    return _myTableView;
}
- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [[NSMutableArray alloc]init];
    }
    
    return _dataArr;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        currentPage = 1;
        self.contentView.backgroundColor = [UIColor colorWithHexString:@"#ffffff"];
        [self.contentView addSubview:self.myTableView];
        [self getdata];
        [self addRefresh];
    }
    return self;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 0.01;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 0.01;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//     return 4;
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DynamicTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"DynamicTableViewCell" forIndexPath:indexPath];
   
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    DynamicListModel *aModel = self.dataArr[indexPath.row];
    if (aModel) {
        
        
      
        
        [cell creatModel:aModel];
    }
    
    
    
    return  cell;
}
//设置cell的高度
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    DynamicListModel *model = [self.dataArr objectAtIndex:indexPath.row];
    return 80 +32 +model.contLabelHeight +model.showImageVheight;
//    return 50;
}
#pragma mark   -----加载更多的数据
- (void)addRefresh{
    
    
    
    
    //下拉刷新
    _myTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefreshing)];
    
    
        //上拉加载更多
    
        _myTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRefreshing)];
    
}
#pragma mark   ----下拉刷新
- (void)headerRefreshing{
    MJRefreshStateHeader *header = (MJRefreshStateHeader *) _myTableView.mj_header;
    [header setTitle:@"下拉可以刷新" forState:MJRefreshStateIdle];
    [header setTitle:@"松开马上刷新" forState:MJRefreshStatePulling];
    [header setTitle:@"刷新中" forState:MJRefreshStateRefreshing];
    
    currentPage = 1;
    
    [self  getdata];
    
    [_myTableView.mj_header endRefreshing];
}
-(void)getdata{
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/share/getUserShare",REQUESTHEADER] andParameter:@{@"pageNum":@"1",@"shareType":@"1",@"shareLongitude":@"0",@"shareLatitude":@"0"} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        [MBProgressHUD hideHUD];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            [self.dataArr removeAllObjects];
            NSArray *arr =successResponse[@"data"];
            for (NSDictionary * dic in arr) {
                DynamicListModel *model =[DynamicListModel createWithModelDic:dic];
                [self.dataArr addObject:model];
            }
            [_myTableView reloadData];
            
        } else {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
    
}
#pragma mark   ---上拉刷新
- (void)footerRefreshing{
    currentPage++;
    
    [self  loadMoerdata];
    [_myTableView.mj_footer endRefreshing];
}
-(void)loadMoerdata{
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/share/getUserShare",REQUESTHEADER] andParameter:@{@"pageNum":[NSString  stringWithFormat:@"%ld",(long)currentPage],@"shareType":@"1",@"shareLongitude":@"0",@"shareLatitude":@"0"} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        [MBProgressHUD hideHUD];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            NSArray *arr =successResponse[@"data"];
            for (NSDictionary * dic in arr) {
                DynamicListModel *model =[DynamicListModel createWithModelDic:dic];
                [self.dataArr addObject:model];
            }
            
            if (arr.count == 0) {
                currentPage --;
                [MBProgressHUD showSuccess:@"已经到底啦"];
            }
            [_myTableView reloadData];
            
        } else {
            currentPage --;
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
        }
    } andFailure:^(id failureResponse) {
         currentPage --;
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
    
}
@end
