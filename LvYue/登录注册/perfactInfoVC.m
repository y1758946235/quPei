//
//  perfactInfoVC.m
//  LvYue
//
//  Created by X@Han on 16/12/23.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "perfactInfoVC.h"
#import "ChangeHeadVC.h"
#import "LYHttpPoster.h"
#import "MBProgressHUD+NJ.h"
#import "LYUserService.h"
#import "QiniuSDK.h"
@interface perfactInfoVC ()<UITableViewDelegate,UITableViewDataSource, UIPickerViewDelegate,UIPickerViewDataSource>{
    UITableView *table;
    NSArray *titleArr;
    UIImageView *headimage; //头像
    UILabel *nickLabel;
    UILabel *sexLabel;
    UILabel *ageLabel;
    UILabel *disStrLabel;//区域
    
    UITextField *nicktf;
    UITextField *sextf;
    UITextField *agetf;
    
    NSString * userNickname;
    NSString * userSex;
    NSString * userAge;
//    NSString * userIcon;
    
    NSMutableArray* _ageArr;
    
    UIButton *sureAgeBtn;
    
    
    NSString * provinceId;
    NSString * cityId;
    NSString * distriId;
    
}
@property(nonatomic,strong)UIButton *modalBtn; //
@property (nonatomic, weak) UIPickerView* agePickerView; //年龄 tag 1001
@property (nonatomic, assign) BOOL ageEnable; //年龄

@property (nonatomic,strong) NSArray *plaIdArr;
@end

@implementation perfactInfoVC
- (UIPickerView *)agePickerView {
    if (!_agePickerView) {
        UIPickerView* pickerView = [[UIPickerView alloc] init];
         pickerView.backgroundColor = [UIColor whiteColor];
        pickerView.width = kMainScreenWidth;
        pickerView.height = kMainScreenHeight-5*56-36-2-40;
        pickerView.x = 0;
        pickerView.y = kMainScreenHeight + pickerView.height;
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
        sureAgeBtn.hidden = YES;
    }];
    
    
    NSInteger selectMin = [_agePickerView selectedRowInComponent:0];
    NSString* ageStr = _ageArr[selectMin];
    userAge = ageStr;
    ageStr = [NSString stringWithFormat:@"%@岁",ageStr];
    ageLabel.text = ageStr;
}

#pragma mark - UIPickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return _ageArr.count;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return _ageArr[row];
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    MLOG(@"pickerView.tag == 1001");
    userAge = [NSString stringWithFormat:@"%ld",row+16] ;
    ageLabel.text = [NSString stringWithFormat:@"%@岁",userAge];
}
- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = NO;
    [super viewWillAppear:animated];
    
  
}

- (void)viewDidLoad {
    [super viewDidLoad];
  
    NSLog(@"22222%@",self.iconID);
    titleArr = @[@"头像",@"昵称",@"性别",@"年龄",@"所在地区"];
    [self setNav];
    
    [self setUI];
    
    userNickname =self.userName;
    //字数限制操作
    if (userNickname.length >= 12) {
        
        userNickname = [userNickname substringToIndex:12];
        
    }
    nicktf.text = userNickname;
    
    userSex = @"";
    userAge = @"";
   
    
    provinceId = @"0";
    cityId = @"0";
    distriId = @"0";
    
    //创建年龄数组
    _ageArr = [[NSMutableArray alloc] init];
    for (int i = 16; i <= 100; i ++) {
        NSString *str = [NSString stringWithFormat:@"%d",i];
        [_ageArr addObject:str];
    }
    
    //创建pickerView出现时同时出现的模态按钮
    _modalBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight)];
    [_modalBtn addTarget:self action:@selector(pickerViewHidden) forControlEvents:UIControlEventTouchUpInside];
    [_modalBtn setBackgroundColor:[UIColor clearColor]];
    _modalBtn.alpha = 1.0;
    _modalBtn.hidden = YES;
    [self.view addSubview:_modalBtn];
    
    sureAgeBtn = [[UIButton alloc]init];
    sureAgeBtn.hidden = YES;
    [sureAgeBtn setTitle:@"确定" forState:UIControlStateNormal];
    sureAgeBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [sureAgeBtn setTitleColor:[UIColor colorWithHexString:@"#ff5252"] forState:UIControlStateNormal];
    sureAgeBtn.frame = CGRectMake(SCREEN_WIDTH-70, 5*56+36+2, 46, 40);
    [self.view addSubview:sureAgeBtn];
    [sureAgeBtn addTarget:self action:@selector(pickerViewHidden) forControlEvents:UIControlEventTouchUpInside];
    
    
    //发送通知  定位到当前位置
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(currentplace:) name:@"currentPerfactInfoVCplace" object:nil];
    [self updataToQiNiu];
}
-(void)updataToQiNiu{
   
   
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/config/getQiniuToken",REQUESTHEADER] andParameter:@{} success:^(id successResponse) {
        
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            
          
            
            NSString * token = successResponse[@"data"];
            
            //获取当前时间
            NSDate *now = [NSDate date];
            NSLog(@"now date is: %@", now);
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
            NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
            NSInteger year = [dateComponent year];
            NSInteger month = [dateComponent month];
            NSInteger day = [dateComponent day];
            NSInteger hour = [dateComponent hour];
            NSInteger minute = [dateComponent minute];
            NSInteger second = [dateComponent second];
            
            
            
           NSString * locationString = [NSString stringWithFormat:@"iosLvYueIcon%ld%ld%ld%ld%ld%ld",(long)year,(long)month,(long)day,(long)hour,(long)minute,(long)second];
            NSLog(@"locationString----%@",locationString);
            //七牛上传图片
              NSData *dataImg = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.iconUrl]];
            QNUploadManager *upManager = [[QNUploadManager alloc] init];
            [upManager putData:dataImg key:locationString token:token
                      complete: ^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                          NSLog(@"%@", info);
                          NSLog(@"%@", resp);
                          if (resp == nil) {
                              [MBProgressHUD hideHUD];
//                              [MBProgressHUD showError:@"上传失败"];
                              //                              return ;
                              self.iconID =@"";
                          }else{
                              self.iconID = locationString;
                               [headimage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",self.iconUrl]] placeholderImage:nil];
                          }
                      }option:nil];
            
            
            
            
            // NSLog(@"999999999999999999999999%@",self.locationString);
            
        }
    } andFailure:^(id failureResponse) {
        
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];

    
    
    
}

//push通知
- (void)currentplace:(NSNotification *)noti {
    disStrLabel.text = self.placee;
    
    self.plaIdArr = [self.placeId componentsSeparatedByString:@","];
    
    
    
    if (self.plaIdArr.count==3) {
        provinceId = self.plaIdArr[0];
        cityId = self.plaIdArr[1];
        distriId = self.plaIdArr[2];
    }else if(self.plaIdArr.count==2){
        provinceId = self.plaIdArr[0];
        cityId = self.plaIdArr[1];
        distriId = @"0";
    }
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)setUI{
    
    table = [[UITableView alloc]initWithFrame:CGRectMake(0, 2, SCREEN_WIDTH, 56*5+36+2) style:UITableViewStylePlain];
    table.delegate = self;
    table.dataSource = self;
    table.rowHeight = 56;
    [self.view addSubview:table];
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 34;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return titleArr.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 34)];
    UILabel *label = [[UILabel alloc]init];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.text = @"完善个人资料，可以更好地体验约会哦~";
    label.textColor = [UIColor colorWithHexString:@"#9e9e9e"];
    label.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
    label.textAlignment = NSTextAlignmentCenter;
    [view addSubview:label];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-52-[label]-52-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(label)]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[label(==12)]-8-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(label)]];
    
   
    return view;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = titleArr[indexPath.row];
    cell.textLabel.textColor = [UIColor colorWithHexString:@"#424242"];
    cell.textLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (indexPath.row==0) {
        headimage = [[UIImageView alloc]init];
        headimage.translatesAutoresizingMaskIntoConstraints = NO;
//        headimage.image = [UIImage imageNamed:@"5.jpg"];
       headimage.layer.cornerRadius = 21;
       headimage.clipsToBounds = YES;
       
        [cell addSubview:headimage];
        [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[headimage(==42)]-32-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(headimage)]];
        [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[headimage(==42)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(headimage)]];
    }
    
    if (indexPath.row==1) {
        nickLabel = [[UILabel alloc]init];
        nickLabel.translatesAutoresizingMaskIntoConstraints = NO;
        if ([CommonTool dx_isNullOrNilWithObject:userNickname]) {
            nickLabel.text = @"请设置";
        }else{
            nickLabel.text = userNickname;
        }
        
        nickLabel.textColor = [UIColor colorWithHexString:@"#bdbdbd"];
        nickLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
        nickLabel.textAlignment = NSTextAlignmentRight;
        [cell addSubview:nickLabel];
        [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[nickLabel(==140)]-32-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(nickLabel)]];
        [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[nickLabel(==14)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(nickLabel)]];
        
    }
    
    if (indexPath.row==2) {
        sexLabel = [[UILabel alloc]init];
        sexLabel.translatesAutoresizingMaskIntoConstraints = NO;
        sexLabel.text = @"请选择";
        sexLabel.textColor = [UIColor colorWithHexString:@"#bdbdbd"];
        sexLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
        sexLabel.textAlignment = NSTextAlignmentRight;
        [cell addSubview:sexLabel];
        [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[sexLabel(==42)]-32-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(sexLabel)]];
        [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[sexLabel(==14)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(sexLabel)]];
        
    }
    
    
    if (indexPath.row==3) {
       ageLabel = [[UILabel alloc]init];
        ageLabel.translatesAutoresizingMaskIntoConstraints = NO;
        ageLabel.text = @"请选择";
        ageLabel.textColor = [UIColor colorWithHexString:@"#bdbdbd"];
        ageLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
        ageLabel.textAlignment = NSTextAlignmentRight;
        [cell addSubview:ageLabel];
        [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[ageLabel(==42)]-32-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(ageLabel)]];
        [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[ageLabel(==14)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(ageLabel)]];
        
    }
    if (indexPath.row==4) {
       disStrLabel  = [[UILabel alloc]init];
        disStrLabel.translatesAutoresizingMaskIntoConstraints = NO;
        disStrLabel.text = @"请选择";
        disStrLabel.textColor = [UIColor colorWithHexString:@"#bdbdbd"];
        disStrLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:14];
        disStrLabel.textAlignment = NSTextAlignmentRight;
        [cell addSubview:disStrLabel];
        [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[disStrLabel(==242)]-32-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(disStrLabel)]];
        [cell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[disStrLabel(==14)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(disStrLabel)]];
        
    }
    
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==0) {
        //换头像
       ChangeHeadVC *VC = [[ChangeHeadVC alloc]init];
         VC.headImage = headimage.image;
        [VC returnText:^(NSString *headIcon,UIImage *image) {
            NSLog(@"^^^^%@",headIcon);
            self.iconID = headIcon;
            headimage.image = image;
            
        }];
       // vc.name      = self.infoModel.name;
        [self.navigationController pushViewController:VC animated:YES];
    }
    if (indexPath.row==1) {
        //昵称
        UIAlertController *nick = [UIAlertController alertControllerWithTitle:@"昵称" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [nick addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = nicktf.text;
           textField.placeholder = @"请输入昵称(限制长度12位)";
            nicktf = textField;
        }];
        UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
           
            nickLabel.text = nicktf.text;
            userNickname = nicktf.text;
            if (userNickname.length>12) {
                
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.mode =MBProgressHUDModeText;//显示的模式
                hud.labelText = @"昵称长度不能超过12位";
                [hud hide:YES afterDelay:1];
                //设置隐藏的时候是否从父视图中移除，默认是NO
                hud.removeFromSuperViewOnHide = YES;
                
            }
        }];
        
        [nick addAction:sure];
        [self presentViewController:nick animated:YES completion:nil];
    }
    if (indexPath.row==2) {
        //性别
//        UIAlertController *sex = [UIAlertController alertControllerWithTitle:@"性别" message:nil preferredStyle:UIAlertControllerStyleAlert];
//        [sex addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
//            textField.placeholder = @"请输入性别";
//            sextf = textField;
//        }];
//        UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            
//            sexLabel.text = sextf.text;
//            
//        }];
//        
//        [sex addAction:sure];
//        [self presentViewController:sex animated:YES completion:nil];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"性别" message:@"温馨提示：性别只能选择一次，之后不可更改" preferredStyle:UIAlertControllerStyleActionSheet];
        // 设置popover指向的item
        alert.popoverPresentationController.barButtonItem = self.navigationItem.leftBarButtonItem;
        
        // 添加按钮
        [alert addAction:[UIAlertAction actionWithTitle:@"男" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            NSLog(@"点击了男按钮");
            sexLabel.text = @"男";
            userSex = @"0";
            
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"女" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            NSLog(@"点击了男按钮");
            sexLabel.text = @"女";
            userSex = @"1";
            
        }]];
//        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
//            NSLog(@"点击了女按钮");
//            sexLabel.text = @"";
//            userSex = @"";
//        }]];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    }
    
    if (indexPath.row==3) {
        //年龄
        self.ageEnable = YES;
        [UIView animateWithDuration:0.25 animations:^{
            self.modalBtn.hidden = NO;
            sureAgeBtn.hidden = NO;
        } completion:^(BOOL finished) {
            self.agePickerView.y = kMainScreenHeight - self.agePickerView.height;
        }];

//        UIAlertController *age = [UIAlertController alertControllerWithTitle:@"年龄" message:nil preferredStyle:UIAlertControllerStyleAlert];
//        [age addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
//            textField.placeholder = @"请输入年龄";
//            agetf = textField;
//            
//        }];
//        UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            ageLabel.text = agetf.text;
//            
//        }];
//        
//        [age addAction:sure];
//        [self presentViewController:age animated:YES completion:nil];
    }
    if (indexPath.row == 4) {
//        //地点

        LocalCountryViewController *local = [[LocalCountryViewController alloc]init];
        //local.preView = @"info";
        [local currnentLocationBlock:^(NSString *currentProvince, NSString *currentCity, NSString *currentDistrict) {
            disStrLabel.text = [NSString stringWithFormat:@"%@%@%@",currentProvince,currentCity,currentDistrict];
            
            
            NSString *a = [currentProvince substringFromIndex:currentProvince.length-1];
            
            if (currentProvince) {
                if ([a isEqualToString:@"省"]) {
                    NSString *str = [currentProvince substringWithRange:NSMakeRange(0, currentProvince.length-1)];
                    [self getProviId:str];
                }else{
                    [self getProviId:currentProvince];}
            }
            
            NSString *b = [currentCity substringFromIndex:currentCity.length-1];
            if (currentCity) {
                if ([b isEqualToString:@"市"]) {
                    NSString *str = [currentCity substringWithRange:NSMakeRange(0, currentCity.length-1)];
                    [self getCityId:str];
                }else{
                    
                    [self getCityId:currentCity];
                }
            }
            
            if (currentDistrict) {
                [self getDisId:currentDistrict];
            }
            
        }];

        [self.navigationController pushViewController:local animated:YES];
    }


}

-(void)getProviId:(NSString *)proStr{
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/cache/getProvinceByName",REQUESTHEADER] andParameter:@{@"provinceName":proStr} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        [MBProgressHUD hideHUD];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            provinceId= [NSString stringWithFormat:@"%@",successResponse[@"data"][@"provinceId"]];
        } else {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
}

-(void)getCityId:(NSString *)cityByName{
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/cache/getCityByName",REQUESTHEADER] andParameter:@{@"cityName":cityByName} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        [MBProgressHUD hideHUD];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            cityId= [NSString stringWithFormat:@"%@",successResponse[@"data"][@"cityId"]];
        } else {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
}
-(void)getDisId:(NSString *)districtName{
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/cache/getDistrictByName",REQUESTHEADER] andParameter:@{@"districtName":districtName} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        [MBProgressHUD hideHUD];
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            distriId= [NSString stringWithFormat:@"%@",successResponse[@"data"][@"districtId"]];
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
    self.title = @"完善个人资料";
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
    [edit setTitle:@"完成" forState:UIControlStateNormal];
    edit.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    [edit addTarget:self action:@selector(saved) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *edited = [[UIBarButtonItem alloc]initWithCustomView:edit];
    self.navigationItem.rightBarButtonItem = edited;
    
}



//返回
#pragma mark   ----退出登录
- (void)back{
    WS(weakSelf)
    NSString *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userId"];
    //    [self dismissViewControllerAnimated:YES completion:nil];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/login/loginOut",REQUESTHEADER] andParameter:@{@"userId":userId} success:^(id successResponse) {
        NSLog(@"退出登录:%@",successResponse);
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            
            [weakSelf performSelector:@selector(gotoLogin) withObject:self afterDelay:1];
        }
    } andFailure:^(id failureResponse) {
        
    }];
    
    
}
-(void)gotoLogin{
    //清除单例数据
    LYUserService *service = [LYUserService sharedInstance];
    NewLoginViewController *loginVC = [[NewLoginViewController alloc]init];
    [service  loginOutWithController:loginVC compeletionBlock:^{
//        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    
}

- (void)saved{
    
    
 
    if ([CommonTool dx_isNullOrNilWithObject:self.iconID]){
        [MBProgressHUD showSuccess:@"请选择头像"];
    }else if ([CommonTool dx_isNullOrNilWithObject:nickLabel.text]) {
        [MBProgressHUD showSuccess:@"请输入您的昵称"];
        
    }else if (userNickname.length >12) {
        [MBProgressHUD showSuccess:@"昵称长度不能超过12位"];
        
    }else if ([CommonTool dx_isNullOrNilWithObject:userSex] || [userSex isEqualToString:@""]) {
        [MBProgressHUD showSuccess:@"请选择性别"];
        
    }else if ([CommonTool dx_isNullOrNilWithObject:userAge]){
        [MBProgressHUD showSuccess:@"请选择年龄"];
    }else if ([CommonTool dx_isNullOrNilWithObject:provinceId] ||[CommonTool dx_isNullOrNilWithObject:cityId]) {
        [MBProgressHUD showSuccess:@"请选择所在地域"];
        
    }else{
     NSString *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userId"];
    //完善个人信息
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/addUserInit",REQUESTHEADER] andParameter:@{@"userId":userId,@"userNickname":userNickname,@"userAge":userAge,@"userSex":userSex,@"userIcon":self.iconID,@"userProvince":provinceId,@"userCity":cityId,@"userDistrict":distriId} success:^(id successResponse) {
        
        
        NSLog(@"初始化信息成功");
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        [user setObject:userNickname forKey:@"userNickname"];
        [user setObject:userSex forKey:@"userSex"];
      [user setObject:userAge forKey:@"userAge"];
        [user setObject:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,self.iconID] forKey:@"userIcon"];
        [user setObject:provinceId forKey:@"userProvince"];
        [user setObject:cityId forKey:@"userCity"];
        [user setObject:distriId forKey:@"userDistrict"];
//        [MBProgressHUD showSuccess:@"初始化信息成功"];
         [CommonTool gotoMain];
        //            //异步更新本地数据库(好友体系中的用户和群组植入)
        //            [self buddyDataBaseOperation];
        //            [self groupDataBaseOperation];
        
    } andFailure:^(id failureResponse) {
        
        
    }];
    }
    
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
