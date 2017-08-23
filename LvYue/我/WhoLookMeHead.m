//
//  WhoLookMeHead.m
//  LvYue
//
//  Created by X@Han on 16/12/20.
//  Copyright © 2016年 OLFT. All rights reserved.
//

#import "WhoLookMeHead.h"
#import "LYHttpPoster.h"
#import "AFNetworking.h"
#import "MBProgressHUD+NJ.h"
#import "UIImageView+WebCache.h"
#import "WhoLookMeHeadModel.h"

@interface WhoLookMeHead (){
    NSArray * imageArr;
   
    NSMutableArray *resultArr;
    
    WhoLookMeHeadModel *model;
}

@end

@implementation WhoLookMeHead

- (UIView *)initCellWithIndex:(NSIndexPath*)index{
    
    self = [super init];
    if (self) {
      
        if (index.section==1&&index.row==1) {
            resultArr = [[NSMutableArray alloc]init];
            self.frame = CGRectMake(0, 0, SCREEN_WIDTH, 56);
           // [self setFirstSection];
            [self getData];
        }
       
    }
    
    return self;
    
}

- (void)getData{
    
      NSString *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userId"];
    
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/user/getMyIndex",REQUESTHEADER] andParameter:@{@"userId":userId} success:^(id successResponse) {
        
        
        
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            imageArr = successResponse[@"data"][@"seeMe"];
          
            
            for (NSDictionary *dic in imageArr) {
               model = [WhoLookMeHeadModel creModelWithDic:dic];
                [resultArr addObject:model.hadImage];
            }
         
            if (resultArr) {
                [self setFirstSection];
            }
        
        }else{
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
        }
        
    } andFailure:^(id failureResponse) {
        [MBProgressHUD showError:@"服务器繁忙,请重试"];
        NSLog(@"失败:%@",failureResponse);
    }];
    
    
    
}

- (void)setFirstSection{
    
    
   for (NSInteger i= 0; i<resultArr.count; i++) {
       UIImageView *image = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-32-(i+1)*32, 16, 24, 24)];
       
       
        image.layer.cornerRadius = 12;
        image.clipsToBounds = YES;
       
       
       //这个是图片的名字
       
       NSURL *imageUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEHEADER,resultArr[i]]];
       
       [image sd_setImageWithURL:imageUrl];
       
        [self addSubview:image]; 
       
    }
    
}


@end
