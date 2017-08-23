//
//  newTableView.m
//  LvYue
//
//  Created by X@Han on 17/1/4.
//  Copyright © 2017年 OLFT. All rights reserved.
//


#import "newTableView.h"
#import "LYHttpPoster.h"
#import "MBProgressHUD+NJ.h"
#import "AppointTableCell.h"
#import "appointModel.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "otherZhuYeVC.h"
#import "MJRefresh.h"

@interface newTableView ()<UITableViewDelegate,UITableViewDataSource>{
    UITableView *appointTable;
    
    NSInteger currentPage;                     //当前页数
    NSInteger currentPage2;
    
}

@property(nonatomic,strong)NSMutableArray  *dateTypeArr;   //约会的类型

@end

@implementation newTableView

static int countInt = 0;

//约会吧  下方数据数组
- (NSMutableArray *)dateTypeArr{
    if (!_dateTypeArr) {
        _dateTypeArr = [[NSMutableArray alloc]init];
    }
    return _dateTypeArr;
}

- (NSString *)yueHuiID{
    if (!_yueHuiID) {
        _yueHuiID = [[NSString alloc]init];
    }
    return _yueHuiID;
}
- (id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if (self) {
        currentPage = 1;
        currentPage2 = 1;  //登陆之后的页数
        
        [self getAppointData];
    }
    return self;
}


#pragma mark   -----下方的约的内容
- (void)appointContent{
    appointTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-56) style:UITableViewStylePlain];
    appointTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    appointTable.rowHeight = 607;
    appointTable.delegate = self;
    appointTable.dataSource = self;
    [self addRefresh];
    [self addSubview:appointTable];
    
    
}

- (void)addRefresh{
    // 1.下拉刷新(进入刷新状态就会调用self的headerRereshing)
    appointTable.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefreshing)];
    
    // 2.上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    appointTable.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRefreshing)];
    
  }

#pragma mark   --下拉刷新
- (void)headerRefreshing{
    
    currentPage2 = 1;
    
    MJRefreshStateHeader *header = (MJRefreshStateHeader *) appointTable.mj_header;
    [header setTitle:@"下拉可以刷新" forState:MJRefreshStateIdle];
    [header setTitle:@"松开马上刷新" forState:MJRefreshStatePulling];
    [header setTitle:@"刷新中" forState:MJRefreshStateRefreshing];
    [self getAppointData];
}



#pragma mark   ---上拉刷新
- (void)footerRefreshing{
    
    //[MBProgressHUD showMessage:@"加载中" toView:self];
    
//    NSInteger page = 1;
    currentPage2++;
//    page = currentPage2;
    
//    NSInteger page=currentPage2++;
    //DLK 内存泄漏修改
    NSString *time;
    appointModel *model = self.dateTypeArr[0];
    if (model) {
        time = model.createTime;
    }
    
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/date/getDate",REQUESTHEADER] andParameter:@{@"userId":@"1000006",@"pageNum":[NSString stringWithFormat:@"%d",(int)currentPage2],@"createTime":time} success:^(id successResponse) {
        NSLog(@"上拉刷新%@",successResponse);
        NSLog(@"上拉刷新%@",successResponse[@"errorMsg"]);
         if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
             [MBProgressHUD hideHUD];
             [appointTable reloadData];
             [MBProgressHUD showSuccess:@"已经到底啦"];
             
             
         }
        
    } andFailure:^(id failureResponse) {
       
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"请检查您的网络"];
    }];
}

#pragma mark  -----下方约的数据
- (void)getAppointData{
    if ([self.yueHuiID  isEqualToString:@""]) {
        self.yueHuiID  = @"0";
    }
    NSLog(@"yueHuiID----%@",self.yueHuiID);
//    [LYHttpPoster requestAppointContentDataWithTypeId:self.yueHuiID Block:^(NSArray *arr) {
//        [self.dateTypeArr removeAllObjects];
//        [self.dateTypeArr addObjectsFromArray:arr];
//         [self appointContent];
//        [appointTable.mj_header endRefreshing];
//         [appointTable reloadData];
//    }];
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dateTypeArr.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppointTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[AppointTableCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    
    
    
    appointModel *aModel = self.dateTypeArr[indexPath.row];
    if (aModel) {
        
        
        for (UIView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
            
        }
       
//        [cell createCell:aModel];
//        [cell.otherHomeBtn addTarget:self action:@selector(goOtherHome:) forControlEvents:UIControlEventTouchUpInside];
        //对约会感兴趣
        [cell.intreBtn addTarget:self action:@selector(instred:) forControlEvents:UIControlEventTouchUpInside];
        //聊天
        [cell.chatBtn addTarget:self action:@selector(chat:) forControlEvents:UIControlEventTouchUpInside];
        
    }

    return cell;
}


#pragma mark  ---对约会感兴趣
- (void)instred:(UIButton *)sender{
    
  //  NSString *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userId"];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/date/addInterestDate",REQUESTHEADER] andParameter:@{@"userId":@"1000006",@"dateActivityId":@"1",@"otherUserId":@"1000001"} success:^(id successResponse) {
        
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            [MBProgressHUD showSuccess:@"感兴趣成功"];
        }
        
    } andFailure:^(id failureResponse) {
        
    }];
    
    
    
}

#pragma mark  --聊天
- (void)chat:(UIButton *)sender{
    
    
    
}
//#pragma mark  --进入别人主页
//- (void)goOtherHome:(UIButton *)sender{
//    
//    //otherZhuYeVC *other = [[otherZhuYeVC alloc]init];
//    //  other.userId = [NSString stringWithFormat:@"%ld",sender.tag];    //别人ID
//    [[NSNotificationCenter defaultCenter]postNotificationName:@"push" object:nil userInfo:@{@"push":@"otherHome"}];
//    
//}
#pragma mark   ----------时间戳转换成时间
- (NSString *)transformTime:(NSString *)time{
    
    NSInteger num = [time integerValue]/1000;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    
    NSDate *contime = [NSDate dateWithTimeIntervalSince1970:num];
    NSString *conTimeStr = [formatter stringFromDate:contime];
    
    return conTimeStr;    //2016-11-21-55
    
}



@end
