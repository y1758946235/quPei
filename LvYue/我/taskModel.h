//
//  taskModel.h
//  LvYue
//
//  Created by X@Han on 17/4/10.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface taskModel : NSObject
@property(copy,nonatomic)NSString *taskId;//:任务id(Integer)
@property(copy,nonatomic)NSString *taskContent;//:任务内容
@property(copy,nonatomic)NSString *keyNumber;//:任务奖励钥匙(Integer)
@property(copy,nonatomic)NSString *interfaceName;//:接口名称
@property(copy,nonatomic)NSString *isFinish;//:是否完成0未完成1已完成2完成未领取(Integer)
@property(copy,nonatomic)NSString *isFinishStr;//:是否完成0未完成1已完成2完成未领取(Integer)


- (id)initWithModelDic:(NSDictionary *)dic;
+ (id)createWithModelDic:(NSDictionary *)dic;
@end
