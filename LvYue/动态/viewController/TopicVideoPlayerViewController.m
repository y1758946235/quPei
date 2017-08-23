//
//  TopicVideoPlayerViewController.m
//  LvYue
//
//  Created by X@Han on 17/8/10.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "TopicVideoPlayerViewController.h"
#import "TopicVideoPlayCollectionViewCell.h"
#import "DyVideoListModel.h"

#import "LZBVideoPlayer.h"

typedef NS_ENUM(NSInteger,LZBVideoScreenDirection)
{
    LZBVideoScreenDirection_None,
    LZBVideoScreenDirection_Left,
    LZBVideoScreenDirection_Right,
    
};
@interface TopicVideoPlayerViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>{
    UICollectionView *videoCV;
    
    NSInteger currentPage;  //当前页数
    
    CGFloat width;
    
}
@property(nonatomic,copy)NSMutableArray *dataArr;


//数据记录
@property (nonatomic, assign) CGFloat lastContentOffsetX;
@property (nonatomic, assign)  LZBVideoScreenDirection moveDirection;
@property (nonatomic, strong)  TopicVideoPlayCollectionViewCell *playingCell;
@property (nonatomic, strong)  NSString *currentVideoPath;
@property (nonatomic, assign)  BOOL isFirst;
@property (nonatomic, assign)  NSInteger lastIndex;

@end

@implementation TopicVideoPlayerViewController
- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [[NSMutableArray alloc]init];
    }
    
    return _dataArr;
}
-(void)viewWillAppear:(BOOL)animated{
    
   [[LZBVideoPlayer sharedInstance] playWithResume];
    [self.navigationController setNavigationBarHidden:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
}
-(void)viewWillDisappear:(BOOL)animated{
    
   
    [self.navigationController setNavigationBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
   
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationController setNavigationBarHidden:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
     [self creatVideoCV];
}

-(void)creatVideoCV{
    
    
    
    UICollectionViewFlowLayout *layOut = [[UICollectionViewFlowLayout alloc]init];
    layOut.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    videoCV = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) collectionViewLayout:layOut];
    videoCV.backgroundColor = [UIColor colorWithHexString:@"#ffffff"];
    [videoCV registerClass:[TopicVideoPlayCollectionViewCell class] forCellWithReuseIdentifier:@"TopicVideoPlayCollectionViewCell"];
    videoCV.dataSource = self;
    videoCV.delegate = self;
    videoCV.showsHorizontalScrollIndicator = YES;
    videoCV.pagingEnabled = YES;
    [self.view addSubview:videoCV];
    
   
    [videoCV scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.index inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    [videoCV reloadData];
   
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    
    return self.dataArr.count;
    
}

#pragma mark   -----item的纵向间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    
    return 0.0f;
    
    
}


#pragma mark   ----item的横向间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    
    return 0.0f;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
   //  NSString *identifier=[NSString stringWithFormat:@"%ld%ld",(long)indexPath.section,(long)indexPath.row];
//     [videoCV registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:identifier];
    
      NSString * stringID = [NSString stringWithFormat:@"TopicVideoPlayCollectionViewCell"];
    TopicVideoPlayCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:stringID forIndexPath:indexPath];
    
    DyVideoListModel *aModel = self.dataArr[indexPath.row];
   
    if (aModel) {
      [cell creatModel:aModel];
    }
    
    WS(weakSelf);
   
    cell.userInteractionEnabled = YES;
    
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if( self.isFirst== NO)
    {
        self.isFirst = YES;
        TopicVideoPlayCollectionViewCell *firstCell = (TopicVideoPlayCollectionViewCell *)cell;
        [self playFirstCellWithFirst:firstCell];
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger index = scrollView.contentOffset.x/[UIScreen mainScreen].bounds.size.width + 0.5;
    if(index > self.lastIndex)
    {
        self.lastIndex = index;
        // scrollView已经完全静止
        [self processNextVideoPlayEventWithDirection:LZBVideoScreenDirection_Right index:index];
    }
    else if(index < self.lastIndex)
    {
        self.lastIndex = index;
        // scrollView已经完全静止
        [self processNextVideoPlayEventWithDirection:LZBVideoScreenDirection_Left index:index];
    }
    
    
}

#pragma mark - handel

- (void)playFirstCellWithFirst:(TopicVideoPlayCollectionViewCell *)firstCell
{
    if(firstCell == nil) return;
    if(firstCell.videoPath.length == 0) return;
    
    self.playingCell = firstCell;
    self.currentVideoPath =firstCell.videoPath;
    NSURL *url = [NSURL URLWithString:firstCell.videoPath];
    [self startPlayerWithUrl:url coverImageUrl:@"设置背景图片" playerSuperView:firstCell.playerView];
    
}
//停止播放
-(void)stopPlayer
{
    [[LZBVideoPlayer sharedInstance] stop];
    self.playingCell = nil;
    self.currentVideoPath = nil;
}

//开始播放
- (void)startPlayerWithUrl:(NSURL *)url coverImageUrl:(NSString *)coverUrl playerSuperView:(UIView *)superView
{
    
    __weak __typeof(self) weakSelf = self;
    [[LZBVideoPlayer sharedInstance] playVideoUrl:url coverImageurl:coverUrl showInSuperView:superView];
    [LZBVideoPlayer sharedInstance].openSoundWhenPlaying = YES;
    //剩余时间
    [[LZBVideoPlayer sharedInstance] setPlayerTimeProgressBlock:^(long residueTime) {
        [weakSelf.playingCell reloadTimeLabelWithTime:residueTime];
        if(residueTime == 0)
        {
//            [[LZBVideoPlayer sharedInstance] stop];
//              [[LZBVideoPlayer sharedInstance] playVideoUrl:url coverImageurl:coverUrl showInSuperView:superView];
//            [LZBVideoPlayer sharedInstance].openSoundWhenPlaying = YES;
            
//            [[LZBVideoPlayer sharedInstance] playWithResume];
//            //播放完成，自动滚动到下一页
//            [weakSelf scrollToNextCell];
        }
        
    }];
}
- (void)processNextVideoPlayEventWithDirection:(LZBVideoScreenDirection)direction  index:(NSInteger)index
{
    //获取当前屏幕的cell
    NSArray *visiableCells = [videoCV visibleCells];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    TopicVideoPlayCollectionViewCell  *nextCell = (TopicVideoPlayCollectionViewCell *)[videoCV cellForItemAtIndexPath:indexPath];
    if([self.playingCell isEqual:nextCell]) return;
    if(nextCell == nil) return;
    
    //屏幕到中间时候，停止上一个cell视频播放
    if ([visiableCells containsObject:self.playingCell]) {
        [self stopPlayer];
    }
    
    //开始播放下一个视频
    self.playingCell = nextCell;
    self.currentVideoPath = nextCell.videoPath;
    NSURL *url = [NSURL URLWithString:nextCell.videoPath];
    [self startPlayerWithUrl:url coverImageUrl:@"设置背景图片" playerSuperView:nextCell.playerView];
    
    
    
}

//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    DyVideoListModel *aModel = self.dataArr[indexPath.row];
//    if (aModel) {
//        
//        
//        [cell creatModel:aModel];
//    }
//    
//
//}
//- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath
//           toIndexPath:(NSIndexPath *)destinationIndexPath{
//    
//    DyVideoListModel *aModel = self.dataArr[sourceIndexPath.row];
//    TopicVideoPlayCollectionViewCell *cell = [collectionView cellForItemAtIndexPath:sourceIndexPath];
//    if (aModel) {
//    
//        
//        [cell creatModel:aModel];
//    }
//
//}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
    return CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT);
    
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    return UIEdgeInsetsMake(0, 0, 0, 0);
    
}

-(void)loadDataArr:(NSArray *)dataArr{
   
    
   
    for (DyVideoListModel *model in dataArr) {
        if ([[NSString stringWithFormat:@"%@",model.isVideoTopic] isEqualToString:@"0"]) {
            [self.dataArr addObject:model];
        }
    }

  
   
   
}
-(void)viewDidLayoutSubviews{
    
}
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
