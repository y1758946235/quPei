//
//  AlbumCollectionViewCell.h
//  LvYue
//
//  Created by X@Han on 17/4/19.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AlbumModel;
@interface AlbumCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) UIImageView *imageViewM;

-(void)creatModel:(AlbumModel *)model userId:(NSString*)userId;
@end
