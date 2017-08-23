//
//  AlterSendGiftCollectionViewCell.h
//  LvYue
//
//  Created by X@Han on 17/6/21.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LYSendGiftModel;
@interface AlterSendGiftCollectionViewCell : UICollectionViewCell
- (void)selected;
- (void)unSelected;
- (void)configData:(LYSendGiftModel *)data;
@end
