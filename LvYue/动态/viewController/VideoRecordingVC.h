//
//  VideoRecordingVC.h
//  LvYue
//
//  Created by X@Han on 17/5/22.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoRecordingVC : UIViewController
@property(nonatomic,assign)BOOL isSenderGiftAsk;
@property(nonatomic,assign)BOOL isPopToLastVc;
@property (nonatomic, strong) NSString *selectShareTopicId;
@property (nonatomic, strong) NSString *selectShareTopicTitle;
@end
