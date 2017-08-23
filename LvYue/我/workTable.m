//
//  workTable.m
//  LvYue
//
//  Created by X@Han on 16/12/21.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "workTable.h"
#import "LYHttpPoster.h"
#import "MBProgressHUD+NJ.h"

@interface workTable (){
    NSArray *titleArr;
    UIButton *seButton;
    NSString *workStr;
    
    UIButton *lastBtn;
}

@end

@implementation workTable

- (void)viewDidLoad {
    [super viewDidLoad];
    
    titleArr = @[@"军人",@"警察",@"医生",@"护士",@"空乘",@"模特",@"教师",@"职员",@"企业者",@"管理者",@"工程师",@"大学生",@"经理人",@"航空公司",@"演艺人员",@"国企工作",@"机关工作",@"媒体工作",@"互联网",@"投资人"];
    
    [self setNav];
    
    [self setContent];
}


- (void)setContent{
    for (NSInteger i=0; i<20;i++) {
        CGFloat width = (SCREEN_WIDTH-62)/4;
        CGFloat height = width/2;
        seButton = [UIButton buttonWithType:UIButtonTypeCustom];
        seButton.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];
        seButton.frame = CGRectMake(16+i%4*(width+10), 90+i/4*(height+8), width, height);
        seButton.tag = 1000+i;
        [seButton.layer setMasksToBounds:YES];
        [seButton.layer setCornerRadius:2];
        [seButton setTitle:titleArr[i] forState:UIControlStateNormal];
        [seButton setTitleColor:[UIColor colorWithHexString:@"#757575"] forState:UIControlStateNormal];
        [seButton setTitleColor:[UIColor colorWithHexString:@"#ff5252"] forState:UIControlStateSelected];
        seButton.titleLabel.font =[UIFont fontWithName:@"PingFangSC-Light" size:14];
        [seButton addTarget:self action:@selector(selectedBtn:) forControlEvents:UIControlEventTouchUpInside];
        seButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [seButton.layer setMasksToBounds:YES];
        [seButton.layer setCornerRadius:2];
         //seButton.selected = NO;
        [self.view addSubview:seButton];
    }
    
}



#pragma mark  -----选中状态  单选

- (void)selectedBtn:(UIButton *)sender{
    
    if (sender==lastBtn) {
        
        return;
        
    }else{
        sender.selected = YES;
        lastBtn.selected = NO;
        lastBtn.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];
        lastBtn = sender;
        UIColor *color = [UIColor colorWithHexString:@"#ff5252"];
        sender.backgroundColor = [color colorWithAlphaComponent:0.1];
        
        workStr = sender.titleLabel.text;
       
        
    }
    
    
}

#pragma mark   -------配置导航栏
- (void)setNav{
    self.title = @"选择职业";
    self.view.backgroundColor = [UIColor colorWithHexString:@"#ffffff"];
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
    if ([CommonTool dx_isNullOrNilWithObject:workStr]) {
        [MBProgressHUD showError:@"请选择职业"];
        return;
    }
    NSString *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userId"];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/updatePersonalInfo",REQUESTHEADER] andParameter:@{@"userId":userId,@"userProfession":workStr} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        [MBProgressHUD hideHUD];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            [MBProgressHUD showSuccess:@"修改成功"];
            [self.navigationController popViewControllerAnimated:YES];
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
