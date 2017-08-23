//
//  MyContactView.m
//  LvYue
//
//  Created by X@Han on 16/12/15.
//  Copyright © 2016年 OLFT. All rights reserved.

#define WIDTH self.frame.size.width
#define HEIGHT self.frame.size.height

#import "MyContactView.h"
#import "FriendTableView.h"
#import "ContactTableView.h"
#import "FansTableView.h"
#import "BlackListTableView.h"

@interface MyContactView (){
    UIButton *currentBut;
    UIView *currentView;
}

@property (nonatomic,strong) UILabel *line;
@property (nonatomic,strong) FriendTableView *friend;
@property (nonatomic,strong) ContactTableView *contact;
@property (nonatomic,strong) FansTableView *fans;
@property (nonatomic,strong) BlackListTableView *black;

@end

@implementation MyContactView

- (instancetype)initWithFrame:(CGRect)frame{
    
    
    self = [super initWithFrame:frame];
    if (self) {
        [self setTopBut];
        [self rigisterAllNotifications];
    }
    return self;
    
}
//注册通知
- (void)rigisterAllNotifications {
     
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updataFirendList:) name:@"LY_friend" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updataContactList:) name:@"LY_contact" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updataFansList:) name:@"LY_fans" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updataBlackList:) name:@"LY_black" object:nil];
   
     
}

-(void)updataFirendList:(NSNotification *)aNotification{
    self.redDotFriendsLabel.hidden = YES;
    [self updateFriendTag];
    [_friend postRequest];
}
-(void)updataContactList:(NSNotification *)aNotification{
    [_contact getData];

}
-(void)updataFansList:(NSNotification *)aNotification{
    self.redDotFansLabel.hidden = YES;
    [self updateAttentionTag];
    [_fans getData];
   
}
-(void)updataBlackList:(NSNotification *)aNotification{
    
    [_black getData];
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
   
}
- (void)setTopBut{
    NSArray *title = @[@"好友",@"关注",@"粉丝",@"黑名单"];
    for (NSInteger i =0; i<title.count; i++) {
        UIButton *topBut = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:topBut];
        topBut.frame = CGRectMake(16+(60+(self.frame.size.width-32-240)/3.0)*i, 0, 60, 29);
        topBut.titleLabel.font = [UIFont systemFontOfSize:13];
        [topBut setTitle:title[i] forState:UIControlStateNormal];
        [topBut setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
        [topBut setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        
        if (i==0) {
            topBut.selected = YES;
            currentBut = topBut;
            UILabel *line = [[UILabel alloc]initWithFrame:CGRectMake(topBut.frame.origin.x, 29, 60, 1)];
            [self addSubview:line];
            line.backgroundColor = [UIColor redColor];
            _line = line;
            
            _friend =[[FriendTableView alloc]initWithFrame:CGRectMake(0, 30, WIDTH, HEIGHT)];
             [_friend postRequest];
            [self addSubview:_friend];
            currentView = _friend;
            
            self.redDotFriendsLabel = [[UILabel alloc]init];
            self.redDotFriendsLabel.frame = CGRectMake(45, 3, 6, 6);
            self.redDotFriendsLabel.layer.cornerRadius = 3;
            self.redDotFriendsLabel.clipsToBounds= YES;
            self.redDotFriendsLabel.backgroundColor = [UIColor  colorWithHexString:@"#ff5252"];
            self.redDotFriendsLabel.hidden = YES;
            [topBut addSubview:self.redDotFriendsLabel];
        }
       
        if (i==2) {
            self.redDotFansLabel = [[UILabel alloc]init];
            self.redDotFansLabel.frame = CGRectMake(45, 3, 6, 6);
            self.redDotFansLabel.layer.cornerRadius = 3;
            self.redDotFansLabel.clipsToBounds= YES;
            self.redDotFansLabel.backgroundColor = [UIColor  colorWithHexString:@"#ff5252"];
            self.redDotFansLabel.hidden = YES;
            [topBut addSubview:self.redDotFansLabel];
        }
        [topBut addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
}

- (void)click:(UIButton *)sender {
    
    if (sender == currentBut) {
        return;
    }
    
    if ([sender.currentTitle isEqualToString:@"好友"]) {
        if (!_friend) {
            _friend =[[FriendTableView alloc]initWithFrame:CGRectMake(0, 30, WIDTH, HEIGHT)];
        }
        [_friend postRequest];
        [currentView removeFromSuperview];
        [self addSubview:_friend];
        currentView = _friend;
        
         self.redDotFriendsLabel.hidden = YES;
        [self updateFriendTag];
    }else if ([sender.currentTitle isEqualToString:@"关注"]){
        if (!_contact) {
            _contact =[[ContactTableView alloc]initWithFrame:CGRectMake(0, 30, WIDTH, HEIGHT)];
        }
        [_contact getData];
        [currentView removeFromSuperview];
        [self addSubview:_contact];
        currentView = _contact;
        
       
    }else if ([sender.currentTitle isEqualToString:@"粉丝"]){
        if (!_fans) {
            _fans =[[FansTableView alloc]initWithFrame:CGRectMake(0, 30, WIDTH, HEIGHT)];
        }
        [_fans getData];
        [currentView removeFromSuperview];
        [self addSubview:_fans];
        currentView = _fans;
        
        self.redDotFansLabel.hidden = YES;
        
        [self updateAttentionTag];
    }else if ([sender.currentTitle isEqualToString:@"黑名单"]){
        if (!_black) {
            _black =[[BlackListTableView alloc]initWithFrame:CGRectMake(0, 30, WIDTH, HEIGHT)];
        }
        [_black getData];
        [currentView removeFromSuperview];
        [self addSubview:_black];
        currentView = _black;
    }else {
        
    }
    
    
    sender.selected = YES;
    currentBut.selected = NO;
    currentBut = sender;
    _line.frame = CGRectMake(currentBut.frame.origin.x, _line.frame.origin.y, _line.frame.size.width, _line.frame.size.height);

}
-(void)updateFriendTag{
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/circle/updateFriendTag",REQUESTHEADER] andParameter:@{@"userId":[CommonTool  getUserID]} success:^(id successResponse) {
        
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
            self.redDotFriendsLabel.hidden = YES;
        }else{
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
        }
    } andFailure:^(id failureResponse) {
        
    }];
    
}

-(void)updateAttentionTag{
    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/circle/updateAttentionTag",REQUESTHEADER] andParameter:@{@"userId":[CommonTool  getUserID]} success:^(id successResponse) {
        
        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
       self.redDotFansLabel.hidden = YES;
            
        }else{
            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
        }
    } andFailure:^(id failureResponse) {
        
    }];
}


//- (void)postRequest {
//
//    [_modelArray removeAllObjects];
//    [_sortedContractArray removeAllObjects];
//
//    NSString *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userId"];
//    [LYHttpPoster postHttpRequestByPost:[NSString stringWithFormat:@"%@/mobile/circle/getFriend",REQUESTHEADER] andParameter:@{@"userId":userId} success:^(id successResponse) {
//        if ([[NSString stringWithFormat:@"%@",successResponse[@"code"]] isEqualToString:@"200"]) {
//            MLOG(@"我的好友列表:%@",successResponse);
//            NSArray *list = successResponse[@"data"];
//            for (NSDictionary *dict in list) {
//                FriendModel *model = [[FriendModel alloc]initWithModelDic:dict];
//                [_modelArray addObject:model];
//            }
//            _sortedContractArray = [self sortDataArray:_modelArray];
//            MLOG(@"排好序的model : %@",_sortedContractArray);
//
//        } else {
//            [MBProgressHUD showError:[NSString stringWithFormat:@"%@",successResponse[@"errorMsg"]]];
//        }
//    } andFailure:^(id failureResponse) {
//        [MBProgressHUD showError:@"服务器繁忙,请重试"];
//    }];
//
//
//
//    //    [kAppDelegate.dataBaseQueue inDatabase:^(FMDatabase *db) {
//    //        //如果数据库打开成功
//    //        if ([kAppDelegate.dataBase open]) {
//    //            appointModel *model = self.dateTypeArr[tag];
//    //            NSString *huanxinUserId = [NSString stringWithFormat:@"qp%@",model.otherId];
//    //            //            for (MyBuddyModel *model in self.dateTypeArr) {
//    //            //如果用户模型在本地数据库表中没有，则插入，否则更新
//    //            NSString *findSql = [NSString stringWithFormat:@"SELECT * FROM '%@' WHERE userID = '%@'",@"User",huanxinUserId];
//    //            FMResultSet *result = [kAppDelegate.dataBase executeQuery:findSql];
//    //            if ([result resultCount]) { //如果查询结果有数据
//    //                //更新对应数据
//    //                NSString *updateSql = [NSString stringWithFormat:@"UPDATE '%@' SET name = '%@',remark = '%@',icon = '%@' WHERE userID = '%@'",@"User",model.nickName,model.remark,[NSString stringWithFormat:@"%@%@",IMAGEHEADER,model.headImage],huanxinUserId];
//    //                BOOL isSuccess = [kAppDelegate.dataBase executeUpdate:updateSql];
//    //                if (isSuccess) {
//    //                    MLOG(@"更新数据成功!");
//    //                } else {
//    //                    MLOG(@"更新数据失败!");
//    //                }
//    //            } else { //如果查询结果没有数据
//    //                //插入相应数据
//    //                NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO '%@'('%@','%@','%@','%@') VALUES('%@','%@','%@','%@')",@"User",@"userID",@"name",@"remark",@"icon",huanxinUserId,model.nickName,model.remark,[NSString stringWithFormat:@"%@%@",IMAGEHEADER,model.headImage]];
//    //                BOOL isSuccess = [kAppDelegate.dataBase executeUpdate:insertSql];
//    //                if (isSuccess) {
//    //                    MLOG(@"插入数据成功!");
//    //                } else {
//    //                    MLOG(@"插入数据失败!");
//    //                }
//    //            }
//    //            //            }
//    //            [kAppDelegate.dataBase close];
//    //        } else {
//    //            MLOG(@"\n本地数据库更新失败\n");
//    //        }
//    //    }];
//
//}







@end
