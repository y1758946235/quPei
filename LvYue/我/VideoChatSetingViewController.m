//
//  VideoChatSetingViewController.m
//  LvYue
//
//  Created by X@Han on 17/6/27.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "VideoChatSetingViewController.h"
#import "VideoRecordingVC.h"
@interface VideoChatSetingViewController ()<UITableViewDelegate,UITableViewDataSource, UIPickerViewDelegate,UIPickerViewDataSource>{
    
    
    NSString * beginUserAge;
    NSString * endUserAge;
    NSMutableArray* _ageArr;
    NSMutableArray* _endAgeArr;
    UILabel *timeRightLabel;
    UIView *sureView;
    
    
    
     BOOL  isOpen;
    
    
     NSString * videoGoldsInfoStr;
    NSString *instructionStr;
    
    UIButton *_lastBtn;
    
    NSString *selectGolds;
     NSString *isVideo;
    
    NSString *disturbTimeStr;
    
    UILabel *myVideoGoldLabel;
   
}
@property(nonatomic,strong)UIButton *modalBtn; //
@property (nonatomic, weak) UIPickerView* agePickerView; //年龄 tag 1001
@property (nonatomic,strong)UITableView *tableView;

@property (nonatomic,strong)NSArray *videoGoldsArr;

@property (nonatomic,strong)NSArray *disturbArr;
@property (nonatomic,strong)NSString *videoGold;

@property (nonatomic,strong)UILabel *videoGoldDetailLabel;
@end

@implementation VideoChatSetingViewController

-(NSString *)videoGold{
    if (!_videoGold) {
        _videoGold = [[NSString alloc]init];
    }
    return _videoGold;
}
//懒加载
-(UILabel *)videoGoldDetailLabel{
    if (!_videoGoldDetailLabel) {
        _videoGoldDetailLabel = [[UILabel alloc]init];
        _videoGoldDetailLabel.font = [UIFont systemFontOfSize:13];
        _videoGoldDetailLabel.textAlignment = NSTextAlignmentCenter;
          _videoGoldDetailLabel.textColor = [UIColor colorWithHexString:@"#424242"];
        _videoGoldDetailLabel.text = videoGoldsInfoStr;
        _videoGoldDetailLabel.numberOfLines = 0;
        CGSize maximumLabelSize = CGSizeMake(SCREEN_WIDTH-32, 160);//labelsize的最大值
        //关键语句
        CGSize expectSize = [_videoGoldDetailLabel sizeThatFits:maximumLabelSize];
        //别忘了把frame给回label，如果用xib加了约束的话可以只改一个约束的值
        _videoGoldDetailLabel.frame = CGRectMake(16, 85, SCREEN_WIDTH-32, expectSize.height);
    }
    return _videoGoldDetailLabel;
}
-(NSArray *)disturbArr{
    if (!_disturbArr) {
        _disturbArr = [[NSArray alloc]init];
    }
    return _disturbArr;
}
-(NSArray *)videoGoldsArr{
    if (!_videoGoldsArr) {
        _videoGoldsArr = [[NSArray alloc]init];
    }
    return _videoGoldsArr;
}
- (UITableView *)tableView{
    
    
    
    if (!_tableView) {
        
        
        
    
        
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0,0, SCREEN_WIDTH, SCREEN_HEIGHT-64) style:UITableViewStyleGrouped];
        
        _tableView.delegate = self;
        
        
        
        _tableView.dataSource = self;
        
        
        
    }
    
    
    
    return _tableView;
    
    
    
}
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
        
        [pickerView selectRow:0 inComponent:0 animated:NO];
        [pickerView selectRow:0 inComponent:1 animated:NO];
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
    // Do any additional setup after loading the view.
    self.title =@"视频聊设置";
    //创建年龄数组
    _ageArr = [[NSMutableArray alloc] init];
    _endAgeArr = [[NSMutableArray alloc] init];
    beginUserAge = @"";
    endUserAge = @"";
    selectGolds = [[NSString  alloc]init];
    isVideo = [[NSString  alloc]init];
    disturbTimeStr = [[NSString alloc]init];
    
    videoGoldsInfoStr = @"（上面价格选择是您作为视频聊天服务的收费价格，男生如果有特别有趣的视频聊天场景，可选择免费，以满足女生好奇心哦！）";
    instructionStr = @"本视频是作为您提供视频聊天服务的聊天场景宣传小视频。\n拍的有趣会吸引更多人找您视频聊天哦！\n接收视频聊越多，积分越多！\n拍一段您的宣传视频吧！";
    [self setNav];
    [self.view addSubview:self.tableView];
    for (int i = 0; i <= 24; i ++) {
        NSString *str = [NSString stringWithFormat:@"%d",i];
        [_ageArr addObject:str];
        [_endAgeArr  addObject:str];
    }
    
    
//    beginUserAge = _ageArr[23];
//    endUserAge = _endAgeArr[7];
    
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
    
   
    [self getUserVideoInstall];
    [self  getVideoAmountList];
 

}
-(void)sureClick{
    //    beginUserAge = _ageArr[23];
    //    endUserAge = _endAgeArr[7];
    if ([CommonTool dx_isNullOrNilWithObject:beginUserAge]) {
        beginUserAge = _ageArr[0];
    }
    if ([CommonTool dx_isNullOrNilWithObject:endUserAge]) {
        endUserAge = _endAgeArr[0];
    }
    self.modalBtn.hidden = YES;
    timeRightLabel.text =[NSString stringWithFormat:@"%@:00~%@:00 >",beginUserAge,endUserAge] ;
//    [self addUserVideoDisturb];
}
//-(void)addUserVideoDisturb{
//    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/video/addUserVideoDisturb",REQUESTHEADER] andParameter:@{@"userId":[CommonTool getUserID],@"disturbTime":[NSString  stringWithFormat:@"%@,%@",beginUserAge,endUserAge]} success:^(id successResponse) {
//        MLOG(@"结果:%@",successResponse);
//        [MBProgressHUD hideHUD];
//        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
//            [MBProgressHUD showSuccess:@"设置成功"];
//        } else {
//            [MBProgressHUD hideHUD];
//            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
//        }
//    } andFailure:^(id failureResponse) {
//        [MBProgressHUD hideHUD];
//        [MBProgressHUD showError:@"服务器繁忙,请重试"];
//    }];
//    
//    
//}

-(void)getUserVideoInstall{
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/video/getUserVideoInstall",REQUESTHEADER] andParameter:@{@"userId":[CommonTool getUserID]} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
    
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            NSString * disturbStr= successResponse[@"data"][@"disturbTime"];
            if (disturbStr.length > 0) {
                
                _disturbArr = [disturbStr componentsSeparatedByString:@","];
                timeRightLabel.text =[NSString stringWithFormat:@"%@:00~%@:00 >",_disturbArr[0],_disturbArr[1]] ;
                beginUserAge = [NSString stringWithFormat:@"%@",_disturbArr[0]];
                endUserAge = [NSString stringWithFormat:@"%@",_disturbArr[1]];

//                NSIndexPath *indexPath=[NSIndexPath indexPathForRow:1 inSection:0];
//                
//                [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
                [_tableView reloadData];
            }
            
            if (self.isOpenSwitv == YES) {
                isOpen = YES;
                isVideo = @"1";
            }else{
            if ([[NSString stringWithFormat:@"%@",successResponse[@"data"][@"isVideo"]] isEqualToString:@"1"]) {
                
                 isOpen = YES;
                isVideo = @"1";
            }else{
              isOpen = NO;
                isVideo = @"0";
            }}
            
            _videoGold =[NSString stringWithFormat:@"%@",successResponse[@"data"][@"videoGold"]];
            selectGolds =_videoGold;
//             [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0]withRowAnimation:UITableViewRowAnimationFade];//有动画的刷新
            [self.tableView reloadData];
        } else {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
    
    
}

-(void)getVideoAmountList{
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/order/getVideoAmount", REQUESTHEADER] andParameter:nil
                                success:^(id successResponse) {
                                    
    if ([[NSString stringWithFormat:@"%@", successResponse[@"code"]] isEqualToString:@"200"]) {
          self.videoGoldsArr= successResponse[@"data"];
   
    
         
         
//         NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:0];
//           [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
        [_tableView reloadData];
    } else {
                                            
             [MBProgressHUD showError:[NSString stringWithFormat:@"%@", successResponse[@"errorMsg"]]];
                                        }
                                }
                             andFailure:^(id failureResponse) {
                                 [MBProgressHUD hideHUD];
                                 [MBProgressHUD showError:@"服务器繁忙,请重试"];
                             }];

}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.isOpenSwitv == YES) {
        return 3;
    }else{
    if (isOpen == YES) {
        return 3;
    }else{
        return 0;
    }
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        if (self.videoGoldsArr  && self.videoGoldsArr>0) {
//            return 48 *(self.videoGoldsArr.count/3);
            CGSize maximumLabelSize = CGSizeMake(SCREEN_WIDTH-32, 160);//labelsize的最大值
            //关键语句
            CGSize expectSize = [_videoGoldDetailLabel sizeThatFits:maximumLabelSize];
            return 100+expectSize.height ;
        }
       
    }
    if (indexPath.row== 2) {
       return  120;
    }
    return 48;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 48;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
        
        
       UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
//        cell.backgroundColor = [UIColor orangeColor];
//    UILabel *titleLabel= [[UILabel alloc]init];
//    titleLabel.frame = CGRectMake(16, 0, 80, 44);
//    titleLabel.font = [UIFont systemFontOfSize:16];
//    titleLabel.textAlignment = NSTextAlignmentRight;
////    titleLabel.textColor = [UIColor colorWithHexString:@"#424242"];
//     titleLabel.text = titleArr[indexPath.row];
//    [cell.contentView addSubview:titleLabel];
    
    
    CGFloat wieth = (SCREEN_WIDTH-32-4*12)/5;
    if (indexPath.row == 0) {
            UILabel *titleLabel= [[UILabel alloc]init];
            titleLabel.frame = CGRectMake(16, 0, 180, 44);
            titleLabel.font = [UIFont systemFontOfSize:16];
            titleLabel.textAlignment = NSTextAlignmentLeft;
        //    titleLabel.textColor = [UIColor colorWithHexString:@"#424242"];
       
            [cell.contentView addSubview:titleLabel];
        titleLabel.text = @"设置视频聊金币";
        titleLabel.font = [UIFont systemFontOfSize:14];
        
        myVideoGoldLabel= [[UILabel alloc]init];
        myVideoGoldLabel.frame = CGRectMake(SCREEN_WIDTH-168,0, 150,44 );
        myVideoGoldLabel.font = [UIFont systemFontOfSize:16];
        myVideoGoldLabel.textAlignment = NSTextAlignmentRight;
        myVideoGoldLabel.textColor = [UIColor colorWithHexString:@"#424242"];
        myVideoGoldLabel.text = [NSString stringWithFormat:@"我的服务聊币：%@",_videoGold];
        myVideoGoldLabel.font = [UIFont systemFontOfSize:14];
        [cell.contentView addSubview:myVideoGoldLabel];
        
        
        for (int i = 0; i <self.videoGoldsArr.count; i ++) {
            UIButton *videoGoldBtn = [[UIButton alloc]init];
            videoGoldBtn.frame = CGRectMake(16+(wieth +12)*i, 50, wieth, 28);
            [videoGoldBtn setTitle:[NSString stringWithFormat:@"%@",self.videoGoldsArr[i]] forState:UIControlStateNormal];
            videoGoldBtn.titleLabel.font = [UIFont systemFontOfSize:12];
            videoGoldBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
            videoGoldBtn.layer.borderColor =[UIColor colorWithHexString:@"#ff5252"].CGColor;
            videoGoldBtn.layer.borderWidth = 0.5;
            videoGoldBtn.layer.cornerRadius = 14;
            videoGoldBtn.clipsToBounds = YES;
            [videoGoldBtn setTitleColor:[UIColor colorWithHexString:@"#424242"] forState:UIControlStateNormal];
            [videoGoldBtn setTitleColor:[UIColor colorWithHexString:@"#ffffff"] forState:UIControlStateSelected];
            
            videoGoldBtn.tag = 1000+i;
            [videoGoldBtn addTarget:self action:@selector(selectGoldsClick:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:videoGoldBtn];
            
            if (self.isOpenSwitv == YES && i == 2) {
            
                videoGoldBtn.backgroundColor = [UIColor colorWithHexString:@"#ff5252"];
                videoGoldBtn.selected = YES;
                _lastBtn.selected = NO;
                _lastBtn.backgroundColor = [UIColor colorWithHexString:@"#ffffff"];
                _lastBtn = videoGoldBtn;
                selectGolds = [NSString stringWithFormat:@"%@",self.videoGoldsArr[i]];

            }
            
            
        }
        
       
       
        [cell.contentView addSubview:self.videoGoldDetailLabel];
        
       

        
    }else if (indexPath.row == 1){
        
        cell.textLabel.text = @"免打扰时间";
        cell.textLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        
        timeRightLabel = [[UILabel alloc]init];
        timeRightLabel.font = [UIFont systemFontOfSize:14];
        timeRightLabel.textAlignment = NSTextAlignmentRight;
        timeRightLabel.textColor = [UIColor colorWithHexString:@"#424242"];
        timeRightLabel.frame =CGRectMake(SCREEN_WIDTH-118,4, 100, 34);
        if (self.disturbArr && self.disturbArr.count>0) {
            timeRightLabel.text =[NSString stringWithFormat:@"%@:00~%@:00 >",self.disturbArr[0],self.disturbArr[1]] ;
        }else{
            timeRightLabel.text =@"请选择时段 >";
        }
        [cell.contentView addSubview:timeRightLabel];

        
    }else{
        
            UILabel *titleLabel= [[UILabel alloc]init];
            titleLabel.frame = CGRectMake(16, 0, SCREEN_WIDTH-32, 120);
            titleLabel.font = [UIFont systemFontOfSize:13];
            titleLabel.textAlignment = NSTextAlignmentCenter;
           titleLabel.textColor = [UIColor colorWithHexString:@"#424242"];
        titleLabel.numberOfLines = 0;
        titleLabel.text = instructionStr;
        [cell.contentView addSubview:titleLabel];
        
    }
    
        
        
        
        return cell;
        
}

-(void)selectGoldsClick:(UIButton *)sender{
    selectGolds = self.videoGoldsArr[sender.tag-1000];
    myVideoGoldLabel.text = [NSString stringWithFormat:@"我的服务聊币：%@",selectGolds];
    if (sender == _lastBtn)
    {
        return;
    }
    sender.backgroundColor = [UIColor colorWithHexString:@"#ff5252"];
    sender.selected = YES;
    _lastBtn.selected = NO;
    _lastBtn.backgroundColor = [UIColor colorWithHexString:@"#ffffff"];
    _lastBtn = sender;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *headView = [[UIView alloc]init];
    headView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 48);
    
    UILabel *titleLabel = [[UILabel alloc]init];
    titleLabel.frame = CGRectMake(16, 0, 80, 48);
    titleLabel.text = @"聊一聊";
    titleLabel.font = [UIFont systemFontOfSize:16];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    [headView addSubview:titleLabel];
    
    UISwitch *switv = [[UISwitch alloc]init];
    
    switv.frame = CGRectMake(SCREEN_WIDTH-62,7, 44, 34);
    [headView addSubview:switv];
    
   
    [switv addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    
    //设置on一边的背景颜色
    switv.onTintColor = [UIColor colorWithHexString:@"#ff5252"];
    
    //off一边的颜色
    
    switv.tintColor = [UIColor lightGrayColor];
    
    //滑块的颜色
    switv.thumbTintColor = [UIColor whiteColor];
    
    if (self.isOpenSwitv == YES) {
         [switv setOn:YES animated:YES];
    }else{
    
    if (isOpen == YES) {
        //默认开关
        [switv setOn:YES animated:YES];
    }else{
        [switv setOn:NO animated:YES];
    }
  
    
    }
    return headView;
}

- (void)switchAction:(UISwitch *)sender{
    
    if (self.isOpenSwitv == YES) {
       
        self.isOpenSwitv = NO;
        isOpen = NO;
        isVideo = @"0";
    }else{

    
    if (isOpen == YES) {//如果是0，就把1赋给字典,打开cell
        isOpen = NO;
        isVideo = @"0";
    }else{//反之关闭cell
        isOpen = YES;
         isVideo = @"1";
    }}
    
    [self.tableView reloadData];
//    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0]withRowAnimation:UITableViewRowAnimationFade];//有动画的刷新
}





- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 1) {
        [UIView animateWithDuration:0.25 animations:^{
            self.modalBtn.hidden = NO;
        } completion:^(BOOL finished) {
            self.agePickerView.center = self.view.center;
        }];
        
        
    }
}

#pragma mark   -------配置导航栏
- (void)setNav{
    
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
    
    
    //右上角筛选按钮
  UIButton*  saveBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 25)];
    
    if (self.isOpenSwitv ==YES) {
        [saveBtn setTitle:@"开通" forState:UIControlStateNormal];
    }else{
        
            [saveBtn setTitle:@"保存" forState:UIControlStateNormal];

       
  }
    [saveBtn setTitleColor:[UIColor colorWithHexString:@"#424242"] forState:UIControlStateNormal];
    saveBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [saveBtn addTarget:self action:@selector(saveClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:saveBtn];
    self.navigationItem.rightBarButtonItem = rightItem;

}
-(void)saveClick{
   
    if ([CommonTool dx_isNullOrNilWithObject:beginUserAge] || [CommonTool dx_isNullOrNilWithObject:endUserAge]) {
        disturbTimeStr = @"";
        [self addUserVideoInstall];
    }else{
        
        disturbTimeStr = [NSString  stringWithFormat:@"%@,%@",beginUserAge,endUserAge];
         [self addUserVideoInstall];
    }
   
}

-(void)addUserVideoInstall{

    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/video/addUserVideoInstall",REQUESTHEADER] andParameter:@{@"userId":[CommonTool getUserID],@"disturbTime":disturbTimeStr,@"isVideo":isVideo,@"videoGold":selectGolds} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        [MBProgressHUD hideHUD];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            [MBProgressHUD showSuccess:@"设置成功"];
           
            if (self.isOpenSwitv == YES) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"拍摄宣传视频" message:@"开通成功，拍一段有趣的视频吸引更多人找您聊天吧！" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                alertView.tag = 1006;
                [alertView show];

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
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1006) {
        if (0 == buttonIndex) {
            [self.navigationController popViewControllerAnimated:YES];
        }
        if (1 == buttonIndex) {
            VideoRecordingVC *vc =[[VideoRecordingVC alloc]init];
            [self.navigationController pushViewController:vc animated:NO];
        }
    }

}
- (void)goBack{
    if (self.isOpenSwitv == NO ){
        if ([CommonTool dx_isNullOrNilWithObject:beginUserAge] || [CommonTool dx_isNullOrNilWithObject:endUserAge]) {
            disturbTimeStr = @"";
            [self goBackAddUserVideoInstall];
        }else{
            
            disturbTimeStr = [NSString  stringWithFormat:@"%@,%@",beginUserAge,endUserAge];
            [self goBackAddUserVideoInstall];
        }

    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}


-(void)goBackAddUserVideoInstall{
    
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/video/addUserVideoInstall",REQUESTHEADER] andParameter:@{@"userId":[CommonTool getUserID],@"disturbTime":disturbTimeStr,@"isVideo":isVideo,@"videoGold":selectGolds} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        [MBProgressHUD hideHUD];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
           
            
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
