//
//  sendAppointCell.h
//  LvYue
//
//  Created by X@Han on 16/12/1.
//  Copyright © 2016年 OLFT. All rights reserved.
//


typedef enum {
    CellTagDefault = 100,
} CellTag;



#import <UIKit/UIKit.h>

@interface sendAppointCell : UIView

@property(nonatomic,retain)NSMutableArray *selectedBtnList;
@property(nonatomic,retain)UIButton *sendPointBtn;  //发布约会按钮
@property(nonatomic,retain)UITextView *savView;  //发布约会的说明
@property(nonatomic,retain)UIButton *buyIndefiniteBtn; //不定
@property(nonatomic,retain)UIButton *AABt;
@property(nonatomic,retain)UIButton *youBuyBtn;
@property(nonatomic,retain)UIButton *meBuyBtn;
@property(nonatomic,retain)UIButton *songIndefiniteBtn;
@property(nonatomic,retain)UIButton *KeSongBtn;
@property(nonatomic,retain)UIButton *xuSongBtn;
@property(nonatomic,retain)UIButton *sexBtn;

@property(nonatomic,retain)UIButton *addPhotoBtn;
@property(nonatomic,retain)UIView * photoView;
- (UIView *)initCellWithIndex:(NSIndexPath *)index;


@end
