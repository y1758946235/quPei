//
//  DynamicListModel.m
//  LvYue
//
//  Created by X@Han on 17/6/7.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "DynamicListModel.h"

@implementation DynamicListModel
- (id)initWithModelDic:(NSDictionary *)dic{
    if (self) {
        
        
        self.shareId = dic[@"videoId"];
        self.userId = dic[@"userId"];
        self.createTime = dic[@"createTime"];
        self.insertTime = dic[@"insertTime"];
        self.userSex = dic[@"userSex"];
        self.userAge = dic[@"userAge"];
        self.isRelay = dic[@"isRelay"];
        self.shareUrl = dic[@"videoUrl"];
        self.shareType = dic[@"shareType"];
//        if ([[NSString stringWithFormat:@"%@",self.shareType] isEqualToString:@"0"]) {
            self.showUrl = dic[@"showUrl"];//视频缩略图
//        }else{
//           self.showUrl = dic[@"shareUrl"];//图片地址
//        }
        
        self.userIcon = dic[@"userIcon"];
        self.userNickname = dic[@"userNickname"];
        self.vipLevel = dic[@"vipLevel"];
        self.otherUserId = dic[@"otherUserId"];
        self.shareType = dic[@"shareType"];
        self.shareSignature= dic[@"videoSignature"];
        
        
        
        if (self.shareSignature.length>0) {
            
            
            CGRect size = [self.shareSignature boundingRectWithSize:CGSizeMake(SCREEN_WIDTH-48, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil];
            self.contLabelHeight = size.size.height;
        }else {
            self.contLabelHeight = -16;
        }
        
        self.showImageArr = [self setImageBottom:self.showUrl];
        if ( self.showImageArr.count==1) {
            self.showImageVheight = 178;
        }else if ( self.showImageArr.count==2 ||  self.showImageArr.count==3 ){
            self.showImageVheight = 85;
        }else {
            self.showImageVheight = -16;
        }
        
        self.videoCommentNumber= dic[@"videoCommentNumber"];
        self.isLike= dic[@"isLike"];
        self.likeNumber= dic[@"likeNumber"];
        self.playNumber= dic[@"playNumber"];
        self.videoId = dic[@"videoId"];
        
        
        
    }
    return self;
}

#pragma mark   ---约会发布的图片
- (NSArray *)setImageBottom:(NSString *)imageData {
    if (imageData.length<4) {
        return nil;
    }
    
    NSArray *imageArr = [imageData componentsSeparatedByString:@","];
    NSMutableArray *URLArr = [NSMutableArray array];
    for (NSInteger i = 0 ; i<imageArr.count ;i++) {
        
        
        //这个是图片的名字
        
        NSURL *imageUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,imageArr[i]]];
        [URLArr addObject:imageUrl];
        
    }
    
    return URLArr;
}
+ (id)createWithModelDic:(NSDictionary *)dic{
    
    return [[self alloc]initWithModelDic:dic];
    
}
@end
