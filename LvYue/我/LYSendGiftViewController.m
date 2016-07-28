//
//  LYSendGiftViewController.m
//  LvYue
//
//  Created by KentonYu on 16/7/27.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "LYSendGiftCollectionViewCell.h"
#import "LYSendGiftHeaderView.h"
#import "LYSendGiftViewController.h"

static NSArray<NSDictionary *> *LYSendGiftCollectionViewDataArray;
static NSString *const LYSendGiftCollectionViewCellIdentity = @"LYSendGiftCollectionViewCellIdentity";

@interface LYSendGiftViewController () <
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *layout;
@property (nonatomic, strong) LYSendGiftHeaderView *headerView;

@property (nonatomic, strong) LYSendGiftCollectionViewCell *selectedCell;

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
        @{ @"icon": @"小汪",
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

    [self.view addSubview:self.headerView];

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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    if (self.selectedCell) {
        [self.selectedCell unSelected];
    }
    self.selectedCell = (LYSendGiftCollectionViewCell *) [collectionView cellForItemAtIndexPath:indexPath];
    [self.selectedCell selected];
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


#pragma mark - Getter

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView                 = [[UICollectionView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT + STATUS_BAR_HEIGHT + 130.f, SCREEN_WIDTH, SCREEN_HEIGHT - NAVIGATION_BAR_HEIGHT - STATUS_BAR_HEIGHT - 130.f) collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
        _collectionView.backgroundColor = RGBCOLOR(213, 213, 213);
        _collectionView.delegate        = self;
        _collectionView.dataSource      = self;
        [_collectionView registerNib:[UINib nibWithNibName:@"LYSendGiftCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:LYSendGiftCollectionViewCellIdentity];
        [self.view addSubview:_collectionView];
    }
    return _collectionView;
}

- (LYSendGiftHeaderView *)headerView {
    if (!_headerView) {
        _headerView = [[[NSBundle mainBundle] loadNibNamed:@"LYSendGiftHeaderView" owner:self options:nil]
            objectAtIndex:0];
        _headerView.frame = CGRectMake(0, NAVIGATION_BAR_HEIGHT + STATUS_BAR_HEIGHT, SCREEN_WIDTH, 130.f);
    }
    return _headerView;
}

@end
