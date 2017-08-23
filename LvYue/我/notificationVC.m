//
//  notificationVC.m
//  LvYue
//
//  Created by X@Han on 16/12/21.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "notificationVC.h"
#import "NoticeViewController.h"
@interface notificationVC ()<UITableViewDelegate,UITableViewDataSource, UIPickerViewDelegate,UIPickerViewDataSource>{
    UITableView *table;
    NSArray *titleArr;
    NSArray *pushArr;
    
    NSString * pushChat;
     NSString * pushInterest;
     NSString * pushAttention;
     NSString * pushInvite;
     NSString * pushSee;
    
    NSString * beginUserAge;
    NSString * endUserAge;
    NSMutableArray* _ageArr;
    NSMutableArray* _endAgeArr;
     UILabel *timeRightLabel;
    UIView *sureView;
    
    NSArray *disturbArr;
}
@property(nonatomic,strong)UIButton *modalBtn; //
@property (nonatomic, weak) UIPickerView* agePickerView; //年龄 tag 1001
@end

@implementation notificationVC
- (UIPickerView *)agePickerView {
    if (!_agePickerView) {
        UIPickerView* pickerView = [[UIPickerView alloc] init];
        pickerView.width = 240;
        pickerView.height = 216;
//        pickerView.frame = CGRectMake(0, 20, pickerView.width, pickerView.height);
        pickerView.center = self.view.center;
//        pickerView.x = 0;
//        pickerView.y = kMainScreenHeight + pickerView.height+150;
        pickerView.backgroundColor = [UIColor colorWithHexString:@"#ffffff"];
        pickerView.delegate = self;
        pickerView.dataSource = self;
     
        [pickerView selectRow:23 inComponent:0 animated:NO];
        [pickerView selectRow:7 inComponent:1 animated:NO];
        [self.modalBtn addSubview:pickerView];
        _agePickerView = pickerView;
       
        
    }
    return _agePickerView;
}

//pickerView隐藏
- (void)pickerViewHidden{
    [UIView animateWithDuration:0.25 animations:^{
        self.agePickerView.center = self.view.center;
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
        return [NSString  stringWithFormat:@"%@:00",_ageArr[row]];
    }else{
        return [NSString  stringWithFormat:@"%@:00",_endAgeArr[row]];
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

#pragma mark 给pickerview设置字体大小和颜色等
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    //可以通过自定义label达到自定义pickerview展示数据的方式
    UILabel* pickerLabel = (UILabel*)view;
    
    if (!pickerLabel)
    {
        pickerLabel = [[UILabel alloc] init];
        pickerLabel.adjustsFontSizeToFitWidth = YES;
        pickerLabel.textAlignment = NSTextAlignmentCenter;
        [pickerLabel setBackgroundColor:[UIColor lightGrayColor]];
        [pickerLabel setFont:[UIFont boldSystemFontOfSize:15]];
    }
    
    pickerLabel.text=[self pickerView:pickerView titleForRow:row forComponent:component];//调用上一个委托方法，获得要展示的title
    return pickerLabel;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    if (component == 0) {
        beginUserAge = _ageArr[row];
    }else{
        endUserAge = _endAgeArr[row];
    }
    [_agePickerView reloadAllComponents];
   
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    titleArr = @[@"聊一聊",@"被关注",@"谁看过我",@"被感兴趣",@"被邀请",@"免打扰模式",@"在设置时间段内将不在接收视频聊天通知"];
    pushArr = @[@"1",@"1",@"1",@"1",@"1",@"1"];
    [self setUI];
    
    [self setNav];
    
    
    //创建年龄数组
    _ageArr = [[NSMutableArray alloc] init];
    _endAgeArr = [[NSMutableArray alloc] init];
    beginUserAge = @"";
    endUserAge = @"";
    
    
    
    for (int i = 0; i <= 24; i ++) {
        NSString *str = [NSString stringWithFormat:@"%d",i];
        [_ageArr addObject:str];
        [_endAgeArr  addObject:str];
    }
    
  
    beginUserAge = _ageArr[23];
    endUserAge = _endAgeArr[7];
    
    timeRightLabel.text =@"请选择时段 >";
    //创建pickerView出现时同时出现的模态按钮
    _modalBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight)];
    [_modalBtn addTarget:self action:@selector(pickerViewHidden) forControlEvents:UIControlEventTouchUpInside];
    [_modalBtn setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.7]];
    _modalBtn.alpha = 1.0;
    _modalBtn.hidden = YES;
    [kKeyWindow addSubview:_modalBtn];
    
    
    sureView = [[UIView alloc]init];
    sureView.width = 240;
    sureView.height = 35;
    sureView.frame = CGRectMake(self.agePickerView.frame.origin.x, self.agePickerView.frame.origin.y, 240, sureView.height);
    sureView.backgroundColor = [UIColor colorWithHexString:@"#ffffff"];
    [self.modalBtn addSubview:sureView];
    UIButton*sureBtn = [[UIButton alloc] initWithFrame:CGRectMake(190, 0, 40, sureView.height)];
    [sureBtn setTitle:@"确定" forState:UIControlStateNormal];
    [sureBtn setTitleColor:[UIColor colorWithHexString:@"#ff5252"] forState:UIControlStateNormal];
    [sureBtn addTarget:self action:@selector(sureClick) forControlEvents:UIControlEventTouchUpInside];
    [sureView addSubview:sureBtn];

    [self getPush];
    [self getUserVideoDisturb];
    
}
-(void)sureClick{
    self.modalBtn.hidden = YES;
     timeRightLabel.text =[NSString stringWithFormat:@"%@:00~%@:00 >",beginUserAge,endUserAge] ;
    [self addUserVideoDisturb];
}
-(void)addUserVideoDisturb{
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/video/addUserVideoInstall",REQUESTHEADER] andParameter:@{@"userId":[CommonTool getUserID],@"disturbTime":[NSString  stringWithFormat:@"%@,%@",beginUserAge,endUserAge]} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        [MBProgressHUD hideHUD];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            [MBProgressHUD showSuccess:@"设置成功"];
        } else {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
    

}

-(void)getUserVideoDisturb{
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/video/getUserVideoInstall",REQUESTHEADER] andParameter:@{@"userId":[CommonTool getUserID]} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            NSString * disturbStr= successResponse[@"data"][@"disturbTime"];
            if (disturbStr.length > 0) {
                
                disturbArr = [disturbStr componentsSeparatedByString:@","];
                timeRightLabel.text =[NSString stringWithFormat:@"%@:00~%@:00 >",disturbArr[0],disturbArr[1]] ;
               
                NSIndexPath *indexPath=[NSIndexPath indexPathForRow:5 inSection:0];
                
                [table reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
            }
        } else {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
    
    
}
- (void)setUI{
    table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStylePlain];
    table.dataSource = self;
    table.delegate = self;
    table.rowHeight = 48;
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:table];
    
}
-(void)getPush{
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/circle/getPush",REQUESTHEADER] andParameter:@{@"userId":[CommonTool getUserID]} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        [MBProgressHUD hideHUD];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            pushChat =[NSString stringWithFormat:@"%@",successResponse[@"data"][@"pushChat"]];
            pushAttention =[NSString stringWithFormat:@"%@",successResponse[@"data"][@"pushAttention"]];
            pushSee =[NSString stringWithFormat:@"%@",successResponse[@"data"][@"pushSee"]];
            pushInterest = [NSString stringWithFormat:@"%@",successResponse[@"data"][@"pushInterest"]];
            pushInvite= [NSString stringWithFormat:@"%@",successResponse[@"data"][@"pushInvite"]];
            pushArr = @[pushChat,pushAttention,pushSee,pushInterest,pushInvite,@"1"];
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
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
  
    return 7;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 6) {
        return 30;
    }
    return 48;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.selectionStyle = UITableViewCellAccessoryNone;
    cell.textLabel.text = titleArr[indexPath.row];
    cell.textLabel.textColor = [UIColor colorWithHexString:@"#424242"];
    cell.textLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    if (indexPath.row == 5) {
        timeRightLabel = [[UILabel alloc]init];
        timeRightLabel.font = [UIFont systemFontOfSize:14];
        timeRightLabel.textAlignment = NSTextAlignmentRight;
        timeRightLabel.textColor = [UIColor colorWithHexString:@"#424242"];
        timeRightLabel.frame =CGRectMake(SCREEN_WIDTH-118,4, 100, 34);
        if (disturbArr && disturbArr.count>0) {
             timeRightLabel.text =[NSString stringWithFormat:@"%@:00~%@:00 >",disturbArr[0],disturbArr[1]] ;
        }else{
            timeRightLabel.text =@"请选择时段 >";
        }
        [cell.contentView addSubview:timeRightLabel];
    } else if (indexPath.row == 6) {
        cell.textLabel.textColor = [UIColor colorWithHexString:@"#424242"];
        cell.textLabel.font = [UIFont systemFontOfSize:13];
        cell.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];
        
    }else{
    UISwitch *switv = [[UISwitch alloc]init];
    
    switv.frame = CGRectMake(SCREEN_WIDTH-62,4, 44, 34);
    

    switv.tag = 1000+indexPath.row;
    [switv addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    
    //设置on一边的背景颜色
    switv.onTintColor = [UIColor colorWithHexString:@"#ff5252"];
    
    //off一边的颜色
    
     switv.tintColor = [UIColor lightGrayColor];
    
    //滑块的颜色
    switv.thumbTintColor = [UIColor whiteColor];
    
    
    if ([pushArr[indexPath.row] isEqualToString:@"1"]) {
        //默认开关
        [switv setOn:YES animated:YES];
    }else{
        [switv setOn:NO animated:YES];
    }
    
    [cell addSubview:switv];
    }
    
   return cell;
}


//- (void)setSwitch{
//    UISwitch *switv = [[UISwitch alloc]init];
//    
//    switv.frame = CGRectMake(SCREEN_WIDTH-16, 0, 26, 20);
//    
//    switv.backgroundColor = [UIColor colorWithHexString:@"#ff5252"];
//    
//    [switv addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
//                   
//    //设置on一边的背景颜色
//    switv.onTintColor = [UIColor redColor];
//    
//    //off一边的颜色
//    switv.tintColor = [UIColor purpleColor];
//    
//    //滑块的颜色
//    switv.thumbTintColor = [UIColor greenColor];
//    
//    //默认开关
//    [switv setOn:YES animated:YES];
//    
//    [self.view addSubview:switv];
//    
//    
//}


- (void)switchAction:(UISwitch *)sender{
    
    if (sender.tag == 1000) {
        if ([pushChat isEqualToString:@"1"]) {
            pushChat = @"0";
        }else{
            pushChat = @"1";
        }
        [self updataPushType:@"pushChat" flag:pushChat];
        
    }
  
    if (sender.tag == 1001) {
        if ([pushAttention isEqualToString:@"1"]) {
            pushAttention = @"0";
        }else{
            pushAttention = @"1";
        }
         [self updataPushType:@"pushAttention" flag:pushAttention];
    }
    
    if (sender.tag == 1002) {
        if ([pushSee isEqualToString:@"1"]) {
            pushSee = @"0";
        }else{
            pushSee = @"1";
        }
        [self updataPushType:@"pushSee" flag:pushSee];
        
    }
    
    if (sender.tag == 1003) {
        if ([pushInterest isEqualToString:@"1"]) {
            pushInterest = @"0";
        }else{
            pushInterest = @"1";
        }
        [self updataPushType:@"pushInterest" flag:pushInterest];
    }
    if (sender.tag == 1004) {
        if ([pushInvite isEqualToString:@"1"]) {
            pushInvite = @"0";
        }else{
            pushInvite = @"1";
        }
         [self updataPushType:@"pushInvite" flag:pushInvite];
    }
    
   
    
    
}

-(void)updataPushType:(NSString* )pushType flag:(NSString *)flag{
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/circle/updatePush",REQUESTHEADER] andParameter:@{@"userId":[CommonTool getUserID],@"pushType":pushType,@"flag":flag} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        [MBProgressHUD hideHUD];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            
            
            
           
        } else {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
    
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 5) {
//        NoticeViewController *vc = [[NoticeViewController alloc]init];
//        [self.navigationController pushViewController:vc animated:YES];
        
        
      
        [UIView animateWithDuration:0.25 animations:^{
            self.modalBtn.hidden = NO;
        } completion:^(BOOL finished) {
            self.agePickerView.center = self.view.center;
        }];
        

    }
  
    
}


#pragma mark   -------配置导航栏
- (void)setNav{
    self.title = @"通知设置";
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
