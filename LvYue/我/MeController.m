//
//  MyCenterViewController.m
//  澜庭
//
//  Created by 广有射怪鸟事 on 15/9/25.
//  Copyright (c) 2015年 刘瀚韬. All rights reserved.
//

#import "MeController.h"
#import "MyCenterTableViewCell.h"
#import "MyInfomationViewController.h"
#import "ChangeHeadViewController.h"
#import "KnowViewController.h"
#import "SettingViewController.h"
#import "FinishKnowViewController.h"
#import "BuyVipViewController.h"
#import "VipInfoViewController.h"
#import "CollectViewController.h"
#import "LYUserService.h"
#import "LYHttpPoster.h"
#import "MBProgressHUD+NJ.h"
#import "MyInfoModel.h"
#import "MyDetailInfoModel.h"
#import "OrderViewController.h"
#import "AllOrderViewController.h"
#import "FriendsCirleViewController.h"
#import "MyLvyueViewController.h"
#import "UIView+SZYOperation.h"
#import "UIImageView+WebCache.h"
#import "MyLiveViewController.h"
#import "MyRedBeanViewController.h"
#import "OtherVideoViewController.h"
#import "MyDispositionViewController.h"
#import "MyAccountViewController.h"
#import "BuyRedBeanViewController.h"
#import "BuyCoinViewController.h"
#import "UMSocial.h"

@interface MeController ()<UITableViewDataSource,UITableViewDelegate,UMSocialUIDelegate>

@property (nonatomic,strong) NSArray *iconArray;
@property (nonatomic,strong) NSArray *sbArray;
@property (nonatomic,strong) NSMutableArray *knowArray;
@property (nonatomic,strong) UIImage *headImage;
@property (nonatomic,strong) UITableView *table;
@property (nonatomic,strong) UIView *headerView;
@property (nonatomic,strong) UIImageView *changeBtn;
@property (nonatomic,strong) MyInfoModel *myInfoModel;
@property (nonatomic,strong) MyDetailInfoModel *myDetailInfoModel;
@property (nonatomic,strong) NSMutableArray *imgViewArray;
@property (nonatomic,assign) NSInteger imgCount;
@property (nonatomic,strong) NSString *locationString;
@property (nonatomic,strong) UIImageView *bgImg;
@property (nonatomic,strong) UIView *headView;


@end

@implementation MeController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];

    [[LYUserService sharedInstance] fetchLoginStateWithCompeletionBlock:^(UserLoginStateType type){
        if (type == UserLoginStateTypeWaitToLogin) {
            [self createHeaderView];
        }
        else {
            [self getDataFromWeb];
        }
    }];

}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.locationString = @"";
    
    self.headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 240)];
    
    //背景imageView
    self.bgImg = [[UIImageView alloc] initWithFrame:self.headView.frame];
    self.bgImg.image = [UIImage imageNamed:@"bg-1"];
    self.bgImg.userInteractionEnabled = YES;
    [self.headView addSubview:self.bgImg];
    
    [self createTableView];
    

#ifdef kEasyVersion
    
    self.iconArray = @[@"个人资料-1",@"个人动态-1",@"我的豆客",@"我的视频-1",@"我的气质",@"我的民宿",@"申请向导",@"全部订单-1"
//                       ,@"我的红豆-1"
                       ,@"设置-1"];
    self.sbArray = @[@"个人资料",@"个人动态",@"我的豆客",@"我的视频",@"我的气质",@"我的民宿",@"身份认证",@"全部订单"
//                     ,@"我的红豆"
                     ,@"设置"];
    
#else
    
    self.iconArray = @[@"个人资料-1",@"个人动态-1",
                       @"我的豆客",
                       @"我的视频-1",@"我的气质",@"申请向导",@"成为会员-1"
//                       ,@"全部订单-1",@"我的红豆-1"
                       ,@"分享好友",@"设置-1"];
    self.sbArray = @[@"个人资料",@"个人动态",
                     @"我的豆客",
                     @"我的视频",@"我的相册",@"身份认证",@"成为会员"
//                     ,@"全部订单",@"我的红豆"
                     ,@"分享好友",@"设置"];
    
#endif
    
    self.knowArray = [[NSMutableArray alloc] init];
    
    self.view.backgroundColor = RGBACOLOR(238, 238, 238, 1);
    
    self.imgViewArray = [[NSMutableArray alloc] init];

}

- (void)createHeaderView{
    
    [self.bgImg removeAllSubViews];
    
    [self.imgViewArray removeAllObjects];
    self.imgCount = 0;
    
    //钱包btn
    UIButton *walletBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 45, 35, 25, 25)];
    [walletBtn setBackgroundImage:[UIImage imageNamed:@"钱包"] forState:UIControlStateNormal];
    [walletBtn addTarget:self action:@selector(turnToCoin:) forControlEvents:UIControlEventTouchUpInside];
    //[self.bgImg addSubview:walletBtn];
    
    UIView *headImageBg = [[UIView alloc] initWithFrame:CGRectMake(self.bgImg.frame.size.width / 2 - 51, 68, 102, 102)];
    headImageBg.backgroundColor = [UIColor clearColor];
    headImageBg.layer.cornerRadius = 51;
    headImageBg.layer.borderWidth = 1.0f;
    headImageBg.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.5].CGColor;
    [self.bgImg addSubview:headImageBg];
    
    //更换头像btn
    self.changeBtn = [[UIImageView alloc]initWithFrame:CGRectMake(self.bgImg.frame.size.width / 2 - 45, 75, 90, 90)];
    [[LYUserService sharedInstance] fetchLoginStateWithCompeletionBlock:^(UserLoginStateType type){
        if (type == UserLoginStateTypeWaitToLogin) {
            self.changeBtn.image = [UIImage imageNamed:@"默认头像"];
        }
        else {
            [self.changeBtn sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,self.myInfoModel.icon]] placeholderImage:[UIImage imageNamed:@"默认头像"]];
        }
    }];

    self.changeBtn.layer.masksToBounds = YES;
    self.changeBtn.layer.cornerRadius = 45;
    self.changeBtn.layer.borderColor = [UIColor colorWithRed:216/255.0 green:216/255.0 blue:216/255.0 alpha:1].CGColor;
    self.changeBtn.layer.borderWidth = 4.0f;
    UITapGestureRecognizer *changeHead = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeHeadAction)];
    self.changeBtn.userInteractionEnabled = YES;
    [self.changeBtn addGestureRecognizer:changeHead];
    [self.bgImg addSubview:self.changeBtn];
    
    //vip标示
    UIImageView *vipImg = [[UIImageView alloc] initWithFrame:CGRectMake(self.changeBtn.frame.size.width - 23 + self.changeBtn.frame.origin.x, self.changeBtn.frame.size.height - 24 + self.changeBtn.frame.origin.y, 23, 24)];
    vipImg.image = [UIImage imageNamed:@"vip"];
    if (self.myInfoModel.vip == 0 ||!self.myInfoModel.vip) {
        vipImg.hidden = YES;
    }
    [self.bgImg addSubview:vipImg];
    
    //地区label
    NSString *locationString = self.myDetailInfoModel.city;
    if (!locationString) {
        locationString = @"地点在哪儿";
    }
    else if ([[NSString stringWithFormat:@"%@",locationString] isEqualToString:@""]) {
        locationString = @"未设置城市";
    }
    else{
        locationString = self.myDetailInfoModel.cityName;
    }
    int leng = 0;
    if ([NSString stringWithFormat:@"%@",locationString].length <= 2) {
        leng = 50;
    }
    else if ([NSString stringWithFormat:@"%@",locationString].length >= 6){
        leng = 90;
    }
    else{
        leng = (int)[NSString stringWithFormat:@"%@",locationString].length * 18;
    }
    
    UILabel *locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.changeBtn.frame.origin.x - leng - 10, self.changeBtn.frame.origin.y + 55, leng, 25)];
    locationLabel.font = [UIFont systemFontOfSize:14.0];
    locationLabel.text = [NSString stringWithFormat:@"%@",locationString];
    locationLabel.textColor = [UIColor whiteColor];
    locationLabel.textAlignment = NSTextAlignmentCenter;
    locationLabel.backgroundColor = [UIColor clearColor];
    locationLabel.layer.masksToBounds = YES;
    locationLabel.layer.cornerRadius = 12.5;
    locationLabel.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.5];
    [self.bgImg addSubview:locationLabel];
    
    //认证label
    UILabel *knowLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.changeBtn.frame.origin.x + 108, self.changeBtn.frame.origin.y + 33, 90, 25)];
    knowLabel.font = [UIFont systemFontOfSize:14.0];
    if (self.myInfoModel.type == 0) {
        knowLabel.text = @"未认证向导";
    }
    else{
        knowLabel.text = @"已认证向导";
    }
    knowLabel.textColor = [UIColor whiteColor];
    knowLabel.textAlignment = NSTextAlignmentCenter;
    knowLabel.backgroundColor = [UIColor clearColor];
    knowLabel.layer.masksToBounds = YES;
    knowLabel.layer.cornerRadius = 12.5;
    knowLabel.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.5];
#warning 未认证
    //[self.bgImg addSubview:knowLabel];
    
    //名字label
    NSString *name;
    if ([self.myInfoModel.name isEqualToString:@""]||!self.myInfoModel.name) {
        name = @"游客";
    }
    else {
        name = self.myInfoModel.name;
    }
    
    CGRect rect = [name boundingRectWithSize:CGSizeMake(SCREEN_WIDTH, 20) options:NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:19]} context:nil];
    UILabel *nameLabel = [[UILabel alloc] init];
    if (kMainScreenWidth == 320) {
        nameLabel.center = CGPointMake(self.bgImg.frame.size.width / 2, self.changeBtn.frame.origin.y + self.changeBtn.frame.size.height + 20);
    }
    else{
        nameLabel.center = CGPointMake(self.bgImg.frame.size.width / 2, self.changeBtn.frame.origin.y + self.changeBtn.frame.size.height + 20);
    }
    nameLabel.bounds = CGRectMake(0, 0, rect.size.width, 20);
    nameLabel.font = [UIFont systemFontOfSize:19.0];
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.text = name;
    nameLabel.textAlignment = NSTextAlignmentCenter;
    [self.bgImg addSubview:nameLabel];
    
    //一堆图标的view
    UIView *iconView = [[UIView alloc] init];
    
    //性别图标
    UIImageView *sexImg = [[UIImageView alloc] initWithFrame:CGRectMake(self.bgImg.frame.size.width / 2 - 20, nameLabel.frame.origin.y + 34, 15, 15)];
    if (!self.myInfoModel.sex) {
        sexImg.hidden = YES;
    }
    else if (self.myInfoModel.sex == 0) {
        sexImg.image = [UIImage imageNamed:@"男"];
    }
    else{
        sexImg.image = [UIImage imageNamed:@"女"];
    }
    [self.bgImg addSubview:sexImg];
    
    //年龄label
    UILabel *ageLabel = [[UILabel alloc] initWithFrame:CGRectMake(sexImg.frame.origin.x + sexImg.frame.size.width + 5, nameLabel.frame.origin.y + 30, 60, 20)];
    ageLabel.textAlignment = NSTextAlignmentLeft;
    if (!self.myInfoModel.age||self.myInfoModel.age == 0) {
        ageLabel.text = @"未知年龄";
    }
    else {
        ageLabel.text = [NSString stringWithFormat:@"%ld岁",(long)self.myInfoModel.age];
    }
    ageLabel.font = [UIFont systemFontOfSize:14.0];
    ageLabel.textColor = [UIColor whiteColor];
    [self.bgImg addSubview:ageLabel];
    
    [[LYUserService sharedInstance] fetchLoginStateWithCompeletionBlock:^(UserLoginStateType type){
        if (type == UserLoginStateTypeWaitToLogin) {
            
        }
        else {
            //星星图标
            UIImageView *starImg = [[UIImageView alloc] initWithFrame:CGRectMake(5, 0, 18, 18)];
            starImg.image = [UIImage imageNamed:@"star-3"];
            [iconView addSubview:starImg];
            
            //第一个认证图标（车辆认证）
            UIImageView *firstImg = [[UIImageView alloc] initWithFrame:CGRectMake(starImg.frame.origin.x + starImg.frame.size.width + 2, 0, 18, 18)];
            
            //第二个（学历认证)
            UIImageView *secondImg = [[UIImageView alloc] initWithFrame:CGRectMake(firstImg.frame.origin.x + firstImg.frame.size.width + 2, 0, 18, 18)];
            
            //第三个（身份证认证)
            UIImageView *thirdImg = [[UIImageView alloc] initWithFrame:CGRectMake(secondImg.frame.origin.x + secondImg.frame.size.width + 2, 0, 18, 18)];
            
            //第四个（导游认证）
            UIImageView *fourthImg = [[UIImageView alloc] initWithFrame:CGRectMake(thirdImg.frame.origin.x + thirdImg.frame.size.width + 2, 0, 18, 18)];
            
            if (self.myInfoModel.auth_car == 2) {
                [self.imgViewArray addObject:@"车"];
                self.imgCount ++;
            }
            if (self.myInfoModel.auth_edu == 2) {
                [self.imgViewArray addObject:@"学"];
                self.imgCount ++;
            }
            if (self.myInfoModel.auth_identity == 2) {
                [self.imgViewArray addObject:@"证"];
                self.imgCount ++;
            }
            if (self.myInfoModel.type == 1) {
                [self.imgViewArray addObject:@"导"];
                self.imgCount ++;
            }
            
            switch (self.imgViewArray.count) {
                case 1:
                {
                    firstImg.image = [UIImage imageNamed:self.imgViewArray[0]];
                    [iconView addSubview:firstImg];
                }
                    break;
                case 2:
                {
                    firstImg.image = [UIImage imageNamed:self.imgViewArray[0]];
                    secondImg.image = [UIImage imageNamed:self.imgViewArray[1]];
                    [iconView addSubview:firstImg];
                    [iconView addSubview:secondImg];
                }
                    break;
                case 3:
                {
                    firstImg.image = [UIImage imageNamed:self.imgViewArray[0]];
                    secondImg.image = [UIImage imageNamed:self.imgViewArray[1]];
                    thirdImg.image = [UIImage imageNamed:self.imgViewArray[2]];
                    [iconView addSubview:firstImg];
                    [iconView addSubview:secondImg];
                    [iconView addSubview:thirdImg];
                }
                    break;
                case 4:
                {
                    firstImg.image = [UIImage imageNamed:self.imgViewArray[0]];
                    secondImg.image = [UIImage imageNamed:self.imgViewArray[1]];
                    thirdImg.image = [UIImage imageNamed:self.imgViewArray[2]];
                    fourthImg.image = [UIImage imageNamed:self.imgViewArray[3]];
                    [iconView addSubview:firstImg];
                    [iconView addSubview:secondImg];
                    [iconView addSubview:thirdImg];
                    [iconView addSubview:fourthImg];
                }
                    break;
                default:
                    break;
            }
            
            
            //    iconView.center = CGPointMake(self.bgImg.frame.size.width / 2, self.changeBtn.frame.origin.y + self.changeBtn.frame.size.height + 20);
            iconView.frame = CGRectMake(nameLabel.frame.origin.x + rect.size.width + 3, self.changeBtn.frame.origin.y + self.changeBtn.frame.size.height + 10, 63 + 20 * self.imgViewArray.count, 20);
            [self.bgImg addSubview:iconView];

        }
    }];

    
}

#pragma mark 网络请求

- (void)getDataFromWeb{
    
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/getDetailInfo",REQUESTHEADER] andParameter:@{@"id":[NSString stringWithFormat:@"%@",[LYUserService sharedInstance].userID]} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            NSDictionary *infoDict = successResponse[@"data"][@"user"];
            self.myInfoModel = [[MyInfoModel alloc] initWithDict:infoDict];
            NSDictionary *detailInfoDict = successResponse[@"data"][@"userDetail"];
            self.myDetailInfoModel = [[MyDetailInfoModel alloc] initWithDict:detailInfoDict];
            [self createHeaderView];
            [self.table reloadData];
        } else {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
}

- (void)createTableView{
    self.table = [[UITableView alloc] initWithFrame:CGRectMake(0, -20, kMainScreenWidth, kMainScreenHeight) style:UITableViewStyleGrouped];
    self.table.delegate = self;
    self.table.dataSource = self;
    self.table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:self.table];
}

//更换头像
- (void)changeHeadAction{
    [[LYUserService sharedInstance] fetchLoginStateWithCompeletionBlock:^(UserLoginStateType type){
        if (type == UserLoginStateTypeWaitToLogin) {
            
        }
        else {
            ChangeHeadViewController *change = [[ChangeHeadViewController alloc] init];
            [change setHidesBottomBarWhenPushed:YES];
            change.headImage = self.changeBtn.image;
            change.name = self.myInfoModel.name;
            [self.navigationController pushViewController:change animated:YES];

        }
    }];

}

//购买金币
- (void)turnToCoin:(UIButton *)sender {
#warning 购买金币
    BuyCoinViewController* vc = [[BuyCoinViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];

}

//个人账户
- (void)turnToAccount {
    MyAccountViewController *myVC = [[MyAccountViewController alloc] init];
    myVC.myInfoModel = self.myInfoModel;
    [self.navigationController pushViewController:myVC animated:YES];
}

#pragma mark tableview代理方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {       //我的账户
        return 1;
    }
    if (section == 1) {       //个人资料
#ifdef kEasyVersion
        
        return 6;
        
#endif
        return 5;
    }
    else if (section == 2){   //身份认证
#ifdef kEasyVersion
        return 1;
#else
        return 2;
#endif
    }
    else{                    //设置
        return 2;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 240;
    }
    else{
        return 0.1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ((indexPath.section == 1&&indexPath.row == 2) || (indexPath.section == 2&&indexPath.row == 1)) {
        return CGFLOAT_MIN;
    }

    return 55;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    
    if (section == 0) {
        
        return self.headView;
    }
    else{
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MyCenterTableViewCell *cell = [MyCenterTableViewCell myCenterTableViewCellWithTableView:tableView andIndexPath:indexPath sbArray:self.sbArray iconArray:self.iconArray];
    
    if ((indexPath.section == 1 && indexPath.row == 2) || (indexPath.section == 2&&indexPath.row == 1)) {
        cell.hidden = YES;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [[LYUserService sharedInstance] fetchLoginStateWithCompeletionBlock:^(UserLoginStateType type){
        if (type == UserLoginStateTypeWaitToLogin) {
            [[LYUserService sharedInstance] jumpToLoginWithController:self.tabBarController];
        }
        else {
            MyInfomationViewController *myinfo = [[MyInfomationViewController alloc] init];
            if (indexPath.section == 0) {       //我的账户
                [self turnToAccount];
//                UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:@"下一版本功能" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil];
//                [alertView show];
                
            }
            if (indexPath.section == 1) {       //个人资料
                switch (indexPath.row) {
                    case 0:
                    {
                        [myinfo setHidesBottomBarWhenPushed:YES];
                        myinfo.id = self.myInfoModel.id;//id
                        myinfo.headImage = self.changeBtn.image;//头像
                        myinfo.introduceString = self.myInfoModel.signature;//个性签名
                        myinfo.userName = self.myInfoModel.name;//名字
                        myinfo.userSex = [NSString stringWithFormat:@"%ld", (long)self.myInfoModel.sex];//性别
                        myinfo.isKnowSex = [NSString stringWithFormat:@"%ld",(long)self.myInfoModel.auth_identity];//是否认证性别
                        myinfo.userAge = [NSString stringWithFormat:@"%ld",(long)self.myInfoModel.age];//年龄
                        myinfo.locationString = [NSString stringWithFormat:@"%@ %@",self.myDetailInfoModel.province,self.myDetailInfoModel.city];//地区，省份城市
                        myinfo.edu = self.myInfoModel.edu;//学历
                        myinfo.isKnowStudy = [NSString stringWithFormat:@"%ld",(long)self.myInfoModel.auth_edu];
                        myinfo.serviceMoneyString = self.myDetailInfoModel.service_price;//服务价格
                        myinfo.jobString = self.myDetailInfoModel.industry;//行业
                        myinfo.star = self.myInfoModel.score;//星级
                        myinfo.codeString = self.myInfoModel.mobile;//手机号
                        myinfo.isVip = [NSString stringWithFormat:@"%ld",(long)self.myInfoModel.vip];//是否会员
                        myinfo.signString = [NSMutableString stringWithFormat:@"%@",self.myDetailInfoModel.service_content];//服务项目
                        myinfo.canLive = [NSString stringWithFormat:@"%ld",(long)self.myDetailInfoModel.provide_stay];//是否提供食宿
                        myinfo.userEmail = self.myDetailInfoModel.contact;//联系方式（邮箱
                        myinfo.vip_time = self.myDetailInfoModel.vip_time;
                        myinfo.type = self.myInfoModel.type;
                        myinfo.is_show = self.myInfoModel.is_show;
                        if ([self.myDetailInfoModel.country isEqualToString:self.myDetailInfoModel.province]) {
                            myinfo.locationString = self.myDetailInfoModel.countryName;
                        }
                        else if ([self.myDetailInfoModel.province isEqualToString:self.myDetailInfoModel.city]){
                            myinfo.locationString = [NSString stringWithFormat:@"%@ %@",self.myDetailInfoModel.countryName,self.myDetailInfoModel.provinceName];
                        }
                        else{
                            myinfo.locationString = [NSString stringWithFormat:@"%@ %@ %@",self.myDetailInfoModel.countryName,self.myDetailInfoModel.provinceName,self.myDetailInfoModel.cityName];
                        }
                        [self.navigationController pushViewController:myinfo animated:YES];
                    }
                        break;
                        
                    case 1:
                    {
                        FriendsCirleViewController *friendsCirleViewController = [[FriendsCirleViewController alloc]init];
                        [friendsCirleViewController setHidesBottomBarWhenPushed:YES];
                        friendsCirleViewController.title = @"个人动态";
                        friendsCirleViewController.userId = [LYUserService sharedInstance].userID;
                        friendsCirleViewController.isFriendsCircle = NO;
                        friendsCirleViewController.personName = self.myInfoModel.name;
                        [self.navigationController pushViewController:friendsCirleViewController animated:YES];
                    }
                        break;
                    case 2:
                    {
                        MyLvyueViewController *ly = [[MyLvyueViewController alloc] init];
                        [self.navigationController pushViewController:ly animated:YES];
                    }
                        break;
                    case 3:
                    {
                        OtherVideoViewController *dest = [[OtherVideoViewController alloc] init];
                        dest.userID = [LYUserService sharedInstance].userID;
                        dest.navTitle = @"我的频道";
                        [self.navigationController pushViewController:dest animated:YES];
                    }
                        break;
                    case 4:
                    {
                        MyDispositionViewController *md = [[MyDispositionViewController alloc] init];
                        [self.navigationController pushViewController:md animated:YES];
                    }
                        break;
                    case 5:
                    {
                        MyLiveViewController *mylive = [[MyLiveViewController alloc] init];
                        mylive.name = [NSString stringWithFormat:@"%@",self.myInfoModel.name];
                        mylive.icon = [NSString stringWithFormat:@"%@",self.myInfoModel.icon];
                        [self.navigationController pushViewController:mylive animated:YES];
                    }
                        break;
                    default:
                        break;
                }
            }
            else if (indexPath.section == 2){   //个人资料
                switch (indexPath.row) {
                    case 0:
                    {
                        KnowViewController *know = [[KnowViewController alloc] init];
                        [know setHidesBottomBarWhenPushed:YES];
                        know.car = self.myInfoModel.auth_car;
                        know.edu = self.myInfoModel.auth_edu;
                        know.identity = self.myInfoModel.auth_identity;
                        know.video = self.myInfoModel.auth_video;
                        know.userType = self.myInfoModel.type;
                        know.alipay = self.myDetailInfoModel.alipay_id;
                        know.weixin = self.myDetailInfoModel.weixin_id;
                        know.provide_stay = self.myInfoModel.provide_stay;
                        [self.navigationController pushViewController:know animated:YES];
                        
                    }
                        break;
                    case 1:
                    {
                        
#ifdef kEasyVersion
                        break;
#else
                        VipInfoViewController *info = [[VipInfoViewController alloc] init];
                        [self.navigationController pushViewController:info animated:YES];
#endif
                    }
                        break;
                    default:
                        break;
                }
            }
            else if (indexPath.section == 3){
                switch (indexPath.row) {
                        //            case 0: //订单
                        //            {
                        //                AllOrderViewController *order = [[AllOrderViewController alloc] init];
                        //                [self.navigationController pushViewController:order animated:YES];
                        //            }
                        //                break;
                        //            case 1: //红豆
                        //            {
                        //                MyRedBeanViewController *red = [[MyRedBeanViewController alloc] init];
                        //                red.alipay = self.myDetailInfoModel.alipay_id;
                        //                red.weixin = self.myDetailInfoModel.weixin_id;
                        //                [self.navigationController pushViewController:red animated:YES];
                        //            }
                        //                break;
                    case 0:
                    {
                        //设置微信
                        [UMSocialData defaultData].extConfig.wechatSessionData.title = @"豆客，出售您的空余时间，向导大家旅行、寻找美食、搭伴健身..除了能带给您经济收入外，互动的过程还能互相深入了解，交到真正、合适的各方朋友，他、她正在豆客等您..";
                        [UMSocialData defaultData].extConfig.wechatTimelineData.title = @"豆客，出售您的空余时间，向导大家旅行、寻找美食、搭伴健身..除了能带给您经济收入外，互动的过程还能互相深入了解，交到真正、合适的各方朋友，他、她正在豆客等您..";
                        [UMSocialData defaultData].extConfig.wechatSessionData.url = [NSString stringWithFormat:@"%@/assets/share",REQUESTHEADER];
                        [UMSocialData defaultData].extConfig.wechatTimelineData.url = [NSString stringWithFormat:@"%@/assets/share",REQUESTHEADER];
                        
                        //设置新浪微博
                        [[UMSocialData defaultData].urlResource setResourceType:UMSocialUrlResourceTypeImage url:[NSString stringWithFormat:@"%@/assets/share",REQUESTHEADER]];
                        
                        
                        //设置QQ
                        [UMSocialData defaultData].extConfig.qqData.title = @"豆客，出售您的空余时间，向导大家旅行、寻找美食、搭伴健身..除了能带给您经济收入外，互动的过程还能互相深入了解，交到真正、合适的各方朋友，他、她正在豆客等您..";
                        [UMSocialData defaultData].extConfig.qzoneData.title = @"豆客，出售您的空余时间，向导大家旅行、寻找美食、搭伴健身..除了能带给您经济收入外，互动的过程还能互相深入了解，交到真正、合适的各方朋友，他、她正在豆客等您..";
                        [UMSocialData defaultData].extConfig.qqData.url = [NSString stringWithFormat:@"%@/assets/share",REQUESTHEADER];
                        [UMSocialData defaultData].extConfig.qzoneData.url = [NSString stringWithFormat:@"%@/assets/share",REQUESTHEADER];
                        
                        //分享
                        [UMSocialSnsService presentSnsIconSheetView:self appKey:@"55f3983c67e58e502a00167d" shareText:@"我分享了一个APP应用，快来看看吧~\n\n——尽在\"豆客\"APP" shareImage:[UIImage imageNamed:@"logo108"] shareToSnsNames:[NSArray arrayWithObjects:UMShareToWechatTimeline,UMShareToWechatSession,UMShareToSina,UMShareToQQ,UMShareToQzone,nil] delegate:self];
                    }
                        break;
                    case 1:
                    {
                        SettingViewController *set = [[SettingViewController alloc] init];
                        set.alipay_id = self.myDetailInfoModel.alipay_id;
                        set.weixin_id = self.myDetailInfoModel.weixin_id;
                        [self.navigationController pushViewController:set animated:YES];
                    }
                        break;
                        
                    default:
                        break;
                }
            }

        }
    }];

    
    }

@end
