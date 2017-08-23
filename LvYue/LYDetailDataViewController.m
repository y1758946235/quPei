//
//  LYDetailDataViewController.m
//  LvYue
//
//  Created by KentonYu on 16/7/22.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "BuyVipViewController.h"
#import "ChatViewController.h"
#import "DXPopover.h"
#import "FriendsCirleViewController.h"
#import "LYDetailDataDefalutTableViewCell.h"
#import "LYDetailDataHeaderView.h"
#import "LYDetailDataPhotoTableViewCell.h"
#import "LYDetailDataReceiveGiftTableViewCell.h"
#import "LYDetailDataViewController.h"
#import "LYEssenceAlbumViewController.h"
#import "LYPopoverView.h"
#import "LYSendGiftViewController.h"
#import "ReportViewController.h"
#import "SendBuddyRequestMessageController.h"
#import "VideoKnowViewController.h"
#import <MediaPlayer/MediaPlayer.h>

#import "ChatSendHelper.h"
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "MBProgressHUD+NJ.h"
#import "MyDetailInfoModel.h"
#import "MyInfoModel.h"

typedef NS_ENUM(NSUInteger, LYDetailDataRelationShipEnum) {
    LYDetailDataRelationShipEnumAdd    = 0, // 加好友
    LYDetailDataRelationShipEnumDelete = 1, // 删除好友
    LYDetailDataRelationShipEnumIng    = 2, // 待验证
};

typedef NS_ENUM(NSUInteger, LYDetailDataAlertViewEnum) {
    LYDetailDataAlertViewEnumSendGift     = 1, // 送礼
    LYDetailDataAlertViewEnumWatchContact = 2, // 查看联系方式
    LYDetailDataAlertViewEnumChangeRemark = 3, // 修改备注
    LYDetailDataAlertViewEnumBecomeVip    = 4, // 成为会员
    LYDetailDataAlertViewEnumVedioAuth    = 5  // 视频认证
};

typedef NS_ENUM(NSUInteger, LYDetailDataActionSheetEnum) {
    LYDetailDataActionSheetEnumFriendShip  = 0, // 删除好友时显示
    LYDetailDataActionSheetEnumWatchAvatar = 1  // 查看头像时
};


static NSString *const LYInviteVedioAuthMessage =
    @"TA 还未通过形象视频认证，请谨慎联系。确认送礼并邀请 TA 认证形象视频吗？如果对方不认证，系统会返回您购买该礼物的金币";
static NSString *const LYPlayAuthVideoMessage1 = @"为了公平起见，你需要成为会员才能观看到更多人的形象视频，否则每天只能观看六个人的视频。";
static NSString *const LYPlayAuthVideoMessage2 = @"为了公平起见，你需要上传自己的形象认证视频才能观看更多人的形象视频，否则每天只能观看两人的形象视频。";

static NSArray<NSArray *> *LYDetailDataTableViewDataArray;
static NSString *const LYDetailDataTableViewDefaultCellIdentity     = @"LYDetailDataTableViewDefaultCellIdentity";
static NSString *const LYDetailDataPhotoTableViewCellIdentity       = @"LYDetailDataPhotoTableViewCellIdentity";
static NSString *const LYDetailDataReceiveGiftTableViewCellIdentity = @"LYDetailDataReceiveGiftTableViewCellIdentity";

@interface LYDetailDataViewController () <
    UITableViewDelegate,
    UITableViewDataSource,
    UIActionSheetDelegate,
    UIAlertViewDelegate,
    LYPopoverViewDataSource>

@property (nonatomic, strong) MyInfoModel *infoModel;
@property (nonatomic, strong) MyDetailInfoModel *detailInfoModel;
// 动态图片数组
@property (nonatomic, strong) NSArray *dynamicImageURLArray;
// TA 的气质数组
@property (nonatomic, strong) NSArray *taDeQiZhiImageURLArray;
// 精华相册数组
@property (nonatomic, strong) NSArray *jingHuaImageURLArray;
// 收到的礼物信息
@property (nonatomic, strong) NSArray *receivedGiftInfoArray;
// 备注
@property (nonatomic, strong) NSString *remark;
// 是否屏蔽
@property (nonatomic, assign) BOOL shield;
// 好友状态
@property (nonatomic, assign) LYDetailDataRelationShipEnum status; // 0 无关系  1 好友  2 等待验证

// 是否是用户自己
@property (nonatomic, assign) BOOL mySelf;

/***** UI ******/

@property (nonatomic, strong) UITableView *tableView;
// 用户头像信息视图
@property (nonatomic, strong) LYDetailDataHeaderView *detailDataHeaderView;
// 邀请形象认证的头部视图
@property (nonatomic, strong) UIView *invitateTableViewHeaderView;
// 包含发消息、加好友
@property (nonatomic, strong) UIView *tableViewFooterView;
// 查看用户头像使用
@property (nonatomic, strong) UIButton *watchAvatarButton;

@end

@implementation LYDetailDataViewController

+ (void)configTableViewDataArray:(MyDetailInfoModel *)detailInfoModel
                       infoModel:(MyInfoModel *)infoModel
                          remark:(NSString *)remark
            dynamicImageURLArray:(NSArray *)dynamicImageURLArray
          taDeQiZhiImageURLArray:(NSArray *)taDeQiZhiImageURLArray
            jingHuaImageURLArray:(NSArray *)jingHuaImageURLArray {
    LYDetailDataTableViewDataArray = @[
        @[
           @{
               @"title": @"个性签名",
               @"value": infoModel && infoModel.signature.length ? infoModel.signature
                                                                 : @"暂无信息",
               @"rowHeight": @44,
               @"actionVC": @""
           },
           @{
               @"title": @"备注",
               @"value": remark && remark.length ? remark : @"暂无信息",
               @"rowHeight": @44,
               @"actionVC": @""
           },
           @{
               @"title": @"地区",
               @"value": detailInfoModel && detailInfoModel.cityName.length
                             ? detailInfoModel.cityName
                             : @"暂无信息",
               @"rowHeight": @44,
               @"actionVC": @""
           },
           @{
               @"title": @"个人动态",
               @"value":
                   dynamicImageURLArray && dynamicImageURLArray ? dynamicImageURLArray
                                                                : [NSNull null],
               @"rowHeight": @82,
               @"actionVC": @"FriendsCirleViewController"
           },
           @{
               @"title": @"TA的气质",
               @"value": taDeQiZhiImageURLArray && taDeQiZhiImageURLArray
                             ? taDeQiZhiImageURLArray
                             : [NSNull null],
               @"rowHeight": @82,
               @"actionVC": @"MyDispositionViewController"
           },
           @{
               @"title": @"精华相册",
               @"value":
                   jingHuaImageURLArray && jingHuaImageURLArray ? jingHuaImageURLArray
                                                                : @"",
               @"rowHeight": @82,
               @"actionVC": @"LYEssenceAlbumViewController"
           },
        ],
        @[
           @{
               @"title": @"TA 收到的礼物",
               @"value":
                   infoModel && infoModel.edu.length ? infoModel.edu : @"暂无信息",
               @"rowHeight": @44,
               @"actionVC": @""
           },
           @{
               @"title": @"学历",
               @"value":
                   infoModel && infoModel.edu.length ? infoModel.edu : @"暂无信息",
               @"rowHeight": @44,
               @"actionVC": @""
           },
           @{
               @"title": @"行业",
               @"value": detailInfoModel && detailInfoModel.industry.length
                             ? detailInfoModel.industry
                             : @"暂无信息",
               @"rowHeight": @44,
               @"actionVC": @""
           },
           @{
               @"title": @"联系方式",
               @"value": detailInfoModel && detailInfoModel.contact.length
                             ? detailInfoModel.contact
                             : @"暂无信息",
               @"rowHeight": @44,
               @"actionVC": @""
           }
        ],
        @[
           //           @{
           //               @"title": @"TA的超能力",
           //               @"value": @"",
           //               @"rowHeight": @44,
           //               @"actionVC": @"PublishRequirementViewController"
           //           },
           @{
               @"title": @"屏蔽用户状态",
               @"value": @"",
               @"rowHeight": @44,
               @"actionVC": @""
           }
        ]
    ];
}

+ (void)initialize {
    [LYDetailDataViewController configTableViewDataArray:nil
                                               infoModel:nil
                                                  remark:nil
                                    dynamicImageURLArray:nil
                                  taDeQiZhiImageURLArray:nil
                                    jingHuaImageURLArray:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"详细资料";

    [self p_loadData];
    [self p_loadRecevicedGift];
    // 用户自己则不显示加好友发消息、右上角的汉堡按钮
    if (!self.mySelf) {
        [self setRightButton:[UIImage imageNamed:@"more"] title:nil target:self action:@selector(p_clickRightBarButtonItem:)];
    }

    [self.tableView reloadData];
}

#pragma mark TableView DataSource & Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // 自己的话 隐藏屏蔽用户  最后一个section
    if ([[LYUserService sharedInstance].userID isEqualToString:self.userId]) {
        return LYDetailDataTableViewDataArray.count - 1;
    }

    return LYDetailDataTableViewDataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return LYDetailDataTableViewDataArray[section].count;
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber *rowHeight = LYDetailDataTableViewDataArray[indexPath.section][indexPath.row][
        @"rowHeight"];
    return [rowHeight floatValue];
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 190.f;
    }

    return 10.f;
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 0) {
        // 我的动态  TA 的气质  精华相册
        if (indexPath.row == 3 || indexPath.row == 4 || indexPath.row == 5) {
            LYDetailDataPhotoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LYDetailDataPhotoTableViewCellIdentity forIndexPath:indexPath];
            BOOL essenceImage                    = NO;
            if (indexPath.row == 5) {
                essenceImage = YES;
            }
            [cell configPhotoArray:LYDetailDataTableViewDataArray
                                       [indexPath.section][indexPath.row][@"value"]
                             title:LYDetailDataTableViewDataArray
                                       [indexPath.section][indexPath.row][@"title"]
                      essenceImage:essenceImage];
            return cell;
        }
    }

    // TA 收到的礼物
    if (indexPath.section == 1 && indexPath.row == 0) {
        LYDetailDataReceiveGiftTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LYDetailDataReceiveGiftTableViewCellIdentity forIndexPath:indexPath];
        [cell configData:self.receivedGiftInfoArray];
        return cell;
    }

    LYDetailDataDefalutTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LYDetailDataTableViewDefaultCellIdentity forIndexPath:indexPath];

    NSDictionary *info = LYDetailDataTableViewDataArray[indexPath.section][indexPath.row];
    [cell configTitle:info[@"title"] content:info[@"value"]];

    // 联系方式
    if (indexPath.section == 1 && indexPath.row == 3) {
        [cell showWatchButton:^(UIButton *button) {

            if ([[LYUserService sharedInstance].userDetail.isVip integerValue]) {
                return YES;
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"豆客" message:@"只有会员才有资格查看" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"成为会员", nil];
                alert.tag          = LYDetailDataAlertViewEnumWatchContact;
                [alert show];
                return NO;
            }

        }];
    }

    // TA 的超能力
    //    if (indexPath.section == 2 && indexPath.row == 0) {
    //        [cell showLeftArrowImageView];
    //    }

    // 屏蔽用户
    if (indexPath.section == 2 && indexPath.row == 0) {
        [cell showSwitchWithOn:self.shield
                  valueChanged:^(UISwitch *sender) {
                      [self p_changShield];
                  }];
    }

    return cell;
}

- (UIView *)tableView:(UITableView *)tableView
    viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return self.detailDataHeaderView;
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView
    viewForFooterInSection:(NSInteger)section {
    return nil;
}

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if ([LYDetailDataTableViewDataArray[indexPath.section][indexPath.row][@"actionVC"] length] > 0) {
        Class cla = NSClassFromString(LYDetailDataTableViewDataArray[indexPath.section][indexPath.row][@"actionVC"]);
        id vc     = [cla new];

        // 个人动态，TA 的气质，精华相册
        if (indexPath.section == 0 && (indexPath.row == 3 || indexPath.row == 4 || indexPath.row == 5)) {
            [vc setValue:[NSString stringWithFormat:@"%ld", (long) self.infoModel.id] forKey:@"userId"];
            // 个人动态
            if (indexPath.row == 3) {
                [vc setValue:@NO forKey:@"isFriendsCircle"];
            }
        }

        // TA 的超能力
        //        if (indexPath.section == 2 && indexPath.row == 0) {
        //            [vc setValue:self.userId forKey:@"userId"];
        //        }


        [self.navigationController pushViewController:vc animated:YES];
    }

    // 备注
    if (indexPath.section == 0 && indexPath.row == 1) {
        if (self.mySelf) { // 自己的话不能修改
            return;
        }

        if (self.status == LYDetailDataRelationShipEnumDelete) {
            // 修改备注
            UIAlertView *alert                         = [[UIAlertView alloc] init];
            alert.alertViewStyle                       = UIAlertViewStylePlainTextInput;
            alert.title                                = @"豆客";
            [alert textFieldAtIndex:0].placeholder     = @"请输入备注";
            [alert textFieldAtIndex:0].clearButtonMode = UITextFieldViewModeAlways;
            [alert addButtonWithTitle:@"取消"];
            [alert addButtonWithTitle:@"确定"];
            alert.tag      = LYDetailDataAlertViewEnumChangeRemark;
            alert.delegate = self;
            [alert show];
        } else {
            [MBProgressHUD showError:@"你们还不是好友"];
        }
    }
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell
            respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet
    clickedButtonAtIndex:(NSInteger)buttonIndex {

    switch (actionSheet.tag) {
        case LYDetailDataActionSheetEnumFriendShip: {
            __weak typeof(self) weakSelf = self;

            if (buttonIndex == 0) {
                [MBProgressHUD showMessage:@"删除中.."];
                [LYHttpPoster
                    postHttpRequestByPost:
                        [NSString stringWithFormat:@"%@/mobile/userFriend/iosDelete",
                                                   REQUESTHEADER]
                    andParameter:@{
                        @"user_id": [LYUserService sharedInstance].userID,
                        @"friend_user_id": weakSelf.userId
                    } 
                    success:^(id successResponse) {
                        if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]]
                                isEqualToString:@"200"]) {
                            //调用环信"删除好友"的方法
                            EMError *error = nil;
                            BOOL isSuccess = [[EaseMob sharedInstance]
                                                  .chatManager removeBuddy:weakSelf.userId
                                                          removeFromRemote:YES
                                                                     error:&error];
                            if (isSuccess && !error) {
                                [MBProgressHUD hideHUD];
                                //删除之前的用户对话
                                [[EaseMob sharedInstance]
                                        .chatManager removeConversationByChatter:self.userId
                                                                  deleteMessages:YES
                                                                     append2Chat:YES];
                                //发送更新会话列表的通知
                                [[NSNotificationCenter defaultCenter]
                                    postNotificationName:@"LY_ReloadConversationList"
                                                  object:nil];
                                [MBProgressHUD showSuccess:@"删除成功"];
                                [self.navigationController popToRootViewControllerAnimated:YES];
                                //手动更新好友列表
                                [[NSNotificationCenter defaultCenter]
                                    postNotificationName:@"refreshMyBuddyList"
                                                  object:nil];
                            }
                        } else {
                            [MBProgressHUD hideHUD];
                            [MBProgressHUD
                                showError:[NSString
                                              stringWithFormat:@"%@", successResponse[@"msg"]]];
                        }
                    }
                    andFailure:^(id failureResponse) {
                        [MBProgressHUD hideHUD];
                        [MBProgressHUD showError:@"服务器繁忙,请重试"];
                    }];
            }
            break;
        }
        case LYDetailDataActionSheetEnumWatchAvatar: {
            // 保存相片
            if (buttonIndex == 0) {
                //保存到用户的本地相册中
                UIImageWriteToSavedPhotosAlbum(((UIImageView *) [self.watchAvatarButton viewWithTag:8088]).image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
            }
            break;
        }
    }
}

//图片保存回调处理方法
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {

    if (error) {
        [MBProgressHUD showError:@"保存失败"];
    } else {
        [MBProgressHUD showSuccess:@"保存成功"];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView
    clickedButtonAtIndex:(NSInteger)buttonIndex {

    LYDetailDataAlertViewEnum type = (LYDetailDataAlertViewEnum) alertView.tag;

    switch (type) {
        case LYDetailDataAlertViewEnumSendGift: {
            if (buttonIndex == 1) {
                LYSendGiftViewController *vc = [LYSendGiftViewController new];
                vc.type                      = LYSendGiftFunTypeInvite;
                vc.friendID                  = [NSString stringWithFormat:@"%ld", (long) self.infoModel.id];
                vc.userName                  = self.infoModel.name;
                vc.avatarImageURL            = self.infoModel.icon;
                [self.navigationController pushViewController:vc animated:YES];
            }
            break;
        }
        case LYDetailDataAlertViewEnumWatchContact: {
            if (buttonIndex == 1) {
                BuyVipViewController *vc = [[BuyVipViewController alloc] init];
                vc.coinNum        = @"0";
                vc.vip_price      = @"20";
                vc.vip_year_price = @"168";
                vc.isShow         = NO;
                [self.navigationController pushViewController:vc animated:YES];
            }
            break;
        }
        case LYDetailDataAlertViewEnumChangeRemark: {
            if (buttonIndex == 1) {
                [self p_changRemark:[alertView textFieldAtIndex:0].text];
            }
            break;
        }
        case LYDetailDataAlertViewEnumBecomeVip: {
            if (buttonIndex == 0) {
                BuyVipViewController *vc = [[BuyVipViewController alloc] init];
                vc.coinNum        = @"0";
                vc.vip_price      = @"20";
                vc.vip_year_price = @"168";
                vc.isShow         = NO;
                [self.navigationController pushViewController:vc animated:YES];
            }
            break;
        }
        case LYDetailDataAlertViewEnumVedioAuth: {
            VideoKnowViewController *vc = [[VideoKnowViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
    }
}

#pragma mark - LYPopoverViewDataSource

- (NSArray<NSDictionary *> *)popoverViewDataSource:(LYPopoverView *)popoverView {
    return @[
        @{
            @"title": @"举报",
            @"icon": @""
        }
    ];
}

- (void)popoverViewDidSelected:(NSInteger)index {
    if (index == 0) {
        ReportViewController *report = [[ReportViewController alloc] init];
        [self.navigationController pushViewController:report animated:YES];
    }
}

#pragma mark - Pravite

- (void)p_loadData {
    __weak typeof(self) weakSelf = self;
    [MBProgressHUD showMessage:nil];
    [LYHttpPoster postHttpRequestByPost:
                      [NSString stringWithFormat:@"%@/mobile/userFriend/getInfo",
                                                 REQUESTHEADER]
        andParameter:@{
            @"friend_user_id": weakSelf.userId,
            @"user_id": [LYUserService sharedInstance].userID
        }
        success:^(id successResponse) {
            MLOG(@"个人资料的结果:%@", successResponse);
            [MBProgressHUD hideHUD];
            if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]]
                    isEqualToString:@"200"]) {

                NSMutableDictionary *infoDic =
                    [successResponse[@"data"][@"user"] mutableCopy];
                // 关注 粉丝   接口传的结构跟用户信息并列的 为了方便插入到 infoModel
                [infoDic setObject:successResponse[@"data"][@"isFocus"]
                            forKey:@"isFocus"];
                [infoDic setObject:successResponse[@"data"][@"fansNum"]
                            forKey:@"fansNum"];
                weakSelf.infoModel       = [[MyInfoModel alloc] initWithDict:[infoDic copy]];
                weakSelf.detailInfoModel = [[MyDetailInfoModel alloc]
                    initWithDict:successResponse[@"data"][@"userDetail"]];

                if ([successResponse[@"data"][@"remark"] length] == 0) {
                    weakSelf.remark = @"";
                } else {
                    weakSelf.remark = successResponse[@"data"][@"remark"];
                }
                // 是否好友关系
                weakSelf.status = [successResponse[@"data"][@"status"] integerValue];
                // 是否屏蔽
                weakSelf.shield = [[NSString stringWithFormat:@"%@", successResponse[@"data"][@"isdefault"]] boolValue];
                // 个人动态图片
                weakSelf.dynamicImageURLArray = successResponse[@"data"][@"photos"];

                // 用户自己则不显示邀请文字
                if (!weakSelf.mySelf) {
                    // 视频未认证则现实头部的邀请入口
                    if (!weakSelf.infoModel.auth_video) {
                        weakSelf.tableView.tableHeaderView = weakSelf.invitateTableViewHeaderView;
                    }
                    // 加好友 发消息
                    self.tableView.tableFooterView = self.tableViewFooterView;
                }

                [weakSelf.detailDataHeaderView configData:weakSelf.infoModel mySelf:weakSelf.mySelf];

                // 加载我的气质
                [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/imgList", REQUESTHEADER]
                    andParameter:@{
                        @"user_id": weakSelf.userId
                    }
                    success:^(id successResponse) {
                        MLOG(@"结果:%@", successResponse);
                        if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]]
                                isEqualToString:@"200"]) {

                            NSMutableArray *array = [[NSMutableArray alloc] init];
                            [successResponse[@"data"][@"list"]
                                enumerateObjectsUsingBlock:^(id _Nonnull obj,
                                                             NSUInteger idx,
                                                             BOOL *_Nonnull stop) {
                                    [array addObject:obj[@"img_name"]];
                                }];
                            weakSelf.taDeQiZhiImageURLArray = [array copy];

                            // 加载精华相册
                            [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/getEssenceImgList", REQUESTHEADER]
                                andParameter:@{
                                    @"user_id": [LYUserService sharedInstance].userID,
                                    @"other_id": @(weakSelf.infoModel.id)
                                }
                                success:^(id successResponse) {
                                    if ([successResponse[@"code"] integerValue] == 200) {
                                        //                                        NSMutableArray *array = [[NSMutableArray alloc] init];
                                        //                                        [successResponse[@"data"][@"list"]
                                        //                                            enumerateObjectsUsingBlock:^(id _Nonnull obj,
                                        //                                                                         NSUInteger idx,
                                        //                                                                         BOOL *_Nonnull stop) {
                                        //                                                [array addObject:obj[@"img_name"]];
                                        //                                            }];
                                        weakSelf.jingHuaImageURLArray = [successResponse[@"data"][@"list"] copy];
                                        [LYDetailDataViewController
                                            configTableViewDataArray:weakSelf.detailInfoModel
                                                           infoModel:weakSelf.infoModel
                                                              remark:weakSelf.remark
                                                dynamicImageURLArray:weakSelf.dynamicImageURLArray
                                              taDeQiZhiImageURLArray:weakSelf.taDeQiZhiImageURLArray
                                                jingHuaImageURLArray:weakSelf.jingHuaImageURLArray];

                                        [weakSelf.tableView reloadData];
                                    } else {
                                        [LYDetailDataViewController
                                            configTableViewDataArray:weakSelf.detailInfoModel
                                                           infoModel:weakSelf.infoModel
                                                              remark:weakSelf.remark
                                                dynamicImageURLArray:weakSelf.dynamicImageURLArray
                                              taDeQiZhiImageURLArray:weakSelf.taDeQiZhiImageURLArray
                                                jingHuaImageURLArray:nil];
                                        [MBProgressHUD hideHUD];
                                        [MBProgressHUD
                                            showError:[NSString stringWithFormat:@"%@", successResponse[@"msg"]]];
                                    }
                                }
                                andFailure:^(id failureResponse) {
                                    [LYDetailDataViewController
                                        configTableViewDataArray:weakSelf.detailInfoModel
                                                       infoModel:weakSelf.infoModel
                                                          remark:weakSelf.remark
                                            dynamicImageURLArray:weakSelf.dynamicImageURLArray
                                          taDeQiZhiImageURLArray:weakSelf.taDeQiZhiImageURLArray
                                            jingHuaImageURLArray:nil];
                                    [MBProgressHUD hideHUD];
                                    [MBProgressHUD showError:@"加载精华照片失败,请重试"];
                                }];

                        } else {
                            [MBProgressHUD hideHUD];
                            [MBProgressHUD
                                showError:[NSString stringWithFormat:@"%@", successResponse[@"msg"]]];
                        }
                    }
                    andFailure:^(id failureResponse) {
                        [MBProgressHUD hideHUD];
                        [MBProgressHUD showError:@"服务器繁忙,请重试"];
                    }];
            } else {
                [MBProgressHUD hideHUD];
                [MBProgressHUD
                    showError:[NSString
                                  stringWithFormat:@"%@", successResponse[@"msg"]]];
            }
        }
        andFailure:^(id failureResponse) {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"服务器繁忙,请重试"];
        }];
}

- (void)p_loadRecevicedGift {
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/gift/giftReceive", REQUESTHEADER]
        andParameter:@{
            @"userId": self.userId
        }
        success:^(id successResponse) {
            if ([successResponse[@"code"] integerValue] == 200) {
                self.receivedGiftInfoArray = successResponse[@"data"][@"giftRecords"];
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
            } else {
                [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"msg"]]];
            }
        }
        andFailure:^(id failureResponse) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [MBProgressHUD showError:@"加载失败，请重试"];
        }];
}


/**
 *  发送消息
 */
- (void)p_sendMessage:(id)sender {
    if (self.fromChatVC) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        ChatViewController *chatVc =
            [[ChatViewController alloc] initWithChatter:self.userId isGroup:NO];
        if (self.remark && ![self.remark isEqualToString:@""] && ![self.remark isEqual:[NSNull null]]) {
            chatVc.title = self.remark;
        } else {
            chatVc.title = self.infoModel.name;
        }
        [self.navigationController pushViewController:chatVc animated:YES];
    }
}

/**
 *  添加朋友
 */
- (void)p_addFriend:(id)sender {
    [self p_processRelationShip:self.status];
}

/**
 *  处理好友关系
 *
 *  @param flag
 */
- (void)p_processRelationShip:(LYDetailDataRelationShipEnum)flag {
    switch (flag) {
        case LYDetailDataRelationShipEnumAdd: {
            SendBuddyRequestMessageController *dest =
                [[SendBuddyRequestMessageController alloc] init];
            dest.buddyID = self.userId;
            [self.navigationController pushViewController:dest animated:YES];
            break;
        }
        case LYDetailDataRelationShipEnumDelete: {
            UIActionSheet *actionSheet = [[UIActionSheet alloc]
                         initWithTitle:@"确定要删除联系人吗,"
                                       @"删除之后聊天记录会被清除"
                              delegate:self
                     cancelButtonTitle:@"取消"
                destructiveButtonTitle:@"删除"
                     otherButtonTitles:nil];
            actionSheet.tag = LYDetailDataActionSheetEnumFriendShip;
            [actionSheet showInView:self.view];
            break;
        }
        case LYDetailDataRelationShipEnumIng: {
            [MBProgressHUD showMessage:@"正在通过验证.."];
            __weak typeof(self) weakSelf = self;
            [LYHttpPoster
                postHttpRequestByPost:
                    [NSString
                        stringWithFormat:@"%@/mobile/messageVerify/updateIosStatus",
                                         REQUESTHEADER]
                andParameter:@{
                    @"user_id": [LYUserService sharedInstance].userID,
                    @"friend_id": weakSelf.userId,
                    @"status": @"2"
                }
                success:^(id successResponse) {
                    if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]]
                            isEqualToString:@"200"]) {
                        //手动调用环信的"通过验证"方法
                        EMError *error = nil;
                        BOOL isSuccess = [[EaseMob sharedInstance]
                                              .chatManager acceptBuddyRequest:weakSelf.userId
                                                                        error:&error];
                        if (isSuccess && !error) {
                            [MBProgressHUD hideHUD];
                            [MBProgressHUD showSuccess:@"通过验证"];
                            //                            [weakSelf getDataFromWeb];
                            //提示通过了XX用户的验证信息(同意加好友)
                            EMConversation *conversation = [[EaseMob sharedInstance]
                                                                .chatManager
                                conversationForChatter:weakSelf.userId
                                      conversationType:eConversationTypeChat];
                            [ChatSendHelper sendTextMessageWithString:
                                                @"我已通过了你的好友验证请求"
                                                           toUsername:conversation.chatter
                                                          messageType:eMessageTypeChat
                                                    requireEncryption:NO
                                                                  ext:nil];
                            //手动更新好友列表
                            [[NSNotificationCenter defaultCenter]
                                postNotificationName:@"refreshMyBuddyList"
                                              object:nil];
                        }
                    } else {
                        [MBProgressHUD hideHUD];
                        [MBProgressHUD
                            showError:[NSString
                                          stringWithFormat:@"%@", successResponse[@"msg"]]];
                    }
                }
                andFailure:^(id failureResponse) {
                    [MBProgressHUD hideHUD];
                    [MBProgressHUD showError:@"服务器繁忙,请重试"];
                }];
            break;
        }
    }
}

/**
 *  播放验证视频
 */
- (void)p_playAuthVideo {
    [MBProgressHUD showMessage:nil];
    __weak typeof(self) weakSelf = self;
    [LYHttpPoster
        postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/video/openVideo", REQUESTHEADER]
        andParameter:@{
            @"user_id": [LYUserService sharedInstance].userID,
            @"video_id": @"1",
            @"fid": weakSelf.userId
        }
        success:^(id successResponse) {
            // 199 开会员   198 去认证视频  200
            if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]]
                    isEqualToString:@"200"]) {
                [MBProgressHUD hideHUD];
                NSLog(@"视频播放：%@", successResponse);
                NSString *str = [NSString stringWithFormat:@"%@%@", IMAGEHEADER,weakSelf.detailInfoModel.authVideoPath];
                NSString *UrlStr = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                MPMoviePlayerViewController *player = [
                    [MPMoviePlayerViewController alloc]
                    initWithContentURL:
                        [NSURL
                            URLWithString:UrlStr]];
                player.moviePlayer.shouldAutoplay = YES;
                [weakSelf presentMoviePlayerViewControllerAnimated:player];
                
            } else if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]]
                           isEqualToString:@"199"]) {
                [MBProgressHUD hideHUD];
                UIAlertView *alertView = [[UIAlertView alloc]
                        initWithTitle:@"豆客"
                              message:LYPlayAuthVideoMessage1
                             delegate:weakSelf
                    cancelButtonTitle:nil
                    otherButtonTitles:@"成为会员", nil];
                alertView.tag = LYDetailDataAlertViewEnumBecomeVip;
                [alertView show];
            } else if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"198"]) {
                [MBProgressHUD hideHUD];
                UIAlertView *alertView = [[UIAlertView alloc]
                        initWithTitle:@"豆客"
                              message:LYPlayAuthVideoMessage2
                             delegate:weakSelf
                    cancelButtonTitle:nil
                    otherButtonTitles:@"去认证", nil];
                alertView.tag = LYDetailDataAlertViewEnumVedioAuth;
                [alertView show];
            } else {
                [MBProgressHUD hideHUD];
                [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"msg"]]];
            }
        }
        andFailure:^(id failureResponse) {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"服务器繁忙,请重试"];
        }];
}

/**
 *  修改屏蔽状态
 */
- (void)p_changShield {

    [MBProgressHUD showMessage:nil toView:self.view];

    NSString *requestURL;
    // 已经屏蔽则取消屏蔽接口
    if (self.shield) {
        requestURL = [NSString stringWithFormat:@"%@/mobile/notice/cancelShield", REQUESTHEADER];
    } else {
        requestURL = [NSString stringWithFormat:@"%@/mobile/notice/shield", REQUESTHEADER];
    }

    // 屏蔽
    [LYHttpPoster postHttpRequestByPost:requestURL
        andParameter:@{
            @"user_id": [NSString
                stringWithFormat:@"%@", [LYUserService sharedInstance].userID],
            @"other_user_id": self.userId
        }
        success:^(id successResponse) {
            MLOG(@"结果:%@", successResponse);
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
                self.shield = !self.shield;

                if (self.shield) {
                    [MBProgressHUD showSuccess:@"屏蔽成功"];
                } else {
                    [MBProgressHUD showSuccess:@"解除屏蔽"];
                }
            } else {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"msg"]]];
            }
        }
        andFailure:^(id failureResponse) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [MBProgressHUD showError:@"服务器繁忙,请重试"];
        }];
}

/**
 *  处理关注
 */
- (void)p_foucsOn {
    [LYHttpPoster
        postHttpRequestByPost:
            [NSString stringWithFormat:@"%@/mobile/userFriend/focusOther",
                                       REQUESTHEADER]
        andParameter:@{
            @"user_id": [LYUserService sharedInstance].userID,
            @"other_user_id": self.userId
        }
        success:^(id successResponse) {
            if ([successResponse[@"code"] integerValue] == 200) {
                self.infoModel.isFocus = !self.infoModel.isFocus;
                [self.detailDataHeaderView configData:self.infoModel mySelf:self.mySelf];
                if (self.infoModel.isFocus) {
                    [MBProgressHUD showSuccess:@"关注成功"];
                } else {
                    [MBProgressHUD showSuccess:@"取消关注成功"];
                }
            } else {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [MBProgressHUD
                    showError:[NSString
                                  stringWithFormat:@"%@", successResponse[@"msg"]]];
            }
        }
        andFailure:^(id failureResponse) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [MBProgressHUD showError:@"服务器繁忙,请重试"];
        }];
}

/**
 *  送礼物界面
 */
- (void)p_sendGift {
    LYSendGiftViewController *vc = [LYSendGiftViewController new];
    vc.userName                  = self.infoModel.name;
    vc.avatarImageURL            = self.infoModel.icon;
    vc.friendID                  = [NSString stringWithFormat:@"%ld", (long) self.infoModel.id];
    [self.navigationController pushViewController:vc animated:YES];
}

/**
 *  邀请好友视频认证
 */
- (void)p_clickInviteVedioAuthButton:(id)sender {
    UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:@"豆客"
                                   message:LYInviteVedioAuthMessage
                                  delegate:self
                         cancelButtonTitle:@"取消"
                         otherButtonTitles:@"赠送并邀请", nil];
    alert.tag = LYDetailDataAlertViewEnumSendGift;
    [alert show];
}

/**
 *  点击导航栏右侧按钮
 */
- (void)p_clickRightBarButtonItem:(UIBarButtonItem *)sender {
    [LYPopoverView showPopoverViewAtPoint:CGPointMake(SCREEN_WIDTH - 15.f, 10.f) inView:self.view type:LYPopoverViewItemTypeDefault delegate:self];
}

/**
 *  修改备注
 */
- (void)p_changRemark:(NSString *)remark {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@%@", REQUESTHEADER, @"/mobile/userFriend/update"]
        andParameter:@{
            @"user_id": [LYUserService sharedInstance].userID,
            @"friend_user_id": self.userId,
            @"remark": remark
        }
        success:^(id successResponse) {
            [MBProgressHUD hideHUDForView:self.view];
            if ([successResponse[@"code"] integerValue] == 200) {
                self.remark = remark;
                [LYDetailDataViewController
                    configTableViewDataArray:self.detailInfoModel
                                   infoModel:self.infoModel
                                      remark:self.remark
                        dynamicImageURLArray:self.dynamicImageURLArray
                      taDeQiZhiImageURLArray:self.taDeQiZhiImageURLArray
                        jingHuaImageURLArray:self.jingHuaImageURLArray];
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            } else {
                [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"msg"]]];
            }
        }
        andFailure:^(id failureResponse) {
            [MBProgressHUD hideHUDForView:self.view];
            [MBProgressHUD showError:@"服务器繁忙，请重试"];
        }];
}

- (void)p_watchAvatarImage:(UIImage *)image {
    self.watchAvatarButton = [[UIButton alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.watchAvatarButton setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:self.watchAvatarButton];

    UIImageView *imgV                     = [[UIImageView alloc] init];
    imgV.tag                              = 8088;
    CGFloat scale                         = image.size.height / image.size.width;
    imgV.center                           = CGPointMake(kMainScreenWidth / 2, kMainScreenHeight / 2);
    imgV.bounds                           = CGRectMake(0, 0, kMainScreenWidth, kMainScreenWidth * scale);
    imgV.image                            = image;
    imgV.userInteractionEnabled           = YES;
    UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(p_saveToUserAlbum:)];
    UITapGestureRecognizer *tap           = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(p_hideWatchAvatarButton:)];
    [imgV addGestureRecognizer:longTap];
    [imgV addGestureRecognizer:tap];
    [self.watchAvatarButton addSubview:imgV];

    [self.navigationController setNavigationBarHidden:YES];
}

- (void)p_hideWatchAvatarButton:(id)sender {
    [self.navigationController setNavigationBarHidden:NO];

    [UIView animateWithDuration:0.3f
        animations:^{
            self.watchAvatarButton.alpha = 0.0f;
        }
        completion:^(BOOL finished) {
            [self.watchAvatarButton removeFromSuperview];
        }];
}

- (void)p_saveToUserAlbum:(UILongPressGestureRecognizer *)sender {
    if ([sender state] == UIGestureRecognizerStateBegan) {
        UIActionSheet *save   = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"保存图片" otherButtonTitles:nil];
        save.delegate         = self;
        save.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        save.tag              = LYDetailDataActionSheetEnumWatchAvatar;
        [save showInView:self.watchAvatarButton];
    }
}

#pragma mark - Getter

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = ({
            UITableView *tableView = [[UITableView alloc]
                initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64.f)
                        style:UITableViewStyleGrouped];
            [tableView registerNib:[UINib nibWithNibName:@"LYDetailDataDefalutTableViewCell" bundle:nil] forCellReuseIdentifier:LYDetailDataTableViewDefaultCellIdentity];
            [tableView registerNib:[UINib nibWithNibName:@"LYDetailDataPhotoTableViewCell" bundle:nil]
                forCellReuseIdentifier:LYDetailDataPhotoTableViewCellIdentity];
            [tableView registerClass:[LYDetailDataReceiveGiftTableViewCell class] forCellReuseIdentifier:LYDetailDataReceiveGiftTableViewCellIdentity];
            tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(CGFLOAT_MIN, CGFLOAT_MIN, CGFLOAT_MIN, CGFLOAT_MIN)];
            tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(CGFLOAT_MIN, CGFLOAT_MIN, CGFLOAT_MIN, CGFLOAT_MIN)];
            tableView.delegate        = self;
            tableView.dataSource      = self;
            [self.view addSubview:tableView];
            tableView;
        });
    }
    return _tableView;
}


/**
 *  个人信息头部视图
 */
- (UIView *)detailDataHeaderView {
    if (!_detailDataHeaderView) {
        _detailDataHeaderView =
            [[[NSBundle mainBundle] loadNibNamed:@"LYDetailDataHeaderView"
                                           owner:self
                                         options:nil] objectAtIndex:0];
        __weak typeof(self) weakSelf             = self;
        _detailDataHeaderView.playAuthVideoBlock = ^{
            [weakSelf p_playAuthVideo];
        };
        _detailDataHeaderView.foucsOnButtonBlock = ^{
            [weakSelf p_foucsOn];
        };
        _detailDataHeaderView.sendGiftButtonBlock = ^{
            [weakSelf p_sendGift];
        };
        _detailDataHeaderView.tapAvatarImageViewBlock = ^(UIImageView *imageView) {
            [weakSelf p_watchAvatarImage:imageView.image];
        };
    }
    return _detailDataHeaderView;
}

/**
 *  邀请形象认证的头部视图
 */
- (UIView *)invitateTableViewHeaderView {
    if (!_invitateTableViewHeaderView) {
        _invitateTableViewHeaderView = ({
            UIView *view =
                [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30.f)];

            UILabel *label  = [[UILabel alloc] init];
            label.font      = [UIFont systemFontOfSize:12.f];
            label.textColor = RGBCOLOR(213, 213, 213);
            label.text      = @"TA 未经过形象视频认证！";
            [label sizeToFit];
            label.frame = CGRectMake(14.f, (30.f - label.height) / 2.f, label.width,
                                     label.height);
            [view addSubview:label];

            UIButton *button = [[UIButton alloc] init];
            [button setTitle:@"点击邀请认证" forState:UIControlStateNormal];
            [button setTitleColor:RGBCOLOR(17, 198, 173)
                         forState:UIControlStateNormal];
            [button.titleLabel setFont:[UIFont systemFontOfSize:14.f]];
            [button addTarget:self
                          action:@selector(p_clickInviteVedioAuthButton:)
                forControlEvents:UIControlEventTouchUpInside];
            [button sizeToFit];
            button.frame = CGRectMake(CGRectGetMaxX(label.frame) + 5.f,
                                      (30.f - button.height) / 2.f, button.width, button.height);
            [view addSubview:button];
            view;
        });
    }
    return _invitateTableViewHeaderView;
}

// 包含发消息、加好友
- (UIView *)tableViewFooterView {
    if (!_tableViewFooterView) {
        _tableViewFooterView = ({
            UIView *view =
                [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 175.f)];
            UIButton *sendMessageButton = [[UIButton alloc]
                initWithFrame:CGRectMake(20.f, 40.f, SCREEN_WIDTH - 20.f * 2.f,
                                         44.f)];
            [sendMessageButton setTitle:@"发消息" forState:UIControlStateNormal];
            [sendMessageButton setTitleColor:[UIColor whiteColor]
                                    forState:UIControlStateNormal];
            sendMessageButton.backgroundColor = RGBCOLOR(17, 198, 173);
            [sendMessageButton addTarget:self
                                  action:@selector(p_sendMessage:)
                        forControlEvents:UIControlEventTouchUpInside];

            UIButton *addFriendButton = [[UIButton alloc]
                initWithFrame:CGRectMake(
                                  20.f, CGRectGetMaxY(sendMessageButton.frame) + 16.f,
                                  SCREEN_WIDTH - 20.f * 2.f, 44.f)];

            switch (self.status) {
                case LYDetailDataRelationShipEnumAdd:
                    [addFriendButton setTitle:@"加好友" forState:UIControlStateNormal];
                    break;
                case LYDetailDataRelationShipEnumDelete:
                    [addFriendButton setTitle:@"删除好友" forState:UIControlStateNormal];
                    break;
                case LYDetailDataRelationShipEnumIng:
                    [addFriendButton setTitle:@"已经发送申请加为好友"
                                     forState:UIControlStateNormal];
                    break;
            }

            [addFriendButton setTitleColor:RGBCOLOR(17, 198, 173)
                                  forState:UIControlStateNormal];
            addFriendButton.backgroundColor = [UIColor whiteColor];
            [addFriendButton addTarget:self
                                action:@selector(p_addFriend:)
                      forControlEvents:UIControlEventTouchUpInside];

            [view addSubview:sendMessageButton];
            [view addSubview:addFriendButton];
            view;
        });
    }
    return _tableViewFooterView;
}

- (BOOL)mySelf {
    return [self.userId isEqualToString:[LYUserService sharedInstance].userID];
}

#pragma mark - Setter

- (void)setUserId:(NSString *)userId {
    if ([userId isKindOfClass:[NSNumber class]]) {
        _userId = [NSString stringWithFormat:@"%@", userId];
        return;
    }
    _userId = userId;
}


@end
