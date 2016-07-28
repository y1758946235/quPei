//
//  LYDetailDataPhotoTableViewCell.h
//  LvYue
//
//  Created by KentonYu on 16/7/27.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LYDetailDataPhotoTableViewCell : UITableViewCell

/**
 *  传入照片 URL
 *
 *  @param imageURLArray 图片URL
 *  @param essenceImage  是否是精华图片
 */
- (void)configPhotoArray:(NSArray *)imageURLArray title:(NSString *)title essenceImage:(BOOL)essenceImage;

@end
