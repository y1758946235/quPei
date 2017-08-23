//
//  AlterSendGiftView.h
//  LvYue
//
//  Created by X@Han on 17/6/20.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^GiftInfoBlock)(NSString *giftName,NSURL *giftUrl,NSString *giftGoldsNum);
typedef void (^SenderGiftAskBlock)(NSString *giftName,NSURL *giftUrl,NSInteger giftId,NSInteger giftGoldsNum);
@interface AlterSendGiftView : UIView

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, copy) NSString *userName;         //对方的名字
@property (nonatomic, copy) NSString *friendID;         //对方的ID

@property (nonatomic, assign) BOOL isSendGiftAsk;

@property (nonatomic, copy) GiftInfoBlock giftInfoBlock;
@property (nonatomic, copy) SenderGiftAskBlock senderGiftAskBlock;

- (void)giftInfoBlock:(GiftInfoBlock)block;
- (void)senderGiftAskBlock:(SenderGiftAskBlock)block;
- (void)p_loadGift;
- (void)p_loadAccountAmount;
@end
