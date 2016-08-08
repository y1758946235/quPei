//
//  LYDetailDataHeaderView.h
//  LvYue
//
//  Created by KentonYu on 16/7/22.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MyInfoModel;

typedef void (^PlayAuthVideoBlock)(void);
typedef void (^ClickFoucsOnButtonBlock)(void);
typedef void (^ClickSendGiftButtonBlock)(void);
typedef void (^TapAvatarImageViewBlock)(UIImageView *imageView);

@interface LYDetailDataHeaderView : UIView

@property (nonatomic, copy) PlayAuthVideoBlock playAuthVideoBlock;
@property (nonatomic, copy) ClickFoucsOnButtonBlock foucsOnButtonBlock;
@property (nonatomic, copy) ClickSendGiftButtonBlock sendGiftButtonBlock;
@property (nonatomic, copy) TapAvatarImageViewBlock tapAvatarImageViewBlock;

- (void)configData:(MyInfoModel *)infoModel mySelf:(BOOL)mySelf;

@end
