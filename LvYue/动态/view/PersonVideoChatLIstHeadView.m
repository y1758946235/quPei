//
//  PersonVideoChatLIstHeadView.m
//  LvYue
//
//  Created by X@Han on 17/8/7.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "PersonVideoChatLIstHeadView.h"
#import "DynamicListModel.h"
@implementation PersonVideoChatLIstHeadView{
    DynamicListModel *aModel;
    NSString *deleteShareId;
}
- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor =[UIColor  cyanColor];
                
        //   删除 按钮
        UIButton *edit = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-90, 0, 50,50)];
        //    edit.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
        //    edit.imageEdgeInsets = UIEdgeInsetsMake(16, 18, 16, 18);
        [edit setImage:[UIImage imageNamed:@"deletephoto"] forState:UIControlStateNormal];
        edit.hidden = YES;
        [edit addTarget:self action:@selector(delete:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:edit];
        


    }
    return self;
    
}
-(void)messClick:(UIButton *)sender{
    
}
-(void)PraiseClick:(UIButton *)sender{
    
}




-(void)creatModel:(DynamicListModel*)model{
    aModel = model;
    if ([[NSString stringWithFormat:@"%@",model.isLike] isEqualToString:@"1"] ) {
         [_PraiseBtn setImage:[UIImage imageNamed:@"ic_video_play_like_white_liked"] forState:UIControlStateNormal];
    }

    _PraiseNumLabel.text = [NSString stringWithFormat:@"%@",model.likeNumber];
    _sendMessLabel.text = [NSString stringWithFormat:@"%@",model.videoCommentNumber];
    
    if ([[NSString stringWithFormat:@"%@",model.userId] isEqualToString:[CommonTool getUserID]]) {
        self.edit.hidden = NO;
    }

}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
