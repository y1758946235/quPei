//
//  LYEssenceAlbumViewController.m
//  LvYue
//
//  Created by KentonYu on 16/7/22.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "FXBlurView.h"
#import "LYEssenceAlbumViewController.h"
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "MBProgressHUD+NJ.h"
#import "MyDispositionCollectionViewCell.h"
#import "OriginalViewController.h"
#import "SDWebImageManager.h"

static NSString *const LYEssenceAlbumCollectionViewCellIdentity =
    @"photoCell";

@interface LYEssenceAlbumViewController () <UICollectionViewDataSource,
                                            UICollectionViewDelegate,
                                            SDWebImageManagerDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewLayout *collectionViewLayout;

@property (nonatomic, strong) NSArray<NSDictionary *> *responseArray;
@property (nonatomic, strong)
    NSArray<NSString *> *imageURLArray;                              // 图片URL
@property (nonatomic, strong) NSMutableArray<UIImage *> *imageArray; // 压缩数组

@end

@implementation LYEssenceAlbumViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"精华相册";
    self.view.backgroundColor = [UIColor whiteColor];

    [self p_loadData];
}

#pragma mark Getter

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = ({
            UICollectionView *collectionView = [[UICollectionView alloc]
                       initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - NAVIGATION_BAR_HEIGHT)
                collectionViewLayout:self.collectionViewLayout];
            collectionView.backgroundColor      = [UIColor whiteColor];
            collectionView.dataSource           = self;
            collectionView.delegate             = self;
            collectionView.alwaysBounceVertical = YES;
            [collectionView registerNib:[UINib nibWithNibName:
                                                   @"MyDispositionCollectionViewCell"
                                                       bundle:nil]
                forCellWithReuseIdentifier:LYEssenceAlbumCollectionViewCellIdentity];
            [self.view addSubview:collectionView];
            collectionView;
        });
    }
    return _collectionView;
}

- (UICollectionViewLayout *)collectionViewLayout {
    if (!_collectionViewLayout) {
        _collectionViewLayout = ({
            UICollectionViewFlowLayout *layout =
                [[UICollectionViewFlowLayout alloc] init];
            layout.itemSize                = CGSizeMake(SCREEN_WIDTH / 3 - 7, SCREEN_WIDTH / 3 - 7);
            layout.sectionInset            = UIEdgeInsetsMake(5, 5, 5, 5);
            layout.minimumInteritemSpacing = 5;
            layout.minimumLineSpacing      = 5;
            layout;
        });
    }
    return _collectionViewLayout;
}

- (NSArray<NSString *> *)imageURLArray {
    if (!_imageURLArray) {
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:self.responseArray.count];
        [self.responseArray enumerateObjectsUsingBlock:^(NSDictionary *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            [array addObject:[NSString stringWithFormat:@"%@%@", IMAGEHEADER, obj[@"img_name"]]];
        }];
        _imageURLArray = [array copy];
    }
    return _imageURLArray;
}

- (NSMutableArray<UIImage *> *)imageArray {
    if (!_imageArray) {
        _imageArray = [[NSMutableArray alloc] initWithCapacity:self.imageURLArray.count];
        for (NSInteger flag = 0; flag < self.imageURLArray.count; flag++) {
            [_imageArray addObject:[UIImage imageNamed:@"PlaceImage"]];
        }
    }
    return _imageArray;
}


#pragma mark - UICollectionDelegate,UICollevtiondataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return self.imageURLArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MyDispositionCollectionViewCell *cell =
        [collectionView dequeueReusableCellWithReuseIdentifier:
                            LYEssenceAlbumCollectionViewCellIdentity
                                                  forIndexPath:indexPath];
    cell.imageViewM.image = self.imageArray[indexPath.row];

    //    NSDictionary *dic = self.compressImageArray[indexPath.item];
    //    NSURL *url = [NSURL URLWithString:[NSString
    //    stringWithFormat:@"%@%@",IMAGEHEADER,dic[@"img_name"]]];
    //    [cell.imageViewM sd_setImageWithURL:url placeholderImage:[UIImage
    //    imageNamed:@"PlaceImage"] options:SDWebImageRetryFailed];

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView
    didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    OriginalViewController *vc = [[OriginalViewController alloc] init];
    vc.imageData               = self.responseArray; // 响应的字典
    vc.smallImage              = self.imageArray;    // 对应已经加载的 image 对象
    ;
    vc.userId = [LYUserService sharedInstance].userID;
    [vc showImageWithIndex:indexPath.row andCount:self.imageArray.count];
}

#pragma mark - Pravite

- (void)p_loadData {

    NSString *userId = [LYUserService sharedInstance].userID;

    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/imgList", REQUESTHEADER] andParameter:@{ @"user_id": userId } success:^(id successResponse) {

        if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {

            self.responseArray = successResponse[@"data"][@"list"];
            [self.collectionView reloadData];

            // 下载图片
            [self p_downloadImage];

        } else {
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"msg"]]];
        }
    }
        andFailure:^(id failureResponse) {
            [MBProgressHUD showError:@"服务器繁忙,请重试"];
        }];
}

- (void)p_downloadImage {
    [self.imageURLArray enumerateObjectsUsingBlock:^(NSString *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {

        NSURL *URL = [NSURL URLWithString:obj];
        [[SDWebImageManager sharedManager] downloadImageWithURL:URL options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            __block UIImage *returnImage = image;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                // 图片模糊
                returnImage = [returnImage blurredImageWithRadius:100 iterations:3 tintColor:RGBACOLOR(0, 0, 0, 0.5)];
                [self.imageArray replaceObjectAtIndex:idx withObject:returnImage];

                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]]];
                });

            });

        }];
    }];
}


@end
