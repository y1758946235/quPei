//
//  ktvTableView.m
//  LvYue
//
//  Created by X@Han on 17/1/1.
//  Copyright © 2017年 OLFT. All rights reserved.
//

#import "ktvTableView.h"
#import "LYHttpPoster.h"
#import "MBProgressHUD+NJ.h"
#import "AppointTableCell.h"
#import "appointModel.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"

@interface ktvTableView ()<UITableViewDelegate,UITableViewDataSource>{
    UITableView *appointTable;
}

@property(nonatomic,strong)NSMutableArray  *dateTypeArr;   //约会的类型
@end

@implementation  ktvTableView
//约会吧  下方数据数组
- (NSMutableArray *)dateTypeArr{
    if (!_dateTypeArr) {
        _dateTypeArr = [[NSMutableArray alloc]init];
    }
    return _dateTypeArr;
}


- (id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if (self) {
        [self getAppointData];
    }
    return self;
}


#pragma mark   -----下方的约的内容
- (void)appointContent{
    appointTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-56) style:UITableViewStylePlain];
    appointTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    appointTable.rowHeight = 607;
    appointTable.delegate = self;
    appointTable.dataSource = self;
    [self addSubview:appointTable];
    
    
}



#pragma mark  -----下方约的数据
- (void)getAppointData{
//    [LYHttpPoster requestAppointContentDataWithTypeId:@"4" Block:^(NSArray *arr) {
//        [self.dateTypeArr addObjectsFromArray:arr];
//        [self appointContent];
//        [appointTable reloadData];
//        
//        
//        
//    }];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dateTypeArr.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    AppointTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[AppointTableCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    
    
    
    appointModel *aModel = self.dateTypeArr[indexPath.row];
    if (aModel) {
        
        
        for (UIView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
            
        }
       
//        [cell createCell:aModel];
        [cell.otherHomeBtn addTarget:self action:@selector(goOtherHome:) forControlEvents:UIControlEventTouchUpInside];
        
        //对约会感兴趣
        [cell.intreBtn addTarget:self action:@selector(instred:) forControlEvents:UIControlEventTouchUpInside];
        //聊天
        [cell.chatBtn addTarget:self action:@selector(chat:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    
    
    return cell;
}


#pragma mark  ---对约会感兴趣
- (void)instred:(UIButton *)sender{
    
    //  NSString *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userId"];
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/date/addInterestDate",REQUESTHEADER] andParameter:@{@"userId":@"1000006",@"dateActivityId":@"1",@"otherUserId":@"1000001"} success:^(id successResponse) {
        
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            [MBProgressHUD showSuccess:@"感兴趣成功"];
        }
        
    } andFailure:^(id failureResponse) {
        
    }];
    
    
    
}

#pragma mark  --聊天
- (void)chat:(UIButton *)sender{
    
    
    
}

- (void)goOtherHome:(UIButton *)sender{
    
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"push" object:nil userInfo:@{@"push":@"otherHome"}];
    
}



#pragma mark   ----------时间戳转换成时间
- (NSString *)transformTime:(NSString *)time{
    
    
    
    NSInteger num = [time integerValue]/1000;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    
    NSDate *contime = [NSDate dateWithTimeIntervalSince1970:num];
    NSString *conTimeStr = [formatter stringFromDate:contime];
    
    return conTimeStr;    
    
}

@end
