//
//  LYPopoverView.h
//  LvYue
//
//  Created by KentonYu on 16/7/29.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "DXPopover.h"
@class LYPopoverView;

NS_ASSUME_NONNULL_BEGIN

@protocol LYPopoverViewDataSource <NSObject>

/**
 *  返回需要显示的title 和 icon
 *
 *  @param popoverView
 *
 *  @return keys: title icon
 */
- (NSArray<NSDictionary *> *)popoverViewDataSource:(LYPopoverView *)popoverView;

/**
 *  点击第几行
 *
 *  @param index 标识
 */
- (void)popoverViewDidSelected:(NSInteger)index;

@end

typedef NS_ENUM(NSUInteger, LYPopoverViewItemType) {
    LYPopoverViewItemTypeDefault   = 0, // 仅文字
    LYPopoverViewItemTypeIconTitle = 1, // icon + title
    LYPopoverViewItemTypeTitleIcon = 2, // title + icon
    LYPopoverViewItemTypeOnlyIcon  = 3  // 仅 icon
};

@interface LYPopoverView : DXPopover

+ (instancetype)showPopoverViewAtPoint:(CGPoint)point
                                inView:(UIView *)inView
                                  type:(LYPopoverViewItemType)type
                              delegate:(id<LYPopoverViewDataSource>)delegate;

+ (void)dismiss;

@end

@interface LYPopoverViewTableViewCell : UITableViewCell

- (void)configData:(LYPopoverViewItemType)type title:(NSString *)title iconName:(NSString *__nullable)iconName;

@end

NS_ASSUME_NONNULL_END
