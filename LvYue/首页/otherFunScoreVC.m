//
//  otherFunScoreVC.m
//  LvYue
//
//  Created by X@Han on 17/1/18.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "otherFunScoreVC.h"
#import "DQStarView.h"
@interface otherFunScoreVC ()<DQStarViewDelegate>{
    NSMutableArray *butArr;
    UIView *blurView;
   // NSString *getGradeStr;//得到评价的标签
    NSString *getGradeNumber;//得到平均分
    NSString *getGradeSum;//得到评价人数
    NSString *gradeStr;//去评价的标签
    NSString *gradeNum;//去评价的分数
   
    
    UILabel *FrendNum;
    UILabel *avaragLabel;
    DQStarView *seeStarView;
}

@end

@implementation otherFunScoreVC

- (void)viewDidLoad {
    [super viewDidLoad];
    gradeStr = @"";
    butArr = [NSMutableArray array];
    [self setContent];
    
    [self setNav];
    
    [self getFriendGrade];
}
-(void)getFriendGrade{
    NSDictionary *dic = @{@"userId":self.userId};
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/getFriendGrade",REQUESTHEADER] andParameter:dic success:^(id successResponse) {
        
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"])  {
            getGradeSum = successResponse[@"data"][@"gradeSum"];//得到评价的人数
            if ([[NSString stringWithFormat:@"%@",getGradeSum]  isEqualToString:@"0"]) {
                FrendNum.text = @"暂未收到别人的评价哦";
                [seeStarView ShowDQStarScoreFunction:0];
                avaragLabel.text = @"评分不足哦";
                
               
                
            }else{
                
                FrendNum.text = [NSString stringWithFormat:@"%@位好友评价了她",getGradeSum];
                
                getGradeNumber = successResponse[@"data"][@"gradeNumber"];//得到评价的分数[NSString stringWithFormat:@"%.1lf",score];
                avaragLabel.text =[NSString stringWithFormat:@"平均分%.1lf分",[getGradeNumber floatValue]] ;
               // getGradeStr = successResponse[@"data"][@"gradeContent"];
                
                [seeStarView ShowDQStarScoreFunction:[getGradeNumber floatValue]];
                
                NSArray *arr = successResponse[@"data"][@"gradeContent"];
                if (arr && arr.count != 0) {
                    [self creatLabel:arr];
                }
                
            }
            
            
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
}

-(void)creatLabel:(NSArray *)arr{
    
        for (int i = 0; i< arr.count; i++) {
            UILabel *label = [[UILabel alloc]init];
            //        label.backgroundColor =[UIColor colorWithHexString:@"#ff5252"];
            label.font  = [UIFont fontWithName:@"PingFangSC-Light" size:14];
            label.textAlignment = NSTextAlignmentCenter;
            label.text = arr[i][@"name"];
            [self.view addSubview:label];
            
            UILabel *roundLabel = [[UILabel alloc]init];
            roundLabel.backgroundColor = [UIColor colorWithHexString:@"#ff5252"];
            roundLabel.font  = [UIFont fontWithName:@"PingFangSC-Light" size:10];
            roundLabel.frame = CGRectMake(64-16, 0, 20, 20);
            roundLabel.textAlignment = NSTextAlignmentCenter;
            roundLabel.layer.cornerRadius = 10.0;
            roundLabel.clipsToBounds = YES;
            roundLabel.text =[NSString stringWithFormat:@"%@",arr[i][@"number"]] ;
            if ([arr[i][@"number"] intValue] >99) {
                roundLabel.text = @"99+";
            }
            [label addSubview:roundLabel];
            
            if (i == 0) {
                label.frame = CGRectMake(SCREEN_WIDTH/2 -32, 160*AutoSizeScaleX, 64, 32*AutoSizeScaleX);
            }
            if (i == 1) {
                label.frame = CGRectMake(SCREEN_WIDTH/2 -120, 190*AutoSizeScaleX, 64, 32*AutoSizeScaleX);
            }
            if (i == 2) {
                label.frame = CGRectMake(SCREEN_WIDTH/2 +36, 190*AutoSizeScaleX, 64, 32*AutoSizeScaleX);
            }
            if (i == 3) {
                label.frame = CGRectMake(SCREEN_WIDTH/2 -100, 260*AutoSizeScaleX, 64, 32*AutoSizeScaleX);
            }
            if (i == 4) {
                label.frame = CGRectMake(SCREEN_WIDTH/2 +16, 260*AutoSizeScaleX, 64, 32*AutoSizeScaleX);
            }
            
            if (i >= 5) {
                return;
            }
        }

   
}
#pragma mark  --内容
- (void)setContent{
    
    FrendNum = [[UILabel alloc]initWithFrame:CGRectMake(50, 24, SCREEN_WIDTH-100, 14)];
    FrendNum.text = @"12位好友评价了他";
    FrendNum.textColor = [UIColor colorWithHexString:@"#757575"];
    FrendNum.textAlignment = NSTextAlignmentCenter;
    FrendNum.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
    [self.view addSubview:FrendNum];
    
//    for (NSInteger i=0; i<4; i++) {
//        
//        CGFloat beginX = (SCREEN_WIDTH-144)/2;
//        UIImageView *heartImage = [[UIImageView alloc]initWithFrame:CGRectMake(beginX+(24+16)*i, 54, 24, 24)];
//        heartImage.tag = 1000+i;
//        heartImage.image= [UIImage imageNamed:@"xixi"];
//        [self.view addSubview:heartImage];
//    }
//    CGFloat beginX = (SCREEN_WIDTH-120)/2;
    seeStarView = [[DQStarView alloc]init];
    seeStarView.frame = CGRectMake((SCREEN_WIDTH-180)/2, 54, 180, 24);
    seeStarView.userInteractionEnabled = NO;
    seeStarView.starTotalCount = 5;
//    seeStarView.delegate = self;
    [self.view addSubview:seeStarView];
    seeStarView.ShowStyle = DQStarShowStyleSliding;
    seeStarView.starSpace = 10;
    [seeStarView ShowDQStarScoreFunction:5];
//    [seeStarView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(self.view.mas_right).with.offset(-16);
//        make.bottom.equalTo(self.view.mas_bottom).with.offset(-8);
//        make.size.mas_equalTo(CGSizeMake(180, 32));
//    }];
    
   avaragLabel = [[UILabel alloc]initWithFrame:CGRectMake(100, 86, SCREEN_WIDTH-200, 16)];
    avaragLabel.text = @"平均分5分";
    avaragLabel.textAlignment = NSTextAlignmentCenter;
    avaragLabel.textColor = [UIColor colorWithHexString:@"#ff5252"];
    avaragLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:16];
    [self.view addSubview:avaragLabel];
    
    #pragma mark 插入
    
    UILabel *firLabel = [[UILabel alloc]init];
    firLabel.tag = 1;
    firLabel.frame = CGRectMake((SCREEN_WIDTH-50)/2, 164*AutoSizeScaleX, 50, 50);
    
    
    UIImageView *headImage = [[UIImageView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-66)/2, 202*AutoSizeScaleX, 66, 66)];
    headImage.layer.cornerRadius = 33;
    headImage.clipsToBounds = YES;
   // headImage.image = [UIImage imageNamed:@"5.jpg"];
    NSURL *headUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,self.userIcon]];
    [headImage sd_setImageWithURL:headUrl];
    [self.view addSubview:headImage];
   

    
    UILabel *bottomLabel = [[UILabel alloc]initWithFrame:CGRectMake(122, 86, SCREEN_WIDTH-244, 16)];
    bottomLabel.translatesAutoresizingMaskIntoConstraints = NO;
    bottomLabel.text = [NSString stringWithFormat:@"%@有一个有趣的灵魂",self.sex];
    bottomLabel.textAlignment = NSTextAlignmentCenter;
    bottomLabel.textColor = [UIColor colorWithHexString:@"#757575"];
    bottomLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
    [self.view addSubview:bottomLabel];
    
    NSString *str = [NSString stringWithFormat:@"H:|-%f-[bottomLabel(==126)]",(SCREEN_WIDTH-126)/2];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat: str options:0 metrics:nil views:NSDictionaryOfVariableBindings(bottomLabel)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bottomLabel(==14)]-116-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(bottomLabel)]];
    
    //评价他
    UIButton *inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    inviteButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:inviteButton];
    NSString *inviteTitle = [NSString stringWithFormat:@"评价%@",self.sex];
    [inviteButton setTitle:inviteTitle forState:UIControlStateNormal];
    inviteButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [inviteButton setTitleColor:[UIColor colorWithHexString:@"#ff5252"] forState:UIControlStateNormal];
    inviteButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [inviteButton addTarget:self action:@selector(opinionOther:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-72-[inviteButton(==80)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(inviteButton)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[inviteButton(==32)]-58-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(inviteButton)]];
    [inviteButton.layer setMasksToBounds:YES];
    [inviteButton.layer setCornerRadius:16];
    [inviteButton.layer setBorderWidth:1];
    
    [inviteButton.layer setBorderColor:[UIColor colorWithHexString:@"#ff5252"].CGColor];
    
    
    //聊一聊
    UIButton *chatButton = [UIButton buttonWithType:UIButtonTypeCustom];
    chatButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:chatButton];
    NSString *chatTitle = @"聊一聊";
    [chatButton setTitle:chatTitle forState:UIControlStateNormal];
     chatButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [chatButton setTitleColor:[UIColor colorWithHexString:@"#ff5252"] forState:UIControlStateNormal];
    chatButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [chatButton addTarget:self action:@selector(chatOther:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[chatButton(==80)]-70-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(chatButton)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[chatButton(==32)]-58-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(chatButton)]];
    [chatButton.layer setMasksToBounds:YES];
    [chatButton.layer setCornerRadius:16];
    [chatButton.layer setBorderWidth:1];
    
    [chatButton.layer setBorderColor:[UIColor colorWithHexString:@"#ff5252"].CGColor];
    
    
}


#pragma mark  --聊一聊
- (void)chatOther:(UIButton *)sender{
    if ([[NSString stringWithFormat:@"%@",self.userId] isEqualToString:[CommonTool getUserID]]) {
    
        return ;
    }else{
    ChatViewController *chatController = [[ChatViewController alloc] initWithChatter:[NSString stringWithFormat:@"qp%@",self.userId]  isGroup:NO] ;
    chatController.title = self.userNickName;
        [self.navigationController pushViewController:chatController animated:YES];
    }
}
#pragma mark  --评价他
- (void)opinionOther:(UIButton *)sender{
    if ([self.userId isEqual:[CommonTool getUserID]]) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode =MBProgressHUDModeText;//显示的模式
        hud.labelText =@"无法自我评价";
        hud.removeFromSuperViewOnHide =YES;
        [hud hide:YES afterDelay:1];
       
    }else{
        
    [self checkFriendGrade];
    
 }
}

-(void)gotoPingJia{
    NSArray *arr = @[@"开朗",@"闷骚",@"火爆",@"安静",@"单纯",@"浪漫",@"善良",@"幽默",@"情商高",@"高冷",@"温暖",@"爱卖萌",@"老司机",@"成熟",@"魅惑",@"会撩"];
    
    
    blurView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    blurView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    [self.view addSubview:blurView];
    
    
    // UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT-198- 160*AutoSizeScaleX,SCREEN_WIDTH,198+ 160*AutoSizeScaleX)];
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT-64-318+32*4-32*4*AutoSizeScaleX,SCREEN_WIDTH,318-32*4+32*4*AutoSizeScaleX)];
    view.backgroundColor = [UIColor whiteColor];
    view.userInteractionEnabled = YES;
    [blurView addSubview:view];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode =MBProgressHUDModeText;//显示的模式
    hud.labelText =@"每个人只能评价一次哦～";
    hud.removeFromSuperViewOnHide =YES;
    [hud hide:YES afterDelay:1];
    
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(24, 20, 70, 14)];
    label.text = @"她的有趣度";
    label.textColor = [UIColor colorWithHexString:@"#424242"];
    label.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [view addSubview:label];
    
    //    for (NSInteger i=0; i<5; i++) {
    //        UIButton *heartBtn = [[UIButton alloc]initWithFrame:CGRectMake(118+(24+8)*i,16, 24,24)];
    //        heartBtn.tag = 1000+i;
    //        [heartBtn setImage:[UIImage imageNamed:@"xixi"] forState:UIControlStateNormal];
    //        [heartBtn addTarget:self action:@selector(getFun:) forControlEvents:UIControlEventTouchUpInside];
    //        [view addSubview:heartBtn];
    //    }
    
    DQStarView *starView = [[DQStarView alloc]init];
    starView.frame = CGRectMake(118, 16, 144, 40);
    starView.starTotalCount = 5;
    starView.delegate = self;
    [view addSubview:starView];
    starView.ShowStyle = DQStarShowStyleSliding;
    if ([CommonTool dx_isNullOrNilWithObject:[NSString stringWithFormat:@"%@",getGradeNumber]] || [[NSString stringWithFormat:@"%@",getGradeSum]  isEqualToString:@"0"]) {
        [seeStarView ShowDQStarScoreFunction:0];
    }else{
        [starView ShowDQStarScoreFunction:[getGradeNumber floatValue]];
    }
    
    UILabel *Melabel = [[UILabel alloc]initWithFrame:CGRectMake(24, 72, 70, 14)];
    Melabel.text = @"我觉得她:";
    Melabel.textColor = [UIColor colorWithHexString:@"#424242"];
    Melabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [view addSubview:Melabel];
    
    for (NSInteger i=0; i<16;i++) {
        CGFloat width = (SCREEN_WIDTH-62)/4;
        CGFloat height = 32*AutoSizeScaleX;
        UIButton *seButton = [UIButton buttonWithType:UIButtonTypeCustom];
        seButton.frame = CGRectMake(16+i%4*(width+10), 102+i/4*(height+8), width, height);
        seButton.tag = 1000+i;
        [seButton setTitle:arr[i] forState:UIControlStateNormal];
        seButton.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];
        
        [seButton setTitleColor:[UIColor colorWithHexString:@"#757575"] forState:UIControlStateNormal];
        seButton.titleLabel.font =[UIFont fontWithName:@"PingFangSC-Light" size:14];
        [seButton setTitleColor:[UIColor colorWithHexString:@"#ff5252"] forState:UIControlStateSelected];
        
        [seButton addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
        seButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [seButton.layer setMasksToBounds:YES];
        [seButton.layer setCornerRadius:2];
        [view addSubview:seButton];
    }
    
    
    
    
    //取消
    UIButton *cancel = [[UIButton alloc]init];
    // cancel.translatesAutoresizingMaskIntoConstraints = NO;
    cancel.titleLabel.textAlignment = NSTextAlignmentCenter;
    cancel.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];
    cancel.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [cancel addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    [cancel setTitle:@"取消" forState:UIControlStateNormal];
    [cancel setTitleColor:[UIColor colorWithHexString:@"#424242"] forState:UIControlStateNormal];
    [view addSubview:cancel];
    //    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[cancel(==48)]-72-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(cancel)]];
    //     [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-294-[cancel(==32)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(cancel)]];
    [cancel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view.mas_right).with.offset(-72);
        make.bottom.equalTo(self.view.mas_bottom).with.offset(-8);
        make.size.mas_equalTo(CGSizeMake(48, 32));
    }];
    
    
    
    //确定
    UIButton *sure = [[UIButton alloc]init];
    //    sure.translatesAutoresizingMaskIntoConstraints = NO;
    sure.titleLabel.textAlignment = NSTextAlignmentCenter;
    sure.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];
    [sure setTitleColor:[UIColor colorWithHexString:@"#ff5252"] forState:UIControlStateNormal];
    sure.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [sure addTarget:self action:@selector(sure:) forControlEvents:UIControlEventTouchUpInside];
    [sure setTitle:@"确定" forState:UIControlStateNormal];
    [view addSubview:sure];
    //    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[sure(==48)]-16-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(sure)]];
    //    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-294-[sure(==32)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(sure)]];
    
    [sure mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view.mas_right).with.offset(-16);
        make.bottom.equalTo(self.view.mas_bottom).with.offset(-8);
        make.size.mas_equalTo(CGSizeMake(48, 32));
    }];
    

}
- (void)starScoreChangFunction:(UIView *)view andScore:(CGFloat)score{
    gradeNum = [NSString stringWithFormat:@"%.1lf",score];
    NSLog(@"评分:%.1lf",score) ;
}
#pragma mark  --确定
- (void)sure:(UIButton *)sender{
    if ([CommonTool dx_isNullOrNilWithObject:gradeNum]) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode =MBProgressHUDModeText;//显示的模式
        hud.labelText =@"请评价下她的有趣度哦～";
        hud.removeFromSuperViewOnHide =YES;
        [hud hide:YES afterDelay:1];
        return;
    }else{
        
        //    if ([CommonTool dx_isNullOrNilWithObject:gradeStr] ==  NO) {
        NSDictionary *dic = @{@"userId":[CommonTool getUserID],@"otherUserId":self.userId,@"gradeContent":gradeStr,@"gradeNumber":gradeNum};
        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/addFriendGrade",REQUESTHEADER]  andParameter:dic success:^(id successResponse) {
            if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
                [sender.superview removeFromSuperview];
                [blurView removeFromSuperview];
                [MBProgressHUD hideHUD];
                [MBProgressHUD showSuccess:@"已收到您的评价"];
            } else {
                [MBProgressHUD hideHUD];
                [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
            }
        } andFailure:^(id failureResponse) {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"服务器繁忙,请重试"];
        }];
        //    }
    }

    
    
}

-(void)checkFriendGrade{
    NSDictionary *dic = @{@"userId":[CommonTool getUserID],@"otherUserId":self.userId};
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/checkFriendGrade",REQUESTHEADER]  andParameter:dic success:^(id successResponse) {
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"300"]) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode =MBProgressHUDModeText;//显示的模式
            hud.labelText =@"您已评价过了哦";
            hud.removeFromSuperViewOnHide =YES;
            [hud hide:YES afterDelay:1];
        } else {
           
            [self gotoPingJia];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];

}
#pragma mark  --取消
- (void)cancel:(UIButton *)sender{
    
    [sender.superview removeFromSuperview];
    [blurView removeFromSuperview];
}

#pragma mark  ----选择别人的性格标签
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
            gradeStr = str;
        }
      
        return;
    }
    if (butArr.count>=5) {
        return;
    }
    
    
    sender.selected = YES;
    UIColor *color = [UIColor colorWithHexString:@"#ff5252"];
    sender.backgroundColor = [color colorWithAlphaComponent:0.3];
    
    
    
    [butArr addObject:sender];
    NSString *str;
    for (NSInteger i =0; i<butArr.count; i++) {
        UIButton *but = butArr[i];
        if (i==0) {
            str = but.currentTitle;
        }else {
            str = [NSString stringWithFormat:@"%@,%@",str,but.currentTitle];
        }
        gradeStr = str;
    }
 
    
    
    
}

#pragma mark  ---点赞她的有趣值
- (void)getFun:(UIButton *)sender{
    
   
    
    
    
    
}

#pragma mark   -------配置导航栏
- (void)setNav{
    self.title = [NSString stringWithFormat:@"%@的有趣度",self.userNickName];
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
    
    
    
}

- (void)goBack{
    
    [self.navigationController popViewControllerAnimated:YES];
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
