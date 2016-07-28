//
//  VideoCategoryBar.h
//  LvYue
//
//  Created by Olive on 15/12/24.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>
@class VideoCategoryBar;

/**
 *  视频圈顶部分类
 */

@protocol VideoCategoryBarDelegate <NSObject>

@required

- (void)videoCategoryBar:(VideoCategoryBar *)categoryBar menuItemDidSelect:(UIButton *)item;

@end

@interface VideoCategoryBar : UIView

@property (nonatomic, weak) id<VideoCategoryBarDelegate> delegate;


/**
 *  构造方法
 *
 *  @param titles               标题数组
 *  @param frame                大小
 *  @param unSelectedTitleColor 未选中标题色
 *  @param selectedTitleColor   选中标题色
 *  @param lineColor            横线颜色
 *
 *  @return VideoCategoryBar实例
 */
- (instancetype)initWithItemTitles:(NSArray<NSString *> *)titles andFrame:(CGRect)frame unSelectedTitleColor:(UIColor *)unSelectedTitleColor selectedTitleColor:(UIColor *)selectedTitleColor lineColor:(UIColor *)lineColor;


/**
 *  更新菜单项
 *
 *  @param titles 菜单标题数组
 */
- (void)reloadItemTitles:(NSArray<NSString *> *)titles;

@end
