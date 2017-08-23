//
//  myDataModel.m
//  LvYue
//
//  Created by X@Han on 17/1/10.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "myDataModel.h"

@implementation myDataModel

- (id)initWithModelDic:(NSDictionary *)dic{
    // NSLog(@">>>%@",dic);
    self = [super init];
    if (self) {
        self.appointType = dic[@"dateTypeName"];
        self.createTime = dic[@"createTime"];
        self.activityTime = dic[@"activityTime"];
        self.dateCity = dic[@"dateCity"];
        self.dateProvince = dic[@"dateProvince"];
        self.dateDistrict = dic[@"dateDistrict"];
        self.dataId = dic[@"dateActivityId"];
        self.isTest = dic[@"isTest"];
        NSString *str = dic[@"dateTagNameArr"];
        
        str = [str stringByReplacingOccurrencesOfString:@"," withString:@"/"];
        self.aaLabel = str;
//        NSString *afer = [dic[@"datePhoto"] substringFromIndex:1];
//        NSLog(@"555555555555%@",afer);
        self.imageArr = [self setImageBottom:dic[@"datePhoto"]];
        self.dataDescription = dic[@"dateSignature"];

        CGRect size = [self.dataDescription boundingRectWithSize:CGSizeMake(SCREEN_WIDTH-48, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont fontWithName:@"PingFangSC-Light" size:14]} context:nil];
        if ([CommonTool dx_isNullOrNilWithObject:self.dataDescription]) {
            self.dataDescriptionHeight = 0;
        }else{
            self.dataDescriptionHeight = size.size.height +19;
        }
        
        if (self.imageArr.count == 0) {
            self.datePhotHeight = 0;
        }else if (self.imageArr.count == 1){
             self.datePhotHeight = 178+24;
        }else{
           
            self.datePhotHeight = (float)(SCREEN_WIDTH-48-16)/3+24;
        }
        
        
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
