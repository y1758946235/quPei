
#import "FriendsCirleViewController.h"
#import "UserChiCell.h"
#import "LYHttpPoster.h"
#import "UserModel.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "MJRefresh.h"
#import "MBProgressHUD+NJ.h"
#import "selectVC.h"
#import "otherZhuYeVC.h"
#import "AlterView.h"
#import "SendVideoViewController.h"
#import "MyInfoVC.h"
#import "VideoKnowViewController.h"

@interface FriendsCirleViewController ()<UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>{
    UICollectionView *cView;
    NSInteger currentPage;  //当前页数
//    NSInteger page1;
    CGFloat width ;
    BOOL isNew;
    BOOL isFirst;
    NSString * firUserId ;
    
    UIView *blurView;
}
    
@property(nonatomic,copy)NSMutableArray *dataArr;
@property (nonatomic, strong) AlterView *alterView ;
@property (nonatomic,retain) NSMutableArray  *userPushDataArr;
@property(nonatomic,copy)NSString *videoUrl;
@property(nonatomic,copy)NSString * otherId;
@end

@implementation FriendsCirleViewController

- (NSMutableArray *)userPushDataArr {
    if (!_userPushDataArr) {
        _userPushDataArr = [[NSMutableArray alloc] init];
    }
    return _userPushDataArr;
}
-(AlterView *)alterView {
    if (!_alterView) {
        _alterView  = [[AlterView alloc]init];
        _alterView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        _alterView.backgroundColor = RGBA(1, 1, 1, 0.1);
    }
    return _alterView;
}
- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [[NSMutableArray alloc]init];
    }
    
    return _dataArr;
}

- (void)viewWillAppear:(BOOL)animated{
    currentPage = 1;
//    page1 = 1;
    [super viewWillAppear:animated];
//    cView.delegate = self;
//    cView.dataSource = self;
}
//-(void)viewDidDisappear:(BOOL)animated{
//    cView.delegate = nil;
//    cView.dataSource = nil;
//    
//}
- (void)viewDidLoad{
    
    [super viewDidLoad];
    [self isNewUser];
    width = (SCREEN_WIDTH-24)/2;
    
    [self setNav];
    [self setCollectionView];
    
    currentPage = 1;
    
    NSDictionary * dic = @{@"userId":[CommonTool getUserID],@"pageNum":[NSString stringWithFormat:@"%ld",(long)currentPage]};
    [self  getFriendsDataNsdic:dic];
    [self addRefresh];
    
    UIViewController *vc = kAppDelegate.rootTabC.viewControllers[3];
    [vc.tabBarController.tabBar hideBadgeOnItemIndex:3];
}
-(void)isNewUser{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *Str = [NSString stringWithFormat:@"%@",[defaults objectForKey:@"alterViewtypeUser"]];
    if ([Str isEqualToString:@"0"]) {
          [self  getUserPushDataUseSex:[CommonTool getUserSex]];
    }
   
}
//获取数据
-(void)getUserPushDataUseSex:(NSString *)userSex{
    WS(weakSelf)
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userLatitude = [defaults objectForKey:@"latitude"];
    NSString *userLongitude = [defaults objectForKey:@"longitude"];
    NSDictionary * dic = @{@"pushType":@"0",@"userSex":userSex,@"userLatitude":[NSString stringWithFormat:@"%@",userLatitude],@"userLongitude":[NSString stringWithFormat:@"%@",userLongitude]};
    [LYHttpPoster requestUserpPushDataWithParameters:dic Block:^(NSMutableArray *arr) {
        if (arr == nil) {
            return ;
        }else{
            NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
            [user setObject:@"" forKey:@"alterViewtypeUser"];
            [weakSelf.userPushDataArr addObjectsFromArray:arr];
            [weakSelf creatAlterView];
            
        }
    }];
    
}
-(void)creatAlterView{
    
    
    [self.alterView removeFromSuperview];
    //    [self.view addSubview:self.alterView];
    [[UIApplication sharedApplication].keyWindow addSubview:self.alterView];
    [self.alterView creatDataArr: self.userPushDataArr];
}
- (void)setCollectionView{
    UICollectionViewFlowLayout *layOut = [[UICollectionViewFlowLayout alloc]init];
    layOut.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    cView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64-49) collectionViewLayout:layOut];
    cView.backgroundColor = [UIColor colorWithHexString:@"#ffffff"];
    [cView registerClass:[UserChiCell class] forCellWithReuseIdentifier:@"cell"];
    cView.dataSource = self;
    cView.delegate = self;
    /** 去除tableview 右侧滚动条 */
    cView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:cView];
    
    
    
}



#pragma mark   -----加载更多的数据
- (void)addRefresh{
    
    self.userSex = @"";
    self.beginUserAge = @"";
    self.endUserAge  = @"";
    firUserId = @"";
    
    
    //下拉刷新
    cView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefreshing)];
    
    
//    //上拉加载更多
//    
//    cView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRefreshing)];
    
}



#pragma mark   ----下拉刷新
- (void)headerRefreshing{
    
//    if (isNew) {
//        currentPage = 1;
//    }else{
//        page1 =1 ;
//    }
    
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.requestSerializer.timeoutInterval = 20.0f;
//    [manager POST:[NSString stringWithFormat:@"%@/mobile/pool/getUserPool",REQUESTHEADER] parameters:@{@"pageNum":@"1"} success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
//       NSLog(@"666666666666666666用户池:%@",responseObject);
//        
//      
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"%@",error.localizedDescription);
//       
//        
//    }];
    
    
    
    MJRefreshStateHeader *header = (MJRefreshStateHeader *) cView.mj_header;
    [header setTitle:@"下拉可以刷新" forState:MJRefreshStateIdle];
    [header setTitle:@"松开马上刷新" forState:MJRefreshStatePulling];
    [header setTitle:@"刷新中" forState:MJRefreshStateRefreshing];
    
  
    currentPage = 1;
   
     NSDictionary * dic = @{@"userId":[CommonTool getUserID],@"pageNum":[NSString stringWithFormat:@"%ld",(long)currentPage],@"userSex":self.userSex,@"userAgeBegin":self.beginUserAge,@"userAgeEnd":self.endUserAge};
    [self getFriendsDataNsdic:dic];
    
      [cView.mj_header endRefreshing];
}

//获取数据
-(void)getFriendsDataNsdic:(NSDictionary*)Dic{
   
    [LYHttpPoster requestUserChiWithParameters:Dic Block:^(NSMutableArray *arr) {
        if (arr == nil) {
            return ;
        }else{
        [self.dataArr removeAllObjects];
        [self.dataArr addObjectsFromArray:arr];
        [cView reloadData];
        }
    }];
    
}
#pragma mark   ----上拉加载更多
- (void)footerRefreshing{
    
    
    //分页信息
//    if (type == UserLoginStateTypeWaitToLogin) {
//        NSInteger page = 1;
//        if (isNew) {
//            currentPage++;
//            page = currentPage;
//        } else {
//           page1++;
//            page = page1;
//        }
    currentPage ++;
  
    if (self.dataArr.count != 0) {
        UserModel *model = self.dataArr[0];
        firUserId = model.userId;
    }
    
   
    NSDictionary * dic = @{@"pageNum":[NSString stringWithFormat:@"%ld",(long)currentPage],@"userIdFirst":firUserId,@"userSex":self.userSex,@"userAgeBegin":self.beginUserAge,@"userAgeEnd":self.endUserAge};
    [self getMoreFriendsDataNsdic:dic];
      [cView.mj_footer endRefreshing];
    
}
//获上啦加载数据
-(void)getMoreFriendsDataNsdic:(NSDictionary*)Dic{
 
    [LYHttpPoster requestUserChiWithParameters:Dic Block:^(NSMutableArray *arr) {
        
        if (arr == nil) {
            currentPage --;
            return ;
        }else{
        [self.dataArr addObjectsFromArray:arr];
        if (arr.count == 0) {
            currentPage --;
            [MBProgressHUD showSuccess:@"已经到底啦"];
        }
            [cView reloadData];
        }
    }];
    
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return self.dataArr.count;
    
}

#pragma mark   -----item的纵向间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    
    return 8.0f;
    
    
}


#pragma mark   ----item的横向间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    
      return 8.0f;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UserChiCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
 
    UserModel *aModel = self.dataArr[indexPath.row];
    [cell creatModel:aModel];
//    
//    NSURL *headUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,aModel.dateImage]];
//    
//    [cell.photoImage sd_setImageWithURL:headUrl];
//  
    cell.affVideoBtn.tag = 1000+indexPath.row;
    if ([aModel.isAffirm integerValue] == 2) {
        cell.affVideoBtn.hidden = NO;
       
        
        [cell.affVideoBtn addTarget:self action:@selector(getPersonalVideoAffirm:) forControlEvents:UIControlEventTouchUpInside];

    }else{
         cell.affVideoBtn.hidden = YES;
       
    }
//
//    if ([[NSString stringWithFormat:@"%@",aModel.sexStr] isEqualToString:@"1"]) {
//        cell.sexImage.image = [UIImage imageNamed:@"female"];
//    }
//    
//    if ([[NSString stringWithFormat:@"%@",aModel.sexStr] isEqualToString:@"0"]) {
//        cell.sexImage.image = [UIImage imageNamed:@"male"];
//    }
//   
//    cell.nickLabel.text = aModel.nick;
//    cell.ageLabel.text = [NSString stringWithFormat:@"%@岁",aModel.agel];
    
   
    return cell;
}


#pragma mark  --点头像进入个人主页
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
     UserModel *model = self.dataArr[indexPath.item];
    if ([[NSString stringWithFormat:@"%@",model.userId]  isEqualToString:[CommonTool getUserID]]) {
        MyInfoVC *inVC = [[MyInfoVC alloc]init];
        
        [self.navigationController pushViewController:inVC animated:YES];
    }else{
   
    otherZhuYeVC *other = [[otherZhuYeVC alloc]init];
    other.userId = model.userId;
     other.userNickName = model.nick;
        [self.navigationController pushViewController:other animated:YES];}
    
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
  
    
    return CGSizeMake(width, width);
    
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    return UIEdgeInsetsMake(8, 8, 0, 8);
    
}
#pragma mark   视频认证状态以及地址
-(void)getPersonalVideoAffirm:(UIButton *)sender{
    UserModel *model = self.dataArr[sender.tag-1000];
    self.otherId = model.userId;
    self.videoUrl =model.userVideo;
    WS(weakSelf)
    if ([[NSString stringWithFormat:@"%@",model.userId] isEqualToString:[CommonTool getUserID]]) {
        
        MPMoviePlayerViewController *player = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", IMAGEHEADER, weakSelf.videoUrl]]];
        player.moviePlayer.shouldAutoplay   = YES;
        [weakSelf presentMoviePlayerViewControllerAnimated:player];
    }else{
    
    [weakSelf  checkIsBuyQuanxian];

    }
}


#pragma mark 购买过权限
-(void)checkIsBuyQuanxian{
    
 
    WS(weakSelf)
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/order/getOrderRecord", REQUESTHEADER] andParameter:@{
                                                                                                                                    @"userId": [CommonTool getUserID],@"otherUserId": self.otherId,@"buyType": @"2" }
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
                                        
                                        //                                        [MBProgressHUD showError:@"查看次数已用完"];
                                        [weakSelf getMyVideoAffirm];
                                   
                                    }
                                }
                             andFailure:^(id failureResponse) {
                                 [MBProgressHUD hideHUD];
                                 [MBProgressHUD showError:@"服务器繁忙,请重试"];
                             }];
    
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    WS(weakSelf)
//    if (alertView.tag == 1000) {
//        if (1 == buttonIndex) {
//            [weakSelf userKeyBuyQuanxian];
//            
//            
//        }
//    }
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
}
//-(void)userKeyBuyQuanxian{
//    WS(weakSelf)
//    //服务器获取图片
//    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/order/updateOrderKey", REQUESTHEADER] andParameter:@{
//                                                                                                                                    @"userId": [CommonTool getUserID],@"otherUserId": self.otherId,@"buyType": @"2",@"keyNumber": @"1",@"remarkInfo": [NSString stringWithFormat:@"%@",self.videoUrl]}
//                                success:^(id successResponse) {
//                                    MLOG(@"钥匙购买权限结果:%@", successResponse);
//                                    if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
//                                        [MBProgressHUD showSuccess:@"解锁成功"];
//                                        MPMoviePlayerViewController *player = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", IMAGEHEADER, weakSelf.videoUrl]]];
//                                        player.moviePlayer.shouldAutoplay   = YES;
//                                        [weakSelf presentMoviePlayerViewControllerAnimated:player];
//                                       
//                                        
//                                    } else {
//                                        [MBProgressHUD hideHUD];
//                                        [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"errorMsg"]]];
//                                    }
//                                }
//                             andFailure:^(id failureResponse) {
//                                 [MBProgressHUD hideHUD];
//                                 [MBProgressHUD showError:@"服务器繁忙,请重试"];
//                             }];
//    
//}

-(void)goldsBuyQuanxian{
    
    WS(weakSelf)
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/order/updateOrderGold", REQUESTHEADER] andParameter:@{
                                                                                                                                     @"userId": [CommonTool getUserID],@"otherUserId": self.otherId,@"usedType": @"record",@"buyType": @"2",@"goldPrice": @"50",@"userCaptcha":[CommonTool getUserCaptcha]}
                                success:^(id successResponse) {
                                    MLOG(@"金币购买权限结果:%@", successResponse);
                                    if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
                                        [MBProgressHUD showSuccess:@"解锁成功"];
                                        MPMoviePlayerViewController *player = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", IMAGEHEADER, weakSelf.videoUrl]]];
                                        player.moviePlayer.shouldAutoplay   = YES;
                                        [weakSelf presentMoviePlayerViewControllerAnimated:player];
                                        
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

#pragma mark   查看自己视频认证状态以及地址
-(void)getMyVideoAffirm{
    WS(weakSelf)
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/getPersonalVideoAffirm", REQUESTHEADER] andParameter:@{
                                                                                                                                           @"userId": [CommonTool  getUserID]}
                                success:^(id successResponse) {
                                    MLOG(@"是否是视频认证结果:%@", successResponse);
                                    if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
                                        
                                        if ([[NSString stringWithFormat:@"%@", successResponse[@"data"][@"isAffirm"]] isEqualToString:@"2"] ) {
                                           
                                                 [weakSelf buyVideoQuanXianClick];
                                            
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
    [kKeyWindow addSubview:blurView];
    
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
    [blurView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[image]-20-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(image)]];
    [blurView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-140-[image(==160)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(image)]];
    
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
    
    [self  getCoinNum];
}

#pragma mark 获得账户金币判断钥匙数量
- (void)getCoinNum{
    
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/getUserPower",REQUESTHEADER] andParameter:@{@"userId":[CommonTool getUserID]} success:^(id successResponse) {
        //
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            //
            NSLog(@"myMoneysuccessResponse---%@",successResponse);
            NSDictionary *dataDic = successResponse[@"data"];
        NSInteger    goldsNum = [dataDic[@"userGold"] integerValue];
//        NSInteger    userKeyNum = [dataDic[@"userKey"] integerValue];
            
//            if (userKeyNum > 0) {
//                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"消耗1枚钥匙查看认证视频" message:@"温馨提示：免费查看次数已用完，购买过后即可永久查看" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//                alertView.tag = 1000;
//                [alertView show];
//            }else{
                if (goldsNum  >= 50) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"花费50金币查看认证视频" message:@"温馨提示：免费查看次数已用完，购买过后即可永久查看" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                    alertView.tag = 1001;
                    [alertView show];
                }else{
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"充值金币" message:@"免费查看次数已用完，金币不足，将无法查看认证视频" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去充值", nil];
                    alertView.tag = 1002;
                    [alertView show];
                }
//            }

            
        }else{
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
        }
        
    } andFailure:^(id failureResponse) {
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
        NSLog(@"失败:%@",failureResponse);
    }];
    //
    
    
}




- (void)setNav{
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:@"#ffffff"];
    
    
    //中间发布约会
    UILabel *yueLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 35)];
    yueLabel.text = @"在线";
    yueLabel.textAlignment = NSTextAlignmentCenter;
    yueLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:18];
    yueLabel.textColor = [UIColor colorWithHexString:@"424242"];
    self.navigationItem.titleView = yueLabel;
    
    //右上角筛选按钮
    UIButton *selectBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 25)];
    [selectBtn setImage:[UIImage imageNamed:@"filter"] forState:UIControlStateNormal];
    [selectBtn addTarget:self action:@selector(select) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:selectBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    
}



#pragma mark   ------- 筛选
- (void)select{
    selectVC *select = [[selectVC alloc]init];
    __weak __typeof(self)weakSelf = self;
    [select shaiXuanText:^(NSString *userSex, NSString *beginUserAge, NSString *endUserAge) {
        weakSelf.userSex = userSex;
        weakSelf.beginUserAge = beginUserAge;
        weakSelf.endUserAge = endUserAge;
        
        currentPage = 1;
        
        NSDictionary * dic = @{@"userId":[CommonTool getUserID],@"pageNum":[NSString stringWithFormat:@"%ld",(long)currentPage],@"userSex":weakSelf.userSex,@"userAgeBegin":weakSelf.beginUserAge,@"userAgeEnd":weakSelf.endUserAge};
        [self getFriendsDataNsdic:dic];
    }];
    [self.navigationController pushViewController:select animated:YES];

    
   
}













@end
