//
//  WalletDetailViewController.m
//  LvYue
//
//  Created by KFallen on 16/6/29.
//  Copyright © 2016年 OLFT. All rights reserved.
//

/**
 *  钱包明细
 */

#import "WalletDetailViewController.h"
#import "UIView+KFFrame.h"
#import "WalletDetailCell.h"
#import "KFDatePicker.h"
#import "LYUserService.h"
#import "LYHttpPoster.h"
#import "DayWallet.h"

#import "MBProgressHUD+NJ.h"

@interface WalletDetailViewController ()<UITableViewDelegate, UITableViewDataSource, KFDatePickerDelegate>

@property (nonatomic, weak) UIView* headerView;     //头部视图
@property (nonatomic, weak) UIButton* dateBtn;      //日期按钮
@property (nonatomic, weak) UIButton* incomeBtn;    //收入按钮
@property (nonatomic, weak) UIButton* payBtn;       //支出按钮
@property (nonatomic, weak) UIView* lineView;       //白色线条

@property (nonatomic, weak) UITableView* tableView; //数据列表
@property (nonatomic, weak) UIPickerView *pickerView; //时间选择器
@property (nonatomic, strong) NSMutableArray* walletArray; //钱包数据

@property (nonatomic, copy) NSString* walletType;  //收入或支付 1.收入;2.支出
@property (nonatomic, copy) NSString* year;  //年份
@property (nonatomic, copy) NSString* month;  //月份


@end

@implementation WalletDetailViewController
#pragma mark - 懒加载

- (NSMutableArray *)walletArray {
    if (!_walletArray) {
        _walletArray = [NSMutableArray array];
    }
    return _walletArray;
}

static int headViewH = 71;
- (UIView *)headerView {
    if (!_headerView) {
        UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, headViewH)];
        view.backgroundColor = RGBACOLOR(40, 198, 175, 1);
        _headerView = view;
        
        //日期选择
        UIButton* dataBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [dataBtn setBackgroundColor:[UIColor clearColor]];
        dataBtn.height = 25;
        dataBtn.width = 150;
        dataBtn.x = (kMainScreenWidth - dataBtn.width)*0.5;
        dataBtn.y = 5;
        //设置假数据
        NSString* titleStr = [NSString stringWithFormat:@"%@年 %@月",self.year, self.month];
        [dataBtn setTitle:titleStr forState:UIControlStateNormal];
        dataBtn.titleLabel.font = kFont14;
        [dataBtn setImage:[UIImage imageNamed:@"选择时间"] forState:UIControlStateNormal];
        [dataBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 120, 0, 0)];
        [dataBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 20)];
        [dataBtn addTarget:self action:@selector(choseTime:) forControlEvents:UIControlEventTouchUpInside];
        self.dateBtn = dataBtn;
        
        [_headerView addSubview:dataBtn];

        //收入按钮
        UIButton* incomeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [incomeBtn setBackgroundColor:[UIColor clearColor]];
        incomeBtn.height = 30;
        incomeBtn.width = 150;
        incomeBtn.x = (kMainScreenWidth - 2*incomeBtn.width)/3;
        incomeBtn.y = _headerView.height - CGRectGetMaxY(dataBtn.frame) - 5;
        //未选中
        incomeBtn.selected = YES;
        [incomeBtn setTitle:@"收入" forState:UIControlStateNormal];
        incomeBtn.titleLabel.font = kFont14;
        [incomeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [incomeBtn setTitle:@"收入" forState:UIControlStateSelected];
        [incomeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        //添加事件
        [incomeBtn addTarget:self action:@selector(choseView:) forControlEvents:UIControlEventTouchUpInside];
        self.incomeBtn = incomeBtn;
        [_headerView addSubview:incomeBtn];
        
        
        //支出按钮
        UIButton* payBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [payBtn setBackgroundColor:[UIColor clearColor]];
        payBtn.height = incomeBtn.height;
        payBtn.width = incomeBtn.width;
        payBtn.x = (kMainScreenWidth - 2*payBtn.width)/3 + CGRectGetMaxX(incomeBtn.frame);
        payBtn.y = incomeBtn.y;
        //未选中
        payBtn.selected = NO;
        [payBtn setTitle:@"支出" forState:UIControlStateNormal];
        payBtn.titleLabel.font = kFont14;
        [payBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [payBtn setTitle:@"支出" forState:UIControlStateSelected];
        [payBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        //添加事件
        [payBtn addTarget:self action:@selector(choseView:) forControlEvents:UIControlEventTouchUpInside];
        self.payBtn = payBtn;
        self.payBtn.alpha = 0.5;
        [_headerView addSubview:payBtn];

        //白色线条
        UIView* lineView = [[UIView alloc] init];
        lineView.backgroundColor = [UIColor whiteColor];
        lineView.width = 50;
        lineView.height = 2;
        lineView.centerX = incomeBtn.centerX;
        lineView.y = CGRectGetMaxY(incomeBtn.frame);
        [_headerView addSubview:lineView];
        self.lineView = lineView;
        [self.view addSubview:_headerView];
    }
    return _headerView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        UITableView* tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, headViewH, kMainScreenWidth, kMainScreenHeight-headViewH-22) style:UITableViewStyleGrouped];
        tableView.delegate = self;
        tableView.dataSource = self;
        
        _tableView = tableView;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

#pragma mark - 视图加载
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    //去navigation分割线
    // bg.png为自己ps出来的想要的背景颜色。
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigationBar"] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    //translucen透明度，NO不透明，控件的frame从navigationBar的左下角开始算；YES，透明从状态栏开始算。
    self.navigationController.navigationBar.translucent = NO;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setUI];
    [self getWalletData];
}

//设置UI
- (void)setUI {
    self.title = @"钱包明细";
    self.view.backgroundColor = RGBCOLOR(241, 240, 246);
    _walletType = @"1";
    
    //设置初始状态
    NSDate *  currentYear=[NSDate date];
    NSDateFormatter *dateformatterYear=[[NSDateFormatter alloc] init];
    [dateformatterYear setDateFormat:@"YYYY"];
    NSString * yearStr=[dateformatterYear stringFromDate:currentYear];
    self.year = yearStr;
    
    NSDate *  currentMonth=[NSDate date];
    NSDateFormatter *dateformatterMonth=[[NSDateFormatter alloc] init];
    [dateformatterMonth setDateFormat:@"MM"];
    NSString * monthStr=[dateformatterMonth stringFromDate:currentMonth];
    self.month = monthStr;
    
    //设置头部的视图
    self.headerView.hidden = NO;
    
    self.tableView.hidden = NO;

}

#pragma mark - 点击方法
//选择收入或支出
- (void)choseView:(UIButton *)sender {
    self.payBtn.selected = NO;
    self.payBtn.alpha = 1.0f;
    self.incomeBtn.selected = NO;
    self.incomeBtn.alpha = 1.0f;
    if ([sender.titleLabel.text isEqualToString:@"收入"]) {
        self.payBtn.alpha = 0.5;
        self.incomeBtn.selected = YES;
        
        _walletType = @"1";
        //改变frame
        [UIView animateWithDuration:0.2 animations:^{
            self.lineView.centerX =  self.incomeBtn.centerX;
        }];
    }
    else if ([sender.titleLabel.text isEqualToString:@"支出"]) {
        self.payBtn.selected = YES;
        self.incomeBtn.alpha = 0.5;
        _walletType = @"2";
        [UIView animateWithDuration:0.2 animations:^{
            self.lineView.centerX =  self.payBtn.centerX;
        }];
    }
    [self getWalletData];
    //[self.tableView reloadData];
    
}

//选择时间
- (void)choseTime:(UIButton *)sender {
    KFDatePicker* datePicker = [KFDatePicker datePicker];
    
    datePicker.delegate = self;
    //设置标题
    UILabel* titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"   选择时间";
    titleLabel.textColor = THEME_COLOR;
    titleLabel.textAlignment = NSTextAlignmentLeft;
    datePicker.titleLabel = titleLabel;
    
    //设置时间
    datePicker.mode = KFDatePickerModeYearAndMonth;
    
    //设置按钮
    [datePicker initWithCancleBtnTitle:@"取消" cancleColor:[UIColor blackColor] confirmBtnTitle:@"确定" confirmColor:THEME_COLOR];
    
    [datePicker show];
}

#pragma mark - 网络请求
- (void)getWalletData {
    [_walletArray removeAllObjects];
    
    NSString* urlStr = [NSString stringWithFormat:@"%@/mobile/user/getWalletDetails",REQUESTHEADER];
    
    NSDictionary* params = @{
                             @"userId":[LYUserService sharedInstance].userID,
                             @"year":self.year,
                             @"month":self.month,
                             @"type":_walletType
                             };
    
    [LYHttpPoster postHttpRequestByPost:urlStr andParameter:params success:^(id successResponse) {
        MLOG(@"钱包明细:%@",successResponse);
        if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
            NSMutableArray* dictM = successResponse[@"data"][@"details"];
            
            for (NSDictionary* dict in dictM) {
                DayWallet* model = [[DayWallet alloc] initWithDict:dict];
                [self.walletArray addObject:model];
            }
            [_tableView reloadData];
        }
    } andFailure:^(id failureResponse) {
       [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
    
}

#pragma mark - KFDatePickerDelegate
- (void)datePicker:(KFDatePicker *)datePicker didClickButtonIndex:(NSInteger)buttonIndex year:(NSString *)year month:(NSString *)month {
    if (buttonIndex == 0) {
        
    }
    else if (buttonIndex == 1) { //确定
        NSString* titleRow = [NSString stringWithFormat:@"%@年 %@月",year,month];
        [self.dateBtn setTitle:titleRow forState:UIControlStateNormal];
        self.year = year;
        self.month = month;
        
        [self getWalletData];
    }
    [datePicker dismiss];
}


#pragma mark - UITableViewDelegate&UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = 0;
    if (self.incomeBtn.selected == YES) {
        count = _walletArray.count;
    }
    else if (self.incomeBtn.selected == NO) {
        
        count = _walletArray.count;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //创建单元格
    WalletDetailCell* cell = [WalletDetailCell cellWithTableView:tableView indexPath:indexPath];
    
    //获取模型
    [UIImage imageNamed:@"礼物"];
//    NSArray* timeArr;
//    NSArray* iconArr;
//    NSArray* titleArr;
//    NSArray* numArr;
//    if (self.incomeBtn.selected == YES) { //收入
//        timeArr = @[@"05日"];
//        iconArr = @[@"礼物"];
//        titleArr = @[@"收到礼物"];
//        numArr = @[@"+380"];
//
//    }
//    else if (self.incomeBtn.selected == NO) { //支出
//        
//      timeArr = @[@"05日", @"04日", @"04日", @"04日"];
//      iconArr = @[@"礼物", @"会员-0", @"金币", @"提现"];
//      titleArr = @[@"购买礼物", @"购买会员", @"充值金币", @"提现"];
//      numArr = @[@"-380", @"-60", @"-100", @"-500"];
//
//    }
    DayWallet* dayWallet = self.walletArray[indexPath.row];
    cell.dayWallet = dayWallet;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}


@end
