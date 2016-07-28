//
//  HotMessageCollectionViewCell.h
//  LvYue
//
//  Created by 郑洲 on 16/3/15.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HotModel.h"

@interface HotMessageCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *showImageView;
@property (nonatomic, strong) UILabel *markLabel;
@property (nonatomic, strong) UILabel *timeLabel;

- (void)fillData:(HotModel *)model;

@end
