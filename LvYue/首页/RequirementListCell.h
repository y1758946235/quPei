//
//  RequirementListCell.h
//  LvYue
//
//  Created by 郑洲 on 16/4/11.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RequirementModel.h"

@interface RequirementListCell : UITableViewCell

- (void)createWithModel:(RequirementModel *)model;

@end
