//
//  AlterSendGiftView.m
//  LvYue
//
//  Created by X@Han on 17/6/20.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "AlterSendGiftView.h"

#import "AlterSendGiftCollectionViewCell.h"
//#import "LYSendGiftCollectionViewCell.h"
#import "AlterSendGiftCollectionReusableView.h"
#import "LYSendGiftModel.h"
#import "YQCollectionViewFlowLayout.h"
typedef NS_ENUM(NSUInteger, LYSendGiftAlertType) {
    LYSendGiftAlertTypeAccountAmount = 1, // 余额不足
    LYSendGiftAlertTypeSendGift      = 2  // 送礼物
};
@interface AlterSendGiftView()<UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>{
   
    CGFloat cellWidth;
}

@property (nonatomic, strong) UICollectionViewFlowLayout *layout;
@property (nonatomic, strong) AlterSendGiftCollectionViewCell *selectedCell;
@property (nonatomic, strong) AlterSendGiftCollectionReusableView *headerView;
@property (nonatomic, copy) NSString *accountAmount; // 账户余额
@property (nonatomic, strong) NSMutableArray<LYSendGiftModel *> *giftInfoList;
@end
@implementation AlterSendGiftView

#pragma mark - Getter

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        
        YQCollectionViewFlowLayout *layOut = [[YQCollectionViewFlowLayout alloc]init];
        layOut.scrollDirection = UICollectionViewScrollDirectionVertical;
        layOut.navHeight = 0;
        _collectionView                 = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, ((SCREEN_WIDTH - 3.f) / 4.f)*3+3+40) collectionViewLayout:layOut];
//        _collectionView.backgroundColor = RGBCOLOR(213, 213, 213);
         _collectionView.backgroundColor = [UIColor  colorWithHexString:@"#ffffff"];
        _collectionView.delegate        = self;
        _collectionView.dataSource      = self;
        _collectionView.showsVerticalScrollIndicator = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
        [_collectionView registerClass:[AlterSendGiftCollectionViewCell class] forCellWithReuseIdentifier:@"AlterSendGiftCollectionViewCell"];
        [_collectionView registerClass:[AlterSendGiftCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"AlterSendGiftCollectionReusableView"];
    }
    return _collectionView;
}
- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor =[UIColor  cyanColor];
        [self addSubview:self.collectionView];
        
        
//        [self p_loadGift];
//        [self p_loadAccountAmount];
    }
    return self;
    
}
- (void)p_loadGift {
   
    
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/cache/getGift", REQUESTHEADER] andParameter:nil
                                success:^(id successResponse) {
                                   
                                    if ([successResponse[@"code"] integerValue] == 200) {
                                        
                                        self.giftInfoList = [[NSMutableArray alloc] init];
                                        [successResponse[@"data"] enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
                                            [self.giftInfoList addObject:[LYSendGiftModel initWithDic:obj]];
                                        }];
                                        [self.collectionView reloadData];
                                        
                                    } else {
                                        [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"errorMsg"]]];
                                    }
                                }
                             andFailure:^(id failureResponse) {
                                 
                                 [MBProgressHUD showError:@"加载礼物列表失败，请重试"];
                             }];
}



#pragma mark - UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.giftInfoList.count;
}
//-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
//    return 1+self.giftInfoList.count/8 ;
//}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AlterSendGiftCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AlterSendGiftCollectionViewCell" forIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor colorWithHexString:@"#ffffff"];
    [cell configData:self.giftInfoList[indexPath.row]];
    return cell;
}



- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    // 用户余额还在加载中
    if (!self.accountAmount || self.accountAmount.length == 0) {
        [MBProgressHUD showError:@"用户余额加载中，请等待"];
        return;
    }
    
    if (self.selectedCell) {
        [self.selectedCell unSelected];
    }
    self.selectedCell = (AlterSendGiftCollectionViewCell *) [collectionView cellForItemAtIndexPath:indexPath];
    [self.selectedCell selected];
    
    // 判断余额不足
    if ([self.accountAmount integerValue] < self.giftInfoList[indexPath.row].giftPrice) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"您的余额不足以购买%@，请先充值。", self.giftInfoList[indexPath.row].giftName] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.tag          = LYSendGiftAlertTypeAccountAmount;
        [alert show];
    } else {
        
        if (self.isSendGiftAsk == YES) {
            LYSendGiftModel *model = self.giftInfoList[indexPath.row];
            self.senderGiftAskBlock(model.giftName,model.giftIconURL,model.giftId,model.giftPrice);
            
        }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"确定赠送%@给%@吗？", self.giftInfoList[indexPath.row].giftName, self.userName] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"赠送", nil];
        alert.tag          = LYSendGiftAlertTypeSendGift;
              [alert show];
        }
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat WH = (SCREEN_WIDTH - 3.f) / 4.f;
    return CGSizeMake(WH, WH);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 1.f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 1.f;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    self.headerView                = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"AlterSendGiftCollectionReusableView" forIndexPath:indexPath];
    __weak typeof(self) weakSelf   = self;
    [weakSelf.headerView.getCoinBtn addTarget:self action:@selector(getCoinClick) forControlEvents:UIControlEventTouchUpInside];
//    self.headerView.fetchCoinBlock = ^(id sender) {
//        [weakSelf removeFromSuperview];
//        MyMoneyVC *vc = [[MyMoneyVC alloc]init];
//        [weakSelf.viewController.navigationController pushViewController:vc animated:YES];
//    };
    
    return self.headerView;
}

-(void)getCoinClick{
   
    MyMoneyVC *vc = [[MyMoneyVC alloc]init];
    [self.viewController.navigationController pushViewController:vc animated:YES];
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(SCREEN_WIDTH, 40.f);
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex NS_DEPRECATED_IOS(2_0, 9_0) {
    LYSendGiftAlertType type = (LYSendGiftAlertType) alertView.tag;
    
    switch (type) {
        case LYSendGiftAlertTypeAccountAmount: {
            // 判断是否显示充值界面
            //            if (![[[NSUserDefaults standardUserDefaults] valueForKey:@"ShowGetCoinKey"] boolValue]) {
            //                return;
            //            }
            // 跳转充值页面
            if (buttonIndex == 1) {
                
                MyMoneyVC *vc = [[MyMoneyVC alloc]init];
                //                LYGetCoinViewController *vc = [LYGetCoinViewController new];
                //                vc.accountAmount            = [self.accountAmount integerValue];
                [self.viewController.navigationController pushViewController:vc animated:YES];
            }
            break;
        }
        case LYSendGiftAlertTypeSendGift: {
            // 确认送礼物
            if (buttonIndex == 1) {
                [self p_sendGift:[self.collectionView indexPathForCell:self.selectedCell].row];
            }
            break;
        }
    }
    
    // 取消选中
    [self.selectedCell unSelected];
    self.selectedCell = nil;
}

- (void)p_sendGift:(NSInteger)index {
    [MBProgressHUD showHUDAddedTo:self.viewController.view animated:YES];
    LYSendGiftModel *model = self.giftInfoList[index];

    NSDictionary *dic= @{
                         @"userId": [CommonTool getUserID],
                         @"otherUserId": self.friendID,
                         @"giftId": @(self.giftInfoList[index].giftId),
                         @"usedType": @"gift",
                         @"goldPrice":@(self.giftInfoList[index].giftPrice),
                         @"userCaptcha":[CommonTool getUserCaptcha]
                         } ;
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/order/updateOrderGold", REQUESTHEADER]
                           andParameter:dic
                                success:^(id successResponse) {
                                    [MBProgressHUD hideHUDForView:self.viewController.view animated:YES];
                                    if ([successResponse[@"code"] integerValue] == 200) {
                                        [MBProgressHUD showSuccess:@"赠送成功"];
//                                        self.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 0);
                                        [self  removeFromSuperview];
                                        self.giftInfoBlock(model.giftName,model.giftIconURL,[NSString  stringWithFormat:@"%d",model.giftPrice]);
                                      
                                    } else {
                                        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.viewController.view animated:YES];
                                        hud.mode =MBProgressHUDModeText;//显示的模式
                                        hud.labelText =[NSString stringWithFormat:@"%@", successResponse[@"errorMsg"]];
                                        hud.removeFromSuperViewOnHide =YES;
                                        [hud hide:YES afterDelay:1];
                                        
                                    }
                                }
                             andFailure:^(id failureResponse) {
                                 [MBProgressHUD hideHUDForView:self.viewController.view animated:YES];
                                 [MBProgressHUD showError:@"赠送礼物失败，请重试"];
                             }];
}
#pragma mark - Pravite

- (void)p_loadAccountAmount {
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/getUserPower", REQUESTHEADER]
                           andParameter:@{
                                          @"userId": [CommonTool getUserID]
                                          }
                                success:^(id successResponse) {
                                    MLOG(@"结果:%@", successResponse);
                                    if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
                                        self.accountAmount = [NSString stringWithFormat:@"%@", successResponse[@"data"][@"userGold"]];
                                        [self.headerView configDataAccountAmount:self.accountAmount];
                                    } else {
                                        [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"msg"]]];
                                    }
                                }
                             andFailure:^(id failureResponse) {
                                 [MBProgressHUD showError:@"查询余额失败，请重试"];
                             }];
}

- (void)giftInfoBlock:(GiftInfoBlock)block{
    self.giftInfoBlock = block;
}
- (void)senderGiftAskBlock:(SenderGiftAskBlock)block{
    self.senderGiftAskBlock = block;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
