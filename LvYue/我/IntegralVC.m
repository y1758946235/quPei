//
//  IntegralVC.m
//  LvYue
//
//  Created by X@Han on 17/4/10.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "IntegralVC.h"
#import "moneyListVc.h"
#import "WithDrawViewController.h"
#import "WithdrawalRecordVC.h"

#import "IntegralTableViewCell.h"
#import "GoldsRecordModel.h"
@interface IntegralVC ()<UITableViewDelegate,UITableViewDataSource>{
    
    
    NSInteger currentPage;  //当前页数
}
@property(nonatomic,copy)NSMutableArray *dataArr;

@property (nonatomic, strong) UITableView *myTableView;


@end

@implementation IntegralVC
-(UITableView *)myTableView {
    if (!_myTableView) {
        _myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,90, SCREEN_WIDTH, SCREEN_HEIGHT-64-90) style:UITableViewStyleGrouped];
        
        [_myTableView registerClass:[IntegralTableViewCell class] forCellReuseIdentifier:@"IntegralTableViewCell"];
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
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self  setNav];
    [self creatTopViews];
    
    [self.view addSubview:self.myTableView];
    [self getdata];
}
-(void)getdata{
    NSDictionary *dic = @{@"otherUserId":[CommonTool getUserID]};
    [ LYHttpPoster requestGettUserWithdrawalDetailDataWithParameters:dic Block:^(NSArray *arr) {
        [self.dataArr removeAllObjects];
        [self.dataArr addObjectsFromArray:arr];
        
        
        [_myTableView reloadData];
        
        
        
    }];

}
-(void)creatTopViews{
    
    UILabel* goldLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 24, 151, 20)];
    goldLabel.textAlignment = NSTextAlignmentCenter;
    goldLabel.text = [NSString stringWithFormat:@"%@积分",self.apointNum];
    goldLabel.textColor = [UIColor colorWithHexString:@"#424242"];
    goldLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:20];
    [self.view addSubview:goldLabel];
    
    UILabel *giftPriceLabel = [[UILabel alloc]init];
    giftPriceLabel.frame = CGRectMake(0, 54, 151, 20);
    giftPriceLabel.textAlignment = NSTextAlignmentCenter;
    giftPriceLabel.text = @"价值";
    giftPriceLabel.textColor = [UIColor colorWithHexString:@"#424242"];
    giftPriceLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
    [self.view addSubview:giftPriceLabel];
    
    UIImageView *ArrowimageV = [[UIImageView alloc]init];
    ArrowimageV.frame = CGRectMake(SCREEN_WIDTH/2 -16, 20, 32, 24);
    ArrowimageV.image = [UIImage imageNamed:@"arrow_redeem"];
    [self.view addSubview:ArrowimageV];
    
    UILabel *changeLabel = [[UILabel alloc]init];
    changeLabel.frame = CGRectMake(100, 58, SCREEN_WIDTH-200, 12);
    changeLabel.textAlignment = NSTextAlignmentCenter;
    changeLabel.text = @"可兑换";
    changeLabel.textColor = [UIColor colorWithHexString:@"#9e9e9e"];
    changeLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
    [self.view addSubview:changeLabel];
    
   UILabel* moneyLabel = [[UILabel alloc]init];
    moneyLabel.frame = CGRectMake(SCREEN_WIDTH-120, 20, 100, 24);
    moneyLabel.textAlignment = NSTextAlignmentCenter;
    moneyLabel.text = [NSString stringWithFormat:@"%.2f元",[self.apointNum floatValue]/100];
    moneyLabel.textColor = [UIColor colorWithHexString:@"#ff5252"];
    moneyLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:24];
    [self.view addSubview:moneyLabel];
    
    UIButton *withdrawalBtn = [[UIButton alloc]init];
    withdrawalBtn.frame = CGRectMake(SCREEN_WIDTH-110, 52, 81, 25);
    withdrawalBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
    [withdrawalBtn setTitle:@"提取现金" forState:UIControlStateNormal];
    [withdrawalBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    withdrawalBtn.backgroundColor = [UIColor colorWithHexString:@"#ff5252"];
    withdrawalBtn.layer.cornerRadius = 12.5;
    withdrawalBtn.clipsToBounds = YES;
    [withdrawalBtn addTarget:self action:@selector(withdrawalClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:withdrawalBtn];
    
}
-(void)withdrawalClick{
    WithDrawViewController* withDrawVC = [[WithDrawViewController alloc] init];
    withDrawVC.coinNum  = self.apointNum;
    [self.navigationController pushViewController:withDrawVC animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 0.01;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 0.01;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 100;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //     return 4;
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    IntegralTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"IntegralTableViewCell" forIndexPath:indexPath];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    GoldsRecordModel *aModel = self.dataArr[indexPath.row];
    if (aModel) {
      [cell createmodel:aModel];
    }
    
    
    return  cell;
}

#pragma mark   -------配置导航栏
- (void)setNav{
    self.title = @"总积分";
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
    
    //导航栏充值记录按钮
    UIButton *edit = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-16-28, 38, 56, 14)];
    [edit setTitleColor:[UIColor colorWithHexString:@"#424242"] forState:UIControlStateNormal];
    [edit setTitle:@"提现记录" forState:UIControlStateNormal];
    edit.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [edit addTarget:self action:@selector(moneyList) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *edited = [[UIBarButtonItem alloc]initWithCustomView:edit];
    self.navigationItem.rightBarButtonItem = edited;
    
}
#pragma mark  --- 提现记录
- (void)moneyList{
    
    WithdrawalRecordVC *moneyList = [[WithdrawalRecordVC alloc]init];
    [self.navigationController pushViewController:moneyList animated:YES];
    
    
    
}
- (void)goBack{
    
    [self.navigationController popViewControllerAnimated:YES];
}



-(void)vipLevelInfo{
    
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/cache/getVipLevel",REQUESTHEADER] andParameter:nil success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        [MBProgressHUD hideHUD];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            NSArray *arr =successResponse[@"data"];
        } else {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
    
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
