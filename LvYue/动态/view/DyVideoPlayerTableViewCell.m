//
//  DyVideoPlayerTableViewCell.m
//  LvYue
//
//  Created by X@Han on 17/8/4.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "DyVideoPlayerTableViewCell.h"

@implementation DyVideoPlayerTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self creatUI];
    }
    return self;
}


-(void)creatUI{


}

-(void)reloadPlayer:(NSURL *)url{
    
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
