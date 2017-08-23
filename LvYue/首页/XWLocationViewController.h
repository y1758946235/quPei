//
//  LocationViewController.h
//  豆客项目
//
//  Created by Xia Wei on 15/10/9.
//  Copyright © 2015年 Xia Wei. All rights reserved.
//

#import "BaseViewController.h"

@interface XWLocationViewController : BaseViewController

@property(nonatomic,copy)NSString *preLoc;
@property(nonatomic,assign)BOOL isProvince;
@property (nonatomic,copy) NSString *countryId;
@property (nonatomic,copy) NSString *preName;
@property (nonatomic,copy) NSString *preView;
@property (nonatomic,copy) NSString *countryName;
@property(nonatomic,copy)NSString *place;  //选择的地方
@property(nonatomic,copy)NSString *placeId;   //选择地方的id
@end
