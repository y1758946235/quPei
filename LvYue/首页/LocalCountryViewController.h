//
//  LocalCountryViewController.h
//  豆客项目
//
//  Created by Xia Wei on 15/10/9.
//  Copyright © 2015年 Xia Wei. All rights reserved.
//
typedef void (^CurrnentLocationBlock)(NSString *currentProvince,NSString *currentCity,NSString *currentDistrict);
#import "BaseViewController.h"

@interface LocalCountryViewController : BaseViewController
@property(nonatomic,strong)NSString *locCountry;  
@property(nonatomic,strong)NSString *locPlace;
@property (nonatomic,strong) NSString *preView;
@property (nonatomic,assign) BOOL xiugaiZiliao;

@property (nonatomic, copy) CurrnentLocationBlock currnentLocationBlock;

- (void)currnentLocationBlock:(CurrnentLocationBlock)block;
@end
