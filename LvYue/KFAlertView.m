//
//  KFAlertView.m
//  LvYue
//
//  Created by KFallen on 16/6/27.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "KFAlertView.h"
#import "UIView+KFFrame.h"

@interface KFAlertView ()

@property (nonatomic, weak) UIView* backView;  //创建alpha = 0.5的view

@property (nonatomic, weak) UIView* containerView;  //背景白色部分

/**
 *  确认按钮
 */
@property (nonatomic, strong) UIButton* confirmBtn;

/**
 *  取消按钮，
 */
@property (nonatomic, strong) UIButton* cancelBtn;


@end

@implementation KFAlertView
#pragma mark - 懒加载
- (UIButton *)cancelBtn {
    if (!_cancelBtn) {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundImage:[UIImage imageNamed:@"矩形-9"] forState:UIControlStateNormal];
        button.size = CGSizeMake(130, 40);
        
        //button.backgroundColor = [UIColor redColor];
        [button addTarget:self action:@selector(cancleClick:) forControlEvents:UIControlEventTouchUpInside];
        _cancelBtn = button;
        [self addSubview:_cancelBtn];
    }
    return _cancelBtn;
}

- (void)cancleClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(alertView:didClickKFButtonIndex:)]) {
        [self.delegate alertView:self didClickKFButtonIndex:0];
    }
}

- (UIButton *)confirmBtn {
    if (!_confirmBtn) {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundImage:[UIImage imageNamed:@"矩形-9"] forState:UIControlStateNormal];
        button.size = CGSizeMake(130, 40);
        
        //button.backgroundColor = [UIColor blueColor];
        [button addTarget:self action:@selector(confirmClick:) forControlEvents:UIControlEventTouchUpInside];
        _confirmBtn = button;
        [self addSubview:_confirmBtn];
    }
    return _confirmBtn;
}

- (void)confirmClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(alertView:didClickKFButtonIndex:)]) {
        [self.delegate alertView:self didClickKFButtonIndex:1];
    }
}

- (UIView *)backView {
    if (!_backView) {
        //创建alpha = 0.5的view
        UIView* backView = [[UIView alloc] initWithFrame:self.bounds];
        //背景色
        backView.backgroundColor = [UIColor redColor];
        _backView = backView;
        [self addSubview:_backView];
    }
    return _backView;
}

- (UIView *)containerView {
    if (!_containerView) {
        UIView* containerView = [[UIView alloc] init];
        containerView.backgroundColor = [UIColor whiteColor];
    
        
        _containerView = containerView;
        [self addSubview:_containerView];
    }
    return _containerView;
}

#pragma mark - 视图加载
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        //self.backView.hidden = NO;
        self.backgroundColor = RGBACOLOR(0, 0, 0, 0.3);
        //设置文字内容
        
    }
    return self;
}

+ (instancetype)alertView {
    return [[self alloc] init];
}

//设置文字宽高
- (void)setTextLabel:(UILabel *)textLabel {
    _textLabel = textLabel;
    
    _textLabel.textAlignment = NSTextAlignmentCenter;
    //设置内容
    [self.containerView addSubview:_textLabel];
    
    //调整containerView的point
    _textLabel.x = 18;
    _textLabel.y = 18;
    
    //设置containerView的frame
    self.containerView.width = 312;
    self.containerView.centerX = kMainScreenWidth * 0.5;
    
    _textLabel.width = self.containerView.width - 2*_textLabel.x;
    
    //通过文字的宽高计算 textlabel的宽高
    UIFont* font = _textLabel.font;
    _textLabel.numberOfLines = 0;
    _textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    CGSize size = [textLabel.text boundingRectWithSize:CGSizeMake(_textLabel.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil] context:nil].size;
    //高度H
    CGFloat contentH = size.height;
    //NSLog(@"调整后内容宽度：%f,高度：%f", _textLabel.width,contentH);
    
    _textLabel.height = contentH;
    
    //设置self.containerView
    self.containerView.height =  contentH + 4*_textLabel.y + 40;
    self.containerView.y = (kMainScreenHeight - self.containerView.height)*0.5;
    //NSLog(@"self.containerView的frame“%@", NSStringFromCGRect(self.containerView.frame));
}

- (void)initWithCancleBtnTitle:(NSString *)cancleStr cancleColor:(UIColor *)cancleColor confirmBtnTitle:(NSString *)confirmStr confirmColor:(UIColor *)confirmColor {
    //赋值
    [self.cancelBtn setTitle:cancleStr forState:UIControlStateNormal];
    [self.cancelBtn setTitleColor:cancleColor forState:UIControlStateNormal];
    self.cancelBtn.x = _textLabel.x;
    self.cancelBtn.y = self.containerView.height - _textLabel.y - self.cancelBtn.height;
    [self.containerView addSubview:self.cancelBtn];
    
    //两个矩形的间距
    CGFloat margin = self.containerView.width - 2*(self.cancelBtn.width+self.cancelBtn.x);
    
    [self.confirmBtn setTitle:confirmStr forState:UIControlStateNormal];
    [self.confirmBtn setTitleColor:confirmColor forState:UIControlStateNormal];
    self.confirmBtn.y = self.cancelBtn.y;
    self.confirmBtn.x = self.containerView.width*0.5 + 0.5*margin;
    [self.containerView addSubview:self.confirmBtn];
    
}

#pragma mark - 点击方法
- (void)show {
    //获得window
    UIWindow* mainWindow = [[UIApplication sharedApplication].windows lastObject];
    //加到window上
    [mainWindow addSubview:self];
    //设置self的frame
    self.frame = mainWindow.bounds;
    
    
    //设置containerView的frame
    self.containerView.width = 312;
    self.containerView.centerX = kMainScreenWidth * 0.5;
}


- (void)dismiss {
    [self removeFromSuperview];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self dismiss];
}






@end
