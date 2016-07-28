//
//  OrderTableView.m
//  豆客项目
//
//  Created by Xia Wei on 15/9/29.
//  Copyright © 2015年 Xia Wei. All rights reserved.
//

#import "OrderTableView.h"
#import "OrderPeopleTableViewCell.h"
#import "OrderTimeTableViewCell.h"
#import "OrderServiceTableViewCell.h"



@interface OrderTableView()<UITableViewDelegate,UITableViewDataSource,UIPickerViewDataSource,UIPickerViewDelegate,UITextViewDelegate,UIScrollViewDelegate,UITextFieldDelegate>{
    NSIndexPath *timeCellPath;
    NSDate *fromDate;
    NSDate *localeDate;
    int days;
    NSString *dateStr;
    NSIndexPath *_cellIndexPath;//记录要更改的Cell的路径然后获取更改
    NSIndexPath *_textCellIndexPath;//记录要更改的Cell的路径然后获取更改
    NSInteger _startDate;//旅行开始那天到今天的天数
}

//@property(nonatomic,strong)UIPickerView *pickerV;
@property(nonatomic,strong)UIButton* modalView;
@property(nonatomic,strong)UIDatePicker *datePicker;
@property(nonatomic,strong)UITableView *tableView;


@end


@implementation OrderTableView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self tableViewCreated];
        [self modalViewCreat];
        [self pickerViewCreat];
        _startDate = -1;
    }
    return self;
}

- (void) tableViewCreated{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width  , self.frame.size.height)];
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    UIColor *bgColor = [UIColor colorWithRed:238 / 255.0 green:238 / 255.0 blue:238 / 255.0 alpha:1];
    _tableView.backgroundColor = bgColor;
    _tableView.tag = 555;
    [self addSubview:_tableView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 3) {
        return  30;
    }
    return 12;
}

//把每个Section的头部都设置为透明
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *sectionV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 12)];
    sectionV.alpha = 0;
    return sectionV;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}

//返回每个cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:
            return 60;
            break;
        case 1:
            return 135;
            break;
        case 2:
            return 177;
            break;
        case 3:
            return 108;
        default:
            break;
    }
    return 100;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //导游+姓名
    if (indexPath.section == 0) {
        NSArray *nibArr = [[NSBundle mainBundle]
                           loadNibNamed:@"OrderPeopleTableViewCell" owner:nil options:nil];
        OrderPeopleTableViewCell *firstCell = [nibArr lastObject];
        firstCell.nameLabel.text = self.guideName;
        firstCell.phoneLabel.text = self.guideNum;
        return firstCell;
    }
    //预约时间
    else if(indexPath.section == 1){
        //记录下当前cell的位置，pickerView要改变此cell的时间值
        timeCellPath = indexPath;
        
        NSArray *nibArr = [[NSBundle mainBundle]
                           loadNibNamed:@"OrderTimeTableViewCell" owner:nil options:nil];
        OrderTimeTableViewCell *secondCell = [nibArr lastObject];
        
        //获取当前时间
//        NSDate *currentDate = [NSDate date];
//        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
//        [dateFormatter setDateFormat:@"yyyy年MM月dd日"];
//        NSString *dateStr = [dateFormatter stringFromDate:currentDate];
        [secondCell.startBtn setTitle:@"" forState:UIControlStateNormal];
        [secondCell.endBtn setTitle:@"" forState:UIControlStateNormal];
        
        secondCell.startBtn.tag = 100;
        secondCell.endBtn.tag = 200;
        [secondCell.startBtn addTarget:self action:@selector(pickerAction:) forControlEvents:UIControlEventTouchUpInside];
        [secondCell.endBtn addTarget:self action:@selector(pickerAction:) forControlEvents:UIControlEventTouchUpInside];
        return secondCell;
    }
    //服务----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    else if(indexPath.section == 2){
        NSArray *nibArr = [[NSBundle mainBundle]loadNibNamed:@"OrderServiceTableViewCell" owner:nil options:nil];
        OrderServiceTableViewCell *serviceCell = [nibArr lastObject];
        serviceCell.textView.delegate = self;
        _textCellIndexPath = indexPath;
        self.content = serviceCell.textView.text;
        _cellIndexPath = indexPath;//记录下当前路径后面好取到这个cell
        serviceCell.textField.text = @"0元";
        serviceCell.textField.keyboardType = UIKeyboardTypeNumberPad;
        serviceCell.textField.delegate = self;
        _textField = serviceCell.textField;
        return serviceCell;
    }
    //按钮
    else{
        UITableViewCell *btnCell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 108)];
        btnCell.backgroundColor = [UIColor colorWithRed:238 / 255.0 green:238 / 255.0 blue:238 / 255.0 alpha:1];
        btnCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        //创建“订购他”按钮
        UIButton *orderBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [orderBtn setFrame:CGRectMake(15, 0, kMainScreenWidth - 30, 44)];
        [orderBtn.layer setCornerRadius:2];
        UIColor *orderBtnColor = [UIColor colorWithRed:29/255.0 green:189/255.0 blue:159/255.0 alpha:1];
        [orderBtn setBackgroundColor:orderBtnColor];
        [orderBtn setTitle:@"咨询Ta" forState:UIControlStateNormal];
        orderBtn.tintColor = [UIColor whiteColor];
        orderBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        _buyBtn = orderBtn;
        [btnCell addSubview:orderBtn];
        
        //创建取消按钮
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [cancelBtn setFrame:CGRectMake(15, 64, kMainScreenWidth - 30, 44)];
        [cancelBtn.layer setCornerRadius:2];
        [cancelBtn setBackgroundColor:[UIColor whiteColor]];
        cancelBtn.tintColor = [UIColor blackColor];
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        cancelBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        self.cancelBtn = cancelBtn;
        [btnCell addSubview:cancelBtn];
        return btnCell;
    }
}

//点击起始时间和终止时间按钮弹出PickerView
- (void) pickerAction:(UIButton *)btn{
    //如果按钮上面是空的则以pickerView当前选中的时间为标题
    if (btn.titleLabel.text == nil) {
        NSDate *date = [_datePicker date];
        NSDateFormatter *pickerFormate = [[NSDateFormatter alloc]init];
        [pickerFormate setDateFormat:@"yyyy-MM-dd"];
        dateStr = [pickerFormate stringFromDate:date];
        [btn setTitle:dateStr forState:UIControlStateNormal];
        dateStr = [NSString stringWithFormat:@"%@ 12:00:00",dateStr];
        if (btn.tag == 100) {
            _startTime = dateStr;
        }
        else{
            _endTime = dateStr;
        }
        
        //判断结束日期有没比开始日期大
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        unsigned int unitFlag = NSDayCalendarUnit;
        NSDateComponents *components = [calendar components:unitFlag fromDate:fromDate toDate:localeDate options:0];
        days = [components day];
        if (days < 0) {
            _timeIsSuitable = NO;
        }
        else{
            _timeIsSuitable = YES;
        }

    }
    
    //根据button的tag得到是哪个button点击的
    _datePicker.tag = btn.tag;
    [UIView animateWithDuration:0.2 animations:^{
        _modalView.alpha = 0.8;
    }];
    [UIView animateWithDuration:0.5 animations:^{
        [_datePicker setFrame:CGRectMake(0, kMainScreenHeight - 216, kMainScreenWidth, 216)];
    }];
}
//点击模态视图pickerView消失
- (void)pickerViewHidden{
    [UIView animateWithDuration:0.2 animations:^{
        _modalView.alpha = 0;
    }];
    [UIView animateWithDuration:0.5 animations:^{
        [_datePicker setFrame:CGRectMake(0, 1000, kMainScreenWidth, 216)];
    }];
}


//-----------------------创建模态视图在上面添加datePicker-------------------------
- (void) modalViewCreat{
    _modalView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, kMainScreenHeight)];
    _modalView.backgroundColor = [UIColor blackColor];
    _modalView.alpha = 0;
    [_modalView addTarget:self action:@selector(pickerViewHidden) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_modalView];
}

//创建picker
- (void) pickerViewCreat{
    float pickerHeight = 216;
    _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 1000,kMainScreenWidth, pickerHeight)];
    //设置picker的选择范围为从现在开始的2年内
    _datePicker.minimumDate = [NSDate dateWithTimeIntervalSinceNow:0];
    _datePicker.maximumDate = [NSDate dateWithTimeIntervalSinceNow:60 * 60 * 24 * 365 * 2];
    _datePicker.datePickerMode = UIDatePickerModeDate;
    _datePicker.backgroundColor = [UIColor whiteColor];
    //当datePicker滑动时button的值也跟着改变
    [_datePicker addTarget:self action:@selector(getDate:) forControlEvents:UIControlEventValueChanged];
    
    [self addSubview:_datePicker];
    [self bringSubviewToFront:_datePicker];
}

//随着datePicker选中的值的改变起始和中指时间也改变
- (void)getDate:(UIDatePicker *)datePicker{
    OrderTimeTableViewCell *timeCell = [_tableView cellForRowAtIndexPath:timeCellPath];

    NSDate *date = [datePicker date];
    NSDateFormatter *pickerFormate = [[NSDateFormatter alloc]init];
    [pickerFormate setDateFormat:@"yyyy-MM-dd"];
    
    dateStr = [pickerFormate stringFromDate:date];
    if (datePicker.tag == 100) {
        [timeCell.startBtn setTitle:dateStr forState:UIControlStateNormal];
        dateStr = [NSString stringWithFormat:@"%@ 12:00:00",dateStr];
        _startTime = dateStr;
        fromDate = [datePicker date];
        
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        unsigned int unitFlag = NSDayCalendarUnit;
        //计算选择旅行开始时间到当前时间
        NSDateComponents *components = [calendar components:unitFlag fromDate:[NSDate date] toDate:fromDate options:0];
//        NSLog(@"now:%@ from:%@",[NSDate date],fromDate);
        _startDate = [components day];
    }
    else{
        [timeCell.endBtn setTitle:dateStr forState:UIControlStateNormal];
        dateStr = [NSString stringWithFormat:@"%@ 12:00:00",dateStr];
        _endTime = dateStr;
        localeDate = [datePicker date];
//        NSLog(@"locale%@",localeDate);
    }
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    unsigned int unitFlag = NSDayCalendarUnit;
    if (localeDate) {
        NSDateComponents *components = [calendar components:unitFlag fromDate:fromDate toDate:localeDate options:0];
        days = [components day];
        if (days < 0) {
            _timeIsSuitable = NO;
        }
        else{
            _timeIsSuitable = YES;
        }
        
    }
    
}

#pragma mark - 设置键盘代理事件

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    UITableView *tempTable = (UITableView *)[self viewWithTag:555];
    OrderServiceTableViewCell *cell = [tempTable cellForRowAtIndexPath:_cellIndexPath];
    [cell.textView resignFirstResponder];
    OrderServiceTableViewCell *serviceCell = [tempTable cellForRowAtIndexPath:_textCellIndexPath];
    self.content = serviceCell.textView.text;
    
    //隐藏_textField的键盘并在输入的价格末尾加上元字
    if ([_textField.text isEqualToString:@""]) {
        _textField.text = @"0元";
    }
    else if([_textField isFirstResponder]){
        _textField.text = [NSString stringWithFormat:@"%@元",_textField.text];
    }
    self.price = _textField.text;
    [_textField resignFirstResponder];
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        [UIView animateWithDuration:0.2 animations:^{
            _tableView.contentOffset = CGPointMake(0, 0);//当textView被选中的时候上移
        }];
        return NO;
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    [UIView animateWithDuration:0.2 animations:^{
         _tableView.contentOffset = CGPointMake(0, 200);//当textView被选中的时候上移
    }];
}

- (void)textViewDidChange:(UITextView *)textView{
    self.content = textView.text;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return 10;
}

#pragma mark-textField

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    [UIView animateWithDuration:0.2 animations:^{
        _tableView.contentOffset = CGPointMake(0, 200);//当textField被选中的时候上移
    }];
    textField.text = @"";
    return YES;
}



@end
