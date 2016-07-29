//
//  LYMeViewController.m
//  LvYue
//
//  Created by KentonYu on 16/7/22.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "LYMeHeaderView.h"
#import "LYMeTableViewCell.h"
#import "LYMeViewController.h"

#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "MBProgressHUD+NJ.h"
#import "MBProgressHUD.h"
#import "UMSocial.h"

#import "FriendsCirleViewController.h"   // 动态圈
#import "KnowViewController.h"           // 身份认证
#import "LYEssenceAlbumViewController.h" // 精华相册
#import "LYMyGiftViewController.h"       // 我的礼物
#import "LYSendGiftViewController.h"
#import "MyAccountViewController.h"     // 我的账户
#import "MyDispositionViewController.h" // 普通相册
#import "MyInfomationViewController.h"  // 我的个人资料
#import "SettingViewController.h"       // 设置

#import "ChangeHeadViewController.h" // 修改头像

#import "MyDetailInfoModel.h"
#import "MyInfoModel.h"

static NSString *const LYMeViewControllerShareTitle = @"豆客，出售您的空余时间，向导大家旅行、寻找美食、搭伴健身..除了能带给您经济收入外，互动的过程还能互相深入了解，交到真正、合适的各方朋友，他、她正在豆客等您..";
static NSString *const LYMeViewControllerShareText  = @"我分享了一个APP应用，快来看看吧~\n\n——尽在\"豆客\"App";
static NSString *const LYMeTableViewCellIdentity    = @"LYMeTableViewCellIdentity";
static NSArray<NSArray *> *kTableViewDataArray;

typedef NS_ENUM(NSUInteger, LYMeViewControllerCellTypeEnum) {
    LYMeViewControllerCellTypeEnumMyAccount     = 0,
    LYMeViewControllerCellTypeEnumMyGift        = 1,
    LYMeViewControllerCellTypeEnumMyInfomation  = 2,
    LYMeViewControllerCellTypeEnumFriendCircle  = 3,
    LYMeViewControllerCellTypeEnumNormalAlbum   = 4, // 普通相册
    LYMeViewControllerCellTypeEnumEssenceAlbum  = 5, // 精华相册
    LYMeViewControllerCellTypeEnumcertification = 6, // 身份认证
    LYMeViewControllerCellTypeEnumShare         = 7,
    LYMeViewControllerCellTypeEnumSetting       = 8
};

@interface LYMeViewController () <
    UITableViewDelegate,
    UITableViewDataSource,
    UMSocialUIDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) LYMeHeaderView *headerView;

@property (nonatomic, strong) MyInfoModel *infoModel;
@property (nonatomic, strong) MyDetailInfoModel *detailInfoModel;
@property (nonatomic, assign) BOOL login; // 登录状态

@end

@implementation LYMeViewController

+ (void)initialize {
    kTableViewDataArray = @[
        @[
           @{
               @"title": @"我的账户",
               @"icon": @"我的豆客",
               @"cellType": @"0"
           },
           @{
               @"title": @"我的礼物",
               @"icon": @"",
               @"cellType": @"1"
           }
        ],
        @[
           @{
               @"title": @"个人资料",
               @"icon": @"个人资料-1",
               @"cellType": @"2"
           },
           @{
               @"title": @"个人动态",
               @"icon": @"个人动态-1",
               @"cellType": @"3"
           },
           @{
               @"title": @"我的相册",
               @"icon": @"我的气质",
               @"cellType": @"4"
           },
           @{
               @"title": @"精华相册",
               @"icon": @"",
               @"cellType": @"5"
           }
        ],
        @[
           @{
               @"title": @"身份认证",
               @"icon": @"申请向导",
               @"cellType": @"6"
           }
        ],
        @[
           @{
               @"title": @"分享好友",
               @"icon": @"分享好友",
               @"cellType": @"7"
           },
           @{
               @"title": @"设置",
               @"icon": @"设置",
               @"cellType": @"8"
           }
        ]
    ];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.navigationController setNavigationBarHidden:YES];

    if (self.login) {
        [self p_loadData];
    }
}


#pragma mark Pravite

- (void)p_loadData {

    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/getDetailInfo", REQUESTHEADER] andParameter:@{ @"id": [NSString stringWithFormat:@"%@", [LYUserService sharedInstance].userID] } success:^(id successResponse) {

        if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {

            NSDictionary *infoDict       = successResponse[@"data"][@"user"];
            self.infoModel               = [[MyInfoModel alloc] initWithDict:infoDict];
            NSDictionary *detailInfoDict = successResponse[@"data"][@"userDetail"];
            self.detailInfoModel         = [[MyDetailInfoModel alloc] initWithDict:detailInfoDict];

            [self.headerView configHeaderViewDataSource:self.detailInfoModel infoModel:self.infoModel];
        } else {
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"msg"]]];
        }

    }
        andFailure:^(id failureResponse) {
            [MBProgressHUD showError:@"服务器繁忙,请重试"];
        }];
}

- (void)p_share {
    //设置微信
    [UMSocialData defaultData].extConfig.wechatSessionData.title  = LYMeViewControllerShareTitle;
    [UMSocialData defaultData].extConfig.wechatTimelineData.title = LYMeViewControllerShareTitle;
    [UMSocialData defaultData].extConfig.wechatSessionData.url    = [NSString stringWithFormat:@"%@/assets/share", REQUESTHEADER];
    [UMSocialData defaultData].extConfig.wechatTimelineData.url   = [NSString stringWithFormat:@"%@/assets/share", REQUESTHEADER];

    //设置新浪微博
    [[UMSocialData defaultData].urlResource setResourceType:UMSocialUrlResourceTypeImage url:[NSString stringWithFormat:@"%@/assets/share", REQUESTHEADER]];


    //设置QQ
    [UMSocialData defaultData].extConfig.qqData.title    = LYMeViewControllerShareTitle;
    [UMSocialData defaultData].extConfig.qzoneData.title = LYMeViewControllerShareTitle;
    [UMSocialData defaultData].extConfig.qqData.url      = [NSString stringWithFormat:@"%@/assets/share", REQUESTHEADER];
    [UMSocialData defaultData].extConfig.qzoneData.url   = [NSString stringWithFormat:@"%@/assets/share", REQUESTHEADER];

    //分享
    [UMSocialSnsService presentSnsIconSheetView:self appKey:@"55f3983c67e58e502a00167d" shareText:LYMeViewControllerShareText shareImage:[UIImage imageNamed:@"logo108"] shareToSnsNames:[NSArray arrayWithObjects:UMShareToWechatTimeline, UMShareToWechatSession, UMShareToSina, UMShareToQQ, UMShareToQzone, nil] delegate:self];
}


#pragma mark TableView DataSource & Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return kTableViewDataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return kTableViewDataArray[section].count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return CGFLOAT_MIN;
    }
    return 20.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LYMeTableViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:LYMeTableViewCellIdentity forIndexPath:indexPath];
    cell.iconImageView.image = [UIImage imageNamed:kTableViewDataArray[indexPath.section][indexPath.row][@"icon"]];
    cell.titleLabel.text     = kTableViewDataArray[indexPath.section][indexPath.row][@"title"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (!self.login) {
        [[LYUserService sharedInstance] jumpToLoginWithController:self.tabBarController];
    }

    LYMeViewControllerCellTypeEnum type = (LYMeViewControllerCellTypeEnum)[kTableViewDataArray[indexPath.section][indexPath.row][@"cellType"] integerValue];
    switch (type) {
        case LYMeViewControllerCellTypeEnumMyAccount: {
            MyAccountViewController *vc = [[MyAccountViewController alloc] init];
            vc.myInfoModel              = self.infoModel;
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case LYMeViewControllerCellTypeEnumMyGift: {
            LYSendGiftViewController *vc = [[LYSendGiftViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case LYMeViewControllerCellTypeEnumMyInfomation: {
            MyInfomationViewController *vc = [[MyInfomationViewController alloc] init];
            [vc setHidesBottomBarWhenPushed:YES];
            vc.id                 = self.infoModel.id;                                                                              //id
            vc.headImage          = self.headerView.avatarImageView.image;                                                          //头像
            vc.introduceString    = self.infoModel.signature;                                                                       //个性签名
            vc.userName           = self.infoModel.name;                                                                            //名字
            vc.userSex            = [NSString stringWithFormat:@"%ld", (long) self.infoModel.sex];                                  //性别
            vc.isKnowSex          = [NSString stringWithFormat:@"%ld", (long) self.infoModel.auth_identity];                        //是否认证性别
            vc.userAge            = [NSString stringWithFormat:@"%ld", (long) self.infoModel.age];                                  //年龄
            vc.locationString     = [NSString stringWithFormat:@"%@ %@", self.detailInfoModel.province, self.detailInfoModel.city]; //地区，省份城市
            vc.edu                = self.infoModel.edu;                                                                             //学历
            vc.isKnowStudy        = [NSString stringWithFormat:@"%ld", (long) self.infoModel.auth_edu];
            vc.serviceMoneyString = self.detailInfoModel.service_price;                                             //服务价格
            vc.jobString          = self.detailInfoModel.industry;                                                  //行业
            vc.star               = self.infoModel.score;                                                           //星级
            vc.codeString         = self.infoModel.mobile;                                                          //手机号
            vc.isVip              = [NSString stringWithFormat:@"%ld", (long) self.infoModel.vip];                  //是否会员
            vc.signString         = [NSMutableString stringWithFormat:@"%@", self.detailInfoModel.service_content]; //服务项目
            vc.canLive            = [NSString stringWithFormat:@"%ld", (long) self.detailInfoModel.provide_stay];   //是否提供食宿
            vc.userEmail          = self.detailInfoModel.contact;                                                   //联系方式（邮箱
            vc.vip_time           = self.detailInfoModel.vip_time;
            vc.type               = self.infoModel.type;
            vc.is_show            = self.infoModel.is_show;
            if ([self.detailInfoModel.country isEqualToString:self.detailInfoModel.province]) {
                vc.locationString = self.detailInfoModel.countryName;
            } else if ([self.detailInfoModel.province isEqualToString:self.detailInfoModel.city]) {
                vc.locationString = [NSString stringWithFormat:@"%@ %@", self.detailInfoModel.countryName, self.detailInfoModel.provinceName];
            } else {
                vc.locationString = [NSString stringWithFormat:@"%@ %@ %@", self.detailInfoModel.countryName, self.detailInfoModel.provinceName, self.detailInfoModel.cityName];
            }
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case LYMeViewControllerCellTypeEnumFriendCircle: {
            FriendsCirleViewController *vc = [[FriendsCirleViewController alloc] init];
            [vc setHidesBottomBarWhenPushed:YES];
            vc.title           = @"个人动态";
            vc.userId          = [LYUserService sharedInstance].userID;
            vc.isFriendsCircle = NO;
            vc.personName      = self.infoModel.name;
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case LYMeViewControllerCellTypeEnumNormalAlbum: {
            MyDispositionViewController *vc = [[MyDispositionViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case LYMeViewControllerCellTypeEnumEssenceAlbum: {
            LYEssenceAlbumViewController *vc = [[LYEssenceAlbumViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case LYMeViewControllerCellTypeEnumcertification: {
            KnowViewController *vc = [[KnowViewController alloc] init];
            [vc setHidesBottomBarWhenPushed:YES];
            vc.car          = self.infoModel.auth_car;
            vc.edu          = self.infoModel.auth_edu;
            vc.identity     = self.infoModel.auth_identity;
            vc.video        = self.infoModel.auth_video;
            vc.userType     = self.infoModel.type;
            vc.alipay       = self.detailInfoModel.alipay_id;
            vc.weixin       = self.detailInfoModel.weixin_id;
            vc.provide_stay = self.infoModel.provide_stay;
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case LYMeViewControllerCellTypeEnumShare: {
            [self p_share];
            break;
        }
        case LYMeViewControllerCellTypeEnumSetting: {
            SettingViewController *vc = [[SettingViewController alloc] init];
            vc.alipay_id              = self.detailInfoModel.alipay_id;
            vc.weixin_id              = self.detailInfoModel.weixin_id;
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
    }
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


#pragma mark - Getter

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = ({
            UITableView *tableView    = [[UITableView alloc] initWithFrame:CGRectMake(0, -STATUS_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - TAB_TAB_HEIGHT + STATUS_BAR_HEIGHT) style:UITableViewStyleGrouped];
            tableView.delegate        = self;
            tableView.dataSource      = self;
            tableView.tableHeaderView = self.headerView;
            [tableView registerNib:[UINib nibWithNibName:@"LYMeTableViewCell" bundle:nil] forCellReuseIdentifier:LYMeTableViewCellIdentity];
            [self.view addSubview:tableView];
            tableView;
        });
    }
    return _tableView;
}

- (LYMeHeaderView *)headerView {
    if (!_headerView) {
        _headerView                        = [[[NSBundle mainBundle] loadNibNamed:@"LYMeHeaderView" owner:self options:nil] objectAtIndex:0];
        _headerView.frame                  = CGRectMake(0, 0, SCREEN_WIDTH, 240.f);
        __weak typeof(self) weakSelf       = self;
        _headerView.changeAvatarImageBlock = ^(id sender) {
            if (weakSelf.login) {
                ChangeHeadViewController *vc = [[ChangeHeadViewController alloc] init];
                [vc setHidesBottomBarWhenPushed:YES];
                vc.headImage = weakSelf.headerView.avatarImageView.image;
                vc.name      = weakSelf.infoModel.name;
                [weakSelf.navigationController pushViewController:vc animated:YES];
            }
        };
    }
    return _headerView;
}

- (BOOL)login {
    __block BOOL result;
    [[LYUserService sharedInstance] fetchLoginStateWithCompeletionBlock:^(UserLoginStateType type) {
        switch (type) {
            case UserLoginStateTypeAlreadyLogin: {
                result = YES;
                break;
            }
            case UserLoginStateTypeWaitToLogin: {
                result = NO;
                break;
            }
        }
    }];
    _login = result;
    return _login;
}

@end
