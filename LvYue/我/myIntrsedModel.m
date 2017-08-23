//
//  myIntrsedModel.m
//  LvYue
//
//  Created by X@Han on 17/1/17.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "myIntrsedModel.h"

@implementation myIntrsedModel
- (id)initWithModelDic:(NSDictionary *)dic{
    NSLog(@">>>%@",dic);
    self = [super init];
    if (self) {
        self.otherId = dic[@"userId"];
        self.appointType = dic[@"dateTypeName"];
        self.height = dic[@"userHeight"];
        self.constelation = dic[@"userConstellation"];
        self.work = dic[@"userProfession"];
        self.nickName = dic[@"userNickname"];
        self.age = dic[@"userAge"];
        self.createTime = dic[@"createTime"];
        self.activityTime = dic[@"activityTime"];
        self.dateCity = dic[@"dateCity"];
        self.dateProvince = dic[@"dateProvince"];
        self.dateDistrict = dic[@"dateDistrict"];
        NSString *str = dic[@"dateTagNameArr"];
        str = [str stringByReplacingOccurrencesOfString:@"," withString:@"/"];
        self.aaLabel = str;
        //        self.dateImage = dic[@"datePhoto"];
        
        self.imageArr = [self setImageBottom:dic[@"datePhoto"]];
        if (_imageArr.count==1) {
            self.cellHeight = 370+178;
        }else if (_imageArr.count==0){
            self.cellHeight = 370;
        }else {
            self.cellHeight = 370+85;
        }
        self.headImage = dic[@"userIcon"];
        self.sex = dic[@"userSex"];
        self.vip = dic[@"isVip"];
        self.dataDescription = dic[@"dateSignature"];
        if (_dataDescription.length>0) {
            CGRect size = [_dataDescription boundingRectWithSize:CGSizeMake(SCREEN_WIDTH-48, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil];
            //            self.cellHeight -= 105;
            self.cellHeight += size.size.height;
        }else {
            //            self.cellHeight -= 105;
        }
        
        
        self.intrestedImage = dic[@"userIcon"];
    }
    
    return self;
}

+ (id)createWithModelDic:(NSDictionary *)dic{
    
    return [[self alloc]initWithModelDic:dic];
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

@end
