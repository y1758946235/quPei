//
//  FindViewController.m
//  澜庭
//
//  Created by 广有射怪鸟事 on 15/9/24.
//  Copyright (c) 2015年 刘瀚韬. All rights reserved.
//

#import "FindTableViewCell.h"
#import "FriendsCirleViewController.h"
#import "JHJJViewController.h"
#import "LYDetailDataViewController.h"
#import "LYUserService.h"
#import "MBProgressHUD+NJ.h"
#import "NearbyPeopleViewController.h"
#import "PeopleLiveViewController.h"
#import "SearchViewController.h"
#import "StartDateViewController.h"
#import "StrategyViewController.h"
#import "SubscriptionViewController.h"
#import "ThemeDateViewController.h"
#import "UMSocial.h"
#import "VideoListViewController.h"
#import <QuartzCore/QuartzCore.h>

#define kScreenWidth self.view.frame.size.width
#define kScreenHeight self.view.frame.size.height

@interface SearchViewController () <UITableViewDataSource, UITableViewDelegate, UMSocialUIDelegate>

@property (nonatomic, strong) NSArray *imgArray;
@property (nonatomic, strong) NSArray *titleArray;

@end

@implementation SearchViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title                = @"发现";
    self.view.backgroundColor = [UIColor colorWithRed:238.0 green:238.0 blue:238.0 alpha:0];

#ifdef kEasyVersion
    self.imgArray   = @[@"朋友圈-3", @"视频圈-1", @"附近的人-1", @"发起豆客", @"救急令-1", @"主题豆客", @"分享好友-1", @"民宿", @"添加订阅", @"旅游攻略"];
    self.titleArray = @[@"朋友圈", @"视频圈", @"附近的人", @"发起豆客", @"江湖救急令", @"主题豆客", @"分享好友", @"民宿", @"资讯", @"旅游攻略"];
#else
    self.imgArray = @[@"朋友圈", @"视频",
                      //                      @"附近的人-1",
                      @"发起豆客",
                      @"令",
                      @"热气球",
                      @"分享好友",
                      @"资讯管理",
                      @"旅游攻略"];
    self.titleArray = @[@"朋友圈", @"视频圈",
                        //                        @"附近的人",
                        @"发起豆客",
                        @"江湖救急令",
                        @"主题豆客",
                        @"分享好友",
                        @"资讯",
                        @"旅游攻略"];
#endif

    [self createTableView];
}

//创建tableView
- (void)createTableView {
    UITableView *tableView   = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight) style:UITableViewStyleGrouped];
    tableView.dataSource     = self;
    tableView.delegate       = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView];
}

#pragma mark talbeView代理方法

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    } else if (section == 2) {
        return 2;
    } else {
#ifdef kEasyVersion
        return 5;
#else
        return 4;
#endif
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *myId   = @"FindTableViewCell";
    FindTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myId];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:myId owner:nil options:nil] lastObject];
    }
    if (indexPath.section == 0) {
        cell.iconImg.image  = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", self.imgArray[indexPath.row]]];
        cell.iconLabel.text = self.titleArray[indexPath.row];
        if (indexPath.row == 1) {
            cell.lineView.hidden = YES;
        } else {
            cell.lineView.hidden = NO;
        }
    } else if (indexPath.section == 2) {
#ifdef kEasyVersion
        cell.iconImg.image  = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", self.imgArray[indexPath.row + 7]]];
        cell.iconLabel.text = self.titleArray[indexPath.row + 7];
#else
        cell.iconImg.image  = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", self.imgArray[indexPath.row + 6]]];
        cell.iconLabel.text = self.titleArray[indexPath.row + 6];
#endif
        if (indexPath.row == 1) {
            cell.lineView.hidden = YES;
        } else {
            cell.lineView.hidden = NO;
        }
    } else {
        cell.iconImg.image  = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", self.imgArray[indexPath.row + 2]]];
        cell.iconLabel.text = self.titleArray[indexPath.row + 2];
#ifdef kEasyVersion
        if (indexPath.row == 4) {
            cell.lineView.hidden = YES;
        } else {
            cell.lineView.hidden = NO;
        }
#else
        if (indexPath.row == 3) {
            cell.lineView.hidden = YES;
        } else {
            cell.lineView.hidden = NO;
        }
#endif
    }

    if (kMainScreenWidth < 375) {
        cell.iconLabel.font = [UIFont systemFontOfSize:14.0];
    }

    cell.hidden = YES;
    if (indexPath.section == 0 && indexPath.row == 0) {
        cell.hidden = NO;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 20;
    } else {
        return 0.1;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section == 0) {

        [[LYUserService sharedInstance] fetchLoginStateWithCompeletionBlock:^(UserLoginStateType type) {
            if (type == UserLoginStateTypeWaitToLogin) {
                [[LYUserService sharedInstance] jumpToLoginWithController:self];
            } else if (type == UserLoginStateTypeAlreadyLogin) {
                switch (indexPath.row) {
                    case 0: {
                        FriendsCirleViewController *friendsCirleViewController = [[FriendsCirleViewController alloc] init];
                        [friendsCirleViewController setHidesBottomBarWhenPushed:YES];
                        friendsCirleViewController.userId          = [LYUserService sharedInstance].userID;
                        friendsCirleViewController.isFriendsCircle = YES;
                        friendsCirleViewController.title           = @"朋友圈";
                        [self.navigationController pushViewController:friendsCirleViewController animated:YES];
                    } break;
                    //                    case 2:
                    //                    {
                    //                        NearbyPeopleViewController *near = [[NearbyPeopleViewController alloc] init];
                    //                        [near setHidesBottomBarWhenPushed:YES];
                    //                        [self.navigationController pushViewController:near animated:YES];
                    //                    }
                    //                        break;
                    default: {
                        VideoListViewController *video = [[VideoListViewController alloc] init];
                        [self.navigationController pushViewController:video animated:YES];
                        break;
                    }
                }
            }
        }];
    } else if (indexPath.section == 1) {

        if (indexPath.row == 0) {
            StartDateViewController *start = [[StartDateViewController alloc] init];
            [start setHidesBottomBarWhenPushed:YES];
            [self.navigationController pushViewController:start animated:YES];
        }

        if (indexPath.row != 0) {
            [[LYUserService sharedInstance] fetchLoginStateWithCompeletionBlock:^(UserLoginStateType type) {
                if (type == UserLoginStateTypeWaitToLogin) {
                    [[LYUserService sharedInstance] jumpToLoginWithController:self];
                } else if (type == UserLoginStateTypeAlreadyLogin) {
                    switch (indexPath.row) {
                        case 1: {
                            JHJJViewController *jjl = [[JHJJViewController alloc] init];
                            [jjl setHidesBottomBarWhenPushed:YES];
                            [self.navigationController pushViewController:jjl animated:YES];
                        } break;
                        case 2: {
                            ThemeDateViewController *theme = [[ThemeDateViewController alloc] init];
                            [theme setHidesBottomBarWhenPushed:YES];
                            [self.navigationController pushViewController:theme animated:YES];
                        } break;
                        case 3: {
                            //设置微信
                            [UMSocialData defaultData].extConfig.wechatSessionData.title  = @"豆客，出售您的空余时间，向导大家旅行、寻找美食、搭伴健身..除了能带给您经济收入外，互动的过程还能互相深入了解，交到真正、合适的各方朋友，他、她正在豆客等您..";
                            [UMSocialData defaultData].extConfig.wechatTimelineData.title = @"豆客，出售您的空余时间，向导大家旅行、寻找美食、搭伴健身..除了能带给您经济收入外，互动的过程还能互相深入了解，交到真正、合适的各方朋友，他、她正在豆客等您..";
                            [UMSocialData defaultData].extConfig.wechatSessionData.url    = [NSString stringWithFormat:@"%@/assets/share", REQUESTHEADER];
                            [UMSocialData defaultData].extConfig.wechatTimelineData.url   = [NSString stringWithFormat:@"%@/assets/share", REQUESTHEADER];

                            //设置新浪微博
                            [[UMSocialData defaultData].urlResource setResourceType:UMSocialUrlResourceTypeImage url:[NSString stringWithFormat:@"%@/assets/share", REQUESTHEADER]];


                            //设置QQ
                            [UMSocialData defaultData].extConfig.qqData.title    = @"豆客，出售您的空余时间，向导大家旅行、寻找美食、搭伴健身..除了能带给您经济收入外，互动的过程还能互相深入了解，交到真正、合适的各方朋友，他、她正在豆客等您..";
                            [UMSocialData defaultData].extConfig.qzoneData.title = @"豆客，出售您的空余时间，向导大家旅行、寻找美食、搭伴健身..除了能带给您经济收入外，互动的过程还能互相深入了解，交到真正、合适的各方朋友，他、她正在豆客等您..";
                            [UMSocialData defaultData].extConfig.qqData.url      = [NSString stringWithFormat:@"%@/assets/share", REQUESTHEADER];
                            [UMSocialData defaultData].extConfig.qzoneData.url   = [NSString stringWithFormat:@"%@/assets/share", REQUESTHEADER];

                            //分享
                            [UMSocialSnsService presentSnsIconSheetView:self appKey:@"55f3983c67e58e502a00167d" shareText:@"我分享了一个APP应用，快来看看吧~\n\n——尽在\"豆客\"APP" shareImage:[UIImage imageNamed:@"logo108"] shareToSnsNames:[NSArray arrayWithObjects:UMShareToWechatTimeline, UMShareToWechatSession, UMShareToSina, UMShareToQQ, UMShareToQzone, nil] delegate:self];
                            break;
                        }
                        case 4: {
                            PeopleLiveViewController *people = [[PeopleLiveViewController alloc] init];
                            [self.navigationController pushViewController:people animated:YES];
                        } break;
                        default:
                            break;
                    }
                }
            }];
        }
    } else {
        [[LYUserService sharedInstance] fetchLoginStateWithCompeletionBlock:^(UserLoginStateType type) {
            if (type == UserLoginStateTypeWaitToLogin) {
                [[LYUserService sharedInstance] jumpToLoginWithController:self];
            } else if (type == UserLoginStateTypeAlreadyLogin) {
                if (indexPath.row == 0) {
                    SubscriptionViewController *sub = [[SubscriptionViewController alloc] init];
                    [sub setHidesBottomBarWhenPushed:YES];
                    [self.navigationController pushViewController:sub animated:YES];
                } else {
                    StrategyViewController *str = [[StrategyViewController alloc] init];
                    [str setHidesBottomBarWhenPushed:YES];
                    [self.navigationController pushViewController:str animated:YES];
                }
            }
        }];
    }
}


#pragma mark - UMSocialUIDelegate
//弹出列表方法presentSnsIconSheetView需要设置delegate为self
//点击每个平台后默认会进入内容编辑页面，若想点击后直接分享内容，可以实现下面的回调方法,return YES
- (BOOL)isDirectShareInIconActionSheet {

    //NO为不会直接分享
    return NO;
}


//分享成功回调方法
- (void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response {

    //根据responseCode得到发送结果,如果分享成功
    if (response.responseCode == UMSResponseCodeSuccess) {

        [MBProgressHUD showSuccess:@"分享成功"];
    } else {
        //以下代码能帮助在控制器台看到错误码
        [UMSocialData openLog:YES];

        [MBProgressHUD showError:@"分享失败"];
    }
}


@end
