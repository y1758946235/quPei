//
//  PublishDetailSkillViewController.m
//  LvYue
//
//  Created by 郑洲 on 16/4/7.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "PublishDetailSkillViewController.h"
#import "MBProgressHUD+NJ.h"
#import "LYHttpPoster.h"
#import "LYUserService.h"
#import "KnowViewController.h"

@interface PublishDetailSkillViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate, UIAlertViewDelegate>{
    
    UITableView *_tableView;
    
    BOOL _isShowField;
    
    NSMutableString *serviceType;
    NSMutableString *serviceTime;
    
    UITextField *addressField;
    UILabel *viewNoteLabel;
    
    UITextField *gradeFiled;
    UITextView *detailView;
    UITextView *advantageView;
    
    UILabel *underLineLabel;
    UITextField *underLine;
    UILabel *units1;
    UILabel *onLineLabel;
    UITextField *onLine;
    UILabel *units2;
    
    UIButton *_firstBtn;
    UIButton *_secondBtn;
    UIButton *_thirdBtn;
}


@end

@implementation PublishDetailSkillViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"发布技能";
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [_tableView addGestureRecognizer:tap];
}

- (void)tap:(UITapGestureRecognizer *)tap {
    [self.view endEditing:YES];
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    }];
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
//            noteLabel.text = @"为保护用户隐私，在未达成交易意向前不能在服务介绍中留下电话号码等联系方式";
            noteLabel.text = @"为保护用户隐私";
            noteLabel.textColor = RGBACOLOR(53, 98, 254, 1);
            noteLabel.textAlignment = NSTextAlignmentCenter;
            noteLabel.numberOfLines = 0;
            noteLabel.font = [UIFont systemFontOfSize:14];
            [cell addSubview:noteLabel];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else if (indexPath.row == 1) {
        static NSString *cellId2 = @"skillCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId2];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId2];
            
            UILabel *tiemLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 20, 80, 20)];
            tiemLabel.text = @"技能品类:";
            tiemLabel.font = [UIFont systemFontOfSize:17];
            [cell addSubview:tiemLabel];
            
            UILabel *skillType = [[UILabel alloc] initWithFrame:CGRectMake(50, 20, 150, 20)];
            skillType.text = _skillName;
            skillType.textAlignment = NSTextAlignmentCenter;
            [cell addSubview:skillType];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else if (indexPath.row == 2) {
        static NSString *cellId3 = @"cell3";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId3];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId3];
            
            UILabel *cellLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, SCREEN_WIDTH - 20, 20)];
            cellLabel.text = @"活动方式(多选)";
            cellLabel.font = [UIFont systemFontOfSize:17];
            [cell addSubview:cellLabel];
            
            addressField = [[UITextField alloc] initWithFrame:CGRectMake(15, 85, SCREEN_WIDTH - 30, 30)];
            addressField.borderStyle = UITextBorderStyleRoundedRect;
            addressField.placeholder = @"活动地址";
            addressField.font = [UIFont systemFontOfSize:13];
            addressField.delegate = self;
            addressField.returnKeyType = UIReturnKeyDone;
            [cell addSubview:addressField];
            
//            underLineLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, cell.frame.size.height - 65, 100, 20)];
//            underLineLabel.text = @"线下服务报价";
//            [cell addSubview:underLineLabel];
//            
//            underLine = [[UITextField alloc] initWithFrame:CGRectMake(115, cell.frame.size.height - 62, 100, 26)];
//            underLine.borderStyle = UITextBorderStyleRoundedRect;
//            underLine.delegate = self;
//            underLine.returnKeyType = UIReturnKeyDone;
//            underLine.keyboardType = UIKeyboardTypeDecimalPad;
//            [cell addSubview:underLine];
//            
//            units1 = [[UILabel alloc] initWithFrame:CGRectMake(215, cell.frame.size.height - 65, 100, 20)];
//            units1.text = @"元/小时";
//            [cell addSubview:units1];
//            
//            onLineLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, cell.frame.size.height - 35, 100, 20)];
//            onLineLabel.text = @"线上服务报价";
//            [cell addSubview:onLineLabel];
//            
//            onLine = [[UITextField alloc] initWithFrame:CGRectMake(115, cell.frame.size.height - 32, 100, 26)];
//            onLine.borderStyle = UITextBorderStyleRoundedRect;
//            onLine.delegate = self;
//            onLine.returnKeyType = UIReturnKeyDone;
//            onLine.keyboardType = UIKeyboardTypeDecimalPad;
//            [cell addSubview:onLine];
//            
//            units2 = [[UILabel alloc] initWithFrame:CGRectMake(215, cell.frame.size.height - 35, 100, 20)];
//            units2.text = @"元/分钟";
//            [cell addSubview:units2];
            
        }
        if (_isShowField) {
            addressField.hidden = NO;
//            underLineLabel.frame = CGRectMake(15, 125, 120, 20);
//            underLine.frame = CGRectMake(135, 122, 100, 26);
//            units1.frame = CGRectMake(245, 125, 100, 20);
//            onLineLabel.frame = CGRectMake(15, 155, 120, 20);
//            onLine.frame = CGRectMake(135, 152, 100, 26);
//            units2.frame = CGRectMake(245, 155, 100, 20);
        }else {
            addressField.hidden = YES;
//            underLineLabel.frame = CGRectMake(15, 85, 120, 20);
//            underLine.frame = CGRectMake(135, 82, 100, 26);
//            units1.frame = CGRectMake(245, 85, 100, 20);
//            onLineLabel.frame = CGRectMake(15, 115, 120, 20);
//            onLine.frame = CGRectMake(135, 112, 100, 26);
//            units2.frame = CGRectMake(245, 115, 100, 20);
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
    }else if (indexPath.row == 3) {
        static NSString *cellId4 = @"cell4";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId4];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId4];
            
            UILabel *cellLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, SCREEN_WIDTH - 20, 20)];
            cellLabel.text = @"活动时间(多选)";
            cellLabel.font = [UIFont systemFontOfSize:17];
            [cell addSubview:cellLabel];
            
            NSArray *arr = @[@"周一",@"周二",@"周三",@"周四",@"周五",@"周六",@"周日"];
            
            CGFloat btnWidth = (SCREEN_WIDTH - 50) / 4;
            for (int i = 0; i < 7; i++) {
                UIButton *btn = [[UIButton alloc] init];
                if (i < 4) {
                    btn.frame = CGRectMake(10 + i * (btnWidth + 10), 45, btnWidth, 30);
                }else {
                    btn.frame = CGRectMake(10 + (i - 4) * (btnWidth + 10), 85, btnWidth, 30);
                }
                [btn setTitle:arr[i] forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                btn.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
                btn.titleLabel.font = [UIFont systemFontOfSize:13];
                btn.layer.cornerRadius = 5.0;
                [btn addTarget:self action:@selector(chooseTime:) forControlEvents:UIControlEventTouchUpInside]; 
                [cell addSubview:btn];
            }
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else if (indexPath.row == 4) {
        static NSString *cellId5 = @"cell5";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId5];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId5];
            
            UILabel *cellLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, SCREEN_WIDTH - 20, 20)];
            cellLabel.text = @"特长介绍";
            cellLabel.font = [UIFont systemFontOfSize:17];
            [cell addSubview:cellLabel];
            
            detailView = [[UITextView alloc] initWithFrame:CGRectMake(15, 45, SCREEN_WIDTH - 30, 100)];
            detailView.layer.cornerRadius = 5.0;
            detailView.layer.borderWidth = 1.0;
            detailView.layer.borderColor = [UIColor grayColor].CGColor;
            detailView.delegate = self;
            detailView.returnKeyType = UIReturnKeyDone;
            [cell addSubview:detailView];
            
            viewNoteLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, SCREEN_WIDTH - 40, 20)];
            viewNoteLabel.textColor = [UIColor lightGrayColor];
            viewNoteLabel.text = @"请填写与技能相关的介绍，最少15个字。";
            viewNoteLabel.font = [UIFont systemFontOfSize:14];
            [detailView addSubview:viewNoteLabel];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else if (indexPath.row == 5) {
        static NSString *cellId6 = @"cell6";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId6];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId6];
            
            UILabel *cellLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, SCREEN_WIDTH - 20, 20)];
            cellLabel.text = @"请描述您的优势以提高成交率";
            cellLabel.font = [UIFont systemFontOfSize:17];
            [cell addSubview:cellLabel];
            
            advantageView = [[UITextView alloc] initWithFrame:CGRectMake(15, 45, SCREEN_WIDTH - 30, 100)];
            advantageView.layer.cornerRadius = 5.0;
            advantageView.layer.borderWidth = 1.0;
            advantageView.layer.borderColor = [UIColor grayColor].CGColor;
            advantageView.delegate = self;
            advantageView.returnKeyType = UIReturnKeyDone;
            [cell addSubview:advantageView];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else if (indexPath.row == 6) {
        static NSString *cellId7 = @"cell7";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId7];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId7];
            
            UILabel *cellLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, SCREEN_WIDTH - 20, 20)];
            cellLabel.text = @"学历(选填)";
            cellLabel.font = [UIFont systemFontOfSize:17];
            [cell addSubview:cellLabel];
            
            gradeFiled = [[UITextField alloc] initWithFrame:CGRectMake(110, 12, 110, 26)];
            gradeFiled.delegate = self;
            gradeFiled.borderStyle = UITextBorderStyleRoundedRect;
            gradeFiled.returnKeyType = UIReturnKeyDone;
            [cell addSubview:gradeFiled];
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
            [publishBtn addTarget:self action:@selector(publishSkill) forControlEvents:UIControlEventTouchUpInside];
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
    }else if (indexPath.row == 2) {
        if (_isShowField) {
            return 125;
        }
        return 85;
    }else if (indexPath.row == 3) {
        return 130;
    }else if (indexPath.row == 6) {
        return 50;
    }else if (indexPath.row == 7) {
        return 70;
    }
    return 160;
}

- (void)chooseTime:(UIButton *)button {
    NSArray *array = [serviceTime componentsSeparatedByString:@","];
    NSMutableArray *mArray = [[NSMutableArray alloc] initWithArray:array];
    if (button.selected == YES) {
        button.selected = NO;
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [mArray removeObject:[NSString stringWithFormat:@"%@",button.titleLabel.text]];
    }
    else{
        button.selected = YES;
        [button setTitleColor:[UIColor colorWithRed:29/255.0 green:189/255.0 blue:159/255.0 alpha:1] forState:UIControlStateNormal];
        [mArray addObject:[NSString stringWithFormat:@"%@",button.titleLabel.text]];
    }
    serviceTime = nil;
    serviceTime = [NSMutableString stringWithString:@""];
    for (NSString *subString in mArray) {
        if (![subString isEqualToString:@""]) {
            [serviceTime appendString:[NSString stringWithFormat:@"%@,",subString]];
        }
    }
    if (serviceTime.length > 0) {
        [serviceTime replaceCharactersInRange:NSMakeRange(serviceTime.length - 1, 1) withString:@""];
    }
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
        if (_isShowField) {
            addressField.hidden = NO;
            [UIView animateWithDuration:0.3 animations:^{
                underLineLabel.frame = CGRectMake(15, 125, 120, 20);
                underLine.frame = CGRectMake(135, 122, 100, 26);
                units1.frame = CGRectMake(245, 125, 100, 20);
                onLineLabel.frame = CGRectMake(15, 155, 120, 20);
                onLine.frame = CGRectMake(135, 152, 100, 26);
                units2.frame = CGRectMake(245, 155, 100, 20);
            }];
        }else {
            addressField.hidden = YES;
            [UIView animateWithDuration:0.3 animations:^{
                underLineLabel.frame = CGRectMake(15, 85, 120, 20);
                underLine.frame = CGRectMake(135, 82, 100, 26);
                units1.frame = CGRectMake(245, 85, 100, 20);
                onLineLabel.frame = CGRectMake(15, 115, 120, 20);
                onLine.frame = CGRectMake(135, 112, 100, 26);
                units2.frame = CGRectMake(245, 115, 100, 20);
            }];
        }
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
            if (_firstBtn.selected == NO && _secondBtn.selected == NO) {
                [MBProgressHUD showSuccess:@"线下服务报价可不填" toView:self.view];
            }
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

- (void)publishSkill {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    if ([[userDefaults objectForKey:@"alipay_Id"] isEqualToString:@""] && [[userDefaults objectForKey:@"weixin_Id"] isEqualToString:@""]) {
//        [MBProgressHUD showError:@"请到资料认证处先完善收款账号信息"];
//        return;
//    }
    
    if (serviceType.length == 0) {
        [MBProgressHUD showError:@"请选择活动类型"];
        return;
    }
    if (addressField.text.length == 0 && _isShowField) {
        [MBProgressHUD showError:@"请输入详细地址"];
        return;
    }
//    if (onLine.text.length == 0 && [serviceType rangeOfString:@"2"].length != 0) {
//        [MBProgressHUD showError:@"请输入线上价格"];
//        return;
//    }
//    if (underLine.text.length == 0 && ([serviceType rangeOfString:@"1"].length != 0 || [serviceType rangeOfString:@"0"].length != 0)) {
//        [MBProgressHUD showError:@"请输入线下价格"];
//        return;
//    }
//    if ([onLine.text rangeOfString:@"."].length > 1 || [underLine.text rangeOfString:@"."].length > 1) {
//        [MBProgressHUD showError:@"价格格式错误"];
//        return;
//    }
    if (serviceTime.length == 0) {
        [MBProgressHUD showError:@"请选择活动时间"];
        return;
    }
    if (detailView.text.length < 15) {
        [MBProgressHUD showError:@"活动详情应多于15字"];
        return;
    }
    if (advantageView.text.length == 0) {
        [MBProgressHUD showError:@"请输入优点"];
        return;
    }
    if ([[userDefaults objectForKey:@"auth_identity"] isEqualToString:@"0"] || [[userDefaults objectForKey:@"auth_video"] isEqualToString:@"0"]) {
        UIAlertView *aleatView = [[UIAlertView alloc] initWithTitle:nil message:@"视频和身份认证后能获得更多信任，您还没有经过认证" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:@"马上去认证", nil];
        [aleatView show];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField != gradeFiled) {
        self.view.frame = CGRectMake(0, -180, SCREEN_WIDTH, SCREEN_HEIGHT);
    }else {
        self.view.frame = CGRectMake(0, -220, SCREEN_WIDTH, SCREEN_HEIGHT);
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    }];
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    self.view.frame = CGRectMake(0, -190, SCREEN_WIDTH, SCREEN_HEIGHT);
}

- (void)textViewDidChange:(UITextView *)textView {
    if (textView == detailView && textView.text.length > 0) {
        viewNoteLabel.hidden = YES;
    }else if (textView == detailView && textView.text.length == 0) {
        viewNoteLabel.hidden = NO;
    }
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        KnowViewController *know = [[KnowViewController alloc] init];
        [know setHidesBottomBarWhenPushed:YES];
        know.car = [[userDefaults objectForKey:@"auth_car"] integerValue];
        know.edu = [[userDefaults objectForKey:@"auth_edu"] integerValue];
        know.identity = [[userDefaults objectForKey:@"auth_identity"] integerValue];
        know.video = [[userDefaults objectForKey:@"auth_video"] integerValue];
        know.userType = [[userDefaults objectForKey:@"type"] integerValue];
        know.alipay = [userDefaults objectForKey:@"alipay_Id"];
        know.weixin = [userDefaults objectForKey:@"weixin_Id"];
        know.provide_stay = @"0";
        [self.navigationController pushViewController:know animated:YES];
    }else {
        [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/need/publishSkill",REQUESTHEADER] andParameter:@{@"onlinePrice":@"25",@"user_id":[LYUserService sharedInstance].userID,@"price":@"5",@"num":[NSNumber numberWithInteger:self.num],@"serviceType":serviceType,@"address":addressField.text,@"time":serviceTime,@"detail":detailView.text,@"edu":gradeFiled.text,@"advantage":advantageView.text,@"name":_skillName,@"small_id":[NSNumber numberWithInteger:self.num]} success:^(id successResponse) {
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
