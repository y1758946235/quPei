//
//  WhoLookMeHead.h
//  LvYue
//
//  Created by X@Han on 16/12/20.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WhoLookMeHead : UIView
@property(nonatomic,copy)NSString *userId;
- (UIView *)initCellWithIndex:(NSIndexPath*)index;

@end
