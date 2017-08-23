//
//  selectVC.m
//  LvYue
//
//  Created by X@Han on 16/12/28.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "selectVC.h"

@interface selectVC ()<UITableViewDelegate,UITableViewDataSource, UIPickerViewDelegate,UIPickerViewDataSource>{
    UITableView *selectTable;
    UILabel *sexRightLabel;
    UILabel *ageRightLabel;
    NSString * userSex;
    NSString * beginUserAge;
    NSString * endUserAge;
    NSMutableArray* _ageArr;
    NSMutableArray* _endAgeArr;
}
@property(nonatomic,strong)UIButton *modalBtn; //
@property (nonatomic, weak) UIPickerView* agePickerView; //年龄 tag 1001
@property (nonatomic, assign) BOOL ageEnable; //年龄
@end

@implementation selectVC
- (UIPickerView *)agePickerView {
    if (!_agePickerView) {
        UIPickerView* pickerView = [[UIPickerView alloc] init];
        pickerView.width = kMainScreenWidth;
        pickerView.height = 216;
        pickerView.x = 0;
        pickerView.y = kMainScreenHeight + pickerView.height+150;
        pickerView.backgroundColor = [UIColor whiteColor];
        pickerView.delegate = self;
        pickerView.dataSource = self;
        
        
        _agePickerView = pickerView;
        [self.modalBtn addSubview:_agePickerView];
    }
    return _agePickerView;
}


//pickerView隐藏
- (void)pickerViewHidden{
    [UIView animateWithDuration:0.25 animations:^{
        self.agePickerView.y = kMainScreenHeight + self.agePickerView.height;
    }];
    [UIView animateWithDuration:0.1 animations:^{
        _modalBtn.hidden = YES;
    }];
    
    
//    NSInteger selectMin = [_agePickerView selectedRowInComponent:0];
//    NSString* ageStr = _ageArr[selectMin];
//    beginUserAge = ageStr;
//    ageStr = [NSString stringWithFormat:@"%@岁",ageStr];
    
}
#pragma mark - UIPickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 2;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (component == 0) {
        return _ageArr.count;
    }else{
        return _endAgeArr.count;
    }

}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if (component == 0) {
        return _ageArr[row];
    }else{
        return _endAgeArr[row];
    }
//    if (component == 0) {
//        return _ageArr[row];
//    }else{
//        
////        if ([_ageArr[row] intValue] >[_endAgeArr[row] intValue]) {
////             return _ageArr[row];
////        }
//        return _endAgeArr[row];
//    }
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    if (component == 0) {
                beginUserAge = _ageArr[row];
    }else{
        endUserAge = _endAgeArr[row];
    }
//    [_endAgeArr removeAllObjects];
//    [_endAgeArr setArray:_ageArr];
//    [_agePickerView reloadAllComponents];
//    if (component == 0) {
//        beginUserAge = _ageArr[row];
//        if ([beginUserAge intValue] > [_endAgeArr[0] intValue]) {
//            endUserAge = beginUserAge;
//            [_endAgeArr removeAllObjects];
//            for (int i = [beginUserAge intValue]; i <= 100; i ++) {
//                NSString *str = [NSString stringWithFormat:@"%d",i];
//                
//                [_endAgeArr  addObject:str];
//                
//            }
//            
//        }
//
//        
//    }else{
//        endUserAge = _endAgeArr[row];
//        if ([beginUserAge intValue] > [_endAgeArr[row] intValue]) {
//            endUserAge = beginUserAge;
//            [_endAgeArr removeAllObjects];
//            for (int i = [beginUserAge intValue]; i <= 100; i ++) {
//                NSString *str = [NSString stringWithFormat:@"%d",i];
//                
//                [_endAgeArr  addObject:str];
//                
//            }
//            
//        }
//
//    }
//    
//   
    if ([beginUserAge intValue] > [endUserAge          intValue]) {
        [MBProgressHUD showError:@"年龄必须从小到大哦～"];
    }else{
        [_agePickerView reloadAllComponents];
        ageRightLabel.text =[NSString stringWithFormat:@"%@~%@",beginUserAge,endUserAge] ;
    }
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
  
    [self setNav];
    [self selectContent];
    
    //创建年龄数组
    _ageArr = [[NSMutableArray alloc] init];
    _endAgeArr = [[NSMutableArray alloc] init];
    userSex = @"";
    beginUserAge = @"";
    endUserAge = @"";
    for (int i = 16; i <= 100; i ++) {
        NSString *str = [NSString stringWithFormat:@"%d",i];
        [_ageArr addObject:str];
        [_endAgeArr  addObject:str];
    }
    
    ageRightLabel.text =@"";
    //创建pickerView出现时同时出现的模态按钮
    _modalBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight)];
    [_modalBtn addTarget:self action:@selector(pickerViewHidden) forControlEvents:UIControlEventTouchUpInside];
    [_modalBtn setBackgroundColor:[UIColor clearColor]];
    _modalBtn.alpha = 1.0;
    _modalBtn.hidden = YES;
    [self.view addSubview:_modalBtn];

}


#pragma mark   -------------筛选下面的内容-----
- (void)selectContent{
    
    
    selectTable = [[UITableView alloc]initWithFrame:CGRectMake(0,0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStyleGrouped];
    
    selectTable.dataSource = self;
    selectTable.delegate = self;
    selectTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    selectTable.rowHeight = 48;
    [self.view addSubview:selectTable];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    cell.textLabel.textColor = [UIColor colorWithHexString:@"#424242"];
    cell.textLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
   

    
    if (indexPath.row==0) {
         cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        sexRightLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-85, 12,60, 25)];
        sexRightLabel.text = @"不限";
        sexRightLabel.textAlignment = NSTextAlignmentCenter;
        sexRightLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        sexRightLabel.textColor = [UIColor colorWithHexString:@"#757575"] ;
        [cell.contentView addSubview:sexRightLabel];
        cell.textLabel.text = @"性别";
    
    }
    if (indexPath.row == 1) {
         cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        ageRightLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-85, 12,60, 25)];
        ageRightLabel.text = @"不限";
         ageRightLabel.textColor = [UIColor colorWithHexString:@"#757575"] ;
          ageRightLabel.textAlignment = NSTextAlignmentCenter;
        ageRightLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        [cell.contentView addSubview:ageRightLabel];
        cell.textLabel.text = @"年龄";
        
    }
    if (indexPath.row == 2) {
        UIButton *reSetBtn = [[UIButton alloc]init];
        reSetBtn.frame = CGRectMake(SCREEN_WIDTH-85, 12, 60, 32);
        reSetBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:16];
        //        reSetBtn.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];
        UIColor *color = [UIColor colorWithHexString:@"#ff5252"];
        reSetBtn.backgroundColor = [color colorWithAlphaComponent:0.1];
        reSetBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        //        [reSetBtn setTitleColor:[UIColor colorWithHexString:@"#757575"] forState:UIControlStateNormal];
        [reSetBtn setTitleColor:[UIColor colorWithHexString:@"#ff5252"] forState:UIControlStateNormal];
        [reSetBtn setTitle:@"重置" forState:UIControlStateNormal];
        [reSetBtn addTarget:self action:@selector(resetClick) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:reSetBtn];
    }
    
//    cell.detailTextLabel.text = cellRightArr[indexPath.row];
//    cell.detailTextLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:15];
//    cell.detailTextLabel.textColor = [UIColor colorWithHexString:@"#757575"];
    
    
    return cell;
    
}
-(void)resetClick{
    
    userSex = @"";
    beginUserAge = @"";
    endUserAge = @"";
    sexRightLabel.text = @"不限";
    ageRightLabel.text = @"不限";
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"性别" message:@"请选择您的性别" preferredStyle:UIAlertControllerStyleActionSheet];
        // 设置popover指向的item
        alert.popoverPresentationController.barButtonItem = self.navigationItem.leftBarButtonItem;
        
        // 添加按钮
        [alert addAction:[UIAlertAction actionWithTitle:@"男" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            NSLog(@"点击了男按钮");
            sexRightLabel.text = @"男";
            userSex = @"0";
            
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"女" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            NSLog(@"点击了男按钮");
            sexRightLabel.text = @"女";
            userSex = @"1";
            
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            NSLog(@"点击了女按钮");
            sexRightLabel.text = @"不限";
            userSex = @"2";
        }]];
        
        [self presentViewController:alert animated:YES completion:nil];
    }else{
        //年龄
        self.ageEnable = YES;
        [UIView animateWithDuration:0.25 animations:^{
            self.modalBtn.hidden = NO;
        } completion:^(BOOL finished) {
            self.agePickerView.y = kMainScreenHeight - self.agePickerView.height;
        }];

    }
}

#pragma mark  --------导航栏配置------
- (void)setNav{
    
    self.title = @"筛选";
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#424242"],NSFontAttributeName:[UIFont fontWithName:@"PingFangSC-Medium" size:18]};
    
    //返回
    UIButton *localeBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    localeBtn.frame = CGRectMake(0, 38, 40,40);
    [localeBtn setTitle:@"返回" forState:UIControlStateNormal];
    localeBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [localeBtn setTitleColor:[UIColor colorWithHexString:@"#424242"] forState:UIControlStateNormal];
    [localeBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:localeBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    
    
    UIButton *selectBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    selectBtn.backgroundColor = [UIColor clearColor];
    [selectBtn setTitle:@"确定" forState:UIControlStateNormal];
    selectBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [selectBtn setTitleColor:[UIColor colorWithHexString:@"#ff5252"] forState:UIControlStateNormal];
    [selectBtn addTarget:self action:@selector(sure:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:selectBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    
}

- (void)sure:(UIButton *)sender{
    
    if (self.shaiXuanTextBlock != nil) {
        
        self.shaiXuanTextBlock(userSex,beginUserAge,endUserAge);
    }
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)back:(UIButton *)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
    
}
- (void)shaiXuanText:(ShaiXuanTextBlock)block{
    self.shaiXuanTextBlock = block;
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
