//
//  appointModel.m
//  LvYue
//
//  Created by X@Han on 16/12/5.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "appointModel.h"
#import "pchFile.pch"
@implementation appointModel

- (id)initWithModelDic:(NSDictionary *)dic{

    self = [super init];
    if (self) {
        
        self.otherId = dic[@"userId"] ;
        self.appointType = dic[@"dateTypeName"];
        self.height = dic[@"userHeight"];
        self.constelation = dic[@"userConstellation"];
        self.work = dic[@"userProfession"];
        self.nickName = dic[@"userNickname"];
        self.age = dic[@"userAge"];
        
        self.createTimestamp = dic[@"createTime"];
        self.createTime = [CommonTool updateTimeForRow:dic[@"createTime"]];
        //13位时间戳转成10位
        self.activityTime =[CommonTool timestampSwitchTime:[dic[@"activityTime"] doubleValue]/1000 andFormatter:@"YYYY-MM-dd"] ;
        self.isTest = dic[@"isTest"];
        self.dateCity = dic[@"dateCity"];
        self.dateProvince = dic[@"dateProvince"];
        self.dateDistrict = dic[@"dateDistrict"];
        self.dateActivityId =  dic[@"dateActivityId"];

        NSString *str = dic[@"dateTagNameArr"];
        str = [str stringByReplacingOccurrencesOfString:@"," withString:@"/"];
        self.aaLabel = str;

        
       
        self.inststates = dic[@"isInterest"];
       
        self.headImage = dic[@"userIcon"];
        self.sex = dic[@"userSex"];
        self.vipLevel = dic[@"vipLevel"];
        self.dataDescription = dic[@"dateSignature"];
        self.cellHeight = 226 *AutoSizeScaleX;
        self.imageTopY =  226*AutoSizeScaleX;
        self.chatBtnTopY = 226*AutoSizeScaleY;
        
        if (_dataDescription.length>0) {
            
            
            CGRect size = [_dataDescription boundingRectWithSize:CGSizeMake(SCREEN_WIDTH-48*AutoSizeScaleX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14*AutoSizeScaleX]} context:nil];


                self.dataDescriptionHeight =  size.size.height;
                self.cellHeight = self.cellHeight + self.dataDescriptionHeight +24*AutoSizeScaleX;
              self.imageTopY =  self.imageTopY + self.dataDescriptionHeight +24*AutoSizeScaleY;
                self.chatBtnTopY = self.chatBtnTopY +self.dataDescriptionHeight  +23*AutoSizeScaleX;
            

        }else {

            self.cellHeight = 226 *AutoSizeScaleX;
            self.imageTopY =  226*AutoSizeScaleY;
            self.chatBtnTopY = 226*AutoSizeScaleX;
        }

        self.imageArr = [self setImageBottom:dic[@"datePhoto"]];
        if (_imageArr.count==1) {
            self.imageHeight = 178*AutoSizeScaleX;
            self.cellHeight = self.cellHeight +self.imageHeight +23*AutoSizeScaleX;
            self.chatBtnTopY = self.chatBtnTopY +self.imageHeight +23*AutoSizeScaleX;

        }else if (_imageArr.count==2 || _imageArr.count==3 ){
            self.imageHeight = 85*AutoSizeScaleX;
            self.cellHeight = self.cellHeight +self.imageHeight +23*AutoSizeScaleX;
            self.chatBtnTopY = self.chatBtnTopY +self.imageHeight +23*AutoSizeScaleX;
        }else {

            //            self.cellHeight = 370;
            self.imageHeight = 0;
            self.cellHeight = self.cellHeight;
            self.chatBtnTopY = self.chatBtnTopY +self.imageHeight;

        }
        

        self.integerDatePersonArr = dic[@"integerDatePerson"];
     
        
        if (self.integerDatePersonArr.count > 0) {
           self.cellHeight= self.cellHeight + 40*AutoSizeScaleX + 24*AutoSizeScaleX + 80*AutoSizeScaleX;
          
            
        }else{
        
             self.cellHeight= self.cellHeight + 40*AutoSizeScaleX+36*AutoSizeScaleX;
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



//- (void)ReturnDiquName:(ReturnDiquBlock)block{
//    self.returnDiquBlock = block;
//}
//@implementation integerDatePerson
//
//+ (instancetype)modelWithDictionary:(NSDictionary *)dic{
//    return [[self alloc] initWithDictionary:dic];
//}
//- (instancetype)initWithDictionary:(NSDictionary *)dic{
//    self = [super init];
//    if (self) {
//        
//        // [self setValuesForKeysWithDictionary:dic];
//         self.userId = dic[@"userId"];
//        self.userIcon = dic[@"userIcon"];
//        
//    }
//    return self;
//}

@end
