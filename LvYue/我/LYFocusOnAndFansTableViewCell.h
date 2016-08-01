//
//  LYFocusOnAndFansTableViewCell.h
//  LvYue
//
//  Created by KentonYu on 16/8/1.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^TapFocusOnImageViewBlock)(id sender);

@interface LYFocusOnAndFansTableViewCell : UITableViewCell

@property (nonatomic, copy) TapFocusOnImageViewBlock tapFocusOnImageViewBlock;


- (void)configData:(NSDictionary *)dic;

@end
