//
//  DynamicViewController.m
//  LvYue
//
//  Created by X@Han on 17/5/22.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "DynamicViewController.h"
#import "DyFirstCollectionViewCell.h"
#import "DySecondCollectionViewCell.h"
#import "XWCatergoryView.h"
#import "UIView+FrameChange.h"
#import "UICollectionViewFlowLayout+XWFullItem.h"
#import "Masonry.h"
#import "PBJViewController.h"
#import "SendDyVideoViewController.h"
#import "VideoRecordingVC.h"

#import "VideoDynamiclistCollectionViewCell.h"
#import "DyVideoListModel.h"
#import "DyVideoPlayerViewController.h"

#import "VideoChatSetingViewController.h"

#import "TopicViewController.h"
#import "TopicVideoPlayerViewController.h"
@interface DynamicViewController ()<UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout, XWCatergoryViewDelegate>{
    UIButton *navRightBtn;

    UICollectionView *videoCV;
    
    NSInteger currentPage;  //当前页数
    
    CGFloat width;
    
}

@property(nonatomic,copy)NSMutableArray *dataArr;
@property(nonatomic,copy)NSMutableArray *topicDataArr;

@property (nonatomic, weak) UILabel *label;
@property (nonatomic, strong) NSArray *titles;

@end

@implementation DynamicViewController
- (NSMutableArray *)topicDataArr{
    if (!_topicDataArr) {
        _topicDataArr = [[NSMutableArray alloc]init];
    }
    
    return _topicDataArr;
}
- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [[NSMutableArray alloc]init];
    }
    
    return _dataArr;
}
-(void)viewWillAppear:(BOOL)animated{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    //设置状态栏的颜色
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNav];
    currentPage = 1;
    width = (SCREEN_WIDTH-24)/2;
    self.view.backgroundColor = [UIColor colorWithHexString:@"#ffffff"];
    [self creatVideoCV];
    
    
  
    [self getdata];
    [self addRefresh];
//    [self creatTheSlideBar];
    
//    [self resigiterNot];
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
    
    videoCV = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64-49) collectionViewLayout:layOut];
    videoCV.backgroundColor = [UIColor colorWithHexString:@"#ffffff"];
    [videoCV registerClass:[VideoDynamiclistCollectionViewCell class] forCellWithReuseIdentifier:@"VideoDynamiclistCollectionViewCell"];
    videoCV.dataSource = self;
    videoCV.delegate = self;
    /** 去除tableview 右侧滚动条 */
    videoCV.showsVerticalScrollIndicator = NO;
    [self.view addSubview:videoCV];
    
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
    DyVideoListModel *model = self.dataArr[indexPath.item];
    if ([[NSString stringWithFormat:@"%@",model.isVideoTopic] isEqualToString:@"1"]) {
        TopicViewController *topVC  = [[TopicViewController alloc]init];
        topVC.title = [NSString stringWithFormat:@"%@",model.videoTopicName];
        topVC.selectShareTopicId = model.videoTopicId;
        topVC.selectShareTopicTitle = model.videoTopicName;
        topVC.videoSignature = model.videoSignature;
        [self.navigationController pushViewController:topVC animated:YES];
        
      
    }else{
  
        NSMutableArray *topDataArr=[[NSMutableArray alloc]init];
        
        for (int i = 0; i<indexPath.item; i ++) {
            
            DyVideoListModel *model = self.dataArr[i];
            if ([[NSString stringWithFormat:@"%@",model.isVideoTopic] isEqualToString:@"1"]) {
                [topDataArr addObject:model];
            }

        }

        TopicVideoPlayerViewController *vc = [[TopicVideoPlayerViewController alloc]init];
        vc.index = indexPath.item -topDataArr.count;
        [vc loadDataArr:self.dataArr];
        [self.navigationController pushViewController:vc animated:YES];
//    DyVideoPlayerViewController*vc = [[DyVideoPlayerViewController alloc]init];
//    NSString *videoURLString = [NSString stringWithFormat:@"%@%@", IMAGEHEADER, model.shareUrl];
//    //    NSString *videoURLString = @"http://yxfile.idealsee.com/9f6f64aca98f90b91d260555d3b41b97_mp4.mp4";
//    
//    vc.videoURL = [NSURL URLWithString:videoURLString];
//    
//    vc.headUrlStr = [NSString stringWithFormat:@"%@%@", IMAGEHEADER, model.userIcon];
//    vc.nameStr = model.userNickname;
//    vc.otherId = model.userId;
//    vc.shareContentStr =[NSString stringWithFormat:@"%@",model.shareSignature] ;
//    vc.videoId = model.videoId;
//        [self.navigationController pushViewController:vc animated:YES];
    }
}

-(void)getdata{
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/video/getUserVideo",REQUESTHEADER] andParameter:@{@"pageNum":[NSString stringWithFormat:@"%ld",(long)currentPage]} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        [MBProgressHUD hideHUD];
        WS(weakSelf);
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            [self.dataArr removeAllObjects];
            NSMutableArray *arr =successResponse[@"data"];
//            [weakSelf getVideoTopic:arr];
            for (NSDictionary * dic in arr) {
                DyVideoListModel *model =[DyVideoListModel createWithModelDic:dic];
                [weakSelf.dataArr addObject:model];
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
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/video/getUserVideo",REQUESTHEADER] andParameter:@{@"pageNum":[NSString stringWithFormat:@"%ld",(long)currentPage]} success:^(id successResponse) {
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


//- (NSArray *)titles{
//    if (!_titles) {
//        _titles = @[@"视频",@"动态"];
//    }
//    return _titles;
//}
//
//
///**监听item点击*/
//- (void)catergoryView:(XWCatergoryView *)catergoryView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
//    NSLog(@"点击了%zd个item", indexPath.item);
//    NSSet *targets = [navRightBtn allTargets]; //或者使用btn. allTargets获取
//    NSEnumerator *enumerator = [targets objectEnumerator];
//    NSObject *obj = nil;
//    while (obj = [enumerator nextObject])
//        [navRightBtn removeTarget: obj action: @selector(gotoPBJViewControllerClick) forControlEvents: UIControlEventTouchUpInside];//注意：这里要跟addTarget写法一致
//     [navRightBtn removeTarget: obj action: @selector(gotoSendDyVideoViewControllerClick) forControlEvents: UIControlEventTouchUpInside];//注意：这里要跟addTarget写法一致
//    if (indexPath.item == 0) {
//        [navRightBtn  setImage:[UIImage imageNamed:@"视频icon"] forState:UIControlStateNormal];
//        
//        [navRightBtn addTarget:self action:@selector(gotoPBJViewControllerClick) forControlEvents:UIControlEventTouchUpInside];
//    }else{
//        [navRightBtn  setImage:[UIImage imageNamed:@"圆圈+号粉色"] forState:UIControlStateNormal];
//        [navRightBtn addTarget:self action:@selector(gotoSendDyVideoViewControllerClick) forControlEvents:UIControlEventTouchUpInside];
//    }
//}
//
//
//- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
//    return self.titles.count;
//}
//
//- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
//    if (indexPath.row == 0) {
//       
//        DyFirstCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DyFirstCollectionViewCell" forIndexPath:indexPath];
//        cell.backgroundColor = [UIColor colorWithRed:(arc4random() % 255) / 255.0f green:(arc4random() % 255) / 255.0f blue:(arc4random() % 255) / 255.0f alpha:1.0];
//        
//        return cell;
//    }else{
//          
//        DySecondCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DySecondCollectionViewCell" forIndexPath:indexPath];
//        cell.backgroundColor = [UIColor colorWithRed:(arc4random() % 255) / 255.0f green:(arc4random() % 255) / 255.0f blue:(arc4random() % 255) / 255.0f alpha:1.0];
//        
//        return cell;
//    }
//    
//    
//        return nil;
//
//}
//-(void)creatTheSlideBar{
//    self.automaticallyAdjustsScrollViewInsets = NO;
//    self.view.backgroundColor = [UIColor whiteColor];
//    //主collectionView
//    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
//    layout.minimumInteritemSpacing = layout.minimumLineSpacing = 0;
//    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
//    layout.fullItem = YES;
//    UICollectionView *mainView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
//    mainView.backgroundColor = [UIColor whiteColor];
//    mainView.dataSource = self;
//    mainView.delegate = self;
//    mainView.pagingEnabled = YES;
//    mainView.scrollsToTop = NO;
//    mainView.showsHorizontalScrollIndicator = NO;
//    [mainView registerClass:[DyFirstCollectionViewCell class] forCellWithReuseIdentifier:@"DyFirstCollectionViewCell"];
//     [mainView registerClass:[DySecondCollectionViewCell class] forCellWithReuseIdentifier:@"DySecondCollectionViewCell"];
//    [self.view addSubview:mainView];
//    [mainView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.bottom.equalTo(self.view);
//    }];
//    //catergoryView
//    XWCatergoryView * catergoryView = [XWCatergoryView new];
//    catergoryView.titles = self.titles;
//    catergoryView.scrollView = mainView;
//    catergoryView.delegate = self;
//    catergoryView.titleColor = [UIColor colorWithHexString:@"#424242"];
//    catergoryView.titleSelectColor = [UIColor colorWithHexString:@"#ff5252"];
//    catergoryView.itemSpacing = 15;
//    catergoryView.edgeSpacing = 50*AutoSizeScaleX;
//    //    /**开启背后椭圆*/
//    //    catergoryView.backEllipseEable = YES;
//    //    catergoryView.scrollWithAnimaitonWhenClicked = NO;
//    /**设置默认defaultIndex*/
//    catergoryView.defaultIndex = 1;
//    catergoryView.backgroundColor = [UIColor whiteColor];
//    [self.view addSubview:catergoryView];
////    catergoryView.backgroundColor = [UIColor cyanColor];
//    [catergoryView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.view.mas_left).offset(50);
//        make.right.equalTo(self.view.mas_right).offset(-50);
//        make.top.equalTo(self.view.mas_top).offset(30);
//        make.height.equalTo(@50);
//        make.bottom.equalTo(mainView.mas_top);
//    }];
//
//}
- (void)setNav{
    //导航栏背景颜色
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:@"#ffffff"];
    
    //导航栏字体颜色
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#ff5252"],NSFontAttributeName:[UIFont systemFontOfSize:18]};
   
    
    //中间发布约会
    UILabel *yueLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 35)];
    yueLabel.text = @"视频聊";
    yueLabel.textAlignment = NSTextAlignmentCenter;
    yueLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:18];
    yueLabel.textColor = [UIColor colorWithHexString:@"424242"];
    self.navigationItem.titleView = yueLabel;
    
    
    //右上角筛选按钮
    UIButton *selectBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 25)];
    selectBtn.backgroundColor = [UIColor clearColor];
    
    selectBtn.tintColor=[UIColor whiteColor];
    [selectBtn setImage:[UIImage imageNamed:@"视频icon"] forState:UIControlStateNormal];
    [selectBtn setBackgroundImage:[UIImage imageNamed:@"视频icon"] forState:UIControlStateHighlighted];
    [selectBtn addTarget:self action:@selector(gotoVideoRecordingVCClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:selectBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
  
   

    
}

#pragma mark  ---获取视频功能开关
- (void)getVideoOption{
    
    // NSString *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userId"];
    
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/video/getVideoOption1",REQUESTHEADER] andParameter:nil success:^(id successResponse) {
        
        NSLog(@"0000000000000:%@",successResponse);
        
        
        if ([[NSString stringWithFormat:@"%@",successResponse[@"data"]] isEqualToString:@"1"]) {
            //开启
            
            VideoChatSetingViewController *vc =[[VideoChatSetingViewController alloc]init];
            vc.isOpenSwitv = YES;
            [self.navigationController pushViewController:vc animated:NO];


        }else{
            VideoRecordingVC *vc =[[VideoRecordingVC alloc]init];
            [self.navigationController pushViewController:vc animated:NO];
        }
        
    } andFailure:^(id failureResponse) {
        
        VideoChatSetingViewController *vc =[[VideoChatSetingViewController alloc]init];
        vc.isOpenSwitv = YES;
        [self.navigationController pushViewController:vc animated:NO];

    }];
    
}
-(void)gotoVideoRecordingVCClick{
    [self  isOpenSwitv];
    
}
-(void)isOpenSwitv{
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/video/getUserVideoInstall",REQUESTHEADER] andParameter:@{@"userId":[CommonTool getUserID]} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        WS(weakSelf)
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            if ([[NSString stringWithFormat:@"%@",successResponse[@"data"][@"isVideo"]] isEqualToString:@"1"]) {
                
                VideoRecordingVC *vc =[[VideoRecordingVC alloc]init];
                [self.navigationController pushViewController:vc animated:NO];
            }else{
                
                 [weakSelf getVideoOption];
            }
        } else {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
    
    


}
-(void)gotoSendDyVideoViewControllerClick{
    SendDyVideoViewController *vc =[[SendDyVideoViewController alloc]init];
    vc.urlPath = @"";
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//-(void)resigiterNot{
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getIndex:) name:@"getIndex" object:nil];
//}
//
//- (void)getIndex:(NSNotification *)aNotification{
//    NSIndexPath *indexPath = aNotification.object;
//    
//    NSSet *targets = [navRightBtn allTargets]; //或者使用btn. allTargets获取
//    NSEnumerator *enumerator = [targets objectEnumerator];
//    NSObject *obj = nil;
//    while (obj = [enumerator nextObject])
//        [navRightBtn removeTarget: obj action: @selector(gotoPBJViewControllerClick) forControlEvents: UIControlEventTouchUpInside];//注意：这里要跟addTarget写法一致
//    [navRightBtn removeTarget: obj action: @selector(gotoSendDyVideoViewControllerClick) forControlEvents: UIControlEventTouchUpInside];//注意：这里要跟addTarget写法一致
//    NSLog(@"滑倒了第%zd个item", indexPath.item);
//    if (indexPath.item == 0) {
//        [navRightBtn  setImage:[UIImage imageNamed:@"视频icon"] forState:UIControlStateNormal];
//        [navRightBtn addTarget:self action:@selector(gotoPBJViewControllerClick) forControlEvents:UIControlEventTouchUpInside];
//    }else{
//          [navRightBtn  setImage:[UIImage imageNamed:@"圆圈+号粉色"] forState:UIControlStateNormal];
//        [navRightBtn addTarget:self action:@selector(gotoSendDyVideoViewControllerClick) forControlEvents:UIControlEventTouchUpInside];
//    }
//}
//
//- (void)dealloc {
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"getIndex" object:nil];
//}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
