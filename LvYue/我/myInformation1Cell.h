//
//  myInformation1Cell.h
//  LvYue
//
//  Created by X@Han on 16/12/21.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "newMyInfoModel.h"
@interface myInformation1Cell : UITableViewCell

@property(nonatomic,retain)UILabel *ageLabel;
@property(nonatomic,retain)UILabel *heightLabel;
@property(nonatomic,retain)UILabel *colleaLabel; //星座
@property(nonatomic,retain)UILabel *workLabel;
@property(nonatomic,retain)UILabel *weightLabel;
@property(nonatomic,retain)UILabel *cityLabel;
@property(nonatomic,retain)UILabel *eduLabel;  //学历
@property(nonatomic,copy)NSString *userId;
//@property(nonatomic,strong) newMyInfoModel*myModel;
@property(nonatomic,strong) NSMutableArray*myArr;
@property (nonatomic,assign)CGFloat secoFirHeight;
@property (nonatomic,assign)CGFloat secoSecoHeight;
@property (nonatomic,assign)CGFloat secoThirHeight;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andIndexPath:(NSIndexPath *)indexPath MyModel:(newMyInfoModel *)myModel goodArr:(NSArray*)goodArray;




@end
