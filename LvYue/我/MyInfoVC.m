//
//  MyInfoVC.m
//  LvYue
//
//  Created by X@Han on 16/12/6.
//  Copyright © 2016年 OLFT. All rights reserved.
//
#import "changeMyOpinonVC.h"
#import "MyInfoVC.h"
#import "changeInfoVC.h"
#import "myInformationCell.h"
#import "myGoodVC.h"
#import "otherZhuYeVC.h"
#import "LYHttpPoster.h"
#import "MBProgressHUD+NJ.h"
#import "myInformation1Cell.h"
#import "newMyInfoModel.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "LookSexVC.h"
#import "LookLoveVC.h"
#import "LookOtherVC.h"
#import "firstPhotoModel.h"
@interface MyInfoVC ()<UITableViewDelegate,UITableViewDataSource>{
    UITableView *infoTable;
  
    
    newMyInfoModel *infoModel;
    UIView *blurView;//模糊视图
//    NSArray *goodArr;
    NSMutableArray*  resultArr ;  //相册图片数组
    
    NSString *myCerVideoUrl;
    
}
@property (nonatomic,assign)CGFloat secoFirHeight;
@property (nonatomic,assign)CGFloat secoSecoHeight;
@property (nonatomic,assign)CGFloat secoThirHeight;
@end

@implementation MyInfoVC


- (void)viewWillAppear:(BOOL)animated{
    
    [infoTable reloadData];
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    infoTable.estimatedRowHeight = 50.0f;
    infoTable.rowHeight = UITableViewAutomaticDimension;
    [self registNotification];
    [self setNav];
    
    resultArr = [[NSMutableArray alloc]init];
   [self myInfoTable];
    [self getPhotoData];
    [self getData];
    [self  getPersonalVideoAffirm];
   
}

-(void)registNotification{
    //发送通知   跳转页面
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushNotification:) name:@"push" object:nil];
    
    //show
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(pushNotification:) name:@"show" object:nil];
    
    // 监听是否需要刷新数据
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_loadDatagetMyIndex) name:@"reloadDisposition" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(p_loadDatagetMyIndex) name:@"reloadMyAlbum" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(p_loadPersonalInfo) name:@"reloadPersonalInfo" object:nil];
}

-(void)p_loadDatagetMyIndex{
    [self getPhotoData];
}

-(void)p_loadPersonalInfo{
    [self getData];
}
//push通知
- (void)pushNotification:(NSNotification *)noti {
    
    
    if ([[noti.userInfo objectForKey:@"show"] isEqualToString:@"love"]) {
        blurView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
       blurView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
        [self.view addSubview:blurView];
        
        
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 110, SCREEN_WIDTH, 220)];
        view.userInteractionEnabled = YES;
        [self.view addSubview:view];
        view.backgroundColor = [UIColor colorWithHexString:@"#ffffff"];
        view.layer.borderWidth =1;
        view.layer.cornerRadius = 2;
        view.layer.borderColor = [UIColor colorWithHexString:@"#ffffff"].CGColor;
        view.layer.masksToBounds = YES;
        
        UILabel *titlelabel = [[UILabel alloc]initWithFrame:CGRectMake(24, 24, 144, 16)];
        titlelabel.text = @"关于爱情，我想说...";
        titlelabel.textColor = [UIColor colorWithHexString:@"#424242"];
        titlelabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:16];
        [view addSubview:titlelabel];
        
        UILabel *contentLabel = [[UILabel alloc]init];
        contentLabel.translatesAutoresizingMaskIntoConstraints  = NO;
        contentLabel.numberOfLines = 0;
        //contentLabel.text = @"爱情其实就是一种生活。与你爱的人相视一笑，默默牵手走过，无须言语不用承诺。 系上围裙，走进厨房，为你爱的人煲一锅汤，风起的时候为她紧紧衣襟、理理乱发，有雨的日子，拿把伞为她撑起一片晴空。";
        contentLabel.text = infoModel.aboutLove;
        contentLabel.textColor = [UIColor colorWithHexString:@"#757575"];
        contentLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
        [view addSubview:contentLabel];
        [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-24-[contentLabel]-24-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(contentLabel)]];
        [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-56-[contentLabel(==100)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(contentLabel)]];
        
        //关闭
        UIButton *btn = [[UIButton alloc]init];
        btn.translatesAutoresizingMaskIntoConstraints = NO;
        [btn setTitle:@"关闭" forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        [btn setTitleColor:[UIColor colorWithHexString:@"#424242"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:btn];
        
        [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-256-[btn]-16-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(btn)]];
        [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-180-[btn(==32)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(btn)]];
        
        
    }
    
    
    
    if ([[noti.userInfo objectForKey:@"show"] isEqualToString:@"other"]) {
        blurView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
      blurView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
        [self.view addSubview:blurView];
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 110, SCREEN_WIDTH, 220)];
        view.userInteractionEnabled = YES;
        [self.view addSubview:view];
        view.backgroundColor = [UIColor colorWithHexString:@"#ffffff"];
        view.layer.borderWidth =1;
        view.layer.cornerRadius = 2;
        view.layer.borderColor = [UIColor colorWithHexString:@"#ffffff"].CGColor;
        view.layer.masksToBounds = YES;
        
        UILabel *titlelabel = [[UILabel alloc]initWithFrame:CGRectMake(24, 24, 154, 16)];
        titlelabel.text = @"关于另一半，我想说...";
        titlelabel.textColor = [UIColor colorWithHexString:@"#424242"];
        titlelabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:16];
        [view addSubview:titlelabel];
        
        UILabel *contentLabel = [[UILabel alloc]init];
        contentLabel.translatesAutoresizingMaskIntoConstraints  = NO;
        contentLabel.numberOfLines = 0;
        //contentLabel.text = @"爱情其实就是一种生活。与你爱的人相视一笑，默默牵手走过，无须言语不用承诺。 系上围裙，走进厨房，为你爱的人煲一锅汤，风起的时候为她紧紧衣襟、理理乱发，有雨的日子，拿把伞为她撑起一片晴空。";
        contentLabel.text = infoModel.aboutOther;
        contentLabel.textColor = [UIColor colorWithHexString:@"#757575"];
        contentLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
        [view addSubview:contentLabel];
        [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-24-[contentLabel]-24-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(contentLabel)]];
        [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-56-[contentLabel(==100)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(contentLabel)]];
        
        //关闭
        UIButton *btn = [[UIButton alloc]init];
        btn.translatesAutoresizingMaskIntoConstraints = NO;
        [btn setTitle:@"关闭" forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        [btn setTitleColor:[UIColor colorWithHexString:@"#424242"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:btn];
        
        [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-256-[btn]-16-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(btn)]];
        [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-180-[btn(==32)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(btn)]];
        
        
    }
    
    
    if ([[noti.userInfo objectForKey:@"show"] isEqualToString:@"sex"]) {
        blurView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        blurView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
        [self.view addSubview:blurView];
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 110, SCREEN_WIDTH, 220)];
        view.userInteractionEnabled = YES;
        [blurView addSubview:view];
        view.backgroundColor = [UIColor colorWithHexString:@"#ffffff"];
        view.layer.borderWidth =1;
        view.layer.cornerRadius = 2;
        view.layer.borderColor = [UIColor colorWithHexString:@"#ffffff"].CGColor;
        view.layer.masksToBounds = YES;
        
        UILabel *titlelabel = [[UILabel alloc]initWithFrame:CGRectMake(24, 24, 144, 16)];
        titlelabel.text = @"关于性，我想说...";
        titlelabel.textColor = [UIColor colorWithHexString:@"#424242"];
        titlelabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:16];
        [view addSubview:titlelabel];
        
        UILabel *contentLabel = [[UILabel alloc]init];
        contentLabel.translatesAutoresizingMaskIntoConstraints  = NO;
        contentLabel.numberOfLines = 0;
        //contentLabel.text = @"爱情其实就是一种生活。与你爱的人相视一笑，默默牵手走过，无须言语不用承诺。 系上围裙，走进厨房，为你爱的人煲一锅汤，风起的时候为她紧紧衣襟、理理乱发，有雨的日子，拿把伞为她撑起一片晴空。";
        contentLabel.text = infoModel.aboutSex;
        contentLabel.textColor = [UIColor colorWithHexString:@"#757575"];
        contentLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
        [view addSubview:contentLabel];
        [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-24-[contentLabel]-24-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(contentLabel)]];
        [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-56-[contentLabel(==100)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(contentLabel)]];
        
        //关闭
        UIButton *btn = [[UIButton alloc]init];
        btn.translatesAutoresizingMaskIntoConstraints = NO;
        [btn setTitle:@"关闭" forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        [btn setTitleColor:[UIColor colorWithHexString:@"#424242"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:btn];
        
        [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-256-[btn]-16-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(btn)]];
        [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-180-[btn(==32)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(btn)]];
        
   
    }
    
    
    
    
    
    
    if ([[noti.userInfo objectForKey:@"push"] isEqualToString:@"changeMyOpinonVC"]) {
        changeMyOpinonVC *changeVC = [[changeMyOpinonVC alloc]init];
        [self.navigationController pushViewController:changeVC animated:YES];
}
    
    if ([[noti.userInfo objectForKey:@"push"] isEqualToString:@"myGoodVC"]) {
        myGoodVC *goodVC = [[myGoodVC alloc]init];
        [self.navigationController pushViewController:goodVC animated:YES];
    }

    
//    if ([[noti.userInfo objectForKey:@"push"] isEqualToString:@"otherZhuYeVC"]) {
//        otherZhuYeVC *otherVC = [[otherZhuYeVC alloc]init];
//        [self.navigationController pushViewController:otherVC animated:YES];
//    }
    
    
}


#pragma mark  ----关闭爱情等弹出来的界面
- (void)close:(UIButton *)sender{
    
    [blurView removeFromSuperview];
    [sender.superview removeFromSuperview];
    
}

- (void)getData{
    
  NSString *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userId"];
   
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/getPersonalInfo",REQUESTHEADER] andParameter:@{@"userId":userId} success:^(id successResponse) {
        
     // NSLog(@"0000000000000我的资料:%@",successResponse);
        
        
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {


            NSDictionary *dataDic = successResponse[@"data"];
            infoModel = [newMyInfoModel createWithModelDic:dataDic];
            
            [infoTable reloadData];
        }else{
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
        }
        
    } andFailure:^(id failureResponse) {
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
        NSLog(@"失败:%@",failureResponse);
    }];
    
}


- (void)getPhotoData{
   
    //     NSString *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userId"];
    
    [resultArr removeAllObjects];
    //  DLK 内存泄漏修改
    
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/getMyIndex",REQUESTHEADER] andParameter:@{@"userId":[CommonTool getUserID]} success:^(id successResponse) {
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            NSArray*  imageArr = successResponse[@"data"][@"userPhoto"];
            
            for (NSDictionary *dic in imageArr) {
                firstPhotoModel*   model = [firstPhotoModel creModelWithDic:dic];
                [resultArr addObject:model.imageUrl];
            }
            
            [infoTable reloadData];
        }else{
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
        }
        
    } andFailure:^(id failureResponse) {
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
        NSLog(@"失败:%@",failureResponse);
    }];
    
}
#pragma mark   视频认证状态以及地址
-(void)getPersonalVideoAffirm{
   //@"1000001"
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/getPersonalVideoAffirm", REQUESTHEADER] andParameter:@{
                                                                                                                                           @"userId": [CommonTool getUserID]}
                                success:^(id successResponse) {
                                    MLOG(@"是否是视频认证结果:%@", successResponse);
                                    if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
                                        
//                                        if ([[NSString stringWithFormat:@"%@", successResponse[@"data"][@"isAffirm"]] isEqualToString:@"2"] ) {
                                        
                                            myCerVideoUrl =[NSString stringWithFormat:@"%@", successResponse[@"data"][@"userVideo"]];
                                           
                                             [infoTable reloadData];
                                            
//                                        }
                                        
                                    } else {
                                        [MBProgressHUD hideHUD];
                                        [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"errorMsg"]]];
                                    }
                                }
                             andFailure:^(id failureResponse) {
                                 [MBProgressHUD hideHUD];
                                 [MBProgressHUD showError:@"服务器繁忙,请重试"];
                             }];
    
    
}

#pragma mark   ------我的资料内容
- (void)myInfoTable{
    
    infoTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64) style:UITableViewStylePlain];
    infoTable.delegate = self;
    infoTable.dataSource = self;
   // [infoTable registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    infoTable.separatorStyle =NO;
    [self.view addSubview:infoTable];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 1) {
        return 4;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==1) {
       
        if (indexPath.row == 0) {
            return self.secoFirHeight;
        }else if (indexPath.row == 1){
            return self.secoSecoHeight;
        }else{
            return 110;
        }

        
    }else
    {
        return SCREEN_HEIGHT/9*4;
           }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section==1) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 10)];
        return view;
    }else{
        return nil;
   }
   
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
      myInformationCell *cell = [[myInformationCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell" photoArr:resultArr];
        cell.selectionStyle = UITableViewCellAccessoryNone;
//        cell.nickLabel.text = infoModel.nickName;
       
        cell.inrtoduceLabel.text = infoModel.sign;
       
        NSURL *headUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@",[CommonTool getUserIcon]]];
        [cell.headImage sd_setImageWithURL:headUrl];
      
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(changeBigImage:)];
        [cell.headImage addGestureRecognizer:tap];
        
        if ([[NSString stringWithFormat:@"%@",infoModel.sex] isEqualToString:@"1"]) {
            cell.sexImge.image = [UIImage imageNamed:@"female"];
        }
        
        if ([[NSString stringWithFormat:@"%@",infoModel.sex] isEqualToString:@"0"]) {
            cell.sexImge.image = [UIImage imageNamed:@"male"];
        }
        
        [cell.certificationBtn addTarget:self action:@selector(playVideo) forControlEvents:UIControlEventTouchUpInside];
       
            [cell creatMyCerVideoUrl:myCerVideoUrl];
       
        
      return cell;
    }
    
    if (indexPath.section==1) {
         newMyInfoModel *myModel = infoModel;
    myInformation1Cell*  cell = [[myInformation1Cell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell" andIndexPath:indexPath MyModel:myModel goodArr:myModel.userGoodAtArr];
        cell.selectionStyle = UITableViewCellAccessoryNone;
        cell.clipsToBounds= YES;
        self.secoFirHeight = cell.secoFirHeight;
        self.secoSecoHeight = cell.secoSecoHeight;
      
//       //我  -----
//        cell.ageLabel.text = [NSString stringWithFormat:@"%@岁",infoModel.age];
//        cell.heightLabel.text = [NSString stringWithFormat:@"%@cm",infoModel.height];
//        cell.colleaLabel.text = infoModel.constelation;
//        cell.workLabel.text = infoModel.work;
//        cell.weightLabel.text = [NSString stringWithFormat:@"%@kg",infoModel.weight];
//        cell.eduLabel.text = infoModel.edu;
        
               
        
    // cell.cityLabel.text = [NSString stringWithFormat:@"%@%@",infoModel.dateProvince,infoModel.dateCity];
   
        
        
        
        return cell;
    }
    
    static NSString *CellID=@"Cell";
    UITableViewCell *Cell=[tableView dequeueReusableCellWithIdentifier:CellID];
    if (!Cell) {
        Cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellID];
        
    }
    return Cell;
}

#pragma mark  ---- 点按进入大图模式  长按保存  点按回去小图模式
- (void)changeBigImage:(UITapGestureRecognizer *)tap{

    
    JJPhotoBowserViewController *photoBowserViewController = [[JJPhotoBowserViewController alloc]init];
    //给大图的数据源
    photoBowserViewController.imageData = @[[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,infoModel.headImage]]];
    photoBowserViewController.isCircle = NO;
    //获得当前点击的图片索引
    //    NSInteger index = 0;
    [photoBowserViewController showImageWithIndex:0 andCount:1];
}
#pragma mark   视频认证状态以及地址
-(void)playVideo{
    // http://7xlcz5.com2.z0.glb.qiniucdn.com/iosLvYueVideo201742416169/\U5f62\U8c61\U89c6\U9891.mp4
    WS(weakSelf)
    MPMoviePlayerViewController *player = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", IMAGEHEADER, myCerVideoUrl]]];
    player.moviePlayer.shouldAutoplay   = YES;
    [weakSelf presentMoviePlayerViewControllerAnimated:player];
}
#pragma mark   -------配置导航栏
- (void)setNav{
    self.title = @"我的资料";
    //导航栏title的颜色
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithHexString:@"#424242"],UITextAttributeTextColor, [UIFont fontWithName:@"PingFangSC-Medium" size:18],UITextAttributeFont, nil]];
     self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:@"#ffffff"];
    //导航栏返回按钮
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(16, 38, 28, 14)];
    [button setTitleColor:[UIColor colorWithHexString:@"#424242"] forState:UIControlStateNormal];
    [button setTitle:@"返回" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [button addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = back;
    
    //导航栏编辑按钮
    UIButton *edit = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-16-28, 38, 28, 14)];
    [edit setTitleColor:[UIColor colorWithHexString:@"#ff5252"] forState:UIControlStateNormal];
    [edit setTitle:@"编辑" forState:UIControlStateNormal];
    edit.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [edit addTarget:self action:@selector(edit) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *edited = [[UIBarButtonItem alloc]initWithCustomView:edit];
    self.navigationItem.rightBarButtonItem = edited;
    
}

- (void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark   ----- 编辑页面
- (void)edit{
    
    changeInfoVC *changeVc = [[changeInfoVC alloc]init];
    [self.navigationController pushViewController:changeVc animated:YES];
    
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"push" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"reloadDisposition" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"show" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"reloadMyAlbum" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"reloadPersonalInfo" object:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
