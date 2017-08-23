//
//  LYHttpPoster.m
//  LvYue
//
//  Created by apple on 15/9/28.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import "AFNetworking.h"
#import "LYHttpPoster.h"
#import "UserModel.h"
#import "appointModel.h"
#import "WhoLookMeModel.h"
#import "myDataModel.h"
#import "ReceiveGiftModel.h"
#import "MoneyListModel.h"
#import "WithdrawalRecordModel.h"
#import "InvitaModel.h"
#import "WhoEvaluationModel.h"
#import "GoldsRecordModel.h"
@implementation LYHttpPoster

+ (void)postHttpRequestByPost:(NSString *)requestUrl andParameter:(NSDictionary *)requestDict success:(void (^)(id))successBlock andFailure:(void (^)(id))failureBlock{


      AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
   
    manager.requestSerializer.timeoutInterval = 20.0;
    
    [manager POST:requestUrl parameters:requestDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        successBlock(responseObject);
        

    }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            //MLOG(@"\n请求失败 原因 : %@", error);
//            [MBProgressHUD showError:[NSString stringWithFormat:@"\n请求失败 原因 : %@", error]];
            failureBlock(error);
        }];
}

//  666
//首页 获取约会内容
+ (void)requestAppointContentDataWithParameters:(NSDictionary *)parameters Block:(void(^)(NSArray *arr))myBlock{
    
 
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 20.0f;
    [manager POST:[NSString stringWithFormat:@"%@/mobile/date/getDate",REQUESTHEADER] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *arr = responseObject;
        NSLog(@"约会内容:%@", arr);
      // NSDictionary *pageDic = responseObject[@"data"][@"pageInfo"];
        NSArray *listArr = responseObject[@"data"][@"list"];
//        NSLog(@"listArr--%@",listArr);
        NSMutableArray *resultArr = [NSMutableArray array];
       
        for (NSDictionary *dic in listArr) {
            appointModel *apModel = [appointModel createWithModelDic:dic];
          
            [resultArr addObject:apModel];
            
        }
        
        if (myBlock) {
            myBlock(resultArr);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error.localizedDescription);
        if (myBlock) {
            myBlock(nil);
            [MBProgressHUD showSuccess:error.localizedDescription];
        }
        
    }];
}


#pragma mark   -- -- 用户池数据
+ (void)requestUserChiWithParameters:(NSDictionary *)parameters Block:(void (^)(NSMutableArray * arr))myBlock{
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 20.0f;
    [manager POST:[NSString stringWithFormat:@"%@/mobile/pool/getUserPool",REQUESTHEADER] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //userGold userKey
        NSLog(@"666666666666666666用户池:%@",responseObject);
       
        NSArray *listArr = responseObject[@"data"][@"list"];

      NSMutableArray *resultArr = [NSMutableArray array];
      for (NSDictionary *dic in listArr) {
           UserModel *appoinModel = [UserModel createWithModelDic:dic];
            [resultArr addObject:appoinModel];
        }
        
        if (myBlock) {
            myBlock(resultArr);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error.localizedDescription);
        if (myBlock) {
            myBlock(nil);
             [MBProgressHUD showSuccess:error.localizedDescription];
        }
        
    }];
    
}
#pragma mark   -- -- 推送用户数据
+ (void)requestUserpPushDataWithParameters:(NSDictionary *)parameters Block:(void (^)(NSMutableArray *))myBlock{
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 20.0f;
    [manager POST:[NSString stringWithFormat:@"%@/mobile/pool/getUserPush",REQUESTHEADER] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"666666666666666666推荐用户:%@",responseObject);
        
        NSArray *listArr = responseObject[@"data"][@"list"];
        
        NSMutableArray *resultArr = [NSMutableArray array];
        for (NSDictionary *dic in listArr) {
            UserModel *appoinModel = [UserModel createWithModelDic:dic];
            [resultArr addObject:appoinModel];
        }
        
        if (myBlock) {
            myBlock(resultArr);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error.localizedDescription);
        if (myBlock) {
            myBlock(nil);
            [MBProgressHUD showSuccess:error.localizedDescription];
        }
        
    }];
    
}
//充值记录
+ (void)requestBuyMoneyWithParameters:(NSDictionary *)parameters block:(void (^)(NSMutableArray *))myBlock{
    
 
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 20.0f;
    [manager POST:[NSString stringWithFormat:@"%@/mobile/order/getOrderDetail",REQUESTHEADER] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"666666666666666666充值记录记录:%@",responseObject);
        NSArray *listArr = responseObject[@"data"][@"list"];
        
        NSMutableArray *resultArr = [NSMutableArray array];
        for (NSDictionary *dic in listArr) {
            MoneyListModel *model = [MoneyListModel createWithModelDic:dic];
            [resultArr addObject:model];
        }
        
        if (myBlock) {
            myBlock(resultArr);
        }

        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error.localizedDescription);
        //        if (myBlock) {
        //            myBlock(nil);
        //        }
        
    }];
    
}
//提现记录
+ (void)requestWithdrawalRcordWithParameters:(NSDictionary *)parameters block:(void (^)(NSMutableArray *))myBlock{
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 20.0f;
    [manager POST:[NSString stringWithFormat:@"%@/mobile/order/getWithdrawal",REQUESTHEADER] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"666666666666666666提现记录记录:%@",responseObject);
        NSArray *listArr = responseObject[@"data"][@"list"];
        
        NSMutableArray *resultArr = [NSMutableArray array];
        for (NSDictionary *dic in listArr) {
            WithdrawalRecordModel *model = [WithdrawalRecordModel createWithModelDic:dic];
            [resultArr addObject:model];
        }
        
        if (myBlock) {
            myBlock(resultArr);
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error.localizedDescription);
        //        if (myBlock) {
        //            myBlock(nil);
        //        }
        
    }];
    
}

+ (void)requestPersonalInfoWithBlock:(void (^)(NSMutableArray *))myBlock{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 20.0f;
    NSString *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userId"];
    [manager POST:[NSString stringWithFormat:@"%@/mobile/user/getMyIndex",REQUESTHEADER] parameters:@{@"userId":userId} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"个人首页信息---->responsObject%@",responseObject);
        
        NSArray *seeArr = responseObject[@"data"][@"seeMe"];
        
        NSMutableArray *resultArr = [[NSMutableArray alloc]init];
        
        for (NSDictionary *dic in seeArr) {
            WhoLookMeModel *lookModel = [WhoLookMeModel createModelWithDic:dic];
            [resultArr addObject:lookModel];
        }
        if (myBlock) {
            myBlock(resultArr);
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
       
        NSLog(@"个人首页信息--->error:%@",error);
        
        if (myBlock) {
            myBlock(nil);
        }
    }];
    
    
    
    
    
    
    
}


#pragma mark   -- -- 个人约会内容
+ (void)requestPersonAppointContentDataWithParameters:(NSDictionary *)parameters Block:(void(^)(NSArray *arr))myBlock{
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 20.0f;
    [manager POST:[NSString stringWithFormat:@"%@/mobile/date/getPersonalDate",REQUESTHEADER] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *arr = responseObject;
        NSLog(@"个人约会内容:%@", arr);
       
        NSArray *listArr = responseObject[@"data"][@"list"];
   
        NSMutableArray *resultArr = [NSMutableArray array];
        for (NSDictionary *dic in listArr) {
            appointModel *dataModel = [appointModel createWithModelDic:dic];
            
            [resultArr addObject:dataModel];
            
        }
        
    
        
        
        if (myBlock) {
            myBlock(resultArr);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error.localizedDescription);
        if (myBlock) {
            myBlock(nil);
            [MBProgressHUD showSuccess:error.localizedDescription];
        }
        
    }];

}

#pragma mark   -- -- 增加谁看过我（马甲）
+ (void)requestAddSeeMeDataWithParameters:(NSDictionary *)parameters Block:(void(^)(NSArray *arr))myBlock{
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 20.0f;
    [manager POST:[NSString stringWithFormat:@"%@/mobile/pool/addAutoSeeMe",REQUESTHEADER] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
       
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"%@",error.localizedDescription);
//        if (myBlock) {
//            myBlock(nil);
//            [MBProgressHUD showSuccess:error.localizedDescription];
//        }
        
    }];
    
}
#pragma mark   -- -- 增加谁看过我的关系
+ (void)requestAddSeeMeRelationshipDataWithParameters:(NSDictionary *)parameters Block:(void(^)(NSArray *arr))myBlock{
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 20.0f;
    [manager POST:[NSString stringWithFormat:@"%@/mobile/user/addSeeMe",REQUESTHEADER] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
    
}

#pragma mark   -- -- 谁看过我
+ (void)requestGetSeeMeDataWithParameters:(NSDictionary *)parameters Block:(void(^)(NSArray *arr))myBlock{
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 20.0f;
    [manager POST:[NSString stringWithFormat:@"%@/mobile/user/getSeeMe",REQUESTHEADER] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *arr = responseObject;
        NSLog(@"谁看过我:%@", arr);
        
        NSArray *listArr = responseObject[@"data"][@"list"];
        
        NSMutableArray *resultArr = [NSMutableArray array];
        for (NSDictionary *dic in listArr) {
            WhoLookMeModel *dataModel = [WhoLookMeModel createModelWithDic:dic];
            
            [resultArr addObject:dataModel];
            
        }
        
        
        
        
        if (myBlock) {
            myBlock(resultArr);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error.localizedDescription);
        if (myBlock) {
            myBlock(nil);
            [MBProgressHUD showSuccess:error.localizedDescription];
        }
        
    }];
    
}
#pragma mark   -- -- 谁评价我
+ (void)requestGetWhoEvaluationMeDataWithParameters:(NSDictionary *)parameters Block:(void(^)(NSArray *arr))myBlock{
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 20.0f;
    [manager POST:[NSString stringWithFormat:@"%@/mobile/user/getPersonalGrade",REQUESTHEADER] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *arr = responseObject;
        NSLog(@"谁评价我:%@", arr);
        
        NSArray *listArr = responseObject[@"data"][@"list"];
        
        NSMutableArray *resultArr = [NSMutableArray array];
        for (NSDictionary *dic in listArr) {
            WhoEvaluationModel *dataModel = [WhoEvaluationModel createModelWithDic:dic];
            
            [resultArr addObject:dataModel];
            
        }
        
        
        
        
        if (myBlock) {
            myBlock(resultArr);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error.localizedDescription);
        if (myBlock) {
            myBlock(nil);
            [MBProgressHUD showSuccess:error.localizedDescription];
        }
        
    }];
    
}
+ (void)requestGetGiftInfomationWithParameters:(NSDictionary *)parameters Block:(void(^)(NSArray *arr))myBlock{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 20.0f;
    [manager POST:[NSString stringWithFormat:@"%@/mobile/order/getOrderGift",REQUESTHEADER] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *arr = responseObject;
        NSLog(@"获取礼物信息:%@", arr);
        
        NSArray *listArr = responseObject[@"data"][@"giftList"];
        
        NSMutableArray *resultArr = [NSMutableArray array];
        for (NSDictionary *dic in listArr) {
            ReceiveGiftModel *dataModel = [ReceiveGiftModel createWithModelDic:dic];
            
            [resultArr addObject:dataModel];
            
        }
        
        
        
        
        if (myBlock) {
            myBlock(resultArr);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error.localizedDescription);
        if (myBlock) {
            myBlock(nil);
            [MBProgressHUD showSuccess:error.localizedDescription];
        }
        
    }];

}

#pragma mark   -- -- 判断用户是否购买过
+ (void)requestCheckUserIsBuyedWithParameters:(NSDictionary *)parameters Block:(void(^)(NSArray *arr))myBlock{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 20.0f;
    [manager POST:[NSString stringWithFormat:@"%@/mobile/order/getOrderRecord",REQUESTHEADER] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([[NSString stringWithFormat:@"%@", responseObject[@"code"]] isEqualToString:@"200"]) {
            NSArray*resultArr = responseObject[@"data"];
            if (myBlock) {
                myBlock(resultArr);
            }
        }else {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@", responseObject[@"errorMsg"]]];
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error.localizedDescription);
        if (myBlock) {
            myBlock(nil);
            [MBProgressHUD showSuccess:error.localizedDescription];
        }
        
    }];
}
#pragma mark   -- -- 消耗钥匙
+ (void)requestSpendUserKeyWithParameters:(NSDictionary *)parameters Block:(void(^)(NSString *codeStr))myBlock{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer.timeoutInterval = 20.0f;
    [manager POST:[NSString stringWithFormat:@"%@/mobile/order/updateOrderKey",REQUESTHEADER] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (myBlock) {
            myBlock([NSString stringWithFormat:@"%@", responseObject[@"code"]]);
            
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error.localizedDescription);
        if (myBlock) {
            myBlock(nil);
            [MBProgressHUD showSuccess:error.localizedDescription];
        }
        
    }];
    
}


#pragma mark   -- -- 花费金币
+ (void)requestSpendGoldsWithParameters:(NSDictionary *)parameters Block:(void(^)(NSString *codeStr))myBlock{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer.timeoutInterval = 20.0f;
    [manager POST:[NSString stringWithFormat:@"%@/mobile/order/updateOrderGold",REQUESTHEADER] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
       
           
            if (myBlock) {
                myBlock([NSString stringWithFormat:@"%@", responseObject[@"code"]]);
               
            }

            
            
      
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error.localizedDescription);
        if (myBlock) {
            myBlock(nil);
            [MBProgressHUD showSuccess:error.localizedDescription];
        }
        
    }];
    
}

#pragma mark   -- -- 邀请类消息
+ (void)requestGtSystemInviteDataWithParameters:(NSDictionary *)parameters Block:(void(^)(NSArray *arr))myBlock{
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 20.0f;
    [manager POST:[NSString stringWithFormat:@"%@/mobile/circle/getSystemInvite",REQUESTHEADER] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *arr = responseObject;
        NSLog(@"邀请类消息:%@", arr);
        
        NSArray *listArr = responseObject[@"data"][@"list"];
        
        NSMutableArray *resultArr = [NSMutableArray array];
        for (NSDictionary *dic in listArr) {
           InvitaModel  *dataModel = [InvitaModel createModelWithDic:dic];
            
            [resultArr addObject:dataModel];
            
        }
        
        
        
        
        if (myBlock) {
            myBlock(resultArr);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error.localizedDescription);
        if (myBlock) {
            myBlock(nil);
            [MBProgressHUD showSuccess:error.localizedDescription];
        }
        
    }];
    
}
#pragma mark   -- -- 获取金币消耗
+ (void)requestGettUserWithdrawalDetailDataWithParameters:(NSDictionary *)parameters Block:(void(^)(NSArray *arr))myBlock{
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 20.0f;
    [manager POST:[NSString stringWithFormat:@"%@/mobile/order/getUserWithdrawalDetail",REQUESTHEADER] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *arr = responseObject;
        NSLog(@"获取金币消耗:%@", arr);
        
        NSArray *listArr = responseObject[@"data"];
        
        NSMutableArray *resultArr = [NSMutableArray array];
        for (NSDictionary *dic in listArr) {
            GoldsRecordModel *dataModel = [GoldsRecordModel createWithModelDic:dic];
            
            [resultArr addObject:dataModel];
            
        }
        
        
        
        
        if (myBlock) {
            myBlock(resultArr);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error.localizedDescription);
        if (myBlock) {
            myBlock(nil);
            [MBProgressHUD showSuccess:error.localizedDescription];
        }
        
    }];
    
}
#pragma mark   -- -- 获取通话消耗
+ (void)requestGetUserGoldOrPointDetailDataWithParameters:(NSDictionary *)parameters Block:(void(^)(NSArray *arr))myBlock{
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer.timeoutInterval = 20.0f;
    [manager POST:[NSString stringWithFormat:@"%@/mobile/order/getUserGoldOrPointDetail",REQUESTHEADER] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *arr = responseObject;
        NSLog(@" 获取通话消耗:%@", arr);
        
        NSArray *listArr = responseObject[@"data"];
        
        NSMutableArray *resultArr = [NSMutableArray array];
        for (NSDictionary *dic in listArr) {
            GoldsRecordModel *dataModel = [GoldsRecordModel createWithModelDic:dic];
            
            [resultArr addObject:dataModel];
            
        }
        
        
        
        
        if (myBlock) {
            myBlock(resultArr);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error.localizedDescription);
        if (myBlock) {
            myBlock(nil);
            [MBProgressHUD showSuccess:error.localizedDescription];
        }
        
    }];
    
}

+ (void)postHttpRequestByGet:(NSString *)requestUrl andParameter:(NSDictionary *)requestDict success:(void (^)(id))successBlock andFailure:(void (^)(id))failureBlock {

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

    manager.requestSerializer.timeoutInterval = 20.0;

    [manager GET:requestUrl parameters:requestDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        successBlock(responseObject);
    }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            MLOG(@"\n请求失败 原因 : %@", error);
            failureBlock(error);
        }];
}



@end
