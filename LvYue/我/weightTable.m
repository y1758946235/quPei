//
//  weightTable.m
//  LvYue
//
//  Created by X@Han on 16/12/20.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "weightTable.h"
#import "LYHttpPoster.h"
#import "MBProgressHUD+NJ.h"


@interface weightTable ()<UITableViewDelegate,UITableViewDataSource>{
    
    UITableView *table;
    NSArray *ageArr;
    NSString *weightStr;
}

@end

@implementation weightTable

- (void)viewDidLoad {
    [super viewDidLoad];
    ageArr = @[@"35kg",@"36kg",@"37kg",@"38kg",@"39kg",@"40kg",@"41kg",@"42kg",@"43kg",@"44kg",@"35kg",@"36kg",@"37kg",@"38kg",@"39kg",@"40kg",@"41kg",@"42kg",@"43kg",@"44kg",@"45kg",@"46kg",@"47kg",@"48kg",@"49kg",@"50kg",@"51kg",@"52kg",@"53kg",@"54kg",@"55kg",@"56kg",@"57kg",@"58kg",@"59kg",@"60kg",@"61kg",@"62kg",@"63kg",@"64kg",@"65kg",@"66kg",@"67kg",@"68kg",@"69kg",@"70kg",@"71kg",@"72kg",@"73kg",@"74kg",@"75kg",@"76kg",@"77kg",@"78kg",@"79kg",@"80kg",@"81kg",@"82kg",@"83kg",@"84kg",@"85kg",@"86kg",@"87kg",@"88kg",@"89kg",@"90kg",@"91kg",@"92kg",@"93kg",@"94kg",@"95kg",@"96kg",@"97kg",@"98kg",@"99kg",@"100kg"];
    
    [self setNav];
    
    [self setTable];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 76;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = ageArr[indexPath.row];
    cell.textLabel.textColor = [UIColor colorWithHexString:@"#424242"];
    cell.textLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    return cell;
}


- (void)setTable{
    
    table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStylePlain];
    table.dataSource = self;
    table.delegate = self;
    table.rowHeight = 48;
    [self.view addSubview:table];
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    weightStr = ageArr[indexPath.row];
    NSString *str = @"kg";
    weightStr = [weightStr stringByReplacingOccurrencesOfString:str withString:@""];
    

}

- (void)setNav{
    self.title = @"选择体重";
    //导航栏title的颜色
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithHexString:@"#424242"],UITextAttributeTextColor, [UIFont fontWithName:@"PingFangSC-Medium" size:18],UITextAttributeFont, nil]];
    
    //导航栏返回按钮
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(16, 38, 28, 14)];
    [button setTitleColor:[UIColor colorWithHexString:@"#424242"] forState:UIControlStateNormal];
    [button setTitle:@"返回" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [button addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
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

- (void)save{
    if ([CommonTool dx_isNullOrNilWithObject:weightStr]) {
        [MBProgressHUD showError:@"请选择体重"];
        return;
    }
    NSString *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userId"];
    
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/updatePersonalInfo",REQUESTHEADER] andParameter:@{@"userId":userId,@"userWeight":weightStr} success:^(id successResponse) {
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
