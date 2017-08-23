//
//  FriendTableView.h
//  LvYue
//
//  Created by leo on 2016/11/22.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FriendModel;
@interface FriendTableView : UIView
@property(nonatomic,retain)FriendModel *model;
- (instancetype)initWithFrame:(CGRect)frame;
-(void)setModel:(FriendModel *)model;
- (void)postRequest;
@end
