//
//  DyVideoPlayerViewController.h
//  LvYue
//
//  Created by X@Han on 17/6/6.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "BaseViewController.h"

@interface DyVideoPlayerViewController : BaseViewController
@property (nonatomic, strong) NSURL *videoURL;
@property (nonatomic, copy) NSString *nameStr;
@property (nonatomic, copy) NSString *headUrlStr;
@property (nonatomic, copy) NSString *otherId;

@property (nonatomic, copy) NSString *shareContentStr;
@property (nonatomic, copy) NSString *videoId;


//-(void)reloadData;
@end
