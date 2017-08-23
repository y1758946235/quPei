//
//  myFunScoreVC.m
//  LvYue
//
//  Created by X@Han on 17/1/17.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "myFunScoreVC.h"
#import "UIImageView+WebCache.h"
#import "DQStarView.h"
#import "WhoEvaluationMeVC.h"
@interface myFunScoreVC (){
    NSString * gradeNumber ;//评价平均分数(Double)
    NSString *  gradeSum;//评价人数(Integer)
    UIButton *FrendNum;
    UILabel *avaragLabel;
    
    DQStarView *seeStarView;
   
}


@end

@implementation myFunScoreVC

- (void)viewDidLoad {
    [super viewDidLoad];
    gradeNumber = [[NSString alloc]init];
    gradeSum = [[NSString alloc]init];
    [self setNav];

    [self setContent];
    [self getFriendGrade];
   
}

#pragma mark  --内容
- (void)setContent{
    
    FrendNum = [[UIButton alloc]initWithFrame:CGRectMake(50, 16, SCREEN_WIDTH-100, 30)];
//    FrendNum.text = @"12位好友评价了我";
    [FrendNum addTarget:self action:@selector(lookFrend) forControlEvents:UIControlEventTouchUpInside];
    FrendNum.userInteractionEnabled = NO;
    FrendNum.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [FrendNum setTitleColor:[UIColor colorWithHexString:@"#757575"] forState:UIControlStateNormal];
    FrendNum.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
    [self.view addSubview:FrendNum];
    
//    for (NSInteger i=0; i<4; i++) {
//        
//        CGFloat beginX = (SCREEN_WIDTH-144)/2;
//        UIImageView *heartImage = [[UIImageView alloc]initWithFrame:CGRectMake(beginX+(24+16)*i, 54, 24, 24)];
//        heartImage.tag = 1000+i;
//        heartImage.image= [UIImage imageNamed:@"xixi"];
//        [self.view addSubview:heartImage];
//    }
    seeStarView = [[DQStarView alloc]init];
    seeStarView.frame = CGRectMake((SCREEN_WIDTH-180)/2, 54, 180, 24);
    seeStarView.userInteractionEnabled = NO;
    seeStarView.starTotalCount = 5;
    //    seeStarView.delegate = self;
    [self.view addSubview:seeStarView];
    seeStarView.ShowStyle = DQStarShowStyleSliding;
    seeStarView.starSpace = 10;
    [seeStarView ShowDQStarScoreFunction:5];

    
    avaragLabel = [[UILabel alloc]initWithFrame:CGRectMake(100, 86, SCREEN_WIDTH-200, 16)];
//    avaragLabel.text = @"平均分7分";
    avaragLabel.textAlignment = NSTextAlignmentCenter;
    avaragLabel.textColor = [UIColor colorWithHexString:@"#ff5252"];
    avaragLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:16];
    [self.view addSubview:avaragLabel];
    
    
    UIImageView *headImage = [[UIImageView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-66)/2, 202*AutoSizeScaleX, 66, 66)];
    headImage.layer.cornerRadius = 33;
    headImage.clipsToBounds = YES;
//    headImage.image = [UIImage imageNamed:@"5.jpg"];
    [headImage sd_setImageWithURL:[NSURL URLWithString:[CommonTool getUserIcon]]];
    [self.view addSubview:headImage];
    
    
    UILabel *bottomLabel = [[UILabel alloc]initWithFrame:CGRectMake(122, 86, SCREEN_WIDTH-244, 16)];
    bottomLabel.translatesAutoresizingMaskIntoConstraints = NO;
    bottomLabel.text = @"我有一个有趣的灵魂";
    bottomLabel.textAlignment = NSTextAlignmentCenter;
    bottomLabel.textColor = [UIColor colorWithHexString:@"#757575"];
    bottomLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
    [self.view addSubview:bottomLabel];
    
   NSString *str = [NSString stringWithFormat:@"H:|-%f-[bottomLabel(==126)]",(SCREEN_WIDTH-126)/2];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat: str options:0 metrics:nil views:NSDictionaryOfVariableBindings(bottomLabel)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bottomLabel(==14)]-116-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(bottomLabel)]];
}

#pragma mark   -------配置导航栏
- (void)setNav{
    self.title = @"我的有趣度";
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

-(void)lookFrend{
    WhoEvaluationMeVC *vc = [[WhoEvaluationMeVC alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}
-(void)getFriendGrade{
    NSDictionary *dic = @{@"userId":[CommonTool getUserID]};
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/getFriendGrade",REQUESTHEADER] andParameter:dic success:^(id successResponse) {
        
         if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"])  {
             gradeSum = successResponse[@"data"][@"gradeSum"];
             if ([[NSString stringWithFormat:@"%@",gradeSum ]  isEqualToString:@"0"]) {
                 FrendNum.userInteractionEnabled = NO;
//                  FrendNum.titleLabel.text = @"还未收到别人的评价";
                 [FrendNum setTitle:@"还未收到别人的评价" forState:UIControlStateNormal];
                 avaragLabel.text = @"评分不足哦";
                 [seeStarView ShowDQStarScoreFunction:0];
             }else{
             gradeNumber = successResponse[@"data"][@"gradeNumber"];
                  avaragLabel.text =[NSString stringWithFormat:@"平均分%.1lf分",[gradeNumber floatValue]] ;
//             FrendNum.titleLabel.text = [NSString stringWithFormat:@"%@好友评价了我",gradeSum];
                 [FrendNum setTitle:[NSString stringWithFormat:@"%@好友评价了我",gradeSum] forState:UIControlStateNormal];
                 [FrendNum setTitleColor:[UIColor colorWithHexString:@"#ff5252"] forState:UIControlStateNormal];
                 FrendNum.userInteractionEnabled = YES;
               
                 
                 FrendNum.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
                 FrendNum.layer.cornerRadius = 15;
                 [FrendNum.layer setBorderWidth:1];
                 [FrendNum.layer setBorderColor:[UIColor colorWithHexString:@"#ff5252"].CGColor];
                 [seeStarView ShowDQStarScoreFunction:[gradeNumber floatValue]];
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
