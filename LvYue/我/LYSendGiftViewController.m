//
//  LYSendGiftViewController.m
//  LvYue
//
//  Created by KentonYu on 16/7/27.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "KFAlertView.h"
#import "LYGetCoinViewController.h"
#import "LYGetCoinViewController.h"
#import "LYHttpPoster.h"
#import "LYSendGiftCollectionViewCell.h"
#import "LYSendGiftHeaderView.h"
#import "LYSendGiftModel.h"
#import "LYSendGiftViewController.h"
#import "LYUserService.h"
#import "MBProgressHUD+NJ.h"

typedef NS_ENUM(NSUInteger, LYSendGiftAlertType) {
    LYSendGiftAlertTypeAccountAmount = 1, // 余额不足
    LYSendGiftAlertTypeSendGift      = 2  // 送礼物
};

static NSString *const LYSendGiftHeaderViewIdentity         = @"LYSendGiftHeaderViewIdentity";
static NSString *const LYSendGiftCollectionViewCellIdentity = @"LYSendGiftCollectionViewCellIdentity";

@interface LYSendGiftViewController () <
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout,
    UIAlertViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) LYSendGiftHeaderView *headerView;
@property (nonatomic, strong) UICollectionViewFlowLayout *layout;

@property (nonatomic, strong) LYSendGiftCollectionViewCell *selectedCell;
@property (nonatomic, copy) NSString *accountAmount; // 账户余额
@property (nonatomic, strong) NSMutableArray<LYSendGiftModel *> *giftInfoList;

@end

@implementation LYSendGiftViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"赠送礼物";

    [self p_loadAccountAmount];
    [self p_loadGift];
}

#pragma mark - UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.giftInfoList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LYSendGiftCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:LYSendGiftCollectionViewCellIdentity forIndexPath:indexPath];
    [cell configData:self.giftInfoList[indexPath.row]];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    self.headerView                = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:LYSendGiftHeaderViewIdentity forIndexPath:indexPath];
    __weak typeof(self) weakSelf   = self;
    self.headerView.fetchCoinBlock = ^(id sender) {
        LYGetCoinViewController *vc = [LYGetCoinViewController new];
        vc.accountAmount            = [weakSelf.accountAmount integerValue];
        [weakSelf.navigationController pushViewController:vc animated:YES];
    };
    [self.headerView configData:self.userName avatarImageURL:self.avatarImageURL accountAmount:self.accountAmount];
    return self.headerView;
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
    self.selectedCell = (LYSendGiftCollectionViewCell *) [collectionView cellForItemAtIndexPath:indexPath];
    [self.selectedCell selected];

    // 判断余额不足
    if ([self.accountAmount integerValue] < self.giftInfoList[indexPath.row].giftPrice) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"您的余额不足已购买%@，请先充值。", self.giftInfoList[indexPath.row].giftName] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.tag          = LYSendGiftAlertTypeAccountAmount;
        [alert show];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"确定赠送%@给%@吗？", self.giftInfoList[indexPath.row].giftName, self.userName] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"赠送", nil];
        alert.tag          = LYSendGiftAlertTypeSendGift;
        [alert show];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat WH = (SCREEN_WIDTH - 2.f) / 3.f;
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

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(SCREEN_WIDTH, 130.f);
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
                LYGetCoinViewController *vc = [LYGetCoinViewController new];
                vc.accountAmount            = [self.accountAmount integerValue];
                [self.navigationController pushViewController:vc animated:YES];
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

#pragma mark - Pravite

- (void)p_loadAccountAmount {
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/need/hongdou", REQUESTHEADER]
        andParameter:@{
            @"user_id": [LYUserService sharedInstance].userID
        }
        success:^(id successResponse) {
            MLOG(@"结果:%@", successResponse);
            if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
                self.accountAmount = [NSString stringWithFormat:@"%@", successResponse[@"data"][@"data"][@"hongdou"]];
                [self.headerView configData:self.userName avatarImageURL:self.avatarImageURL accountAmount:self.accountAmount];
            } else {
                [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"msg"]]];
            }
        }
        andFailure:^(id failureResponse) {
            [MBProgressHUD showError:@"查询余额失败，请重试"];
        }];
}

- (void)p_loadGift {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/gift/giftlist", REQUESTHEADER] andParameter:nil
        success:^(id successResponse) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if ([successResponse[@"code"] integerValue] == 200) {

                self.giftInfoList = [[NSMutableArray alloc] init];
                [successResponse[@"data"][@"giftlist"] enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
                    [self.giftInfoList addObject:[LYSendGiftModel initWithDic:obj]];
                }];
                [self.collectionView reloadData];

            } else {
                [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"msg"]]];
            }
        }
        andFailure:^(id failureResponse) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [MBProgressHUD showError:@"加载礼物列表失败，请重试"];
        }];
}

- (void)p_sendGift:(NSInteger)index {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    NSInteger type = 0;
    switch (self.type) {
        case LYSendGiftFunTypeDefalut: {
            type = 1;
            break;
        }
        case LYSendGiftFunTypeInvite: {
            type = 2;
            break;
        }
    }

    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/gift/present", REQUESTHEADER]
        andParameter:@{
            @"userId": [LYUserService sharedInstance].userID,
            @"otherId": self.friendID,
            @"giftId": @(self.giftInfoList[index].giftId),
            @"type": @(type)
        }
        success:^(id successResponse) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if ([successResponse[@"code"] integerValue] == 200) {
                [MBProgressHUD showSuccess:@"赠送成功"];
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"msg"]]];
            }
        }
        andFailure:^(id failureResponse) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [MBProgressHUD showError:@"赠送礼物失败，请重试"];
        }];
}

#pragma mark - Getter

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView                 = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64.f) collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
        _collectionView.backgroundColor = RGBCOLOR(213, 213, 213);
        _collectionView.delegate        = self;
        _collectionView.dataSource      = self;
        [_collectionView registerNib:[UINib nibWithNibName:@"LYSendGiftHeaderView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:LYSendGiftHeaderViewIdentity];
        [_collectionView registerClass:[LYSendGiftCollectionViewCell class] forCellWithReuseIdentifier:LYSendGiftCollectionViewCellIdentity];
        [self.view addSubview:_collectionView];
    }
    return _collectionView;
}

@end
