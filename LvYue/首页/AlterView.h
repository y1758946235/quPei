//
//  AlterView.h
//  LvYue
//
//  Created by X@Han on 17/4/11.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlterView : UIView

@property(nonatomic,retain)UIButton *liaoBtn;
@property(nonatomic,copy)NSString *typeUser;
- (instancetype)initWithFrame:(CGRect)frame;
-(void)creatDataArr:(NSMutableArray *)dataArr;

@end
