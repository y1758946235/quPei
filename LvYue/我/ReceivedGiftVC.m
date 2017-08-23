//
//  ReceivedGiftVC.m
//  LvYue
//
//  Created by X@Han on 17/3/21.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "ReceivedGiftVC.h"
#import "moneyListVc.h"
#import "ReceGiftTableViewCell.h"
#import "ReceiveGiftModel.h"
#import "WithDrawViewController.h"
@interface ReceivedGiftVC ()<UITableViewDataSource,UITableViewDelegate>{
   
    
    UILabel *goldLabel;
    UILabel *moneyLabel;
    NSInteger currentPage2;
    CGFloat WithdrawalFee;
}
@property (nonatomic, strong) UITableView *myTableView;
@property (nonatomic,strong) NSMutableArray  *giftDataArr;
@end

@implementation ReceivedGiftVC
-(UITableView*)myTableView{
    if (!_myTableView) {
        _myTableView  = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kMainScreenWidth, SCREEN_HEIGHT-64) style:UITableViewStyleGrouped];
        _myTableView.backgroundColor = [UIColor whiteColor];
        _myTableView.dataSource = self;
        _myTableView.delegate = self;
        _myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//        _myTableView.decelerationRate = 0.1f;
        
        
        [_myTableView registerClass:[ReceGiftTableViewCell class] forCellReuseIdentifier:@"ReceGiftTableViewCell"];
      
       
    }
    return _myTableView;
}
-(NSMutableArray*)giftDataArr{
    if (!_giftDataArr) {
        
        _giftDataArr = [[NSMutableArray alloc]init];
    }
    return _giftDataArr;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //http://blog.csdn.net/mayerlucky/article/details/50699975  iOS7后 导航栏中的 translucent 导致的视图frame的变化
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationController.navigationBar.translucent = YES;
   
    [self setNav];
    
    [self.view addSubview:self.myTableView];
    [self getWithdrawalFee];
     [self addRefresh];
}
-(void)getWithdrawalFee{
        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/cache/getWithdrawalFee",REQUESTHEADER] andParameter:nil success:^(id successResponse) {
    
            if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
                WithdrawalFee =[successResponse[@"data"] doubleValue];
                currentPage2 = 1;
                [self getData];
             } else {
                [MBProgressHUD hideHUD];
                [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
            }
        } andFailure:^(id failureResponse) {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"服务器繁忙,请重试"];
        }];
}
-(void)getData{
    currentPage2 = 1;
   NSDictionary *dic = @{@"otherUserId":self.userId,@"pageNum":[NSString stringWithFormat:@"%ld",(long)currentPage2]};
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/order/getOrderGift",REQUESTHEADER]  andParameter:dic success:^(id successResponse) {
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            [self.giftDataArr removeAllObjects];
            
            NSArray *listArr = successResponse[@"data"][@"giftList"];
           
            if (listArr) {
                for (NSDictionary *dic in listArr) {
                    ReceiveGiftModel *model = [ReceiveGiftModel createWithModelDic:dic];
                    [self.giftDataArr addObject:model];
                }
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
- (void)addRefresh{
    currentPage2 = 1;
    // 1.下拉刷新(进入刷新状态就会调用self的headerRereshing)
    _myTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefreshing)];
    
    // 2.上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    _myTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRefreshing)];
    
}

#pragma mark   --下拉刷新
- (void)headerRefreshing{
    
    
    
    MJRefreshStateHeader *header = (MJRefreshStateHeader *) _myTableView.mj_header;
    [header setTitle:@"下拉可以刷新" forState:MJRefreshStateIdle];
    [header setTitle:@"松开马上刷新" forState:MJRefreshStatePulling];
    [header setTitle:@"刷新中" forState:MJRefreshStateRefreshing];
    [self getWithdrawalFee];
    [_myTableView.mj_header endRefreshing];
}





#pragma mark   ---上拉刷新
- (void)footerRefreshing{
    
    
    currentPage2++;
    
    NSDictionary *dic = @{@"otherUserId":self.userId,@"pageNum":[NSString stringWithFormat:@"%ld",(long)currentPage2]};
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/order/getOrderGift",REQUESTHEADER]  andParameter:dic success:^(id successResponse) {
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            NSArray *listArr = successResponse[@"data"][@"list"];
            for (NSDictionary *dic in listArr) {
                ReceiveGiftModel *model = [ReceiveGiftModel createWithModelDic:dic];
                [self.giftDataArr addObject:model];
            }
            if (!listArr || listArr.count == 0 ) {
                [MBProgressHUD showSuccess:@"已经到底啦"];
                currentPage2 --;
            }
             [_myTableView reloadData];
            
        } else {
            currentPage2 --;
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
        }
        
    } andFailure:^(id failureResponse) {
        currentPage2 --;
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
        
    }];

    
    [_myTableView.mj_footer endRefreshing];
}








- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
  
    return self.giftDataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ReceGiftTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"ReceGiftTableViewCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //    [self configureCell:cell atIndexPath:indexPath];
    cell.preservesSuperviewLayoutMargins = NO;
    cell.separatorInset = UIEdgeInsetsZero;
    cell.layoutMargins = UIEdgeInsetsZero;
      ReceiveGiftModel *aModel = self.giftDataArr[indexPath.row];
    if (aModel) {
       
        
//        for (UIView *view in cell.contentView.subviews) {
//            [view removeFromSuperview];
//            
//        }
      
        cell.model = aModel;
//        NSString  * price =[NSString stringWithFormat:@"%.3f元",[aModel.goldPrice integerValue]/100 *WithdrawalFee]  ;
//        cell.giftMoneyLabel.text = price ;

        
    }
    
    
    //self.height = cell.height;
    return  cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 98;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
     return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
     return 1;
}
#pragma mark   -------配置导航栏
- (void)setNav{
    self.title = @"收到的礼物";
    self.view.backgroundColor = [UIColor whiteColor];
    //导航栏title的颜色
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithHexString:@"#424242"],UITextAttributeTextColor, [UIFont fontWithName:@"PingFangSC-Medium" size:18],UITextAttributeFont, nil]];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:@"#ffffff"];
    //导航栏返回按钮
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(16, 38, 28, 14)];
    [button setTitleColor:[UIColor colorWithHexString:@"#424242"] forState:UIControlStateNormal];
    [button setTitle:@"返回" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [button addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = back;
    
//    //导航栏充值记录按钮
//    UIButton *edit = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-16-28, 38, 56, 14)];
//    [edit setTitleColor:[UIColor colorWithHexString:@"#424242"] forState:UIControlStateNormal];
//    [edit setTitle:@"提现记录" forState:UIControlStateNormal];
//    edit.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
//    [edit addTarget:self action:@selector(moneyList) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *edited = [[UIBarButtonItem alloc]initWithCustomView:edit];
//    self.navigationItem.rightBarButtonItem = edited;
    
}
#pragma mark  --- 充值记录
- (void)moneyList{
    
    moneyListVc *moneyList = [[moneyListVc alloc]init];
    [self.navigationController pushViewController:moneyList animated:YES];
    
    
    
}

- (void)goBack{
    
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
