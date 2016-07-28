//
//  AllOrderChangeButtonView.m
//  豆客项目
//
//  Created by Xia Wei on 15/10/12.
//  Copyright © 2015年 Xia Wei. All rights reserved.
//

#import "AllOrderChangeButtonView.h"

@interface AllOrderChangeButtonView()

@property(nonatomic,strong)NSArray *btnArr;

@end

@implementation AllOrderChangeButtonView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        //创建三个button
        self.firstBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.secondBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.thirdBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self buttonCreated:@"全部订单" origin_x:0 button:self.firstBtn];
        [self buttonCreated:@"发起订单" origin_x:(kMainScreenWidth / 3.0) button:self.secondBtn];
        [self buttonCreated:@"接收订单" origin_x:(kMainScreenWidth * 2 / 3.0) button:self.thirdBtn];
        _firstBtn.tag = 100;
        _secondBtn.tag = 101;
        _thirdBtn.tag = 102;
        
        //创建button之间的分割线
        UIView *separaLine = [[UIView alloc] initWithFrame:
                              CGRectMake(frame.size.width / 3.0, (frame.size.height - 14) / 2.0, 1, 14)];
        [separaLine setBackgroundColor:UIColorWithRGBA(202, 202, 202, 1)];
        [self addSubview:separaLine];
        
        //创建button之间的分割线
        UIView *separaLine2 = [[UIView alloc] initWithFrame:
                              CGRectMake(frame.size.width * 2 / 3.0, (frame.size.height - 14) / 2.0, 1, 14)];
        [separaLine2 setBackgroundColor:UIColorWithRGBA(202, 202, 202, 1)];
        [self addSubview:separaLine2];
        
        //设置第一个按钮被选中时的颜色
        [_firstBtn setTintColor:UIColorWithRGBA(29, 189, 159, 1)];
        
        //创建下面滑动的view
        self.scrollLine = [[UIView alloc] initWithFrame:
                           CGRectMake(0,frame.size.height - 2, frame.size.width / 3.0, 2)];
        self.scrollLine.tag = 200;
        [self.scrollLine setBackgroundColor:UIColorWithRGBA(29, 189, 159, 1)];
        [self addSubview:self.scrollLine];
        
    }
    return  self;
}

- (void)buttonCreated:(NSString *)titleText origin_x:(float)origin_x button:(UIButton *)btn{
    [btn setFrame:CGRectMake(origin_x, 0, kMainScreenWidth / 3.0, 44)];
    [btn setTitle:titleText forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    [btn setTintColor:UIColorWithRGBA(101, 101, 101, 1)];
    [self addSubview:btn];
}

@end
