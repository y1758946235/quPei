//
//  VideoAskViewController.h
//  LvYue
//
//  Created by X@Han on 17/7/26.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "BaseViewController.h"

@interface VideoAskViewController : BaseViewController
@property(nonatomic,copy)NSString *otherId;
@property(nonatomic,copy)NSString *nameStr;
@property(nonatomic,assign)BOOL isFromDyVideoPlayerViewController;
@property (nonatomic, assign) BOOL isExistedSendGiftAskNotification;
@end
