//
//  DetailDataViewController.m
//  LvYue
//
//  Created by 广有射怪鸟事 on 15/10/8.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import "AllWordViewController.h"
#import "BuyVipViewController.h"
#import "ChatSendHelper.h"
#import "ChatViewController.h"
#import "DetailDataTableViewCell.h"
#import "DetailDataViewController.h"
#import "FriendsCirleViewController.h"
#import "KFAlertView.h"
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "LYUserService.h"
#import "MBProgressHUD+NJ.h"
#import "MyDetailInfoModel.h"
#import "MyDispositionViewController.h"
#import "MyInfoModel.h"
#import "OrderViewController.h"
#import "OtherVideoViewController.h"
#import "PublishRequirementViewController.h"
#import "ReportViewController.h"
#import "SendBuddyRequestMessageController.h"
#import "SkillListViewController.h"
#import "UIImageView+WebCache.h"
#import "VideoKnowViewController.h"
#import "VipInfoViewController.h"
#import "VipInfoViewController.h"
#import "bgView.h"
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface DetailDataViewController () <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate, UIScrollViewDelegate, DetailDataTableViewCellDelegate, KFAlertViewDelegte>

@property (nonatomic, strong) UIView *headView;
@property (nonatomic, strong) UIView *footView;
@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) UIView *changeNameView; //修改备注界面
@property (nonatomic, strong) UITextField *nameField; //修改备注text
@property (nonatomic, strong) UIButton *videoPlayBtn; //播放视频的按钮
@property (nonatomic, strong) bgView *bgView;         //半透明view

@property (nonatomic, strong) MyDetailInfoModel *detailModel;
@property (nonatomic, strong) MyInfoModel *infoModel;

@property (nonatomic, strong) NSString *remark;    //备注
@property (nonatomic, strong) NSString *status;    //好友状态 //0不是好友 1是好友
@property (nonatomic, strong) NSString *tradeNum;  //交易单数
@property (nonatomic, strong) NSString *isDefault; //是否屏蔽，0为否，1为是
@property (nonatomic, copy) NSString *videoUrl;    //认证视频url
@property (nonatomic, strong) NSMutableArray *photoArray;
@property (nonatomic, strong) NSMutableArray *videoArray; //ta的视频数组
@property (nonatomic, strong) NSMutableArray *photoArr;
@property (nonatomic, strong) NSMutableString *skill; //备注

@end

@implementation DetailDataViewController {
    UIImageView *headImg;
    UIButton *lookBtn;
    NSString *whichAct;

    UIView *moreView;
    NSString *isMoreShow;
    NSString *hongdou;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [moreView removeFromSuperview];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.title = @"详细资料";

    isMoreShow = @"0";

    moreView                    = [[UIView alloc] initWithFrame:CGRectMake(kMainScreenWidth - 110, 64, 140, 60)];
    moreView.backgroundColor    = [UIColor whiteColor];
    moreView.layer.cornerRadius = 4;


    //隐藏送红豆

    //    UIButton *giveRed = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    //    [giveRed setTitle:@"送红豆" forState:UIControlStateNormal];
    //    [giveRed setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    //    [giveRed.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
    //    [giveRed addTarget:self action:@selector(giveRed) forControlEvents:UIControlEventTouchUpInside];
    //    [moreView addSubview:giveRed];

    UIButton *report = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    [report setTitle:@"举报" forState:UIControlStateNormal];
    [report setTitleColor:[UIColor colorWithRed:29 / 255.0 green:189 / 255.0 blue:159 / 255.0 alpha:1] forState:UIControlStateNormal];
    [report.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
    [report addTarget:self action:@selector(report) forControlEvents:UIControlEventTouchUpInside];
    [moreView addSubview:report];

    //    UIButton *push = [[UIButton alloc] initWithFrame:CGRectMake(0, 40, 100, 40)];
    //    [push setTitle:@"向TA发布需求" forState:UIControlStateNormal];
    //    [push setTitleColor:[UIColor colorWithRed:29/255.0 green:189/255.0 blue:159/255.0 alpha:1] forState:UIControlStateNormal];
    //    [push.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
    //    [push addTarget:self action:@selector(push) forControlEvents:UIControlEventTouchUpInside];
    //    [moreView addSubview:push];

    [self createTableView];

    self.photoArray = [[NSMutableArray alloc] init];
    self.videoArray = [[NSMutableArray alloc] init];
    self.photoArr   = [[NSMutableArray alloc] init];

    if (self.friendId != [[LYUserService sharedInstance].userID integerValue]) {
        [self setRightButton:[UIImage imageNamed:@"more"] title:nil target:self action:@selector(moreClick)];
    }

    [self getDataFromWeb];
    [self getSkill];
}


- (void)dealloc {
    self.table.delegate   = nil;
    self.table.dataSource = nil;
}

- (void)createTableView {
    self.table                = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    self.table.delegate       = self;
    self.table.dataSource     = self;
    self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.table];
}

- (void)moreClick {
    if ([isMoreShow isEqualToString:@"0"]) {
        [self.view addSubview:moreView];
        isMoreShow = @"1";
    } else {
        [moreView removeFromSuperview];
        isMoreShow = @"0";
    }
}

#pragma mark 送红豆

- (void)giveRed {

    [[LYUserService sharedInstance] fetchLoginStateWithCompeletionBlock:^(UserLoginStateType type) {
        if (type == UserLoginStateTypeWaitToLogin) {
            [[LYUserService sharedInstance] jumpToLoginWithController:self];
        } else if (type == UserLoginStateTypeAlreadyLogin) {
            [[[UIAlertView alloc] initWithTitle:nil message:@"此功能暂未开通，尽请期待" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil] show];

            //            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"请输入赠送数量" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            //            alert.tag = 902;
            //            [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
            //
            //            UITextField *numField = [alert textFieldAtIndex:0];
            //            numField.placeholder = @"请输入红豆数量";
            //            numField.keyboardType = UIKeyboardTypeNumberPad;

            //            [alert show];
        }
    }];
}

//举报

- (void)report {

    [[LYUserService sharedInstance] fetchLoginStateWithCompeletionBlock:^(UserLoginStateType type) {
        if (type == UserLoginStateTypeWaitToLogin) {
            [[LYUserService sharedInstance] jumpToLoginWithController:self];
        } else if (type == UserLoginStateTypeAlreadyLogin) {
            ReportViewController *report = [[ReportViewController alloc] init];
            [self.navigationController pushViewController:report animated:YES];
        }
    }];
}


- (UIView *)createHeadView {

    NSMutableArray *imgViewArray = [[NSMutableArray alloc] init];
    NSInteger imgCount           = 0;

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 120)];
    //头像
    headImg = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 100, 100)];
    [headImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", IMAGEHEADER, self.infoModel.icon]] placeholderImage:[UIImage imageNamed:@"头像"]];
    headImg.layer.cornerRadius     = 4;
    headImg.contentMode            = UIViewContentModeScaleAspectFill;
    headImg.clipsToBounds          = YES;
    headImg.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap    = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(lookHead:)];
    [headImg addGestureRecognizer:tap];

    //vip标志
    UIImageView *vipImg = [[UIImageView alloc] initWithFrame:CGRectMake(2, 59, 20, 20)];

    [headImg addSubview:vipImg];

    [view addSubview:headImg];

    //名字
    UILabel *nameLabel      = [[UILabel alloc] initWithFrame:CGRectMake(125, 15, 110, 20)];
    nameLabel.text          = self.infoModel.name;
    nameLabel.textAlignment = NSTextAlignmentLeft;
    nameLabel.font          = [UIFont systemFontOfSize:14.0];
    [nameLabel sizeToFit];
    [view addSubview:nameLabel];

    //内容
    UILabel *introduce               = [[UILabel alloc] initWithFrame:CGRectMake(125, CGRectGetMaxY(nameLabel.frame) + 10.f, kMainScreenWidth - 150, 50)];
    introduce.text                   = self.infoModel.signature;
    introduce.numberOfLines          = 0;
    introduce.font                   = [UIFont systemFontOfSize:13.0];
    introduce.userInteractionEnabled = YES;
    UITapGestureRecognizer *intro    = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(lookIntroduce:)];
    [introduce addGestureRecognizer:intro];
    [introduce sizeToFit];
    [view addSubview:introduce];

    //播放认证
    self.videoPlayBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(headImg.frame) - 33, CGRectGetMaxY(headImg.frame) - 33, 33, 33)];
    //self.videoPlayBtn = [[UIButton alloc] initWithFrame:CGRectMake(kMainScreenWidth -40, CGRectGetMaxY(headImg.frame)-33, 33, 33)];
    [view addSubview:self.videoPlayBtn];

    UIView *iconView    = [[UIView alloc] initWithFrame:CGRectMake(125.f, 95, 130, 18)];
    UIImageView *sexImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 15, 18)];
    [iconView addSubview:sexImg];

    UILabel *ageLabel  = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(sexImg.frame) + 5, 0, 20, 20)];
    ageLabel.font      = [UIFont systemFontOfSize:10];
    ageLabel.text      = [NSString stringWithFormat:@"%ld", (long) self.infoModel.age];
    ageLabel.textColor = [UIColor blackColor];
    [iconView addSubview:ageLabel];

    UIImageView *starImg = [[UIImageView alloc] initWithFrame:CGRectMake(50, 0, 18, 18)];
    starImg.image        = [UIImage imageNamed:@"star-3"];
    [iconView addSubview:starImg];

    UIImageView *firstImg = [[UIImageView alloc] initWithFrame:CGRectMake(73, 0, 18, 18)];
    [iconView addSubview:firstImg];

    UIImageView *secondImg = [[UIImageView alloc] initWithFrame:CGRectMake(96, 0, 18, 18)];
    [iconView addSubview:secondImg];

    UIImageView *thirdImg = [[UIImageView alloc] initWithFrame:CGRectMake(119, 0, 18, 18)];
    [iconView addSubview:thirdImg];

    UIImageView *fourImg = [[UIImageView alloc] initWithFrame:CGRectMake(142, 0, 18, 18)];
    [iconView addSubview:fourImg];

    if (self.infoModel.sex == 0) {
        sexImg.image = [UIImage imageNamed:@"男"];
    } else if (self.infoModel.sex == 1) {
        sexImg.image = [UIImage imageNamed:@"女"];
    }
    if (self.infoModel.vip == 1) {
        vipImg.image = [UIImage imageNamed:@"vip"];
    }
    if (self.infoModel.auth_car == 2) {
        [imgViewArray addObject:@"车"];
        imgCount++;
    }
    if (self.infoModel.auth_edu == 2) {
        [imgViewArray addObject:@"学"];
        imgCount++;
    }
    if (self.infoModel.auth_identity == 2) {
        [imgViewArray addObject:@"证"];
        imgCount++;
    }
    if (self.infoModel.auth_video == 2) {
        [self.videoPlayBtn setBackgroundImage:[UIImage imageNamed:@"播放认证"] forState:UIControlStateNormal];
        [self.videoPlayBtn addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        //隐藏播放认证
        self.videoPlayBtn.hidden = YES;
        [self.videoPlayBtn setBackgroundImage:[UIImage imageNamed:@"邀请认证"] forState:UIControlStateNormal];
        [self.videoPlayBtn addTarget:self action:@selector(inviteVideo:) forControlEvents:UIControlEventTouchUpInside];
    }
    if (self.infoModel.type == 1) {
        [imgViewArray addObject:@"导"];
        imgCount++;
    }
    switch (imgViewArray.count) {
        case 1: {
            firstImg.image = [UIImage imageNamed:imgViewArray[0]];
        } break;
        case 2: {
            firstImg.image  = [UIImage imageNamed:imgViewArray[0]];
            secondImg.image = [UIImage imageNamed:imgViewArray[1]];
        } break;
        case 3: {
            firstImg.image  = [UIImage imageNamed:imgViewArray[0]];
            secondImg.image = [UIImage imageNamed:imgViewArray[1]];
            thirdImg.image  = [UIImage imageNamed:imgViewArray[2]];
        } break;
        case 4: {
            firstImg.image  = [UIImage imageNamed:imgViewArray[0]];
            secondImg.image = [UIImage imageNamed:imgViewArray[1]];
            thirdImg.image  = [UIImage imageNamed:imgViewArray[2]];
            fourImg.image   = [UIImage imageNamed:imgViewArray[3]];
        } break;
        default:
            break;
    }

    [view addSubview:iconView];

    return view;
}

- (void)lookIntroduce:(UITapGestureRecognizer *)gestureRecognizer {
    AllWordViewController *all = [[AllWordViewController alloc] init];
    all.title                  = @"个人简介";
    all.detail                 = self.infoModel.signature;
    [self.navigationController pushViewController:all animated:YES];
}

- (void)lookHead:(UITapGestureRecognizer *)gestureRecognizer {

    lookBtn = [[UIButton alloc] initWithFrame:self.view.frame];
    [lookBtn setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:lookBtn];

    UIImageView *imgV                     = [[UIImageView alloc] init];
    UIImage *img                          = headImg.image;
    CGFloat scale                         = img.size.height / img.size.width;
    imgV.center                           = CGPointMake(kMainScreenWidth / 2, kMainScreenHeight / 2);
    imgV.bounds                           = CGRectMake(0, 0, kMainScreenWidth, kMainScreenWidth * scale);
    imgV.image                            = img;
    imgV.userInteractionEnabled           = YES;
    UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(saveToUserAlbum:)];
    UITapGestureRecognizer *tap           = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideBack:)];
    [imgV addGestureRecognizer:longTap];
    [imgV addGestureRecognizer:tap];
    [lookBtn addSubview:imgV];

    [self.navigationController setNavigationBarHidden:YES];
}

#pragma mark 长按保存到相册
- (void)saveToUserAlbum:(UILongPressGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {

        UIActionSheet *save = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"保存图片" otherButtonTitles:nil];
        save.delegate       = self;

        save.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        [save showInView:lookBtn];
        whichAct = @"save";
    }
}

- (void)hideBack:(UITapGestureRecognizer *)gestureRecognizer {

    [self.navigationController setNavigationBarHidden:NO];
    [UIView animateWithDuration:0.3 animations:^{
        lookBtn.alpha = 0.0;
    }
        completion:^(BOOL finished) {
            [lookBtn removeFromSuperview];
        }];
}

- (void)savePhoto {

    //保存到用户的本地相册中
    UIImageWriteToSavedPhotosAlbum(headImg.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

//图片保存回调处理方法
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {

    if (error) {
        [MBProgressHUD showError:@"保存失败"];
    } else {
        [MBProgressHUD showSuccess:@"保存成功"];
    }
}

- (UIView *)createFootView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 200)];

    UIButton *sendBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 70, kMainScreenWidth - 40, 40)];
    [sendBtn.layer setCornerRadius:4];
    [sendBtn setTitle:@"发消息" forState:UIControlStateNormal];
    [sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sendBtn setBackgroundColor:[UIColor colorWithRed:29 / 255.0 green:189 / 255.0 blue:159 / 255.0 alpha:1]];
    [sendBtn addTarget:self action:@selector(sendMessage:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:sendBtn];

    UIButton *addBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 130, kMainScreenWidth - 40, 40)];
    addBtn.tag       = 100;
    [addBtn.layer setCornerRadius:4];
    [addBtn setTitle:@"加好友" forState:UIControlStateNormal];
    [addBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [addBtn setBackgroundColor:[UIColor whiteColor]];
    [addBtn addTarget:self action:@selector(handleBuddy:) forControlEvents:UIControlEventTouchUpInside];

    if ([self.status integerValue] == 0) {
        [view addSubview:addBtn];
    } else if ([self.status integerValue] == 2) {
        [view addSubview:addBtn];
        addBtn.tag = 200;
        [addBtn setBackgroundColor:[UIColor colorWithRed:0.185 green:0.753 blue:0.057 alpha:1.000]];
        [addBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [addBtn setTitle:@"通过验证" forState:UIControlStateNormal];
    } else {
        [view addSubview:addBtn];
        [addBtn setTitle:@"删除好友" forState:UIControlStateNormal];
        [addBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        addBtn.tag = 300;
    }

    return view;
}

#pragma mark 网络请求
- (void)getSkill {
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/need/mySkillList", REQUESTHEADER] andParameter:@{ @"user_id": [NSString stringWithFormat:@"%ld", (long) self.friendId] } success:^(id successResponse) {
        MLOG(@"结果:%@", successResponse);
        if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
            NSArray *array = successResponse[@"data"][@"mySkills"];
            _skill         = [[NSMutableString alloc] init];
            for (NSDictionary *dic in array) {
                [_skill appendString:[NSString stringWithFormat:@"%@,", dic[@"name"]]];
            }
            if (_skill.length > 0) {
                NSRange range = NSMakeRange(_skill.length - 1, 1);
                [_skill deleteCharactersInRange:range];
            }
            [self.table reloadData];
        } else {
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"msg"]]];
        }
    }
        andFailure:^(id failureResponse) {
            [MBProgressHUD showError:@"服务器繁忙,请重试"];
        }];
}


- (void)getDataFromWeb {
    [[LYUserService sharedInstance] fetchLoginStateWithCompeletionBlock:^(UserLoginStateType type) {
        if (type == UserLoginStateTypeWaitToLogin) { // 未登录
            [MBProgressHUD showMessage:nil];
            NSString *str = [NSString stringWithFormat:@"%ld", (long) self.friendId];
            [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/userFriend/getInfo", REQUESTHEADER] andParameter:@{ @"friend_user_id": str,
                                                                                                                                           @"isToristEnter": @"1" }
                success:^(id successResponse) {
                    MLOG(@"结果:%@", successResponse);
                    [MBProgressHUD hideHUD];
                    if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
                        self.infoModel   = [[MyInfoModel alloc] initWithDict:successResponse[@"data"][@"user"]];
                        self.detailModel = [[MyDetailInfoModel alloc] initWithDict:successResponse[@"data"][@"userDetail"]];
                        if ([successResponse[@"data"][@"remark"] isKindOfClass:[NSNull class]]) {
                            self.remark = @"";
                        } else {
                            self.remark = successResponse[@"data"][@"remark"];
                        }
                        self.status     = successResponse[@"data"][@"status"];
                        self.tradeNum   = successResponse[@"data"][@"tradeNum"];
                        self.photoArray = successResponse[@"data"][@"photos"];
                        self.videoArray = successResponse[@"data"][@"video"];

                        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/imgList", REQUESTHEADER] andParameter:@{ @"user_id": [NSString stringWithFormat:@"%ld", (long) self.friendId] } success:^(id successResponse) {
                            MLOG(@"结果:%@", successResponse);
                            if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
                                self.photoArr = successResponse[@"data"][@"list"];

                                self.headView = [self createHeadView];
                                [self.table reloadData];
                            } else {
                            }
                        }
                            andFailure:^(id failureResponse){

                            }];

                        if (self.infoModel.type == 1) {
                            if (![[NSString stringWithFormat:@"%ld", (long) self.friendId] isEqualToString:[NSString stringWithFormat:@"%@", [LYUserService sharedInstance].userID]]) {
                                UIButton *buyBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 80, 100, 40)];
                                [buyBtn setTitle:@"咨询他" forState:UIControlStateNormal];
                                [buyBtn setTitleColor:[UIColor colorWithRed:29 / 255.0 green:189 / 255.0 blue:159 / 255.0 alpha:1] forState:UIControlStateNormal];
                                [buyBtn.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
                                [buyBtn addTarget:self action:@selector(buyGuide) forControlEvents:UIControlEventTouchUpInside];
                                [moreView addSubview:buyBtn];
                            }
                        } else {
                            moreView.frame = CGRectMake(kMainScreenWidth - 110, 64, 100, 60);
                        }

                        [kAppDelegate.dataBaseQueue inDatabase:^(FMDatabase *db) {
                            //矫正本地数据库
                            //如果数据库打开成功
                            if ([kAppDelegate.dataBase open]) {
                                //如果用户模型在本地数据库表中没有，则插入，否则更新
                                NSString *findSql   = [NSString stringWithFormat:@"SELECT * FROM '%@' WHERE userID = '%@'", @"User", [NSString stringWithFormat:@"%ld", (long) self.infoModel.id]];
                                FMResultSet *result = [kAppDelegate.dataBase executeQuery:findSql];
                                if ([result resultCount]) { //如果查询结果有数据
                                    //更新对应数据
                                    NSString *updateSql = [NSString stringWithFormat:@"UPDATE '%@' SET name = '%@',remark = '%@',icon = '%@' WHERE userID = '%@'", @"User", self.infoModel.name, self.remark, [NSString stringWithFormat:@"%@%@", IMAGEHEADER, self.infoModel.icon], [NSString stringWithFormat:@"%ld", (long) self.infoModel.id]];
                                    BOOL isSuccess      = [kAppDelegate.dataBase executeUpdate:updateSql];
                                    if (isSuccess) {
                                        MLOG(@"更新数据成功!");
                                    } else {
                                        MLOG(@"更新数据失败!");
                                    }
                                } else { //如果查询结果没有数据
                                    //插入相应数据
                                    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO '%@'('%@','%@','%@','%@') VALUES('%@','%@','%@','%@')", @"User", @"userID", @"name", @"remark", @"icon", [NSString stringWithFormat:@"%ld", (long) self.infoModel.id], self.infoModel.name, self.remark, [NSString stringWithFormat:@"%@%@", IMAGEHEADER, self.infoModel.icon]];
                                    BOOL isSuccess      = [kAppDelegate.dataBase executeUpdate:insertSql];
                                    if (isSuccess) {
                                        MLOG(@"插入数据成功!");
                                    } else {
                                        MLOG(@"插入数据失败!");
                                    }
                                }
                                [kAppDelegate.dataBase close];
                            }
                        }];
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

        else if (type == UserLoginStateTypeAlreadyLogin) {
            [MBProgressHUD showMessage:nil];
            NSString *str = [NSString stringWithFormat:@"%ld", (long) self.friendId];
            [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/userFriend/getInfo", REQUESTHEADER] andParameter:@{ @"friend_user_id": str,
                                                                                                                                           @"user_id": [LYUserService sharedInstance].userID }
                success:^(id successResponse) {
                    MLOG(@"个人资料的结果:%@", successResponse);
                    [MBProgressHUD hideHUD];
                    if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
                        self.infoModel   = [[MyInfoModel alloc] initWithDict:successResponse[@"data"][@"user"]];
                        self.detailModel = [[MyDetailInfoModel alloc] initWithDict:successResponse[@"data"][@"userDetail"]];
                        if ([successResponse[@"data"][@"remark"] isKindOfClass:[NSNull class]]) {
                            self.remark = @"";
                        } else {
                            self.remark = successResponse[@"data"][@"remark"];
                        }
                        self.status     = successResponse[@"data"][@"status"];
                        self.tradeNum   = successResponse[@"data"][@"tradeNum"];
                        self.photoArray = successResponse[@"data"][@"photos"];
                        self.videoArray = successResponse[@"data"][@"video"];
                        self.isDefault  = [NSString stringWithFormat:@"%@", successResponse[@"data"][@"isdefault"]];
                        self.videoUrl   = [NSString stringWithFormat:@"%@", successResponse[@"data"][@"userDetail"][@"auth_video_path"]];
                        //如果不是本人才有加好友和发消息
                        if (![[NSString stringWithFormat:@"%ld", (long) self.friendId] isEqualToString:[NSString stringWithFormat:@"%@", [LYUserService sharedInstance].userID]]) {
                            self.footView = [self createFootView];
                        }

                        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/imgList", REQUESTHEADER] andParameter:@{ @"user_id": [NSString stringWithFormat:@"%ld", (long) self.friendId] } success:^(id successResponse) {
                            MLOG(@"结果:%@", successResponse);
                            if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
                                self.photoArr = successResponse[@"data"][@"list"];

                                self.headView = [self createHeadView];
                                [self.table reloadData];
                            } else {
                            }
                        }
                            andFailure:^(id failureResponse){

                            }];


                        if (self.infoModel.type == 1) {
                            if (![[NSString stringWithFormat:@"%ld", (long) self.friendId] isEqualToString:[NSString stringWithFormat:@"%@", [LYUserService sharedInstance].userID]]) {
                                UIButton *buyBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 80, 100, 40)];
                                [buyBtn setTitle:@"咨询Ta" forState:UIControlStateNormal];
                                [buyBtn setTitleColor:[UIColor colorWithRed:29 / 255.0 green:189 / 255.0 blue:159 / 255.0 alpha:1] forState:UIControlStateNormal];
                                [buyBtn.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
                                [buyBtn addTarget:self action:@selector(buyGuide) forControlEvents:UIControlEventTouchUpInside];
                                [moreView addSubview:buyBtn];
                            }
                        } else {
                            moreView.frame = CGRectMake(kMainScreenWidth - 110, 64, 100, 80);
                        }

                        [kAppDelegate.dataBaseQueue inDatabase:^(FMDatabase *db) {
                            //矫正本地数据库
                            //如果数据库打开成功
                            if ([kAppDelegate.dataBase open]) {
                                //如果用户模型在本地数据库表中没有，则插入，否则更新
                                NSString *findSql   = [NSString stringWithFormat:@"SELECT * FROM '%@' WHERE userID = '%@'", @"User", [NSString stringWithFormat:@"%ld", (long) self.infoModel.id]];
                                FMResultSet *result = [kAppDelegate.dataBase executeQuery:findSql];
                                if ([result resultCount]) { //如果查询结果有数据
                                    //更新对应数据
                                    NSString *updateSql = [NSString stringWithFormat:@"UPDATE '%@' SET name = '%@',remark = '%@',icon = '%@' WHERE userID = '%@'", @"User", self.infoModel.name, self.remark, [NSString stringWithFormat:@"%@%@", IMAGEHEADER, self.infoModel.icon], [NSString stringWithFormat:@"%ld", (long) self.infoModel.id]];
                                    BOOL isSuccess      = [kAppDelegate.dataBase executeUpdate:updateSql];
                                    if (isSuccess) {
                                        MLOG(@"更新数据成功!");
                                    } else {
                                        MLOG(@"更新数据失败!");
                                    }
                                } else { //如果查询结果没有数据
                                    //插入相应数据
                                    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO '%@'('%@','%@','%@','%@') VALUES('%@','%@','%@','%@')", @"User", @"userID", @"name", @"remark", @"icon", [NSString stringWithFormat:@"%ld", (long) self.infoModel.id], self.infoModel.name, self.remark, [NSString stringWithFormat:@"%@%@", IMAGEHEADER, self.infoModel.icon]];
                                    BOOL isSuccess      = [kAppDelegate.dataBase executeUpdate:insertSql];
                                    if (isSuccess) {
                                        MLOG(@"插入数据成功!");
                                    } else {
                                        MLOG(@"插入数据失败!");
                                    }
                                }
                                [kAppDelegate.dataBase close];
                            }
                        }];
                    } else {
                        [MBProgressHUD hideHUD];
                        [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"msg"]]];
                    }
                }
                andFailure:^(id failureResponse) {
                    [MBProgressHUD hideHUD];
                    [MBProgressHUD showError:@"服务器繁忙,请重试"];
                }];

            [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/getDetailInfo", REQUESTHEADER] andParameter:@{ @"id": [NSString stringWithFormat:@"%@", [LYUserService sharedInstance].userID] } success:^(id successResponse) {
                MLOG(@"获取红豆:%@", successResponse);
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
                    hongdou = [NSString stringWithFormat:@"%@", successResponse[@"data"][@"user"][@"hongdou"]];
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
    }];
}

#pragma mark 咨询他事件

- (void)buyGuide {

    [[LYUserService sharedInstance] fetchLoginStateWithCompeletionBlock:^(UserLoginStateType type) {
        if (type == UserLoginStateTypeWaitToLogin) {
            [[LYUserService sharedInstance] jumpToLoginWithController:self];
        } else if (type == UserLoginStateTypeAlreadyLogin) {
            if ([[LYUserService sharedInstance].userDetail.isVip isEqualToString:@"0"]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"您需要开通会员才能咨询向导" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:@"去开通", nil];
                alert.delegate     = self;
                alert.tag          = 901;
                [alert show];
            } else {
                OrderViewController *order = [[OrderViewController alloc] init];
                order.guideName            = self.infoModel.name;
                order.guideNum             = self.detailModel.contact;
                order.guidePrice           = self.detailModel.service_price;
                order.guideId              = [NSString stringWithFormat:@"%ld", (long) self.infoModel.id];
                [self.navigationController pushViewController:order animated:YES];
            }
        }
    }];
}

- (void)push {
    PublishRequirementViewController *prVC = [[PublishRequirementViewController alloc] init];
    prVC.isPushSkill                       = NO;
    prVC.isFromDetail                      = YES;
    prVC.skills                            = _skill;
    [self.navigationController pushViewController:prVC animated:YES];
}

#pragma mark tableview代理方法

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 5;
    } else {
        return 7;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *array = [NSArray arrayWithObjects:@"备注", @"地区", @"个人动态", @"TA的视频", @"TA的气质", @"星级", @"学历", @"行业", @"完成单数", @"联系方式", @"TA的技能", @"屏蔽用户动态", nil];


    DetailDataTableViewCell *cell = [DetailDataTableViewCell myCellWithTableView:tableView indexPath:indexPath];

    cell.delegate = self;

    if (self.infoModel) {
        [cell fillDataWithModel:(MyInfoModel *) self.infoModel andModel:(MyDetailInfoModel *) self.detailModel andIndexPath:(NSIndexPath *) indexPath andArray:(NSArray *) array andRemark:(NSString *) self.remark andStatus:(NSString *) self.status andPhotoArray:(NSMutableArray *) self.photoArray andVideoArray:(NSMutableArray *) self.videoArray andPhotoArr:(NSMutableArray *) self.photoArr andSkill:(NSMutableString *) self.skill];
    }

    [cell.blockSwitch setOn:[self.isDefault integerValue]];
    [cell.blockSwitch addTarget:self action:@selector(changeBlock:) forControlEvents:UIControlEventValueChanged];
    if (indexPath.section == 1 && indexPath.row == 5) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    /**
     *  @author KF, 16-07-14 11:07:57
     *
     *  @brief 隐藏她的视频
     */
    if (indexPath.section == 0 && indexPath.row == 3) {
        cell.hidden = YES;
    }
    // 星级 完成单数隐藏
    if (indexPath.section == 1 && (indexPath.row == 3 || indexPath.row == 0)) {
        cell.hidden = YES;
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 星级 完成单数隐藏
    if (indexPath.section == 1 && (indexPath.row == 3 || indexPath.row == 0)) {
        return CGFLOAT_MIN;
    }

    if (indexPath.section == 0) {
        if (indexPath.row == 2 || indexPath.row == 3 || indexPath.row == 4) {
            /**
             *  @author KF, 16-07-14 11:07:57
             *
             *  @brief 隐藏她的视频
             */
            if (indexPath.row == 3) {
                return CGFLOAT_MIN;
            }
            return 105;
        } else {
            return 44;
        }
    } else {
        return 44;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 120;
    } else {
        return 0.1;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    if (section == 0) {
        return self.headView;
    } else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return 20;
    } else {
        return 200;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {

    if (section == 1) {
        return self.footView;
    } else {
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            if ([self.status integerValue] == 0 || [self.status integerValue] == 2) {
                return;
            } else {
                self.bgView = [[bgView alloc] initWithFrame:self.view.frame];
                [self.view addSubview:self.bgView];
                [self createChangeNameView];
            }
        }
        if (indexPath.row == 2) {
            [[LYUserService sharedInstance] fetchLoginStateWithCompeletionBlock:^(UserLoginStateType type) {
                if (type == UserLoginStateTypeWaitToLogin) {
                    [[LYUserService sharedInstance] jumpToLoginWithController:self];
                } else if (type == UserLoginStateTypeAlreadyLogin) { //朋友圈
//                    FriendsCirleViewController *fri = [[FriendsCirleViewController alloc] init];
//                    fri.userId                      = [NSString stringWithFormat:@"%ld", (long) self.infoModel.id];
//                    fri.isFriendsCircle             = NO;
//                    fri.personName                  = self.infoModel.name;
//                    [self.navigationController pushViewController:fri animated:YES];
                }
            }];
        }
        if (indexPath.row == 3) {
            //跳转到TA的视频频道
            OtherVideoViewController *dest = [[OtherVideoViewController alloc] init];
            if ([[LYUserService sharedInstance].userID isEqualToString:[NSString stringWithFormat:@"%ld", (long) _friendId]]) {
                dest.navTitle = @"我的频道";
            } else {
                MLOG(@"%@", self.infoModel.name);
                dest.navTitle = [NSString stringWithFormat:@"%@的频道", self.infoModel.name];
            }
            dest.userID = [NSString stringWithFormat:@"%ld", (long) self.friendId];
            [self.navigationController pushViewController:dest animated:YES];
        }
        if (indexPath.row == 4) {
            MyDispositionViewController *mdVC = [[MyDispositionViewController alloc] init];
            mdVC.userId                       = [NSString stringWithFormat:@"%ld", (long) self.friendId];
            [self.navigationController pushViewController:mdVC animated:YES];
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 5) {
            SkillListViewController *slVC = [[SkillListViewController alloc] init];
            slVC.userId                   = [NSString stringWithFormat:@"%ld", (long) self.infoModel.id];
            [self.navigationController pushViewController:slVC animated:YES];
        }
    }
}

#pragma mark 创建修改备注界面

//创建修改姓名view

- (void)createChangeNameView {

    self.changeNameView                    = [[UIView alloc] init];
    self.changeNameView.center             = CGPointMake(kMainScreenWidth / 2, kMainScreenHeight / 2 - 50);
    self.changeNameView.bounds             = CGRectMake(0, 0, kMainScreenWidth - 40, 130);
    self.changeNameView.backgroundColor    = [UIColor whiteColor];
    self.changeNameView.layer.cornerRadius = 6;
    [self.bgView addSubview:self.changeNameView];

    UILabel *editLabel      = [[UILabel alloc] init];
    editLabel.center        = CGPointMake(self.changeNameView.frame.size.width / 2, 20);
    editLabel.bounds        = CGRectMake(0, 0, 100, 20);
    editLabel.text          = @"编辑备注";
    editLabel.font          = [UIFont systemFontOfSize:14.0];
    editLabel.textAlignment = NSTextAlignmentCenter;
    [self.changeNameView addSubview:editLabel];

    self.nameField               = [[UITextField alloc] init];
    self.nameField.center        = CGPointMake(self.changeNameView.frame.size.width / 2, 60);
    self.nameField.bounds        = CGRectMake(0, 0, self.changeNameView.frame.size.width - 40, 30);
    self.nameField.textAlignment = NSTextAlignmentLeft;
    [self.nameField becomeFirstResponder];
    self.nameField.layer.cornerRadius = 4;
    self.nameField.layer.borderWidth  = 1;
    self.nameField.layer.borderColor  = RGBACOLOR(217, 217, 217, 1).CGColor;
    self.nameField.clearButtonMode    = UITextFieldViewModeWhileEditing;
    self.nameField.text               = self.remark;
    [self.nameField addTarget:self action:@selector(resignFirstResponder) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.changeNameView addSubview:self.nameField];

    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setFrame:CGRectMake(self.nameField.frame.origin.x, self.nameField.frame.origin.y + 40, self.nameField.frame.size.width / 2 - 5, 30)];
    cancelBtn.layer.borderWidth  = 1;
    cancelBtn.layer.borderColor  = RGBACOLOR(217, 217, 217, 1).CGColor;
    cancelBtn.layer.cornerRadius = 4;
    cancelBtn.titleLabel.font    = [UIFont systemFontOfSize:13.0];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(backChangeName) forControlEvents:UIControlEventTouchUpInside];
    [self.changeNameView addSubview:cancelBtn];

    UIButton *sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [sureBtn setFrame:CGRectMake(self.nameField.frame.origin.x + cancelBtn.frame.size.width + 5, self.nameField.frame.origin.y + 40, self.nameField.frame.size.width / 2 - 5, 30)];
    sureBtn.layer.borderWidth  = 1;
    sureBtn.layer.borderColor  = RGBACOLOR(217, 217, 217, 1).CGColor;
    sureBtn.layer.cornerRadius = 4;
    sureBtn.titleLabel.font    = [UIFont systemFontOfSize:13.0];
    [sureBtn setTitle:@"确定" forState:UIControlStateNormal];
    [sureBtn setTitleColor:RGBACOLOR(29, 189, 159, 1) forState:UIControlStateNormal];
    [sureBtn addTarget:self action:@selector(sureChangeName) forControlEvents:UIControlEventTouchUpInside];
    [self.changeNameView addSubview:sureBtn];
}

- (void)sureChangeName {

    if (self.nameField.text.length == 0) {
        self.remark = self.infoModel.name;
    } else {
        [MBProgressHUD showMessage:nil];
        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/userFriend/update", REQUESTHEADER] andParameter:@{ @"user_id": [NSString stringWithFormat:@"%@", [LYUserService sharedInstance].userID],
                                                                                                                                      @"friend_user_id": [NSString stringWithFormat:@"%ld", (long) self.friendId],
                                                                                                                                      @"remark": self.nameField.text }
            success:^(id successResponse) {
                MLOG(@"结果:%@", successResponse);
                [MBProgressHUD hideHUD];
                if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
                    [MBProgressHUD showSuccess:@"修改成功"];
                    self.remark = self.nameField.text;
                    [self backChangeName];
                    [self.table reloadData];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadBuddyList" object:nil];
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
}

- (void)backChangeName {
    [self.bgView removeFromSuperview];
    [self.bgView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

#pragma mark - 监听发送消息
- (void)sendMessage:(UIButton *)sender {
    if (_shouldPop) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        ChatViewController *chatVc = [[ChatViewController alloc] initWithChatter:[NSString stringWithFormat:@"%ld", (long) _friendId] isGroup:NO];
        if (_isContactsList2Detail) {
            chatVc.isContactsList2Chat = YES;
        }
        if (_remark && ![_remark isEqualToString:@""] && ![_remark isEqualToString:@"(null)"]) {
            chatVc.title = _remark;
        } else {
            chatVc.title = self.infoModel.name;
        }
        [self.navigationController pushViewController:chatVc animated:YES];
    }
}


#pragma mark - 处理好友关系
- (void)handleBuddy:(UIButton *)sender {
    if (sender.tag == 100) { //加好友
        SendBuddyRequestMessageController *dest = [[SendBuddyRequestMessageController alloc] init];
        dest.buddyID                            = [NSString stringWithFormat:@"%ld", (long) _friendId];
        [self.navigationController pushViewController:dest animated:YES];
    } else if (sender.tag == 300) { //删除好友
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"确定要删除联系人吗,删除之后聊天记录会被清除" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除" otherButtonTitles:nil];
        [actionSheet showInView:self.view];
        whichAct = @"delete";
    } else { //通过验证
        [MBProgressHUD showMessage:@"正在通过验证.."];
        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/messageVerify/updateIosStatus", REQUESTHEADER] andParameter:@{ @"user_id": [LYUserService sharedInstance].userID,
                                                                                                                                                  @"friend_id": [NSString stringWithFormat:@"%ld", (long) _friendId],
                                                                                                                                                  @"status": @"2" }
            success:^(id successResponse) {
                if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
                    //手动调用环信的"通过验证"方法
                    EMError *error = nil;
                    BOOL isSuccess = [[EaseMob sharedInstance].chatManager acceptBuddyRequest:[NSString stringWithFormat:@"%ld", (long) _friendId] error:&error];
                    if (isSuccess && !error) {
                        [MBProgressHUD hideHUD];
                        [MBProgressHUD showSuccess:@"通过验证"];
                        [self getDataFromWeb];
                        //提示通过了XX用户的验证信息(同意加好友)
                        EMConversation *conversation = [[EaseMob sharedInstance].chatManager conversationForChatter:[NSString stringWithFormat:@"%ld", (long) self.friendId] conversationType:eConversationTypeChat];
                        [ChatSendHelper sendTextMessageWithString:@"我已通过了你的好友验证请求"
                                                       toUsername:conversation.chatter
                                                      messageType:eMessageTypeChat
                                                requireEncryption:NO
                                                              ext:nil];
                        //手动更新好友列表
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMyBuddyList" object:nil];
                    }
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
}


//播放验证视频
- (void)playVideo:(UIButton *)sender {
    [MBProgressHUD showMessage:nil];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/video/openVideo", REQUESTHEADER] andParameter:@{
        @"user_id": [LYUserService sharedInstance].userID,
        @"video_id": @"1",
        @"fid": [NSString stringWithFormat:@"%ld", (long) self.friendId]
    }
        success:^(id successResponse) {
            /**
         199 开会员   198 去认证视频  200
         */
            if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
                [MBProgressHUD hideHUD];
                NSLog(@"视频播放：%@", successResponse);
                MPMoviePlayerViewController *player = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", IMAGEHEADER, self.videoUrl]]];
                player.moviePlayer.shouldAutoplay   = YES;
                [self presentMoviePlayerViewControllerAnimated:player];
            } else if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"199"]) {
                [MBProgressHUD hideHUD];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"：为了公平起见，你需要成为会员才能观看更多人的形象视频，否者每天只能观看六人的形象视频。" delegate:self cancelButtonTitle:nil otherButtonTitles:@"知道了", nil];
                alertView.tag          = 903;
                [alertView show];

            } else if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"198"]) {
                [MBProgressHUD hideHUD];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"：为了公平起见，你需要上传自己的形象认证视频才能观看更多人的形象视频，否者每天只能观看两人的形象视频。" delegate:self cancelButtonTitle:nil otherButtonTitles:@"知道了", nil];
                alertView.tag          = 904;
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

//邀请拍摄
- (void)inviteVideo:(UIButton *)sender {
    KFAlertView *alertView = [KFAlertView alertView];
    alertView.tag          = 1001;
    alertView.delegate     = self;
    //设置内容
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"ta还未通过形象视频认证，请谨慎联系！通过送礼并邀请ta认证形象视频吗？如果对方不认证，系统会返回您购买该礼物的金币。"];
    [str addAttribute:NSForegroundColorAttributeName value:RGBACOLOR(207, 73, 64, 1) range:NSMakeRange(0, 19)];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(18, 40)];
    UILabel *textlabel       = [[UILabel alloc] init];
    textlabel.attributedText = str;
    alertView.textLabel      = textlabel;
    [alertView initWithCancleBtnTitle:@"取消" cancleColor:[UIColor blackColor] confirmBtnTitle:@"送礼并邀请" confirmColor:THEME_COLOR];

    //sssss
    //显示
    [alertView show];
    return;
}

#pragma mark - DetailDataTableViewCellDelegate
//点击按钮，判断权限
- (void)detailcell:(DetailDataTableViewCell *)cell didClickButton:(UIButton *)sender contact:(NSString *)contact {

    KFAlertView *alertView = [KFAlertView alertView];
    alertView.tag          = 1002;
    alertView.delegate     = self;

    if ([[LYUserService sharedInstance].userDetail.isVip isEqualToString:@"0"]) { //非会员
        NSLog(@"非会员:%@", contact);

        //设置内容
        UILabel *label      = [[UILabel alloc] init];
        label.text          = @"只有会员才有资格查看";
        alertView.textLabel = label;
        [alertView initWithCancleBtnTitle:@"取消" cancleColor:[UIColor blackColor] confirmBtnTitle:@"成为会员" confirmColor:[UIColor redColor]];

        //显示
        [alertView show];
    } else { //会员
        NSLog(@"会员:%@", contact);

        //设置内容
        UILabel *textLabel  = [[UILabel alloc] init];
        textLabel.text      = contact;
        alertView.textLabel = textLabel;
        //设置按钮
        [alertView initWithCancleBtnTitle:@"取消" cancleColor:[UIColor blackColor] confirmBtnTitle:@"确定" confirmColor:[UIColor redColor]];
        //显示按钮
        [alertView show];
    }
}

#pragma mark - KFAlertViewDelegte
- (void)alertView:(KFAlertView *)alertView didClickKFButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1001) { //邀请视频拍摄
        if (buttonIndex == 0) {  //取消
            [alertView dismiss];
        } else if (buttonIndex == 1) {                                                    //确定
            if ([[LYUserService sharedInstance].userDetail.isVip isEqualToString:@"0"]) { //非会员

                [alertView dismiss];
                return;
            } else { //会员
                //邀请视频拍摄

                [alertView dismiss];
            }
        }

    } else if (alertView.tag == 1002) { //判断会员
        if (buttonIndex == 0) {         //取消
            [alertView dismiss];
        } else if (buttonIndex == 1) {                                                    //确定
            if ([[LYUserService sharedInstance].userDetail.isVip isEqualToString:@"0"]) { //非会员
                //成为会员
                VipInfoViewController *vc = [[VipInfoViewController alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
                [alertView dismiss];
            } else { //会员
                [alertView dismiss];
            }
        }
    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {

    if ([whichAct isEqualToString:@"save"]) {
        if (buttonIndex == 0) {
            [self savePhoto];
        }
    } else {
        if (buttonIndex == 0) {
            [MBProgressHUD showMessage:@"删除中.."];
            [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/userFriend/iosDelete", REQUESTHEADER] andParameter:@{ @"user_id": [LYUserService sharedInstance].userID,
                                                                                                                                             @"friend_user_id": [NSString stringWithFormat:@"%ld", (long) _friendId] }
                success:^(id successResponse) {
                    if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
                        //调用环信"删除好友"的方法
                        EMError *error = nil;
                        BOOL isSuccess = [[EaseMob sharedInstance].chatManager removeBuddy:[NSString stringWithFormat:@"%ld", (long) _friendId] removeFromRemote:YES error:&error];
                        if (isSuccess && !error) {
                            [MBProgressHUD hideHUD];
                            //删除之前的用户对话
                            [[EaseMob sharedInstance].chatManager removeConversationByChatter:[NSString stringWithFormat:@"%ld", (long) self.friendId] deleteMessages:YES append2Chat:YES];
                            //发送更新会话列表的通知
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"LY_ReloadConversationList" object:nil];
                            [MBProgressHUD showSuccess:@"删除成功"];
                            [self.navigationController popToRootViewControllerAnimated:YES];
                            //手动更新好友列表
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMyBuddyList" object:nil];
                        }
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
    }
}

#pragma mark UIAlertview代理
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 901) {
        if (buttonIndex == 1) {
            VipInfoViewController *info = [[VipInfoViewController alloc] init];
            [self.navigationController pushViewController:info animated:YES];
        }
    } else if (alertView.tag == 902) {
        if (buttonIndex == 1) {
            UITextField *text = [alertView textFieldAtIndex:0];
            if ([text.text integerValue] <= 0) {
                [MBProgressHUD showError:@"数量有误"];
                return;
            }
            if ([text.text integerValue] > [hongdou integerValue]) {
                [MBProgressHUD showError:@"余额不足"];
                return;
            }

            [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/present", REQUESTHEADER] andParameter:@{ @"user_id": [NSString stringWithFormat:@"%@", [LYUserService sharedInstance].userID],
                                                                                                                                     @"friend_id": [NSString stringWithFormat:@"%ld", (long) self.friendId],
                                                                                                                                     @"hongdou": text.text }
                success:^(id successResponse) {
                    MLOG(@"结果:%@", successResponse);
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                    if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
                        [MBProgressHUD showSuccess:@"赠送成功"];
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
    } else if (alertView.tag == 903) { //成为会员
        NSLog(@"%ld", (long) buttonIndex);
        if (buttonIndex == 0) {
            VipInfoViewController *buyVip = [[VipInfoViewController alloc] init];
            [self.navigationController pushViewController:buyVip animated:YES];
        }
    } else if (alertView.tag == 904) { //成为上传认证视频
        NSLog(@"%ld", (long) buttonIndex);
        if (buttonIndex == 0) {
            VideoKnowViewController *video = [[VideoKnowViewController alloc] init];
            [self.navigationController pushViewController:video animated:YES];
        }
    }
}

#pragma mark scrollview代理

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [moreView removeFromSuperview];
}

#pragma mark 屏蔽用户事件

- (void)changeBlock:(UISwitch *)sender {
    [[LYUserService sharedInstance] fetchLoginStateWithCompeletionBlock:^(UserLoginStateType type) {
        if (type == UserLoginStateTypeWaitToLogin) {
            [[LYUserService sharedInstance] jumpToLoginWithController:self];
            [sender setOn:![sender isOn] animated:YES];
        } else if (type == UserLoginStateTypeAlreadyLogin) {

            [MBProgressHUD showMessage:nil toView:self.view];

            if (![sender isOn]) {
                [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/userFriend/deleteShield", REQUESTHEADER] andParameter:@{ @"user_id": [NSString stringWithFormat:@"%@", [LYUserService sharedInstance].userID],
                                                                                                                                                    @"other_user_id": [NSString stringWithFormat:@"%ld", (long) self.friendId] }
                    success:^(id successResponse) {
                        MLOG(@"结果:%@", successResponse);
                        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                        if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
                            [MBProgressHUD showSuccess:@"解除屏蔽"];
                        } else {
                            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                            [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"msg"]]];
                            [sender setOn:![sender isOn] animated:YES];
                        }
                    }
                    andFailure:^(id failureResponse) {
                        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                        [MBProgressHUD showError:@"服务器繁忙,请重试"];
                        [sender setOn:![sender isOn] animated:YES];
                    }];
            } else {
                [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/userFriend/shield", REQUESTHEADER] andParameter:@{ @"user_id": [NSString stringWithFormat:@"%@", [LYUserService sharedInstance].userID],
                                                                                                                                              @"other_user_id": [NSString stringWithFormat:@"%ld", (long) self.friendId] }
                    success:^(id successResponse) {
                        MLOG(@"结果:%@", successResponse);
                        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                        if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
                            [MBProgressHUD showSuccess:@"屏蔽成功"];
                        } else {
                            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                            [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"msg"]]];
                            [sender setOn:![sender isOn] animated:YES];
                        }
                    }
                    andFailure:^(id failureResponse) {
                        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                        [MBProgressHUD showError:@"服务器繁忙,请重试"];
                        [sender setOn:![sender isOn] animated:YES];
                    }];
            }
        }
    }];
}


@end
