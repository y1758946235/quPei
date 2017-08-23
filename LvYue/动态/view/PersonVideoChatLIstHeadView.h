//
//  PersonVideoChatLIstHeadView.h
//  LvYue
//
//  Created by X@Han on 17/8/7.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DynamicListModel;
@interface PersonVideoChatLIstHeadView : UIView
@property(nonatomic,strong)UIButton *PraiseBtn;
@property(nonatomic,strong)UILabel *sendMessLabel;
@property(nonatomic,strong)UILabel *PraiseNumLabel;
@property(nonatomic,assign)BOOL isLike;
@property(nonatomic,strong) UIButton *edit;  //；
-(void)creatModel:(DynamicListModel*)model;
@end
