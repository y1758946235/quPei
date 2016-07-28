//
//  MyInfomationViewController.h
//  澜庭
//
//  Created by 广有射怪鸟事 on 15/9/25.
//  Copyright (c) 2015年 刘瀚韬. All rights reserved.
//

#import "BaseViewController.h"

@interface MyInfomationViewController : BaseViewController

@property (nonatomic,strong) UIImage *headImage;

@property (nonatomic,strong) NSString *userSex;//用户性别，0为男，1为女
@property (nonatomic,strong) NSString *introduceString;//个人介绍string
@property (nonatomic,strong) NSString *userName;//用户姓名
@property (nonatomic,strong) NSString *userAge;//用户年龄
@property (nonatomic,strong) NSMutableArray *serviceArray;//服务项目数组
@property (nonatomic,copy) NSMutableString *signString; //标签可变string
@property (nonatomic,strong) NSString *locationString;//地区string
@property (nonatomic,strong) NSString *serviceMoneyString;//服务价格string
@property (nonatomic,strong) NSString *jobString;//行业string
@property (nonatomic,assign) int showCode;//是否显示全部号码,1为显示，2为不显示
@property (nonatomic,strong) NSString *codeString;//豆客账号
@property (nonatomic,strong) NSString *canLive;//是否提供住宿，0为否，1为是
@property (nonatomic,strong) NSString *userEmail;//邮箱
@property (nonatomic,strong) NSString *isKnowSex;//是否认证性别,0为否，1为正在，2为是
@property (nonatomic,strong) NSString *isKnowStudy;//是否认证学历，1为是，2为否
@property (nonatomic,strong) NSString *isVip;//是否是vip，1为是，0为普通用户
@property (nonatomic,strong) NSString *edu;//学历
@property (nonatomic,assign) NSInteger star;//星级
@property (nonatomic,assign) NSInteger id;//id
@property (nonatomic,strong) NSString *vip_time;//会员到期时间
@property (nonatomic,assign) NSInteger type;//是否导游。0为否，1 为是
@property (nonatomic,strong) NSString *is_show;//是否显示豆客账号null和0是不可，1是可以

@end
