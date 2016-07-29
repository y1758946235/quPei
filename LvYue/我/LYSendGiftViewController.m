//
//  LYSendGiftViewController.m
//  LvYue
//
//  Created by KentonYu on 16/7/27.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "KFAlertView.h"
#import "LYHttpPoster.h"
#import "LYSendGiftCollectionViewCell.h"
#import "LYSendGiftHeaderView.h"
#import "LYSendGiftViewController.h"
#import "LYUserService.h"
#import "MBProgressHUD+NJ.h"

typedef NS_ENUM(NSUInteger, LYSendGiftAlertType) {
    LYSendGiftAlertTypeAccountAmount = 1, // 余额不足
    LYSendGiftAlertTypeSendGift      = 2  // 送礼物
};

static NSArray<NSDictionary *> *LYSendGiftCollectionViewDataArray;
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

@end

@implementation LYSendGiftViewController

+ (void)initialize {
    LYSendGiftCollectionViewDataArray = @[
        @{ @"icon": @"青瓜",
           @"name": @"小青瓜",
           @"coin": @"1" },
        @{ @"icon": @"魔棒",
           @"name": @"魔术棒",
           @"coin": @"2" },
        @{ @"icon": @"小旺",
           @"name": @"小汪",
           @"coin": @"5" },
        @{ @"icon": @"鲜花",
           @"name": @"束花",
           @"coin": @"10" },
        @{ @"icon": @"烟花",
           @"name": @"爱心烟花",
           @"coin": @"6666" },
        @{ @"icon": @"戒指",
           @"name": @"钻戒",
           @"coin": @"5000" },
        @{ @"icon": @"红包",
           @"name": @"大红包",
           @"coin": @"3000" },
        @{ @"icon": @"小蘑菇",
           @"name": @"小蘑菇",
           @"coin": @"1" },
        @{ @"icon": @"干杯",
           @"name": @"干杯",
           @"coin": @"2" },
        @{ @"icon": @"香蕉先生",
           @"name": @"香蕉先生",
           @"coin": @"2" },
        @{ @"icon": @"飞吻",
           @"name": @"飞吻",
           @"coin": @"33" },
        @{ @"icon": @"爱心钻石",
           @"name": @"爱心钻石",
           @"coin": @"88" },
        @{ @"icon": @"红包",
           @"name": @"小红包",
           @"coin": @"500" },
        @{ @"icon": @"飞机",
           @"name": @"飞机",
           @"coin": @"3000" },
        @{ @"icon": @"赛车",
           @"name": @"赛车",
           @"coin": @"3000" },
        @{ @"icon": @"西瓜",
           @"name": @"小西瓜",
           @"coin": @"1" },
        @{ @"icon": @"雷枪",
           @"name": @"手枪",
           @"coin": @"2" },
        @{ @"icon": @"鞭",
           @"name": @"鞭",
           @"coin": @"3" },
    ];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"赠送礼物";

    [self p_loadAccountAmount];

    [self.collectionView reloadData];
}

#pragma mark - UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return LYSendGiftCollectionViewDataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LYSendGiftCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:LYSendGiftCollectionViewCellIdentity forIndexPath:indexPath];
    [cell configData:LYSendGiftCollectionViewDataArray[indexPath.row]];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    self.headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:LYSendGiftHeaderViewIdentity forIndexPath:indexPath];
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
    if ([self.accountAmount integerValue] < [LYSendGiftCollectionViewDataArray[indexPath.row][@"coin"] integerValue]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"您的余额不足已购买%@，请先充值。", LYSendGiftCollectionViewDataArray[indexPath.row][@"name"]] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.tag          = LYSendGiftAlertTypeAccountAmount;
        [alert show];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"确定赠送%@给%@吗？", LYSendGiftCollectionViewDataArray[indexPath.row][@"name"], self.userName] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"赠送", nil];
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
            // 跳转充值页面
            if (buttonIndex == 0) {
            }
            break;
        }
        case LYSendGiftAlertTypeSendGift: {
            // 确认送礼物
            if (buttonIndex == 0) {
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

#pragma mark - Getter

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView                 = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
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
