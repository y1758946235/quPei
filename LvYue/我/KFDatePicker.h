//
//  KFDatePicker.h
//  LvYue
//
//  Created by KFallen on 16/6/30.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
typedef NS_OPTIONS(NSUInteger, KFDatePickerMode) {
    KFDatePickerModeYear                    = 0,
    KFDatePickerModeMonth                   = 1 << 0,
    KFDatePickerModeDay                     = 1 << 1,
    KFDatePickerModeYearAndMonth            = 1 << 2,
    KFDatePickerModeMonthAndDay             = 1 << 3,
    KFDatePickerModeYearAndMonthAndDay      = 1 << 4,
};
//模式增加；日期自定义；代理综合

@class KFDatePicker;
@protocol KFDatePickerDelegate <NSObject>

@optional
- (void)datePicker:(KFDatePicker *)datePicker didClickButtonIndex:(NSInteger)buttonIndex titleRow:(NSString *)titleRow;

@optional
- (void)datePicker:(KFDatePicker *)datePicker didClickButtonIndex:(NSInteger)buttonIndex year:(NSString *)year month:(NSString *)month;
@end

@interface KFDatePicker : UIView

@property (weak, nonatomic) id<KFDatePickerDelegate> delegate;

/**
 *  设置KFDatePicker的模式,实现年月
 */
@property (nonatomic, assign) KFDatePickerMode mode;

/**
 *  标题
 */
@property (nonatomic, strong) UILabel* titleLabel;


/**
 *  初始化datePicker
 */
+ (instancetype)datePicker;

/**
 *  显示
 */
- (void)show;

/**
 *  隐藏
 */
- (void)dismiss;

/**
 *  初始化两个按钮，无需设置frame；点击实现代理
 */
- (void)initWithCancleBtnTitle:(NSString *)cancleStr cancleColor:(UIColor *)cancleColor confirmBtnTitle:(NSString *)confirmStr confirmColor:(UIColor *)confirmColor;

@end

NS_ASSUME_NONNULL_END
