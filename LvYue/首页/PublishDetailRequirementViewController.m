//
//  PublishDetailRequirementViewController.m
//  LvYue
//
//  Created by 郑洲 on 16/4/6.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "PublishDetailRequirementViewController.h"
#import "LYHttpPoster.h"
#import "MBProgressHUD+NJ.h"
#import "LYUserService.h"

@interface PublishDetailRequirementViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>{
    
    UITableView *_tableView;
    
    BOOL _isShowField;
    
    NSString *dateString;
    NSInteger expiryTime;
    NSInteger sex;
    NSMutableString *serviceType;
    NSMutableString *age;
    
    UITextField *addressField;
    UITextView *_textView;
    
    UIButton *_firstBtn;
    UIButton *_secondBtn;
    UIButton *_thirdBtn;
    
    UIButton *currentTime;
    
    NSString *_yearStr;//获得当前pickView已选的年份
    NSString *_monthStr;//获得当前pickView已选的月份
    NSString *_dayStr;//获得当前pickView已选的日期
    
    UIPickerView *_pickView;//选择时间
    UIView *_pickViewToobar;//PickView的操作条
    
    NSArray *_yearArray;//年份数据源
    NSArray *_monthArray;//月份数据源
    NSArray *_dayArray;//日期数据源
    UIButton *_shadowBtn;//蒙尘效果按钮
}

@end

@implementation PublishDetailRequirementViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"发布需求";
    _isShowField = NO;
    expiryTime = 1;
    sex = 0;
    age = [NSMutableString stringWithString:@""];
    serviceType = [NSMutableString stringWithString:@""];
    
    _yearArray = @[@"2016",@"2017",@"2018",@"2019"];
    _monthArray = @[@"01",@"02",@"03",@"04",@"05",@"06",@"07",@"08",@"09",@"10",@"11",@"12"];
    _dayArray = @[@"01",@"02",@"03",@"04",@"05",@"06",@"07",@"08",@"09",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23",@"24",@"25",@"26",@"27",@"28",@"29",@"30",@"31"];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 8;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        static NSString *cellId1 = @"noteCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId1];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId1];
            
            UILabel *noteLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, SCREEN_WIDTH - 30, 40)];
//            noteLabel.text = @"我们会把您的需求推送给很多有同样技能的服务者，以便您获得合适的服务";
            noteLabel.text = @"我们会把您的需求推送给有同样特长的伙伴，以便您更容易找到共同兴趣爱好者参加活动";
            noteLabel.textColor = RGBACOLOR(53, 98, 254, 1);
            noteLabel.textAlignment = NSTextAlignmentCenter;
            noteLabel.numberOfLines = 0;
            noteLabel.font = [UIFont systemFontOfSize:14];
            [cell addSubview:noteLabel];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else if (indexPath.row == 1) {
        static NSString *cellId2 = @"timeCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId2];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId2];
            
            UILabel *tiemLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 20, 80, 20)];
            tiemLabel.text = @"预约时间";
            tiemLabel.font = [UIFont systemFontOfSize:17];
            [cell addSubview:tiemLabel];
            
            NSDate *currentDate = [NSDate date];//获取当前时间，日期
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"YYYY-MM-dd"];
            dateString = [dateFormatter stringFromDate:currentDate];
            
            NSDate *now = [NSDate date];
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
            NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
            
            NSInteger year = [dateComponent year];
            NSInteger month = [dateComponent month];
            NSInteger day = [dateComponent day];
            
            _yearStr = [NSString stringWithFormat:@"%ld",(long)year];
            _monthStr = [NSString stringWithFormat:@"%02ld",(long)month];
            _dayStr = [NSString stringWithFormat:@"%02ld",(long)day];
            
            currentTime = [[UIButton alloc] initWithFrame:CGRectMake(95, 15, dateString.length * 12, 30)];
            [currentTime setTitle:dateString forState:UIControlStateNormal];
            [currentTime setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            currentTime.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
            currentTime.clipsToBounds = YES;
            currentTime.layer.cornerRadius = 5.0;
            [currentTime addTarget:self action:@selector(changeTime:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:currentTime];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else if (indexPath.row == 2) {
        static NSString *cellId3 = @"cell3";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId3];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId3];
            
            UILabel *cellLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, SCREEN_WIDTH - 20, 20)];
            cellLabel.text = @"需求有效期(单选)";
            cellLabel.font = [UIFont systemFontOfSize:17];
            [cell addSubview:cellLabel];
            
            UIButton *firstBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, 45, 90, 30)];
            [firstBtn setTitle:@"8天" forState:UIControlStateNormal];
            [firstBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            firstBtn.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
            firstBtn.titleLabel.font = [UIFont systemFontOfSize:13];
            firstBtn.layer.cornerRadius = 5.0;
            firstBtn.tag = 201;
            [firstBtn addTarget:self action:@selector(chooseExpiryTime:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:firstBtn];
            
            UIButton *secondBtn = [[UIButton alloc] initWithFrame:CGRectMake(115, 45, 90, 30)];
            [secondBtn setTitle:@"1天" forState:UIControlStateNormal];
            [secondBtn setTitleColor:[UIColor colorWithRed:29/255.0 green:189/255.0 blue:159/255.0 alpha:1] forState:UIControlStateNormal];
            secondBtn.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
            secondBtn.titleLabel.font = [UIFont systemFontOfSize:13];
            secondBtn.layer.cornerRadius = 5.0;
            secondBtn.tag = 202;
            [secondBtn addTarget:self action:@selector(chooseExpiryTime:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:secondBtn];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else if (indexPath.row == 3) {
        static NSString *cellId4 = @"cell4";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId4];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId4];
            
            UILabel *cellLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, SCREEN_WIDTH - 20, 20)];
            cellLabel.text = @"性别要求(单选)";
            cellLabel.font = [UIFont systemFontOfSize:17];
            [cell addSubview:cellLabel];
            
            UIButton *firstBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, 45, 90, 30)];
            [firstBtn setTitle:@"不限" forState:UIControlStateNormal];
            [firstBtn setTitleColor:[UIColor colorWithRed:29/255.0 green:189/255.0 blue:159/255.0 alpha:1] forState:UIControlStateNormal];
            firstBtn.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
            firstBtn.titleLabel.font = [UIFont systemFontOfSize:13];
            firstBtn.layer.cornerRadius = 5.0;
            firstBtn.tag = 301;
            [firstBtn addTarget:self action:@selector(chooseSex:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:firstBtn];
            
            UIButton *secondBtn = [[UIButton alloc] initWithFrame:CGRectMake(115, 45, 90, 30)];
            [secondBtn setTitle:@"男" forState:UIControlStateNormal];
            [secondBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            secondBtn.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
            secondBtn.titleLabel.font = [UIFont systemFontOfSize:13];
            secondBtn.layer.cornerRadius = 5.0;
            secondBtn.tag = 302;
            [secondBtn addTarget:self action:@selector(chooseSex:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:secondBtn];
            
            UIButton *thirdBtn = [[UIButton alloc] initWithFrame:CGRectMake(215, 45, 90, 30)];
            [thirdBtn setTitle:@"女" forState:UIControlStateNormal];
            [thirdBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            thirdBtn.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
            thirdBtn.titleLabel.font = [UIFont systemFontOfSize:13];
            thirdBtn.layer.cornerRadius = 5.0;
            thirdBtn.tag = 303;
            [thirdBtn addTarget:self action:@selector(chooseSex:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:thirdBtn];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else if (indexPath.row == 4) {
        static NSString *cellId5 = @"cell5";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId5];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId5];
            
            UILabel *cellLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, SCREEN_WIDTH - 20, 20)];
            cellLabel.text = @"活动方式(多选)";
            cellLabel.font = [UIFont systemFontOfSize:17];
            [cell addSubview:cellLabel];
            
            addressField = [[UITextField alloc] initWithFrame:CGRectMake(15, 90, SCREEN_WIDTH - 30, 30)];
            addressField.borderStyle = UITextBorderStyleRoundedRect;
            addressField.placeholder = @"请输入详细地址";
            addressField.font = [UIFont systemFontOfSize:13];
            addressField.delegate = self;
            addressField.hidden = !_isShowField;
            addressField.returnKeyType = UIReturnKeyDone;
            [cell addSubview:addressField];
        }
        
        [_firstBtn removeFromSuperview];
        [_secondBtn removeFromSuperview];
        [_thirdBtn removeFromSuperview];
        
        if (!_firstBtn) {
            _firstBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, 45, 90, 30)];
            [_firstBtn setTitle:@"TA来找我" forState:UIControlStateNormal];
            [_firstBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            _firstBtn.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
            _firstBtn.titleLabel.font = [UIFont systemFontOfSize:13];
            _firstBtn.layer.cornerRadius = 5.0;
            _firstBtn.tag = 401;
            [_firstBtn addTarget:self action:@selector(chooseType:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [cell addSubview:_firstBtn];
        
        if (!_secondBtn) {
            _secondBtn = [[UIButton alloc] initWithFrame:CGRectMake(115, 45, 90, 30)];
            [_secondBtn setTitle:@"我去找TA" forState:UIControlStateNormal];
            [_secondBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_secondBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            _secondBtn.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
            _secondBtn.titleLabel.font = [UIFont systemFontOfSize:13];
            _secondBtn.layer.cornerRadius = 5.0;
            _secondBtn.tag = 402;
            [_secondBtn addTarget:self action:@selector(chooseType:) forControlEvents:UIControlEventTouchUpInside];
        }
        [cell addSubview:_secondBtn];
        
        if (!_thirdBtn) {
            _thirdBtn = [[UIButton alloc] initWithFrame:CGRectMake(215, 45, 100, 30)];
            [_thirdBtn setTitle:@"电话或网上服务" forState:UIControlStateNormal];
            [_thirdBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_thirdBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            _thirdBtn.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
            _thirdBtn.titleLabel.font = [UIFont systemFontOfSize:13];
            _thirdBtn.layer.cornerRadius = 5.0;
            _thirdBtn.tag = 403;
            [_thirdBtn addTarget:self action:@selector(chooseType:) forControlEvents:UIControlEventTouchUpInside];
        }
        [cell addSubview:_thirdBtn];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else if (indexPath.row == 5) {
        static NSString *cellId6 = @"cell6";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId6];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId6];
            
            UILabel *cellLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, SCREEN_WIDTH - 20, 20)];
            cellLabel.text = @"年龄要求(多选)";
            cellLabel.font = [UIFont systemFontOfSize:17];
            [cell addSubview:cellLabel];
            
            UIButton *firstBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, 45, 90, 30)];
            [firstBtn setTitle:@"18岁-25岁" forState:UIControlStateNormal];
            [firstBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            firstBtn.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
            firstBtn.titleLabel.font = [UIFont systemFontOfSize:13];
            firstBtn.layer.cornerRadius = 5.0;
            firstBtn.tag = 501;
            [firstBtn addTarget:self action:@selector(chooseAge:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:firstBtn];
            
            UIButton *secondBtn = [[UIButton alloc] initWithFrame:CGRectMake(115, 45, 90, 30)];
            [secondBtn setTitle:@"26岁-30岁" forState:UIControlStateNormal];
            [secondBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            secondBtn.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
            secondBtn.titleLabel.font = [UIFont systemFontOfSize:13];
            secondBtn.layer.cornerRadius = 5.0;
            secondBtn.tag = 502;
            [secondBtn addTarget:self action:@selector(chooseAge:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:secondBtn];
            
            UIButton *thirdBtn = [[UIButton alloc] initWithFrame:CGRectMake(215, 45, 90, 30)];
            [thirdBtn setTitle:@"30岁以上" forState:UIControlStateNormal];
            [thirdBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            thirdBtn.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
            thirdBtn.titleLabel.font = [UIFont systemFontOfSize:13];
            thirdBtn.layer.cornerRadius = 5.0;
            thirdBtn.tag = 503;
            [thirdBtn addTarget:self action:@selector(chooseAge:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:thirdBtn];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else if (indexPath.row == 6) {
        static NSString *cellId7 = @"cell7";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId7];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId7];
            
            UILabel *cellLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, SCREEN_WIDTH - 20, 20)];
            cellLabel.text = @"需求详情";
            cellLabel.font = [UIFont systemFontOfSize:17];
            [cell addSubview:cellLabel];
            
            _textView = [[UITextView alloc] initWithFrame:CGRectMake(15, 45, SCREEN_WIDTH - 30, 100)];
            _textView.layer.cornerRadius = 5.0;
            _textView.layer.borderWidth = 1.0;
            _textView.layer.borderColor = [UIColor grayColor].CGColor;
            _textView.delegate = self;
            _textView.returnKeyType = UIReturnKeyDone;
            [cell addSubview:_textView];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else{
        static NSString *cellId = @"cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
            
            UIButton *publishBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, 15, SCREEN_WIDTH - 30,40)];
            publishBtn.backgroundColor = RGBACOLOR(29, 189, 159, 1);
            [publishBtn setTitle:@"发布" forState:UIControlStateNormal];
            publishBtn.layer.cornerRadius = 5.0;
            [publishBtn addTarget:self action:@selector(publishRequirement) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:publishBtn];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 55;
    }else if (indexPath.row == 1) {
        return 60;
    }else if (indexPath.row == 2 || indexPath.row == 3 || indexPath.row == 5) {
        return 90;
    }else if (indexPath.row == 4) {
        if (_isShowField) {
            return 130;
        }
        return 90;
    }else if (indexPath.row == 6) {
        return 160;
    }
    return 70;
}

- (void)chooseType:(UIButton *)button {
    
    NSArray *array = [serviceType componentsSeparatedByString:@","];
    NSMutableArray *mArray = [[NSMutableArray alloc] initWithArray:array];
    
    if (button.tag == 401) {
        
        if (_firstBtn.selected == YES) {
            _firstBtn.selected = NO;
            [_firstBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [mArray removeObject:[NSString stringWithFormat:@"%ld",(long)(button.tag - 401)]];
        }
        else{
            _firstBtn.selected = YES;
            [_firstBtn setTitleColor:[UIColor colorWithRed:29/255.0 green:189/255.0 blue:159/255.0 alpha:1] forState:UIControlStateNormal];
            [mArray addObject:[NSString stringWithFormat:@"%ld",(long)(button.tag - 401)]];
        }
        
        _isShowField = !_isShowField;
        addressField.hidden = !_isShowField;
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:4 inSection:0];
        [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationFade];
    }else if (button.tag == 402) {
        
        if (_secondBtn.selected == YES) {
            _secondBtn.selected = NO;
            [_secondBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [mArray removeObject:[NSString stringWithFormat:@"%ld",(long)(button.tag - 401)]];
        }
        else{
            _secondBtn.selected = YES;
            [_secondBtn setTitleColor:[UIColor colorWithRed:29/255.0 green:189/255.0 blue:159/255.0 alpha:1] forState:UIControlStateNormal];
            [mArray addObject:[NSString stringWithFormat:@"%ld",(long)(button.tag - 401)]];
        }
    }else {
        
        if (_thirdBtn.selected == YES) {
            _thirdBtn.selected = NO;
            [_thirdBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [mArray removeObject:[NSString stringWithFormat:@"%ld",(long)(button.tag - 401)]];
        }
        else{
            _thirdBtn.selected = YES;
            [_thirdBtn setTitleColor:[UIColor colorWithRed:29/255.0 green:189/255.0 blue:159/255.0 alpha:1] forState:UIControlStateNormal];
            [mArray addObject:[NSString stringWithFormat:@"%ld",(long)(button.tag - 401)]];
        }
    }
    
    serviceType = nil;
    serviceType = [NSMutableString stringWithString:@""];
    for (NSString *subString in mArray) {
        if (![subString isEqualToString:@""]) {
            [serviceType appendString:[NSString stringWithFormat:@"%@,",subString]];
        }
    }
    if (serviceType.length > 0) {
        [serviceType replaceCharactersInRange:NSMakeRange(serviceType.length - 1, 1) withString:@""];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.view.frame = CGRectMake(0, -210, SCREEN_WIDTH, SCREEN_HEIGHT);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    }];
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    self.view.frame = CGRectMake(0, -210, SCREEN_WIDTH, SCREEN_HEIGHT);
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [self.view endEditing:YES];
        [UIView animateWithDuration:0.3 animations:^{
            self.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        }];
        return NO;
    } else {
        return YES;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self.view endEditing:YES];
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    }];
}

- (void)chooseExpiryTime:(UIButton *)button {
    if (button.tag == 201) {
        UIButton *otherBtn = [self.view viewWithTag:202];
        [button setTitleColor:[UIColor colorWithRed:29/255.0 green:189/255.0 blue:159/255.0 alpha:1] forState:UIControlStateNormal];
        [otherBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        expiryTime = 8;
    }else {
        UIButton *otherBtn = [self.view viewWithTag:201];
        [button setTitleColor:[UIColor colorWithRed:29/255.0 green:189/255.0 blue:159/255.0 alpha:1] forState:UIControlStateNormal];
        [otherBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        expiryTime = 1;
    }
}

- (void)chooseSex:(UIButton *)button {
    if (button.tag == 301) {
        UIButton *otherBtn = [self.view viewWithTag:302];
        UIButton *anotherBtn = [self.view viewWithTag:303];
        [button setTitleColor:[UIColor colorWithRed:29/255.0 green:189/255.0 blue:159/255.0 alpha:1] forState:UIControlStateNormal];
        [otherBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [anotherBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        sex = 0;
    }else if (button.tag == 302) {
        UIButton *otherBtn = [self.view viewWithTag:301];
        UIButton *anotherBtn = [self.view viewWithTag:303];
        [button setTitleColor:[UIColor colorWithRed:29/255.0 green:189/255.0 blue:159/255.0 alpha:1] forState:UIControlStateNormal];
        [otherBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [anotherBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        sex = 1;
    }else {
        UIButton *otherBtn = [self.view viewWithTag:302];
        UIButton *anotherBtn = [self.view viewWithTag:301];
        [button setTitleColor:[UIColor colorWithRed:29/255.0 green:189/255.0 blue:159/255.0 alpha:1] forState:UIControlStateNormal];
        [otherBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [anotherBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        sex = 2;
    }
}

- (void)chooseAge:(UIButton *)button {
    NSArray *array = [age componentsSeparatedByString:@","];
    NSMutableArray *mArray = [[NSMutableArray alloc] initWithArray:array];
    if (button.selected == YES) {
        button.selected = NO;
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [mArray removeObject:[NSString stringWithFormat:@"%ld",(long)(button.tag - 501)]];
    }
    else{
        button.selected = YES;
        [button setTitleColor:[UIColor colorWithRed:29/255.0 green:189/255.0 blue:159/255.0 alpha:1] forState:UIControlStateNormal];
        [mArray addObject:[NSString stringWithFormat:@"%ld",(long)(button.tag - 501)]];
    }
    age = nil;
    age = [NSMutableString stringWithString:@""];
    for (NSString *subString in mArray) {
        if (![subString isEqualToString:@""]) {
            [age appendString:[NSString stringWithFormat:@"%@,",subString]];
        }
    }
    if (age.length > 0) {
        [age replaceCharactersInRange:NSMakeRange(age.length - 1, 1) withString:@""];
    }
}

- (void)publishRequirement {
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
    
    NSInteger year = [dateComponent year];
    NSInteger month = [dateComponent month];
    NSInteger day = [dateComponent day];
    
    if ([_yearStr integerValue] < year) {
        [MBProgressHUD showError:@"预约时间已过期"];
        return;
    }else if ([_yearStr integerValue] == year) {
        if ([_monthStr integerValue] < month) {
            [MBProgressHUD showError:@"预约时间已过期"];
            return;
        }else if ([_monthStr integerValue] == month) {
            if ([_dayStr integerValue] < day) {
                [MBProgressHUD showError:@"预约时间已过期"];
                return;
            }
        }
    }
    
    if (_isShowField && addressField.text.length == 0) {
        [MBProgressHUD showError:@"请输入详细地址"];
        return;
    }
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/need/publishNeed",REQUESTHEADER] andParameter:@{@"appointmentTime":dateString,@"user_id":[LYUserService sharedInstance].userID,@"expiryTime":[NSNumber numberWithInteger:expiryTime],@"sex":[NSNumber numberWithInteger:sex],@"serviceType":serviceType, @"address":addressField.text,@"detail":_textView.text,@"age":age,@"small_id":[NSNumber numberWithInteger:self.num]} success:^(id successResponse) {
        MLOG(@"结果:%@",successResponse);
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            [MBProgressHUD showSuccess:@"发布成功"];
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"msg"]]];
        }
    } andFailure:^(id failureResponse) {
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
    }];
}

- (void)changeTime:(UIButton *)button {
    if (!_pickView) {
        
        UIButton *shadowBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-TAB_TAB_HEIGHT)];
        [shadowBtn setBackgroundColor:UIColorWithRGBA(191, 191, 191, 0.5)];
        [shadowBtn addTarget:self action:@selector(hiddenPickView) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:shadowBtn];
        _shadowBtn = shadowBtn;
        
        _pickView = [[UIPickerView alloc]initWithFrame:CGRectMake(0,SCREEN_HEIGHT+44, SCREEN_WIDTH, 216)];
        _pickView.delegate = self;
        _pickView.dataSource = self;
        _pickView.backgroundColor = [UIColor whiteColor];
        _pickView.showsSelectionIndicator = YES;
        
        //工具条
        _pickViewToobar = [[UIView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 44)];
        _pickViewToobar.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_pickViewToobar];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 43, SCREEN_WIDTH, 1)];
        line.backgroundColor = LineColor;
        [_pickViewToobar addSubview:line];
        
        UIButton *cancleBtn = [[UIButton alloc]initWithFrame:CGRectMake(Kinterval, 0, 40, _pickViewToobar.frame.size.height)];
        [cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
        [cancleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [cancleBtn addTarget:self action:@selector(pickViewOperateClick:) forControlEvents:UIControlEventTouchUpInside];
        [_pickViewToobar addSubview:cancleBtn];
        
        UIButton *achiveBtn = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 50, 0, 40, _pickViewToobar.frame.size.height)];
        [achiveBtn setTitle:@"完成" forState:UIControlStateNormal];
        achiveBtn.tag = 1;
        [achiveBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [achiveBtn addTarget:self action:@selector(pickViewOperateClick:) forControlEvents:UIControlEventTouchUpInside];
        [_pickViewToobar addSubview:achiveBtn];
        
        //获取当前时间
        NSDate *now = [NSDate date];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
        NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
        
        NSInteger year = [dateComponent year];
        NSInteger month = [dateComponent month];
        NSInteger day = [dateComponent day];
        
        _yearStr = [NSString stringWithFormat:@"%ld",(long)year];
        _monthStr = [NSString stringWithFormat:@"%02ld",(long)month];
        _dayStr = [NSString stringWithFormat:@"%02ld",(long)day];
        
        switch (year) {
            case 2016:
                [_pickView selectRow:0 inComponent:0 animated:year];
                break;
            case 2017:
                [_pickView selectRow:1 inComponent:0 animated:year];
                break;
            case 2018:
                [_pickView selectRow:2 inComponent:0 animated:year];
                break;
            case 2019:
                [_pickView selectRow:3 inComponent:0 animated:year];
                break;
            default:
                [_pickView selectRow:5 inComponent:0 animated:year];
                break;
        }
        
        switch (month) {
            case 1:
                [_pickView selectRow:0 inComponent:1 animated:month];
                break;
            case 2:
                [_pickView selectRow:1 inComponent:1 animated:month];
                break;
            case 3:
                [_pickView selectRow:2 inComponent:1 animated:month];
                break;
            case 4:
                [_pickView selectRow:3 inComponent:1 animated:month];
                break;
            case 5:
                [_pickView selectRow:4 inComponent:1 animated:month];
                break;
            case 6:
                [_pickView selectRow:5 inComponent:1 animated:month];
                break;
            case 7:
                [_pickView selectRow:6 inComponent:1 animated:month];
                break;
            case 8:
                [_pickView selectRow:7 inComponent:1 animated:month];
                break;
            case 9:
                [_pickView selectRow:8 inComponent:1 animated:month];
                break;
            case 10:
                [_pickView selectRow:9 inComponent:1 animated:month];
                break;
            case 11:
                [_pickView selectRow:10 inComponent:1 animated:month];
                break;
            default:
                [_pickView selectRow:11 inComponent:1 animated:month];
                break;
        }
        
        switch (day) {
            case 1:
                [_pickView selectRow:0 inComponent:2 animated:day];
                break;
            case 2:
                [_pickView selectRow:1 inComponent:2 animated:day];
                break;
            case 3:
                [_pickView selectRow:2 inComponent:2 animated:day];
                break;
            case 4:
                [_pickView selectRow:3 inComponent:2 animated:day];
                break;
            case 5:
                [_pickView selectRow:4 inComponent:2 animated:day];
                break;
            case 6:
                [_pickView selectRow:5 inComponent:2 animated:day];
                break;
            case 7:
                [_pickView selectRow:6 inComponent:2 animated:day];
                break;
            case 8:
                [_pickView selectRow:7 inComponent:2 animated:day];
                break;
            case 9:
                [_pickView selectRow:8 inComponent:2 animated:day];
                break;
            case 10:
                [_pickView selectRow:9 inComponent:2 animated:day];
                break;
            case 11:
                [_pickView selectRow:10 inComponent:2 animated:day];
                break;
            case 12:
                [_pickView selectRow:11 inComponent:2 animated:day];
                break;
            case 13:
                [_pickView selectRow:12 inComponent:2 animated:day];
                break;
            case 14:
                [_pickView selectRow:13 inComponent:2 animated:day];
                break;
            case 15:
                [_pickView selectRow:14 inComponent:2 animated:day];
                break;
            case 16:
                [_pickView selectRow:15 inComponent:2 animated:day];
                break;
            case 17:
                [_pickView selectRow:16 inComponent:2 animated:day];
                break;
            case 18:
                [_pickView selectRow:17 inComponent:2 animated:day];
                break;
            case 19:
                [_pickView selectRow:18 inComponent:2 animated:day];
                break;
            case 20:
                [_pickView selectRow:19 inComponent:2 animated:day];
                break;
            case 21:
                [_pickView selectRow:20 inComponent:2 animated:day];
                break;
            case 22:
                [_pickView selectRow:21 inComponent:2 animated:day];
                break;
            case 23:
                [_pickView selectRow:22 inComponent:2 animated:day];
                break;
            case 24:
                [_pickView selectRow:23 inComponent:2 animated:day];
                break;
            case 25:
                [_pickView selectRow:24 inComponent:2 animated:day];
                break;
            case 26:
                [_pickView selectRow:25 inComponent:2 animated:day];
                break;
            case 27:
                [_pickView selectRow:26 inComponent:2 animated:day];
                break;
            case 28:
                [_pickView selectRow:27 inComponent:2 animated:day];
                break;
            case 29:
                [_pickView selectRow:28 inComponent:2 animated:day];
                break;
            case 30:
                [_pickView selectRow:29 inComponent:2 animated:day];
                break;
            default:
                [_pickView selectRow:30 inComponent:2 animated:day];
                break;
        }

        
        [self.view addSubview:_pickView];
    }
    
    //判断pickerView的位置
    if (_pickView.frame.origin.y == SCREEN_HEIGHT+44) {
        
        [UIView animateWithDuration:0.3 animations:^{
            
            _pickView.frame = CGRectMake(0, SCREEN_HEIGHT - 216, SCREEN_WIDTH, 216);
            _pickViewToobar.frame = CGRectMake(0, SCREEN_HEIGHT - 216 - 44, SCREEN_WIDTH, 44);
        }];
        
        _shadowBtn.hidden = NO;
        
    }else{
        
        [UIView animateWithDuration:0.3 animations:^{
            
            _pickView.frame = CGRectMake(0, SCREEN_HEIGHT + 44, SCREEN_WIDTH, 216);
            _pickViewToobar.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 44);
        }];
        
        _shadowBtn.hidden = YES;
    }
}

- (void)pickViewOperateClick:(UIButton *)sender{
    
    if (sender.tag == 1) {
        //完成
        [self hiddenPickView];
        
        dateString = [NSString stringWithFormat:@"%@-%@-%@",_yearStr,_monthStr,_dayStr];
        
        [currentTime setTitle:dateString forState:UIControlStateNormal];
        
    }else{
        //取消
        [self hiddenPickView];
    }
}

//隐藏时间选择器
- (void)hiddenPickView{
    
    [UIView animateWithDuration:0.3 animations:^{
        
        _pickView.frame = CGRectMake(0, SCREEN_HEIGHT+44, SCREEN_WIDTH, 216);
        _pickViewToobar.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 44);
    }];
    
    _shadowBtn.hidden = YES;
}

#pragma mark - UIPickView 数据源代理方法
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    if (component == 0) {
        return _yearArray.count;
    }else if (component == 1) {
        return _monthArray.count;
    }else {
        return _dayArray.count;
    }
    return 31;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    if (component == 0) {
        return _yearArray[row];
    }else if (component == 1){
        return _monthArray[row];
    }
    return _dayArray[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    NSInteger yearIndex = [_pickView selectedRowInComponent: 0];
    NSInteger monthIndex = [_pickView selectedRowInComponent: 1];
    NSInteger dayIndex = [_pickView selectedRowInComponent: 2];
    
    _yearStr = [_yearArray objectAtIndex: yearIndex];
    _monthStr = [_monthArray objectAtIndex: monthIndex];
    _dayStr = [_dayArray objectAtIndex:dayIndex];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
