//
//  LYMeViewController.m
//  LvYue
//
//  Created by KentonYu on 16/7/22.
//  Copyright © 2016年 OLFT. All rights reserved.
//


#import "LYMeViewController.h"
#import "MyInfoVC.h"
#import "MyMoneyVC.h"
#import "WhoLookMeVC.h"//谁看过我
#import "LYHttpPoster.h"
#import "MBProgressHUD+NJ.h"
#import "MyFirstPhotoCell.h"
#import "WhoLookMeHead.h"
#import "UMSocial.h"
#import "settingVC.h"
#import "myDataVC.h"
#import "BuyVipViewController.h"
#import "BuyVIPVC.h"
#import "newMyInfoModel.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "myAlbumVC.h"
#import "LYUserService.h"
#import "IconModel.h"
#import "myInrestedVC.h"
#import "myFunScoreVC.h"
#import "taskViewController.h"
#import "firstPhotoModel.h"
#import "WhoLookMeHeadModel.h"
#import "KnowViewController.h"
#import "VideoKnowViewController.h"
#import "PublishVideoViewController.h"
#import "MyDynamicViewController.h"
static NSString *const LYMeViewControllerShareTitle = @"趣陪，出售您的空余时间，向导大家旅行、寻找美食、搭伴健身..除了能带给您经济收入外，互动的过程还能互相深入了解，交到真正、合适的各方朋友，他、她正在趣陪等您..";
static NSString *const LYMeViewControllerShareText  = @"我分享了一个APP应用，快来看看吧~\n\n——尽在\"趣陪\"App";
@interface LYMeViewController ()<UITableViewDelegate,UITableViewDataSource,UMSocialUIDelegate>{
    UITableView *table;

    
    NSArray *cellLeft1Arr;
    NSArray *celleft2Arr;
    
    
    
    
    
    
//    newMyInfoModel *infoModel;
    
    IconModel *iconModel;
    NSMutableArray*  resultArr ;
    NSMutableArray*  seemeImageArr;
}

@end

@implementation LYMeViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
    [self getWhoSeeMe];//谁看过我
   [table reloadData];
    
    
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"reloadDisposition" object:nil];
       [[NSNotificationCenter defaultCenter]removeObserver:self name:@"push" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"reloadMyAlbum" object:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getVideoOption];
    celleft2Arr = @[@"任务",@"视频认证",@"设置",@"分享"];
    
  
    resultArr = [[NSMutableArray alloc]init];
    seemeImageArr = [[NSMutableArray alloc]init];
    
    [self setMineTable];
    
   
    [self getMyIndex];
//    [self getPersonalInfo];
    
    //发送通知 点照片调到相册
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(pushNotification:) name:@"push" object:nil];
 
    // 监听是否需要刷新数据
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_loadDatagetMyIndex) name:@"reloadDisposition" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(p_loadDatagetMyIndex) name:@"reloadMyAlbum" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStateDidChange:) name:@"LY_NetworkConnectionStateDidChange" object:nil];
    
}

#pragma mark  ---获取视频功能开关
- (void)getVideoOption{
    
    // NSString *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userId"];
    
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/video/getVideoOption1",REQUESTHEADER] andParameter:nil success:^(id successResponse) {
        
        NSLog(@"0000000000000:%@",successResponse);
        
        
        if ([[NSString stringWithFormat:@"%@",successResponse[@"data"]] isEqualToString:@"1"]) {
             cellLeft1Arr = @[@"我的账户",@"谁看过我",@"我的约会",@"感兴趣",@"我的有趣度",@"我的视频聊"];
      
        }else{
             cellLeft1Arr = @[@"我的账户",@"谁看过我",@"我的约会",@"感兴趣",@"我的有趣度"];
           
        }
        //一个section刷新
        NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:2];
        [table reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
    } andFailure:^(id failureResponse) {
         cellLeft1Arr = @[@"我的账户",@"谁看过我",@"我的约会",@"感兴趣",@"我的有趣度",@"我的视频聊"];
        //一个section刷新
        NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:2];
        [table reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
    
}
-(void)p_loadDatagetMyIndex{
    [self getMyIndex];
}
#pragma mark - 通知中心
//网络变化时显示提示UI
- (void)networkStateDidChange:(NSNotification *)aNotification {
    
    NSDictionary *stateDict = [aNotification userInfo];
    EMConnectionState connectState = [stateDict[@"connectionState"] integerValue];
    [self networkChanged:connectState];
}

- (void)networkChanged:(EMConnectionState)connectionState
{
    if (connectionState == eEMConnectionDisconnected) {
      
    }
    else{
        [self getMyIndex];
        [self getVideoOption];
    }
}
//- (void)getPersonalCoin{
//    
//    
////    NSString *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userId"];
//    
//    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/getMyIndex",REQUESTHEADER] andParameter:@{@"userId":@"1000006"} success:^(id successResponse) {
//        
//        NSLog(@"0000000000000我的金币:%@",successResponse);
//        
//        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
//            
//            NSDictionary *dataDic = successResponse[@"data"][@"userInfo"];
//            iconModel = [IconModel createWithModelDic:dataDic];
//            
//            [table reloadData];
//        }else{
//            
//            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
//        }
//    } andFailure:^(id failureResponse) {
//        [MBProgressHUD showError:@"服务器繁忙,请重试"];
//        NSLog(@"失败:%@",failureResponse);
//        
//    }];
//    
//}


- (void)pushNotification:(NSNotification *)noti{
    if ([[noti.userInfo objectForKey:@"push"] isEqualToString:@"photoVC"]) {

        //相册
        myAlbumVC *vc = [[myAlbumVC alloc]init];
        vc.userId = [CommonTool getUserID];
        vc.gotoVCIdentifier = @"LYMeViewController";
        [self.navigationController pushViewController:vc animated:YES];
    
    }
}




- (void)getWhoSeeMe{
  
    [seemeImageArr removeAllObjects];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/getMyIndex",REQUESTHEADER] andParameter:@{@"userId":[CommonTool getUserID]} success:^(id successResponse) {
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            
     
            
            NSArray *  seemeArr = successResponse[@"data"][@"seeMe"];
            
            
            for (NSDictionary *dic in seemeArr) {
                WhoLookMeHeadModel*    model = [WhoLookMeHeadModel creModelWithDic:dic];
                [seemeImageArr addObject:model.hadImage];
            }
            
            
            //一个section刷新
            NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:1];
            [table reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
         
            
            //            [table reloadData];
        }else{
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
        }
        
    } andFailure:^(id failureResponse) {
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
        NSLog(@"失败:%@",failureResponse);
    }];
}
#pragma mark  ---金币数  发布约会数量等
- (void)getMyIndex{
    
    //     NSString *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userId"];
    
    
    //  DLK 内存泄漏修改
    [resultArr removeAllObjects];
  
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/getMyIndex",REQUESTHEADER] andParameter:@{@"userId":[CommonTool getUserID]} success:^(id successResponse) {
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            
            NSDictionary *dataDic = successResponse[@"data"][@"userInfo"];
            iconModel = [IconModel createWithModelDic:dataDic];
            
          NSArray*  imageArr = successResponse[@"data"][@"userPhoto"];
            [resultArr removeAllObjects];
            for (NSDictionary *dic in imageArr) {
             firstPhotoModel*   model = [firstPhotoModel creModelWithDic:dic];
                [resultArr addObject:model.imageUrl];
            }
            
         
            NSIndexSet *indexSet2=[[NSIndexSet alloc]initWithIndex:2];
            [table reloadSections:indexSet2 withRowAnimation:UITableViewRowAnimationAutomatic];
           
//            [table reloadData];
        }else{
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
        }
        
    } andFailure:^(id failureResponse) {
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
        NSLog(@"失败:%@",failureResponse);
    }];
    
}

//#pragma mark  ---获取个人信息
//- (void)getPersonalInfo{
//    
//   // NSString *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userId"];
//    
//    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/getPersonalInfo",REQUESTHEADER] andParameter:@{@"userId":[CommonTool getUserID]} success:^(id successResponse) {
//        
//       // NSLog(@"0000000000000我的资料:%@",successResponse);
//        
//        
//        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
//            
//            NSDictionary *dataDic = successResponse[@"data"];
//            infoModel = [newMyInfoModel createWithModelDic:dataDic];
//            
//            //一个section刷新
//            NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:0];
//            [table reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
//            
//        }else{
//            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
//        }
//        
//    } andFailure:^(id failureResponse) {
//        [MBProgressHUD showError:@"服务器繁忙,请重试"];
//        NSLog(@"失败:%@",failureResponse);
//    }];
//    
//}




#pragma mark ----------- 创建UI  table
- (void)setMineTable{
    
   table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-56) style:UITableViewStylePlain];
   table.dataSource = self;
   table.delegate = self;
   table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
   [table registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
   [self.view addSubview:table];
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section==0) {
        return 1;
    }else if (section==1){
        return 1;
    }else if (section==2){
        return cellLeft1Arr.count;
    }else{
        return 3;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        return 132;
    }else if (indexPath.section==1) {
        return 62+ (SCREEN_WIDTH-72)/5;
    } {
        return 56;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return 1;
    }else {
        return 3;
    }
}


#pragma mark   -------区头  头像等
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section==0) {
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
    
   
        return view;
    }else{
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 3)];
        return view;
    }
    
}

#pragma mark   -----点击头像进入我的资料
- (void)goInfo:(UIButton *)sender{
    
     MyInfoVC *inVC = [[MyInfoVC alloc]init];

    [self.navigationController pushViewController:inVC animated:YES];
    
    
}


#pragma mark   ----------开通VIP
- (void)changeVIP:(UIButton *)sender{
    
    BuyVIPVC *vipVC = [[BuyVIPVC alloc]init];
    [self.navigationController pushViewController:vipVC animated:YES];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.section==0) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 132)];
        [cell.contentView addSubview:view];
        UIImageView *bgImage =[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 132)];
        bgImage.userInteractionEnabled = YES;
        bgImage.image = [UIImage imageNamed:@"头像背景"];
        [view addSubview:bgImage];
        
        UIImageView *headImage = [[UIImageView alloc]initWithFrame:CGRectMake(15, 43, 66, 66)];
        headImage.userInteractionEnabled = YES;
        NSURL *headUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@",[CommonTool getUserIcon]]];
        [headImage sd_setImageWithURL:headUrl];
        headImage.layer.cornerRadius = 33;
        headImage.clipsToBounds = YES;
        [bgImage addSubview:headImage];
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 66, 66)];
        btn.backgroundColor = [UIColor clearColor];
        [btn addTarget:self action:@selector(goInfo:) forControlEvents:UIControlEventTouchUpInside];
        [headImage addSubview:btn];
        
        
        
        UIButton *infoBtn = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-15-8, 70, 18, 12)];
        [infoBtn setTitle:@">" forState:UIControlStateNormal];
        [infoBtn setTitleColor:[UIColor colorWithHexString:@"#ffffff"] forState:UIControlStateNormal];
        [bgImage addSubview:infoBtn];
        
        
        //昵称
        UILabel *nickLabel = [[UILabel alloc]initWithFrame:CGRectMake(98, 50, 123, 24)];
        nickLabel.text = [NSString stringWithFormat:@"%@",[CommonTool getUserNickname]];
        nickLabel.textColor = [UIColor colorWithHexString:@"#ffffff"];
        nickLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:20];
        [bgImage addSubview:nickLabel];
        
        //vip图片
        UIImageView * vipImagV = [[UIImageView alloc]init];
        vipImagV.frame = CGRectMake(99, 85, 24, 24);
        vipImagV.image = [UIImage imageNamed:@"p_vip"];
        [bgImage addSubview:vipImagV];
        
        UILabel *vipLabel = [[UILabel alloc]init];
        vipLabel.frame = CGRectMake(120, 93, 40, 12);
        vipLabel.text = [CommonTool getUserVipLevel];
        vipLabel.textAlignment = NSTextAlignmentLeft;
        vipLabel.textColor = [UIColor colorWithHexString:@"#ff5252"];
        vipLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
        [bgImage addSubview:vipLabel];
        

        return cell;
    }
    if (indexPath.section==1) {
        if (indexPath.row == 0) {
            //我的照片
            MyFirstPhotoCell *cell = [[MyFirstPhotoCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil photoArr:resultArr];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.photoLabel.text = @"我的照片";
            cell.noLabel.text = @"目前您还没有上传照片\n点此上传照片可以增加交友概率哦";
            return cell;
        }
       

      }
    
  
    if (indexPath.section==2) {
      
        cell.textLabel.text = cellLeft1Arr[indexPath.row];
      
    }
    
    
    if (indexPath.section==2&&indexPath.row==0) {
        //我的账户
        cell.imageView.image = [UIImage imageNamed:@"m_money"];
//        UILabel *moneyLabel = [[UILabel alloc]init];
//        moneyLabel.translatesAutoresizingMaskIntoConstraints = NO;
//        if (iconModel) {
//            moneyLabel.text = [NSString stringWithFormat:@"%@",iconModel.money];
//        }
//      
//        moneyLabel.textColor = [UIColor colorWithHexString:@"#757575"];
//        moneyLabel.textAlignment = NSTextAlignmentRight;
//        moneyLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
//        [cell addSubview:moneyLabel];
//        
//        [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[moneyLabel(==54)]-32-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(moneyLabel)]];
//        [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-22-[moneyLabel(==14)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(moneyLabel)]];
     
        UIImageView *goldsImage = [[UIImageView alloc]init];
        goldsImage.frame = CGRectMake(SCREEN_WIDTH-144-16-20, 20, 16, 16);
        goldsImage.image = [UIImage imageNamed:@"golds2"];
        [cell.contentView addSubview:goldsImage];
        
        UIImageView *keyImage = [[UIImageView alloc]init];
        keyImage.frame = CGRectMake(SCREEN_WIDTH-90-16, 20, 16, 16);
        keyImage.image = [UIImage imageNamed:@"account_key_grey"];
        [cell.contentView addSubview:keyImage];
        
        UIImageView *apointImage = [[UIImageView alloc]init];
        apointImage.frame = CGRectMake(SCREEN_WIDTH-41-16, 20, 16, 16);
        apointImage.image = [UIImage imageNamed:@"account_money_grey"];
        [cell.contentView addSubview:apointImage];
        
        
        UILabel *goldsLabel =[[UILabel alloc]init];
        goldsLabel.frame = CGRectMake(SCREEN_WIDTH-114-26-20, 18, 46, 20);
        goldsLabel.textColor = [UIColor colorWithHexString:@"#757575"];
        goldsLabel.textAlignment = NSTextAlignmentLeft;
        goldsLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
        goldsLabel.text = [NSString stringWithFormat:@"%@",iconModel.money];
        [cell.contentView addSubview:goldsLabel];
        
        UILabel *keyLabel =[[UILabel alloc]init];
        keyLabel.frame = CGRectMake(SCREEN_WIDTH-77-9, 18, 26, 20);
        keyLabel.textColor = [UIColor colorWithHexString:@"#757575"];
        keyLabel.textAlignment = NSTextAlignmentLeft;
        keyLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
        keyLabel.text = [NSString stringWithFormat:@"%@",iconModel.userKey];
        [cell.contentView addSubview:keyLabel];
        
        UILabel *apointLabel =[[UILabel alloc]init];
        apointLabel.frame = CGRectMake(SCREEN_WIDTH-22-17, 18, 36, 20);
        apointLabel.textColor = [UIColor colorWithHexString:@"#757575"];
        apointLabel.textAlignment = NSTextAlignmentLeft;
        apointLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
        apointLabel.text = [NSString stringWithFormat:@"%@",iconModel.userPoint];
        [cell.contentView addSubview:apointLabel];
    }
    
    if (indexPath.section==2&&indexPath.row==1) {
        cell.imageView.image = [UIImage imageNamed:@"m_viewers"];
        for (NSInteger i= 0; i<seemeImageArr.count; i++) {
            UIImageView *image = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-32-(i+1)*32, 16, 24, 24)];
            
            
            image.layer.cornerRadius = 12;
            image.clipsToBounds = YES;
            
            
            //这个是图片的名字
            
            NSURL *imageUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,seemeImageArr[i]]];
            
            [image sd_setImageWithURL:imageUrl];
            
            [cell.contentView addSubview:image];
            
            
            
        }
        
        if (seemeImageArr && seemeImageArr.count>0) {
            UILabel *pointLabel = [[UILabel alloc]init];
            pointLabel.frame = CGRectMake(120, 20, 6, 6);
            pointLabel.layer.cornerRadius = 3;
            pointLabel.clipsToBounds = YES;
            pointLabel.backgroundColor = [UIColor colorWithHexString:@"#ff5252"];
            [cell.contentView addSubview:pointLabel];
        }

    }
    
    if (indexPath.section==2&&indexPath.row==2) {
        //约会个数
        cell.imageView.image = [UIImage imageNamed:@"m_mydates"];
        UILabel *moneyLabel = [[UILabel alloc]init];
        moneyLabel.translatesAutoresizingMaskIntoConstraints = NO;
        if (iconModel) {
           moneyLabel.text = [NSString stringWithFormat:@"%@",iconModel.aboutAppoint];
        }
        
        moneyLabel.textColor = [UIColor colorWithHexString:@"#757575"];
        moneyLabel.textAlignment = NSTextAlignmentRight;
        moneyLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
        [cell addSubview:moneyLabel];
        
        [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[moneyLabel(==54)]-32-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(moneyLabel)]];
        [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-22-[moneyLabel(==14)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(moneyLabel)]];
    }
    
    if (indexPath.section==2&&indexPath.row==3) {
        //感兴趣
        cell.imageView.image = [UIImage imageNamed:@"m_liked"];
        UILabel *moneyLabel = [[UILabel alloc]init];
        moneyLabel.translatesAutoresizingMaskIntoConstraints = NO;
        if (iconModel) {
            moneyLabel.text = [NSString stringWithFormat:@"%@",iconModel.instesd];
        }
        
        moneyLabel.textColor = [UIColor colorWithHexString:@"#757575"];
        moneyLabel.textAlignment = NSTextAlignmentRight;
        moneyLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
        [cell addSubview:moneyLabel];
        
        [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[moneyLabel(==54)]-32-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(moneyLabel)]];
        [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-22-[moneyLabel(==14)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(moneyLabel)]];
    }
    
    if (indexPath.section==2&&indexPath.row==4) {
        //我的有趣度
        cell.imageView.image = [UIImage imageNamed:@"m_rate"];
        
//        UILabel *moneyLabel = [[UILabel alloc]init];
//        moneyLabel.translatesAutoresizingMaskIntoConstraints = NO;
//        if (iconModel) {
//            moneyLabel.text = [NSString stringWithFormat:@"%@",iconModel.instesd];
//        }
//       
//        moneyLabel.textColor = [UIColor colorWithHexString:@"#757575"];
//        moneyLabel.textAlignment = NSTextAlignmentRight;
//        moneyLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
//        [cell addSubview:moneyLabel];
//        
//        [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[moneyLabel(==54)]-32-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(moneyLabel)]];
//        [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-22-[moneyLabel(==14)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(moneyLabel)]];
        
        
        
        
    }
    
    if (indexPath.section==2&&indexPath.row==5) {
        //我的动态
        cell.imageView.image = [UIImage imageNamed:@"红色动态"];
        
//        UILabel *moneyLabel = [[UILabel alloc]init];
//        moneyLabel.translatesAutoresizingMaskIntoConstraints = NO;
//        if (iconModel) {
//            moneyLabel.text = [NSString stringWithFormat:@"%@",iconModel.instesd];
//        }
//        
//        moneyLabel.textColor = [UIColor colorWithHexString:@"#757575"];
//        moneyLabel.textAlignment = NSTextAlignmentRight;
//        moneyLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
//        [cell addSubview:moneyLabel];
//        
//        [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[moneyLabel(==54)]-32-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(moneyLabel)]];
//        [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-22-[moneyLabel(==14)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(moneyLabel)]];
//        
        
        
        
    }
    
//    //谁看过我的人的头像
//  
//    [cell.contentView addSubview:[[WhoLookMeHead alloc]initCellWithIndex:indexPath]];
   
   if (indexPath.section==3) {
    
        cell.textLabel.text = celleft2Arr[indexPath.row];
    }
    if (indexPath.section==3&&indexPath.row==0) {
        cell.imageView.image = [UIImage imageNamed:@"m_tast"];
    }
    
    if (indexPath.section==3&&indexPath.row==1) {
        cell.imageView.image = [UIImage imageNamed:@"m_video"];
    }
    
    if (indexPath.section==3&&indexPath.row==2) {
        cell.imageView.image = [UIImage imageNamed:@"m_setting"];
    }
    
    if (indexPath.section==3&&indexPath.row==3) {
        cell.imageView.image = [UIImage imageNamed:@"m_share"];
    }
    
    

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.textColor = [UIColor colorWithHexString:@"#424242"];
    cell.textLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    return cell;
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0&&indexPath.row==0) {
        MyInfoVC *inVC = [[MyInfoVC alloc]init];
        
        [self.navigationController pushViewController:inVC animated:YES];

    }
       if (indexPath.section==1&&indexPath.row==0) {
        //我的相册
        myAlbumVC *vc = [[myAlbumVC alloc]init];
        vc.userId = [CommonTool getUserID];
        vc.gotoVCIdentifier = @"LYMeViewController";
        [self.navigationController pushViewController:vc animated:YES];
           
        
    
    }
  
    if (indexPath.section==2&&indexPath.row==2) {
        //我的约会
        myDataVC *dataVc = [[myDataVC alloc]init];
        dataVc.otherUserId =[CommonTool getUserID];
//        dataVc.otherZhuYeVC = @"LYMeViewController";
        [self.navigationController pushViewController:dataVc animated:YES];
    }
    
    if (indexPath.section==2&&indexPath.row ==3) {
        //感兴趣的约会
        myInrestedVC *insre = [[myInrestedVC alloc]init];
        insre.userId = [CommonTool getUserID];
        insre.userNike = @"我";
        insre.gotoVCIdentifier = @"LYMeViewController";
        [self.navigationController pushViewController:insre animated:YES];
    }
    
    if (indexPath.section==2&&indexPath.row==4) {
        //我的有趣度
        myFunScoreVC *fun = [[myFunScoreVC alloc]init];
        [self.navigationController pushViewController:fun animated:YES];
    }
    if (indexPath.section==2&&indexPath.row==5) {
        //我的动态
         MyDynamicViewController *fun = [[ MyDynamicViewController alloc]init];
        fun.userID= [CommonTool getUserID];
        [self.navigationController pushViewController:fun animated:YES];
    }
   
    if (indexPath.section==2&&indexPath.row==0) {
        //我的账户
        MyMoneyVC *moneyVC = [[MyMoneyVC alloc]init];
        [self.navigationController pushViewController:moneyVC animated:YES];
    }
    
    if (indexPath.section==2&&indexPath.row==1) {
        //谁看过我
        [self getCoinNum];
           }
    
    if (indexPath.section==3&&indexPath.row==0) {
        //任务
        taskViewController *task = [[taskViewController alloc]init];
        [self.navigationController pushViewController:task animated:YES];
     
//        KnowViewController *task = [[KnowViewController alloc]init];
//                [self.navigationController pushViewController:task animated:YES];
    }
    
    if (indexPath.section==3&&indexPath.row==1) {
        //视频认证
        VideoKnowViewController *vc = [[VideoKnowViewController alloc]init];
        
        [self.navigationController pushViewController:vc animated:YES];
    }
    
//    if (indexPath.section==3&&indexPath.row==3) {
//        //分享
//        [self share];
//    }
    
    
    if (indexPath.section==3&&indexPath.row==2) {
        //设置
        settingVC *set = [[settingVC alloc]init];
        [self.navigationController pushViewController:set animated:YES];
    }
}

#pragma mark  ---获得账户金币
- (void)getCoinNum{
    
    
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/getUserPower",REQUESTHEADER] andParameter:@{@"userId":[CommonTool getUserID]} success:^(id successResponse) {
        //
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            //
            NSLog(@"myMoneysuccessResponse---%@",successResponse);
            NSDictionary *dataDic = successResponse[@"data"];
            iconModel = [IconModel createWithModelDic:dataDic];
            NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
            [user setObject:[NSString stringWithFormat:@"%@",iconModel.vipLevel] forKey:@"vipLevel"];
            if ([iconModel.vipLevel integerValue] >= 2) {
                WhoLookMeVC *lookVC = [[WhoLookMeVC alloc]init];
                [self.navigationController pushViewController:lookVC animated:YES];

            }else{
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"只有vip2及以上的用户才能免费查看,马上购买金币成为vip2用户,成为vip2用户不需消费金币，购买的金币可以用于购物等消费" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
                alertView.tag = 1002;
                [alertView show];
              
            }
        }else{
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
        }
        
    } andFailure:^(id failureResponse) {
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
        NSLog(@"失败:%@",failureResponse);
    }];
    //
    
    
}
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    WS(weakSelf)
    if (alertView.tag == 1002) {
        if (1 == buttonIndex) {
            MyMoneyVC *myMoney = [[MyMoneyVC alloc] init];
            [weakSelf.navigationController pushViewController:myMoney animated:YES];
        }
    }

}
#pragma mark   ------ 分享好友------
- (void)share{
    
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







@end
