//
//  KFDatePicker.m
//  LvYue
//
//  Created by KFallen on 16/6/30.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "KFDatePicker.h"
#import "UIView+KFFrame.h"

@interface KFDatePicker()<UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, weak) UIView* containerView;  //背景白色部分

/**
 *  确认按钮
 */
@property (nonatomic, strong) UIButton* confirmBtn;

/**
 *  取消按钮，
 */
@property (nonatomic, strong) UIButton* cancelBtn;

@property (nonatomic, weak) UIPickerView* pickerView; //选择器

//年月
@property (nonatomic,strong) NSMutableArray *yearArray;
@property (nonatomic,strong) NSMutableArray *monthArray;

@property (nonatomic,assign) NSInteger currentYear;
@property (nonatomic,assign) NSInteger currentMonth;

@property (nonatomic,assign) NSInteger yearRow;
@property (nonatomic,assign) NSInteger monthRow;
//选中的年月
@property (nonatomic,copy) NSString *yearStr;
@property (nonatomic,copy) NSString *monthStr;

@end


@implementation KFDatePicker

- (UIView *)containerView {
    if (_containerView == nil) {
        UIView* containerView = [[UIView alloc] init];
        containerView.backgroundColor = [UIColor whiteColor];
        
        
        _containerView = containerView;
        [self addSubview:_containerView];
    }
    return _containerView;
}

static int buttonH = 40;
- (UIButton *)cancelBtn {
    if (_cancelBtn == nil) {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
        //[button setBackgroundImage:[UIImage imageNamed:@"矩形-9"] forState:UIControlStateNormal];
        button.size = CGSizeMake(kMainScreenWidth*0.5, buttonH);
        button.x = 0;
        button.y = containerViewH - button.height;
        
        button.backgroundColor = [UIColor redColor];
        [button addTarget:self action:@selector(cancleClick:) forControlEvents:UIControlEventTouchUpInside];
        _cancelBtn = button;
        [self.containerView addSubview:_cancelBtn];
    }
    return _cancelBtn;
}

- (void)cancleClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(datePicker:didClickButtonIndex:titleRow:)]) {
        [self.delegate datePicker:self didClickButtonIndex:0 titleRow:nil];
    }
    
}

- (UIButton *)confirmBtn {
    if (_confirmBtn == nil) {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
        //[button setBackgroundImage:[UIImage imageNamed:@"矩形-9"] forState:UIControlStateNormal];
        button.size = CGSizeMake(kMainScreenWidth*0.5, buttonH);
        button.x = kMainScreenWidth*0.5;
        button.y = containerViewH - button.height;
        
        button.backgroundColor = [UIColor blueColor];
        [button addTarget:self action:@selector(confirmClick:) forControlEvents:UIControlEventTouchUpInside];
        _confirmBtn = button;
        [self.containerView addSubview:_confirmBtn];
    }
    return _confirmBtn;
}

- (void)confirmClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(datePicker:didClickButtonIndex:titleRow:)]) {
        
//        NSString* titleRow = [self pickerView:self.pickerView titleForRow:_currentMonth forComponent:_currentYear];
        NSString* titleRow = [NSString stringWithFormat:@"%@年 %@月",self.yearStr, self.monthStr];
        [self.delegate datePicker:self didClickButtonIndex:1 titleRow:titleRow];
    }

}

- (UIPickerView *)pickerView {
    if (_pickerView == nil) {
        UIPickerView* pick = [[UIPickerView alloc] init];
        pick.x = 0;
        pick.y = titleLabelH + lineViewH;
        pick.width = kMainScreenWidth;
        pick.height = containerViewH - titleLabelH - lineViewH - buttonH;
        pick.delegate = self;
        pick.dataSource = self;
        
        //灰色线条
        UIView* grayLineView = [[UIView alloc] init];
        grayLineView.x = 0;
        grayLineView.height = 1;
        grayLineView.y = pick.height - grayLineView.height;
        grayLineView.width = kMainScreenWidth;
        grayLineView.backgroundColor = [UIColor lightGrayColor];
        [pick addSubview:grayLineView];
        
        _pickerView = pick;
        [self.containerView addSubview:_pickerView];
    }
    return _pickerView;
}

- (NSMutableArray *)yearArray{
    if (!_yearArray) {
        _yearArray = [[NSMutableArray alloc] init];
        
        for (int i = 2015; i <= self.currentYear; i++) {
            [_yearArray addObject:[NSString stringWithFormat:@"%d",i]];
        }
    }
    return _yearArray;
}

- (NSMutableArray *)monthArray{
    if (!_monthArray) {
        _monthArray = [[NSMutableArray alloc] init];
        for (int i = 1; i <= 12; i++) {
            [_monthArray addObject:[NSString stringWithFormat:@"%d月",i]];
        }
    }
    return _monthArray;
}

/**
 *  获取当前年月
 */
- (void)getRow{
    for (int i = 0; i < self.yearArray.count; i++) {
        if ([self.yearArray[i] integerValue] == self.currentYear) {
            self.yearRow = i;
            break;
        }
    }
    for (int i = 0; i < self.monthArray.count; i++) {
        if ([self.monthArray[i] integerValue] == self.currentMonth) {
            self.monthRow = i;
            break;
        }
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = RGBACOLOR(0, 0, 0, 0.3);

    }
    return self;
}

+ (instancetype)datePicker {
    return [[self alloc] init];
}

static int containerViewH = 250;

- (void)show {
    //获取window
    UIWindow* mainWindow = [UIApplication sharedApplication].windows.lastObject;
    //加到window
    [mainWindow addSubview:self];
    //设置self
    self.frame = mainWindow.bounds;
    self.y = 64;
    self.height = kMainScreenHeight - self.y;
    
    //设置self.containerView的frame
    self.containerView.height = containerViewH;
    self.containerView.width = kMainScreenWidth;
    self.containerView.x = 0;
    self.containerView.y = self.height - containerViewH;
    
    //设置设置模式
    [self selectMode];
    
    //显示默认pickerView
    //self.pickerView.hidden = NO;
    //默认选中的
    [self getRow];
    [self.pickerView selectRow:self.yearRow inComponent:0 animated:YES];
    [self.pickerView selectRow:self.monthRow inComponent:1 animated:YES];
    //
    [self pickerView:self.pickerView didSelectRow:self.yearRow inComponent:0];
    [self pickerView:self.pickerView didSelectRow:self.monthRow inComponent:1];

    
}

- (void)dismiss {
    [self removeFromSuperview];
}


//设置设置模式
- (void)selectMode {
    if (self.mode == KFDatePickerModeYearAndMonth) {    //年月
        //设置获得当前年月
        self.currentYear = [self getCurrentYear];
        self.currentMonth = [self getCurrentMonth];
        
    }
    else if (self.mode == KFDatePickerModeYear) {
        self.currentYear = [self getCurrentYear];
    }
    else if (self.mode == KFDatePickerModeMonth) {
        self.currentMonth = [self getCurrentMonth];
    }
    else if (self.mode == KFDatePickerModeDay) {
        self.currentMonth = [self getCurrentMonth];
    }

}




static int titleLabelH = 48;
static int lineViewH   = 2;
- (void)setTitleLabel:(UILabel *)titleLabel {
    _titleLabel = titleLabel;
    
    _titleLabel.x = 0;
    _titleLabel.y = 0;
    _titleLabel.width = kMainScreenWidth;
    _titleLabel.height = 48;
    [self.containerView addSubview:_titleLabel];
    
    //添加一条线
    UIView* lineView = [[UIView alloc] init];
    lineView.x = 0;
    lineView.y = _titleLabel.height;
    lineView.width = _titleLabel.width;
    lineView.height = lineViewH;
    lineView.backgroundColor = titleLabel.textColor;
    [self.containerView addSubview:lineView];
}


- (void)initWithCancleBtnTitle:(NSString *)cancleStr cancleColor:(UIColor *)cancleColor confirmBtnTitle:(NSString *)confirmStr confirmColor:(UIColor *)confirmColor {
    [self.cancelBtn setTitle:cancleStr forState:UIControlStateNormal];
    [self.cancelBtn setTitleColor:cancleColor forState:UIControlStateNormal];
    
    [self.cancelBtn setBackgroundColor:[UIColor clearColor]];
    
    [self.containerView addSubview:self.cancelBtn];
    
    UIView* devideLine = [[UIView alloc] init];
    devideLine.width = 1;
    devideLine.y = self.cancelBtn.y + 2;
    devideLine.height = buttonH - 4;
    devideLine.centerX = kMainScreenWidth * 0.5;
    devideLine.backgroundColor = [UIColor lightGrayColor];
    [self.containerView addSubview:devideLine];
    
    [self.confirmBtn setTitle:confirmStr forState:UIControlStateNormal];
    [self.confirmBtn setTitleColor:confirmColor forState:UIControlStateNormal];
    [self.confirmBtn setBackgroundColor:[UIColor clearColor]];
    [self.containerView addSubview:self.confirmBtn];
}


#pragma mark - Private
//获得当前月份
- (NSInteger)getCurrentMonth {
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
    NSInteger month = [dateComponent month];
    return month;
}

- (NSInteger)getCurrentYear{
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
    NSInteger year = [dateComponent year];
    return year;
}

#pragma mark - UIPickerViewDataSource, UIPickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if (self.mode == KFDatePickerModeYearAndMonth) {
        return 2;
    }
    else if (self.mode == KFDatePickerModeYear) {
        return 1;
    }
    else if (self.mode == KFDatePickerModeMonth) {
        return 1;
    }
    else {
        return 1;
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (self.mode == KFDatePickerModeYearAndMonth) {
        if (component == 0) {
            return self.yearArray.count;
        }
        else {
            return self.monthArray.count;
        }
    }
    else if (self.mode == KFDatePickerModeYear) {
        return 1;
    }
    else if (self.mode == KFDatePickerModeMonth) {
        return 1;
    }
    else {
        return 1;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (self.mode == KFDatePickerModeYearAndMonth) {
        if (component == 0) {
            return self.yearArray[row];
        }
        else {
            return self.monthArray[row];
        }
    }
    else if (self.mode == KFDatePickerModeYear) {
        return self.yearArray[row];
    }
    else if (self.mode == KFDatePickerModeMonth) {
        return self.yearArray[row];
    }
    else {
        return self.yearArray[row];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (self.mode == KFDatePickerModeYearAndMonth) {
        if (component == 0) {
            self.yearStr = [NSString stringWithFormat:@"%ld",(long)[self.yearArray[row] integerValue]];
//            self.currentYear = component;
//            self.currentMonth = row;
        }
        else {
//            self.currentYear = component;
//            self.currentMonth = row;
            self.monthStr = [NSString stringWithFormat:@"%ld",(long)[self.monthArray[row] integerValue]];
        }
    }
    else if (self.mode == KFDatePickerModeYear) {
         self.yearStr = [NSString stringWithFormat:@"%ld",(long)[self.yearArray[row] integerValue]];
    }
    else if (self.mode == KFDatePickerModeMonth) {
        self.monthStr = [NSString stringWithFormat:@"%ld",(long)[self.monthArray[row] integerValue]];
    }
    else {
         self.yearStr = [NSString stringWithFormat:@"%ld",(long)[self.yearArray[row] integerValue]];
    }
    [pickerView reloadAllComponents];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self dismiss];
}

@end
