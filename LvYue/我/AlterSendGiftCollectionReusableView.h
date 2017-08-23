//
//  AlterSendGiftCollectionReusableView.h
//  LvYue
//
//  Created by X@Han on 17/6/22.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^LYSendGiftFetchCoinBlock)(id sender);
@interface AlterSendGiftCollectionReusableView : UICollectionReusableView

@property (nonatomic, copy) LYSendGiftFetchCoinBlock fetchCoinBlock;
@property (strong, nonatomic)  UILabel *coinLabel;
@property (strong, nonatomic)  UIButton *getCoinBtn;
- (void)configDataAccountAmount:(NSString *)accountAmount;
@end
