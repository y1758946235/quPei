//
//  selectResultVC.m
//  LvYue
//
//  Created by X@Han on 17/1/16.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "selectResultVC.h"

@interface selectResultVC ()

@end

@implementation selectResultVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNav];
    [self requestData];
}


#pragma mark  --------导航栏配置------
- (void)setNav{
    
    self.title = @"筛选结果";
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#424242"],NSFontAttributeName:[UIFont fontWithName:@"PingFangSC-Medium" size:18]};
    
    //定位按钮
    UIButton *localeBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    localeBtn.frame = CGRectMake(0, 38, 40,40);
    [localeBtn setTitle:@"返回" forState:UIControlStateNormal];
    localeBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [localeBtn setTitleColor:[UIColor colorWithHexString:@"#424242"] forState:UIControlStateNormal];
    [localeBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:localeBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    
    //右上角筛选图片  按钮
    UIButton *selectBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    selectBtn.backgroundColor = [UIColor clearColor];
    [selectBtn setTitle:@"确定" forState:UIControlStateNormal];
    selectBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [selectBtn setTitleColor:[UIColor colorWithHexString:@"#ff5252"] forState:UIControlStateNormal];
    [selectBtn addTarget:self action:@selector(sure:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:selectBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    
}
- (void)requestData{
    if (self.placeId.length == 0) {
        self.placeId = @",,";
    }
    NSString *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userId"];
    NSString *provinceId ;
    NSString *cityId;
    NSString *distriId;
    NSArray *plaIdArr = [self.placeId componentsSeparatedByString:@","];
    if (plaIdArr.count==3) {
        provinceId = plaIdArr[0];
        cityId = plaIdArr[1];
        distriId = plaIdArr[2];
    }else{
        provinceId = plaIdArr[0];
        cityId = plaIdArr[1];
        distriId = @"0";
    }
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/date/getDate",REQUESTHEADER] andParameter:@{@"userId":userId,@"arrayType":self.arrayType,@"userSex":self.userSex,@"provinceId":distriId,@"cityId":cityId,@"districtId":distriId} success:^(id successResponse) {
        
        NSLog(@"筛选结果%@",successResponse);
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            [MBProgressHUD showSuccess:@"筛选成功"];
         
        }
        
        
    } andFailure:^(id failureResponse) {
        
        NSLog(@"失败结果%@",failureResponse);
    }];
    

}
- (void)sure:(UIButton *)sender{
    
    
    
}

- (void)back:(UIButton *)sender{
    
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
