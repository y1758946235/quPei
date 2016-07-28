//
//  SettingViewController.m
//  
//
//  Created by 广有射怪鸟事 on 15/10/3.
//
//

#import "SettingViewController.h"
#import "FeedBackViewController.h"
#import "BundingViewController.h"
#import "MBProgressHUD+NJ.h"
#import "LYUserService.h"
#import "HelpCenterViewController.h"
#import "SDImageCache.h"
#import "PrivacyPolicyViewController.h"
#import "BlockListViewController.h"
#import "NoticeViewController.h"

@interface SettingViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) NSArray *titleArray;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationController setNavigationBarHidden:NO];
    
    self.view.backgroundColor = RGBACOLOR(238, 238, 238, 1);

    self.title = @"设置";
    
    self.titleArray = @[@"通知与消息",@"帮助中心",@"意见反馈",@"联系我们",@"屏蔽列表",@"清理缓存"];
    
    [self createTableView];
}

- (void)createTableView{
    UITableView *table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight) style:UITableViewStyleGrouped];
    table.delegate = self;
    table.dataSource = self;
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:table];
}

- (void)logout{
    [[LYUserService sharedInstance] loginOutWithController:nil compeletionBlock:nil];
}
- (void)checkPrivate{
    PrivacyPolicyViewController *private = [[PrivacyPolicyViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:private];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark tableview代理方法

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 20;
    }else{
        return 0.1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 5;
    }
    else{
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *myId = @"myId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:myId];
    }
    if (indexPath.section == 0) {
        cell.textLabel.text = self.titleArray[indexPath.row];
    }
    else{
        cell.textLabel.text = self.titleArray[indexPath.row + 5];
    }
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    return cell;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = RGBACOLOR(238, 238, 238, 1);
    
    UIButton *quitBtn = [[UIButton alloc] init];
    [quitBtn setCenter:CGPointMake(kMainScreenWidth / 2, 50)];
    [quitBtn setBounds:CGRectMake(0, 0, kMainScreenWidth - 40, 40)];
    [quitBtn setBackgroundColor:[UIColor colorWithRed:29/255.0 green:189/255.0 blue:159/255.0 alpha:1]];
    [quitBtn setTitle:@"退出登录" forState:UIControlStateNormal];
    [quitBtn addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
    [quitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [quitBtn.layer setCornerRadius:4];
    [view addSubview:quitBtn];
    
    UIButton *useBtn = [[UIButton alloc] init];
    [useBtn setCenter:CGPointMake(kMainScreenWidth / 2, 100)];
    [useBtn setBounds: CGRectMake(0, 0, kMainScreenWidth, 20)];
    [useBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [useBtn setTitle:@"使用条款和隐私政策" forState:UIControlStateNormal];
    [useBtn setTitleColor:[UIColor colorWithRed:29/255.0 green:189/255.0 blue:159/255.0 alpha:1] forState:UIControlStateNormal];
    [useBtn.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
    [useBtn addTarget:self action:@selector(checkPrivate) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:useBtn];
    
    UILabel *comLabel = [[UILabel alloc] init];
    comLabel.center = CGPointMake(kMainScreenWidth / 2, 140);
    comLabel.bounds = CGRectMake(0, 0, kMainScreenWidth, 20);
    comLabel.font = [UIFont systemFontOfSize: 14.0];
    comLabel.textColor = RGBACOLOR(174, 174, 174, 1);
    comLabel.textAlignment = NSTextAlignmentCenter;
    comLabel.text = @"杭州傲骨科技有限公司 版权所有";
    [view addSubview:comLabel];
    
    UILabel *copLabel = [[UILabel alloc] init];
    copLabel.center = CGPointMake(kMainScreenWidth / 2, 170);
    copLabel.bounds = CGRectMake(0, 0, kMainScreenWidth, 20);
    copLabel.font = [UIFont systemFontOfSize: 14.0];
    copLabel.textColor = RGBACOLOR(174, 174, 174, 1);
    copLabel.textAlignment = NSTextAlignmentCenter;
    copLabel.text = @"Copyright@2015.";
    [view addSubview:copLabel];
    
    UILabel *allLabel = [[UILabel alloc] init];
    allLabel.center = CGPointMake(kMainScreenWidth / 2, 200);
    allLabel.bounds = CGRectMake(0, 0, kMainScreenWidth, 20);
    allLabel.font = [UIFont systemFontOfSize: 14.0];
    allLabel.textColor = RGBACOLOR(174, 174, 174, 1);
    allLabel.textAlignment = NSTextAlignmentCenter;
    allLabel.text = @"All Rights Reserved";
    [view addSubview:allLabel];
    
    if (section == 1) {
        return view;
    }
    else{
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
            {
                NoticeViewController *notice = [[NoticeViewController alloc] init];
                [self.navigationController pushViewController:notice animated:YES];
            }
                break;
            case 1:
            {
                HelpCenterViewController *help = [[HelpCenterViewController alloc] init];
                [self.navigationController pushViewController:help animated:YES];
            }
                break;
            case 2:
            {
                FeedBackViewController *feed = [[FeedBackViewController alloc] init];
                [self.navigationController pushViewController:feed animated:YES];
            }
                break;
            case 3:
            {
                UIWebView * callWebview = [[UIWebView alloc] init];
                [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"tel://0571-81622361"]]];
                [self.view addSubview:callWebview];
            }
                break;
            case 4:
            {
                BlockListViewController *list = [[BlockListViewController alloc] init];
                [self.navigationController pushViewController:list animated:YES];
            }
                break;
            default:
                break;
        }
    }
    else{
        switch (indexPath.row) {
                
            case 0:
            {
                [[SDImageCache sharedImageCache] clearDisk];
                [[SDImageCache sharedImageCache] clearMemory];
                
                [MBProgressHUD showSuccess:@"清理成功"];
            }
                break;
            default:
                break;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 0) {
        return 20;
    }
    else{
        return 220;
    }
}


@end
