//
//  TopicVideoPlayerViewController.h
//  LvYue
//
//  Created by X@Han on 17/8/10.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "BaseViewController.h"

@interface TopicVideoPlayerViewController : BaseViewController
@property(nonatomic,assign) NSInteger index;
-(void)loadDataArr:(NSArray *)dataArr;

@end
