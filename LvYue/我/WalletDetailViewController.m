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

@interface WalletDetailViewController ()<UITableViewDelegate, UITableViewDataSource, KFDatePickerDelegate>

@property (nonatomic, weak) UIView* headerView;     //头部视图
@property (nonatomic, weak) UIButton* dateBtn;      //日期按钮
@property (nonatomic, weak) UIButton* incomeBtn;    //收入按钮
@property (nonatomic, weak) UIButton* payBtn;       //支出按钮
@property (nonatomic, weak) UIView* lineView;       //白色线条

@property (nonatomic, weak) UITableView* tableView; //数据列表


@property (nonatomic, weak) UIPickerView *pickerView;



@end

@implementation WalletDetailViewController




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
        [dataBtn setTitle:@"2016年02月" forState:UIControlStateNormal];
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
        [incomeBtn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
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
        [payBtn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
        //添加事件
        [payBtn addTarget:self action:@selector(choseView:) forControlEvents:UIControlEventTouchUpInside];
        self.payBtn = payBtn;
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
        UITableView* tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, headViewH, kMainScreenWidth, kMainScreenHeight) style:UITableViewStyleGrouped];
        tableView.delegate = self;
        tableView.dataSource = self;
        
        _tableView = tableView;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

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
}

//设置UI
- (void)setUI {
    self.title = @"钱包明细";
    self.view.backgroundColor = RGBCOLOR(241, 240, 246);
    
    //设置头部的视图
    self.headerView.hidden = NO;
    
    self.tableView.hidden = NO;
    
    

    
}


//选择收入或支出
- (void)choseView:(UIButton *)sender {
    self.payBtn.selected = NO;
    self.incomeBtn.selected = NO;
    if ([sender.titleLabel.text isEqualToString:@"收入"]) {
        self.incomeBtn.selected = YES;
        //改变frame
        [UIView animateWithDuration:0.2 animations:^{
            self.lineView.centerX =  self.incomeBtn.centerX;
        }];
    }
    else if ([sender.titleLabel.text isEqualToString:@"支出"]) {
        self.payBtn.selected = YES;
        [UIView animateWithDuration:0.2 animations:^{
            self.lineView.centerX =  self.payBtn.centerX;
        }];
    }
    [self.tableView reloadData];
    
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

#pragma amrk - KFDatePickerDelegate
- (void)datePicker:(KFDatePicker *)datePicker didClickButtonIndex:(NSInteger)buttonIndex titleRow:(NSString *)titleRow {
    if (buttonIndex == 0) {
    }
    else if (buttonIndex == 1) { //确定
        [self.dateBtn setTitle:titleRow forState:UIControlStateNormal];
        
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
        count = 1;
    }
    else if (self.incomeBtn.selected == NO) {
        
        count = 4;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //创建单元格
    WalletDetailCell* cell = [WalletDetailCell cellWithTableView:tableView indexPath:indexPath];
    
    //获取模型
    [UIImage imageNamed:@"礼物"];
    NSArray* timeArr;
    NSArray* iconArr;
    NSArray* titleArr;
    NSArray* numArr;
    if (self.incomeBtn.selected == YES) {
        timeArr = @[@"05日"];
        iconArr = @[@"礼物"];
        titleArr = @[@"收到礼物"];
        numArr = @[@"+380"];

    }
    else if (self.incomeBtn.selected == NO) {
        
      timeArr = @[@"05日", @"04日", @"04日", @"04日"];
      iconArr = @[@"礼物", @"会员-0", @"金币", @"提现"];
      titleArr = @[@"购买礼物", @"购买会员", @"充值金币", @"提现"];
      numArr = @[@"-380", @"-60", @"-100", @"-500"];

    }
    
    cell.timeLabel.text = timeArr[indexPath.row];
    cell.iconImgView.image = [UIImage imageNamed:iconArr[indexPath.row]];
    cell.titleLabel.text = titleArr[indexPath.row];
    cell.moneyLabel.text = numArr[indexPath.row];
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
