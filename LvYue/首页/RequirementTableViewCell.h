//
//  RequirementTableViewCell.h
//  LvYue
//
//  Created by 郑洲 on 16/4/6.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RequirementTableViewCell : UITableViewCell {
    NSArray *_dataArray;
}

- (void)createWithData:(NSArray *)dataArray;

@end
