//
//  MyFirstPhotoCell.h
//  LvYue
//
//  Created by X@Han on 16/12/20.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "firstPhotoModel.h"
@interface MyFirstPhotoCell : UITableViewCell
@property(nonatomic,retain)UIImageView *photoImage;
@property(nonatomic,copy)NSString *userId;
@property (nonatomic,retain)UILabel *noLabel;
@property (nonatomic,retain)UILabel *photoLabel;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier photoArr:(NSArray*)photoArr;
@end
