//
//  SearchResultViewController.h
//  LvYue
//
//  Created by 郑洲 on 16/3/18.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "BaseViewController.h"

@interface SearchResultViewController : BaseViewController

@property (nonatomic, strong) NSMutableArray *resultData;
@property (nonatomic, copy) NSString *sex;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *age;
@property (nonatomic, copy) NSString *searchs;
@property (nonatomic, copy) NSString *longitude;
@property (nonatomic, copy) NSString *latitude;

@end
