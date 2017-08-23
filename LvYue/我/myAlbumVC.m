//
//  myAlbumVC.m
//  LvYue
//  Created by X@Han on 16/12/28.
//  Copyright © 2016年 OLFT. All rights reserved.


#import "myAlbumVC.h"
#import "LYEssenceImageUploadViewController.h"
#import "LYHttpPoster.h"
#import "MBProgressHUD+NJ.h"
#import "MyDispositionCollectionViewCell.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "OriginalViewController.h"
#import "AlbumCollectionViewCell.h"
#import "AlbumModel.h"
@interface myAlbumVC ()<UICollectionViewDataSource,UICollectionViewDelegate,UIAlertViewDelegate>{
    NSMutableArray *dataArr;   //总共相片数组
    NSMutableArray *dataModelArr;   //总共相片数组
   
    NSMutableArray *smallArr;   //小图
    
    NSInteger selectIndex;//选中的cell所以
    NSMutableArray* scroArr;//滑动为了不显示我的相册数组第一个的图片
    BOOL isBuyed;
    
    NSInteger goldsNum;
    NSInteger  userKeyNum;
}
@property (nonatomic, copy) NSString *accountAmount; // 账户余额

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation myAlbumVC

- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO];
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
   
    [self setNav];
    isBuyed =NO;
    scroArr = [[NSMutableArray alloc]init];
    if ([self.gotoVCIdentifier isEqualToString:@"LYMeViewController"]) {
        dataArr  = [[NSMutableArray alloc] initWithObjects:@{@"photoUrl":@"button"}, nil];
        AlbumModel *model = [AlbumModel createWithModelDic:@{@"photoUrl":@"button"}];
        dataModelArr = [[NSMutableArray alloc] initWithObjects:model, nil];
        
        
    
    }
    if ([self.gotoVCIdentifier isEqualToString:@"otherZhuYeVC"]) {
         dataArr  = [[NSMutableArray alloc] init];
        dataModelArr  = [[NSMutableArray alloc] init];
    }
    smallArr = [[NSMutableArray alloc] init];
    [self setContent];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reload:) name:@"reloadMyAlbum" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload2:) name:@"reloadDisposition" object:nil];
//
      [self getData];
    [self getCoinNum];
  
    
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

//#pragma mark - Pravite
//
//- (void)p_loadAccountAmount {
//    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/getUserPower", REQUESTHEADER]
//                           andParameter:@{
//                                          @"userId": [CommonTool getUserID]
//                                          }
//                                success:^(id successResponse) {
//                                    MLOG(@"结果:%@", successResponse);
//                                    if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
//                                        self.accountAmount = [NSString stringWithFormat:@"%@", successResponse[@"data"][@"userGold"]];
//                                        
//                                    } else {
//                                        [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"msg"]]];
//                                    }
//                                }
//                             andFailure:^(id failureResponse) {
//                                 [MBProgressHUD showError:@"查询余额失败，请重试"];
//                             }];
//}

- (void)reload:(NSNotification *)noti{
    
     [self getData];

    
    
}
- (void)reload2:(NSNotification *)noti{
    [MBProgressHUD  showSuccess:@"审核通过后，即可展示出来哦"];
    [self getData];
    
    
    
}
-(void)removiewAllSubviews{
    for (UIView *view  in self.view.subviews) {
        [view removeFromSuperview];
    }
}
- (void)setContent{
    
    [self removiewAllSubviews];
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize                    = CGSizeMake((SCREEN_WIDTH -20)/ 3 , (SCREEN_WIDTH -20)/ 3);
    flowLayout.sectionInset                = UIEdgeInsetsMake(5, 5, 5, 5);
    flowLayout.minimumInteritemSpacing     = 5;
    flowLayout.minimumLineSpacing          = 5;
    if(!_collectionView){
        _collectionView                      = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64.f) collectionViewLayout:flowLayout];
        _collectionView.delegate             = self;
        _collectionView.dataSource           = self;
        _collectionView.backgroundColor      = [UIColor clearColor];
        _collectionView.alwaysBounceVertical = YES;
    }
    
    [self.view addSubview:_collectionView];
    
//    [_collectionView registerNib:[UINib nibWithNibName:@"MyDispositionCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"photoCell"];
    [_collectionView registerClass:[AlbumCollectionViewCell class] forCellWithReuseIdentifier:@"photoCell"];
}


#pragma mark - 获得相册数据
- (void)getData {

    
  NSString *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userId"];
    if ([userId isEqualToString:self.userId]) {
        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/getUserPhoto", REQUESTHEADER]
                               andParameter:@{@"userId":[NSString stringWithFormat:@"%@",self.userId]}  success:^(id successResponse) {
                                   
                                   NSLog(@"照片000000000%@",successResponse);
                                   
                                   if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
                                  
                                       [dataArr removeAllObjects];
                                       [dataModelArr removeAllObjects];
                                       [dataArr addObject:@{@"photoUrl":@"button"}];
                                       AlbumModel *model1 = [[AlbumModel alloc]init];
//                                       AlbumModel *model = [AlbumModel createWithModelDic:@{@"photoUrl":@"button"}];
                                       dataModelArr = [[NSMutableArray alloc] initWithObjects:model1, nil];
                                      
                                       scroArr = successResponse[@"data"];
                                       [dataArr addObjectsFromArray:scroArr];
                                       //这里便利的是dataarr
                                       for (NSDictionary *dic in scroArr) {
                                           AlbumModel *model = [AlbumModel createWithModelDic:dic];
                                           [dataModelArr addObject:model];
                                           
                                       }
                                       
                                       
                                       [self.collectionView reloadData];
                                       //        }
                                       
                                   } else {
                                       [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"errorMsg"]]];
                                   }
                               }
                                 andFailure:^(id failureResponse) {
                                     [MBProgressHUD showError:@"服务器繁忙,请重试"];
                                 }];

    }else{
        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/getUserPhoto", REQUESTHEADER]
                               andParameter:@{@"userId":[CommonTool getUserID],@"otherUserId":[NSString stringWithFormat:@"%@",self.userId]}  success:^(id successResponse) {
                                   
                                   NSLog(@"照片000000000%@",successResponse);
                                   
                                   if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
                                       [dataArr removeAllObjects];
                                           [dataModelArr removeAllObjects];
                                      
                                       scroArr = successResponse[@"data"];
                                       [dataArr addObjectsFromArray:scroArr];
                                       
                                       for (NSDictionary *dic in dataArr) {
                                           AlbumModel *model = [AlbumModel createWithModelDic:dic];
                                           [dataModelArr addObject:model];
                                       }
                                       
                                       
                                       [self.collectionView reloadData];
                                       //        }
                                       
                                   } else {
                                       [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"errorMsg"]]];
                                   }
                               }
                                 andFailure:^(id failureResponse) {
                                     [MBProgressHUD showError:@"服务器繁忙,请重试"];
                                 }];

    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
        return dataArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID               = @"photoCell";
    AlbumCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];

//    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%d%d", [indexPath section], [indexPath row]];//以indexPath来唯一确定cell
//    AlbumCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];

   
    if (dataModelArr && dataModelArr.count>0) {
        AlbumModel *model = dataModelArr[indexPath.row];
        
        [cell creatModel:model  userId:self.userId];
        if ([[NSString stringWithFormat:@"%@",self.userId] isEqualToString:[CommonTool getUserID]] && indexPath.row == 0) {
            
            cell.imageViewM.image = [UIImage imageNamed:@"button"];
            
            
            
        }
    }
    
  
    
//    NSURL *url                            = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", IMAGEHEADER, dic[@"photoUrl"]]];
//    [cell.imageViewM sd_setImageWithURL:url];
//    if ([self.gotoVCIdentifier isEqualToString:@"LYMeViewController"]) {
//        if (  indexPath.row == 0) {
//            cell.imageViewM.image = [UIImage imageNamed:dataArr[0][@"photoUrl"]];
//
//        }
//          }
//    else{
//        if ([dic[@"photoPrice"] doubleValue]> 0 && [dic[@"isLook"] integerValue] == 0) {
//            //高斯模糊
//            UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
//            UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
////            effectView.alpha = 0.9;
//            effectView.frame = CGRectMake(0, 0, SCREEN_WIDTH / 3 - 7, SCREEN_WIDTH / 3 - 7);
//            [cell.imageViewM addSubview:effectView];
//        }
//       
//
//    }
//    [cell.imageViewM sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"PlaceImage"] options:SDWebImageRetryFailed];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  
    selectIndex = indexPath.row;
    if ([self.gotoVCIdentifier isEqualToString:@"LYMeViewController"]) {
        if (indexPath.row == 0 ) {
            LYEssenceImageUploadViewController *vc = [LYEssenceImageUploadViewController new];
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            selectIndex = selectIndex-1;
           [self lookBigImage];
         
        }

        
    }else{
        AlbumModel *model                   = dataModelArr[indexPath.item];
        if ([model.photoPrice doubleValue]> 0 && [model.isLook integerValue] == 0) {
            
            if (userKeyNum > 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"确定消耗一枚钥匙查看%@的私照吗？",self.userNike] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                alert.tag = 1000;
                [alert show];
            }else{
                if (goldsNum  >= 100) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"确定花费%@金币查看%@的私照吗？", model.photoPrice,self.userNike] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                    alert.tag = 1001;
                                [alert show];
                }else{
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"充值金币" message:[NSString stringWithFormat:@"金币不足，需花费%@金币查看%@的私照", model.photoPrice,self.userNike] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去充值", nil];
                    alertView.tag = 1002;
                    [alertView show];
                }
            }
        


          
//              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"确定花费%@金币查看%@的私照吗？", dataArr[selectIndex][@"photoPrice"],self.userNike] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//            [alert show];


        }else{
            [self lookBigImage];}
    }
}
//-(void)isBuyed{
//    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/order/getOrderRecord", REQUESTHEADER]
//                           andParameter:@{@"userId":[CommonTool getUserID],@"otherUserId":self.userId,@"buyType":@"3",@"remarkInfo":[NSString stringWithFormat:@"%@",dataArr[selectIndex][@"photoUrl"]]}  success:^(id successResponse) {
//                               
//                               NSLog(@"000000000%@",successResponse);
//                               
//                               if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
//                                   NSArray *arr = successResponse[@"data"];
//                                   if (arr && arr.count > 0) {
//                                       [self lookBigImage];
//                                       isBuyed = YES;
//                                   }else{
//                                                   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"确定花费%@金币查看%@的私照吗？", dataArr[selectIndex][@"photoPrice"],self.userNike] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//                                       
//                                                   [alert show];
//                                   }
//                               } else {
//                                   [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"errorMsg"]]];
//                               }
//                           }
//                             andFailure:^(id failureResponse) {
//                                 [MBProgressHUD showError:@"服务器繁忙,请重试"];
//                             }];
//
//
//
//}
-(void)lookBigImage{
    [smallArr removeAllObjects];
    for (int i = 0; i < scroArr.count; i++) {
        MyDispositionCollectionViewCell *cell = (MyDispositionCollectionViewCell *) [_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
        UIImage *image                        = cell.imageViewM.image;
        if (image) {
            [smallArr addObject:image];
        }
    }
    
  
    OriginalViewController *oVC = [[OriginalViewController alloc] init];

    oVC.imageData               = scroArr;
    oVC.smallImage              = smallArr;
    

    oVC.userId = self.userId;
    [oVC showImageWithIndex:selectIndex andCount:scroArr.count];
}
#pragma mark uiactionsheet 代理
#pragma mark - UIAlertViewDelegate
//
//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex NS_DEPRECATED_IOS(2_0, 9_0) {
//    
////    switch (buttonIndex) {
////        case 1:
////            [self lookPhoto];
////            break;
////            
////        default:
////            break;
////    }
//}
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    WS(weakSelf)
   

    //花费钥匙购买性
    if (alertView.tag == 1000) {
        if (1 == buttonIndex) {
            
            NSDictionary *dic =    @{@"userId": [CommonTool getUserID],@"otherUserId": self.userId,@"buyType": @"3",@"keyNumber": @"1",@"remarkInfo":[NSString stringWithFormat:@"%@",dataArr[selectIndex][@"photoUrl"]]};
            [LYHttpPoster requestSpendUserKeyWithParameters:dic Block:^(NSString *codeStr) {
                if ([[NSString stringWithFormat:@"%@",codeStr] isEqualToString:@"200"])  {
                    userKeyNum = userKeyNum-1;
                    AlbumModel *model = dataModelArr[selectIndex];
                    model.isLook = @"1";
                    [self getData];
                  
                }
            }];
        }
    }
    //花费金币购买性
    if (alertView.tag == 1001) {
        if (1 == buttonIndex) {
            [self lookPhoto];        }
    }
    
    if (alertView.tag == 1002) {
        if (1 == buttonIndex) {
            MyMoneyVC *myMoney = [[MyMoneyVC alloc] init];
            [weakSelf.navigationController pushViewController:myMoney animated:YES];
        }
    }
}

-(void)lookPhoto{
    NSDictionary *dic= @{
                         @"userId": [CommonTool getUserID],
                         @"otherUserId": self.userId,
                         @"usedType":@"record",
                         @"buyType": @"3",
                         @"remarkInfo":[NSString stringWithFormat:@"%@",dataArr[selectIndex][@"photoUrl"]],
                         @"goldPrice":[NSString stringWithFormat:@"%@",dataArr[selectIndex][@"photoPrice"]],
                         @"userCaptcha":[CommonTool getUserCaptcha]
                         } ;
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/order/updateOrderGold", REQUESTHEADER]
                           andParameter:dic
                                success:^(id successResponse) {
                                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                                    if ([successResponse[@"code"] integerValue] == 200) {
                                        [MBProgressHUD showSuccess:@"查看成功"];
//                                        [self.navigationController popViewControllerAnimated:YES];
                                        
//                                        isBuyed = YES;
                                        AlbumModel *model = dataModelArr[selectIndex];
                                        model.isLook = @"1";
                                        [self getData];
                                        goldsNum = goldsNum - [model.photoPrice integerValue];
                                        [_collectionView reloadData];
//
                                        
                                    } else {
                                        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                                        hud.mode =MBProgressHUDModeText;//显示的模式
                                        hud.labelText =[NSString stringWithFormat:@"%@", successResponse[@"errorMsg"]];
                                        hud.removeFromSuperViewOnHide =YES;
                                    
                                    }
                                }
                             andFailure:^(id failureResponse) {
                                 [MBProgressHUD hideHUDForView:self.view animated:YES];
                                
                                 [MBProgressHUD showError:@"照片查看失败，请重试"];
                             }];

}
- (void)setNav{
   
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithHexString:@"#424242"],UITextAttributeTextColor, [UIFont fontWithName:@"PingFangSC-Medium" size:18],UITextAttributeFont, nil]];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:@"#ffffff"];
    //导航栏返回按钮
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(16, 38, 28, 14)];
    [button setTitleColor:[UIColor colorWithHexString:@"#424242"] forState:UIControlStateNormal];
    [button setTitle:@"返回" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [button addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = back;
    
    
     if ([self.gotoVCIdentifier isEqualToString:@"LYMeViewController"]) {
          self.title = @"我的相册";
//    //导航栏充值记录按钮
//    UIButton *edit = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-16-28, 38, 56, 14)];
//    [edit setTitleColor:[UIColor colorWithHexString:@"#ff5252"] forState:UIControlStateNormal];
//   
//        [edit setTitle:@"上传照片" forState:UIControlStateNormal];
//    
//    
//    edit.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
//    [edit addTarget:self action:@selector(uploadPhoto) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *edited = [[UIBarButtonItem alloc]initWithCustomView:edit];
//    self.navigationItem.rightBarButtonItem = edited;
     }
    if ([self.gotoVCIdentifier isEqualToString:@"otherZhuYeVC"]) {
        self.title = [NSString stringWithFormat:@"%@的相册",self.userNike];
    }
    
}

- (void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
}

//#pragma mark   -- 上传照片
//- (void)uploadPhoto{
//    
//    
//    
//    
//}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
