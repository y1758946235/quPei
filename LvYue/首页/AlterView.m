//
//  AlterView.m
//  LvYue
//
//  Created by X@Han on 17/4/11.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "AlterView.h"
#import "UserPoolCollectionViewCell.h"
#import "UserModel.h"
#import "ChatSendHelper.h"

@interface AlterView()<UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>{
    UICollectionView *cView;
  
    CGFloat cellWidth;
    NSMutableArray *userPushDataArr;
    NSMutableArray *userIdSelectArr;
    NSString *otherIdStr;
    
    NSArray *arr;
    NSString *testMessageStr;//打招呼的消息
    
    UIButton *_lastBtn;
    
  
}

@end
@implementation AlterView 

//- (NSMutableArray *)dataArr{
//    if (!self.dataArr) {
//        self.dataArr = [[NSMutableArray alloc]init];
//    }
//    
//    return self.dataArr;
//}

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        _typeUser = [[NSString alloc]init];
        //高斯模糊
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
        effectView.frame = CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT-64);
        [self addSubview:effectView];
        [self setCollectionView];
        userPushDataArr= [NSMutableArray array];
        userIdSelectArr = [NSMutableArray array];
        otherIdStr = [[NSString alloc]init];
        
      
    }
    return self;
    
}

- (void)setCollectionView{
   
    
    
    cellWidth = (SCREEN_WIDTH-32)/3;
    UICollectionViewFlowLayout *layOut = [[UICollectionViewFlowLayout alloc]init];
    layOut.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    cView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 54+64, SCREEN_WIDTH, SCREEN_HEIGHT-64-54-54) collectionViewLayout:layOut];
    cView.backgroundColor = [UIColor colorWithHexString:@"#ffffff"];
    //collection头视图的注册   奇葩的地方来了，头视图也得注册
    [cView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter  withReuseIdentifier:@"footCell"];
    [cView registerClass:[UserPoolCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    cView.dataSource = self;
    cView.delegate = self;
    
    [self addSubview:cView];
    
    
    UIButton *tiaoguoBtn = [[UIButton alloc]init];
    tiaoguoBtn.frame = CGRectMake(SCREEN_WIDTH-70, 64, 46, 40);
    [tiaoguoBtn setTitle:@"跳过" forState:UIControlStateNormal];
    [tiaoguoBtn setTitleColor:[UIColor colorWithHexString:@"#424242"] forState:UIControlStateNormal];
    tiaoguoBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [self addSubview:tiaoguoBtn];
    [tiaoguoBtn addTarget:self action:@selector(tiaoGuoClick) forControlEvents:UIControlEventTouchUpInside];
     
    
}

-(void)tiaoGuoClick{
    [self removeAlview];
}
-(void)liaoClick{
   
    [cView removeFromSuperview];
    
    if (userIdSelectArr.count == 0) {
        [self removeFromSuperview];
        return;
    }else{
        
        for (int i = 0; i <userIdSelectArr.count; i ++) {
        
            if (i==0) {
                otherIdStr = userIdSelectArr[0];
            }else {
                otherIdStr = [NSString stringWithFormat:@"%@,%@",otherIdStr,userIdSelectArr[i]];
            }
        }
        
        [self creatTestMessageView];}
   
}
-(void)creatTestMessageView{
    UIView * testMessageView = [[UIView alloc]init];
    testMessageView.frame = CGRectMake(SCREEN_WIDTH/2 -140, 96+64, 280, 248);
    [self addSubview:testMessageView];
    
    UILabel *titLabel = [[UILabel alloc]init];
    titLabel.frame = CGRectMake(24, 24, 180, 16);
    titLabel.text = @"请选择一条打招呼消息";
    titLabel.textAlignment = NSTextAlignmentLeft;
    titLabel.textColor = [UIColor colorWithHexString:@"#424242"];
    titLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:16];
    [testMessageView addSubview:titLabel];
    
   arr = @[@"你好~",@"你在干嘛",@"你这么好看，愿意和我做朋友吗?"];
    for (int i = 0; i < arr.count; i++) {
        UIButton *testBtn = [[UIButton alloc]init];
        testBtn.frame = CGRectMake(32, 62 + 48*i, 216, 20);
        testBtn.tag = 1000+i;
       // testBtn.titleLabel.textAlignment = NSTextAlignmentLeft;这句无效
        testBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//        testBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        [testBtn setTitle:arr[i] forState:UIControlStateNormal];
        [testBtn setTitleColor:[UIColor colorWithHexString:@"#757575"] forState:UIControlStateNormal];
        [testBtn setTitleColor:[UIColor colorWithHexString:@"#ff5252"] forState:UIControlStateSelected];
        testBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
        [testMessageView addSubview:testBtn];
        
        [testBtn addTarget:self action:@selector(selectTest:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    UIButton *sendBtn = [[UIButton alloc]init];
    sendBtn.frame = CGRectMake(224, 208, 48, 32);
    sendBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    [sendBtn setTitleColor:[UIColor colorWithHexString:@"#ff5252"] forState:UIControlStateNormal];
    sendBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
    [testMessageView addSubview:sendBtn];
    
    [sendBtn addTarget:self action:@selector(sendTest) forControlEvents:UIControlEventTouchUpInside];
}

-(void)selectTest:(UIButton *)sender{
    testMessageStr =arr[sender.tag-1000];
    
    if (sender == _lastBtn)
    {
        return;
    }
    sender.selected = YES;
    _lastBtn.selected = NO;
    _lastBtn = sender;
    
}
-(void)sendTest{
    
 


    
    if ([CommonTool dx_isNullOrNilWithObject:testMessageStr]) {
        
        [MBProgressHUD showError:@"请选择一条打招呼消息"];
        return;
    }
    
    NSDictionary *ext =  @{@"avatar":[CommonTool getUserIcon],@"nick":[CommonTool getUserNickname]};
    
    
    for (NSInteger i =0; i<userIdSelectArr.count; i++) {
        
        
        //一键发送消息
        EMConversation *conversation = [[EaseMob sharedInstance].chatManager conversationForChatter:[NSString stringWithFormat:@"qp%@",userIdSelectArr[i]] conversationType:eConversationTypeChat];
        [ChatSendHelper sendTextMessageWithString:testMessageStr
                                       toUsername:conversation.chatter
                                      messageType:eMessageTypeChat
                                requireEncryption:NO
                                              ext:ext];
        
       
        
    }
   
   
    
    [self addAttentionOrRecordArr];
    
    
    
}

-(void)addAttentionOrRecordArr{
  WS(weakSelf)
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/circle/addAttentionOrRecordArr",REQUESTHEADER] andParameter:@{@"userId":[CommonTool getUserID],@"otherUserIdArr":otherIdStr} success:^(id successResponse) {
        
        // NSLog(@"0000000000000我的资料:%@",successResponse);
        
        
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
           
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
            hud.mode =MBProgressHUDModeText;//显示的模式
            hud.detailsLabelText = @"已帮您一键关注他们，请去消息界面查看他们的主页吧!";
            [hud hide:YES afterDelay:1];
            //设置隐藏的时候是否从父视图中移除，默认是NO
            hud.removeFromSuperViewOnHide = YES;
           [weakSelf performSelector:@selector(removeAlview) withObject:weakSelf afterDelay:1];
            
        }else{
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
        }
        
    } andFailure:^(id failureResponse) {
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
        NSLog(@"失败:%@",failureResponse);
    }];

}
-(void)removeAlview{
    [self removeFromSuperview];
}
//#pragma mark   -----加载更多的数据
//- (void)addRefresh{
//    
//   
//    
//    
//    //下拉刷新
//    cView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefreshing)];
//    
//    
//    //上拉加载更多
//    
//    cView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRefreshing)];
//    
//}
//
//
//
//#pragma mark   ----下拉刷新
//- (void)headerRefreshing{
//    
//    
//    
//    
//    MJRefreshStateHeader *header = (MJRefreshStateHeader *) cView.mj_header;
//    [header setTitle:@"下拉可以刷新" forState:MJRefreshStateIdle];
//    [header setTitle:@"松开马上刷新" forState:MJRefreshStatePulling];
//    [header setTitle:@"刷新中" forState:MJRefreshStateRefreshing];
//    
//    
//    currentPage = 1;
//    
//    NSDictionary * dic = @{@"pageNum":[NSString stringWithFormat:@"%ld",(long)currentPage],@"userSex":self.userSex,@"userAgeBegin":self.beginUserAge,@"userAgeEnd":self.endUserAge};
//    [self getFriendsDataNsdic:dic];
//    
//    [cView.mj_header endRefreshing];
//}


//#pragma mark   ----上拉加载更多
//- (void)footerRefreshing{
//    
//    
//    //分页信息
//    //    if (type == UserLoginStateTypeWaitToLogin) {
//    //        NSInteger page = 1;
//    //        if (isNew) {
//    //            currentPage++;
//    //            page = currentPage;
//    //        } else {
//    //           page1++;
//    //            page = page1;
//    //        }
//    currentPage ++;
//    
//    if (self.dataArr.count != 0) {
//        UserModel *model = self.dataArr[0];
//        firUserId = model.userId;
//    }
//    
//    
//    NSDictionary * dic = @{@"pageNum":[NSString stringWithFormat:@"%ld",(long)currentPage],@"userIdFirst":firUserId,@"userSex":self.userSex,@"userAgeBegin":self.beginUserAge,@"userAgeEnd":self.endUserAge};
//    [self getMoreFriendsDataNsdic:dic];
//    [cView.mj_footer endRefreshing];
//    
//}
////获上啦加载数据
//-(void)getMoreFriendsDataNsdic:(NSDictionary*)Dic{
//    
//    [LYHttpPoster requestUserChiWithParameters:Dic Block:^(NSMutableArray *arr) {
//        
//        if (arr == nil) {
//            currentPage --;
//            return ;
//        }else{
//            [self.dataArr addObjectsFromArray:arr];
//            if (arr.count == 0) {
//                currentPage --;
//                [MBProgressHUD showSuccess:@"已经到底啦"];
//            }
//            [cView reloadData];
//        }
//    }];
//    
//}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return userPushDataArr.count;
    
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
    
    UserPoolCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    UserModel *aModel = userPushDataArr[indexPath.row];
    
    NSURL *headUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,aModel.dateImage]];
    
    [cell.photoImage sd_setImageWithURL:headUrl];
    
    cell.heartImageBtn.tag = 1000 +indexPath.row;
    [cell.heartImageBtn addTarget:self action:@selector(clickHeart:) forControlEvents:UIControlEventTouchUpInside];
    
    
    cell.nickLabel.text = aModel.nick;
    cell.ageLabel.text = [NSString stringWithFormat:@"%@岁",aModel.agel];
    
    
    return cell;
}
-(void)clickHeart:(UIButton *)sender{
    sender.selected = !sender.selected;
    UserModel *model = userPushDataArr[sender.tag-1000];
    if (sender.selected) {
        [userIdSelectArr removeObject:model.userId];
    }else{
       [userIdSelectArr addObject:model.userId];
    }
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    return CGSizeMake(SCREEN_WIDTH, 84);
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableview = nil;
  
    if ([kind isEqualToString: UICollectionElementKindSectionFooter]) {
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footCell" forIndexPath:indexPath];
        UIButton *liaoBtn = [[UIButton alloc]init];
        liaoBtn.frame = CGRectMake(SCREEN_WIDTH/2 -60, 24, 120, 36);
        liaoBtn.layer.cornerRadius = 18;
        liaoBtn.clipsToBounds = YES;
        liaoBtn.backgroundColor = [UIColor colorWithHexString:@"#ff5252"];
        [liaoBtn setTitle:@"一键开撩" forState:UIControlStateNormal];
        [liaoBtn setTitleColor:[UIColor colorWithHexString:@"#ffffff"] forState:UIControlStateNormal];
        [headerView addSubview:liaoBtn];
        //    self.liaoBtn = liaoBtn;
        [liaoBtn addTarget:self action:@selector(liaoClick) forControlEvents:UIControlEventTouchUpInside];
        reusableview = headerView;
    }
    return reusableview;
    
}
#pragma mark  --点头像进入个人主页
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
//    
//    UserModel *model = self.dataArr[indexPath.item];
//    otherZhuYeVC *other = [[otherZhuYeVC alloc]init];
//    other.userId = model.userId;
//    other.userNickName = model.nick;
//    [self.navigationController pushViewController:other animated:YES];
    
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
    return CGSizeMake(cellWidth, cellWidth);
    
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    return UIEdgeInsetsMake(8, 8, 0, 8);
    
}
-(void)creatDataArr:(NSMutableArray *)dataArr{
    if (dataArr && dataArr.count > 0) {
        [userPushDataArr addObjectsFromArray:dataArr];
        cView.frame =   CGRectMake(0, 54+64, SCREEN_WIDTH, cellWidth+8+84+(cellWidth+8)*((userPushDataArr.count-1)/3 ));
        if (userPushDataArr.count > 9) {
            cView.frame =   CGRectMake(0, 54+64, SCREEN_WIDTH, cellWidth+8+84+(cellWidth+8)*2);
        }
        
        for (UserModel *model  in userPushDataArr) {
            [userIdSelectArr addObject:model.userId];
        }
        [cView reloadData];
        
    }
    
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
