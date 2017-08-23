//
//  ageTable.m
//  LvYue
//
//  Created by X@Han on 16/12/20.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "ageTable.h"
#import "LYHttpPoster.h"
#import "MBProgressHUD+NJ.h"

@interface ageTable ()<UITableViewDelegate,UITableViewDataSource>{
    
    UITableView *table;
    NSArray *ageArr;
    
    NSString *ageStr;
}

@end

@implementation ageTable

- (void)viewDidLoad {
    [super viewDidLoad];
    ageArr = @[@"18岁",@"19岁",@"20岁",@"21岁",@"22岁",@"23岁",@"24岁",@"25岁",@"26岁",@"27岁",@"28岁",@"29岁",@"30岁",@"18岁",@"19岁",@"20岁",@"21岁",@"22岁",@"23岁",@"24岁",@"25岁",@"26岁",@"27岁",@"28岁",@"29岁",@"30岁",@"31岁",@"32岁",@"33岁",@"34岁",@"35岁",@"36岁",@"37岁",@"38岁",@"39岁",@"40岁",@"41岁",@"42岁",@"43岁",@"44岁",@"45岁",@"46岁",@"47岁",@"48岁",@"49岁",@"50岁",@"51岁",@"52岁",@"53岁",@"54岁",@"55岁",@"56岁",@"57岁",@"58岁",@"59岁",@"60岁",@"61岁",@"62岁",@"63岁",@"64岁",@"65岁",@"66岁",@"67岁",@"68岁",@"69岁",@"70岁",@"71岁",@"72岁",@"73岁",@"74岁",@"75岁",@"76岁",@"77岁",@"78岁",@"79岁",@"80岁"];
    
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

- (void)setNav{
    self.title = @"选择年龄";
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ageStr = ageArr[indexPath.row];
    NSString *str = @"岁";
   ageStr = [ageStr stringByReplacingOccurrencesOfString:str withString:@""];
    

   
    
}

- (void)save{
    if ([CommonTool dx_isNullOrNilWithObject:ageStr]) {
        [MBProgressHUD showError:@"请选择年龄"];
        return;
    }
    NSString *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userId"];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/updatePersonalInfo",REQUESTHEADER] andParameter:@{@"userId":userId,@"userAge":ageStr} success:^(id successResponse) {
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
