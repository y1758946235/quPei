//
//  LYMyGiftTableViewCell.h
//  LvYue
//
//  Created by KentonYu on 16/8/1.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "LYMyGiftViewController.h"
#import <UIKit/UIKit.h>

@interface LYMyGiftTableViewCell : UITableViewCell

@property (nonatomic, assign) LYMyGiftViewControllerType type;

- (void)configData:(NSDictionary *)dic;

@end
