//
//  TopicVideoPlayCollectionViewCell.h
//  LvYue
//
//  Created by X@Han on 17/8/10.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DyVideoListModel ;
typedef void(^LZBVideoPlayCollectionViewCellCloseClickBlock)();
@interface TopicVideoPlayCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) NSURL *videoURL;
@property (nonatomic, copy) NSString *nameStr;
@property (nonatomic, copy) NSString *headUrlStr;
@property (nonatomic, copy) NSString *otherId;

@property (nonatomic, copy) NSString *shareContentStr;
@property (nonatomic, copy) NSString *videoId;

/** videoPath */
@property(nonatomic, strong)NSString *videoPath;
@property(nonatomic, strong)NSIndexPath *indexPath;

//点击关闭按钮
@property (nonatomic, copy) LZBVideoPlayCollectionViewCellCloseClickBlock closeClick;
-(void)setCloseClick:(LZBVideoPlayCollectionViewCellCloseClickBlock)closeClick;

//刷新时间的数据
- (void)reloadTimeLabelWithTime:(NSInteger)time;

@property(nonatomic,strong) UIView *playerView;
-(void)creatModel:(DyVideoListModel*)model;
@end
