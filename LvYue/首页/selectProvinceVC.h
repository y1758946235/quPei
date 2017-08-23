//
//  selectProvinceVC.h
//  LvYue
//
//  Created by X@Han on 17/1/6.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "BaseViewController.h"
typedef void (^CurrnentLocationBlock)(NSString *currentProvince,NSString *currentCity,NSString *currentDistrict);
@interface selectProvinceVC : BaseViewController
@property(nonatomic,strong)NSString *locCountry;
@property(nonatomic,strong)NSString *locPlace;
@property (nonatomic,strong) NSString *preView;


@property (nonatomic, copy) CurrnentLocationBlock currnentLocationBlock;

- (void)currnentLocationBlock:(CurrnentLocationBlock)block;
@end
