//
//  AppDelegate.h
//  LvYue
//
//  Created by apple on 15/9/28.
//  Copyright (c) 2015年 OLFT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootTabBarController.h"
#import "WXApi.h"
#import "FMDB.h"
#import "BMapKit.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    EMConnectionState _connectionState;
    enum WXScene _scene;
    BMKMapManager *_mapManager;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) RootTabBarController *rootTabC;

//设备DeviceToken
@property (nonatomic, strong) NSString *deviceToken;

//本地数据库(与本地服务器交互的数据库，非环信自带的数据库)
@property (nonatomic, strong) FMDatabase *dataBase;
//多线程操作数据库的同步约束队列
@property (nonatomic, strong) FMDatabaseQueue *dataBaseQueue;

//当前的系统消息数量
@property (nonatomic, assign) NSInteger unReadSystemMessageNum;

@end

