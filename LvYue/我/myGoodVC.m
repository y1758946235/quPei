//
//  myGoodVC.m
//  LvYue
//
//  Created by X@Han on 16/12/7.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "myGoodVC.h"
#import "LYHttpPoster.h"
#import "MBProgressHUD+NJ.h"
#import "MoneyHeadCollectionReusableView.h"
@interface myGoodVC ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>{
    NSArray *titleArr;
    UIButton *seButton;
    UITextField *tf;
    NSInteger num;
    NSMutableArray *butArr;
    
//    NSArray *hobbiesArr;
//    NSArray *sportsArr;
    UICollectionView *_MyCollectionView;
    UIButton *goodsBtn;
    
    NSString *goodsAt;
}

@end

@implementation myGoodVC

- (void)viewDidLoad {
    [super viewDidLoad];
   //初始化按钮数组
    butArr = [NSMutableArray array];
    
    titleArr = @[@"摄影",@"游泳",@"化妆",@"魔术",@"驾驶",@"瑜伽",@"英语",@"日语",@"韩语",@"期货",@"涂鸦",@"美甲",@"K歌",@"舞蹈",@"弹钢琴",@"羽毛球",@"小语种",@"PS照片",@"烹饪美食",@"健身指导",@"烹饪美食",@"高尔夫球",@"心理辅导",@"户外探险",@"修电脑",@"越狱刷机",@"手机贴膜",@"iOS编程",@"安卓编程",@"造型设计",@"股票投资",@"企业经营"];

    [self setNav];
    
//    [self setContent];
    [self createCollectionView];
}
- (void)createCollectionView {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    
    // 1.设置列间距
    flowLayout.minimumInteritemSpacing = 8;
    // 2.设置行间距
    flowLayout.minimumLineSpacing = 11;
    // 5.设置布局方向
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    _MyCollectionView                      = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 16, SCREEN_WIDTH , SCREEN_HEIGHT -16) collectionViewLayout:flowLayout];
    _MyCollectionView.delegate             = self;
    _MyCollectionView.dataSource           = self;
    _MyCollectionView.backgroundColor      = [UIColor whiteColor];
    _MyCollectionView.alwaysBounceVertical = YES;
    _MyCollectionView.scrollEnabled = NO;//禁止滑动
    //collection头视图的注册   奇葩的地方来了，头视图也得注册
    [_MyCollectionView registerClass:[MoneyHeadCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader  withReuseIdentifier:@"headCell"];
    [_MyCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell" ];
    [self.view addSubview:_MyCollectionView];
}
#pragma mark - UICollectionDelegate,UICollevtiondataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return titleArr.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
//    cell.backgroundColor = [UIColor cyanColor];
    goodsBtn = [[UIButton alloc]init];
    goodsBtn.frame = CGRectMake(0, 0, (SCREEN_WIDTH-55)/4, 32*AutoSizeScaleX);
    [goodsBtn setTitle:titleArr[indexPath.row] forState:UIControlStateNormal];
    [goodsBtn setTitleColor:[UIColor colorWithHexString:@"#757575"] forState:UIControlStateNormal];
    goodsBtn.titleLabel.font =[UIFont fontWithName:@"PingFangSC-Light" size:14];
    [goodsBtn setTitleColor:[UIColor colorWithHexString:@"#ff5252"] forState:UIControlStateSelected];
    [goodsBtn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    goodsBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [goodsBtn.layer setMasksToBounds:YES];
    [goodsBtn.layer setCornerRadius:2];
    [cell.contentView addSubview:goodsBtn];
    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeMake(SCREEN_WIDTH, 0);
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    return CGSizeMake(SCREEN_WIDTH, 0);
}

//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
//    UICollectionReusableView *reusableview = nil;
//    NSArray *rightArr = @[@"兴趣爱好"];
//    if ([kind isEqualToString: UICollectionElementKindSectionHeader]) {
//        MoneyHeadCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headCell" forIndexPath:indexPath];
//       
//        headerView.stateLabel.text =  rightArr[indexPath.section];
//       
//        reusableview = headerView;
//    }
//    
//    return reusableview;
//    
//}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
}
//设定全局的Cell尺寸，如果想要单独定义某个Cell的尺寸，可以使用下面方法：
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((SCREEN_WIDTH-55)/4, 32*AutoSizeScaleX);
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(8, 11, 0 , 11);
    
}

- (void)setContent{
    
    tf = [[UITextField alloc]initWithFrame:CGRectMake(50, 74, SCREEN_WIDTH-100, 30)];
    tf.userInteractionEnabled = NO;//禁止编辑
    tf.textColor = [UIColor colorWithHexString:@"#424242"];
    tf.backgroundColor = [UIColor colorWithHexString:@"#757575"];
    tf.placeholder = @"您的擅长...";
    tf.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
    [self.view addSubview:tf];
   
    
//    for (NSInteger i=0; i<32;i++) {
//        CGFloat width = (SCREEN_WIDTH-62)/4;
//        CGFloat height = width/2;
//       seButton = [UIButton buttonWithType:UIButtonTypeCustom];
//       seButton.frame = CGRectMake(16+i%4*(width+10), 120+i/4*(height+8), width, height);
//        seButton.tag = 1000+i;
//        [seButton setTitle:titleArr[i] forState:UIControlStateNormal];
//        seButton.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];
//        
//        [seButton setTitleColor:[UIColor colorWithHexString:@"#757575"] forState:UIControlStateNormal];
//        seButton.titleLabel.font =[UIFont fontWithName:@"PingFangSC-Light" size:14];
//        [seButton setTitleColor:[UIColor colorWithHexString:@"#ff5252"] forState:UIControlStateSelected];
//       
//       [seButton addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
//        seButton.titleLabel.textAlignment = NSTextAlignmentCenter;
//        [seButton.layer setMasksToBounds:YES];
//        [seButton.layer setCornerRadius:2];
//        [self.view addSubview:seButton];
//    }
    
}



#pragma mark  -----选中状态  多选

- (void)click:(UIButton *)sender{
    
    

    if (sender.selected) {
        
        sender.selected = NO;
        
        sender.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];
        
        [butArr removeObject:sender];
        NSString *str;
        for (NSInteger i =0; i<butArr.count; i++) {
            UIButton *but = butArr[i];
            if (i==0) {
                str = but.currentTitle;
            }else {
                str = [NSString stringWithFormat:@"%@,%@",str,but.currentTitle];
            }
            
        }
        goodsAt = str;
        return;
    }
    if (butArr.count>=5) {
        [MBProgressHUD  showSuccess:@"最多选五个"];
        return;
    }
    
    
    sender.selected = YES;
    UIColor *color = [UIColor colorWithHexString:@"#ff5252"];
    sender.backgroundColor = [color colorWithAlphaComponent:0.1];
    

    
    [butArr addObject:sender];
    NSString *str;
    for (NSInteger i =0; i<butArr.count; i++) {
        UIButton *but = butArr[i];
        if (i==0) {
            str = but.currentTitle;
        }else {
            str = [NSString stringWithFormat:@"%@,%@",str,but.currentTitle];
        }
        
    }
    goodsAt = str;

    
}

#pragma mark   -------配置导航栏
- (void)setNav{
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"我的擅长";
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:@"#ffffff"];
    //导航栏title的颜色
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithHexString:@"#424242"],UITextAttributeTextColor, [UIFont fontWithName:@"PingFangSC-Medium" size:18],UITextAttributeFont, nil]];
    
    //导航栏返回按钮
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(16, 38, 28, 14)];
    [button setTitleColor:[UIColor colorWithHexString:@"#424242"] forState:UIControlStateNormal];
    [button setTitle:@"返回" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = back;
    
    //导航栏保存按钮
    UIButton *edit = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-16-28, 38, 28, 14)];
    [edit setTitleColor:[UIColor colorWithHexString:@"#ff5252"] forState:UIControlStateNormal];
    [edit setTitle:@"保存" forState:UIControlStateNormal];
    edit.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [edit addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *edited = [[UIBarButtonItem alloc]initWithCustomView:edit];
    self.navigationItem.rightBarButtonItem = edited;
    
}

//返回
- (void)back{
    
    [self.navigationController popViewControllerAnimated:YES];
}

//保存
- (void)save{
    
    if ([CommonTool dx_isNullOrNilWithObject:goodsAt]) {
        [MBProgressHUD showError:@"请选择我的擅长"];
        return;
    }
      NSString *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userId"];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/updatePersonalInfo",REQUESTHEADER] andParameter:@{@"userId":userId,@"userGoodAt":goodsAt} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        [MBProgressHUD hideHUD];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadPersonalInfo" object:nil userInfo:nil];
            [self.navigationController popViewControllerAnimated:YES];
            [MBProgressHUD showSuccess:@"修改成功"];
            
        } else {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
    
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
