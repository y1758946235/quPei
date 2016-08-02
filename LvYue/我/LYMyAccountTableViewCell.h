//
//  LYMyAccountTableViewCell.h
//  LvYue
//
//  Created by KentonYu on 16/8/2.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, LYMyAccountTableViewCellType) {
    LYMyAccountTableViewCellTypeCoin = 0,
    LYMyAccountTableViewCellWithDraw = 1
};

typedef void (^FetchCoinBlock)(id sender);

@interface LYMyAccountTableViewCell : UITableViewCell

@property (nonatomic, copy) FetchCoinBlock fetchBlock;

- (void)configData:(LYMyAccountTableViewCellType)type coin:(NSString *)coin;

@end
