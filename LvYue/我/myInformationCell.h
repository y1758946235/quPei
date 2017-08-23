//
//  myInformationCell.h
//  LvYue
//
//  Created by X@Han on 16/12/21.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface myInformationCell : UITableViewCell
@property(nonatomic,retain)UIImageView *headImage;
@property(nonatomic,retain)UILabel *nickLabel;
@property(nonatomic,retain)UILabel *inrtoduceLabel;
@property(nonatomic,retain)UIImageView *photoImage;
@property(nonatomic,retain)UIImageView *sexImge;
@property(nonatomic,retain)UIButton *certificationBtn;
@property(nonatomic,strong)NSString *userId;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier photoArr:(NSMutableArray *)photoArr;
-(void)creatMyCerVideoUrl:(NSString*)myCerVideoUrl;

@end
