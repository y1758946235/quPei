//
//  DyFirstCollectionViewCell.m
//  LvYue
//
//  Created by X@Han on 17/5/22.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "DyFirstCollectionViewCell.h"
#import "VideoDynamiclistCollectionViewCell.h"
#import "DyVideoListModel.h"
#import "DyVideoPlayerViewController.h"
@interface DyFirstCollectionViewCell ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>{
    UICollectionView *videoCV;

    NSInteger currentPage;  //当前页数
    
    CGFloat width;
 
}

@property(nonatomic,copy)NSMutableArray *dataArr;

@property (nonatomic, weak) UILabel *label;
@end
@implementation DyFirstCollectionViewCell

- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [[NSMutableArray alloc]init];
    }
    
    return _dataArr;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        currentPage = 1;
        width = (SCREEN_WIDTH-24)/2;
        self.contentView.backgroundColor = [UIColor colorWithHexString:@"#ffffff"];
        [self creatVideoCV];
        [self getdata];
        [self addRefresh];
        
    }
    return self;
}

#pragma mark   -----加载更多的数据
- (void)addRefresh{
    
  
    
    
    //下拉刷新
    videoCV.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefreshing)];
    
    
        //上拉加载更多
    
        videoCV.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRefreshing)];
    
}
#pragma mark   ----下拉刷新
- (void)headerRefreshing{
    MJRefreshStateHeader *header = (MJRefreshStateHeader *) videoCV.mj_header;
    [header setTitle:@"下拉可以刷新" forState:MJRefreshStateIdle];
    [header setTitle:@"松开马上刷新" forState:MJRefreshStatePulling];
    [header setTitle:@"刷新中" forState:MJRefreshStateRefreshing];
    
    
   currentPage = 1;
    [self  getdata];
    
    [videoCV.mj_header endRefreshing];
}

#pragma mark   ---上拉刷新
- (void)footerRefreshing{
    currentPage++;
    
    [self  loadMoerdata];
    [videoCV.mj_footer endRefreshing];
}
-(void)creatVideoCV{
   
    
    
    UICollectionViewFlowLayout *layOut = [[UICollectionViewFlowLayout alloc]init];
    layOut.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    videoCV = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-30-49-50) collectionViewLayout:layOut];
    videoCV.backgroundColor = [UIColor colorWithHexString:@"#ffffff"];
    [videoCV registerClass:[VideoDynamiclistCollectionViewCell class] forCellWithReuseIdentifier:@"VideoDynamiclistCollectionViewCell"];
    videoCV.dataSource = self;
    videoCV.delegate = self;
    /** 去除tableview 右侧滚动条 */
    videoCV.showsVerticalScrollIndicator = NO;
    [self.contentView addSubview:videoCV];
    
    UILabel *lineLabel= [[UILabel alloc]init];
    lineLabel.frame = CGRectMake(0, 0, SCREEN_WIDTH, 0.2);
    lineLabel.backgroundColor = RGBA(229, 229, 231, 1);
    [videoCV addSubview:lineLabel];
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
    
    VideoDynamiclistCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"VideoDynamiclistCollectionViewCell" forIndexPath:indexPath];
    
    DyVideoListModel *aModel = self.dataArr[indexPath.row];
    if (aModel) {
         [cell creatModel:aModel];
    }
   
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
    return CGSizeMake(width, width*424/264);
    
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    return UIEdgeInsetsMake(8, 8, 0, 8);
    
}
#pragma mark  --点头
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    DyVideoListModel *model = self.dataArr[indexPath.row];
    DyVideoPlayerViewController*vc = [[DyVideoPlayerViewController alloc]init];
    NSString *videoURLString = [NSString stringWithFormat:@"%@%@", IMAGEHEADER, model.shareUrl];
//    NSString *videoURLString = @"http://yxfile.idealsee.com/9f6f64aca98f90b91d260555d3b41b97_mp4.mp4";
   
    vc.videoURL = [NSURL URLWithString:videoURLString];
    
    vc.headUrlStr = [NSString stringWithFormat:@"%@%@", IMAGEHEADER, model.userIcon];
    vc.nameStr = model.userNickname;
    vc.otherId = model.userId;
    vc.shareContentStr =[NSString stringWithFormat:@"%@",model.shareSignature] ;
    vc.videoId = model.videoId;
    [self.viewController.navigationController pushViewController:vc animated:YES];
}

-(void)getdata{
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/share/getUserShare",REQUESTHEADER] andParameter:@{@"pageNum":@"1",@"shareType":@"0",@"shareLongitude":@"0",@"shareLatitude":@"0"} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        [MBProgressHUD hideHUD];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            [self.dataArr removeAllObjects];
            NSArray *arr =successResponse[@"data"];
            for (NSDictionary * dic in arr) {
                DyVideoListModel *model =[DyVideoListModel createWithModelDic:dic];
                [self.dataArr addObject:model];
            }
            [videoCV reloadData];
           
        } else {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];

}
-(void)loadMoerdata{
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/share/getUserShare",REQUESTHEADER] andParameter:@{@"pageNum":[NSString stringWithFormat:@"%ld",(long)currentPage],@"shareType":@"0",@"shareLongitude":@"0",@"shareLatitude":@"0"} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        [MBProgressHUD hideHUD];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
           
            NSArray *arr =successResponse[@"data"];
            for (NSDictionary * dic in arr) {
                DyVideoListModel *model =[DyVideoListModel createWithModelDic:dic];
                [self.dataArr addObject:model];
            }
            [videoCV reloadData];
            if (arr.count == 0) {
                currentPage --;
                [MBProgressHUD showSuccess:@"已经到底啦"];
            }
            
        } else {
            currentPage--;
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
            
        }
    } andFailure:^(id failureResponse) {
        currentPage--;
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
    
}
@end
