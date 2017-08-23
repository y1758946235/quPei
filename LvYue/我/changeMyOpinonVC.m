//
//  changeMyOpinonVC.m
//  LvYue
//
//  Created by X@Han on 16/12/7.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "changeMyOpinonVC.h"
#import "MyInfoVC.h"
#import "aboutSexVC.h"
#import "aboutLoveVC.h"
#import "aboutOtherBanVC.h"
#import "LYHttpPoster.h"
#import "MBProgressHUD+NJ.h"
@interface changeMyOpinonVC ()<UITableViewDelegate,UITableViewDataSource>{
    UITableView *table;
    
    NSArray *leftArr;  //关于。。。
    NSDictionary *infoDic;
    
}

@end

@implementation changeMyOpinonVC


- (void)viewWillAppear:(BOOL)animated
{
    [self getPersonalInfo];
    [super viewWillAppear:animated];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    leftArr = @[@"关于爱情",@"关于另一半",@"关于性"];
   
   
    [self setNav];
    
    [self setTable];
}


//得到个人资料

- (void)getPersonalInfo{
    
      NSString *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userId"];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/getPersonalInfo",REQUESTHEADER] andParameter:@{@"userId":userId} success:^(id successResponse) {
       // MLOG(@"结果00000000000000000000000000000000000000000000000000000000000:%@",successResponse);
        [MBProgressHUD hideHUD];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
           infoDic = successResponse[@"data"];
            
            [table reloadData];
        } else {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
    
    
    
}




#pragma mark   -------配置导航栏
- (void)setNav{
    self.title = @"修改我的看法";
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
    
    
    
}

- (void)setTable{
    table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStylePlain];
    table.dataSource = self;
    table.delegate = self;
    table.rowHeight = 57;
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:table];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    cell.textLabel.text = leftArr[indexPath.row];
  
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.textColor = [UIColor colorWithHexString:@"#424242"];
    cell.textLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    if (indexPath.row==0) {
        //关于爱情
        UILabel *ageLabel = [[UILabel alloc]initWithFrame:CGRectMake(136, 20, SCREEN_WIDTH-136-32, 14)];
        ageLabel.text = @"我想说...";
        ageLabel.textAlignment = NSTextAlignmentRight;
        ageLabel.textColor = [UIColor colorWithHexString:@"#757575"];
        ageLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
        ageLabel.text = [NSString stringWithFormat:@"%@",infoDic[@"userOpinionLove"]];
        [cell addSubview:ageLabel];
    }
    
    if (indexPath.row==1) {
        //关于另一半
        UILabel *ageLabel = [[UILabel alloc]initWithFrame:CGRectMake(136, 20, SCREEN_WIDTH-136-32, 20)];
        ageLabel.textAlignment = NSTextAlignmentRight;
         ageLabel.text = @"我想说...";
        ageLabel.textColor = [UIColor colorWithHexString:@"#757575"];
        ageLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
        ageLabel.text = [NSString stringWithFormat:@"%@",infoDic[@"userOpinionHalf"]];
        [cell addSubview:ageLabel];
    
    }
    
    
    if (indexPath.row==2) {
        //关于性
        UILabel *ageLabel = [[UILabel alloc]initWithFrame:CGRectMake(136, 20, SCREEN_WIDTH-136-32, 20)];
        ageLabel.textAlignment = NSTextAlignmentRight;
         ageLabel.text = @"我想说...";
        ageLabel.textColor = [UIColor colorWithHexString:@"#757575"];
        ageLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
        ageLabel.text = [NSString stringWithFormat:@"%@",infoDic[@"userOpinionSex"]];
        [cell addSubview:ageLabel];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==0) {
        //关于爱情
        aboutLoveVC *love = [[aboutLoveVC alloc]init];
        [self.navigationController pushViewController:love animated:YES];
    }
    
    if (indexPath.row==1) {
        //关于另一半
        aboutOtherBanVC *other = [[aboutOtherBanVC alloc]init];
        [self.navigationController pushViewController:other animated:YES];
    }
    
    
    if (indexPath.row==2) {
        //关于性
        aboutSexVC *sex = [[aboutSexVC alloc]init];
        [self.navigationController pushViewController:sex animated:YES];
    }
    
    
}


- (void)back{
    
    [self.navigationController popViewControllerAnimated:YES];

}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   

}



@end
