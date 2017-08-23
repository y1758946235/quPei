//
//  SZCalendarPicker.m
//  SZCalendarPicker
//
//  Created by Stephen Zhuang on 14/12/1.
//  Copyright (c) 2014年 Stephen Zhuang. All rights reserved.
//

#import "SZCalendarPicker.h"
#import "SZCalendarCell.h"
#import "UIColor+ZXLazy.h"

NSString *const SZCalendarCellIdentifier = @"cell";

@interface SZCalendarPicker ()
@property (nonatomic , weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic , weak) IBOutlet UILabel *monthLabel;
@property (nonatomic , weak) IBOutlet UIButton *previousButton;
@property (nonatomic , weak) IBOutlet UIButton *nextButton;
@property (nonatomic , strong) NSArray *weekDayArray;
@property (nonatomic , strong) UIView *mask;


@property(nonatomic,strong)NSArray *dayArr;
@end

@implementation SZCalendarPicker


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [self addTap];
    [self addSwipe];
    [self show];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [_collectionView registerClass:[SZCalendarCell class] forCellWithReuseIdentifier:SZCalendarCellIdentifier];
     _weekDayArray = @[@"日",@"一",@"二",@"三",@"四",@"五",@"六"];
     //_dayArr = @[@"全天",@"上午",@"下午",@"晚上"];
}

- (void)customInterface
{
    CGFloat itemWidth = _collectionView.frame.size.width / 7;
   CGFloat itemHeight = _collectionView.frame.size.height / 8;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    [_collectionView setCollectionViewLayout:layout animated:YES];
    
    
}

- (void)setDate:(NSDate *)date
{
    _date = date;
    [_monthLabel setText:[NSString stringWithFormat:@"%li-%.2ld",(long)[self year:date],(long)[self month:date]]];
    _monthLabel.textColor = [UIColor colorWithHexString:@"#424242"];
    [_collectionView reloadData];
}


#pragma mark - date

- (NSInteger)day:(NSDate *)date{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    return [components day];
}


- (NSInteger)month:(NSDate *)date{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    return [components month];
}

- (NSInteger)year:(NSDate *)date{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    return [components year];
}


- (NSInteger)firstWeekdayInThisMonth:(NSDate *)date{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar setFirstWeekday:1];//1.Sun. 2.Mon. 3.Thes. 4.Wed. 5.Thur. 6.Fri. 7.Sat.
    NSDateComponents *comp = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    [comp setDay:1];
    NSDate *firstDayOfMonthDate = [calendar dateFromComponents:comp];
    
    NSUInteger firstWeekday = [calendar ordinalityOfUnit:NSCalendarUnitWeekday inUnit:NSCalendarUnitWeekOfMonth forDate:firstDayOfMonthDate];
    return firstWeekday - 1;
}

- (NSInteger)totaldaysInThisMonth:(NSDate *)date{
    NSRange totaldaysInMonth = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    return totaldaysInMonth.length;
}

- (NSInteger)totaldaysInMonth:(NSDate *)date{
    NSRange daysInLastMonth = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    return daysInLastMonth.length;
}

- (NSDate *)lastMonth:(NSDate *)date{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.month = -1;
    NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:date options:0];
    return newDate;
}

- (NSDate*)nextMonth:(NSDate *)date{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.month = +1;
    NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:date options:0];
    return newDate;
}

#pragma -mark collectionView delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    //return 2;
    return 3;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
//    if (section == 0) {
//        return _weekDayArray.count;
//    } else {
//        return 42;
//    }
    if (section==0) {
        return _weekDayArray.count;
    }else if(section == 1){
        return 35;
    }else if (section == 2){
        return 2;
    }else{
        return 0;
    }
    
    }

//
- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat itemWidth = _collectionView.frame.size.width / 7;
   // CGFloat itemHeight = _collectionView.frame.size.height / 8;
    if (indexPath.section==0&&indexPath.section==1) {
        return CGSizeMake(itemWidth, 40);
        
    }else if(indexPath.section==2){
        return CGSizeMake(64, 32);
    }else{
        return CGSizeMake(itemWidth, 32);
    }
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SZCalendarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:SZCalendarCellIdentifier forIndexPath:indexPath];
    if (indexPath.section == 0) {
        [cell.dateLabel setText:_weekDayArray[indexPath.row]];
        [cell.dateLabel setTextColor:[UIColor colorWithHexString:@"#424242"]];   //周日  周一 等
    } else if(indexPath.section == 1){
        NSInteger daysInThisMonth = [self totaldaysInMonth:_date];
        NSInteger firstWeekday = [self firstWeekdayInThisMonth:_date];
        
        NSInteger day = 0;
        NSInteger i = indexPath.row;
        
        if (i < firstWeekday) {
            [cell.dateLabel setText:@""];
            
        }else if (i > firstWeekday + daysInThisMonth - 1){
            [cell.dateLabel setText:@""];
        }else{
            day = i - firstWeekday + 1;
            [cell.dateLabel setText:[NSString stringWithFormat:@"%li",day]];
            [cell.dateLabel setTextColor:[UIColor colorWithHexString:@"#757575"]];   //今天以前的日期
            
            //this month
            if ([_today isEqualToDate:_date]) {
                if (day == [self day:_date]) {
                    [cell.dateLabel setTextColor:[UIColor colorWithHexString:@"#ff5252"]];   //今天日期
                } else if (day > [self day:_date]) {
                    [cell.dateLabel setTextColor:[UIColor colorWithHexString:@"#757575"]];
                }
            } else if ([_today compare:_date] == NSOrderedAscending) {
                [cell.dateLabel setTextColor:[UIColor colorWithHexString:@"#757575"]];
            }
        }
    }else {
        
            UIButton *sure = [[UIButton alloc]init];
       
        sure.backgroundColor = [UIColor blueColor];
            sure.translatesAutoresizingMaskIntoConstraints = NO;
            [sure addTarget:self action:@selector(sure:) forControlEvents:UIControlEventTouchUpInside];
            [sure setTitle:@"确定" forState:UIControlStateNormal];
            [sure setTitleColor:[UIColor colorWithHexString:@"#ff5252"] forState:UIControlStateNormal];
            sure.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
            [cell addSubview:sure];
//            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[sure(==44)]-16-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(sure)]];
//            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[sure(==32)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(sure)]];

       
       
        
        UIButton *cancel = [[UIButton alloc]init];
        cancel.translatesAutoresizingMaskIntoConstraints = NO;
        [cancel addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
        [cancel setTitle:@"取消" forState:UIControlStateNormal];
        [cancel setTitleColor:[UIColor colorWithHexString:@"#424242"] forState:UIControlStateNormal];
        cancel.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        [cell addSubview:cancel];
//        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[cancel(==44)]-68-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(cancel)]];
//        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[cancel(==32)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(cancel)]];
        
    }
    return cell;
}


//取消选日期
- (void)cancel:(UIButton *)sender{
    
    
}

#pragma mark  ---选择日期  确定
- (void)sure:(UIButton *)sender{
    
    if (self.calendarBlock != nil) {
        
        //self.calendarBlock(_date,self.scrollImageArr[sender.tag-1000+1]);
    }
    
}
- (void)calendarBlock:(calendarBlock)Block{
    self.calendarBlock = Block;
}
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        NSInteger daysInThisMonth = [self totaldaysInMonth:_date];
        NSInteger firstWeekday = [self firstWeekdayInThisMonth:_date];
        
        NSInteger day = 0;
        NSInteger i = indexPath.row;
        
        if (i >= firstWeekday && i <= firstWeekday + daysInThisMonth - 1) {
            day = i - firstWeekday + 1;
            
            //this month
            if ([_today isEqualToDate:_date]) {
                if (day <= [self day:_date]) {
                    return YES;
                }
            } else if ([_today compare:_date] == NSOrderedDescending) {
                return YES;
            }
        }
       
    }
    return NO;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDateComponents *comp = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:self.date];
    NSInteger firstWeekday = [self firstWeekdayInThisMonth:_date];
    
    NSInteger day = 0;
    NSInteger i = indexPath.row;
    day = i - firstWeekday + 1;
    if (self.calendarBlock) {
        self.calendarBlock(day, [comp month], [comp year]);
    }
    
    [self hide];
}

- (IBAction)previouseAction:(UIButton *)sender
{
    [UIView transitionWithView:self duration:0.5 options:UIViewAnimationOptionTransitionCurlDown animations:^(void) {
        self.date = [self lastMonth:self.date];
    } completion:nil];
}

- (IBAction)nexAction:(UIButton *)sender
{
    [UIView transitionWithView:self duration:0.5 options:UIViewAnimationOptionTransitionCurlUp animations:^(void) {
        self.date = [self nextMonth:self.date];
    } completion:nil];
}


#pragma mark   -------------日历-----------------

+ (instancetype)showOnView:(UIView *)view
{
    
   
    //日历
    SZCalendarPicker *calendarPicker = [[[NSBundle mainBundle] loadNibNamed:@"SZCalendarPicker" owner:self options:nil] firstObject];
    calendarPicker.mask = [[UIView alloc] initWithFrame:view.bounds];
    calendarPicker.mask.backgroundColor = [UIColor blackColor];
    calendarPicker.mask.alpha = 0.3;
    
  
    
    [view addSubview:calendarPicker.mask];
    
    [view addSubview:calendarPicker];
    
    
    return calendarPicker;
}

- (void)show
{
    self.transform = CGAffineTransformTranslate(self.transform, 0, - self.frame.size.height);
    [UIView animateWithDuration:0.5 animations:^(void) {
        self.transform = CGAffineTransformIdentity;
    } completion:^(BOOL isFinished) {
        [self customInterface];
    }];
}

- (void)hide
{
    [UIView animateWithDuration:0.5 animations:^(void) {
        self.transform = CGAffineTransformTranslate(self.transform, 0, - self.frame.size.height);
        self.mask.alpha = 0;
    } completion:^(BOOL isFinished) {
        [self.mask removeFromSuperview];
        [self removeFromSuperview];
    }];
}


- (void)addSwipe
{
    UISwipeGestureRecognizer *swipLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(nexAction:)];
    swipLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:swipLeft];
    
    UISwipeGestureRecognizer *swipRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(previouseAction:)];
    swipRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:swipRight];
}

- (void)addTap
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    [self.mask addGestureRecognizer:tap];
}
@end
