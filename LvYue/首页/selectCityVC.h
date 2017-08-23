//
//  selectCityVC.h
//  LvYue
//
//  Created by X@Han on 17/1/6.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "BaseViewController.h"

@interface selectCityVC : BaseViewController

@property(nonatomic,copy)NSString *preLoc;
@property(nonatomic,assign)BOOL isProvince;
@property (nonatomic,copy) NSString *countryId;
@property (nonatomic,copy) NSString *preName;
@property (nonatomic,copy) NSString *preView;
@property (nonatomic,copy) NSString *countryName;
@property(nonatomic,copy)NSString *place;  //选择的地方
@property(nonatomic,copy)NSString *placeId;   //选择地方的id

@end
