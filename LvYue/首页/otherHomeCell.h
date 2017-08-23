//
//  otherHomeCell.h
//  LvYue
//
//  Created by X@Han on 16/12/16.
//  Copyright © 2016年 OLFT. All rights reserved.
//

typedef enum {
    
    CellTagDefault=666,
    
}CellTag;

#import <UIKit/UIKit.h>
#import "newMyInfoModel.h"

@interface otherHomeCell : UIView

@property(nonatomic,retain)UILabel *ageLabel;
@property(nonatomic,retain)UILabel *heightLabel;
@property(nonatomic,retain)UILabel *colleaLabel; //星座
@property(nonatomic,retain)UILabel *workLabel;
@property(nonatomic,retain)UILabel *weightLabel;
@property(nonatomic,retain)UILabel *cityLabel;
@property(nonatomic,retain)UILabel *eduLabel;  //学历
@property(nonatomic,copy)NSString *userId;
//@property(nonatomic,retain)UIImageView *photoImage;
@property(nonatomic,retain)UIImageView *sexImge;
@property(nonatomic,retain)UIImageView *headImage;
@property(nonatomic,retain)UIButton * certificationBtn;
@property(nonatomic,retain)UIImageView * vipImagV;

@property(nonatomic,retain)UILabel *nameLabel;
@property(nonatomic,retain)UILabel *signLabel;
@property(nonatomic,retain)newMyInfoModel *model;
@property(nonatomic,retain)provinceModel *pModel;
@property(nonatomic,retain)cityModel *cModel;
@property (nonatomic,assign)CGFloat secoFirHeight;
@property (nonatomic,assign)CGFloat secoSecoHeight;
@property (nonatomic,assign)CGFloat secoThirHeight;
@property (nonatomic,assign)CGFloat secoFourHeight;
@property (nonatomic,assign)CGFloat secoHeight;
@property (nonatomic,assign)CGFloat ThirHeight;
@property (nonatomic,assign)CGFloat fourHeight;
@property (nonatomic,assign)CGFloat faveHeight;
@property (nonatomic,assign)CGFloat sixHeight;
//@property(nonatomic,strong)NSArray *goodArr;
- (UIView *)initCellWithIndex:(NSIndexPath *)index setModel:(newMyInfoModel *)model pModel:(provinceModel*)pModel cModel:(cityModel*)cModel goodArr:(NSArray*)goodArry;
//-(void)setModel:(newMyInfoModel *)model;
@end
