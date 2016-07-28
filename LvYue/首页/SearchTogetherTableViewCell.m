//
//  SearchTogetherTableViewCell.m
//  豆客项目
//
//  Created by Xia Wei on 15/10/8.
//  Copyright © 2015年 Xia Wei. All rights reserved.
//

#import "SearchTogetherTableViewCell.h"

@interface SearchTogetherTableViewCell()<UITextFieldDelegate>

@property(nonatomic,strong)NSMutableArray *btnArr;
@property(nonatomic,assign)int btnTag;
@property(nonatomic,assign)float width;
@property (nonatomic,strong) NSMutableString *signString;

@property (nonatomic,strong) UILabel *ser;

@end

@implementation SearchTogetherTableViewCell

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self separatorCreated];
        [self labelCreated];
        self.service_content = [[NSMutableArray alloc]init];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        _btnTag = 1;
        _width = frame.size.width;
        _btnArr = [[NSMutableArray alloc]init];
        
        self.ser = [[UILabel alloc] initWithFrame:CGRectMake(20, 160, 80, 20)];
        self.ser.font = [UIFont systemFontOfSize:14.0];
        self.ser.text = @"服务项目:";
//        [self addSubview:self.ser];
        
        self.serText = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.ser.frame) - 10, self.ser.frame.origin.y, kMainScreenWidth - CGRectGetMaxX(self.ser.frame) - 40, 30)];
        self.serText.font = [UIFont systemFontOfSize:14.0];
        self.serText.layer.borderWidth = 0.5;
        self.serText.layer.borderColor = [UIColor grayColor].CGColor;
        self.serText.returnKeyType = UIReturnKeyDone;
        self.serText.layer.cornerRadius = 4.0;
        self.serText.delegate = self;
        self.serText.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 30)];
        self.serText.leftViewMode = UITextFieldViewModeAlways;
        self.serText.placeholder = @"输入上面没有的其他服务";
        [self.serText addTarget:self action:@selector(resignFirstResponder) forControlEvents:UIControlEventEditingDidEndOnExit];
//        [self addSubview:self.serText];
        
        UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.ser.frame.origin.x, CGRectGetMaxY(self.ser.frame) + 20, self.ser.frame.size.width + self.serText.frame.size.width, 20)];
        tipLabel.font = [UIFont systemFontOfSize: 14.0];
        tipLabel.text = @"填写时请以逗号隔开";
        tipLabel.textAlignment = NSTextAlignmentCenter;
//        [self addSubview:tipLabel];
        
    }
    return self;
}

- (void)setWithNameArr:(NSArray *)nameArr{
    int btnW = 80;
    int btnX = 20;
    if (kMainScreenWidth >= 375) {
        btnX = 50;
    }
    int btnY = 40;
    for (int i = 0; i < nameArr.count; i++) {
        UIButton *btn = [[UIButton alloc] init];
        [btn setFrame:CGRectMake(btnX, btnY, btnW, 30)];
        [btn setTitle:nameArr[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn setTitleColor:RGBACOLOR(29, 189, 159, 1) forState:UIControlStateSelected];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
        [btn.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [btn addTarget:self action:@selector(btnChanged:) forControlEvents:UIControlEventTouchUpInside];
        btn.layer.cornerRadius = 4;
        btn.layer.borderColor = RGBACOLOR(217, 217, 217, 1).CGColor;
        btn.layer.borderWidth = 0.5;
        btn.tag = 900 + i;
        btnX += btn.frame.size.width + 10;
        if ((i + 1) % 3 == 0) {
            btnY += 40;
            btnX = 20;
            if (kMainScreenWidth >= 375) {
                btnX = 50;
            }
        }
        
        [self addSubview:btn];
    }
}

#pragma mark 表格填写自适应

-(void)textFieldDidBeginEditing:(UITextField *)textField{

    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyBoard" context:nil];
    [UIView setAnimationDuration:animationDuration];

    CGRect rect = CGRectMake(0.0f, - 240,kMainScreenWidth,kMainScreenHeight);
    self.superview.superview.frame = rect;

    [UIView commitAnimations];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyBoard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    CGRect rect = CGRectMake(0.0f, 0,kMainScreenWidth,kMainScreenHeight);
    self.superview.superview.frame = rect;
    
    [UIView commitAnimations];
    
    NSDictionary *dict = @{@"service":self.serText.text};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"service" object:nil userInfo:dict];
}

- (void)separatorCreated{
    //创建和上面的分割线
    UIView *separateLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth * 2, 1)];
    separateLine.backgroundColor = UIColorWithRGBA(239, 239,239, 1);
    [self addSubview:separateLine];
}

- (void)labelCreated{
    UILabel *us = [[UILabel alloc]initWithFrame:CGRectMake(20, 15, 150, 20)];
    us.text = @"选择查找对象的技能";
    us.textColor = UIColorWithRGBA(158, 158, 158, 1);
    us.font = [UIFont systemFontOfSize:14];
    [self addSubview:us];
}

//创建所有button
- (void)btnCreated:(NSString *)text origin_x:(float)origin_x origin_y:(float)origin_y{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.tag = _btnTag ++;
    
    //使每个btn自适应宽度
    NSDictionary *attribute = @{NSFontAttributeName:btn.titleLabel.font};
    CGSize size = CGSizeMake(360, 1000);
    CGSize btnSize = [text boundingRectWithSize:size options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    if (_width < 370) {
        [btn setFrame:CGRectMake(origin_x, origin_y, btnSize.width + 32, 30)];
    }
    else{
        [btn setFrame:CGRectMake(origin_x, origin_y, btnSize.width + 40, 30)];
    }
    [btn setTitle:text forState:UIControlStateNormal];
    [btn.layer setCornerRadius:3];
    [btn.layer setBorderWidth:1];
    [btn setTitleColor:RGBACOLOR(83, 83, 83, 1) forState:UIControlStateNormal];
    [btn.layer setBorderColor:UIColorWithRGBA(221, 221, 221, 1).CGColor];
    [btn addTarget:self action:@selector(btnChanged:) forControlEvents:UIControlEventTouchUpInside];
    [_btnArr addObject:btn];
    [self addSubview:btn];
}

//点击按钮，使按钮颜色变化
- (void)btnChanged:(UIButton *)doBtn{
    
    NSArray *array = [self.serText.text componentsSeparatedByString:@","];
    NSMutableArray *mArray = [[NSMutableArray alloc] initWithArray:array];
    if (doBtn.selected == YES) {
        doBtn.selected = NO;
        [doBtn.layer setBorderWidth:1];
        [doBtn.layer setBorderColor:UIColorWithRGBA(221, 221, 221, 1).CGColor];
        [doBtn setBackgroundColor:[UIColor whiteColor]];
        [doBtn setTitleColor:RGBACOLOR(83, 83, 83, 1) forState:UIControlStateNormal];
        [mArray removeObject:[NSString stringWithFormat:@"%@",doBtn.titleLabel.text]];
    }
    else{
        doBtn.selected = YES;
        [doBtn.layer setBorderColor:UIColorWithRGBA(29, 189, 159, 1).CGColor];
        [doBtn setBackgroundColor:[UIColor whiteColor]];
        [doBtn setTitleColor:RGBACOLOR(29, 189, 159, 1) forState:UIControlStateNormal];
        [mArray addObject:[NSString stringWithFormat:@"%@",doBtn.titleLabel.text]];
    }
    _signString = nil;
    _signString = [NSMutableString stringWithString:@""];
    for (NSString *subString in mArray) {
        if (![subString isEqualToString:@""]) {
            [self.signString appendString:[NSString stringWithFormat:@"%@,",subString]];
        }
    }
    
    self.serText.text = self.signString;
    
    NSDictionary *dict = @{@"service":self.serText.text};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"service" object:nil userInfo:dict];
}

- (void)awakeFromNib {

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
