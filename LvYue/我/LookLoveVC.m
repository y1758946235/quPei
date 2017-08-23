//
//  LookLoveVC.m
//  LvYue
//
//  Created by X@Han on 16/12/27.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "LookLoveVC.h"
#import "LYHttpPoster.h"
#import "MBProgressHUD+NJ.h"

@interface LookLoveVC (){
    NSDictionary *infoDic;
    UILabel *contentLabel;
}

@end

@implementation LookLoveVC

- (void)viewWillAppear:(BOOL)animated{
    
    [self getPersonalInfo];
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNav];
    [self setContent];
}


//得到个人资料

- (void)getPersonalInfo{
      NSString *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userId"];
    
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/getPersonalInfo",REQUESTHEADER] andParameter:@{@"userId":userId} success:^(id successResponse) {
       // MLOG(@"结果00000000000000000000000000000000000000000000000000000000000:%@",successResponse);
        [MBProgressHUD hideHUD];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            infoDic = successResponse[@"data"];
            contentLabel.text = infoDic[@"userOpinionLove"];
          
        } else {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
    
    
    
}



- (void)setContent{
    
    self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.10];
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
    
    contentLabel = [[UILabel alloc]init];
    contentLabel.translatesAutoresizingMaskIntoConstraints  = NO;
    contentLabel.numberOfLines = 0;
    contentLabel.text = @"爱情其实就是一种生活。与你爱的人相视一笑，默默牵手走过，无须言语不用承诺。 系上围裙，走进厨房，为你爱的人煲一锅汤，风起的时候为她紧紧衣襟、理理乱发，有雨的日子，拿把伞为她撑起一片晴空。";
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


#pragma mark  ----关闭----
- (void)close:(UIButton *)sender{
    
    
    
    
}



#pragma mark   -------配置导航栏
- (void)setNav{
    self.title = @"胖胖的主页";
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
    //如果是自己   这个就没有     是别人就有
    //导航栏   举报 拉黑 按钮
    UIButton *edit = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-16-28, 38, 18, 28)];
    [edit setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
    [edit addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *edited = [[UIBarButtonItem alloc]initWithCustomView:edit];
    self.navigationItem.rightBarButtonItem = edited;
    
}

- (void)save{
    UIView *rightView = [[UIView alloc]init];
    rightView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width-98, 8, 88, 112);
    rightView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:rightView];
    
    UIImageView *image = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 88, 112)];
    image.image = [UIImage imageNamed:@"举报背景"];
    image.userInteractionEnabled = YES;
    [rightView addSubview:image];
    
    NSArray *title = @[@"举报",@"拉黑"];
    for (NSInteger i = 0; i < 2;  i++) {
        UIButton *action = [UIButton buttonWithType:UIButtonTypeCustom];
        action.frame  =CGRectMake(0, 8+i*48, 88, 48);
        [action setTitle:title[i] forState:UIControlStateNormal];
        action.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        [action setTitleColor:[UIColor colorWithHexString:@"#424242"] forState:UIControlStateNormal];
        action.tag = 1000+i;
        [action addTarget:self action:@selector(moreAction:) forControlEvents:UIControlEventTouchUpInside];
        [image addSubview:action];
        
    }
    
    
}


- (void)moreAction:(UIButton *)sender{
    [sender.superview  removeFromSuperview];
    
    UIImageView *image = [[UIImageView alloc]init];
    image.userInteractionEnabled = YES;
    image.translatesAutoresizingMaskIntoConstraints = NO;
    image.image = [UIImage imageNamed:@"举报背景"];
    image.userInteractionEnabled = YES;
    [self.view addSubview:image];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[image]-20-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(image)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-140-[image(==160)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(image)]];
    
    UILabel *sureLabel = [[UILabel alloc]initWithFrame:CGRectMake(24, 24, 96, 16)];
    sureLabel.text = @"确定拉黑吗";
    sureLabel.textColor = [UIColor colorWithHexString:@"424242"];
    sureLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:16];
    [image addSubview:sureLabel];
    
    UILabel *aletLabel = [[UILabel alloc]init];
    aletLabel.translatesAutoresizingMaskIntoConstraints = NO;
    aletLabel.text = @"拉黑后无法互相发送消息，对方将无法查看您的主页，直到您取消拉黑";
    aletLabel.numberOfLines = 0;
    aletLabel.textColor = [UIColor colorWithHexString:@"#757575"];
    aletLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
    [image addSubview:aletLabel];
    [image addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-24-[aletLabel]-24-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(aletLabel)]];
    [image addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-56-[aletLabel(==40)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(aletLabel)]];
    
    
    //取消  确定  按钮
    UIButton *cancel = [[UIButton alloc]init];
    cancel.translatesAutoresizingMaskIntoConstraints = NO;
    [cancel setTitle:@"取消" forState:UIControlStateNormal];
    [cancel setTitleColor:[UIColor colorWithHexString:@"#424242"] forState:UIControlStateNormal];
    cancel.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [cancel addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    [image addSubview:cancel];
    [image addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[cancel(==48)]-64-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(cancel)]];
    [image addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-120-[cancel(==32)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(cancel)]];
    
    
    UIButton *sure = [[UIButton alloc]init];
    sure.translatesAutoresizingMaskIntoConstraints = NO;
    [sure setTitle:@"确定" forState:UIControlStateNormal];
    [sure setTitleColor:[UIColor colorWithHexString:@"#ff5252"] forState:UIControlStateNormal];
    sure.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [sure addTarget:self action:@selector(sure:) forControlEvents:UIControlEventTouchUpInside];
    [image addSubview:sure];
    [image addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[sure(==48)]-8-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(sure)]];
    [image addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-120-[sure(==32)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(sure)]];
}


#pragma mark   --确定拉黑

- (void)sure:(UIButton *)sender{
    
    [sender.superview removeFromSuperview];
    
}

#pragma mark  ---取消拉黑
- (void)cancel:(UIButton *)sender{
    
    [sender.superview removeFromSuperview];
    
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
