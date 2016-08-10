//
//  LYMyGiftViewController.m
//  LvYue
//
//  Created by KentonYu on 16/8/1.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "LYDetailDataViewController.h"
#import "LYHttpPoster.h"
#import "LYMyGiftTableViewCell.h"
#import "LYMyGiftViewController.h"
#import "LYUserService.h"
#import "MBProgressHUD+NJ.h"

static NSString *const LYMyGiftTableViewCellIdentity = @"LYMyGiftTableViewCellIdentity";

@interface LYMyGiftViewController () <
    UITableViewDelegate,
    UITableViewDataSource>

@property (nonatomic, assign) LYMyGiftViewControllerType selectedType;
@property (nonatomic, strong) NSArray<NSDictionary *> *tableViewDataArray;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navBottomLineLeading;
@property (weak, nonatomic) IBOutlet UIView *navBottomLineView;

@property (weak, nonatomic) IBOutlet UILabel *wealthLabel;
@property (weak, nonatomic) IBOutlet UILabel *meiliLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation LYMyGiftViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //去navigation分割线
    // bg.png为自己ps出来的想要的背景颜色。
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigationBar"] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    //translucen透明度，NO不透明，控件的frame从navigationBar的左下角开始算；YES，透明从状态栏开始算。
    self.navigationController.navigationBar.translucent = NO;

    self.title = @"我的礼物";

    [self.tableView registerNib:[UINib nibWithNibName:@"LYMyGiftTableViewCell" bundle:nil] forCellReuseIdentifier:LYMyGiftTableViewCellIdentity];
    self.tableView.delegate   = self;
    self.tableView.dataSource = self;

    self.wealthLabel.text = self.wealth;
    self.meiliLabel.text  = self.meiLiZhi;

    [self p_loadData];
}

// 我收到的
- (IBAction)clickMyGiftButton:(id)sender {
    self.selectedType = LYMyGiftViewControllerTypeFetch;
    [self p_loadData];
    self.navBottomLineLeading.constant = 0;

    [UIView animateWithDuration:1.f animations:^{
        [self.navBottomLineView layoutIfNeeded];
    }];
}

// 我送出的
- (IBAction)clickSendButton:(id)sender {
    self.selectedType = LYMyGiftViewControllerTypeSend;
    [self p_loadData];
    self.navBottomLineLeading.constant = SCREEN_WIDTH / 2.f;

    [UIView animateWithDuration:1.f animations:^{
        [self.navBottomLineView layoutIfNeeded];
    }];
}

#pragma mark TableView DataSource & Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableViewDataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100.f;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LYMyGiftTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LYMyGiftTableViewCellIdentity forIndexPath:indexPath];
    cell.type                   = self.selectedType;
    [cell configData:self.tableViewDataArray[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    LYDetailDataViewController *vc = [[LYDetailDataViewController alloc] init];
    vc.userId                      = self.tableViewDataArray[indexPath.row][@"userId"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - Pravite

- (void)p_loadData {

    NSString *relativeURL;

    switch (self.selectedType) {
        case LYMyGiftViewControllerTypeFetch: {
            relativeURL = @"/mobile/gift/giftReceive";
            break;
        }
        case LYMyGiftViewControllerTypeSend: {
            relativeURL = @"/mobile/gift/giftSend";
            break;
        }
    }

    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@%@", REQUESTHEADER, relativeURL]
        andParameter:@{
            @"userId": [LYUserService sharedInstance].userID
        }
        success:^(id successResponse) {
            if ([successResponse[@"code"] integerValue] == 200) {

                self.tableViewDataArray = successResponse[@"data"][@"giftRecords"];
                [self.tableView reloadData];

            } else {
                [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"msg"]]];
            }
        }
        andFailure:^(id failureResponse) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [MBProgressHUD showError:@"加载失败，请重试"];
        }];
}


@end
