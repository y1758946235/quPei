//
//  SystemMessageTableViewCell.m
//  LvYue
//
//  Created by X@Han on 17/5/31.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "SystemMessageTableViewCell.h"
#import "SystemMessageModel.h"
#import "AllWordViewController.h"
#import "otherZhuYeVC.h"
@implementation SystemMessageTableViewCell{
    SystemMessageModel * _model;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle: style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self creatUI];
    }
    
    return self;
}
-(void)creatUI{
   
        self.timeStampLabel      = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 -100, 10, 200, 20)];
        self.timeStampLabel.textAlignment = NSTextAlignmentCenter;
        self.timeStampLabel.layer.cornerRadius = 10;
    
        self.timeStampLabel.textColor = [UIColor colorWithHexString:@"#9e9e9e"];
        self.timeStampLabel.clipsToBounds = YES;
    self.timeStampLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:self.timeStampLabel];
    
    //chat_receiver_bg
    self.bubblesImageV  = [[UIImageView alloc]init];
    self.bubblesImageV.frame = CGRectMake(62, 40, SCREEN_WIDTH-96, 40);
    UIImage * backImage;
    backImage = [UIImage imageNamed:@"chat_receiver_bg"];
    backImage = [backImage resizableImageWithCapInsets:UIEdgeInsetsMake(35, 22, 10, 10)];
    self.bubblesImageV.image = backImage;
//    self.bubblesImageV.image = [UIImage imageNamed:@"chat_receiver_bg"];
    [self.contentView addSubview:self.bubblesImageV];
    
    self.headImageV = [[UIImageView alloc]initWithFrame:CGRectMake(16, 40, 40, 40)];
    self.headImageV.layer.cornerRadius = 20;
    self.headImageV.clipsToBounds = YES;
    [self addSubview:self.headImageV];
    self.headImageV.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(goOtherVC)];
    [self.headImageV addGestureRecognizer:tap];

        
        self.messageLabel      = [[UILabel alloc] initWithFrame:CGRectMake(72, 60, SCREEN_WIDTH-96, 20)];
        self.messageLabel.superview.layer.cornerRadius = 10.0;
    self.messageLabel.font = [UIFont systemFontOfSize:16];
    self.messageLabel.numberOfLines = 0;
    self.messageLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.messageLabel.textColor = [UIColor colorWithHexString:@"#424242"];
        self.messageLabel.superview.clipsToBounds = YES;
        [self.contentView addSubview:self.messageLabel];
        
//        UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(lookAll:)];
//        self.messageLabel.userInteractionEnabled = YES;
//        [self.messageLabel addGestureRecognizer:tap2];
    
    
    
}


- (void)fillDataWithModel:(SystemMessageModel *)model {
    _model = model;
    self.messageLabel.text =[NSString stringWithFormat:@"%@",model.content] ;
    self.messageLabel.frame = CGRectMake(72, 50, SCREEN_WIDTH-96, model.descriptionHeight);
    self.bubblesImageV.frame = CGRectMake(62, 40, model.descriptionWieth+20, model.descriptionHeight+20);
    self.timeStampLabel.text = [CommonTool timestampSwitchTime:[model.timeStamp doubleValue]/1000 andFormatter:@"YYYY-MM-dd hh:mm:ss"]  ;
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,model.userIcon]];
    [self.headImageV sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"systom_head"]];
    
    self.cellHeight = model.cellHeight;
}
-(void)goOtherVC{
    if ([[NSString stringWithFormat:@"%@",_model.userId] isEqualToString:@"0"]) {
        
    }else{
    
    otherZhuYeVC *VC = [[otherZhuYeVC alloc]init];
    VC.userNickName = _model.userNickname;
    VC.userId = _model.userId;
        [self.viewController.navigationController pushViewController:VC animated:YES];}
}
//- (void)lookAll:(UIGestureRecognizer *)ges{
//    AllWordViewController *all = [[AllWordViewController alloc] init];
//    all.title = @"详情";
//    all.detail = self.messageLabel.text;
//    [self.navi pushViewController:all animated:YES];
//}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
