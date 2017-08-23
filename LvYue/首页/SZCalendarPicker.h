//
//  SZCalendarPicker.h
//  SZCalendarPicker
//
//  Created by Stephen Zhuang on 14/12/1.
//  Copyright (c) 2014年 Stephen Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^calendarBlock)(NSInteger day, NSInteger month, NSInteger year);

@interface SZCalendarPicker : UIView<UICollectionViewDelegate , UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic , strong) NSDate *date;
@property (nonatomic , strong) NSDate *today;
//@property (nonatomic, copy) void(^calendarBlock)(NSInteger day, NSInteger month, NSInteger year);
@property (nonatomic, copy) calendarBlock calendarBlock;
+ (instancetype)showOnView:(UIView *)view;

- (void)calendarBlock:(calendarBlock)Block;
@end
