//
//  MyDispositionViewController.m
//  LvYue
//
//  Created by 郑洲 on 16/3/15.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "MBProgressHUD+NJ.h"
#import "MJRefresh.h"
#import "MyDispositionCollectionViewCell.h"
#import "MyDispositionViewController.h"
#import "OriginalViewController.h"
#import "UIImageView+WebCache.h"
#import "UpLoadViewController.h"

@interface MyDispositionViewController () <UICollectionViewDataSource, UICollectionViewDelegate> {
    NSMutableArray *dataArr;
    NSMutableArray *smallArr;
}

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation MyDispositionViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"我的气质";

    if (_userId.length == 0) {
        [self setRightButton:[UIImage imageNamed:@"上传照片"] title:nil target:self action:@selector(uploadPhoto)];
    }

    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize                    = CGSizeMake(SCREEN_WIDTH / 3 - 7, SCREEN_WIDTH / 3 - 7);
    flowLayout.sectionInset                = UIEdgeInsetsMake(5, 5, 5, 5);
    flowLayout.minimumInteritemSpacing     = 5;
    flowLayout.minimumLineSpacing          = 5;

    _collectionView                      = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) collectionViewLayout:flowLayout];
    _collectionView.delegate             = self;
    _collectionView.dataSource           = self;
    _collectionView.backgroundColor      = [UIColor clearColor];
    _collectionView.alwaysBounceVertical = YES;
    [self.view addSubview:_collectionView];

    [_collectionView registerNib:[UINib nibWithNibName:@"MyDispositionCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"photoCell"];
    dataArr  = [[NSMutableArray alloc] init];
    smallArr = [[NSMutableArray alloc] init];
    [self getData];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getData) name:@"reloadDisposition" object:nil];
}

- (void)getData {
    if (_userId.length == 0) {
        _userId = [LYUserService sharedInstance].userID;
    }
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/imgList", REQUESTHEADER] andParameter:@{ @"user_id": _userId } success:^(id successResponse) {
        MLOG(@"结果:%@", successResponse);
        if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
            dataArr = successResponse[@"data"][@"list"];
            [_collectionView reloadData];
        } else {
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"msg"]]];
        }
    }
        andFailure:^(id failureResponse) {
            [MBProgressHUD showError:@"服务器繁忙,请重试"];
        }];
}

- (void)uploadPhoto {
    UpLoadViewController *uploadVC = [[UpLoadViewController alloc] init];
    [self.navigationController pushViewController:uploadVC animated:YES];
}

#pragma mark - UICollectionDelegate,UICollevtiondataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return dataArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID               = @"photoCell";
    MyDispositionCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    NSDictionary *dic                     = dataArr[indexPath.item];
    NSURL *url                            = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", IMAGEHEADER, dic[@"img_name"]]];
    [cell.imageViewM sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"PlaceImage"] options:SDWebImageRetryFailed];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    for (int i = 0; i < dataArr.count; i++) {
        MyDispositionCollectionViewCell *cell = (MyDispositionCollectionViewCell *) [collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
        UIImage *image                        = cell.imageViewM.image;
        if (image) {
            [smallArr addObject:image];
        }
    }
    OriginalViewController *oVC = [[OriginalViewController alloc] init];
    oVC.imageData               = dataArr;
    oVC.smallImage              = smallArr;
    oVC.userId                  = self.userId;
    [oVC showImageWithIndex:indexPath.row andCount:dataArr.count];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
