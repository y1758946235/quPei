//
//  LYSendGiftCollectionViewCell.h
//  LvYue
//
//  Created by KentonYu on 16/7/27.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LYSendGiftModel;

@interface LYSendGiftCollectionViewCell : UICollectionViewCell

- (void)selected;
- (void)unSelected;
- (void)configData:(LYSendGiftModel *)data;

@end
