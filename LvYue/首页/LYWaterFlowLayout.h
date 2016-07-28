//
//  LYWaterFlowLayout.h
//  LvYue
//
//  Created by 郑洲 on 16/3/18.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef CGFloat(^HeightBlock)(NSIndexPath *indexPath , CGFloat width);
@interface LYWaterFlowLayout : UICollectionViewFlowLayout
/** 列数 */
@property (nonatomic, assign) NSInteger lineNumber;
/** 行间距 */
@property (nonatomic, assign) CGFloat rowSpacing;
/** 列间距 */
@property (nonatomic, assign) CGFloat lineSpacing;
/** 内边距 */
@property (nonatomic, assign) UIEdgeInsets sectionInset;
/**
 *  计算各个item高度方法
 *
 *  @param block 设计计算item高度的block
 */
- (void)computeIndexCellHeightWithWidthBlock:(CGFloat(^)(NSIndexPath *indexPath , CGFloat width))block;

@end
