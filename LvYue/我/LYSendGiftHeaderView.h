//
//  LYSendGiftHeaderView.h
//  LvYue
//
//  Created by KentonYu on 16/7/27.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LYSendGiftHeaderView : UICollectionReusableView

- (void)configData:(NSString *)userName avatarImageURL:(NSString *)avatarImageURL accountAmount:(NSString *)accountAmount;

@end
