//
//  otherZhuYeVC.m
//  LvYue
//
//  Created by X@Han on 16/12/8.
//  Copyright © 2016年 OLFT. All rights reserved.
//


//别人的主页
#import "otherZhuYeVC.h"
#import "otherHomeCell.h"
#import "LYHttpPoster.h"
#import "MBProgressHUD+NJ.h"
#import "newMyInfoModel.h"
#import "UIImageView+WebCache.h"
#import "AFNetworking.h"
#import "firstPhotoModel.h"
#import "reportVC.h"
#import "OtherAppointModel.h"
#import "otherDataVC.h"   //别人发布的约会
#import "otherInsresedVC.h"  //别人感兴趣的约会
#import "otherFunScoreVC.h"
#import "personHomeTableViewCell.h"
#import "myDataVC.h"
#import "myAlbumVC.h"
#import "DQStarView.h"
#import "myInrestedVC.h"
#import "LYSendGiftViewController.h"
#import "ReceiveGiftModel.h"
#import "ReceivedGiftVC.h"
#import "VideoKnowViewController.h"
#import "MyDynamicViewController.h"
#import "DynamicListModel.h"
@interface otherZhuYeVC ()<UITableViewDelegate,UITableViewDataSource,DQStarViewDelegate>{
    UIView *rightView;//拉黑举报view
    UITableView *infoTable;
    newMyInfoModel *infoModel;
    provinceModel *pModel;
    cityModel *cModel;
    distrModel *dModel;
    NSString *goodStr;
    UIView *blurView;
    NSArray *goodArr;
    UILabel *goodLabel;
    firstPhotoModel *photoModel;
    NSMutableArray *resultArr;//照片数组
    NSMutableArray *photoPriceArr;//照片价格
    NSMutableArray *giftArr;//礼物数组
    NSString * photoNumStr;
    UIButton *action;   // 拉黑
    NSString * actionStr;
    
    NSMutableArray *otherDataArr; //别人约会的数据
    NSMutableArray *otherInstrdArr;  //别人感兴趣约会的数据
    NSMutableArray *otherDynaticArr;  //动态数组
    
    NSString *userInterestSum;
    NSString *userDateSum;
    NSString *userPhotoSum;
    NSString *userVipLevel;
//    NSString *shareNumber;
    
    UILabel *instLabel;
    UIButton *instrBtn;
   
    NSString * FouseStr;//关注
    
    otherHomeCell *cellH;
    
    DQStarView *seeStarView;
    NSString *   getGradeNumber;
    
    NSInteger  userKeyNum;
    NSInteger  goldsNum;
    
    BOOL isBuyKanfa;
    
    NSArray * contactTitleArr;
    NSArray *contactArr;
    
    UIView *bottoView ;//底部关注 聊一聊按钮的view
}
@property (nonatomic, strong) otherHomeCell *cell;
@property(nonatomic,copy)NSString *sex;
@property(nonatomic,copy)NSString *videoUrl;
@property(nonatomic,copy)NSString *vipLevel;
@property(nonatomic,assign)CGFloat historyY;
@end

@implementation otherZhuYeVC

- (void)viewWillAppear:(BOOL)animated{
    
    rightView.hidden = YES;
  
    
    [super viewWillAppear:animated];
    
}

- (void)viewDidLoad {
   
    [super viewDidLoad];
    
   // NSLog(@"用户池:%@",self.userId);
    actionStr = @"拉黑";
    //这里先加在表 在加导航 防止表把举报拉黑覆盖住
    [self myInfoTable];
    [self setNav];
    [self focusAndChatView];
    FouseStr = @"关 注";
    resultArr = [[NSMutableArray alloc]init];
    photoPriceArr = [[NSMutableArray alloc]init];
    giftArr = [[NSMutableArray alloc]init];
    goodArr = [[NSArray alloc]init];
    otherInstrdArr = [[NSMutableArray alloc]init];
    otherDataArr = [[NSMutableArray alloc]init];
    otherDynaticArr = [[NSMutableArray alloc]init];
    contactTitleArr = @[@"手机号",@"微信号",@"QQ号"];
    contactArr = @[@"未填写",@"未填写",@"未填写"];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(pushNotification:) name:@"show" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updaGoldsAnduserKeyNum:) name:@"addAccount" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(seeContact:) name:@"seeContact" object:nil];
    
    [self  getAllData];
    
    [self getCoinNum];
    [self checkIsBlack];
    [self getFouseData];
    
//    [self getPhoto];
//    [self getGood];
    
    [self getData];
//    [self getOtherAppointData];
//    [self getOtherInstrstedAppointData];
//    [self getOrderGift];
    [self getFriendGrade];
    [self getPersonalVideoAffirm];
    [self addWhoSeeMeRelationship];
   
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStateDidChange:) name:@"LY_NetworkConnectionStateDidChange" object:nil];
    
}


-(void)getAllData{
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/getOtherIndex",REQUESTHEADER] andParameter:@{@"userId":self.userId,@"otherUserId":[CommonTool  getUserID]} success:^(id successResponse) {
        NSLog(@"别人的主页 ---》:%@",successResponse);
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            
            [resultArr  removeAllObjects];
            [photoPriceArr removeAllObjects];
            [giftArr removeAllObjects];
            [otherInstrdArr removeAllObjects];
            [otherDataArr  removeAllObjects];
            
            goodStr = successResponse[@"data"][@"goodAt"];
            if (goodStr.length > 0) {
                //以逗号分开   判断有几个擅长
                goodArr = [goodStr componentsSeparatedByString:@","];
            }
            
            
            NSArray *imageArr = successResponse[@"data"][@"userPhoto"];
            
            for (NSDictionary *dic in imageArr) {
                photoModel = [firstPhotoModel creModelWithDic:dic];
                //照片的价格
                // NSString *money = infoModel.photoPrice;
                [resultArr addObject:photoModel.imageUrl];
                [photoPriceArr addObject:photoModel.photoPrice];
            }
            
            
            NSArray *listArr = successResponse[@"data"][@"userGift"];
            for (NSDictionary *dic in listArr) {
                ReceiveGiftModel *dataModel = [ReceiveGiftModel createWithModelDic:dic];
                
                [giftArr addObject:dataModel];
                
            }

            
            NSArray *userInterestlistArr = successResponse[@"data"][@"userInterest"];
            userInterestSum = successResponse[@"data"][@"userInterestSum"];
            for (NSDictionary *dic in userInterestlistArr) {
                OtherAppointModel *otherModel = [[OtherAppointModel alloc]initWithModelDic:dic];
                [otherInstrdArr addObject:otherModel];
               
            }
            
            
            NSArray *userDatalistArr = successResponse[@"data"][@"userDate"];
            userDateSum = successResponse[@"data"][@"userDateSum"];
            for (NSDictionary *dic in userDatalistArr) {
                OtherAppointModel *otherModel = [[OtherAppointModel alloc]initWithModelDic:dic];
                [otherDataArr addObject:otherModel];
                
            }
//          shareNumber = successResponse[@"data"][@"shareNumber"];
            
            NSArray *userShareArr = successResponse[@"data"][@"userVideoList"];
            for (NSDictionary *dic in userShareArr) {
                
                DynamicListModel *dyNaticModel = [DynamicListModel createWithModelDic:dic];
//                NSString*  otherDynaticStr = dyNaticModel.shareUrl;
                 [otherDynaticArr addObject:dyNaticModel.showUrl];
//                NSArray *sharArr = [NSArray array];
//                if ([[NSString  stringWithFormat:@"%@",dyNaticModel.shareType] isEqualToString:@"1"] &&otherDynaticStr.length > 0 ) {
//                    sharArr  = [otherDynaticStr componentsSeparatedByString:@","];
//                    [otherDynaticArr addObjectsFromArray:sharArr];
//                }else{
//                     [otherDynaticArr addObject:dyNaticModel.shareUrl];
//                }
            }
            
            [infoTable reloadData];
            
        }else{
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
        }
    } andFailure:^(id failureResponse) {
        
    }];
    
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
        [MBProgressHUD showSuccess:@"请检查网络"];
    }
    else{
        
        [self  getAllData];
        [self getCoinNum];
        [self checkIsBlack];
        [self getFouseData];
        
//        [self getPhoto];
//        [self getGood];
        
        [self getData];
//        [self getOtherAppointData];
//        [self getOtherInstrstedAppointData];
//        [self getOrderGift];
        [self getFriendGrade];
        
        [self addWhoSeeMeRelationship];
         [self getPersonalVideoAffirm];
        
        [infoTable reloadData];
    }
}


//push通知
- (void)seeContact:(NSNotification *)noti {
    [self checkIsSeeContact];
}
//push通知
- (void)updaGoldsAnduserKeyNum:(NSNotification *)noti {
     [self getCoinNum];
}
//push通知
- (void)pushNotification:(NSNotification *)noti {
       WS(weakSelf)
    
 
    
    if ([[noti.userInfo objectForKey:@"show"] isEqualToString:@"love"]) {
        [weakSelf creatAbooutViewWithTitle:@"关于爱情，我想说..." content:[NSString stringWithFormat:@"%@",infoModel.aboutLove] ];
        
    }
    
    
    
    if ([[noti.userInfo objectForKey:@"show"] isEqualToString:@"other"]) {
        [weakSelf creatAbooutViewWithTitle:@"关于另一半，我想说..." content:[NSString stringWithFormat:@"%@",infoModel.aboutOther] ];
    }
    
    
    if ([[noti.userInfo objectForKey:@"show"] isEqualToString:@"sex"]) {
        if ([CommonTool dx_isNullOrNilWithObject:[NSString stringWithFormat:@"%@",infoModel.aboutSex]] || [NSString stringWithFormat:@"%@",infoModel.aboutSex].length == 0) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode =MBProgressHUDModeText;//显示的模式
            hud.labelText = [NSString stringWithFormat:@"%@还没有发表对性的看法哦",self.sex];
            [hud hide:YES afterDelay:1];
            //设置隐藏的时候是否从父视图中移除，默认是NO
            hud.removeFromSuperViewOnHide = YES;
        }else{
        if (isBuyKanfa == YES) {
            [weakSelf creatAbooutViewWithTitle:@"关于性，我想说..." content:[NSString stringWithFormat:@"%@",infoModel.aboutSex] ];
        }else{
            [self buyAboutSexQuanXianClick];
        }
        }
    }
    
}


-(void)addWhoSeeMeRelationship{
    [LYHttpPoster requestAddSeeMeRelationshipDataWithParameters:@{@"userId":[CommonTool getUserID],@"otherUserId":self.userId} Block:^(NSArray *arr) {
        
    }];
}
-(void)CheckUserIsBuyedKanfa{
    WS(weakSelf)
    NSDictionary *dic =     @{
                              @"userId": [CommonTool getUserID],@"otherUserId": weakSelf.userId,@"buyType": @"4",@"remarkInfo":@"userOpinionSex"};
    //检查是否购买过看法
    [LYHttpPoster requestCheckUserIsBuyedWithParameters:dic Block:^(NSArray *arr)
     {
         if (arr && arr.count >0) {
             isBuyKanfa = YES;
         }else{
             
         }
     }];

}
-(void)buyAboutSexQuanXianClick{
    
    if (userKeyNum > 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"消耗1枚钥匙查看对性的看法" message:@"温馨提示：购买过后即可永久查看" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertView.tag = 1003;
        [alertView show];
    }else{
        if (goldsNum  >= 100) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"花费100金币查看对性的看法" message:@"温馨提示：购买过后即可永久查看" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alertView.tag = 1004;
            [alertView show];
        }else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"花费100金币查看对性的看法" message:@"金币不足，将无法查看对性的看法" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去充值", nil];
            alertView.tag = 1002;
            [alertView show];
        }
    }
    
}

-(void)creatAbooutViewWithTitle:(NSString *)title content:(NSString *)content{
    blurView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    blurView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    [self.view addSubview:blurView];
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 110, SCREEN_WIDTH, 220)];
    view.userInteractionEnabled = YES;
    [self.view addSubview:view];
    view.backgroundColor = [UIColor colorWithHexString:@"#ffffff"];
    view.layer.borderWidth =1;
    view.layer.cornerRadius = 2;
    view.layer.borderColor = [UIColor colorWithHexString:@"#ffffff"].CGColor;
    view.layer.masksToBounds = YES;
    
    UILabel *titlelabel = [[UILabel alloc]initWithFrame:CGRectMake(24, 24, 200, 16)];
//    titlelabel.text = @"关于另一半，我想说...";
    titlelabel.text = title;
    titlelabel.textAlignment = NSTextAlignmentLeft;
    titlelabel.textColor = [UIColor colorWithHexString:@"#424242"];
    titlelabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:16];
    [view addSubview:titlelabel];
    
    UILabel *contentLabel = [[UILabel alloc]init];
    contentLabel.translatesAutoresizingMaskIntoConstraints  = NO;
    contentLabel.numberOfLines = 0;
    //contentLabel.text = @"爱情其实就是一种生活。与你爱的人相视一笑，默默牵手走过，无须言语不用承诺。 系上围裙，走进厨房，为你爱的人煲一锅汤，风起的时候为她紧紧衣襟、理理乱发，有雨的日子，拿把伞为她撑起一片晴空。";
//    contentLabel.text = [NSString stringWithFormat:@"%@",infoModel.aboutOther] ;
    contentLabel.text = content ;
    contentLabel.textColor = [UIColor colorWithHexString:@"#757575"];
    contentLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
    [view addSubview:contentLabel];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-24-[contentLabel]-24-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(contentLabel)]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-56-[contentLabel(==100)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(contentLabel)]];
    
    //关闭
    UIButton *btn = [[UIButton alloc]init];
    btn.translatesAutoresizingMaskIntoConstraints = NO;
    [btn setTitle:@"关闭" forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [btn setTitleColor:[UIColor colorWithHexString:@"#424242"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btn];
    
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-256-[btn]-16-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(btn)]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-180-[btn(==32)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(btn)]];
    
    

}
- (void)dealloc {
    infoTable.delegate   = nil;
    infoTable.dataSource = nil;
    infoTable            = nil;
   [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)close:(UIButton *)sender{
    [sender.superview removeFromSuperview];
    [blurView removeFromSuperview];
}
- (void)checkIsBlack{
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/circle/getBlacklist",REQUESTHEADER] andParameter:@{@"userId":[CommonTool getUserID],@"otherUserId":self.userId} success:^(id successResponse) {
        NSLog(@"检查是否拉黑:%@",successResponse);
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            NSArray *arr =successResponse[@"data"];
            if (arr.count >0) {
                actionStr = @"取消拉黑";
                [action setTitle:actionStr forState:UIControlStateNormal];
            }
        }else{
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
        }
    } andFailure:^(id failureResponse) {
        
    }];
}
//别人的照片
- (void)getPhoto{
    
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/getMyIndex",REQUESTHEADER] andParameter:@{@"userId":self.userId} success:^(id successResponse) {
       NSLog(@"别人的主页照片:%@",successResponse);
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            
            NSArray *imageArr = successResponse[@"data"][@"userPhoto"];
            
            for (NSDictionary *dic in imageArr) {
               photoModel = [firstPhotoModel creModelWithDic:dic];
                //照片的价格
                // NSString *money = infoModel.photoPrice;
                [resultArr addObject:photoModel.imageUrl];
                [photoPriceArr addObject:photoModel.photoPrice];
            }
            [infoTable reloadData];
            //NSLog(@"别人的相片%@",resultArr);
        }else{
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
        }
    } andFailure:^(id failureResponse) {
        
    }];
    
    
    
    
}

//- (void)getPhotoNum{
//    [resultArr removeAllObjects];
//    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/getUserPhotoSum",REQUESTHEADER] andParameter:@{@"userId":self.userId} success:^(id successResponse) {
//        
//        
//        photoNumStr =[NSString stringWithFormat:@"%@",successResponse[@"data"]] ;
//        
//        
//    } andFailure:^(id failureResponse) {
//        
//    }];
//    
//    
//    
//    
//}
#pragma mark  ---别人的主页--》个人信息
- (void)getData{
    WS(weakSelf)
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/getPersonalInfo",REQUESTHEADER] andParameter:@{@"userId":self.userId} success:^(id successResponse) {
       NSLog(@"别人的主页 ---》个人信息:%@",successResponse);
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            
            NSDictionary *dataDic = successResponse[@"data"];
            infoModel = [newMyInfoModel createWithModelDic:dataDic];
            if (infoModel) {
                contactArr = @[infoModel.userMobile,infoModel.userWX,infoModel.userQQ];
                
            }
            [weakSelf CheckUserIsBuyedKanfa];
            
            
            if ([[NSString stringWithFormat:@"%@",infoModel.sex] isEqualToString:@"1"]) {
                weakSelf.sex = @"她";
            }
            
            if ([[NSString stringWithFormat:@"%@",infoModel.sex] isEqualToString:@"0"]) {
                weakSelf.sex = @"他";
            }
            if ([CommonTool dx_isNullOrNilWithObject:self.userNickName]) {
                weakSelf.title = [NSString stringWithFormat:@"%@的主页",infoModel.nickName];
            }else{
                weakSelf.title = [NSString stringWithFormat:@"%@的主页",self.userNickName];}
                            [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/cache/getProvince",REQUESTHEADER] andParameter:@{@"provinceId":[NSString stringWithFormat:@"%@",infoModel.dateProvince]} success:^(id successResponse) {
            
            
//                              placeStr = [NSString stringWithFormat:@"%@",successResponse[@"data"][@"provinceName"]];
                                pModel  = [provinceModel modelWithDictionary:successResponse[@"data"]];
            
                            } andFailure:^(id failureResponse) {
            
            
                            }];
            
            if ([[NSString stringWithFormat:@"%@",infoModel.dateCity] isEqualToString:@"0"]) {
                
            }else{
                            //城市
                            [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/cache/getCity",REQUESTHEADER] andParameter:@{@"cityId":[NSString stringWithFormat:@"%@",infoModel.dateCity]} success:^(id successResponse) {
                                cModel  = [cityModel modelWithDictionary:successResponse[@"data"]];
                              
                
                            } andFailure:^(id failureResponse) {
                                
                            }];}

            
            [infoTable reloadData];
            
    }else{
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
        }
    } andFailure:^(id failureResponse) {
        
    }];
    
}


#pragma mark  ---查看别人发布约会的信息
- (void)getOtherAppointData{
    
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/date/getPersonalDate",REQUESTHEADER] andParameter:@{@"userId":self.userId} success:^(id successResponse) {
        
        NSArray *listArr = successResponse[@"data"][@"list"];
      
        for (NSDictionary *dic in listArr) {
            OtherAppointModel *otherModel = [[OtherAppointModel alloc]initWithModelDic:dic];
            [otherDataArr addObject:otherModel];
            [infoTable reloadData];
        }
        
      
      
        
    } andFailure:^(id failureResponse) {
    
        
    }];
    
    
}


#pragma mark  ---查看别人感兴趣约会的信息
- (void)getOtherInstrstedAppointData{
    
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/date/getInterestDate",REQUESTHEADER] andParameter:@{@"userId":self.userId} success:^(id successResponse) {
        
        NSLog(@"-------->>他感兴趣的约会:%@",successResponse);
        
        NSArray *listArr = successResponse[@"data"][@"list"];
        
        for (NSDictionary *dic in listArr) {
            OtherAppointModel *otherModel = [[OtherAppointModel alloc]initWithModelDic:dic];
            [otherInstrdArr addObject:otherModel];
            [infoTable reloadData];
        }
        
        } andFailure:^(id failureResponse) {
        
        
    }];
    
    
}
-(void)getOrderGift{
    NSDictionary *dic = @{@"otherUserId":self.userId,@"pageNum":@"1"};
    [LYHttpPoster requestGetGiftInfomationWithParameters:dic Block:^(NSArray *arr) {
        [giftArr addObjectsFromArray:arr];
    }];
}
-(void)getFriendGrade{
    NSDictionary *dic = @{@"userId":self.userId};
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/getFriendGrade",REQUESTHEADER] andParameter:dic success:^(id successResponse) {
        
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"])  {
         NSString *   getGradeSum = successResponse[@"data"][@"gradeSum"];//得到评价的人数
            if ([[NSString stringWithFormat:@"%@",getGradeSum]  isEqualToString:@"0"]) {
               
                [seeStarView ShowDQStarScoreFunction:0];
               
                
            }else{
                
               
                
                getGradeNumber = successResponse[@"data"][@"gradeNumber"];//得到评价的分数[NSString stringWithFormat:@"%.1lf",score];
                
             
            }
            
            
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
}

#pragma mark   ------别人主页的内容
- (void)myInfoTable{
   
    infoTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64-84) style:UITableViewStylePlain];
    infoTable.delegate = self;
    infoTable.dataSource = self;
    infoTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:infoTable];
    
}
//- (void)createTableView {
//    self.table                = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
//    self.table.delegate       = self;
//    self.table.dataSource     = self;
//    self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
//    [self.view addSubview:self.table];
//}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 2) {
        return 4;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    tableView.delegate=nil;
//    
//    UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.section==0) {
        return 260;
    }else if(indexPath.section==2){
//        return 110;
        if (indexPath.row == 0) {
            return    cellH.secoFirHeight;
        }
        if (indexPath.row ==1){
            return cellH.secoSecoHeight;
        } if (indexPath.row == 2) {
            return    cellH.secoThirHeight;
        }
        if (indexPath.row ==3){
            return cellH.secoFourHeight;
        }
        
        return cellH.secoThirHeight;
        
    }else if (indexPath.section==1){
        if (otherDynaticArr.count > 0) {
            cellH.ThirHeight = (SCREEN_WIDTH-136)/4.0  +54;
        }else{
            cellH.ThirHeight = 0;
        }
        return cellH.secoHeight;
    }else if (indexPath.section==3){
        cellH.ThirHeight = 254;
        return cellH.ThirHeight;
    }else if (indexPath.section==4){
        return 198;//ganxingqu
    }else if(indexPath.section==5){
        return (SCREEN_WIDTH-136)/4.0 +78;//送礼物
    }else if(indexPath.section==6){
        return 152;//有趣之
    }else{
        return 84;
    }
}


//- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
//    return NO;
//}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section==1) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 10)];
        return view;
    }else{
        return nil;
    }
    
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%d%d", [indexPath section], [indexPath row]];//以indexPath来唯一确定cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier]; //出列可重用的cell
    tableView.clipsToBounds = YES;
    cell.clipsToBounds = YES;
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSArray *subviews = [[NSArray alloc] initWithArray:cell.contentView.subviews];
    for (UIView *subview in subviews) {
        [subview removeFromSuperview];
    }  
 
    newMyInfoModel *model = infoModel;
    
        cellH = [[otherHomeCell alloc]initCellWithIndex:indexPath setModel:model pModel:pModel cModel:cModel goodArr:goodArr];
    
    if (self.videoUrl &&[NSString stringWithFormat:@"%@",self.videoUrl].length >0) {
        cellH.certificationBtn.hidden = NO;
    }else{
        cellH.certificationBtn.hidden = YES;
    }
    
    cellH.userInteractionEnabled = YES;
     [cell.contentView addSubview:cellH];

    
    cellH.ageLabel.text = [NSString stringWithFormat:@"%@岁",infoModel.age];
    NSURL *headUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,infoModel.headImage]];
    [cellH.headImage sd_setImageWithURL:headUrl];
    
    cellH.nameLabel.text = infoModel.nickName;
    cellH.signLabel.text = infoModel.sign;
   
    
        if ([[NSString stringWithFormat:@"%@",infoModel.sex] isEqualToString:@"1"]) {
            cellH.sexImge.image = [UIImage imageNamed:@"female"];
        }
    
        if ([[NSString stringWithFormat:@"%@",infoModel.sex] isEqualToString:@"0"]) {
            cellH.sexImge.image = [UIImage imageNamed:@"male"];
      }
    
    cellH.heightLabel.text = [NSString stringWithFormat:@"%@cm",infoModel.height];
    cellH.colleaLabel.text = infoModel.constelation;
    cellH.workLabel.text = infoModel.work;
    cellH.weightLabel.text = [NSString stringWithFormat:@"%@kg",infoModel.weight];
     cellH.eduLabel.text = infoModel.edu;
    
   
    if (indexPath.section == 0) {
        //相册中的4张
        
        CGFloat width = (SCREEN_WIDTH-136)/4.0;
        
        if (resultArr.count==0) {
            //没照片
           // CGFloat width1 = SCREEN_WIDTH-224;
            UILabel *noLabel = [[UILabel alloc]init];
           noLabel.translatesAutoresizingMaskIntoConstraints = NO;
            noLabel.userInteractionEnabled = YES;
            noLabel.text = @"还没有共享的照片";
            noLabel.textColor = [UIColor colorWithHexString:@"#9e9e9e"];
            noLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
            noLabel.textAlignment = NSTextAlignmentCenter;
            [cellH addSubview:noLabel];
         [cellH addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-84-[noLabel]-140-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(noLabel)]];
        [cellH addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-200-[noLabel(==12)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(noLabel)]];
            
            UIButton *invite = [[UIButton alloc]init];
            cellH.userInteractionEnabled = YES;
            invite.translatesAutoresizingMaskIntoConstraints = NO;
        
            [invite setTitleColor:[UIColor colorWithHexString:@"#ff5252"] forState:UIControlStateNormal];
            invite.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
            [invite setTitle:@"邀请上传" forState:UIControlStateNormal];
            [invite addTarget:self action:@selector(invite:) forControlEvents:UIControlEventTouchUpInside];
            [cellH addSubview:invite];
            [cellH addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[noLabel]-8-[invite(==52)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(noLabel,invite)]];
            [cellH addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-200-[invite(==12)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(invite)]];
        
        }else{
            
            for (NSInteger i = 0 ; i<resultArr.count ;i++) {
              
                if (i < 4) {
                
                   
                    UIImageView *photoImage = [[UIImageView alloc]initWithFrame:CGRectMake(56+(width+8)*i, 190, width,width)];
                    photoImage.contentMode=UIViewContentModeScaleAspectFill;
                    photoImage.clipsToBounds=YES;//  是否剪切掉超出 UIImageView 范围的图片
                    [photoImage setContentScaleFactor:[[UIScreen mainScreen] scale]];

              
                if ([photoPriceArr[i] doubleValue]> 0) {
                    //高斯模糊
                    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
                    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
//                    effectView.alpha = 0.9;
                    effectView.frame = CGRectMake(0, 0, width, width);
                    [photoImage addSubview:effectView];
                }
                 photoImage.tag = 1000+i;
                
                if (resultArr.count <= 4) {
                    if (photoImage.tag == 1000+(resultArr.count-1)) {
                        UILabel *blurLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, width, width)];
                        blurLabel.backgroundColor =[UIColor colorWithWhite:0 alpha:0.5];
                        blurLabel.textColor = [UIColor whiteColor];
                        // blurLabel.text = [NSString stringWithFormat:@"全部\n%@张",photoNumStr];
                        blurLabel.numberOfLines = 2;
                        blurLabel.textAlignment = NSTextAlignmentCenter;
                        blurLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
                        [photoImage addSubview:blurLabel];
                        __block    NSString *photoNum ;
                        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/getUserPhotoSum",REQUESTHEADER] andParameter:@{@"userId":self.userId} success:^(id successResponse) {
                            
                            
                            photoNum =   [NSString stringWithFormat:@"%@",successResponse[@"data"]] ;
                            
                            blurLabel.text = [NSString stringWithFormat:@"全部\n%@张",photoNum];
                        } andFailure:^(id failureResponse) {
                            
                            
                        }];
                        
                    }

                }else{
                    if (photoImage.tag == 1003) {
                        UILabel *blurLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, width, width)];
                        blurLabel.backgroundColor =[UIColor colorWithWhite:0 alpha:0.5];
                        blurLabel.textColor = [UIColor whiteColor];
                        // blurLabel.text = [NSString stringWithFormat:@"全部\n%@张",photoNumStr];
                        blurLabel.numberOfLines = 2;
                        blurLabel.textAlignment = NSTextAlignmentCenter;
                        blurLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
                        [photoImage addSubview:blurLabel];
                        __block    NSString *photoNum ;
                        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/getUserPhotoSum",REQUESTHEADER] andParameter:@{@"userId":self.userId} success:^(id successResponse) {
                            
                            
                            photoNum =   [NSString stringWithFormat:@"%@",successResponse[@"data"]] ;
                            
                            blurLabel.text = [NSString stringWithFormat:@"全部\n%@张",photoNum];
                        } andFailure:^(id failureResponse) {
                            
                            
                        }];
                        
                    }

                }
                                photoImage.userInteractionEnabled = YES;
                
                [cellH addSubview:photoImage];
                
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(goAlbulm)];
                [photoImage addGestureRecognizer:tap];
                
                
                //这个是图片的名字
                
                NSURL *imageUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,resultArr[i]]];
                
                [photoImage sd_setImageWithURL:imageUrl];
                }else {
                  
                }
              
                }
                
            
           
        }
            
    }

    
 

    if (indexPath.section==0) {
         [cellH.certificationBtn addTarget:self action:@selector(checkIsBuyQuanxian) forControlEvents:UIControlEventTouchUpInside];
       cellH.frame = CGRectMake(0, 0, SCREEN_WIDTH, 260);
    }
    if (indexPath.section == 2) {
        if (indexPath.row == 0) {
             cellH.frame = CGRectMake(0, 0, SCREEN_WIDTH, cellH.secoFirHeight);
           
        }
        if (indexPath.row ==1){
             cellH.frame = CGRectMake(0, 0, SCREEN_WIDTH, cellH.secoSecoHeight);
        
        }
        if (indexPath.row == 2 ) {
            cellH.frame = CGRectMake(0, 0, SCREEN_WIDTH, cellH.secoThirHeight);

        }
        if (indexPath.row ==3){
            cellH.frame = CGRectMake(0, 0, SCREEN_WIDTH, cellH.secoFourHeight);
            
        }
        
    }
    
    if (indexPath.section==1) {
        if (otherDynaticArr.count > 0) {
            cellH.secoHeight = (SCREEN_WIDTH-136)/4.0  +54;
            cellH.frame = CGRectMake(0, 0, SCREEN_WIDTH, cellH.secoHeight);
            [self thirdSection];
        }else{
          cellH.secoHeight = 0;
              cellH.frame = CGRectMake(0, 0, SCREEN_WIDTH, cellH.secoHeight);
        }
       
    }
    if (indexPath.section==3) {
        cellH.ThirHeight = 254;
        cellH.frame = CGRectMake(0, 0, SCREEN_WIDTH, cellH.ThirHeight);
        [self fourSection];
    }
    
    if (indexPath.section ==4) {
        cellH.frame = CGRectMake(0, 0, SCREEN_WIDTH, 198);
        [self fifthSectin];
        
    }
    if (indexPath.section ==5) {
           cellH.frame = CGRectMake(0, 0, SCREEN_WIDTH, (SCREEN_WIDTH-136)/4.0 +78);
        [self sixSection];
        
    }
    if (indexPath.section==6) {
        cellH.frame = CGRectMake(0, 0, SCREEN_WIDTH, 152);
        [self sevenSection];
    }
    

   
    return cell;
    
    }

-(void)goAlbulm{
    myAlbumVC *myalbuVC = [[myAlbumVC alloc]init];
    myalbuVC.userId = self.userId;
    myalbuVC.gotoVCIdentifier = @"otherZhuYeVC";
    myalbuVC.userNike = infoModel.nickName;
    [self.navigationController pushViewController:myalbuVC animated:YES];
}
#pragma mark  --邀请别人上传照片
- (void)invite:(UIButton *)sender{
    if ([[CommonTool getUserID] isEqualToString:[NSString stringWithFormat:@"%@",self.userId]]) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode =MBProgressHUDModeText;//显示的模式
        hud.labelText = @"不能邀请自己哦～";
        [hud hide:YES afterDelay:1];
        //设置隐藏的时候是否从父视图中移除，默认是NO
        hud.removeFromSuperViewOnHide = YES;
    }else{
    NSString *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userId"];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/circle/doInvitePush",REQUESTHEADER] andParameter:@{@"userId":userId,@"otherUserId":self.userId,@"flag":@"1"} success:^(id successResponse) {
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            [MBProgressHUD showSuccess:@"已发送邀请"];
            
           
        }
        
        
    } andFailure:^(id failureResponse) {
        
    }];
    }
}


#pragma mark  ---第七个区的内容
- (void)sevenSection{
    
    UILabel *FrendNum = [[UILabel alloc]initWithFrame:CGRectMake(138, 26, SCREEN_WIDTH-276, 14)];
    FrendNum.text = @"有趣值";
    FrendNum.textColor = [UIColor colorWithHexString:@"#424242"];
    FrendNum.textAlignment = NSTextAlignmentCenter;
    FrendNum.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [cellH addSubview:FrendNum];
    
//    for (NSInteger i=0; i<4; i++) {
//        
//        CGFloat beginX = (SCREEN_WIDTH-144)/2;
//        UIImageView *heartImage = [[UIImageView alloc]initWithFrame:CGRectMake(beginX+(24+16)*i, 56, 24, 24)];
//        heartImage.tag = 1000+i;
//        heartImage.image= [UIImage imageNamed:@"xixi"];
//        [cellH addSubview:heartImage];
//    }
    
    seeStarView = [[DQStarView alloc]init];
     seeStarView.frame = CGRectMake((SCREEN_WIDTH-180)/2, 56, 180, 24);
    seeStarView.starTotalCount = 5;
    seeStarView.userInteractionEnabled = NO;
    seeStarView.starSpace = 10*AutoSizeScaleX;
    [cellH addSubview:seeStarView];
    if ([CommonTool dx_isNullOrNilWithObject:[NSString stringWithFormat:@"%@",getGradeNumber]]) {
        [seeStarView ShowDQStarScoreFunction:0];
    }else{
        [seeStarView ShowDQStarScoreFunction:[getGradeNumber floatValue]];}
    
    //他是个这样的人
    UIButton *inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    inviteButton.translatesAutoresizingMaskIntoConstraints = NO;
    [cellH addSubview:inviteButton];
    NSString *inviteTitle = [NSString stringWithFormat:@"%@是个这样的人",self.sex];
    [inviteButton setTitle:inviteTitle forState:UIControlStateNormal];
    inviteButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [inviteButton setTitleColor:[UIColor colorWithHexString:@"#ff5252"] forState:UIControlStateNormal];
    inviteButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [inviteButton addTarget:self action:@selector(OtherFun:) forControlEvents:UIControlEventTouchUpInside];
    [cellH addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-80-[inviteButton]-80-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(inviteButton)]];
    [cellH addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-96-[inviteButton(==32)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(inviteButton)]];
    [inviteButton.layer setMasksToBounds:YES];
    [inviteButton.layer setCornerRadius:16];
    [inviteButton.layer setBorderWidth:1];
    
    [inviteButton.layer setBorderColor:[UIColor colorWithHexString:@"#ff5252"].CGColor];
    
}


#pragma mark  ---他是个这样的人
- (void)OtherFun:(UIButton *)sender{
    otherFunScoreVC *fun = [[otherFunScoreVC alloc]init];
    fun.userId = self.userId;
    fun.userNickName = infoModel.nickName;
    fun.userIcon = infoModel.headImage;
    fun.sex = self.sex;
    [self.navigationController pushViewController:fun animated:YES];
}


#pragma mark   ---第7个区的内容
- (void)focusAndChatView{
    bottoView = [[UIView alloc]init];
//    bottoView.backgroundColor = [UIColor cyanColor];
    bottoView.frame = CGRectMake(0, SCREEN_HEIGHT-84-64, SCREEN_WIDTH, 84);
    [self.view addSubview:bottoView];
   instrBtn = [[UIButton alloc]init];
//    instrBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [instrBtn addTarget:self action:@selector(instrist:) forControlEvents:UIControlEventTouchUpInside];
    if ([FouseStr isEqualToString: @"关 注"]) {
        
         [instrBtn setImage:[UIImage imageNamed:@"nolike"] forState:UIControlStateNormal];
    }else{
       [instrBtn setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
    }
    instrBtn.frame = CGRectMake((SCREEN_WIDTH/2) -75, 16, 40, 40);
    [bottoView addSubview:instrBtn];
    
//    [bottoView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-120-[instrBtn(==40)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(instrBtn)]];
//    [bottoView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-16-[instrBtn(==40)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(instrBtn)]];
    
    
    instLabel = [[UILabel alloc]init];
//    instLabel.translatesAutoresizingMaskIntoConstraints = NO;
    instLabel.text = FouseStr;
    instLabel.textColor = [UIColor colorWithHexString:@"#9e9e9e"];
    instLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
    instLabel.frame = CGRectMake((SCREEN_WIDTH/2) -74, 64, 36, 12);
    [bottoView addSubview:instLabel];
//    [bottoView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-122-[instLabel(==36)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(instLabel)]];
//    [bottoView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-64-[instLabel(==12)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(instLabel)]];
    
    UIButton *chatBtn = [[UIButton alloc]init];
    chatBtn.frame = CGRectMake((SCREEN_WIDTH/2) +35, 16, 40, 40);
//    chatBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [chatBtn addTarget:self action:@selector(chat) forControlEvents:UIControlEventTouchUpInside];
    [chatBtn setImage:[UIImage imageNamed:@"chat"] forState:UIControlStateNormal];
    [bottoView addSubview:chatBtn];
    
//    [bottoView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[chatBtn(==40)]-120-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(chatBtn)]];
//    [bottoView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-16-[chatBtn(==40)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(chatBtn)]];
    
    UILabel *chatLabel =[[UILabel alloc]init];
    chatLabel.frame = CGRectMake((SCREEN_WIDTH/2) +38, 64, 36, 12);
//    chatLabel.translatesAutoresizingMaskIntoConstraints = NO;
    chatLabel.text = @"聊一聊";
    chatLabel.textColor = [UIColor colorWithHexString:@"#9e9e9e"];
    chatLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
    [bottoView addSubview:chatLabel];
//    [bottoView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[chatLabel(==36)]-122-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(chatLabel)]];
//    [bottoView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-64-[chatLabel(==12)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(chatLabel)]];
    
    
    
}
- (void)getFouseData{
    NSString *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userId"];
    
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/circle/getAttention",REQUESTHEADER] andParameter:@{@"userId":userId,@"otherUserId":[NSString stringWithFormat:@"%@",self.userId]} success:^(id successResponse) {
        NSLog(@"关注:%@",successResponse);
        
        NSArray *arr = successResponse[@"data"];
        
        
            if ( ![CommonTool dx_isNullOrNilWithObject:arr]&& arr.count > 0) {
        
            FouseStr = @"已关注";
                instLabel.text = FouseStr;
                
               [instrBtn setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
            }
            else{
                     FouseStr = @"关 注";
                instLabel.text = FouseStr;
                 [instrBtn setImage:[UIImage imageNamed:@"nolike"] forState:UIControlStateNormal];
            }


    } andFailure:^(id failureResponse) {
        
    }];
}

#pragma mark  ---点击关注别人
- (void)instrist:(UIButton *)sender{
     NSString *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userId"];
    if ([self.userId isEqual:[CommonTool getUserID]]) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
         hud.mode =MBProgressHUDModeText;//显示的模式
        hud.labelText = @"不能关注自己哦～";
        [hud hide:YES afterDelay:1];
        //设置隐藏的时候是否从父视图中移除，默认是NO
        hud.removeFromSuperViewOnHide = YES;
       
    }else{
       if ([FouseStr isEqualToString:@"关 注"]) {
       
        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/circle/addAttention",REQUESTHEADER] andParameter:@{@"userId":userId,@"otherUserId":self.userId} success:^(id successResponse) {
            
            if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LY_contact" object:nil];
                [MBProgressHUD showSuccess:@"关注成功!"];
                instLabel.text = @"已关注";
                
                 [instrBtn setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
                FouseStr = @"已关注";
            }
            
        
         
            
            
        } andFailure:^(id failureResponse) {
            
    }];}else{
        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/circle/deleteAttention",REQUESTHEADER] andParameter:@{@"userId":userId,@"otherUserId":self.userId} success:^(id successResponse) {
            
            if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
                 [[NSNotificationCenter defaultCenter] postNotificationName:@"LY_contact" object:nil];
                [MBProgressHUD showSuccess:@"已取消关注"];
                instLabel.text = @"关 注";
                //
                [sender setImage:[UIImage imageNamed:@"nolike"] forState:UIControlStateNormal];
                 FouseStr = @"关 注";
            }
            
            
            
            
            
        } andFailure:^(id failureResponse) {
            
        }];

        
    }
    }
    
}



#pragma mark  ---点击和别人聊天
- (void)chat{
    if (self.userId && [self.userId isEqual:[CommonTool getUserID]]) {
        return;
    }else{
        if (self.isChatVC == YES) {
            [self.navigationController popViewControllerAnimated:NO];
        }else{
    ChatViewController *chatController = [[ChatViewController alloc] initWithChatter:[NSString stringWithFormat:@"qp%@",self.userId]  isGroup:NO] ;
    chatController.isContactsList2Chat = NO;
        chatController.isOtherZhuyeVC = YES;
    chatController.title = self.userNickName;
    chatController.isExistedSendGiftAskNotification = self.isExistedSendGiftAskNotification;
    [self.navigationController pushViewController:chatController animated:YES];
        }

    }
}


#pragma mark    ----第六个区的内容
-(void)sixSection{
    UILabel *giftNameLabel = [[UILabel alloc]init];
    giftNameLabel.text = @"收到的礼物";
    giftNameLabel.frame = CGRectMake(10, 0, SCREEN_WIDTH-20, 14);
    giftNameLabel.textAlignment = NSTextAlignmentCenter;
    giftNameLabel.textColor = [UIColor colorWithHexString:@"#424242"];
    giftNameLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [cellH addSubview:giftNameLabel];
    
  
 
    //礼物中的4张
    
    CGFloat width = (SCREEN_WIDTH-136)/4.0;
    if (giftArr.count==0) {
        //没照片
        // CGFloat width1 = SCREEN_WIDTH-224;
        UILabel *noLabel = [[UILabel alloc]init];
        noLabel.frame = CGRectMake(0, 56, SCREEN_WIDTH, 14);
        noLabel.textAlignment = NSTextAlignmentCenter;
        noLabel.userInteractionEnabled = YES;
        noLabel.text = @"还没有收到礼物哦～";
        noLabel.textColor = [UIColor colorWithHexString:@"#9e9e9e"];
        noLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
        noLabel.textAlignment = NSTextAlignmentCenter;
        [cellH addSubview:noLabel];
 
        
       
        
    }else{
        
        for (NSInteger i = 0 ; i<giftArr.count ;i++) {
           
           
            if (i<4) {
              UIImageView*   photoImage = [[UIImageView alloc]initWithFrame:CGRectMake(56+(width+8)*i, 30, width,width)];
                
                
//            }else{
////                for (NSInteger j=0; j<4; j++) {
////                    photoImage = [[UIImageView alloc]initWithFrame:CGRectMake(56+(width+8)*j, 190, width,width)];
////                }
//                
//            }

            
            
          
            
//            photoImage.tag = 1000+i;
//            if (photoImage.tag == 1000+(giftArr.count-1)) {
//                UILabel *blurLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, width, width)];
//                blurLabel.backgroundColor =[UIColor colorWithWhite:0 alpha:0.5];
//                blurLabel.textColor = [UIColor whiteColor];
//                // blurLabel.text = [NSString stringWithFormat:@"全部\n%@张",photoNumStr];
//                blurLabel.numberOfLines = 2;
//                blurLabel.textAlignment = NSTextAlignmentCenter;
//                blurLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
//                [photoImage addSubview:blurLabel];
//                 blurLabel.text = [NSString stringWithFormat:@"全部\n%lu个",(unsigned long)giftArr.count];
//                __block    NSString *photoNum ;
//                [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/getUserPhotoSum",REQUESTHEADER] andParameter:@{@"userId":self.userId} success:^(id successResponse) {
//                    
//                    
//                    photoNum =   [NSString stringWithFormat:@"%@",successResponse[@"data"]] ;
//                    
//                    blurLabel.text = [NSString stringWithFormat:@"全部\n%@个",photoNum];
//                } andFailure:^(id failureResponse) {
//                    
//                    
//                }];
                
          //  }
            photoImage.userInteractionEnabled = YES;
//            photoImage.backgroundColor = [UIColor cyanColor];
            [cellH addSubview:photoImage];
            //这个是图片的名字
            ReceiveGiftModel *dataModel = giftArr[i];
            NSURL *imageUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,dataModel.giftIcon]];
            
                [photoImage sd_setImageWithURL:imageUrl];
                
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(goGiftList)];
                [photoImage addGestureRecognizer:tap];

            }
            
          
        }
        
        
    }
    
    UIButton *giveGiftBtn = [[UIButton alloc]init];
    giveGiftBtn.frame = CGRectMake(80, width +45, SCREEN_WIDTH-160, 32);
    giveGiftBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [giveGiftBtn setTitleColor:[UIColor colorWithHexString:@"#ff5252"] forState:UIControlStateNormal];
    giveGiftBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
    [giveGiftBtn setTitle:[NSString stringWithFormat:@"送%@礼物",self.sex] forState:UIControlStateNormal];
    [giveGiftBtn addTarget:self action:@selector(giveGift) forControlEvents:UIControlEventTouchUpInside];
    [giveGiftBtn.layer setMasksToBounds:YES];
    [giveGiftBtn.layer setCornerRadius:16];
    [giveGiftBtn.layer setBorderWidth:1];
    [giveGiftBtn.layer setBorderColor:[UIColor colorWithHexString:@"#ff5252"].CGColor];
    [cellH addSubview:giveGiftBtn];
}
-(void)goGiftList{
    ReceivedGiftVC *vc = [[ReceivedGiftVC alloc]init];
    vc.userId = self.userId;
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark    ----送她礼物界面
-(void)giveGift{
    /**
     *  送礼物界面
     */
   
        LYSendGiftViewController *vc = [LYSendGiftViewController new];
        vc.userName                  = infoModel.nickName;
        vc.avatarImageURL            = infoModel.headImage;
        vc.friendID                  = self.userId;
        [self.navigationController pushViewController:vc animated:YES];
   
}
#pragma mark    ----第五个区的内容
- (void)fifthSectin{
    UILabel *instreLabel = [[UILabel alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-42)/2, 26, 42, 14)];
    
    instreLabel.text = @"感兴趣";
    instreLabel.textColor = [UIColor colorWithHexString:@"#424242"];
    instreLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [cellH addSubview:instreLabel];
    
    
    //他感兴趣的约会
    
    UIButton *appoButton = [[UIButton alloc]init];
    appoButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    [cellH addSubview:appoButton];
    
    NSString *sex;
    if ([[NSString stringWithFormat:@"%@",infoModel.sex] isEqualToString:@"1"]) {
        sex = @"她";
    }
    
    if ([[NSString stringWithFormat:@"%@",infoModel.sex] isEqualToString:@"0"]) {
        sex = @"他";
    }
    
    
    NSString *num = [NSString stringWithFormat:@"%@感兴趣的%@个约会 >",sex,userInterestSum];
    
    
    [appoButton setTitle:num forState:UIControlStateNormal];
    appoButton.titleLabel.textAlignment = NSTextAlignmentRight;
    
    [appoButton setTitleColor:[UIColor colorWithHexString:@"#757575"] forState:UIControlStateNormal];
    appoButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    [appoButton addTarget:self action:@selector(moreInstred:) forControlEvents:UIControlEventTouchUpInside];
    
    [cellH addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[appoButton(==150)]-16-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(appoButton)]];
    [cellH addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-162-[appoButton(==12)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(appoButton)]];
    
    if (otherInstrdArr.count ==0) {
         [appoButton setTitle:[NSString stringWithFormat:@"%@还没有感兴趣的约会",sex] forState:UIControlStateNormal];
        appoButton.userInteractionEnabled = NO;
        //还没感兴趣的约会
        UILabel *noAppintLabel = [[UILabel alloc]init];
        noAppintLabel.translatesAutoresizingMaskIntoConstraints = NO;
        noAppintLabel.text = [NSString stringWithFormat:@"%@还没有感兴趣的约会哦",infoModel.nickName];
        noAppintLabel.textColor = [UIColor colorWithHexString:@"#9e9e9e"];
        noAppintLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
        noAppintLabel.textAlignment = NSTextAlignmentCenter;
        [cellH addSubview:noAppintLabel];
        [cellH addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[noAppintLabel]-10-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(noAppintLabel)]];
        [cellH addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-96-[noAppintLabel(==12)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(noAppintLabel)]];
    }
    
    
    
    //leftImage
    UIImageView *leftImage = [[UIImageView alloc]initWithFrame:CGRectMake(24, 66, 32, 32)];
    leftImage.image = [UIImage imageNamed:@"quote_1"];
    [cellH addSubview:leftImage];
    
    //rightImage
    UIImageView *rightImage = [[UIImageView alloc]init];
    rightImage.translatesAutoresizingMaskIntoConstraints = NO;
    rightImage.image = [UIImage imageNamed:@"quote_2"];
    [cellH addSubview:rightImage];
    
    [cellH addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[rightImage(==32)]-24-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(rightImage)]];
    [cellH addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-106-[rightImage(==32)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(rightImage)]];
    
    
    
    if (otherInstrdArr.count >=1) {
        appoButton.userInteractionEnabled = YES;
        OtherAppointModel *insteModel = otherInstrdArr[0];
        //约的类型
        UILabel *type1Label = [[UILabel alloc]initWithFrame:CGRectMake(60, 78,60, 20)];
        type1Label.text = insteModel.dateName;
        type1Label.textColor = [UIColor colorWithHexString:@"#424242"];
        type1Label.font = [UIFont fontWithName:@"PingFangSC-Regular" size:20];
        [cellH addSubview:type1Label];
        //约会的时间
        UILabel *aPpointimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(130, 86,84, 12)];
        aPpointimeLabel.text = [CommonTool timestampSwitchTime:[insteModel.dateTime doubleValue]/1000 andFormatter:@"YYYY-MM-dd"] ;
        aPpointimeLabel.textColor = [UIColor colorWithHexString:@"#424242"];
        aPpointimeLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
        [cellH addSubview:aPpointimeLabel];
        
    
        //发布时间
        UILabel *timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 106,134, 12)];
        
        timeLabel.text = [NSString stringWithFormat:@"%@发布",[CommonTool updateTimeForRow:insteModel.sendDateTime]];
        timeLabel.textColor = [UIColor colorWithHexString:@"#9e9e9e"];
        timeLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
        [cellH addSubview:timeLabel];
    }
    
        
        
        
    
    
    
   
    
    
    
}


#pragma mark   ---他感兴趣的约会
- (void)moreInstred:(UIButton *)sender{
    
    myInrestedVC *insre = [[myInrestedVC alloc]init];
    insre.userId = self.userId;
    insre.userNike = self.userNickName;
    insre.gotoVCIdentifier = @"otherZhuYeVC";
    [self.navigationController pushViewController:insre animated:YES];
    
    
}


#pragma mark   ----第四个区的约会内容
- (void)fourSection{
//    view.backgroundColor = [UIColor cyanColor];
//    NSLog(@"约会个数:%ld",otherDataArr.count);
  
    
    UILabel *appointLabel = [[UILabel alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-28)/2, 26, 28, 14)];
    
    appointLabel.text = @"约会";
    appointLabel.textColor = [UIColor colorWithHexString:@"#424242"];
    appointLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [cellH addSubview:appointLabel];
    
    if (otherDataArr.count == 0) {
        
        //leftImage
        UIImageView *leftImage = [[UIImageView alloc]initWithFrame:CGRectMake(24,66,32,32)];
        leftImage.image = [UIImage imageNamed:@"quote_1"];
        [cellH addSubview:leftImage];
        
        //rightImage
        UIImageView *right1Image = [[UIImageView alloc]init];
        right1Image.translatesAutoresizingMaskIntoConstraints = NO;
        right1Image.image = [UIImage imageNamed:@"quote_2"];
        [cellH addSubview:right1Image];
        [cellH addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[right1Image(==32)]-24-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(right1Image)]];
        [cellH addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-106-[right1Image(==32)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(right1Image)]];
        
        //暂时还没发布过约会
            UILabel *noAppintLabel = [[UILabel alloc]init];
            noAppintLabel.translatesAutoresizingMaskIntoConstraints = NO;
          noAppintLabel.text = [NSString stringWithFormat:@"%@还没发布过约会",infoModel.nickName];
          noAppintLabel.textColor = [UIColor colorWithHexString:@"#9e9e9e"];
            noAppintLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
            noAppintLabel.textAlignment = NSTextAlignmentCenter;
           [cellH addSubview:noAppintLabel];
            [cellH addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-80-[noAppintLabel]-80-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(noAppintLabel)]];
            [cellH addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-96-[noAppintLabel(==12)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(noAppintLabel)]];
        
    }
    
    
    if (otherDataArr.count ==1) {
        
        OtherAppointModel *model = otherDataArr[0];
        //leftImage
        UIImageView *leftImage = [[UIImageView alloc]initWithFrame:CGRectMake(24, 66, 32, 32)];
        leftImage.image = [UIImage imageNamed:@"quote_1"];
        [cellH addSubview:leftImage];
        
        //约的类型
        UILabel *type1Label = [[UILabel alloc]initWithFrame:CGRectMake(60, 78,60, 20)];
        type1Label.text = [NSString stringWithFormat:@"约%@",model.dateName];
        type1Label.textColor = [UIColor colorWithHexString:@"#424242"];
        type1Label.font = [UIFont fontWithName:@"PingFangSC-Regular" size:20];
        [cellH addSubview:type1Label];
        
        //发布时间
        UILabel *timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(36, 106,88, 12)];
        timeLabel.text = [NSString stringWithFormat:@"%@发布",[CommonTool updateTimeForRow:model.sendDateTime]];
        timeLabel.textColor = [UIColor colorWithHexString:@"#9e9e9e"];
        timeLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
        [cellH addSubview:timeLabel];
        
        
        //rightImage
        UIImageView *right1Image = [[UIImageView alloc]init];
        right1Image.translatesAutoresizingMaskIntoConstraints = NO;
        right1Image.image = [UIImage imageNamed:@"quote_2"];
        [cellH addSubview:right1Image];
        [cellH addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-116-[right1Image(==32)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(right1Image)]];
        [cellH addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-106-[right1Image(==32)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(right1Image)]];
        

    }
    
    
    if (otherDataArr.count >=2) {
        
        OtherAppointModel *model = otherDataArr[0];
        //leftImage
        UIImageView *leftImage = [[UIImageView alloc]initWithFrame:CGRectMake(24,66,32,32)];
        leftImage.image = [UIImage imageNamed:@"quote_1"];
        [cellH addSubview:leftImage];
        
        //约的类型
        UILabel *type1Label = [[UILabel alloc]initWithFrame:CGRectMake(60, 78,60, 20)];
        type1Label.text = [NSString stringWithFormat:@"约%@",model.dateName];
        type1Label.textColor = [UIColor colorWithHexString:@"#424242"];
        type1Label.font = [UIFont fontWithName:@"PingFangSC-Regular" size:20];
        [cellH addSubview:type1Label];
        
        //发布时间
        UILabel *timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(36,106,88, 12)];
        timeLabel.text = [NSString stringWithFormat:@"%@发布",[CommonTool updateTimeForRow:model.sendDateTime]];
        timeLabel.textColor = [UIColor colorWithHexString:@"#9e9e9e"];
        timeLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
        [cellH addSubview:timeLabel];
        
        
        //rightImage
        UIImageView *rightImage = [[UIImageView alloc]initWithFrame:CGRectMake(116,106, 32, 32)];
        rightImage.image = [UIImage imageNamed:@"quote_2"];
        [cellH addSubview:rightImage];

        
        //右边
        //leftImage
        OtherAppointModel *model1 = otherDataArr[1];
        
        UIImageView *left1Image = [[UIImageView alloc]init];
        left1Image.translatesAutoresizingMaskIntoConstraints = NO;
        left1Image.image = [UIImage imageNamed:@"quote_1"];
        [cellH addSubview:left1Image];
        
        [cellH addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[left1Image(==32)]-116-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(left1Image)]];
        [cellH addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-66-[left1Image(==32)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(left1Image)]];
        
        
        
        //约的类型
        UILabel *type2Label = [[UILabel alloc]init];
        type2Label.translatesAutoresizingMaskIntoConstraints = NO;
        type2Label.text = [NSString stringWithFormat:@"约%@",model1.dateName];
        type2Label.textColor = [UIColor colorWithHexString:@"#424242"];
        type2Label.font = [UIFont fontWithName:@"PingFangSC-Regular" size:20];
        [cellH addSubview:type2Label];
        [cellH addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[type2Label(==80)]-32-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(type2Label)]];
        [cellH addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-78-[type2Label(==20)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(type2Label)]];
        
        
        
        //发布时间
        UILabel *time1Label = [[UILabel alloc]init];
        time1Label.translatesAutoresizingMaskIntoConstraints = NO;
        time1Label.text = [NSString stringWithFormat:@"%@发布",[CommonTool updateTimeForRow:model1.sendDateTime]];
        time1Label.textColor = [UIColor colorWithHexString:@"#9e9e9e"];
        time1Label.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
        [cellH addSubview:time1Label];
        [cellH addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[time1Label(==88)]-64-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(time1Label)]];
        [cellH addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-106-[time1Label(==12)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(time1Label)]];
        
        
        //rightImage
        UIImageView *right1Image = [[UIImageView alloc]init];
        right1Image.translatesAutoresizingMaskIntoConstraints = NO;
        right1Image.image = [UIImage imageNamed:@"quote_2"];
        [cellH addSubview:right1Image];
        [cellH addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[right1Image(==32)]-24-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(right1Image)]];
        [cellH addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-106-[right1Image(==32)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(right1Image)]];
        
        
        

    }
  
    //发布的约会
    
    UIButton *appoButton = [[UIButton alloc]init];
    appoButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    [cellH addSubview:appoButton];
    
  
    
    
    NSString *num = [NSString stringWithFormat:@"%@发布的%@个约会 >",_sex,userDateSum];
    [appoButton setTitle:num forState:UIControlStateNormal];
    appoButton.titleLabel.textAlignment = NSTextAlignmentRight;
    
    [appoButton setTitleColor:[UIColor colorWithHexString:@"#757575"] forState:UIControlStateNormal];
    appoButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    [appoButton addTarget:self action:@selector(moreappoint:) forControlEvents:UIControlEventTouchUpInside];
    
    [cellH addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[appoButton(==108)]-16-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(appoButton)]];
    [cellH addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-162-[appoButton(==12)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(appoButton)]];
    
    if (otherDataArr.count == 0) {
         [appoButton setTitle:[NSString stringWithFormat:@"%@还没有发布约会",_sex] forState:UIControlStateNormal];
        appoButton.userInteractionEnabled =NO;
    }else{
        appoButton.userInteractionEnabled =YES;
    }
    
    
    //邀请参加我的约会
    UIButton *inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    inviteButton.translatesAutoresizingMaskIntoConstraints = NO;
    [cellH addSubview:inviteButton];
    
    NSString *inviteTitle = [NSString stringWithFormat:@"邀请%@参加我的约会",_sex];
    [inviteButton setTitle:inviteTitle forState:UIControlStateNormal];
    inviteButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [inviteButton setTitleColor:[UIColor colorWithHexString:@"#ff5252"] forState:UIControlStateNormal];
    inviteButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [inviteButton addTarget:self action:@selector(inviteSeeMyYuehui:) forControlEvents:UIControlEventTouchUpInside];
    [cellH addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-80-[inviteButton]-80-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(inviteButton)]];
    [cellH addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-198-[inviteButton(==32)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(inviteButton)]];
    [inviteButton.layer setMasksToBounds:YES];
    [inviteButton.layer setCornerRadius:16];
    [inviteButton.layer setBorderWidth:1];
    
    [inviteButton.layer setBorderColor:[UIColor colorWithHexString:@"#ff5252"].CGColor];
    
}

#pragma mark  ---第三个区 动态
-(void)thirdSection{
    
    //dongtai
    UIButton *inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    inviteButton.translatesAutoresizingMaskIntoConstraints = NO;
    [cellH addSubview:inviteButton];
    
    NSString *inviteTitle = [NSString stringWithFormat:@"%@的视频",_sex];
    [inviteButton setTitle:inviteTitle forState:UIControlStateNormal];
    inviteButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [inviteButton setTitleColor:[UIColor colorWithHexString:@"#424242"] forState:UIControlStateNormal];
    inviteButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [inviteButton addTarget:self action:@selector(seeTaDynatic) forControlEvents:UIControlEventTouchUpInside];
    [cellH addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-80-[inviteButton]-80-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(inviteButton)]];
    [cellH addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-24-[inviteButton(==14)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(inviteButton)]];
//    [inviteButton.layer setMasksToBounds:YES];
//    [inviteButton.layer setCornerRadius:16];
//    [inviteButton.layer setBorderWidth:1];
    
    [inviteButton.layer setBorderColor:[UIColor colorWithHexString:@"#ff5252"].CGColor];
    
      CGFloat width = (SCREEN_WIDTH-136)/4.0;
    if (otherDynaticArr.count > 0) {
        
        for (NSInteger i = 0 ; i<otherDynaticArr.count ;i++) {
            
            if (i < 4) {
                
                
                UIImageView *photoImage = [[UIImageView alloc]initWithFrame:CGRectMake(56+(width+8)*i, 54, width,width)];
                photoImage.userInteractionEnabled = YES;
                photoImage.contentMode=UIViewContentModeScaleAspectFill;
                photoImage.clipsToBounds=YES;//  是否剪切掉超出 UIImageView 范围的图片
                [photoImage setContentScaleFactor:[[UIScreen mainScreen] scale]];
                 [cellH addSubview:photoImage];
                //这个是图片的名字
                
                NSURL *imageUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,otherDynaticArr[i]]];
                
                [photoImage sd_setImageWithURL:imageUrl];
                
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(seeTaDynatic)];
                [photoImage addGestureRecognizer:tap];
                
                UIImageView *palyerImagV = [[UIImageView alloc]init];
                //                    palyerImagV.center = showImageV.center;
                palyerImagV.frame = CGRectMake(photoImage.height/2  -15, photoImage.height/2  -15, 30, 30);
                palyerImagV.image = [UIImage  imageNamed:@"播放icon"];
                [photoImage addSubview:palyerImagV];
            }
            
        }
       
 
    }
    
    

}

-(void)seeTaDynatic{
    //我的动态
    MyDynamicViewController *fun = [[ MyDynamicViewController alloc]init];
    fun.userID= self.userId;
    fun.userName = infoModel.nickName;
    [self.navigationController pushViewController:fun animated:YES];

}
#pragma mark  ---邀请他参加我的约会
-(void)inviteSeeMyYuehui:(UIButton *)sender{
    if ([[NSString stringWithFormat:@"%@",self.userId]  isEqualToString:[CommonTool getUserID]]) {
        [MBProgressHUD showError:@"不能邀请自己哦～"];
        
        return;
    }else{

    myDataVC *myVC = [[myDataVC alloc]init];
    myVC.otherUserId = self.userId;
    myVC.otherZhuYeVC = @"otherZhuYeVC";
    
        [self.navigationController pushViewController:myVC animated:YES];}
}
#pragma mark  ---他发布的更多约会
- (void)moreappoint:(UIButton *)sender{
    
    //NSLog(@"77发布约会7777");
    
    otherDataVC *othe = [[otherDataVC alloc]init];
    othe.userName = infoModel.nickName;
    othe.otherUserId = self.userId;
    [self.navigationController pushViewController:othe animated:YES];
}

#pragma mark   视频认证状态以及地址
-(void)getPersonalVideoAffirm{
   
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/getPersonalVideoAffirm", REQUESTHEADER] andParameter:@{
                                                                                                                                           @"userId": self.userId}
                                success:^(id successResponse) {
                                    MLOG(@"是否是视频认证结果:%@", successResponse);
                                    if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
                                        
                                        if ([[NSString stringWithFormat:@"%@", successResponse[@"data"][@"isAffirm"]] isEqualToString:@"2"] ) {
                                            self.videoUrl =[NSString stringWithFormat:@"%@", successResponse[@"data"][@"userVideo"]];
                   cellH.certificationBtn.hidden = NO;
                                            [infoTable reloadData];
//                                             [weakSelf  checkIsBuyQuanxian];
                                            
                                            
                                        }else{
                                            [MBProgressHUD hideHUD];
//                                            [MBProgressHUD showError:[NSString stringWithFormat:@"%@还没有视频认证过", self.sex]];
                                            
                                            cellH.certificationBtn.hidden = YES;
                                            
                                        }
                                        
                                    } else {
                                        [MBProgressHUD hideHUD];
                                        [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"errorMsg"]]];
                                    }
                                }
                             andFailure:^(id failureResponse) {
                                 [MBProgressHUD hideHUD];
                                 [MBProgressHUD showError:@"服务器繁忙,请重试"];
                             }];
    
    
}
#pragma mark 购买过权限
-(void)checkIsBuyQuanxian{
    
    
    WS(weakSelf)
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/order/getOrderRecord", REQUESTHEADER] andParameter:@{
                                                                                                                                    @"userId": [CommonTool getUserID],@"otherUserId": self.userId,@"buyType": @"2" }
                                success:^(id successResponse) {
                                    MLOG(@"否购买过权限结果:%@", successResponse);
                                    if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
                                        NSArray*arr = successResponse[@"data"];
                                        if ( arr && arr.count >0) {
                                            
                                            MPMoviePlayerViewController *player = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", IMAGEHEADER, weakSelf.videoUrl]]];
                                            player.moviePlayer.shouldAutoplay   = YES;
                                            [weakSelf presentMoviePlayerViewControllerAnimated:player];
                                        }else{
                                            [weakSelf  playCerVideo];
                                        }
                                        
                                    } else {
                                        [MBProgressHUD hideHUD];
                                        [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"errorMsg"]]];
                                    }
                                }
                             andFailure:^(id failureResponse) {
                                 [MBProgressHUD hideHUD];
                                 [MBProgressHUD showError:@"服务器繁忙,请重试"];
                             }];
    
}

#pragma mark  ---判断用户是否可查看其他用户认证视频
-(void)playCerVideo{
    WS(weakSelf)
//    [MBProgressHUD showMessage:nil];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/getVideoSee", REQUESTHEADER] andParameter:@{
                                                                                                                                @"userId": [CommonTool getUserID]
                                                                                                                                }
                                success:^(id successResponse) {
                                    /**
                                        300 去认证视频次数过多  200
                                     */
//                                     [MBProgressHUD hideHUD];
                                    if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
                                       
                                        NSLog(@"视频播放：%@", successResponse);
                                        MPMoviePlayerViewController *player = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", IMAGEHEADER, weakSelf.videoUrl]]];
                                        player.moviePlayer.shouldAutoplay   = YES;
                                        [weakSelf presentMoviePlayerViewControllerAnimated:player];
                                    }

                                    else if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"300"]) {
                                      
                                        [weakSelf getMyVideoAffirm];
                                      
                                    }
                                }
                             andFailure:^(id failureResponse) {
                                 [MBProgressHUD hideHUD];
                                 [MBProgressHUD showError:@"服务器繁忙,请重试"];
                             }];
    
}


#pragma mark   查看自己视频认证状态以及地址
-(void)getMyVideoAffirm{
    WS(weakSelf)
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/getPersonalVideoAffirm", REQUESTHEADER] andParameter:@{
                                                                                                                                           @"userId": [CommonTool  getUserID]}
                                success:^(id successResponse) {
                                    MLOG(@"是否是视频认证结果:%@", successResponse);
                                    if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
                                        
                                        if ([[NSString stringWithFormat:@"%@", successResponse[@"data"][@"isAffirm"]] isEqualToString:@"2"] ) {
                                            [self  buyVideoQuanXianClick];
                                            
                                            
                                        }else{
                                            [MBProgressHUD hideHUD];
                                            //                                            [MBProgressHUD showError:[NSString stringWithFormat:@"%@还没有视频认证过", self.sex]];
                                            [weakSelf uploadVideoLookMoreVideo];
                                            
                                        }
                                        
                                    } else {
                                        [MBProgressHUD hideHUD];
                                        [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"errorMsg"]]];
                                    }
                                }
                             andFailure:^(id failureResponse) {
                                 [MBProgressHUD hideHUD];
                                 [MBProgressHUD showError:@"服务器繁忙,请重试"];
                             }];
    
    
}

#pragma mark---- 上传验证视频获得更多播放机会
-(void)uploadVideoLookMoreVideo{
    blurView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    blurView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    [self.view addSubview:blurView];
    
    UIButton * hidBtn = [[UIButton alloc]init];
    hidBtn.backgroundColor = [UIColor clearColor];
    hidBtn.frame = blurView.bounds;
    [hidBtn addTarget:self action:@selector(hidClick:) forControlEvents:UIControlEventTouchUpInside];
    [blurView addSubview:hidBtn];
    
    UIView *image = [[UIView alloc]init];
    image.translatesAutoresizingMaskIntoConstraints = NO;
    image.backgroundColor = [UIColor whiteColor];
    image.userInteractionEnabled = YES;
    [blurView addSubview:image];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[image]-20-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(image)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-140-[image(==160)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(image)]];
    
    //取消  确定  按钮
    UIButton *cancel = [[UIButton alloc]init];
    cancel.translatesAutoresizingMaskIntoConstraints = NO;
    [cancel setImage:[UIImage  imageNamed:@""] forState:UIControlStateNormal];
    cancel.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [cancel addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    [image addSubview:cancel];
    [image addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[cancel(==30)]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(cancel)]];
    [image addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[cancel(==30)]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(cancel)]];
    
    UILabel *sureLabel = [[UILabel alloc]initWithFrame:CGRectMake(24, 24, 96, 16)];
    sureLabel.text = @"温馨提示";
    sureLabel.textColor = [UIColor colorWithHexString:@"424242"];
    sureLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:16];
    [image addSubview:sureLabel];
    
    UILabel *aletLabel = [[UILabel alloc]init];
    aletLabel.translatesAutoresizingMaskIntoConstraints = NO;
    aletLabel.text = @"基于公平原则，您需要自拍一段视频才能看更多TA人视频";
    aletLabel.numberOfLines = 0;
    aletLabel.textColor = [UIColor colorWithHexString:@"#757575"];
    aletLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
    [image addSubview:aletLabel];
    [image addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-24-[aletLabel]-24-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(aletLabel)]];
    [image addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-56-[aletLabel(==40)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(aletLabel)]];
    
    
    //取消  确定  按钮
    UIButton *leftBtn = [[UIButton alloc]init];
    leftBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [leftBtn setTitle:@"拍段形象视频" forState:UIControlStateNormal];
    [leftBtn setTitleColor:[UIColor colorWithHexString:@"#424242"] forState:UIControlStateNormal];
    leftBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [leftBtn addTarget:self action:@selector(gotoCertificationVideoVC:) forControlEvents:UIControlEventTouchUpInside];
    [image addSubview:leftBtn];
    [image addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-30-[leftBtn(==100)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(leftBtn)]];
    [image addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-120-[leftBtn(==32)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(leftBtn)]];
    
    
    UIButton *sure = [[UIButton alloc]init];
    sure.translatesAutoresizingMaskIntoConstraints = NO;
    [sure setTitle:@"金币观看" forState:UIControlStateNormal];
    [sure setTitleColor:[UIColor colorWithHexString:@"#424242"] forState:UIControlStateNormal];
    sure.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [sure addTarget:self action:@selector(buyVideoQuanXianClick) forControlEvents:UIControlEventTouchUpInside];
    [image addSubview:sure];
    [image addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[sure(==80)]-30-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(sure)]];
    [image addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-120-[sure(==32)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(sure)]];

}
-(void)hidClick:(UIButton *)sender{
    [blurView removeFromSuperview];
    [sender.superview removeFromSuperview];
}

-(void)gotoCertificationVideoVC:(UIButton *)sender{
    [blurView removeFromSuperview];
    [sender.superview removeFromSuperview];
    VideoKnowViewController * vc = [[VideoKnowViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
    
}
//购买视频权限
-(void)buyVideoQuanXianClick{
    if (blurView) {
        [blurView removeFromSuperview];
    }
    
    

//        if (userKeyNum > 0) {
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"消耗1枚钥匙查看认证视频" message:@"温馨提示：免费查看次数已用完，购买过后即可永久查看" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//            alertView.tag = 1000;
//            [alertView show];
//        }else{
            if (goldsNum  >= 50) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"花费50金币查看认证视频" message:@"温馨提示：免费查看次数已用完，购买过后即可永久查看" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                alertView.tag = 1001;
                [alertView show];
            }else{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"充值金币" message:@"免费查看次数已用完，金币不足，将无法查看认证视频" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去充值", nil];
                alertView.tag = 1002;
                [alertView show];
            }
//       }
    


}
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
     WS(weakSelf)
    if (alertView.tag == 1000) {
        if (1 == buttonIndex) {
            [weakSelf userKeyBuyQuanxian];
           
            
        }
    }
    if (alertView.tag == 1001) {
        if (1 == buttonIndex) {
            [weakSelf goldsBuyQuanxian];
        }
    }
    if (alertView.tag == 1002) {
        if (1 == buttonIndex) {
            MyMoneyVC *myMoney = [[MyMoneyVC alloc] init];
            [weakSelf.navigationController pushViewController:myMoney animated:YES];
        }
    }
    //花费钥匙购买性
    if (alertView.tag == 1003) {
        if (1 == buttonIndex) {
           
            NSDictionary *dic =    @{@"userId": [CommonTool getUserID],@"otherUserId": self.userId,@"buyType": @"4",@"keyNumber": @"1",@"remarkInfo":@"userOpinionSex"};
            [LYHttpPoster requestSpendUserKeyWithParameters:dic Block:^(NSString *codeStr) {
                if ([[NSString stringWithFormat:@"%@",codeStr] isEqualToString:@"200"])  {
                    userKeyNum = userKeyNum-1;
                    isBuyKanfa = YES;
                     [MBProgressHUD showSuccess:@"恭喜您获得查看权限"];
                     [weakSelf creatAbooutViewWithTitle:@"关于性，我想说..." content:[NSString stringWithFormat:@"%@",infoModel.aboutSex] ];
                }
            }];
        }
    }
    //花费金币购买性
    if (alertView.tag == 1004) {
        if (1 == buttonIndex) {
            NSDictionary *dic = @{
                                  @"userId": [CommonTool getUserID],@"otherUserId": self.userId,@"usedType": @"record",@"buyType": @"4",@"goldPrice": @"100",@"remarkInfo": @"userOpinionSex",@"userCaptcha":[CommonTool getUserCaptcha]};
            [LYHttpPoster requestSpendGoldsWithParameters:dic Block:^(NSString *codeStr) {
                if ([[NSString stringWithFormat:@"%@",codeStr] isEqualToString:@"200"])  {
                    userKeyNum = userKeyNum-1;
                    isBuyKanfa = YES;
                    [MBProgressHUD showSuccess:@"恭喜您获得查看权限"];
                    [weakSelf creatAbooutViewWithTitle:@"关于性，我想说..." content:[NSString stringWithFormat:@"%@",infoModel.aboutSex] ];
                }
            }];
        }
    }
    
    
    if (alertView.tag == 1005) {
        if (buttonIndex == 1) {
            [weakSelf buyContactQuanxian];
        }
    }
}

-(void)userKeyBuyQuanxian{
  
    //服务器获取图片
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/order/updateOrderKey", REQUESTHEADER] andParameter:@{
                                                                                                                                    @"userId": [CommonTool getUserID],@"otherUserId": self.userId,@"buyType": @"2",@"keyNumber": @"1",@"remarkInfo": [NSString stringWithFormat:@"%@",self.videoUrl]}
                                success:^(id successResponse) {
                                    MLOG(@"钥匙购买权限结果:%@", successResponse);
                                    if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
                                        [MBProgressHUD showSuccess:@"解锁成功"];
                                       
                                        userKeyNum = userKeyNum-1;
                                        
                                        MPMoviePlayerViewController *player = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", IMAGEHEADER, self.videoUrl]]];
                                        player.moviePlayer.shouldAutoplay   = YES;
                                        [self presentMoviePlayerViewControllerAnimated:player];
                                    } else {
                                        [MBProgressHUD hideHUD];
                                        [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"errorMsg"]]];
                                    }
                                }
                             andFailure:^(id failureResponse) {
                                 [MBProgressHUD hideHUD];
                                 [MBProgressHUD showError:@"服务器繁忙,请重试"];
                             }];
    
}

-(void)goldsBuyQuanxian{
    
    
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/order/updateOrderGold", REQUESTHEADER] andParameter:@{
                                                                                                                                     @"userId": [CommonTool getUserID],@"otherUserId": self.userId,@"usedType": @"record",@"buyType": @"2",@"goldPrice": @"50",@"userCaptcha":[CommonTool getUserCaptcha]}
                                success:^(id successResponse) {
                                    MLOG(@"金币购买权限结果:%@", successResponse);
                                    if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
                                        [MBProgressHUD showSuccess:@"解锁成功"];
                                        goldsNum = goldsNum-50;
                                        
                                        
                                        MPMoviePlayerViewController *player = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", IMAGEHEADER, self.videoUrl]]];
                                        player.moviePlayer.shouldAutoplay   = YES;
                                        [self presentMoviePlayerViewControllerAnimated:player];
                                    } else {
                                        [MBProgressHUD hideHUD];
                                        [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"errorMsg"]]];
                                    }
                                }
                             andFailure:^(id failureResponse) {
                                 [MBProgressHUD hideHUD];
                                 [MBProgressHUD showError:@"服务器繁忙,请重试"];
                             }];
    
}
#pragma mark 获得账户金币判断钥匙数量
- (void)getCoinNum{
    
    
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/getUserPower",REQUESTHEADER] andParameter:@{@"userId":[CommonTool getUserID]} success:^(id successResponse) {
        //
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            //
            NSLog(@"myMoneysuccessResponse---%@",successResponse);
            NSDictionary *dataDic = successResponse[@"data"];
            goldsNum = [dataDic[@"userGold"] integerValue];
            userKeyNum = [dataDic[@"userKey"] integerValue];
            
            
            
        }else{
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
        }
        
    } andFailure:^(id failureResponse) {
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
        NSLog(@"失败:%@",failureResponse);
    }];
    //
    
    
}


#pragma mark  -擅长


- (void)getGood{

 [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/getPersonalInfo",REQUESTHEADER] andParameter:@{@"userId":self.userId} success:^(id successResponse) {


        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            goodStr = successResponse[@"data"][@"userGoodAt"];
            if (goodStr.length > 0) {
                //以逗号分开   判断有几个擅长
                goodArr = [goodStr componentsSeparatedByString:@","];
            }
          
            [infoTable reloadData];

        }else{
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
        }

    } andFailure:^(id failureResponse) {
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
        NSLog(@"失败:%@",failureResponse);
    }];

   

}

-(void)checkIsSeeContact{
    if ([[CommonTool getUserVipLevel] integerValue] >= 2) {
        [self checkIsBuyedContact];
    }else{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode =MBProgressHUDModeText;//显示的模式
        hud.labelText = @"只有vip2及以上的用户才有权限查看";
        [hud hide:YES afterDelay:1];
        //设置隐藏的时候是否从父视图中移除，默认是NO
        hud.removeFromSuperViewOnHide = YES;
       
    }
}
-(void)checkIsBuyedContact{
    
    WS(weakSelf)
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/order/getOrderRecord", REQUESTHEADER] andParameter:@{
                                                                                                                                    @"userId": [CommonTool getUserID],@"otherUserId": weakSelf.userId,@"buyType": @"1" }
                                success:^(id successResponse) {
                                    MLOG(@"否购买过权限结果:%@", successResponse);
                                    if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
                                        NSArray*arr = successResponse[@"data"];
                                        if ( arr && arr.count >0) {
                                            
                                            [weakSelf contactClick];
                                        }else{
                                            
                                            
                                            if (goldsNum  >= 300) {
                                                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"购买联系方式" message:@"需花费300金币来购买联系方式" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"购买", nil];
                                                alertView.tag = 1005;
                                                [alertView show];
                                            }else{
                                                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"金币不足" message:@"金币不足，无法购买联系方式" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去充值", nil];
                                                alertView.tag = 1002;
                                                [alertView show];
                                            }

                                            
                                        }
                                        
                                    } else {
                                        [MBProgressHUD hideHUD];
                                        [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"errorMsg"]]];
                                    }
                                }
                             andFailure:^(id failureResponse) {
                                 [MBProgressHUD hideHUD];
                                 [MBProgressHUD showError:@"服务器繁忙,请重试"];
                             }];
    
}


//获取联系方式
-(void)contactClick{
    
    
    blurView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    blurView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    [self.view addSubview:blurView];
    
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 110, SCREEN_WIDTH, 220)];
    view.userInteractionEnabled = YES;
    [blurView addSubview:view];
    view.backgroundColor = [UIColor colorWithHexString:@"#ffffff"];
    view.layer.borderWidth =1;
    view.layer.cornerRadius = 2;
    view.layer.borderColor = [UIColor colorWithHexString:@"#ffffff"].CGColor;
    view.layer.masksToBounds = YES;
    
    for (int i = 0; i < contactTitleArr.count; i++) {
        UILabel *titlelabel = [[UILabel alloc]initWithFrame:CGRectMake(24, 60*i, 60, 60)];
        titlelabel.text =[NSString stringWithFormat:@"%@:",contactTitleArr[i]] ;
        titlelabel.textColor = [UIColor colorWithHexString:@"#424242"];
        titlelabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:16];
        [view addSubview:titlelabel];
    }
    for (int i = 0; i < contactTitleArr.count; i++) {
        UILabel *contactLabel = [[UILabel alloc]init];
        contactLabel.frame = CGRectMake(90, 60*i, SCREEN_WIDTH-114, 60);
        contactLabel.text = contactArr[i];
        contactLabel.textColor = [UIColor colorWithHexString:@"#757575"];
        contactLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
        [view addSubview:contactLabel];
        
    }
    
    
    
    //关闭
    UIButton *btn = [[UIButton alloc]init];
    btn.frame = CGRectMake(SCREEN_WIDTH-72, 180, 48, 32);
    [btn setTitle:@"关闭" forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [btn setTitleColor:[UIColor colorWithHexString:@"#424242"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(closeClick) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btn];
    
    
}
-(void)closeClick{
    [blurView removeFromSuperview];
}

-(void)buyContactQuanxian{
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/order/updateOrderGold", REQUESTHEADER] andParameter:@{
                                                                                                                                     @"userId": [CommonTool getUserID],@"otherUserId": self.userId,@"usedType": @"record",@"buyType": @"1",@"goldPrice": @"300",@"userCaptcha":[CommonTool getUserCaptcha]}
                                success:^(id successResponse) {
                                    MLOG(@"金币购买权限结果:%@", successResponse);
                                    if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
                                        [MBProgressHUD showSuccess:@"恭喜解锁"];
                                        goldsNum = goldsNum-300;
                                        [self contactClick];
                                        
                                    } else {
                                        [MBProgressHUD hideHUD];
                                        [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"errorMsg"]]];
                                    }
                                }
                             andFailure:^(id failureResponse) {
                                 [MBProgressHUD hideHUD];
                                 [MBProgressHUD showError:@"服务器繁忙,请重试"];
                             }];
    
    
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    rightView.hidden = YES;
}



//设置滑动的判定范围
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (self.historyY+20<targetContentOffset->y)
    {
        
        [UIView animateWithDuration:0.2 animations:^{
            bottoView.frame = CGRectMake(0, SCREEN_HEIGHT-64, SCREEN_WIDTH, 0);
            infoTable.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64);
        }];
    }
    else if(self.historyY-20>targetContentOffset->y)
    {
        [UIView animateWithDuration:0.2 animations:^{
            bottoView.frame = CGRectMake(0, SCREEN_HEIGHT-84-64, SCREEN_WIDTH, 84);
            infoTable.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64-84);
        }];
        
    }
    
    
    self.historyY=targetContentOffset->y;
    
   
}



- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    CGFloat height = scrollView.frame.size.height;
    CGFloat contentOffsetY = scrollView.contentOffset.y;
    CGFloat bottomOffset = scrollView.contentSize.height - contentOffsetY;
    if (bottomOffset <= height)
    {
        //在最底部
        //        infoTable.frame = CGRectMake(0, -84, SCREEN_WIDTH, SCREEN_HEIGHT-64);
        [UIView animateWithDuration:0.2 animations:^{
            
            bottoView.frame = CGRectMake(0, SCREEN_HEIGHT-84-64, SCREEN_WIDTH, 84);
            infoTable.frame = CGRectMake(0, -84, SCREEN_WIDTH, SCREEN_HEIGHT-64);
            
        }];
        
    }
    else
    {
                [UIView animateWithDuration:0.2 animations:^{
        
                    bottoView.frame = CGRectMake(0, SCREEN_HEIGHT-84-64, SCREEN_WIDTH, 84);
                    infoTable.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64-84);
                    
                }];
        
    }

}
#pragma mark   -------配置导航栏
- (void)setNav{
    if ([CommonTool dx_isNullOrNilWithObject:self.userNickName]) {
//         self.title = [NSString stringWithFormat:@"%@的主页",infoModel.nickName];
    }else{
        self.title = [NSString stringWithFormat:@"%@的主页",self.userNickName];}
     self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    //导航栏title的颜色
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithHexString:@"#424242"],UITextAttributeTextColor, [UIFont fontWithName:@"PingFangSC-Medium" size:18],UITextAttributeFont, nil]];
    
    //导航栏返回按钮
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(16, 38, 28, 14)];
    [button setTitleColor:[UIColor colorWithHexString:@"#424242"] forState:UIControlStateNormal];
    [button setTitle:@"返回" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [button addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = back;
    if ([[CommonTool getUserID] isEqualToString:[NSString stringWithFormat:@"%@",self.userId]]) {
        
    }else{
    //导航栏   举报 拉黑 按钮
    UIButton *edit = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-16-28, 38, 18, 28)];
    [edit setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
    [edit addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *edited = [[UIBarButtonItem alloc]initWithCustomView:edit];
    self.navigationItem.rightBarButtonItem = edited;
        [self creatLaheiJubaoView];}
}
#pragma mark   -------举报拉黑view
-(void)creatLaheiJubaoView{
    rightView = [[UIView alloc]init];
    rightView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width-98, 8, 88, 112);
    rightView.hidden = YES;
    rightView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:rightView];
    
    UIImageView *image = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 88, 112)];
        image.image = [UIImage imageNamed:@"举报背景"];
    
    image.userInteractionEnabled = YES;
    [rightView addSubview:image];
    
//    NSArray *title = @[@"举报",@"拉黑"];
   UIButton* reportBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    reportBtn.frame  =CGRectMake(0, 8, 88, 48);
    [reportBtn setTitle:@"举报" forState:UIControlStateNormal];
    reportBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [reportBtn setTitleColor:[UIColor colorWithHexString:@"#424242"] forState:UIControlStateNormal];
//    action.tag = 1000+i;
    [reportBtn addTarget:self action:@selector(reportAction) forControlEvents:UIControlEventTouchUpInside];
    [image addSubview:reportBtn];
    
        action = [UIButton buttonWithType:UIButtonTypeCustom];
        action.frame  =CGRectMake(0, 8+48, 88, 48);
        [action setTitle:actionStr forState:UIControlStateNormal];
        action.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        [action setTitleColor:[UIColor colorWithHexString:@"#424242"] forState:UIControlStateNormal];
//        action.tag = 1000+i;
        [action addTarget:self action:@selector(moreAction) forControlEvents:UIControlEventTouchUpInside];
        [image addSubview:action];
        
    

}
- (void)goBack{
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)save{
//    jubaoLaheiNum ++;
//    if ( jubaoLaheiNum%2 ==1 ) {
//         rightView.hidden = NO;
//    }else{
//         rightView.hidden = YES;
//    }
    if (rightView.hidden== YES) {
        rightView.hidden= NO;
    }else{
        rightView.hidden= YES;
    }
  //  rightView.hidden = !rightView.hidden;
}
-(void)reportAction{
    //举报
    reportVC *report = [[reportVC alloc]init];
    report.otherUserId = self.userId;
    [self.navigationController pushViewController:report animated:YES];
}
- (void)moreAction{
    
 
    if ([actionStr isEqualToString:@"拉黑"]) {
        //拉黑
        //     [sender.superview  removeFromSuperview];
        
        blurView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        blurView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
        [self.view addSubview:blurView];
        
        UIView *image = [[UIView alloc]init];
        image.translatesAutoresizingMaskIntoConstraints = NO;
        image.backgroundColor = [UIColor whiteColor];
        image.userInteractionEnabled = YES;
        [blurView addSubview:image];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[image]-20-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(image)]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-140-[image(==160)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(image)]];
        
        UILabel *sureLabel = [[UILabel alloc]initWithFrame:CGRectMake(24, 24, 96, 16)];
        sureLabel.text = @"确定拉黑吗";
        sureLabel.textColor = [UIColor colorWithHexString:@"424242"];
        sureLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:16];
        [image addSubview:sureLabel];
        
        UILabel *aletLabel = [[UILabel alloc]init];
        aletLabel.translatesAutoresizingMaskIntoConstraints = NO;
        aletLabel.text = @"拉黑后无法互相发送消息，对方将无法查看您的主页，直到您取消拉黑";
        aletLabel.numberOfLines = 0;
        aletLabel.textColor = [UIColor colorWithHexString:@"#757575"];
        aletLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
        [image addSubview:aletLabel];
        [image addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-24-[aletLabel]-24-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(aletLabel)]];
        [image addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-56-[aletLabel(==40)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(aletLabel)]];
        
        
        //取消  确定  按钮
        UIButton *cancel = [[UIButton alloc]init];
        cancel.translatesAutoresizingMaskIntoConstraints = NO;
        [cancel setTitle:@"取消" forState:UIControlStateNormal];
        [cancel setTitleColor:[UIColor colorWithHexString:@"#424242"] forState:UIControlStateNormal];
        cancel.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        [cancel addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
        [image addSubview:cancel];
        [image addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[cancel(==48)]-64-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(cancel)]];
        [image addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-120-[cancel(==32)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(cancel)]];
        
        
        UIButton *sure = [[UIButton alloc]init];
        sure.translatesAutoresizingMaskIntoConstraints = NO;
        [sure setTitle:@"确定" forState:UIControlStateNormal];
        [sure setTitleColor:[UIColor colorWithHexString:@"#ff5252"] forState:UIControlStateNormal];
        sure.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        [sure addTarget:self action:@selector(sure:) forControlEvents:UIControlEventTouchUpInside];
        [image addSubview:sure];
        [image addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[sure(==48)]-8-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(sure)]];
        [image addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-120-[sure(==32)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(sure)]];
        

    }else{
        //取消拉黑
        
        NSString *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userId"];
        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/circle/deleteBlacklist",REQUESTHEADER] andParameter:@{@"userId":userId,@"otherUserId":self.userId} success:^(id successResponse) {
            if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
                [MBProgressHUD showSuccess:@"已取消拉黑"];
               
                [blurView removeFromSuperview];
                rightView.hidden = YES;
                actionStr = @"拉黑";
                [action setTitle:actionStr forState:UIControlStateNormal];
            }
            
            
        } andFailure:^(id failureResponse) {
            
        }];

    }
    
    
     
       
        
   
}


#pragma mark   --确定拉黑

- (void)sure:(UIButton *)sender{
    
      NSString *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userId"];
     [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/circle/addBlacklist",REQUESTHEADER] andParameter:@{@"userId":userId,@"otherUserId":self.userId} success:^(id successResponse) {
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
              [MBProgressHUD showSuccess:@"拉黑成功"];
            [sender.superview removeFromSuperview];
            [blurView removeFromSuperview];
            rightView.hidden = YES;
            actionStr = @"取消拉黑";
            [action setTitle:actionStr forState:UIControlStateNormal];
            [self.navigationController popViewControllerAnimated:YES];
        }
      
        
       } andFailure:^(id failureResponse) {
        
    }];
    
}

#pragma mark  ---取消拉黑
- (void)cancel:(UIButton *)sender{
    [blurView removeFromSuperview];
    [sender.superview removeFromSuperview];
    
    rightView.hidden = YES;
}

//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
// 
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}


@end
