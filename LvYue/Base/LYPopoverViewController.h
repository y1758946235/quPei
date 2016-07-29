//
//  LYPopoverViewController.h
//  LvYue
//
//  Created by KentonYu on 16/7/29.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LYPopoverTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *titleLabel;

@end


typedef void(^LYPopoverTableViewCellSelectedBlock)(void);

@interface LYPopoverViewController : UIViewController

/**
 *  popover 的内容以及处理回调 Block
 *  keys : title  block
 */
@property (nonatomic, strong) NSArray<NSDictionary *> *itemInfoArray;

@end
