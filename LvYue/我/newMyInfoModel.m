//
//  newMyInfoModel.m
//  LvYue
//
//  Created by X@Han on 16/12/26.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "newMyInfoModel.h"

@implementation newMyInfoModel


- (id)initWithModelDic:(NSDictionary *)dic{
    if (self) {
        self.headImage = dic[@"userIcon"];
        self.nickName = dic[@"userNickname"];
        self.sign = dic[@"userSignature"];
        self.age = dic[@"userAge"];
        self.height = dic[@"userHeight"];
        self.constelation = dic[@"userConstellation"];
        self.edu = dic[@"userQualification"];
        self.work = dic[@"userProfession"];
        self.weight = dic[@"userWeight"];
        self.dateProvince = dic[@"userProvince"];
        self.dateCity = dic[@"userCity"];
        self.sex = dic[@"userSex"];
        self.vipLevel = dic[@"vipLevel"];
        self.aboutSex = dic[@"userOpinionSex"];
        self.aboutLove = dic[@"userOpinionLove"];
        self.aboutOther = dic[@"userOpinionHalf"];
        self.userId = dic[@"userId"];
        
        self.userGoodAt = dic[@"userGoodAt"];
        if (self.userGoodAt) {
            //以逗号分开   判断有几个擅长
            if (self.userGoodAt.length>0) {
                 self.userGoodAtArr = [self.userGoodAt componentsSeparatedByString:@","];
            }
           
            
        }
        
        self.userMobile = dic[@"userMobile"];
        self.userWX = dic[@"userWX"];
        self.userQQ = dic[@"userQQ"];
            }
    
    return self;
}
+ (id)createWithModelDic:(NSDictionary *)dic{
    
    return [[self alloc]initWithModelDic:dic];
}






@end
@implementation provinceModel

+ (instancetype)modelWithDictionary:(NSDictionary *)dic{
    return [[self alloc] initWithDictionary:dic];
}
- (instancetype)initWithDictionary:(NSDictionary *)dic{
    self = [super init];
    if (self) {
        
        // [self setValuesForKeysWithDictionary:dic];
        
        self.provinceName =[NSString  stringWithFormat:@"%@",dic[@"provinceName"]] ;
        
        
        
    }
    return self;
}

@end

@implementation cityModel

+ (instancetype)modelWithDictionary:(NSDictionary *)dic{
    return [[self alloc] initWithDictionary:dic];
}
- (instancetype)initWithDictionary:(NSDictionary *)dic{
    self = [super init];
    if (self) {
        
        // [self setValuesForKeysWithDictionary:dic];
        
       
        self.cityName = [NSString  stringWithFormat:@"%@",dic[@"cityName"]] ;
        
        
        
    }
    return self;
}

@end
@implementation distrModel

+ (instancetype)modelWithDictionary:(NSDictionary *)dic{
    return [[self alloc] initWithDictionary:dic];
}
- (instancetype)initWithDictionary:(NSDictionary *)dic{
    self = [super init];
    if (self) {
        
        // [self setValuesForKeysWithDictionary:dic];
        
        
        self.distrName = [NSString  stringWithFormat:@"%@",dic[@"fileUrl"]] ;
        
        
    }
    return self;
}

@end
