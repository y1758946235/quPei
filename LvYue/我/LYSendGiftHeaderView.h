//
//  LYSendGiftHeaderView.h
//  LvYue
//
//  Created by KentonYu on 16/7/27.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^LYSendGiftFetchCoinBlock)(id sender);

@interface LYSendGiftHeaderView : UICollectionReusableView

@property (nonatomic, copy) LYSendGiftFetchCoinBlock fetchCoinBlock;

- (void)configData:(NSString *)userName avatarImageURL:(NSString *)avatarImageURL accountAmount:(NSString *)accountAmount;

@end
