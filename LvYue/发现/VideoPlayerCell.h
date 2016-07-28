//
//  VideoPlayerCell.h
//  LvYue
//
//  Created by Olive on 15/12/30.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>
@class VideoDetail;

@interface VideoPlayerCell : UITableViewCell

@property (nonatomic, strong) NSIndexPath *indexPath;

@property (weak, nonatomic) IBOutlet UIImageView *previewImageView;

@property (weak, nonatomic) IBOutlet UIButton *playBtn;

@property (weak, nonatomic) IBOutlet UILabel *praiseNumLabel;

@property (weak, nonatomic) IBOutlet UIButton *praiseBtn;

@property (weak, nonatomic) IBOutlet UIButton *shareBtn;

+ (instancetype)videoPlayerCellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;

- (void)fillDataWithModel:(VideoDetail *)model;

@end
