//
//  MyContactView.h
//  LvYue
//
//  Created by X@Han on 16/12/15.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyContactView : UIView

- (instancetype)initWithFrame:(CGRect)frame;

@property(nonatomic,strong) NSString*  FriendTag;
@property(nonatomic,strong) NSString*  AttentionTag;
@property(nonatomic,strong)  UILabel * redDotFriendsLabel;
@property(nonatomic,strong)  UILabel * redDotFansLabel;
@end
