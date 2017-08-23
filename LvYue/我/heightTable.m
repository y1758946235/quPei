//
//  heightTable.m
//  LvYue
//
//  Created by X@Han on 16/12/20.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "heightTable.h"
#import "LYHttpPoster.h"
#import "MBProgressHUD+NJ.h"

@interface heightTable ()<UITableViewDelegate,UITableViewDataSource>{
    
    UITableView *table;
    NSArray *ageArr;
    NSString *heightStr;
}

@end

@implementation heightTable

- (void)viewDidLoad {
    [super viewDidLoad];
    ageArr = @[@"140cm",@"141cm",@"142cm",@"143cm",@"144cm",@"145cm",@"146cm",@"147cm",@"148cm",@"149cm",@"150cm",@"151cm",@"152cm",@"153cm",@"154cm",@"155cm",@"156cm",@"157cm",@"158cm",@"159cm",@"150cm",@"161cm",@"162cm",@"163cm",@"164cm",@"165cm",@"166cm",@"167cm",@"168cm",@"169cm",@"170cm",@"171cm",@"172cm",@"173cm",@"174cm",@"175cm",@"176cm",@"177cm",@"178cm",@"179cm",@"180cm",@"181cm",@"182cm",@"183cm",@"184cm",@"185cm",@"186cm",@"187cm",@"188cm",@"189cm",@"190cm",@"191cm",@"192cm",@"193cm",@"194cm",@"195cm",@"196cm",@"197cm",@"198cm",@"199cm",@"200cm",@"201cm",@"202cm",@"203cm",@"204cm",@"205cm",@"206cm",@"207cm",@"208cm",@"209cm",@"210cm",@"211cm",@"212cm",@"213cm",@"214cm",@"215cm",@"216cm",@"217cm",@"218cm",@"219cm",@"220cm"];
    
    [self setNav];
    
    [self setTable];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 76;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  
    heightStr = ageArr[indexPath.row];
    NSString *str = @"cm";
    heightStr = [heightStr stringByReplacingOccurrencesOfString:str withString:@""];
    

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
    self.title = @"选择身高";
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
    if ([CommonTool dx_isNullOrNilWithObject:heightStr]) {
        [MBProgressHUD showError:@"请选择身高"];
        return;
    }
      NSString *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userId"];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/updatePersonalInfo",REQUESTHEADER] andParameter:@{@"userId":userId,@"userHeight":heightStr} success:^(id successResponse) {
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
