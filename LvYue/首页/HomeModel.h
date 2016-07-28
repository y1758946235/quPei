//
//  HomeModel.h
//  LvYue
//
//  Created by 広有射怪鸟事 on 15/10/22.
//  Copyright © 2015年 OLFT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HomeModel : NSObject

@property (nonatomic,strong) NSString *age;
@property (nonatomic,strong) NSString *auth_car;
@property (nonatomic,strong) NSString *auth_edu;
@property (nonatomic,strong) NSString *auth_identity;
@property (nonatomic,strong) NSString *auth_video; //是否认证视频
@property (nonatomic,strong) NSString *distance;
@property (nonatomic,strong) NSString *edu;
@property (nonatomic,strong) NSString *icon;
@property (nonatomic,strong) NSString *id;
@property (nonatomic,strong) NSString *is_show;
@property (nonatomic,strong) NSString *mobile;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *score;
@property (nonatomic,strong) NSString *sex;
@property (nonatomic,strong) NSString *signature;
@property (nonatomic,strong) NSString *skillDetail;
@property (nonatomic,strong) NSString *status;
@property (nonatomic,strong) NSString *type;
@property (nonatomic,strong) NSString *vip;
@property (nonatomic,strong) NSArray *photos;
@property (nonatomic,strong) NSArray *visit;
@property (nonatomic,strong) UIImage *image;
@property (nonatomic,strong) NSString *img;
@property (nonatomic,assign) CGFloat imageHeight;
@property (nonatomic,assign) CGFloat textHeight;
@property (nonatomic,assign) CGFloat cellHeight;
@property (nonatomic,assign) BOOL    isShowAction;

- (id)initWithDict:(NSDictionary *)dict;

@end
