//
//  SearchViewController.h
//  豆客项目
//
//  Created by Xia Wei on 15/10/6.
//  Copyright © 2015年 Xia Wei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
typedef void (^ShaiXuanTextBlock)(NSString *placeId,NSString *arrayType,NSString *userSex);
@interface SearchNearbyViewController : BaseViewController<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)NSString *latitude;
@property(nonatomic,strong)NSString *longitude;

@property(nonatomic,copy)NSString *placee;
@property(nonatomic,copy)NSString *placeId;
@property(nonatomic,copy)NSString *arrayType;
@property(nonatomic,copy)NSString *userSex;


@property (nonatomic, copy) ShaiXuanTextBlock shaiXuanTextBlock;

- (void)shaiXuanText:(ShaiXuanTextBlock)block;
@end
