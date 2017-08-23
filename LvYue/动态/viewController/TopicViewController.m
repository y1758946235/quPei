//
//  TopicViewController.m
//  LvYue
//
//  Created by X@Han on 17/8/9.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "TopicViewController.h"



#import "JLDragCardView.h"
#import "CardHeader.h"
#import "DyVideoListModel.h"
#import "VideoRecordingVC.h"
#import "LZBVideoPlayer.h"
#define CARD_NUM 3
#define MIN_INFO_NUM 3
#define CARD_SCALE 0.95


@interface TopicViewController()<JLDragCardDelegate,UITableViewDelegate,UITableViewDataSource>{
    NSString * topicStr;
    
    UIView *topBackgrundView;
}

@property (strong, nonatomic)  NSMutableArray *allCards;
@property (assign, nonatomic) CGPoint lastCardCenter;
@property (assign, nonatomic) CGAffineTransform lastCardTransform;
@property (strong, nonatomic) NSMutableArray *sourceObject;
@property (assign, nonatomic) NSInteger page;

@property (strong, nonatomic) UIButton *liekBtn;
@property (strong, nonatomic) UIButton *disLikeBtn;

@property (assign, nonatomic) BOOL flag;

@property (nonatomic, strong) UITableView *myTableView;
@property(nonatomic,copy)NSMutableArray *dataArr;
@property(nonatomic,copy)NSMutableArray *dataBuBianInfoDicArr;

@end


@implementation TopicViewController

- (NSMutableArray *)dataBuBianInfoDicArr{
    if (!_dataBuBianInfoDicArr) {
        _dataBuBianInfoDicArr = [[NSMutableArray alloc]init];
    }
    
    return _dataBuBianInfoDicArr;
}
- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [[NSMutableArray alloc]init];
    }
    
    return _dataArr;
}

-(UITableView *)myTableView {
    if (!_myTableView) {
        _myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,0, SCREEN_WIDTH, SCREEN_HEIGHT-64-40) style:UITableViewStylePlain ];
        [_myTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        _myTableView.delegate = self;
        _myTableView.dataSource = self;
        _myTableView.backgroundColor = [UIColor whiteColor];
        
    }
    
    return _myTableView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewDidDisappear:animated];
   [[LZBVideoPlayer sharedInstance] playWithResume];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
-(void)viewWillDisappear:(BOOL)animated{
     [[LZBVideoPlayer sharedInstance] pause];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    topBackgrundView = [[UIView alloc]init];
    [self.view addSubview:self.myTableView];
    
    
    
    UIButton * partakeBtn = [[UIButton alloc]init];
    partakeBtn.frame  = CGRectMake(0, SCREEN_HEIGHT-64-40, SCREEN_WIDTH, 40);
    partakeBtn.backgroundColor = RGBA(26, 29, 225, 1);
//    partakeBtn.layer.cornerRadius = 20;
//    partakeBtn.clipsToBounds = YES;
//    partakeBtn.layer.borderWidth = 1;
//    partakeBtn.layer.borderColor = [UIColor colorWithHexString:@"#ff5252"].CGColor;
//    [partakeBtn setTitle:@"立即参与" forState:UIControlStateNormal];
//    [partakeBtn setTitleColor:[UIColor colorWithHexString:@"#ff5252"] forState:UIControlStateNormal];
//    partakeBtn.titleLabel.font = kFont15;
    [partakeBtn addTarget:self action:@selector(partakeClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:partakeBtn];
    
    
    UIImageView *partImagV =[[UIImageView alloc]init];
    partImagV.frame = CGRectMake(SCREEN_WIDTH/2 -63, 5, 30, 30);
    partImagV.image = [UIImage imageNamed:@"ic_nearby_micro_video_entry"];
    [partakeBtn addSubview:partImagV];
    
    UILabel *partLabel = [[UILabel alloc]init];
    partLabel.text = @"立即参与";
    partLabel.font = kFont15;
    partLabel.textColor = [UIColor colorWithHexString:@"#ffffff"];
    partLabel.frame = CGRectMake(SCREEN_WIDTH/2 -27, 5, 100, 30);
    [partakeBtn addSubview:partLabel];
    
    topicStr = [[NSString alloc]init];
    topicStr = self.videoSignature;
    self.allCards = [NSMutableArray array];
    self.sourceObject = [NSMutableArray array];
    self.page = 0;
    
//    [self addControls];
//    [self addCards];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self requestSourceData:YES];
    });
    
}


-(void)partakeClick{
    VideoRecordingVC *vc = [[VideoRecordingVC alloc]init];
    vc.selectShareTopicId = self.selectShareTopicId;
    vc.selectShareTopicTitle = self.selectShareTopicTitle;
    vc.isPopToLastVc = YES;
    [self.navigationController pushViewController:vc animated:YES];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    
        return 0.01;
   
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
   
        return 1;
 
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
   
    [cell.contentView addSubview:topBackgrundView];
    for (int i = 0; i<CARD_NUM; i++) {
        
        JLDragCardView *draggableView = [[JLDragCardView alloc]initWithFrame:CGRectMake([[UIScreen mainScreen]bounds].size.width+CARD_WIDTH, self.view.center.y-CARD_HEIGHT/2, CARD_WIDTH, CARD_HEIGHT)];
        
        if (i>0&&i<CARD_NUM-1) {
            draggableView.transform=CGAffineTransformScale(draggableView.transform, pow(CARD_SCALE, i), pow(CARD_SCALE, i));
        }else if(i==CARD_NUM-1){
            draggableView.transform=CGAffineTransformScale(draggableView.transform, pow(CARD_SCALE, i-1), pow(CARD_SCALE, i-1));
        }
        draggableView.transform = CGAffineTransformMakeRotation(ROTATION_ANGLE);
        draggableView.delegate = self;
        
        [_allCards addObject:draggableView];
        if (i==0) {
            draggableView.canPan=YES;
        }else{
            draggableView.canPan=NO;
        }
    }
    
    for (int i=(int)CARD_NUM-1; i>=0; i--){
        [topBackgrundView addSubview:_allCards[i]];
    }

    
//    UIButton *reloadBtn = [UIButton buttonWithType:UIButtonTypeSystem];
//    [reloadBtn setTitle:@"重置" forState:UIControlStateNormal];
//    reloadBtn.frame = CGRectMake(self.view.center.x-25, self.view.frame.size.height-60, 50, 30);
//    [reloadBtn addTarget:self action:@selector(refreshAllCards) forControlEvents:UIControlEventTouchUpInside];
//    [cell.contentView addSubview:reloadBtn];
    
    
    self.disLikeBtn       = [UIButton buttonWithType:UIButtonTypeCustom];
    self.disLikeBtn.frame = CGRectMake(lengthFit(80), CARD_HEIGHT+lengthFit(100), 30, 30);
    [self.disLikeBtn setImage:[UIImage imageNamed:@"dislikeBtn"] forState:UIControlStateNormal];
    [self.disLikeBtn addTarget:self action:@selector(leftButtonClickAction) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:self.disLikeBtn];
    
    self.liekBtn       = [UIButton buttonWithType:UIButtonTypeCustom];
    self.liekBtn.frame = CGRectMake(self.view.frame.size.width-lengthFit(80)-30 , CARD_HEIGHT+lengthFit(100), 30, 30);
    [self.liekBtn setImage:[UIImage imageNamed:@"likeBtn"] forState:UIControlStateNormal];
    [self.liekBtn addTarget:self action:@selector(rightButtonClickAction) forControlEvents:UIControlEventTouchUpInside];
    [topBackgrundView addSubview:self.liekBtn];
    
    UILabel *topicLabel = [[UILabel alloc]init];
    topicLabel.text = topicStr;
    topicLabel.numberOfLines = 0;
//    topicLabel.backgroundColor = [UIColor cyanColor];
    topicLabel.textColor = [UIColor colorWithHexString:@"#424242"];
    topicLabel.font = kFont13;
    [topBackgrundView addSubview:topicLabel];
    CGSize size = [topicStr xw_sizeWithfont:topicLabel.font maxSize:CGSizeMake(SCREEN_WIDTH-60, 400)];
    topicLabel.frame = CGRectMake(30, CARD_HEIGHT+lengthFit(100)+50, SCREEN_WIDTH-60, size.height);
    topBackgrundView.frame = CGRectMake(0, 0, SCREEN_WIDTH,  CARD_HEIGHT+lengthFit(100)+60+size.height+10);
    
    return cell;
}
//设置cell的高度
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
     CGSize size = [topicStr xw_sizeWithfont:kFont13 maxSize:CGSizeMake(SCREEN_WIDTH-60, 400)];
    
    return CARD_HEIGHT+lengthFit(100)+60+size.height+10;

    
    
}



#pragma mark - 添加控件
//-(void)addControls{
//    
//    UIButton *reloadBtn = [UIButton buttonWithType:UIButtonTypeSystem];
//    [reloadBtn setTitle:@"重置" forState:UIControlStateNormal];
//    reloadBtn.frame = CGRectMake(self.view.center.x-25, self.view.frame.size.height-60, 50, 30);
//    [reloadBtn addTarget:self action:@selector(refreshAllCards) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:reloadBtn];
//    
//    
//    self.disLikeBtn       = [UIButton buttonWithType:UIButtonTypeCustom];
//    self.disLikeBtn.frame = CGRectMake(lengthFit(80), CARD_HEIGHT+lengthFit(100), 60, 60);
//    [self.disLikeBtn setImage:[UIImage imageNamed:@"dislikeBtn"] forState:UIControlStateNormal];
//    [self.disLikeBtn addTarget:self action:@selector(leftButtonClickAction) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:self.disLikeBtn];
//    
//    self.liekBtn       = [UIButton buttonWithType:UIButtonTypeCustom];
//    self.liekBtn.frame = CGRectMake(self.view.frame.size.width-lengthFit(80)-60 , CARD_HEIGHT+lengthFit(100), 60, 60);
//    [self.liekBtn setImage:[UIImage imageNamed:@"likeBtn"] forState:UIControlStateNormal];
//    [self.liekBtn addTarget:self action:@selector(rightButtonClickAction) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:self.liekBtn];
//    
//    
//}

#pragma mark - 刷新所有卡片
-(void)refreshAllCards{
    
    self.sourceObject=[@[] mutableCopy];
    self.page = 0;
    
    for (int i=0; i<_allCards.count ;i++) {
        
        JLDragCardView *card=self.allCards[i];
        
        CGPoint finishPoint = CGPointMake(-CARD_WIDTH, 2*PAN_DISTANCE+card.frame.origin.y);
        
        [UIView animateKeyframesWithDuration:0.5 delay:0.06*i options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
            
            card.center = finishPoint;
            card.transform = CGAffineTransformMakeRotation(-ROTATION_ANGLE);
            
        } completion:^(BOOL finished) {
            
            card.yesButton.transform=CGAffineTransformMakeScale(1, 1);
            card.transform = CGAffineTransformMakeRotation(ROTATION_ANGLE);
            card.hidden=YES;
            card.center=CGPointMake([[UIScreen mainScreen]bounds].size.width+CARD_WIDTH, self.view.center.y);
            
            if (i==_allCards.count-1) {
                [self requestSourceData:YES];
            }
        }];
    }
}

#pragma mark - 请求数据


-(void)requestSourceData:(BOOL)needLoad{
    
    /*
     在此添加网络数据请求代码
     */
    
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/video/getUserVideo",REQUESTHEADER] andParameter:@{@"videoTopicId":[NSString stringWithFormat:@"%@",self.selectShareTopicId]} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        [MBProgressHUD hideHUD];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
          
            NSArray *arr =successResponse[@"data"];
            
          
               NSMutableArray *objectArray = [@[] mutableCopy];
            [self.dataArr removeAllObjects];
            [self.dataBuBianInfoDicArr removeAllObjects];
            
            for (NSDictionary * dic in arr) {
                DyVideoListModel *model =[DyVideoListModel createWithModelDic:dic];
                [self.dataArr addObject:model];
                
                  [objectArray addObject:@{@"otherId":[NSString stringWithFormat:@"%@",model.userId],@"videoId":[NSString stringWithFormat:@"%@",model.videoId],@"image":[NSString stringWithFormat:@"%@",model.showUrl],@"headImage":[NSString stringWithFormat:@"%@",model.userIcon],@"shareUrl":[NSString stringWithFormat:@"%@",model.shareUrl],@"userNickname":[NSString stringWithFormat:@"%@",model.userNickname],@"shareSignature":[NSString stringWithFormat:@"%@",model.shareSignature]}];
                
                [self.dataBuBianInfoDicArr addObject:@{@"videoId":[NSString stringWithFormat:@"%@",model.videoId]}];
               
            }
            
            
          
            
           
            [self.sourceObject addObjectsFromArray:objectArray];
          
                self.page++;
                
                //如果只是补充数据则不需要重新load卡片，而若是刷新卡片组则需要重新load
                if (needLoad) {
                    [self loadAllCards];
                }

           
           
          
            
        } else {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
    

    
//    
//    NSMutableArray *objectArray = [@[] mutableCopy];
//    for (int i = 1; i<=self.dataArr.count; i++) {
//        [objectArray addObject:@{@"number":[NSString stringWithFormat:@"%d",self.page*10+i],@"image":[NSString stringWithFormat:@"%d.jpeg",i]}];
//        
//    }
//    
//    [self.sourceObject addObjectsFromArray:objectArray];
//    self.page++;
//    
//    //如果只是补充数据则不需要重新load卡片，而若是刷新卡片组则需要重新load
//    if (needLoad) {
//        [self loadAllCards];
//    }
    
}

#pragma mark - 重新加载卡片
-(void)loadAllCards{
    
    for (int i=0; i<self.allCards.count; i++) {
        JLDragCardView *draggableView=self.allCards[i];
        
        if ([self.sourceObject firstObject]) {
            draggableView.infoDict=[self.sourceObject firstObject];
//            draggableView.infoModel=[self.sourceObject firstObject];
             draggableView.dataArr = self.dataArr;
            draggableView.dataBuBianInfoDicArr = self.dataBuBianInfoDicArr;
            [self.sourceObject removeObjectAtIndex:0];
           
            [draggableView layoutSubviews];
            draggableView.hidden=NO;
        }else{
            draggableView.hidden=YES;//如果没有数据则隐藏卡片
        }
    }
    
    for (int i=0; i<_allCards.count ;i++) {
        
        JLDragCardView *draggableView=self.allCards[i];
        
        CGPoint finishPoint = CGPointMake(self.view.center.x, CARD_HEIGHT/2 + 40);
        
        [UIView animateKeyframesWithDuration:0.5 delay:0.06*i options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
            
            draggableView.center = finishPoint;
            draggableView.transform = CGAffineTransformMakeRotation(0);
            
            if (i>0&&i<CARD_NUM-1) {
                JLDragCardView *preDraggableView=[_allCards objectAtIndex:i-1];
                draggableView.transform=CGAffineTransformScale(draggableView.transform, pow(CARD_SCALE, i), pow(CARD_SCALE, i));
                CGRect frame=draggableView.frame;
                frame.origin.y=preDraggableView.frame.origin.y+(preDraggableView.frame.size.height-frame.size.height)+10*pow(0.7,i);
                draggableView.frame=frame;
                
            }else if (i==CARD_NUM-1) {
                JLDragCardView *preDraggableView=[_allCards objectAtIndex:i-1];
                draggableView.transform=preDraggableView.transform;
                draggableView.frame=preDraggableView.frame;
            }
        } completion:^(BOOL finished) {
            
        }];
        
        draggableView.originalCenter=draggableView.center;
        draggableView.originalTransform=draggableView.transform;
        
        if (i==CARD_NUM-1) {
            self.lastCardCenter=draggableView.center;
            self.lastCardTransform=draggableView.transform;
        }
    }
}

#pragma mark - 首次添加卡片
//-(void)addCards{
//    for (int i = 0; i<CARD_NUM; i++) {
//        
//        JLDragCardView *draggableView = [[JLDragCardView alloc]initWithFrame:CGRectMake([[UIScreen mainScreen]bounds].size.width+CARD_WIDTH, self.view.center.y-CARD_HEIGHT/2, CARD_WIDTH, CARD_HEIGHT)];
//        
//        if (i>0&&i<CARD_NUM-1) {
//            draggableView.transform=CGAffineTransformScale(draggableView.transform, pow(CARD_SCALE, i), pow(CARD_SCALE, i));
//        }else if(i==CARD_NUM-1){
//            draggableView.transform=CGAffineTransformScale(draggableView.transform, pow(CARD_SCALE, i-1), pow(CARD_SCALE, i-1));
//        }
//        draggableView.transform = CGAffineTransformMakeRotation(ROTATION_ANGLE);
//        draggableView.delegate = self;
//        
//        [_allCards addObject:draggableView];
//        if (i==0) {
//            draggableView.canPan=YES;
//        }else{
//            draggableView.canPan=NO;
//        }
//    }
//    
//    for (int i=(int)CARD_NUM-1; i>=0; i--){
//        [self.view addSubview:_allCards[i]];
//    }
//}

#pragma mark - 滑动后续操作
-(void)swipCard:(JLDragCardView *)cardView Direction:(BOOL)isRight {
    
    if (isRight) {
        [self like:cardView.infoDict];
    }else{
        [self unlike:cardView.infoDict];
        
    }
    
    [_allCards removeObject:cardView];
    cardView.transform = self.lastCardTransform;
    cardView.center = self.lastCardCenter;
    cardView.canPan=NO;
//    [self.view insertSubview:cardView belowSubview:[_allCards lastObject]];
     [topBackgrundView insertSubview:cardView belowSubview:[_allCards lastObject]];
    [_allCards addObject:cardView];
    
    if ([self.sourceObject firstObject]!=nil) {
        cardView.infoDict=[self.sourceObject firstObject];
#pragma mark -  cardView.dataArr = self.sourceObject;
        cardView.dataArr = self.dataArr;
        cardView.dataBuBianInfoDicArr = self.dataBuBianInfoDicArr;
        [self.sourceObject removeObjectAtIndex:0];

        [cardView layoutSubviews];
        
        if (self.sourceObject.count<MIN_INFO_NUM) {
            [self requestSourceData:NO];
        }
    }else{
        cardView.hidden=YES;//如果没有数据则隐藏卡片
    }
    
    for (int i = 0; i<CARD_NUM; i++) {
        JLDragCardView*draggableView=[_allCards objectAtIndex:i];
        draggableView.originalCenter=draggableView.center;
        draggableView.originalTransform=draggableView.transform;
        if (i==0) {
            draggableView.canPan=YES;
         
            
        }
       
      
    }
    //        NSLog(@"%d",_sourceObject.count);
}

#pragma mark - 滑动中更改其他卡片位置
-(void)moveCards:(CGFloat)distance{
    
    if (fabs(distance)<=PAN_DISTANCE) {
        for (int i = 1; i<CARD_NUM-1; i++) {
            JLDragCardView *draggableView=_allCards[i];
            JLDragCardView *preDraggableView=[_allCards objectAtIndex:i-1];
            
            draggableView.transform=CGAffineTransformScale(draggableView.originalTransform, 1+(1/CARD_SCALE-1)*fabs(distance/PAN_DISTANCE)*0.6, 1+(1/CARD_SCALE-1)*fabs(distance/PAN_DISTANCE)*0.6);//0.6为缩减因数，使放大速度始终小于卡片移动速度
            
            CGPoint center=draggableView.center;
            center.y=draggableView.originalCenter.y-(draggableView.originalCenter.y-preDraggableView.originalCenter.y)*fabs(distance/PAN_DISTANCE)*0.6;//此处的0.6同上
            draggableView.center=center;
            
            }
    }
    if (distance > 0) {
        self.liekBtn.transform=CGAffineTransformMakeScale(1+0.1*fabs(distance/PAN_DISTANCE), 1+0.1*fabs(distance/PAN_DISTANCE));
    } else {
        self.disLikeBtn.transform=CGAffineTransformMakeScale(1+0.1*fabs(distance/PAN_DISTANCE), 1+0.1*fabs(distance/PAN_DISTANCE));
    }
}

#pragma mark - 滑动终止后复原其他卡片
-(void)moveBackCards{
    for (int i = 1; i<CARD_NUM-1; i++) {
        JLDragCardView *draggableView=_allCards[i];
        [UIView animateWithDuration:RESET_ANIMATION_TIME
                         animations:^{
                             draggableView.transform=draggableView.originalTransform;
                             draggableView.center=draggableView.originalCenter;
                             
                             
                         }];
    }
}

#pragma mark - 滑动后调整其他卡片位置
-(void)adjustOtherCards{
    
    [UIView animateWithDuration:0.2
                     animations:^{
                         for (int i = 1; i<CARD_NUM-1; i++) {
                             JLDragCardView *draggableView=_allCards[i];
                             JLDragCardView *preDraggableView=[_allCards objectAtIndex:i-1];
                             draggableView.transform=preDraggableView.originalTransform;
                             draggableView.center=preDraggableView.originalCenter;
                             
                             
                             if (i == 1) {
                                 [draggableView seeVideo];
                             }
                             
                           

                         }
                     }completion:^(BOOL complete){
                         self.disLikeBtn.transform = CGAffineTransformMakeScale(1, 1);
                         self.liekBtn.transform = CGAffineTransformMakeScale(1, 1);
                     }];
    
}

#pragma mark - 喜欢
-(void)like:(NSDictionary*)userInfo{
    
    /*
     在此添加“喜欢”的后续操作
     */
    
    NSLog(@"like:%@",userInfo[@"otherId"]);
    [self focusClick:userInfo[@"otherId"]];
}
-(void)focusClick:(NSString *)otherId{
    if ([[NSString stringWithFormat:@"%@",otherId] isEqual:[CommonTool getUserID]]) {
        
    }else{
        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/circle/addAttention",REQUESTHEADER] andParameter:@{@"userId":[CommonTool getUserID],@"otherUserId":otherId} success:^(id successResponse) {
            
            if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
               
                
            }
            
        } andFailure:^(id failureResponse) {
            
        }];}
}
#pragma mark - 不喜欢
-(void)unlike:(NSDictionary*)userInfo{
    
    /*
     在此添加“不喜欢”的后续操作
     */
    
    NSLog(@"unlike:%@",userInfo[@"videoId"]);
}



-(void)rightButtonClickAction {
    if (_flag == YES) {
        return;
    }
    _flag = YES;
    JLDragCardView *dragView=self.allCards[0];
    CGPoint finishPoint = CGPointMake([[UIScreen mainScreen]bounds].size.width+CARD_WIDTH*2/3, 2*PAN_DISTANCE+dragView.frame.origin.y);
    [UIView animateWithDuration:CLICK_ANIMATION_TIME
                     animations:^{
                         self.liekBtn.transform = CGAffineTransformMakeScale(1.2, 1.2);
                         dragView.center = finishPoint;
                         dragView.transform = CGAffineTransformMakeRotation(-ROTATION_ANGLE);
                     } completion:^(BOOL finished) {
                         self.liekBtn.transform = CGAffineTransformMakeScale(1, 1);
                         [self swipCard:dragView Direction:YES];
                         _flag = NO;
                     }];
    [self adjustOtherCards];
}
-(void)leftButtonClickAction {
    if (_flag == YES) {
        return;
    }
    _flag = YES;
    JLDragCardView *dragView=self.allCards[0];
    CGPoint finishPoint = CGPointMake(-CARD_WIDTH*2/3, 2*PAN_DISTANCE + dragView.frame.origin.y);
    [UIView animateWithDuration:CLICK_ANIMATION_TIME
                     animations:^{
                         self.disLikeBtn.transform = CGAffineTransformMakeScale(1.2, 1.2);
                         dragView.center = finishPoint;
                         dragView.transform = CGAffineTransformMakeRotation(-ROTATION_ANGLE);
                     } completion:^(BOOL finished) {
                         self.disLikeBtn.transform = CGAffineTransformMakeScale(1, 1);
                         [self swipCard:dragView Direction:NO];
                         _flag = NO;
                     }];
    [self adjustOtherCards];
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
