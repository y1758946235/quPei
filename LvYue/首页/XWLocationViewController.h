//
//  LocationViewController.h
//  豆客项目
//
//  Created by Xia Wei on 15/10/9.
//  Copyright © 2015年 Xia Wei. All rights reserved.
//

#import "BaseViewController.h"

@interface XWLocationViewController : BaseViewController

@property(nonatomic,strong)NSString *preLoc;
@property(nonatomic,assign)BOOL isProvince;
@property (nonatomic,strong) NSString *countryId;
@property (nonatomic,strong) NSString *preName;
@property (nonatomic,strong) NSString *preView;
@property (nonatomic,strong) NSString *countryName;

@end
